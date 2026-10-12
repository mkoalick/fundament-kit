import Foundation

// Adds the app's hooks to Claude Code's settings.json and removes them again.
// It edits the file as text: it appends its own entries at the end of the
// relevant arrays and deletes exactly those entries later. Everything else in
// the file keeps its bytes. Before writing, it checks that its edits replaced
// nothing but whitespace and that the file, minus its entries, means the same.
struct ClaudeHookInstaller {
    struct Hook: Equatable {
        let event: String
        let matcher: String?
    }

    // Long-standing hook events only: an unknown event name could make an older
    // Claude Code reject the whole settings file.
    static let hooks: [Hook] = [
        Hook(event: "SessionStart", matcher: nil),
        Hook(event: "UserPromptSubmit", matcher: nil),
        Hook(event: "PreToolUse", matcher: "AskUserQuestion"),
        Hook(event: "PostToolUse", matcher: nil),
        Hook(event: "Notification", matcher: nil),
        Hook(event: "Stop", matcher: nil),
        Hook(event: "SessionEnd", matcher: nil)
    ]

    enum State: Equatable { case notInstalled, installed, outdated }

    enum Failure: Error, Equatable, CustomStringConvertible {
        case invalidJSON(String)
        case unexpectedShape(String)
        case verificationFailed
        case changedWhileWriting
        var description: String {
            switch self {
            case .invalidJSON(let detail): return "settings.json is not valid JSON (\(detail)); nothing was changed."
            case .unexpectedShape(let detail): return "settings.json has an unexpected shape (\(detail)); nothing was changed."
            case .verificationFailed: return "The change would have touched other entries; nothing was changed."
            case .changedWhileWriting: return "settings.json kept changing while writing; nothing was changed."
            }
        }
    }

    let helperPath: String
    let marker: String
    var timeout = 10

    init(helperPath: String, marker: String = AppIdentity.hookMarker) {
        self.helperPath = helperPath
        self.marker = marker
    }

    // Shell form, so a removed app ends silently instead of raising hook errors.
    var command: String {
        let quoted = "'" + helperPath.replacingOccurrences(of: "'", with: "'\\''") + "'"
        return "[ -x \(quoted) ] && \(quoted) claude-hook; true # \(marker)"
    }

    // MARK: - Reading

    private struct Parsed {
        let bytes: [UInt8]
        let root: JSONSpan
        let hooks: JSONSpan?
    }

    private func parse(_ bytes: [UInt8]) throws -> Parsed? {
        if bytes.allSatisfy({ [0x20, 0x09, 0x0A, 0x0D].contains($0) }) { return nil }
        let root: JSONSpan
        do { root = try JSONSpanParser.parse(bytes) } catch { throw Failure.invalidJSON("\(error)") }
        guard root.kind == .object else { throw Failure.unexpectedShape("the top level is not an object") }
        // A key twice: every JSON reader keeps the last one, this one would edit the
        // first. Refuse instead of writing entries that would never take effect.
        if root.members.filter({ $0.key == "hooks" }).count > 1 {
            throw Failure.unexpectedShape("\"hooks\" appears more than once")
        }
        let hooks = root.member("hooks")
        if let hooks = hooks {
            let events = hooks.members.map { $0.key }
            if Set(events).count != events.count { throw Failure.unexpectedShape("an event appears more than once in \"hooks\"") }
            guard hooks.kind == .object else { throw Failure.unexpectedShape("\"hooks\" is not an object") }
            for member in hooks.members where member.value.kind != .array {
                throw Failure.unexpectedShape("\"hooks.\(member.key)\" is not a list")
            }
        }
        return Parsed(bytes: bytes, root: root, hooks: hooks)
    }

