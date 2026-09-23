#!/usr/bin/env python3
"""Statuszeile: zeigt unter jeder Antwort, wie voll das Kontextfenster gerade ist.

Ergänzt den Kontext-Wächter (`kontext_waechter.py`), der nur an Marken meldet —
diese Zeile beantwortet stattdessen "wie stehe ich gerade", und zwar außerhalb
des Gesprächs: Eine Statuszeile kostet kein einziges Token, ein Hinweis im
Kontext dagegen schon.

Gerechnet wird NICHT ein zweites Mal — Füllstand und Fenstergröße kommen aus
`kontext_waechter.py`. Zwei Implementierungen derselben Zahl wären zwei Zahlen.

Eingabe ist wie beim Wächter ein JSON-Objekt auf stdin; ausgegeben wird eine
einzelne Zeile, ANSI-Farben erlaubt.
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import kontext_waechter as kw  # noqa: E402

GRUEN, GELB, ORANGE, ROT = "\033[32m", "\033[33m", "\033[38;5;208m", "\033[31m"
AUS = "\033[0m"

# Ab hier ist keine Aussage über nachlassende Qualität gemeint — nur: ein neuer
# Themenwechsel wird ab hier teuer, weil jeder weitere Schritt das ganze
# bisherige Gespräch erneut mitliest.
EFFECTIVE_PCT = 60


def balken(pct, breite=10):
    voll = min(breite, max(0, round(pct / 100 * breite)))
    return "█" * voll + "·" * (breite - voll)


def zeile(payload):
    path = payload.get("log_path")
    if not path or not os.path.exists(path):
        return ""

    used, model_id = kw.read_log(path)
    if not used:
        return ""
    if not model_id:
        model_id = kw.scan_model_id(path)

    window = kw.window_for(model_id, used)
    pct = used / window * 100
    rest = max(0, window - used)

    if rest <= kw.RESERVE_LAST:
        lampe, farbe, hinweis = "🔴", ROT, " · jetzt abschließen"
    elif rest <= kw.RESERVE_PLAN:
        lampe, farbe, hinweis = "🟠", ORANGE, " · letzte Etappe"
    elif pct >= EFFECTIVE_PCT:
        lampe, farbe, hinweis = "🟡", GELB, " · neues Thema? jetzt schneiden"
    else:
        lampe, farbe, hinweis = "🟢", GRUEN, ""

    return (f"{lampe} {farbe}{balken(pct)} {pct:.0f} % · {kw.human(rest)} frei"
            f"{hinweis}{AUS}")


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        payload = {}
    try:
        print(zeile(payload))
    except Exception:
        print("")  # eine kaputte Statuszeile darf die Eingabe nie blockieren


if __name__ == "__main__":
    main()
    sys.exit(0)
