# Erweiterung 9 · Den Arbeitsplatz selbst regeln

> **Anlass:** Der dritte maschinenweite Eingriff ist gemacht — und niemand weiß mehr, wo
> der erste war.

---

## Worum es geht

Ein Arbeitsplatz, an dem KI mitarbeitet, sammelt Eingriffe, die **außerhalb** jedes
Projekts liegen: Tastaturkürzel, Zeitpläne, Startprogramme, Systemeinstellungen,
Fensterfarben, Abkürzungen in der Kommandozeile. Sie wirken überall und stehen nirgends.

Nach einem halben Jahr weiß niemand mehr, warum sich der Rechner so verhält — und vor
allem nicht, wie man es zurücknimmt.

**Die Erweiterung ist klein und besteht im Kern aus einer einzigen Datei.**

---

## Bestandsaufnahme — wenn schon etwas da ist

*Nur für den Durchlauf aus `INTEGRIEREN.md`. Beim Neuaufbau überspringen.*

**Sieh nach, bevor du redest:**

| Wonach | Wo typischerweise | Was der Fund bedeutet |
|---|---|---|
| Abkürzungen in der Shell | `.zshrc`, `.bashrc`, `.profile` — Aliase und Funktionen mit Bezug zur KI-Arbeit | Ein maschinenweiter Eingriff, meist ohne jede Notiz dazu |
| Zeitpläne und Automatisierungen | Cron, launchd/Task-Scheduler, Hammerspoon, Automator | Wirken, ohne dass jemand hinschaut, bis sie auffallen |
| Startprogramme | Login-Items, Autostart-Einträge | Dasselbe Muster wie Zeitpläne, nur beim Anmelden statt nach Uhrzeit |
| Maschinenweite Einstellungen des KI-Werkzeugs | Hooks/Settings **außerhalb** eines Projektordners | Gehört genau hierher, nicht in eine Projektdatei |
| Eine bereits vorhandene Liste solcher Eingriffe | Datei im Stamm eines zentralen Repos, README | Vorhanden → nur noch auf Vollständigkeit und Rückweg prüfen |

**Drei Ausgangslagen, die fast alles abdecken:**

- **Kein einziger maschinenweiter Eingriff vorhanden.** Dann ist das Modul verfrüht, mit
  einer Ausnahme: Der Fenster-nach-vorn-Riegel lohnt sich unabhängig vom Bestand sofort,
  weil er nichts voraussetzt.
- **Es gibt mehrere Eingriffe, aber keine Liste davon.** Der lohnendste erste Schritt ist
  nicht, ab jetzt zu protokollieren, sondern **rückwirkend** einzusammeln, was schon da
  ist — sonst fehlt genau der älteste und am meisten vergessene Eingriff.
- **Es gibt schon eine Liste, aber ohne Rückweg-Spalte.** Dann geht es nicht um neue
  Einträge, sondern darum, den Rückweg für die vorhandenen nachzutragen — ohne ihn ist
  die Liste ein Tagebuch, kein Werkzeug.

> **Der häufigste Fehlgriff an dieser Stelle:** Projektspezifisches in dieselbe Liste
> eintragen wollen, weil es gerade bequem ist — die Liste ist dann in kurzer Zeit eine
> zweite, schlechtere Projektdokumentation.

---

## Die Entscheidung

Es gibt eigentlich nur eine: **Wird jeder Eingriff notiert, oder nicht?**

Und die Antwort ist nur dann ein Ja, wenn das Notieren **eine Zeile** kostet. Alles, was
mehr verlangt, wird nach drei Wochen nicht mehr gemacht.

---

## Was in jedem Fall gilt

### Projektbezogenes gehört nicht hierher

Diese Datei ist ausschließlich für maschinenweite Eingriffe. Was zu einem Projekt gehört,
gehört ins Projekt — sonst ist die Liste nach kurzer Zeit eine zweite, schlechtere
Projektdokumentation.

### Der Rückweg ist die wichtigste Spalte

Nicht „was habe ich gemacht", sondern „wie mache ich es rückgängig". Ohne diese Spalte ist
die Liste ein Tagebuch; mit ihr ist sie ein Werkzeug.

### Der Vordergrund gehört dem, der tippt

Der eine Eingriff, der sich immer lohnt: **Alles, was ein Fenster nach vorn holt, tut das
nur auf ausdrückliche Ansage.** Ein Agent, der eine Datei öffnet, um „mal eben zu zeigen",
reißt jemanden aus der Arbeit — und tut es dann alle paar Minuten.

Die Trennlinie ist nicht, wie nützlich das Fenster wäre, sondern **wer es angefordert
hat**. Wer einen Ausnahme-Marker setzt, weil das Ergebnis sehenswert ist, hebt die Regel
auf, die er gerade anwendet.

Das lässt sich als Riegel bauen — einer der wenigen, die sich sofort lohnen. Was ein Riegel
können muss, steht in `../00-kern/02-regeln-und-grenzen.md`, Entscheidung D; wie er im
konkreten Werkzeug heißt, in `../WERKZEUG-ABBILDUNG.md`; und was unter Windows anders ist,
in `../WINDOWS-UND-MAC.md`.

### Ein Wächter für den Kontextfüllstand lohnt sich früh

Eine Sitzung, deren Kontext volläuft, wird verdichtet — und verliert dabei Genauigkeit.
Eine Meldung bei der Hälfte und dann in Schritten kostet eine Zeile und spart Nacharbeit.

**Aber:** Ein solcher Hinweis muss **seinen Bezugswert kennen**. Die Fenstergröße hängt am
Modell, und ein Wächter, der das falsche annimmt, meldet entweder Unsinn oder schweigt
genau dort, wo es eng wird. Im Zweifel das kleinere Fenster annehmen — eine Meldung zu
früh kostet eine Zeile, eine zu spät die Arbeit.

---

## Woran man merkt, dass es bricht

| Zu messen | Bricht, wenn |
|---|---|
| Zeitpläne und Startprogramme auf dem Rechner, die nicht in der Liste stehen | > 0 |
| Einträge ohne Rückweg | > 0 |
| Alter des letzten Eintrags | älter als der letzte erinnerte Eingriff |

---

## Vorlage

```markdown
# Eingriffe am Arbeitsplatz

| Datum | Art | Was | Wo (Datei) | Steuerung / Rückweg |
|---|---|---|---|---|
| JJJJ-MM-TT | Zeitplan | <was es tut> | <pfad> | <befehl zum abschalten> |
| JJJJ-MM-TT | Abkürzung | <was es tut> | <datei> | Zeile entfernen |
| JJJJ-MM-TT | Riegel | <was es verhindert> | <datei> | Datei entfernen |
```

**Arten, die sich bewährt haben:** Zeitplan · Startprogramm · Abkürzung · Riegel ·
Systemeinstellung · Fensterautomatik · Werkzeug (systemweit installiert)

**Im Profil vermerken:** wo die Liste liegt und dass jeder Eingriff hineingehört — auch
der aus einer anderen Sitzung.
