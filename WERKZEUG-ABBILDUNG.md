# Wie das hier in deinem Werkzeug heißt

*Das Kit spricht bewusst werkzeugneutral von **Regel**, **Werkzeug** und **Riegel**, weil
sich die Produkte schneller ändern als die Prinzipien. Diese Datei schlägt die Brücke.*

*Prüf die Namen im Zweifel in der aktuellen Dokumentation nach — sie ändern sich. Die drei
Formen dahinter nicht.*

---

## Die drei Formen

| Kit-Begriff | Was es leistet | Heißt bei Agenten-Werkzeugen typischerweise |
|---|---|---|
| **Regel** | Text, der in jeder Sitzung mitgelesen wird | Eine Projekt- oder Benutzeranweisungsdatei im Stammverzeichnis (`CLAUDE.md`, `AGENTS.md`, `.cursorrules`, „Custom Instructions"), oft ergänzt um einen Ordner für einzelne Regeldateien |
| **Werkzeug** | Ein Ablauf, der auf Zuruf geladen wird | „Skill", „Command", „Slash Command", „Prompt", „Recipe" — meist eine Datei mit Kopfangaben, deren **Beschreibung** entscheidet, wann sie geladen wird |
| **Riegel** | Code, der einen Vorgang abweist | „Hook", „Guard", „Pre-Tool-Use" — ein Programm, das vor oder nach einer Werkzeugnutzung läuft und einen Vorgang **ablehnen** kann. Fehlt das im Werkzeug: die Versionsverwaltung hat eigene Riegel, die unabhängig davon greifen |

---

## Die anderen Bausteine

| Kit-Begriff | Typische Entsprechung |
|---|---|
| **Zustellung beim Start** | Ein Riegel, der beim Sitzungsstart auslöst und Text in den Kontext legt |
| **Gemeinsame Ebene einhängen** | Eine Verknüpfung im Projektordner, oder ein Pfad, den die Projektregel nennt |
| **Abgegebene Sitzung** | Das Kommandozeilenprogramm des Agenten im nicht-interaktiven Modus, mit dem Zielverzeichnis als Arbeitsverzeichnis |
| **Rückstand als Aufgaben** | Textdateien mit Kopfangaben. Ein Projektwerkzeug taugt auch — dann ist es die Wahrheit, und das gehört in Weiche 3 |
| **Vollzugriffsmodus** | Ein Start-Flag oder eine Einstellung des Agenten-Programms, die jede Berechtigungsabfrage abschaltet (z. B. `--dangerously-skip-permissions`, `bypassPermissions`) — kein Riegel für sich, sondern das, wogegen der eigene Geländer-Riegel antritt |
| **Statuszeile** | Eine vom Agenten-Programm gerenderte Kopf- oder Fußzeile im Terminal, falls vorhanden — sonst ein selbstgebauter Prompt-Zusatz, der außerhalb des Gesprächs rendert und deshalb nichts kostet |

---

## Drei Dinge, die überall gelten

**Die Beschreibung eines Werkzeugs entscheidet, ob es geladen wird.** Nicht sein Inhalt,
nicht sein Name. Schreib sie wie eine Suchanfrage: die Wörter, die jemand benutzt, der das
braucht — und ausdrücklich, wann es **nicht** gilt.

**Ein Riegel, der am gemeinsamen Schritt hängt, schlägt einen je Werkzeug.** Ein Riegel in
der Versionsverwaltung erfasst jeden, der etwas festschreibt — auch den Agenten, der die
Regeln nie gelesen hat. Ein Riegel im Agenten-Werkzeug erfasst nur dieses eine.

**Unterschiedliche Werkzeuge laden unterschiedlich.** Das eine folgt Verknüpfungen, das
andere nicht. Das eine liest einen ganzen Ordner, das andere genau eine Datei. Prüf das für
jedes Werkzeug **einzeln** nach — und miss danach, ob wirklich ankommt, was ankommen soll.
Das ist keine Vorsicht, sondern die Lehre aus einem Fall, in dem zwei Regeln ein zweites
Werkzeug **nie** erreichten.
