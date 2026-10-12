#!/bin/sh
# Renders docs/images/*.png (the five settings tabs plus a wide strip
# preview) without ever showing a window. Builds Tests/render-settings.swift
# together with Core/*.swift and App/*.swift (everything except
# App/main.swift, which starts the real app) into a temporary .app bundle
# that carries the en.lproj/de.lproj built from Resources/Localizable.xcstrings
# - a bare command-line binary cannot find them, only a real bundle layout
# can - then runs that bundle offscreen (render-settings.swift sets
# NSApplication's activation policy to .prohibited, so no window and no Dock
# icon ever appear).
#   scripts/render-images.sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$ROOT/scripts/app.env"
WORK=$(mktemp -d "${TMPDIR:-/tmp}/render-images.XXXXXX")
trap 'rm -rf "$WORK"' EXIT

BUNDLE="$WORK/RenderTool.app"
mkdir -p "$BUNDLE/Contents/MacOS" "$BUNDLE/Contents/Resources"

APP_SOURCES=$(ls "$ROOT"/App/*.swift | grep -v '/main\.swift$')
# Swift only allows top-level statements in a file literally named main.swift
# when compiling several files together, so render-settings.swift is copied
# under that name for this one build instead of being renamed in the repo.
cp "$ROOT/Tests/render-settings.swift" "$WORK/main.swift"
# shellcheck disable=SC2086
swiftc -O "$ROOT"/Core/*.swift $APP_SOURCES "$WORK/main.swift" -o "$BUNDLE/Contents/MacOS/RenderTool"

sed -e "s#__APP_NAME__#RenderTool#g" -e "s#__BUNDLE_ID__#dev.kileiste.render#g" -e "s#__EXECUTABLE__#RenderTool#g" \
    -e "s#__HELPER_NAME__#render-helper#g" -e "s#__VERSION__#$VERSION#g" -e "s#__BUILD_NUMBER__#$BUILD_NUMBER#g" \
    -e "s#__MIN_MACOS__#$MIN_MACOS#g" "$ROOT/Resources/Info.plist" > "$BUNDLE/Contents/Info.plist"

# Translations: same conversion step as the real build, into this temporary
# bundle's own Resources instead of the app's.
swift "$ROOT/scripts/xcstrings-to-strings.swift" "$ROOT/Resources/Localizable.xcstrings" "$BUNDLE/Contents/Resources"

mkdir -p "$ROOT/docs/images"
"$BUNDLE/Contents/MacOS/RenderTool" "$ROOT/docs/images" light -AppleLanguages "(en)"
echo "Rendered docs/images/*.png (English, light)"

# German is never part of the deliverables - only a throwaway check that the
# translation actually applies and nothing gets cut off.
DE_OUT="$WORK/de-preview"
mkdir -p "$DE_OUT"
"$BUNDLE/Contents/MacOS/RenderTool" "$DE_OUT" light -AppleLanguages "(de)"
echo "German preview (QA only, not part of docs/images): $DE_OUT"