    // A matcher group is ours when every command handler in it has exactly the
    // shape this installer writes (any helper path), not merely the marker word.
    private func isOurs(_ group: JSONSpan) -> Bool {
        guard group.kind == .object, let handlers = group.member("hooks"), handlers.kind == .array,
              !handlers.elements.isEmpty else { return false }
        return handlers.elements.allSatisfy { handler in
            guard let command = handler.member("command")?.string else { return false }
            return ClaudeHookInstaller.isOwnCommand(command, marker: marker)
        }
    }

    static func isOwnCommand(_ command: String, marker: String) -> Bool {
        command.hasPrefix("[ -x '") && command.hasSuffix(" claude-hook; true # \(marker)")
            && command.contains("' ] && '")
    }

    private func isCurrent(_ group: JSONSpan, for hook: Hook) -> Bool {
        guard let handlers = group.member("hooks"), handlers.elements.count == 1,
              let handler = handlers.elements.first,
              handler.member("command")?.string == command,
              handler.member("type")?.string == "command" else { return false }
        return group.member("matcher")?.string == hook.matcher
    }

    func state(of data: Data?) throws -> State {
        guard let parsed = try parse(Array(data ?? Data())), let hooks = parsed.hooks else { return .notInstalled }
        var any = false
        var complete = true
        var extra = false
        for member in hooks.members {
            let ours = member.value.elements.filter(isOurs)
            any = any || !ours.isEmpty
            if let hook = ClaudeHookInstaller.hooks.first(where: { $0.event == member.key }) {
                if ours.count != 1 || !isCurrent(ours[0], for: hook) { complete = false }
            } else if !ours.isEmpty { extra = true }
        }
        for hook in ClaudeHookInstaller.hooks where hooks.member(hook.event) == nil { complete = false }
        if !any { return .notInstalled }
        return complete && !extra ? .installed : .outdated
    }

    // MARK: - Text edits

    private struct Edit {
        let start: Int
        let end: Int
        let text: [UInt8]
    }

    private func apply(_ edits: [Edit], to bytes: [UInt8]) -> [UInt8] {
        var result = bytes
        for edit in edits.sorted(by: { $0.start > $1.start }) {
            result.replaceSubrange(edit.start..<edit.end, with: edit.text)
        }
        return result
    }

    private func lineIndent(before offset: Int, in bytes: [UInt8]) -> [UInt8] {
        var start = offset
        while start > 0, bytes[start - 1] != 0x0A { start -= 1 }
        var end = start
        while end < bytes.count, bytes[end] == 0x20 || bytes[end] == 0x09 { end += 1 }
        return Array(bytes[start..<end])
    }

    // Indent unit and line break as the file already uses them.
    private func style(of bytes: [UInt8], root: JSONSpan?) -> (unit: [UInt8], newline: [UInt8]) {
        let newline: [UInt8] = bytes.firstIndex(of: 0x0A).map { $0 > 0 && bytes[$0 - 1] == 0x0D } == true ? [0x0D, 0x0A] : [0x0A]
        if let first = root?.members.first {
            let indent = lineIndent(before: first.keyStart, in: bytes)
            if !indent.isEmpty, root.map({ lineIndent(before: $0.start, in: bytes).isEmpty }) ?? true { return (indent, newline) }
        }
        return (Array("  ".utf8), newline)
    }

    private func jsonString(_ value: String) -> String {
        let data = try! JSONSerialization.data(withJSONObject: value, options: [.fragmentsAllowed, .withoutEscapingSlashes])
        return String(decoding: data, as: UTF8.self)
    }

    private func groupText(_ hook: Hook, indent: [UInt8], unit: [UInt8], newline: [UInt8]) -> [UInt8] {
        let i = String(decoding: indent, as: UTF8.self), u = String(decoding: unit, as: UTF8.self)
        let n = String(decoding: newline, as: UTF8.self)
        var lines = ["{"]
        if let matcher = hook.matcher { lines.append("\(i)\(u)\"matcher\": \(jsonString(matcher)),") }
        lines += ["\(i)\(u)\"hooks\": [",
                  "\(i)\(u)\(u){",
                  "\(i)\(u)\(u)\(u)\"type\": \"command\",",
                  "\(i)\(u)\(u)\(u)\"command\": \(jsonString(command)),",
                  "\(i)\(u)\(u)\(u)\"timeout\": \(timeout)",
                  "\(i)\(u)\(u)}",
                  "\(i)\(u)]",
                  "\(i)}"]
        return Array(lines.joined(separator: n).utf8)
    }

