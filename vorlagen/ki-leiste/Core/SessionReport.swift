import Foundation

// An explicit status line an agent may print in its answer, for states that
// cannot be observed reliably (a finished task, a blocker, a free-text question):
//
//   SESSION_REPORT: {"status":"done","result":"Migration applied and verified."}
//   SESSION_REPORT: {"status":"waiting","question":"Variant A or B?"}
//
// Any upper-case prefix ending in SESSION_REPORT is accepted (for example a
// personal MYNAME_SESSION_REPORT), and so are the keys of the first versions
// (frage, ergebnis, auftrag, thema).
struct SessionReport: Equatable {
    var status: SessionRecord.Status
    var question = ""
    var result = ""
    var task = ""
    var title = ""

    static let marker = try! NSRegularExpression(pattern: "^\\s*(?:[A-Z][A-Z0-9]*_)*SESSION_REPORT:\\s*(\\{.*\\})\\s*$")

    // A waiting report needs a question; a done report must not carry one.
    var isValid: Bool {
        switch status {
        case .waiting: return !question.isEmpty
        case .done: return question.isEmpty
        case .unknown: return false
        default: return true
        }
    }

    init(status: SessionRecord.Status, question: String = "", result: String = "", task: String = "", title: String = "") {
        self.status = status
        self.question = question
        self.result = result
        self.task = task
        self.title = title
    }

    init?(json: [String: Any]) {
        guard let raw = json["status"] as? String, let status = SessionRecord.Status(alias: raw) else { return nil }
        func text(_ keys: String..., limit: Int) -> String {
            for key in keys { if let value = json[key] as? String { return String(value.trimmingCharacters(in: .whitespacesAndNewlines).prefix(limit)) } }
            return ""
        }
        self.init(status: status, question: text("question", "frage", limit: 2000), result: text("result", "ergebnis", limit: 2000),
                  task: text("task", "auftrag", limit: 300), title: text("title", "thema", limit: 300))
        guard isValid else { return nil }
    }

    // The last valid report line in a block of text, if any.
    static func last(in text: String) -> SessionReport? {
        var found: SessionReport?
        for line in text.split(separator: "\n", omittingEmptySubsequences: true) where line.contains("SESSION_REPORT") {
            let string = String(line)
            guard let match = marker.firstMatch(in: string, range: NSRange(string.startIndex..., in: string)),
                  let range = Range(match.range(at: 1), in: string),
                  let object = try? JSONSerialization.jsonObject(with: Data(string[range].utf8)) as? [String: Any],
                  let report = SessionReport(json: object) else { continue }
            found = report
        }
        return found
    }
}
