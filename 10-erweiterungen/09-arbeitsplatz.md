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

### Vollzugriff ohne Rückfragen — nur mit Geländer

Manche Arbeit besteht aus vielen kleinen, gut überschaubaren Schritten hintereinander —
Refactoring, Textarbeit, ein Durchlauf über viele ähnliche Dateien. Bei jedem Schritt
einzeln nachzufragen kostet dann mehr Zeit, als eine gelegentliche Fehlentscheidung kosten
würde. Die meisten Agenten-Programme haben dafür einen Modus, der jede Berechtigungsabfrage
abschaltet.

**Das ist ein Tausch, kein Fortschritt.** Es lohnt sich, wo ein Fehlgriff **sofort auffällt**
und **billig rückgängig** ist — ein Projekt unter Versionsverwaltung, ein enger Ordner, eine
vertraute Aufgabenart. Es lohnt sich nicht bei Migrationen, fremdem Code oder irgendetwas
außerhalb der Versionsverwaltung — und schon gar nicht mit einem schwächeren Motor am
Steuer: **ein schwächeres Modell plus keine Rückfragen ist die schlechteste Paarung**, siehe
`08-mehrere-motoren.md`.

**Der Riegel dazu ist derselbe wie in `../00-kern/02-regeln-und-grenzen.md`, „Zwei Riegel,
die sich immer lohnen" Nr. 1:** Vollzugriff hängt am Arbeitsverzeichnis, nicht am Modus. Eine
Abkürzung, die diesen Modus startet, prüft deshalb selbst, ob das Arbeitsverzeichnis
innerhalb der vorgesehenen Projekt-Wurzel liegt — und fragt außerhalb einmal nach, statt
denselben Vollzugriff stillschweigend auf den ganzen Rechner auszuweiten.

**Eine Falle, die nur in diesem Modus zuschlägt:** Manche Editoren schicken ihre eigene
Umgebungs-Aktivierungszeile **verzögert** ins Terminal — Sekunden, nachdem es existiert.
Startet in der Zwischenzeit schon der Agent, gehört die Eingabe dann seiner Prompt-Zeile: Die
Zeile landet dort samt Enter und wird **ohne Rückfrage ausgeführt**, weil genau das der Sinn
dieses Modus ist. Das ist ein Wettlauf, keine Ausnahme — er tritt bei jedem Terminal auf, das
ein Editor öffnet, während dessen automatische Umgebungsaktivierung an ist. Zwei Teile der
Lösung: die automatische Aktivierung im Editor abschalten, und die Abkürzung selbst
aktiviert die Umgebung **synchron, vor dem Start** — dann erben auch die eigenen Kommandos
des Agenten sie gleich mit.

Beispielhaft als Shell-Funktion (zsh; der Beispielbefehl `claude --dangerously-skip-permissions`
gehört zu einem konkreten Programm — wie andere heißen, steht in `../WERKZEUG-ABBILDUNG.md`):

```zsh
# Projekt-Umgebung suchen und aktivieren — vor dem Start, synchron
av() {
  if [ -n "$VIRTUAL_ENV" ]; then
    echo "Umgebung bereits aktiv: $VIRTUAL_ENV"
    return 0
  fi
  local d="${${1:-$PWD}:A}" c
  while true; do
    for c in "$d/.venv" "$d/venv"; do
      if [ -f "$c/bin/activate" ]; then
        source "$c/bin/activate"
        echo "Umgebung aktiviert: $c"
        return 0
      fi
    done
    [ "$d" = "$HOME" ] || [ "$d" = "/" ] && break
    d="${d:h}"
  done
  return 1
}

# Agent ohne Berechtigungsabfragen starten — mit Geländer fürs Arbeitsverzeichnis
yolo() {
  local here="${PWD:A}" safe="${HOME:A}/<projekt-wurzel>"   # anpassen
  if [[ "$here" != "$safe" && "$here" != "$safe"/* ]]; then
    print -u2 "⚠️  Startet OHNE Berechtigungsabfragen."
    print -u2 "    Arbeitsverzeichnis: $here — liegt außerhalb von $safe."
    if [[ ! -o interactive ]]; then
      print -u2 "    Nicht-interaktiv, also abgebrochen."
      return 1
    fi
    if ! read -q "?    Trotzdem starten? [y/N] "; then
      print; return 1
    fi
    print
  fi
  av
  claude --dangerously-skip-permissions "$@"
}
```

Windows-Fassung (PowerShell) und die Grenzen der Übersetzung: `../WINDOWS-UND-MAC.md`.

### Wie voll das Kontextfenster ist — zwei Anzeigen, zwei Zwecke

Eine Sitzung, deren Kontext volläuft, wird irgendwann automatisch verdichtet — und verliert
dabei Genauigkeit. Zwei Fragen stehen dabei nebeneinander und brauchen verschiedene
Antworten: **„wie stehe ich gerade"** (nach jeder Antwort neu) und **„wann wird es eng"**
(nur an ein paar Marken). Aus dem einen Bedürfnis eine einzige Lösung zu machen, ist der
naheliegende Fehler.

**Das Prinzip: ablesen, nicht schätzen.** Die belegten Tokens stehen im eigenen Protokoll der
Sitzung — in der letzten Zeile mit einer Nutzungsangabe steht die Summe aus Eingabe,
Cache-Treffer, Cache-Aufbau und Ausgabe des letzten Aufrufs, und genau damit startet der
nächste. Das ist eine Ablesung, keine Schätzung — und die einzige Zahl, die zählt.