    // Removes one element of a list including exactly one neighbouring comma.
    private func removal(of index: Int, in list: [JSONSpan], container: JSONSpan, bytes: [UInt8]) -> Edit {
        let element = list[index]
        if index > 0 { return Edit(start: list[index - 1].end, end: element.end, text: []) }
        if list.count > 1 { return Edit(start: element.start, end: list[1].start, text: []) }
        return Edit(start: container.start + 1, end: container.end - 1, text: [])
    }

    private func memberRemoval(_ key: String, in object: JSONSpan) -> Edit? {
        guard let index = object.members.firstIndex(where: { $0.key == key }) else { return nil }
        let member = object.members[index]
        if index > 0 { return Edit(start: object.members[index - 1].value.end, end: member.value.end, text: []) }
        if object.members.count > 1 { return Edit(start: member.keyStart, end: object.members[1].keyStart, text: []) }
        return Edit(start: object.start + 1, end: object.end - 1, text: [])
    }

    // Our entries out; lists and the hooks object that only held ours go too.
    private func removingOurs(_ parsed: Parsed) -> [UInt8] {
        guard let hooks = parsed.hooks else { return parsed.bytes }
        var edits: [Edit] = []
        var emptied: [String] = []
        for member in hooks.members {
            let list = member.value.elements
            let ours = list.indices.filter { isOurs(list[$0]) }
            if ours.isEmpty { continue }
            if ours.count == list.count { emptied.append(member.key); continue }
            // Remove from the back so offsets of earlier removals stay valid as one batch.
            var remaining = list
            for index in ours.reversed() {
                edits.append(removal(of: index, in: remaining, container: member.value, bytes: parsed.bytes))
                remaining.remove(at: index)
            }
        }
        if !emptied.isEmpty, emptied.count == hooks.members.count, let edit = memberRemoval("hooks", in: parsed.root) {
            return apply([edit], to: parsed.bytes)
        }
        var object = hooks
        for key in emptied.reversed() {
            guard let edit = memberRemoval(key, in: object) else { continue }
            edits.append(edit)
            object.members.removeAll { $0.key == key }
        }
        return apply(mergeAdjacent(edits), to: parsed.bytes)
    }

    // Removals computed against shrinking lists can touch; merge overlaps.
    private func mergeAdjacent(_ edits: [Edit]) -> [Edit] {
        var result: [Edit] = []
        for edit in edits.sorted(by: { $0.start < $1.start }) {
            if let last = result.last, edit.start < last.end {
                result[result.count - 1] = Edit(start: last.start, end: max(last.end, edit.end), text: [])
            } else { result.append(edit) }
        }
        return result
    }

    func removed(from data: Data) throws -> Data {
        guard let parsed = try parse(Array(data)) else { return data }
        return Data(removingOurs(parsed))
    }

