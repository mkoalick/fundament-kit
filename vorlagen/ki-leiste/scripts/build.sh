#!/bin/sh
# Builds build/<APP_NAME>.app with the Command Line Tools alone (no Xcode project).
#   scripts/build.sh               for this Mac's architecture
#   UNIVERSAL=1 scripts/build.sh   Apple silicon and Intel in one bundle (releases)
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$ROOT/scripts/app.env"
OUT="${OUT:-$ROOT/build}"
BUNDLE="$OUT/$APP_NAME.app"
WORK=$(mktemp -d "${TMPDIR:-/tmp}/build.XXXXXX")
trap 'rm -rf "$WORK"' EXIT

if [ "${UNIVERSAL:-0}" = "1" ]; then ARCHS="arm64 x86_64"; else ARCHS=$(uname -m); fi
compile() { # <output> <sources…>
    output=$1; shift
    slices=""
    for arch in $ARCHS; do
        swiftc -O -target "$arch-apple-macos$MIN_MACOS" "$@" -o "$WORK/$(basename "$output").$arch"
        slices="$slices $WORK/$(basename "$output").$arch"
    done
    # shellcheck disable=SC2086
    lipo -create $slices -output "$output"
}

rm -rf "$BUNDLE"
mkdir -p "$BUNDLE/Contents/MacOS" "$BUNDLE/Contents/Resources"
sed -e "s#__APP_NAME__#$APP_NAME#g" -e "s#__BUNDLE_ID__#$BUNDLE_ID#g" -e "s#__EXECUTABLE__#$EXECUTABLE#g" \
    -e "s#__HELPER_NAME__#$HELPER_NAME#g" -e "s#__VERSION__#$VERSION#g" -e "s#__BUILD_NUMBER__#$BUILD_NUMBER#g" \
    -e "s#__MIN_MACOS__#$MIN_MACOS#g" "$ROOT/Resources/Info.plist" > "$BUNDLE/Contents/Info.plist"
plutil -lint -s "$BUNDLE/Contents/Info.plist"

compile "$BUNDLE/Contents/MacOS/$EXECUTABLE" "$ROOT"/Core/*.swift "$ROOT"/App/*.swift
# The hook helper links Foundation only, so a hook costs milliseconds.
compile "$BUNDLE/Contents/MacOS/$HELPER_NAME" "$ROOT"/Core/*.swift "$ROOT"/Helper/main.swift

# Translations: the String Catalog is the source; macOS reads .strings at runtime.
if [ -f "$ROOT/Resources/Localizable.xcstrings" ]; then
    swift "$ROOT/scripts/xcstrings-to-strings.swift" "$ROOT/Resources/Localizable.xcstrings" "$BUNDLE/Contents/Resources"
fi
[ -f "$ROOT/Resources/AppIcon.icns" ] && cp "$ROOT/Resources/AppIcon.icns" "$BUNDLE/Contents/Resources/"

# Ad-hoc signature with a fixed designated requirement: macOS keeps the
# Accessibility permission across rebuilds because it is tied to the bundle id,
# not to the changing code hash. A Developer ID signature replaces this later.
codesign --force --sign - --identifier "$BUNDLE_ID.hook" "$BUNDLE/Contents/MacOS/$HELPER_NAME"
codesign --force --sign - --identifier "$BUNDLE_ID" \
    --requirements "=designated => identifier \"$BUNDLE_ID\"" "$BUNDLE"
codesign --verify --strict "$BUNDLE"
echo "$BUNDLE"
