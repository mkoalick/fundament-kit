# Einstieg — für die KI, die das Kit gerade geholt hat

**An die KI:** Die Person hat dir einen Freigabelink gegeben, du hast das Kit nach
`~/fundament-kit` geholt, und jetzt bist du hier. Lies nur diese Datei, dann geht es los.
`START-HIER.md`, `INTEGRIEREN.md` und die Module liest du erst, wenn diese Datei dich
gezielt dorthin schickt — nicht vorher, nicht auf Vorrat.

---

## Schritt 1 · Begrüßen und genau eine Frage stellen

Begrüß kurz, sag in einem Satz, was das Kit ist — Lehren und Vorlagen für die Arbeit mit
KI-Agenten, keine Software, nichts wird installiert — und frag dann **genau eines**:

> „Willst du kurz alles durchgehen, oder geht es dir um ein bestimmtes Thema?"

**Schnellweg:** Nennt die Person schon ein Thema, auch umschrieben, geh **direkt** zu
dessen Modul — ohne die Schnellprüfung aus Schritt 2. Diese Tabelle ordnet zu und dient
gleich in Schritt 2 als Grundlage:

| Modul | Datei | Auch genannt als |
|---|---|---|
| Arbeitsweise | `vorlagen/arbeitsweise.md` | Antwortstil, Tonfall, wie die KI antwortet |
| Wissen | `00-kern/01-wissen.md` | Wissensbasis, Notizen organisieren |
| Regeln und Grenzen | `00-kern/02-regeln-und-grenzen.md` | Regeln, CLAUDE.md, Berechtigungen, Riegel |
| Quelle der Wahrheit | `00-kern/03-quelle-der-wahrheit.md` | Was gilt bei Widerspruch, Sync-Richtung |
| Übergabe | `00-kern/04-uebergabe.md` | Handover, Sitzungen übergeben, Sitzungsende |
| Bereiche trennen | `10-erweiterungen/01-bereiche-trennen.md` | Mandanten, Kunden trennen |
| Mehrere Projekte überblicken | `10-erweiterungen/02-mehrere-projekte.md` | Projektübersicht, Dashboard |
| Arbeit delegieren | `10-erweiterungen/03-delegation.md` | Subagenten, parallel arbeiten |
| Unbeaufsichtigt arbeiten | `10-erweiterungen/04-unbeaufsichtigt.md` | Nachtläufe, Cron, Automatisierung, Backlog |
| In ein anderes Werkzeug spiegeln | `10-erweiterungen/05-spiegel.md` | Notion-Sync, Wiki-Spiegel |
| Dokumente erzeugen | `10-erweiterungen/06-dokumente.md` | Reports, Excel/Word/PowerPoint bauen |
| Eigene Werkzeuge bauen | `10-erweiterungen/07-werkzeugbau.md` | Skills, eigene Commands |
| Mehrere Modelle nutzen | `10-erweiterungen/08-mehrere-motoren.md` | Claude und Codex, Motorwahl |
| Arbeitsplatz selbst regeln | `10-erweiterungen/09-arbeitsplatz.md` | Maschinenweite Einstellungen, Hooks, Aliase |
| Web und Medien | `10-erweiterungen/10-web-und-medien.md` | Website, Bilder/Videos fürs Web |

Für ein gefundenes Modul gilt ab jetzt der Ablauf aus Schritt 3.

---

## Schritt 2 · Sonst: die Schnellprüfung

Will die Person alles durchgehen, prüfst du **still und zügig** — das Ergebnis steht nach
wenigen Minuten, nicht nach einer halben Stunde. Kein Zwischenbericht je Modul, keine
Rückfrage währenddessen.

Für jedes Modul aus der Tabelle oben: Öffne nur dessen eigenen Abschnitt
„## Bestandsaufnahme" — jedes Modul hat einen — und geh nur die dort genannte
Sieh-nach-Liste durch, im Projekt bzw. Home der Person. **Nur lesen, nichts anlegen, nichts
fragen.** Den Rest des jeweiligen Moduls liest du jetzt nicht.

Ergebnis ist **eine Tabelle**, vier Spalten:

| Modul | Bringt | Bei dir | Empfehlung |
|---|---|---|---|
| … | ein Satz, wofür es gut ist | vorhanden / teilweise / fehlt | ja / später / nicht nötig |

Darunter **höchstens drei Sätze**: was zuerst dran wäre und warum. Keine Begründung je
Zeile — die steht schon in der Tabelle.

---

## Schritt 3 · Die Person wählt, du baust

Für jedes gewählte Modul gilt genau der Ablauf aus `INTEGRIEREN.md`: Bestandsaufnahme
(sofern in Schritt 2 nicht schon geschehen) → was das Modul mitbringt → Vorschlag in drei
Töpfen (lohnt sich / brauchst du nicht / später) → Zustimmung abwarten → einbauen.

**Nichts wird geschrieben, ohne dass die Person zugestimmt hat.** Und: **nichts, was schon
funktioniert, wird durch etwas Gleichwertiges ersetzt**, nur weil das Kit es anders
vorschlägt.

**Biet das Anpassen ausdrücklich an**, bevor du etwas ablegst: eigene Namen, eigene
Sprache, eigene Pfade, kleinerer oder größerer Umfang als im Kit. Eine 1:1-Kopie ist so
gut wie nie richtig — sag ihr das auch.

---

## Schritt 4 · Abschluss

Sind ein oder mehrere Module eingebaut, fass in einer **Liste** zusammen, was jetzt
existiert — je Zeile die Datei und ein Satz, wozu sie da ist.

Sag außerdem, wie es weitergeht: „Sag mir jederzeit **‚aktualisiere das Kit'** — dann hole
ich die neueste Fassung über denselben Weg, mit dem du das Kit bekommen hast, zeig dir nur,
was sich in `VERSION.md` geändert hat, und du entscheidest, ob du es übernimmst."

---

## Grenzen, die immer gelten

- Solange die Person nichts gewählt und nichts zugestimmt hat, wird **nichts außerhalb von
  `~/fundament-kit` verändert**.
- **Keine Zugangsdaten oder Secrets anfassen** — auch nicht lesen, um zu prüfen, ob
  welche da sind.
- **Nichts pushen, keine Marke setzen.** Was im Projekt der Person landet, committest du
  nur auf ihre Ansage, und dann in ihrem Repo — nie in `~/fundament-kit`.