    func installed(into data: Data?) throws -> Data {
        let original = Array(data ?? Data())
        guard let parsedOriginal = try parse(original) else {
            let (unit, newline) = ([UInt8]("  ".utf8), [UInt8(0x0A)])
            return Data(freshFile(unit: unit, newline: newline))
        }
        if try state(of: data) == .installed { return data ?? Data() }
        let base = removingOurs(parsedOriginal)
        guard let parsed = try parse(base) else { return Data(freshFile(unit: Array("  ".utf8), newline: [0x0A])) }
        let (unit, newline) = style(of: base, root: parsed.root)
        let rootIndent = lineIndent(before: parsed.root.start, in: base)
        var edits: [Edit] = []
        if let hooks = parsed.hooks {
            let memberIndent = hooks.members.first.map { lineIndent(before: $0.keyStart, in: base) } ?? (lineIndent(before: hooks.start, in: base) + unit)
            var missing: [Hook] = []
            for hook in ClaudeHookInstaller.hooks {
                guard let list = hooks.member(hook.event) else { missing.append(hook); continue }
                if let last = list.elements.last {
                    let indent = lineIndent(before: last.start, in: base)
                    let sameLine = !base[list.start..<last.start].contains(0x0A)
                    let text = sameLine ? [UInt8](", ".utf8) + groupText(hook, indent: lineIndent(before: list.start, in: base), unit: unit, newline: newline)
                                        : [UInt8](",".utf8) + newline + indent + groupText(hook, indent: indent, unit: unit, newline: newline)
                    edits.append(Edit(start: last.end, end: last.end, text: text))
                } else {
                    let keyIndent = lineIndent(before: list.start, in: base)
                    let text = newline + keyIndent + unit + groupText(hook, indent: keyIndent + unit, unit: unit, newline: newline) + newline + keyIndent
                    edits.append(Edit(start: list.start + 1, end: list.end - 1, text: text))
                }
            }
            if !missing.isEmpty {
                let members = missing.map { hook -> [UInt8] in
                    memberIndent + Array("\(jsonString(hook.event)): [".utf8) + newline + memberIndent + unit
                        + groupText(hook, indent: memberIndent + unit, unit: unit, newline: newline) + newline + memberIndent + Array("]".utf8)
                }
                let joined = members.enumerated().flatMap { $0.offset == 0 ? $0.element : Array(",".utf8) + newline + $0.element }
                if let last = hooks.members.last {
                    edits.append(Edit(start: last.value.end, end: last.value.end, text: Array(",".utf8) + newline + joined))
                } else {
                    edits.append(Edit(start: hooks.start + 1, end: hooks.end - 1,
                                      text: newline + joined + newline + lineIndent(before: hooks.start, in: base)))
                }
            }
        } else {
            let memberIndent = parsed.root.members.first.map { lineIndent(before: $0.keyStart, in: base) } ?? (rootIndent + unit)
            let block = hooksBlock(indent: memberIndent, unit: unit, newline: newline)
            if let last = parsed.root.members.last {
                edits.append(Edit(start: last.value.end, end: last.value.end, text: Array(",".utf8) + newline + memberIndent + block))
            } else {
                edits.append(Edit(start: parsed.root.start + 1, end: parsed.root.end - 1,
                                  text: newline + memberIndent + block + newline + rootIndent))
            }
        }
        let result = apply(edits, to: base)
        // Proof before anything is written: the edits only replace whitespace,
        // the result is complete, and minus our entries it means the same.
        let onlyWhitespace = edits.allSatisfy { edit in base[edit.start..<edit.end].allSatisfy { [0x20, 0x09, 0x0A, 0x0D].contains($0) } }
        guard onlyWhitespace, (try? state(of: Data(result))) == .installed,
              let after = foreignView(Data(result)), let before = foreignView(Data(base)), after == before else {
            throw Failure.verificationFailed
        }
        return Data(result)
    }

    // The settings as plain values with our entries and empty event lists left out.
    func foreignView(_ data: Data) -> NSDictionary? {
        guard let root = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else { return nil }
        var copy = root
        if let hooks = root["hooks"] as? [String: Any] {
            var kept: [String: Any] = [:]
            for (event, value) in hooks {
                let groups = (value as? [Any] ?? []).filter { group in
                    let handlers = (group as? [String: Any])?["hooks"] as? [Any] ?? []
                    return handlers.isEmpty || !handlers.allSatisfy { handler in
                        ((handler as? [String: Any])?["command"] as? String).map { ClaudeHookInstaller.isOwnCommand($0, marker: marker) } == true
                    }
                }
                if !groups.isEmpty { kept[event] = groups }
            }
            copy["hooks"] = kept.isEmpty ? nil : kept
        }
        return copy as NSDictionary
    }

