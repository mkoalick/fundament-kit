import Foundation
import Darwin

// Process facts straight from the kernel (sysctl, libproc). No `ps` or `lsof`
// child processes, so checking a dozen sessions costs a few system calls.
enum ProcessInspector {
    struct Info: Equatable {
        let pid: Int32
        let parent: Int32
        let name: String
        let startedAt: Date
    }

    static func info(_ pid: Int32) -> Info? {
        guard pid > 0 else { return nil }
        var process = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, pid]
        guard sysctl(&mib, 4, &process, &size, nil, 0) == 0, size > 0, process.kp_proc.p_pid == pid else { return nil }
        let name = withUnsafePointer(to: process.kp_proc.p_comm) {
            $0.withMemoryRebound(to: CChar.self, capacity: Int(MAXCOMLEN) + 1) { String(cString: $0) }
        }
        let start = process.kp_proc.p_starttime
        return Info(pid: pid, parent: process.kp_eproc.e_ppid, name: name,
                    startedAt: Date(timeIntervalSince1970: TimeInterval(start.tv_sec) + TimeInterval(start.tv_usec) / 1_000_000))
    }

    // Alive and still the same process: a reused PID has a different start time.
    static func isAlive(_ pid: Int32, startedAt: Date? = nil) -> Bool {
        guard let info = info(pid) else { return false }
        guard let startedAt = startedAt else { return true }
        return abs(info.startedAt.timeIntervalSince(startedAt)) < 1
    }

    // The first ancestor that is not a shell: the program that ran the hook command.
    static func callingProgram(of pid: Int32 = getppid(), maxDepth: Int = 4) -> Info? {
        let shells: Set<String> = ["sh", "bash", "zsh", "dash", "fish", "env"]
        var current = info(pid)
        var depth = 0
        while let candidate = current, shells.contains(candidate.name), depth < maxDepth {
            current = info(candidate.parent)
            depth += 1
        }
        return current
    }

    static func allPids() -> [Int32] {
        let count = proc_listallpids(nil, 0)
        guard count > 0 else { return [] }
        var pids = [Int32](repeating: 0, count: Int(count) + 32)
        let filled = proc_listallpids(&pids, Int32(pids.count * MemoryLayout<Int32>.size))
        guard filled > 0 else { return [] }
        return Array(pids.prefix(Int(filled))).filter { $0 > 0 }
    }

    static func pids(named name: String) -> [Int32] {
        allPids().filter { info($0)?.name == name }
    }

    // Paths of the regular files a process has open (what `lsof -p` would list).
    static func openFiles(_ pid: Int32) -> [String] {
        let bytes = proc_pidinfo(pid, PROC_PIDLISTFDS, 0, nil, 0)
        guard bytes > 0 else { return [] }
        let stride = MemoryLayout<proc_fdinfo>.stride
        var fds = [proc_fdinfo](repeating: proc_fdinfo(), count: Int(bytes) / stride + 16)
        let filled = proc_pidinfo(pid, PROC_PIDLISTFDS, 0, &fds, Int32(fds.count * stride))
        guard filled > 0 else { return [] }
        var paths: [String] = []
        for fd in fds.prefix(Int(filled) / stride) where fd.proc_fdtype == UInt32(PROX_FDTYPE_VNODE) {
            var vnode = vnode_fdinfowithpath()
            let size = Int32(MemoryLayout<vnode_fdinfowithpath>.stride)
            guard proc_pidfdinfo(pid, fd.proc_fd, PROC_PIDFDVNODEPATHINFO, &vnode, size) == size else { continue }
            let path = withUnsafePointer(to: vnode.pvip.vip_path) {
                $0.withMemoryRebound(to: CChar.self, capacity: Int(MAXPATHLEN)) { String(cString: $0) }
            }
            if !path.isEmpty { paths.append(path) }
        }
        return paths
    }
}
