import Foundation

// Converts the String Catalog (Resources/Localizable.xcstrings) into the
// en.lproj/de.lproj Localizable.strings files macOS reads at runtime. The
// Command Line Tools build has no Xcode to compile .xcstrings itself, so
// scripts/build.sh runs this script instead, once per build.
//   swift scripts/xcstrings-to-strings.swift <catalog.xcstrings> <ResourcesDir>
//
// English has no explicit localization in the catalog: the key is already
// the English text (every L() call and SwiftUI literal is written in
// English), so en.lproj always maps each key to itself. A key missing its
// German value falls back to the same English key text.

guard CommandLine.arguments.count >= 3 else {
    FileHandle.standardError.write(Data("Usage: xcstrings-to-strings.swift <catalog> <ResourcesDir>\n".utf8))
    exit(1)
}
let catalogURL = URL(fileURLWithPath: CommandLine.arguments[1])
let resourcesDir = URL(fileURLWithPath: CommandLine.arguments[2])

let data: Data
do {
    data = try Data(contentsOf: catalogURL)
} catch {
    FileHandle.standardError.write(Data("Could not read \(catalogURL.path): \(error)\n".utf8))
    exit(1)
}

guard let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
      let strings = root["strings"] as? [String: Any] else {
    FileHandle.standardError.write(Data("Could not parse \(catalogURL.path) as a String Catalog\n".utf8))
    exit(1)
}

// .strings files use C-style escaping inside the quoted value.
func escape(_ value: String) -> String {
    var result = ""
    result.reserveCapacity(value.count)
    for character in value {
        switch character {
        case "\\": result += "\\\\"
        case "\"": result += "\\\""
        case "\n": result += "\\n"
        default: result.append(character)
        }
    }
    return result
}

func germanValue(_ entry: Any?) -> String? {
    guard let entry = entry as? [String: Any],
          let localizations = entry["localizations"] as? [String: Any],
          let de = localizations["de"] as? [String: Any],
          let unit = de["stringUnit"] as? [String: Any],
          let value = unit["value"] as? String, !value.isEmpty else { return nil }
    return value
}

func writeLocalizableStrings(_ language: String, valueFor: (String) -> String) throws {
    let folder = resourcesDir.appendingPathComponent("\(language).lproj")
    try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    var lines: [String] = []
    for key in strings.keys.sorted() {
        lines.append("\"\(escape(key))\" = \"\(escape(valueFor(key)))\";")
    }
    let content = lines.joined(separator: "\n") + "\n"
    try content.write(to: folder.appendingPathComponent("Localizable.strings"), atomically: true, encoding: .utf8)
}

do {
    try writeLocalizableStrings("en") { key in key }
    try writeLocalizableStrings("de") { key in germanValue(strings[key]) ?? key }
} catch {
    FileHandle.standardError.write(Data("Could not write Localizable.strings: \(error)\n".utf8))
    exit(1)
}

print("xcstrings-to-strings: wrote \(strings.count) keys to en.lproj and de.lproj in \(resourcesDir.path)")