    private func hooksBlock(indent: [UInt8], unit: [UInt8], newline: [UInt8]) -> [UInt8] {
        let inner = indent + unit
        let members = ClaudeHookInstaller.hooks.map { hook -> [UInt8] in
            inner + Array("\(jsonString(hook.event)): [".utf8) + newline + inner + unit
                + groupText(hook, indent: inner + unit, unit: unit, newline: newline) + newline + inner + Array("]".utf8)
        }
        let joined = members.enumerated().flatMap { $0.offset == 0 ? $0.element : Array(",".utf8) + newline + $0.element }
        return Array("\"hooks\": {".utf8) + newline + joined + newline + indent + Array("}".utf8)
    }

    private func freshFile(unit: [UInt8], newline: [UInt8]) -> [UInt8] {
        Array("{".utf8) + newline + unit + hooksBlock(indent: unit, unit: unit, newline: newline) + newline + Array("}".utf8) + newline
    }

    // MARK: - Files

    struct Outcome {
        let changed: Bool
        let backup: URL?
    }

    // Writes through symlinks to the real file, keeps its permissions, saves a
    // backup of the previous version first, and retries if Claude Code wrote
    // the file in between.
    func install(at url: URL, backups: URL) throws -> Outcome { try rewrite(url, backups: backups) { try installed(into: $0) } }
    func uninstall(at url: URL, backups: URL) throws -> Outcome {
        try rewrite(url, backups: backups) { data in
            guard let data = data else { return nil }
            return try removed(from: data)
        }
    }

    // Follows a chain of symlinks to the file that is really written, also when
    // that file does not exist yet (resolvingSymlinksInPath gives up then).
    static func realTarget(of url: URL) -> URL {
        var current = url.standardizedFileURL
        for _ in 0..<16 {
            guard let destination = try? FileManager.default.destinationOfSymbolicLink(atPath: current.path) else { return current }
            current = (destination.hasPrefix("/") ? URL(fileURLWithPath: destination)
                       : current.deletingLastPathComponent().appendingPathComponent(destination)).standardizedFileURL
        }
        return current
    }

    private func rewrite(_ url: URL, backups: URL, _ change: (Data?) throws -> Data?) throws -> Outcome {
        let target = ClaudeHookInstaller.realTarget(of: url)
        for _ in 0..<3 {
            let before = try? Data(contentsOf: target)
            guard let next = try change(before), next != before else { return Outcome(changed: false, backup: nil) }
            var backup: URL?
            if let before = before {
                let stamp = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: [.withYear, .withMonth, .withDay, .withTime])
                    .replacingOccurrences(of: ":", with: "")
                var file = backups.appendingPathComponent("claude-settings-\(stamp).json")
                var counter = 2
                while FileManager.default.fileExists(atPath: file.path) {
                    file = backups.appendingPathComponent("claude-settings-\(stamp)-\(counter).json")
                    counter += 1
                }
                try writePrivately(before, to: file)
                backup = file
            }
            let attributes = try? FileManager.default.attributesOfItem(atPath: target.path)
            let permissions = (attributes?[.posixPermissions] as? NSNumber)?.int16Value ?? 0o644
            guard (try? Data(contentsOf: target)) == before else { continue }
            try FileManager.default.createDirectory(at: target.deletingLastPathComponent(), withIntermediateDirectories: true)
            let temporary = target.deletingLastPathComponent().appendingPathComponent(".\(target.lastPathComponent).\(getpid()).tmp")
            guard FileManager.default.createFile(atPath: temporary.path, contents: next, attributes: [.posixPermissions: permissions]) else {
                throw CocoaError(.fileWriteUnknown)
            }
            guard rename(temporary.path, target.path) == 0 else {
                try? FileManager.default.removeItem(at: temporary)
                throw CocoaError(.fileWriteUnknown)
            }
            return Outcome(changed: true, backup: backup)
        }
        throw Failure.changedWhileWriting
    }
}
