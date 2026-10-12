import Foundation
import CoreServices

// File system events for a few folders (FSEvents, recursive). Replaces polling:
// the collector runs when a hook writes, a session file appears, or a rollout grows.
final class FileWatcher {
    private var stream: FSEventStreamRef?
    private let paths: [String]
    private let queue: DispatchQueue
    private let handler: (Set<String>) -> Void

    init(paths: [URL], queue: DispatchQueue, handler: @escaping (Set<String>) -> Void) {
        self.paths = Array(Set(paths.map { $0.path }))
        self.queue = queue
        self.handler = handler
    }

    func start(latency: TimeInterval = 0.3) {
        stop()
        guard !paths.isEmpty else { return }
        var context = FSEventStreamContext(version: 0, info: Unmanaged.passUnretained(self).toOpaque(), retain: nil, release: nil, copyDescription: nil)
        let callback: FSEventStreamCallback = { _, info, count, eventPaths, _, _ in
            guard let info = info else { return }
            let watcher = Unmanaged<FileWatcher>.fromOpaque(info).takeUnretainedValue()
            let list = unsafeBitCast(eventPaths, to: NSArray.self) as? [String] ?? []
            watcher.handler(Set(list.prefix(count)))
        }
        let flags = UInt32(kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagNoDefer)
        guard let created = FSEventStreamCreate(kCFAllocatorDefault, callback, &context, paths as CFArray,
                                                FSEventStreamEventId(kFSEventStreamEventIdSinceNow), latency, flags) else { return }
        FSEventStreamSetDispatchQueue(created, queue)
        FSEventStreamStart(created)
        stream = created
    }

    func stop() {
        guard let stream = stream else { return }
        FSEventStreamStop(stream)
        FSEventStreamInvalidate(stream)
        FSEventStreamRelease(stream)
        self.stream = nil
    }

    deinit { stop() }
}

// A small log with a size limit, instead of an ever-growing stdout file.
enum AppLog {
    static let limit = 256 * 1024
    private static let queue = DispatchQueue(label: "app.log")

    static func write(_ message: String, to url: URL = AppPaths().log) {
        queue.async {
            let line = "\(formatDate(Date())) \(message)\n"
            try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            if let size = (try? FileManager.default.attributesOfItem(atPath: url.path))?[.size] as? NSNumber, size.intValue > limit,
               let data = try? Data(contentsOf: url) {
                // Keep the newer half.
                try? data.suffix(limit / 2).write(to: url, options: .atomic)
            }
            if let handle = FileHandle(forWritingAtPath: url.path) {
                handle.seekToEndOfFile()
                handle.write(Data(line.utf8))
                try? handle.close()
            } else {
                FileManager.default.createFile(atPath: url.path, contents: Data(line.utf8), attributes: [.posixPermissions: 0o600])
            }
        }
    }
}
