import Foundation

// A JSON reader that remembers where every value sits in the original bytes.
// The hook installer uses it to insert and remove its own entries as plain
// text, so every other byte of a settings file stays exactly as it was:
// key order, spacing, comments in strings, escapes, and line endings.
struct JSONSpan {
    enum Kind { case object, array, string, number, literal }
    let kind: Kind
    let start: Int          // offset of the first byte
    let end: Int            // offset after the last byte
    var members: [(key: String, keyStart: Int, value: JSONSpan)] = []
    var elements: [JSONSpan] = []
    var string: String?     // decoded value of a string

    func member(_ key: String) -> JSONSpan? { members.first { $0.key == key }?.value }
}

struct JSONSpanError: Error, CustomStringConvertible {
    let offset: Int
    let reason: String
    var description: String { "Invalid JSON at byte \(offset): \(reason)" }
}

struct JSONSpanParser {
    private let bytes: [UInt8]
    private var index = 0
    private var depth = 0

    static func parse(_ bytes: [UInt8]) throws -> JSONSpan {
        var parser = JSONSpanParser(bytes: bytes)
        parser.skipWhitespace()
        let value = try parser.value()
        parser.skipWhitespace()
        guard parser.index == bytes.count else { throw JSONSpanError(offset: parser.index, reason: "trailing content") }
        return value
    }

    private init(bytes: [UInt8]) { self.bytes = bytes }

    private mutating func skipWhitespace() {
        while index < bytes.count, [0x20, 0x09, 0x0A, 0x0D].contains(bytes[index]) { index += 1 }
    }

    private func fail(_ reason: String) -> JSONSpanError { JSONSpanError(offset: index, reason: reason) }

    private mutating func value() throws -> JSONSpan {
        guard index < bytes.count else { throw fail("unexpected end") }
        switch bytes[index] {
        case UInt8(ascii: "{"): return try object()
        case UInt8(ascii: "["): return try array()
        case UInt8(ascii: "\""): return try string()
        case UInt8(ascii: "-"), UInt8(ascii: "0")...UInt8(ascii: "9"): return try number()
        default: return try literal()
        }
    }

    private mutating func object() throws -> JSONSpan {
        let start = index
        depth += 1
        guard depth < 200 else { throw fail("nested too deeply") }
        defer { depth -= 1 }
        index += 1
        var result = JSONSpan(kind: .object, start: start, end: start)
        skipWhitespace()
        if index < bytes.count, bytes[index] == UInt8(ascii: "}") {
            index += 1
            return JSONSpan(kind: .object, start: start, end: index)
        }
        while true {
            skipWhitespace()
            guard index < bytes.count, bytes[index] == UInt8(ascii: "\"") else { throw fail("expected a key") }
            let keyStart = index
            let key = try string()
            skipWhitespace()
            guard index < bytes.count, bytes[index] == UInt8(ascii: ":") else { throw fail("expected ':'") }
            index += 1
            skipWhitespace()
            let member = try value()
            result.members.append((key: key.string ?? "", keyStart: keyStart, value: member))
            skipWhitespace()
            guard index < bytes.count else { throw fail("unexpected end in object") }
            if bytes[index] == UInt8(ascii: ",") { index += 1; continue }
            guard bytes[index] == UInt8(ascii: "}") else { throw fail("expected ',' or '}'") }
            index += 1
            return JSONSpan(kind: .object, start: start, end: index, members: result.members)
        }
    }

    private mutating func array() throws -> JSONSpan {
        let start = index
        depth += 1
        guard depth < 200 else { throw fail("nested too deeply") }
        defer { depth -= 1 }
        index += 1
        var elements: [JSONSpan] = []
        skipWhitespace()
        if index < bytes.count, bytes[index] == UInt8(ascii: "]") {
            index += 1
            return JSONSpan(kind: .array, start: start, end: index)
        }
        while true {
            skipWhitespace()
            elements.append(try value())
            skipWhitespace()
            guard index < bytes.count else { throw fail("unexpected end in array") }
            if bytes[index] == UInt8(ascii: ",") { index += 1; continue }
            guard bytes[index] == UInt8(ascii: "]") else { throw fail("expected ',' or ']'") }
            index += 1
            return JSONSpan(kind: .array, start: start, end: index, elements: elements)
        }
    }

    private mutating func string() throws -> JSONSpan {
        let start = index
        index += 1
        while index < bytes.count {
            switch bytes[index] {
            case UInt8(ascii: "\\"): index += 2
            case UInt8(ascii: "\""):
                index += 1
                let raw = Data(bytes[start..<index])
                guard let decoded = try? JSONSerialization.jsonObject(with: raw, options: .fragmentsAllowed) as? String else {
                    throw JSONSpanError(offset: start, reason: "invalid string")
                }
                return JSONSpan(kind: .string, start: start, end: index, string: decoded)
            case 0x00...0x1F: throw fail("control character in string")
            default: index += 1
            }
        }
        throw JSONSpanError(offset: start, reason: "unterminated string")
    }

    private mutating func number() throws -> JSONSpan {
        let start = index
        while index < bytes.count, "+-0123456789.eE".utf8.contains(bytes[index]) { index += 1 }
        guard (try? JSONSerialization.jsonObject(with: Data(bytes[start..<index]), options: .fragmentsAllowed)) is NSNumber else {
            throw JSONSpanError(offset: start, reason: "invalid number")
        }
        return JSONSpan(kind: .number, start: start, end: index)
    }

    private mutating func literal() throws -> JSONSpan {
        let start = index
        for word in ["true", "false", "null"] {
            let utf8 = Array(word.utf8)
            if index + utf8.count <= bytes.count, Array(bytes[index..<index + utf8.count]) == utf8 {
                index += utf8.count
                return JSONSpan(kind: .literal, start: start, end: index)
            }
        }
        throw fail("unexpected character")
    }
}
