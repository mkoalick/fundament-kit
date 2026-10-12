# Claude Code hooks

KI-Leiste uses Claude Code's official [hooks](https://code.claude.com/docs/en/hooks) as its main source of information about Claude Code sessions. This page describes exactly what "Install hooks" in Settings › Sources changes, how to check it, and how to remove it again.

## What gets added

Seven hook events are registered in `~/.claude/settings.json`: `SessionStart`, `UserPromptSubmit`, `PreToolUse` (matched to `AskUserQuestion` only), `PostToolUse`, `Notification`, `Stop`, and `SessionEnd`. Each one gets exactly one command entry. For example, the `PreToolUse` entry looks like this:

```json
{
  "matcher": "AskUserQuestion",
  "hooks": [
    {
      "type": "command",
      "command": "[ -x '/Applications/KI-Leiste.app/Contents/MacOS/<helper>' ] && '/Applications/KI-Leiste.app/Contents/MacOS/<helper>' claude-hook; true # ki-leiste-hook",
      "timeout": 10
    }
  ]
}
```

Events without a matcher (`SessionStart`, `UserPromptSubmit`, `PostToolUse`, `Notification`, `Stop`, `SessionEnd`) get the same `hooks` array without a `matcher` key. A full file with nothing else in it would look like:

```json
{
  "hooks": {
    "SessionStart": [
      { "hooks": [ { "type": "command", "command": "[ -x '...' ] && '...' claude-hook; true # ki-leiste-hook", "timeout": 10 } ] }
    ],
    "UserPromptSubmit": [ ... ],
    "PreToolUse": [
      { "matcher": "AskUserQuestion", "hooks": [ { "type": "command", "command": "...", "timeout": 10 } ] }
    ],
    "PostToolUse": [ ... ],
    "Notification": [ ... ],
    "Stop": [ ... ],
    "SessionEnd": [ ... ]
  }
}
```

If `~/.claude/settings.json` already has hooks of your own, or entries for other events, those stay exactly as they are. Installing only ever **appends** an entry to the array for each of the seven events above; it never edits or reorders anything that isn't one of its own entries. Before writing, the app proves this to itself: it removes its own entries from the result it is about to write and compares that against the original file with its own entries (if any) also removed - if those two don't match, nothing is written.

The install also follows symlinks to the real file and keeps its existing file permissions.

## The marker

Every command this app adds ends with `# ki-leiste-hook`. That comment is how the app recognizes its own entries later - on the next install (to avoid duplicates), on every status check, and on removal. An entry only counts as "ours" when every command inside it carries this exact marker.

## Why this exact command

```sh
[ -x '<path-to-helper>' ] && '<path-to-helper>' claude-hook; true # ki-leiste-hook
```

- It's a plain shell command (not a direct executable path) so that a removed or renamed app doesn't turn into a hook error that Claude Code would surface in the conversation. If the helper isn't there or isn't executable, the `[ -x ... ]` test simply fails.
- The trailing `; true` makes the whole line succeed (exit 0) no matter what happened before it - a missing app, a crash, anything. A failing hook is worse than a silent no-op.
- The helper itself never writes anything to stdout when run as `claude-hook`; whatever it printed would otherwise be added to the conversation.

## Checking the state

- Inside Claude Code, run `/hooks` to see everything currently configured, including these entries.
- From Settings › Sources, the label next to the Claude Code toggle shows "Hooks installed", "Hooks need an update" (after the app was moved, renamed, or updated in a way that changed the command), or "Hooks not installed".
- From the command line: `"<app>/Contents/MacOS/<helper>" hooks status [--settings <file>]`.

## Removing hooks

Three equivalent ways:

1. Settings › Sources › "Remove hooks".
2. From the command line: `"<app>/Contents/MacOS/<helper>" hooks uninstall [--settings <file>]`.
3. By hand: open `~/.claude/settings.json` and delete every hook entry whose `command` contains `# ki-leiste-hook`. If removing an entry empties an event's list, or empties the whole `hooks` object, those empty containers are removed too (the app does this automatically; by hand, it's safe to leave an empty `[]` or `{}` behind instead if you'd rather not touch more than the entries themselves).

## Backups

Before the very first write that changes anything, and before every later change, the previous `settings.json` is copied to this app's data folder, under `backups/`, named with the date and time of the backup. Nothing is ever overwritten without a copy of what was there before.

## Live effect

Hooks apply to every Claude Code session that reads this settings file, including ones already running - Claude Code reloads hook changes live, so you don't need to restart a session after installing or removing them.

## Observed payloads

Checked against a real Claude Code 2.1.280 run (`claude -p` with these hooks in a separate settings file):

- `SessionStart`, `UserPromptSubmit`, `PostToolUse`, `Stop` and `SessionEnd` arrive as documented; `SessionEnd` carries `reason: "other"` for a print-mode run.
- None of the events carried a `model` field, although the reference lists one. The app therefore takes the model from the end of the transcript when the hook does not name it.
- `PostToolUse` carries the tool output as `tool_response`. The app ignores it.
- One hook run, including the shell, takes about 16 ms on an Apple silicon Mac (median of 30 runs).

To try hooks without touching your own settings, start a throwaway session with `--setting-sources project --settings <file>` from an empty folder: only the hooks in `<file>` run, not the ones in `~/.claude/settings.json`.
