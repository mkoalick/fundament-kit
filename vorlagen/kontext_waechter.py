#!/usr/bin/env python3
"""Kontext-Wächter: meldet an Marken, wie voll das Kontextfenster einer Sitzung ist.

Referenzfassung für Claude Code — lauffähig gegen ein echtes Transcript
(`~/.claude/projects/*/*.jsonl`), als Hook auf `UserPromptSubmit` und
`PostToolUse` eingehängt (Einrichtung: `settings.json`, Feld `hooks`).
Bei einem anderen Programm ändern sich die Feldnamen unten — das Prinzip nicht:

  1. Unteraufträge (eigene Sitzungen, Subagenten) haben ihr EIGENES Fenster —
     ein Lauf, der innerhalb eines solchen Unterauftrags feuert, überspringt sich.
     Claude Code meldet das über `agent_id` im Hook-Payload; Subagent-Zeilen
     innerhalb eines Transcripts selbst tragen zusätzlich `isSidechain: true`.
  2. Die Fenstergröße hängt an der GENAUEN Modellkennung, nicht am Anzeigenamen —
     und diese Kennung (samt Fenster-Zusatz wie `[1m]`) steht nur in der
     `attachment`-Zeile vom Typ `model` (`attachment.identity.modelId`), meist am
     ANFANG des Transcripts. `message.model` in den Assistant-Zeilen trägt nur
     die Modellfamilie, nicht den Fenster-Zusatz.
  3. Nach einer Verdichtung FÄLLT der Füllstand — ohne Rücksetzen bliebe der
     Wächter danach für immer still, weil die höchste Marke schon gemeldet ist.
     Claude Code meldet die bevorstehende Verdichtung selbst als eigenes Ereignis
     (`hook_event_name: "PreCompact"`) — dort wird der Zähler zurückgesetzt.

Fehler hier dürfen nie die eigentliche Arbeit blockieren: alles fällt auf `exit 0`.
Anpassen: `BIG_WINDOW_MARKERS` an die eigenen Modellkennungen, und wie `message()`
ausgegeben wird (hier das Hook-Antwortformat von Claude Code).
"""
import json
import os
import sys
import time

STATE_DIR = os.environ.get("KONTEXT_WAECHTER_STATE_DIR") or os.path.expanduser(
    "~/.agent-context-watch"
)

# Melde-Marken: 50 % und danach in Zehnerschritten, plus 95 % kurz vor der
# automatischen Verdichtung der meisten Programme.
LEVELS = (50, 60, 70, 80, 90, 95)

# Zwei zusätzliche Marken — KEINE Prozentwerte, sondern feste Restbeträge in
# Tokens. Ein Abschluss (Zwischenstand sichern, festschreiben) kostet einen
# festen Betrag, keinen Anteil vom Fenster — bei einem kleinen Fenster ist
# derselbe Prozentwert also früher gefährlich als bei einem großen. Werte an
# den eigenen Abschluss-Ablauf anpassen, nicht an dieses Skript.
RESERVE_PLAN = 60_000   # darunter nichts Großes mehr anfangen
RESERVE_LAST = 35_000   # darunter reicht es für einen Abschluss nicht mehr sicher

RESET_DROP = 15           # Einbruch um mehr als das gilt als Verdichtung/Neustart
DEFAULT_WINDOW = 200_000  # Annahme bei unbekanntem Modell — im Zweifel klein
BIG_WINDOW_MARKERS = {"1m": 1_000_000}  # an die eigenen Modellkennungen anpassen
TAIL_BYTES = 400_000
HEAD_BYTES = 2_000_000


def levels_for(window):
    lv = set(LEVELS)
    for rest in (RESERVE_PLAN, RESERVE_LAST):
        pct = round((window - rest) / window * 100, 1)
        if 50 <= pct < 100:
            lv.add(pct)
    return tuple(sorted(lv))


def tail_lines(path, nbytes=TAIL_BYTES):
    with open(path, "rb") as fh:
        fh.seek(0, os.SEEK_END)
        size = fh.tell()
        fh.seek(max(0, size - nbytes))
        chunk = fh.read()
    if len(chunk) == nbytes and size > nbytes:
        chunk = chunk.split(b"\n", 1)[-1]  # angeschnittene erste Zeile wegwerfen
    return chunk.decode("utf-8", "replace").splitlines()


def read_transcript(path):
    """(belegte Tokens, Modellkennung) aus dem Transcript — von hinten gelesen.

    Belegt sind die Tokens der letzten Assistant-Zeile mit `usage`: Eingabe +
    Cache-Treffer + Cache-Aufbau + Ausgabe des letzten API-Aufrufs — und genau
    damit startet der nächste."""
    used = model_id = None
    for line in reversed(tail_lines(path)):
        if used is not None and model_id is not None:
            break
        if not line.startswith("{"):
            continue
        try:
            d = json.loads(line)
        except Exception:
            continue
        if d.get("isSidechain"):
            continue  # Subagent-Zeile — eigenes Fenster, nicht das der Sitzung
        if used is None and d.get("type") == "assistant":
            u = (d.get("message") or {}).get("usage") or {}
            if u:
                used = (
                    (u.get("input_tokens") or 0)
                    + (u.get("cache_read_input_tokens") or 0)
                    + (u.get("cache_creation_input_tokens") or 0)
                    + (u.get("output_tokens") or 0)
                )
        if model_id is None:
            att = d.get("attachment") or {}
            if att.get("type") == "model":
                model_id = (att.get("identity") or {}).get("modelId")
    return used, model_id


