#!/bin/sh
# Logic tests (layout, display, collector, providers, hooks):   Tests/run.sh
# Plus real windows and Accessibility on this Mac:              Tests/run.sh --native
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$ROOT/scripts/app.env"
TEST_DIR=$(mktemp -d "${TMPDIR:-/tmp}/strip-tests.XXXXXX")
PAUSED=""
cleanup() {
    if [ -n "$PAUSED" ]; then kill -CONT $PAUSED 2>/dev/null || true; fi
    rm -rf "$TEST_DIR"
}
trap cleanup EXIT HUP INT TERM
APP_SOURCES="$ROOT/App/WindowSpace.swift $ROOT/App/SessionDisplay.swift $ROOT/App/BarSettings.swift $ROOT/App/SessionAppearance.swift $ROOT/App/SessionToast.swift $ROOT/App/FileWatcher.swift"
# shellcheck disable=SC2086
swiftc "$ROOT"/Core/*.swift $APP_SOURCES "$ROOT"/Tests/Support.swift "$ROOT"/Tests/*Tests.swift "$ROOT/Tests/main.swift" -o "$TEST_DIR/tests"
if [ "${1:-}" = "--native" ]; then
    # A running strip would adjust the test window before the first snapshot.
    # Pause every running copy of this app briefly; cleanup always resumes it.
    # PAUSE_PATTERN adds other strips (for example an older build) to pause.
    PAUSED=$(pgrep -f "/Contents/MacOS/${PAUSE_PATTERN:-$EXECUTABLE}\$" | tr '\n' ' ' || true)
    if [ -n "$PAUSED" ]; then kill -STOP $PAUSED 2>/dev/null || true; fi
    swiftc "$ROOT/Tests/window-fixture.swift" -o "$TEST_DIR/window-fixture"
    "$TEST_DIR/tests" "$TEST_DIR/window-fixture"
    mkdir -p "$TEST_DIR/toast-source"
    cp "$ROOT/Tests/toast-fixture.swift" "$TEST_DIR/toast-source/main.swift"
    # shellcheck disable=SC2086
    swiftc "$ROOT"/Core/*.swift $APP_SOURCES "$TEST_DIR/toast-source/main.swift" -o "$TEST_DIR/toast-fixture"
    "$TEST_DIR/toast-fixture"
else
    "$TEST_DIR/tests"
fi