**Drei Fallstricke, an denen ein selbstgebauter Wächter sonst still statt falsch wird:**

1. **Unteraufträge haben ihr eigenes Fenster.** Ein Agent, der einen Unterauftrag an eine
   eigene Sitzung vergibt (Task, Subagent, Delegation — siehe `03-delegation.md`), darf
   deren Füllstand nicht mit dem der Hauptsitzung verwechseln. Ein Wächter, der innerhalb
   eines solchen Unterauftrags feuert, überspringt sich selbst.
2. **Die Fenstergröße hängt an der genauen Modellkennung, nicht am Anzeigenamen.** Dieselbe
   Modellfamilie kann mehrere Fenstergrößen haben, und der Unterschied steht oft nur in
   einem Zusatz zur genauen Kennung — die wiederum oft nur **am Anfang** des Protokolls
   einmal auftaucht, nicht am Ende. Wer nur das Ende liest, findet sie nicht und nimmt in
   guter Absicht die kleinere, falsche Annahme.
3. **Nach einer Verdichtung fällt der Füllstand — und der Wächter muss das merken.** Ohne
   ein Zurücksetzen bliebe er nach der höchsten je gemeldeten Marke für immer still. Der
   genauere Weg: Das Programm meldet die Verdichtung selbst als eigenes Ereignis, und genau
   dort wird der Zähler zurückgesetzt. Ersatzweg für Programme, die das nicht melden: Ein
   Einbruch weit unter die zuletzt gemeldete Marke gilt als Indiz und setzt ebenfalls zurück.

**Warum zwei Anzeigen und nicht eine:** Ein Hinweis, der bei **jeder** Antwort in den Kontext
geschrieben wird, verbraucht genau das, wovor er warnt — und das Modell liest ihn mit, obwohl
er eigentlich an den Menschen gerichtet ist. Der Dauerzustand gehört deshalb an einen Ort,
der nichts kostet: eine **Statuszeile**, die das Agenten-Programm ohnehin schon im Terminal
rendert, außerhalb des Gesprächs. Der **Wächter** meldet sich dagegen nur an den paar Marken,
die wirklich etwas bedeuten — bei der Hälfte, dann in Zehnerschritten, und an zwei
zusätzlichen Marken kurz vor der automatischen Verdichtung.

> ⚠️ Diese Marken sind **keine Aussage über nachlassende Qualität** — dafür fand sich in
> eigenen Daten kein Beleg. Sie sind Arithmetik: Jeder weitere Schritt liest das ganze
> bisherige Gespräch erneut mit, ein Schritt bei 80 % Füllstand kostet also deutlich mehr als
> derselbe bei 30 %. Und die Meldung muss ohnehin **sachlich** klingen: Ein Hinweis, der wie
> eine eingeschleuste Anweisung auftritt, verstößt gegen Riegel-Eigenschaft 4 aus
> `../00-kern/02-regeln-und-grenzen.md` und wird als Manipulationsversuch verworfen — auch
> wenn er es nicht ist.

**Zwei zusätzliche Marken lohnen sich, und sie sind keine Prozentwerte:** ein fester Betrag
freier Tokens, ab dem nichts Großes mehr begonnen werden sollte, und ein kleinerer, ab dem
nur noch der Abschluss selbst passt. Ein Abschluss (Zwischenstand sichern, festschreiben)
kostet nämlich einen **festen Betrag**, keinen Anteil vom Fenster — bei einem kleinen Fenster
ist derselbe Prozentwert also viel früher gefährlich als bei einem großen.

**Einrichtung, werkzeugneutral:** Ein Riegel, der bei jeder neuen Eingabe **und** nach jedem
Werkzeugaufruf prüft (misst öfter, verpasst dadurch keinen Sprung), plus ein Zusatz für das
Verdichtungs-Ereignis, wo es das gibt. Dazu ein Eintrag, der dem Agenten-Programm sagt, mit
welchem Befehl es seine Statuszeile befüllen soll. Wie diese Ereignisse und diese Einstellung
im eigenen Werkzeug heißen, steht in `../WERKZEUG-ABBILDUNG.md`.

**Referenzfassung, gekürzt und lauffähig:** `../vorlagen/kontext_waechter.py` (der Riegel,
meldet an Marken) und `../vorlagen/statuszeile.py` (der Dauerstand, rendert eine Zeile).
Beide sind für ein Protokoll geschrieben, das JSON-Zeilen mit einer Nutzungsangabe schreibt
und Ereignisse als JSON auf der Standardeingabe liefert — bei einem anderen Programm ändert
sich das Format der Felder, nicht das Prinzip dahinter.

---

## Woran man merkt, dass es bricht

| Zu messen | Bricht, wenn |
|---|---|
| Zeitpläne und Startprogramme auf dem Rechner, die nicht in der Liste stehen | > 0 |
| Einträge ohne Rückweg | > 0 |
| Abkürzungen mit Vollzugriff ohne Geländer-Prüfung | > 0 |
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
Systemeinstellung · Fensterautomatik · Werkzeug (systemweit installiert) · Anzeige
(Statuszeile)

**Im Profil vermerken:** wo die Liste liegt und dass jeder Eingriff hineingehört — auch
der aus einer anderen Sitzung.