def scan_model_id(path, nbytes=HEAD_BYTES):
    """Modellkennung am Kopf der Datei — ein späterer Wechsel landet am Ende und
    wird von `read_transcript` erfasst; ein Blick in die Mitte einer großen Datei
    lohnt nicht."""
    try:
        with open(path, encoding="utf-8", errors="replace") as fh:
            for line in fh:
                nbytes -= len(line)
                if nbytes < 0:
                    break
                if '"modelId"' not in line:
                    continue
                try:
                    d = json.loads(line)
                except Exception:
                    continue
                att = d.get("attachment") or {}
                if att.get("type") == "model":
                    mid = (att.get("identity") or {}).get("modelId")
                    if mid:
                        return mid
    except Exception:
        pass
    return None


def window_for(model_id, used=0):
    window = DEFAULT_WINDOW
    for marker, size in BIG_WINDOW_MARKERS.items():
        if model_id and f"[{marker}]" in model_id:
            window = size
    if used > window * 1.02:
        # Belegung über dem angenommenen Fenster kann es nicht geben — auf die
        # nächstgrößere bekannte Stufe heben, statt eine unmögliche Zahl zu melden.
        bigger = [s for s in sorted(BIG_WINDOW_MARKERS.values()) if s > window and s >= used]
        if bigger:
            window = bigger[0]
    return window


def state_path(session_id):
    safe = "".join(c for c in (session_id or "unknown") if c.isalnum() or c in "-_")
    return os.path.join(STATE_DIR, f"{safe}.json")


def load_state(path):
    try:
        with open(path) as fh:
            return json.load(fh)
    except Exception:
        return {"level": 0}


def save_state(path, level, pct, model_id=None):
    os.makedirs(STATE_DIR, exist_ok=True)
    tmp = path + ".tmp"
    with open(tmp, "w") as fh:
        json.dump({"level": level, "pct": round(pct, 1), "ts": time.time(),
                   "model_id": model_id}, fh)
    os.replace(tmp, path)


def human(n):
    return f"{n/1000:.0f}k" if n < 1_000_000 else f"{n/1_000_000:.2f}M"


def message(level, pct, used, window):
    rest = max(0, window - used)
    head = f"Kontext {pct:.0f} % belegt — {human(used)} von {human(window)}, noch {human(rest)} frei."
    if rest <= RESERVE_LAST:
        return head + " Reicht für einen Abschluss, nicht mehr für neue Arbeit."
    if rest <= RESERVE_PLAN:
        return head + " Nichts Großes mehr anfangen, das den Rest füllt."
    if level >= 90:
        return head + " Guter Moment, einen Zwischenstand zu sichern."
    return head


def on_reset_event(payload):
    """Bei `PreCompact` aufgerufen: Claude Code verdichtet gleich, der Zähler
    fängt danach neu an — der genauere Weg gegenüber der Abfall-Regel in
    main(), die den Einbruch erst aus den Zahlen erschließen müsste."""
    sp = state_path(payload.get("session_id"))
    state = load_state(sp)
    if state.get("level"):
        save_state(sp, 0, 0.0, state.get("model_id"))


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return

    if payload.get("hook_event_name") == "PreCompact":
        on_reset_event(payload)
        return

    if payload.get("agent_id"):
        return  # Subagent: eigenes Fenster, nicht das der Hauptsitzung

    path = payload.get("transcript_path")
    if not path or not os.path.exists(path):
        return

    used, model_id = read_transcript(path)
    if not used:
        return
    if not model_id:
        model_id = scan_model_id(path)

    window = window_for(model_id, used)
    pct = used / window * 100.0

    sp = state_path(payload.get("session_id"))
    state = load_state(sp)
    last = state.get("level", 0)
    if last and pct < last - RESET_DROP:  # verdichtet oder geleert
        save_state(sp, 0, pct, model_id)
        last = 0

    reached = max((l for l in levels_for(window) if pct >= l), default=0)
    if reached <= last:
        return

    save_state(sp, reached, pct, model_id)
    text = message(reached, pct, used, window)
    print(json.dumps({
        "systemMessage": text,
        "hookSpecificOutput": {
            "hookEventName": payload.get("hook_event_name") or "PostToolUse",
            "additionalContext": "[kontext-waechter] " + text,
        },
    }))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass  # ein kaputter Wächter darf keine Arbeit blockieren
    sys.exit(0)
