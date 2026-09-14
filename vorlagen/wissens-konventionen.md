# Vorlage · Wissenskonventionen

*Ausfüllen, wenn Weiche 1 entschieden ist. Platzhalter in spitzen Klammern kommen aus
`PROFIL.md`. Streich, was nicht gewählt wurde.*

---

## § 1 · Die Ebenen

Es gibt <anzahl> Ebenen:

| Ebene | Name | Was darauf gehört | Wo sie liegt |
|---|---|---|---|
| 1 | <name> | Was überall gilt, unabhängig vom Bereich | <ort> |
| 2 | <name> | <…> | <ort> |
| 3 | <name> | Was nur dieses Projekt angeht | <ort> |

**Die höchste Ebene ist bereichsneutral.** Kein Bereichsname in einer Überschrift. Ein
Beispiel im Fließtext ist erlaubt, ein eigener Abschnitt nicht.

## § 2 · Die Art kommt vor der Ebene

Bevor gefragt wird, wohin etwas gehört, wird geklärt, **was** es ist:

| Art | Erkennungsmerkmal | Gehört |
|---|---|---|
| Wissen | Gilt über den Anlass hinaus | in den Wissensspeicher |
| Dokumentation | Beschreibt etwas Gebautes | neben das Gebaute |
| Aufgabe | Hat einen Zustand | in den Rückstand |
| Regel | Soll Verhalten ändern | in die Regelfläche |

**Trenntest Wissen/Doku:** Lösch das Gebaute — ist der Text noch wahr? Ja → Wissen.

## § 3 · Der Kopf jeder Notiz

```yaml
---
titel: <ein Satz>
art: wissen | doku | regel | aufgabe
ebene: <name>
stand: entwurf | gueltig | ueberholt
aktualisiert: JJJJ-MM-TT
herkunft: erarbeitet | quelle | erschlossen
pruefen_nach_tagen: <zahl>
---
```

**Pflicht:** <welche Felder>. **Optional:** <welche>.

## § 4 · Verweise

**Verweise zeigen nur nach oben.** Projekt → Bereich → allgemein. Niemals abwärts, niemals
quer zwischen zwei Bereichen.

**Ausnahme:** Texte, die über etwas schreiben — Analysen, Untersuchungen, Rückblicke —
dürfen ihren Gegenstand benennen. Sie werden getrennt gezählt.

## § 5 · Sichtbarkeit

Jede Kategorie hat ein Verzeichnis. **Eine Notiz, die kein Verzeichnis erreicht, ist
unsichtbar** — für Menschen wie für Agenten.

Das Verzeichnis wird **erzeugt oder gemessen**, nicht von Hand gepflegt. Von Hand gepflegte
Verzeichnisse sind nach vier Wochen falsch.

## § 6 · Zustellung

Beim Start jeder Sitzung liegt <was genau> im Startkontext: <Kategorien und ein Satz je
Kategorie / etwas anderes>. Kein Volltext.

**Begründung:** Ein Speicher, aus dem niemand von allein etwas liest, existiert für die
tägliche Arbeit nicht.

## § 7 · Hygiene

- Vor dem Anlegen suchen, ob es das schon gibt.
- Nichts löschen — nach `00-archiv/` verschieben.
- Eine Notiz beantwortet **eine** Frage. Zwei Fragen → zwei Notizen.
- Was überholt ist, wird als überholt markiert, nicht stillschweigend gelassen.

## § 8 · Was gemessen wird

| Messung | Verstoß bei |
|---|---|
| Notizen ohne Pflichtangaben | > 0 |
| Verweise, die nicht auflösen | > 0 |
| Verweise nach unten oder quer | > 0 |
| Notizen, die kein Verzeichnis erreicht | > 0 |
| `ebene` passt nicht zum Ort | > 0 |
| Verzeichnis älter als seine jüngste Notiz | > 0 |

Ein geprüfter Befund, der bewusst so bleibt, wird in <datei> eingetragen und verstummt
dann. **Ein Befund, der geprüft wurde, aber nicht verstummen kann, trainiert das
Wegsehen.**
