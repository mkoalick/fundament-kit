#!/bin/sh
# Collects every L("...") key and SwiftUI literal (Text(, Toggle(, Button(,
# Picker(, Section(, Label(, TextField(, Stepper(, ColorPicker(, plus .help(
# and .accessibilityLabel( for completeness) from App/*.swift, then reports
# which of them are missing from Resources/Localizable.xcstrings.
#   scripts/check-strings.sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

python3 - "$ROOT" <<'PY'
import json
import re
import sys
from pathlib import Path

root = Path(sys.argv[1])
app_dir = root / "App"
catalog_path = root / "Resources" / "Localizable.xcstrings"

catalog = json.loads(catalog_path.read_text(encoding="utf-8"))
catalog_keys = set(catalog.get("strings", {}).keys())

# Plain-word identifiers need a boundary check so "L(" does not match inside
# "URL(", and "Text(" does not match inside some other word ending in "Text".
WORD_IDENTS = ["L", "Text", "Toggle", "Button", "Picker", "Section", "Label",
               "TextField", "Stepper", "ColorPicker"]
DOT_IDENTS = [".help", ".accessibilityLabel"]


def unescape(raw):
    return raw  # already unescaped while scanning (see scan_string below)


def scan_string(text, start):
    """text[start] == '"' (opening quote). Returns (literal, index after closing quote)."""
    n = len(text)
    j = start + 1
    buf = []
    while j < n:
        c = text[j]
        if c == "\\" and j + 1 < n:
            nxt = text[j + 1]
            if nxt == "(":
                # String interpolation \(...): find the matching close paren
                # (nested parens allowed) and turn it into a format placeholder.
                k = j + 2
                depth = 1
                inner_start = k
                while k < n and depth > 0:
                    if text[k] == "(":
                        depth += 1
                    elif text[k] == ")":
                        depth -= 1
                    k += 1
                inner = text[inner_start:k - 1].strip()
                if inner.startswith("Int("):
                    buf.append("%lld")
                elif inner.startswith("Double("):
                    buf.append("%lf")
                else:
                    buf.append("%@")
                j = k
                continue
            elif nxt == "n":
                buf.append("\n")
            elif nxt == '"':
                buf.append('"')
            elif nxt == "\\":
                buf.append("\\")
            else:
                buf.append(nxt)
            j += 2
            continue
        if c == '"':
            return "".join(buf), j + 1
        buf.append(c)
        j += 1
    return "".join(buf), j


def first_argument_literals(text, call_start):
    """call_start points right after the call's opening '('. Scans the FIRST
    argument only (up to the first top-level comma or the call's closing
    paren), returning every top-level string literal found there (covers a
    plain literal and a `cond ? "a" : "b"` ternary alike), ignoring literals
    nested inside a further call such as `selection: model.x("y")`."""
    n = len(text)
    pos = call_start
    depth = 1  # already inside the call's own parens
    literals = []
    while pos < n and depth > 0:
        ch = text[pos]
        if ch == '"':
            literal, pos = scan_string(text, pos)
            if depth == 1:
                literals.append(literal)
            continue
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
            if depth == 0:
                break
        elif ch == "," and depth == 1:
            break
        pos += 1
    return literals


def find_calls(text, ident):
    if ident[0].isalpha():
        pattern = re.compile(r"(?<![A-Za-z0-9_])" + re.escape(ident) + r"\(")
    else:
        pattern = re.compile(re.escape(ident) + r"\(")
    for m in pattern.finditer(text):
        yield m.end()


found = set()
for path in sorted(app_dir.glob("*.swift")):
    text = path.read_text(encoding="utf-8")
    for ident in WORD_IDENTS + DOT_IDENTS:
        for call_start in find_calls(text, ident):
            for literal in first_argument_literals(text, call_start):
                if literal:
                    found.add(literal)

missing = sorted(k for k in found if k not in catalog_keys)
if missing:
    print(f"{len(missing)} missing from the catalog:")
    for key in missing:
        print(f"  - {key!r}")
    sys.exit(1)

print(f"{len(found)} keys found in App/*.swift, 0 missing from the catalog ({len(catalog_keys)} keys total).")
PY
