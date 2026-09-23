#!/usr/bin/env python3
"""Kontext-Wächter: meldet an Marken, wie voll das Kontextfenster einer Sitzung ist.

Gekürzte Referenzfassung für ein Agenten-Programm, das bei jedem Ereignis ein
JSON-Objekt auf der Standardeingabe liefert und sein eigenes Protokoll als
JSON-Zeilen schreibt, darunter eine Nutzungsangabe je Antwort. Bei einem anderen
Programm ändern sich die Feldnamen — das Prinzip unten nicht:

  1. Unteraufträge (eigene Sitzungen, Subagenten) haben ihr EIGENES Fenster —
     ein Lauf, der innerhalb eines solchen Unterauftrags feuert, überspringt sich.
  2. Die Fenstergröße hängt an der GENAUEN Modellkennung, nicht am Anzeigenamen —
     und diese Kennung steht oft nur am ANFANG des Protokolls, nicht am Ende.
  3. Nach einer Verdichtung FÄLLT der Füllstand — ohne Rücksetzen bliebe der
     Wächter danach für immer still, weil die höchste Marke schon gemeldet ist.

Fehler hier dürfen nie die eigentliche Arbeit blockieren: alles fällt auf `exit 0`.
Anpassen: die Feldnamen im JSON, `BIG_WINDOW_MARKERS`, und wie `message()` ausgegeben
wird (hier eine einzelne JSON-Zeile auf stdout).
"""
import json
import os
import sys
import time

STATE_DIR = os.path.expanduser("~/.agent-context-watch")

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


def read_log(path):
    """(belegte Tokens, Modellkennung) aus dem Protokoll — von hinten gelesen."""
    used = model_id = None
    for line in reversed(tail_lines(path)):
        if not line.startswith("{"):
            continue
        try:
            d = json.loads(line)
        except Exception:
            continue
        if d.get("is_subagent"):
            continue
        if used is None:
            u = d.get("usage") or {}
            if u:
                used = sum(u.get(k, 0) for k in
                           ("input_tokens", "cache_read_tokens",
                            "cache_write_tokens", "output_tokens"))
        if model_id is None:
            model_id = d.get("model_id")
        if used is not None and model_id is not None:
            break
    return used, model_id


def scan_model_id(path, nbytes=2_000_000):
    """Modellkennung am Kopf der Datei — ein späterer Wechsel landet am Ende und
    wird von `read_log` erfasst; ein Blick in die Mitte einer großen Datei lohnt
    nicht."""
    try:
        with open(path, encoding="utf-8", errors="replace") as fh:
            for line in fh:
                nbytes -= len(line)
                if nbytes < 0:
                    break
                if not line.startswith("{"):
                    continue
                try:
                    d = json.loads(line)
                except Exception:
                    continue
                if d.get("model_id"):
                    return d["model_id"]
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
    """Aufrufen, wenn das eigene Programm eine bevorstehende Verdichtung als
    eigenes Ereignis meldet — der genauere Weg gegenüber der Abfall-Regel unten."""
    sp = state_path(payload.get("session_id"))
    state = load_state(sp)
    if state.get("level"):
        save_state(sp, 0, 0.0, state.get("model_id"))


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return

    if payload.get("is_subagent"):
        return  # eigenes Fenster, nicht das der Hauptsitzung

    path = payload.get("log_path")
    if not path or not os.path.exists(path):
        return

    used, model_id = read_log(path)
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
    print(json.dumps({"message": message(reached, pct, used, window)}))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass  # ein kaputter Wächter darf keine Arbeit blockieren
    sys.exit(0)
