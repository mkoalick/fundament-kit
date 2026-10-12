# Session register format

KI-Leiste writes everything it currently sees to a register file, so other tools can read it without talking to the app itself. The same format lets other tools feed their own sessions back into the strip.

## Files

| File | Written by | Read by |
|---|---|---|
| `~/Library/Application Support/<bundle id>/sessions.json` | the app, at least every 30 seconds | other tools |
| `~/Library/Application Support/<bundle id>/sources/*.json` | other tools, any file name | the app |

Both use the same shape:

```json
{
  "schema": 1,
  "source": null,
  "generatedAt": "2026-10-12T09:41:07.000Z",
  "sessions": [ ... ]
}
```

`source` is `null` in the app's own `sessions.json`. In a file under `sources/`, it is the display name of the tool that wrote it (shown next to the sessions it contributes, for example in tooltips).

## Full example

```json
{
  "schema": 1,
  "source": "ci-watcher",
  "generatedAt": "2026-10-12T09:41:07.000Z",
  "sessions": [
    {
      "id": "claude:8f2b0c4e-91a1-4e6d-9a3f-2d6b0a9c7e11",
      "provider": "claude",
      "nativeId": "8f2b0c4e-91a1-4e6d-9a3f-2d6b0a9c7e11",
      "repo": "api-server",
      "repoPath": "/Users/alex/code/api-server",
      "cwd": "/Users/alex/code/api-server",
      "color": "#3B7DD8",
      "title": "Rate limiter",
      "task": "Add a sliding-window rate limiter to the public API.",
      "status": "waiting",
      "question": "Redis-backed or in-memory for the counters?",
      "questions": [
        {
          "question": "Redis-backed or in-memory for the counters?",
          "header": "Storage",
          "multiSelect": false,
          "options": ["Redis", "In-memory", "Let me decide later"]
        }
      ],
      "result": "",
      "since": "2026-10-12T09:38:21.000Z",
      "activeAt": "2026-10-12T09:38:21.000Z",
      "reportedAt": null,
      "open": true,
      "closedAt": null,
      "model": "claude-sonnet-5",
      "pid": 51234,
      "transcriptPath": "/Users/alex/.claude/projects/-Users-alex-code-api-server/8f2b0c4e.jsonl",
      "statusSource": "hook:PreToolUse",
      "origin": null,
      "stale": false,
      "lastMessage": ""
    },
    {
      "id": "codex:cli-20261012-0937",
      "provider": "codex",
      "nativeId": "20261012-0937",
      "repo": "web-app",
      "repoPath": "/Users/alex/code/web-app",
      "cwd": "/Users/alex/code/web-app/src",
      "color": null,
      "title": "Flaky checkout test",
      "task": "",
      "status": "working",
      "question": "",
      "questions": [],
      "result": "",
      "since": "2026-10-12T09:37:02.000Z",
      "activeAt": "2026-10-12T09:40:55.000Z",
      "reportedAt": null,
      "open": true,
      "closedAt": null,
      "model": "",
      "pid": 51901,
      "transcriptPath": "/Users/alex/.codex/sessions/2026/10/12/rollout-20261012-093702-cli.jsonl",
      "statusSource": "codex-rollout",
      "origin": null,
      "stale": false,
      "lastMessage": ""
    }
  ]
}
```

A file under `sources/` can leave out any field it has no value for; only `id` is required. The app fills in everything else with a safe default.

## Fields

| Field | Type | Meaning |
|---|---|---|
| `id` | string | `"<provider>:<nativeId>"` for local sessions; any unique string for an external source. |
| `provider` | string | `"claude"`, `"codex"`, or an external engine's own name. |
| `nativeId` | string | The ID the provider itself uses for this session. |
| `repo` | string | Display group: the name of the git repository. |
| `repoPath` | string | The git top level, or the working directory if there is none. |
| `cwd` | string | The session's current working directory. |
| `color` | string or null | `"#RRGGBB"` for the repository, if one is known. |
| `title` | string | Short display name for the chip. |
| `task` | string | Longer description of what the session is doing. |
| `status` | string | `working`, `waiting`, `ready`, `done`, `blocked`, or `unknown` (see aliases below). |
| `question` | string | A free-text question, if `status` is `waiting`. |
| `questions` | array | Structured questions; see below. Empty if there is only, or no, free text. |
| `result` | string | The last reported result text. |
| `since` | date or null | When the current status began. |
| `activeAt` | date or null | Last evidence that the session was doing something. |
| `reportedAt` | date or null | Timestamp of the last explicit report (see "Explicit status reports" in the README). |
| `open` | bool | Whether the underlying process is still running. |
| `closedAt` | date or null | When the session was last seen as closed. |
| `model` | string | The model name, if known. |
| `pid` | number or null | Process ID, local sessions only. |
| `transcriptPath` | string or null | Path to the session's transcript, if any. |
| `statusSource` | string | Which piece of evidence set the current status; for diagnosis only. |
| `origin` | string or null | `null` for a session from this Mac's own app; otherwise the source's display name. |
| `stale` | bool | True once the source that reported this session has stopped updating. |
| `lastMessage` | string | End of the last answer, shortened. Local only; never written to a `sources/` file. |

Each entry in `questions` has:

| Field | Type | Meaning |
|---|---|---|
| `question` | string | The question text. |
| `header` | string | A short label for the question, if any. |
| `multiSelect` | bool | Whether more than one option can be chosen. |
| `options` | array of strings | The choices offered, if any. |

## Rules

- **Staleness.** A file under `sources/` whose `generatedAt` is more than 90 seconds old is treated as stale: its sessions are still shown, but marked `stale: true`, so a reader can tell a running tool from one that stopped.
- **Local wins.** If a session from this Mac's own providers and one from a `sources/` file share the same `id`, the local one is kept and the external one is dropped.
- **Dates.** Every date is ISO 8601 with a time zone. The app always writes UTC with fractional seconds (`2026-10-12T09:41:07.123Z`); a reader may write any valid ISO 8601 offset, with or without fractional seconds.
- **Unknown fields are ignored**, not rejected - so a newer version of this format can add fields without breaking older readers, and a `sources/` file can carry extra fields of its own that this app simply skips.
- **Old status names still work.** The first version of this format used German status names; they are still accepted as aliases: `arbeitet` = `working`, `wartet` or `input` = `waiting`, `bereit` = `ready`, `fertig` = `done`, `blockiert` = `blocked`, `unbekannt` or `unklar` = `unknown`.
- **Size.** The app keeps at most 500 rows in its own `sessions.json`; a `sources/` file is read up to the same limit.
