import Foundation

// Facts read out of one Claude Code transcript (JSONL), the data every
// fallback record and every hook-based record ultimately needs: what the
// session is called, which model answered last, whether a question is still
// open, and the last explicit SESSION_REPORT line.

// An AskUserQuestion tool call with no matching tool_result yet.
struct PendingQuestion: Equatable {
    var text: String
    var questions: [SessionRecord.Question]
    var at: Date?
}

// A SessionReport together with the timestamp of the line that carried it.
struct TimedReport: Equatable {
    var report: SessionReport
    var at: Date?
}

struct ClaudeTranscriptSummary: Equatable {
    var title = ""              // custom-title beats ai-title; never the prompt text
    var model = ""               // last assistant message.model; ignore values starting with "<"
    var pending: PendingQuestion?    // unanswered AskUserQuestion
    var report: TimedReport?         // last valid SESSION_REPORT line in assistant text
    var lastActivity: Date?          // timestamp of the last event seen
}

// Parses the tail of a transcript in one pass and caches the result by file
// stamp, so a session that is not currently changing costs nothing to read
// again. Errors (missing file, truncated JSON, odd event shapes) never throw
// or crash; they just leave the corresponding field empty.
final class ClaudeTranscriptReader {
    private struct Cached {
        let stamp: FileStamp
        let summary: ClaudeTranscriptSummary
    }

    private var cache: [String: Cached] = [:]
    private let tailLimit = 1_000_000

    init() {}

    func summary(path: String) -> ClaudeTranscriptSummary {
        guard let stamp = FileStamp(path) else {
            cache.removeValue(forKey: path)
            return ClaudeTranscriptSummary()
        }
        if let cached = cache[path], cached.stamp == stamp {
            return cached.summary
        }
        var summary = parse(path: path)
        // A tail that no longer reaches back to the title event keeps the
        // title this reader already found for this path.
        if summary.title.isEmpty, let previous = cache[path]?.summary.title, !previous.isEmpty {
            summary.title = previous
        }
        cache[path] = Cached(stamp: stamp, summary: summary)
        return summary
    }

    private func parse(path: String) -> ClaudeTranscriptSummary {
        var summary = ClaudeTranscriptSummary()
        var customTitle = ""
        var aiTitle = ""
        var lastModel = ""
        var lastReport: TimedReport?
        var lastActivity: Date?
        var pendingByID: [String: PendingQuestion] = [:]
        var pendingOrder: [String] = []

        for line in tailLines(path, limit: tailLimit) {
            guard let event = jsonObject(line) else { continue }
            let when = (event["timestamp"] as? String).flatMap(parseDate)
            if let when = when { lastActivity = when }

            if let type = event["type"] as? String {
                if type == "custom-title" {
                    let text = (event["customTitle"] as? String) ?? (event["title"] as? String) ?? ""
                    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty { customTitle = String(trimmed.prefix(300)) }
                    continue
                }
                if type == "ai-title" {
                    let trimmed = ((event["aiTitle"] as? String) ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty { aiTitle = String(trimmed.prefix(300)) }
                    continue
                }
            }

            guard let message = event["message"] as? [String: Any] else { continue }
            let role = message["role"] as? String ?? ""

            var blocks: [[String: Any]] = []
            if let list = message["content"] as? [Any] {
                blocks = list.compactMap { $0 as? [String: Any] }
            } else if let text = message["content"] as? String {
                blocks = [["type": "text", "text": text]]
            }

            if role == "assistant", let model = message["model"] as? String, !model.hasPrefix("<") {
                lastModel = model
            }

            for block in blocks {
                guard let blockType = block["type"] as? String else { continue }
                switch blockType {
                case "tool_result":
                    if let id = block["tool_use_id"] as? String { pendingByID.removeValue(forKey: id) }
                case "tool_use":
                    guard block["name"] as? String == "AskUserQuestion", let id = block["id"] as? String else { continue }
                    let input = block["input"] as? [String: Any]
                    let questions = SessionRecord.Question.parse(input?["questions"])
                    let joined = questions.map { $0.question }.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !joined.isEmpty else { continue }
                    pendingByID[id] = PendingQuestion(text: String(joined.prefix(2000)), questions: questions, at: when)
                    pendingOrder.append(id)
                case "text":
                    guard role == "assistant", let text = block["text"] as? String, text.contains("SESSION_REPORT"),
                          let report = SessionReport.last(in: text) else { continue }
                    lastReport = TimedReport(report: report, at: when)
                default:
                    break
                }
            }
        }

        summary.title = !customTitle.isEmpty ? customTitle : aiTitle
        summary.model = lastModel
        summary.report = lastReport
        summary.lastActivity = lastActivity
        if let lastID = pendingOrder.last(where: { pendingByID[$0] != nil }) {
            summary.pending = pendingByID[lastID]
        }
        return summary
    }
}
