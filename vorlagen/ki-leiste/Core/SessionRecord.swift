import Foundation

// One agent session as the app sees it. Providers produce records, the
// collector merges them, the strip renders them, and the register file on disk
// carries them to other tools. Every field is optional on disk except `id`, so
// external sources and older files keep decoding.
struct SessionRecord: Codable, Equatable {
    enum Status: String, Codable, CaseIterable {
        case working   // the agent is busy (turn running, tool running)
        case waiting   // a concrete question or permission waits for the user
        case ready     // the agent sits at its prompt, nothing reported as done
        case done      // explicitly reported as finished
        case blocked   // explicitly reported as blocked (or a documented hard stop)
        case unknown   // no current evidence

        // Accepts the names of the first, German-language versions as aliases.
        init?(alias: String) {
            let key = alias.trimmingCharacters(in: .whitespaces).lowercased()
            if let value = Status(rawValue: key) { self = value; return }
            switch key {
            case "arbeitet": self = .working
            case "input", "wartet": self = .waiting
            case "bereit": self = .ready
            case "fertig": self = .done
            case "blockiert": self = .blocked
            case "unbekannt", "unklar": self = .unknown
            default: return nil
            }
        }

        init(from decoder: Decoder) throws {
            let raw = try decoder.singleValueContainer().decode(String.self)
            self = Status(alias: raw) ?? .unknown
        }
    }

    // A structured question (Claude's AskUserQuestion, Codex's request_user_input).
    struct Question: Codable, Equatable {
        var question: String
        var header: String = ""
        var multiSelect = false
        var options: [String] = []
    }

    var id: String                    // "<provider>:<nativeId>"; external sources use their own
    var provider: String = ""         // "claude", "codex", or an external engine name
    var nativeId: String = ""
    var repo: String = ""             // display group: name of the git repository
    var repoPath: String = ""         // git root (or the working directory outside git)
    var cwd: String = ""
    var color: String?                // "#RRGGBB" from the repository, if any
    var title: String = ""
    var task: String = ""
    var status: Status = .unknown
    var question: String = ""
    var questions: [Question] = []
    var result: String = ""
    var since: Date?                  // when the current status began
    var activeAt: Date?               // last evidence of work
    var reportedAt: Date?             // last explicit report
    var open = true                   // the agent process is still running
    var closedAt: Date?
    var model: String = ""
    var pid: Int32?
    var transcriptPath: String?
    var statusSource: String = ""     // which evidence set the status, for diagnosis
    var origin: String?               // nil for this Mac; a label for external sources
    var stale = false                 // an external source that stopped updating
    var lastMessage: String = ""      // local only: end of the last answer, shortened

    init(id: String, provider: String = "", nativeId: String = "") {
        self.id = id
        self.provider = provider
        self.nativeId = nativeId
    }

    private enum Keys: String, CodingKey {
        case id, provider, nativeId, repo, repoPath, cwd, color, title, task, status, question, questions, result,
             since, activeAt, reportedAt, open, closedAt, model, pid, transcriptPath, statusSource, origin, stale, lastMessage
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: Keys.self)
        func value<T: Decodable>(_ key: Keys, _ fallback: T) -> T { (try? c.decodeIfPresent(T.self, forKey: key)) ?? fallback }
        id = try c.decode(String.self, forKey: .id)
        provider = value(.provider, "")
        nativeId = value(.nativeId, "")
        repo = value(.repo, "")
        repoPath = value(.repoPath, "")
        cwd = value(.cwd, "")
        color = value(.color, String?.none)
        title = value(.title, "")
        task = value(.task, "")
        status = value(.status, Status.unknown)
        question = value(.question, "")
        questions = value(.questions, [Question]())
        result = value(.result, "")
        since = value(.since, Date?.none)
        activeAt = value(.activeAt, Date?.none)
        reportedAt = value(.reportedAt, Date?.none)
        open = value(.open, true)
        closedAt = value(.closedAt, Date?.none)
        model = value(.model, "")
        pid = value(.pid, Int32?.none)
        transcriptPath = value(.transcriptPath, String?.none)
        statusSource = value(.statusSource, "")
        origin = value(.origin, String?.none)
        stale = value(.stale, false)
        lastMessage = value(.lastMessage, "")
    }
}

extension SessionRecord.Question {
    private enum Keys: String, CodingKey { case question, header, multiSelect, options }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: Keys.self)
        question = (try? c.decode(String.self, forKey: .question)) ?? ""
        header = (try? c.decode(String.self, forKey: .header)) ?? ""
        multiSelect = (try? c.decode(Bool.self, forKey: .multiSelect)) ?? false
        options = (try? c.decode([String].self, forKey: .options)) ?? []
    }

    // AskUserQuestion / request_user_input input: [{question, header, multiSelect, options: [{label}] | [String]}]
    static func parse(_ raw: Any?, maxQuestions: Int = 4, maxOptions: Int = 6) -> [SessionRecord.Question] {
        guard let list = raw as? [Any] else { return [] }
        var result: [SessionRecord.Question] = []
        for item in list.prefix(maxQuestions) {
            guard let entry = item as? [String: Any] else { continue }
            let text = (entry["question"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { continue }
            let options = (entry["options"] as? [Any] ?? []).prefix(maxOptions).compactMap { option -> String? in
                let label = (option as? [String: Any])?["label"] as? String ?? option as? String ?? ""
                let trimmed = label.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmed.isEmpty ? nil : String(trimmed.prefix(100))
            }
            result.append(.init(question: String(text.prefix(300)),
                                header: String((entry["header"] as? String ?? "").trimmingCharacters(in: .whitespaces).prefix(100)),
                                multiSelect: entry["multiSelect"] as? Bool ?? false, options: options))
        }
        return result
    }
}

// The file format shared by the register the app writes and by external
// sources it reads: { "schema": 1, "source": ..., "generatedAt": ..., "sessions": [...] }
struct SessionRegister: Codable {
    static let schema = 1
    var schema = SessionRegister.schema
    var source: String?
    var generatedAt: Date
    var sessions: [SessionRecord]

    static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let raw = try decoder.singleValueContainer().decode(String.self)
            guard let date = parseDate(raw) else {
                throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "date"))
            }
            return date
        }
        return decoder
    }

    static func encoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var c = encoder.singleValueContainer()
            try c.encode(formatDate(date))
        }
        return encoder
    }
}

// ISO 8601 with or without fractional seconds; always written with them, in UTC.
func parseDate(_ raw: String) -> Date? {
    let fractional = ISO8601DateFormatter()
    fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    if let date = fractional.date(from: raw) { return date }
    let plain = ISO8601DateFormatter()
    plain.formatOptions = [.withInternetDateTime]
    return plain.date(from: raw)
}

func formatDate(_ date: Date) -> String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter.string(from: date)
}

// Writes JSON through a temporary file and a rename, with private permissions.
func writePrivately(_ data: Data, to url: URL) throws {
    let folder = url.deletingLastPathComponent()
    try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
    let temporary = folder.appendingPathComponent(".\(url.lastPathComponent).\(getpid()).\(UInt32.random(in: 0...UInt32.max))")
    guard FileManager.default.createFile(atPath: temporary.path, contents: data, attributes: [.posixPermissions: 0o600]) else {
        throw CocoaError(.fileWriteUnknown)
    }
    if rename(temporary.path, url.path) != 0 {
        try? FileManager.default.removeItem(at: temporary)
        throw CocoaError(.fileWriteUnknown)
    }
}
