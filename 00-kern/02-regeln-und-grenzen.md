# Weiche 2 · Regeln und Grenzen

> **Die Frage:** Was ist eine Bitte, was ein Werkzeug, was ein Riegel — und wie kommt
> das eine wie das andere dorthin, wo es wirkt?

---

## Worum es geht

Fast jeder, der mit KI-Agenten arbeitet, schreibt irgendwann Regeln auf. Und fast jeder
schreibt dabei drei verschiedene Dinge in dieselbe Datei, obwohl sie unterschiedlich
funktionieren und unterschiedlich versagen.

**Das ist die Unterscheidung, um die es hier geht — und sie ist wichtiger als jeder
einzelne Regeltext:**

| | Was es ist | Wirkt | Versagt, wenn |
|---|---|---|---|
| **Regel** | Text, der immer mitgelesen wird | Als Neigung. Der Agent *will* sich daran halten | Der Kontext voll ist, die Regel lang ist, oder etwas Dringenderes dagegen zieht |
| **Werkzeug** | Ein Ablauf, der auf Zuruf geladen wird | Wenn er passt und erkannt wird | Die Beschreibung nicht zum Anlass passt |
| **Riegel** | Code, der einen Vorgang abweist | Immer. Er fragt nicht | Er zu breit greift und richtige Arbeit blockiert |

**Der Merksatz:** *Eine Regel ist Kontext. Eine harte Grenze ist Code.*

Wer eine Grenze als Regel formuliert, hat sie nicht gezogen — er hat sie gewünscht. Das
hält, solange nichts dagegen drückt, und genau dann nicht mehr, wenn es darauf ankäme.

---

## Bestandsaufnahme — wenn schon etwas da ist

*Nur für den Durchlauf aus `INTEGRIEREN.md`. Beim Neuaufbau überspringen.*

**Sieh nach, bevor du redest:**

| Wonach | Wo typischerweise | Was der Fund bedeutet |
|---|---|---|
| Anweisungsdatei(en) im Stamm | `CLAUDE.md`, `AGENTS.md`, `.cursorrules`, ein Abschnitt „Rules" in der `README` | Vorhanden → das ist schon die Regelfläche. Prüf als Erstes, ob Regel, Werkzeug und Riegel darin vermischt sind |
| Deren Länge | Zeilenzahl, Zahl der Abschnitte | Über eine Bildschirmseite → Kandidat fürs Auslagern als Werkzeug, siehe Entscheidung A, Frage 3 |
| Mehrere solcher Dateien nebeneinander | `CLAUDE.md` neben `.cursorrules` neben `AGENTS.md` | Mehrere Werkzeuge im Einsatz → Entscheidung C wird sofort wichtig. Prüf, ob sie schon auseinanderlaufen |
| Hooks, Pre-Commit-Prüfungen, CI-Schritte | `.claude/hooks`, `.git/hooks`, `.github/workflows`, `husky` | Vorhanden → es gibt schon Riegel. Frage ist, ob sie am richtigen Punkt sitzen, siehe Entscheidung D |
| Schutz für Zugangsdaten | `.gitignore`-Einträge für `.env`/Secrets, ein Scanner im Commit-Weg | Fehlt er → das ist der höchste Hebel, siehe „Zwei Riegel, die sich immer lohnen" |
| Berechtigungs- oder Permission-Einstellungen | `.claude/settings.json`, Freigabe-Modi eines anderen Werkzeugs | Vorhanden → die Vollzugriffsfrage ist schon angegangen. Fehlt sie → wahrscheinlichster erster Fund |

**Drei Ausgangslagen, die fast alles abdecken:**

- **Keine Anweisungsdatei, alles im Kopf.** Der lohnendste erste Schritt ist nicht die
  Dreiteilung, sondern eine einzige kurze Datei mit dem Nötigsten. Die Unterscheidung
  Regel/Werkzeug/Riegel kommt, sobald die Datei wächst.
- **Eine große Anweisungsdatei, die alles trägt.** Ton, Testbefehle, Verbote, manchmal
  sogar Wissen — alles in einer Datei. Lohnendster erster Schritt ist Test 1 aus
  Entscheidung A: jeden Absatz markieren, oft ist die Hälfte gar keine Regel.
- **Mehrere Werkzeuge mit eigenen Regeldateien.** Meist schon leicht auseinandergelaufen.
  Lohnendster erster Schritt ist ein Inhaltsabgleich nach Entscheidung C — nicht nach
  Zeitstempel, sondern nach Text.

> **Der häufigste Fehlgriff an dieser Stelle:** Sofort einen Riegel vorschlagen, obwohl
> der Fall bisher nur eine Regel braucht. Ein Riegel für etwas, das noch nie passiert ist,
> kostet mehr, als er bringt.

---

## Entscheidung A — Was wird was

Für jede Sache, die geregelt werden soll, drei Fragen in dieser Reihenfolge:

**1. Was passiert im schlimmsten Fall, wenn sie gebrochen wird?**
- Verlust, der nicht rückholbar ist; etwas verlässt das Haus; Geld; fremde Daten
  → **Riegel**. Keine Diskussion.
- Ärger, Nacharbeit, Unordnung → weiter zu Frage 2.

**2. Gilt sie immer oder nur bei einer bestimmten Tätigkeit?**
- Immer, in jeder Sitzung, unabhängig vom Anlass → **Regel**.
- Nur wenn jemand gerade X tut → **Werkzeug**. Es lädt sich, wenn X ansteht, und kostet
  sonst nichts.

**3. Ist sie so lang, dass sie als Regel den Kontext belastet?**
- Über etwa eine Bildschirmseite → **Werkzeug**, auch wenn sie immer gilt. Lange Regeln
  werden überlesen, und zwar zuerst in ihren hinteren Teilen.

> **Der häufigste Fehlgriff:** Alles wird Regel. Nach ein paar Monaten stehen zwanzig
> Regeln im Startkontext, die Hälfte davon gilt selten, und die wichtige geht darin
> unter. Regeln haben einen Preis, den man nicht sieht — er wird woanders bezahlt.

> **Und das ist keine Vermutung:** Mehr geladener Kontext — mehr Regeln, mehr Werkzeuge,
> mehr Anweisungen — senkt die Befolgungsrate **nachweislich**. Wer immer mehr hinzufügt
> in der Annahme, das könne nur helfen, verschlechtert genau die Zuverlässigkeit, die er
> verbessern wollte. Zu „mehr Spezialwerkzeuge = bessere Ergebnisse" existiert bis heute
> keine belastbare Vorher-Nachher-Messung.

---

## Entscheidung B — Wo Regeln liegen und wie sie ankommen

Zwei Wege, die sich nicht ausschließen:

### Immer geladen — das Ladefenster

Eine feste, **kurze** Liste von Regeln, die bei jedem Sitzungsstart im Kontext ist.
Faustregel: **fünf bis acht Dateien, zusammen unter etwa zweitausend Wörtern.**

Was hinein gehört: Arbeitsweise, Umgangsform, unumstößliche Konventionen. Was nicht:
alles, was nur manchmal gilt.

### Auf Abruf

Alles andere. Wird geladen, wenn es dran ist — durch ein Werkzeug, durch einen Verweis
in einer geladenen Regel, oder weil jemand danach fragt.

> **Die Regel über die Regeln:** Eine Regel, die im Ladefenster steht, muss jeden Tag
> ihren Platz verdienen. Streich regelmäßig — nicht, weil sie falsch geworden ist,
> sondern weil sie selten gilt.

---

## Entscheidung C — Was passiert, wenn mehrere Agenten mitlesen

Sobald ein zweites Programm oder Modell mitarbeitet, stellt sich eine unangenehme Frage:
**Liest es dieselben Regeln?**

Meistens nicht. Verschiedene Werkzeuge laden Regeln unterschiedlich — das eine folgt
Verknüpfungen, das andere nicht; das eine lädt einen Ordner, das andere genau eine Datei.
Die naheliegende Lösung ist, Kopien anzulegen. Und Kopien driften.

**Gelernt an:** Eine Regelkopie für ein zweites Werkzeug hing sechs Tage auf einer
Fassung, deren Fehler am selben Tag korrigiert worden war, an dem die Korrektur 741 tote
Verweise beseitigte. Das zweite Werkzeug arbeitete also weiter nach der Anweisung, die
den Schaden verursacht hatte.

**Und ein Riegel am gemeinsamen Schritt schlägt einen Riegel je Werkzeug.** Ein Riegel, der
am Festschreibe-Schritt selbst hängt, erfasst **jeden** Akteur, der ihn ausführt — auch
den, der die Regeln nie gelesen hat.

**Die drei Möglichkeiten:**

| Weg | Bringt | Kostet |
|---|---|---|
| **Verknüpfung** statt Kopie | Kann nicht driften | Geht nur, wo das Werkzeug Verknüpfungen folgt |
| **Erzeugte Kopie** aus einer Quelle | Eine Quelle, viele Formen | Ein Verteilschritt, der laufen muss |
| **Gepflegte Kopie** | Sofort da | Driftet. Immer. Nur eine Frage der Zeit |

**Empfehlung:** Verknüpfung, wo es geht; erzeugte Kopie, wo nicht. Und in beiden Fällen
eine Messung, die **Inhalte vergleicht, nicht Zeitstempel**.

> **Nicht nur Regeln driften.** Auch Handlungsanweisungen in Werkzeugen, Vorlagen und
> Hilfstexten driften — und zwar unabhängig. In einem Fall wies eine Werkzeug-Anleitung
> an, direkt in eine gemeinsam genutzte Datei zu schreiben; genau das, was die zugehörige
> Konvention verbietet. **Die Regel war überall korrekt, die Anleitung nicht** — ein
> Regeltext-Abgleich hätte grün gemeldet.

> **Die Falle unter der Falle:** Die Liste, welche Regeln verteilt werden, existiert
> schnell dreimal — im Verteilskript, in der Prüfung, und faktisch im Ladefenster. Keine
> davon ist falsch gepflegt; es gibt sie nur dreimal. In einem beobachteten Fall
> erreichten zwei Regeln die anderen Werkzeuge **nie**, darunter ausgerechnet die, die
> das Umgehen der Ablage-Wahrheit verbot. **Leite die Liste aus dem Ladefenster ab,
> statt sie zu führen.**

---

## Entscheidung D — Wie ein Riegel gebaut wird

Riegel sind mächtig und deshalb gefährlich. Vier Eigenschaften, die einer haben muss:

1. **Er sagt, warum.** Ein abgewiesener Vorgang ohne Begründung führt dazu, dass es
   dreimal anders versucht wird. Die Meldung nennt die Regel und den erlaubten Weg.
2. **Er hat eine Tür.** Ein Riegel ohne bewusste Ausnahme wird umgangen, sobald er das
   erste Mal falsch greift. Besser eine ausdrückliche Markierung für „hier ist es
   gewollt" als ein abgeschalteter Riegel.
3. **Er greift eng.** Ein Riegel, der die Mehrheit der richtigen Fälle trifft, trainiert
   genau das Wegsehen, gegen das er gebaut wurde. Lieber ein paar echte Fälle verpassen
   als viele falsche melden.
4. **Er klingt nicht wie eine eingeschleuste Anweisung.** Ein Hinweistext, der befehlend
   auftritt oder sich selbst widerspricht, wird von einem Agenten zu Recht als
   Manipulationsversuch behandelt und verworfen. **Ein Wächter, dem niemand glaubt, ist
   schlechter als keiner.**

---

## Der teuerste Fehler in diesem Bereich

⚠️ **Zugehörigkeit wird an einer genauen Registrierung geprüft, nie an „liegt in der
Nähe".**

**Gelernt an:** Ein Mechanismus, der beim Sitzungsstart die zuständige Wissensfläche
laden sollte, prüfte die Zuständigkeit über eine **ungebundene Richtungsprüfung** — liegt
A unterhalb von B oder B unterhalb von A. An einem gemeinsamen übergeordneten Verzeichnis
ausgeführt, ist „irgendwo dazwischen" für **alles gleichzeitig** wahr. Der Mechanismus
hielt sich für zuständig für sämtliche Bereiche — **einschließlich eines als streng
vertraulich markierten** — und legte dessen Inhalte offen.

Genau der Mechanismus, der eine Vertraulichkeitsgrenze durchsetzen sollte, wurde zum Leck.
Lautlos, bis jemand gezielt danach suchte.

**Zwei Konsequenzen:**

1. **Zuständigkeit kommt aus einer Registrierung mit exakten Einträgen**, nicht aus einer
   Pfadbeziehung. Und jede Prüfung braucht eine Tiefenbegrenzung.
2. **Eine Trennung reinigt Nebenspeicher nicht rückwirkend.** Nach der Herauslösung eines
   vertraulichen Bereichs in eine eigene Struktur lud das **Sitzungsgedächtnis** des
   Herkunftsprojekts dessen Inhalte weiterhin automatisch mit. Der behobene Fehler lebte
   in einem zweiten Speicher unbemerkt weiter. Prüf Gedächtnis, Zwischenspeicher und
   Protokolle **einzeln** nach.

> **Und die allgemeine Lehre daraus:** „Wir haben das getestet" ist nur so stark wie die
> Grenzfälle, die sich der Bauende vorgestellt hat. Dieser Fehler wurde von einer
> **unabhängigen, gegnerisch angelegten Gegenprüfung** gefunden — der ursprüngliche
> Betriebstest lief nur durch normale Verzeichnisse.

---

## Zwei Riegel, die sich immer lohnen

**1 · Der Vollzugriff hängt am Arbeitsverzeichnis, nicht am Modus.**
„Darf alles unterhalb des Arbeitsverzeichnisses" bedeutet in einem engen Projektordner
etwas völlig anderes als im persönlichen Ordner. Derselbe Modus, dieselbe Erlaubnis,
tausendfacher Unterschied im Umfang. Bau einen Riegel, der **außerhalb der vorgesehenen
Orte nachfragt** — und ohne Antwort abbricht statt durchzulaufen.

**2 · Zugangsdaten werden am gemeinsamen Punkt geschützt, nicht je Werkzeug.**
Ein Riegel, der beim Festschreiben nach Geheimnissen sucht, gilt für **jeden** Akteur.
Dazu die billigste erste Schicht: Ausschlussregeln für die Dateien selbst.

> ⚠️ **Und die Ausschlussregel muss den ganzen Baum abdecken.** In einem beobachteten Fall
> deckte sie eine Zugangsdaten-Datei nur in einem Unterordner ab, nicht dieselbe Datei im
> Wurzelverzeichnis. Zwei Geheimnisse lagen ungeschützt im Baum, einen einzigen
> unachtsamen Befehl von der Veröffentlichung entfernt.

---

## Was in jedem Fall gilt

1. **Eine Regel, die der Agent nicht einhalten *kann*, ist keine Regel.** Ein Auftrag,
   der Schreiben verlangt, während der Modus Schreiben verbietet, endet ohne Fehler und
   ohne Wirkung. In einem beobachteten Fall liefen fünf Aufträge je viermal über fünf
   Tage, meldeten jedes Mal Erfolg — und hatten keine einzige Datei angefasst.
2. **Regeln, die sich widersprechen, sind schlimmer als eine fehlende Regel.** Leg fest,
   welche Ebene gewinnt, und schreib es in die oberste Regel.
3. **Jede Regel braucht einen Grund im Text.** Eine Regel ohne Begründung wird beim ersten
   Konflikt geopfert, weil niemand weiß, was verloren geht.
4. **Verbote sind schwächer als Vorschriften.** „Nicht X" lässt offen, was stattdessen
   gilt. „Tu Y" nicht.

---

## Woran man merkt, dass es bricht

| Zu messen | Bricht, wenn |
|---|---|
| Regelkopien gegen ihre Quelle, **inhaltlich** | Unterschied > 0 |
| Verknüpfungen, die ins Leere zeigen | > 0 |
| Umfang des Ladefensters in Wörtern | wächst über das Doppelte des Startwerts |
| Regeln im Ladefenster, die nie zutreffen | Schätzung genügt, einmal im Quartal |
| Riegel, die abgewiesen haben | Wird nie gezählt — sollte es aber. Ein Riegel, der in Monaten nie gegriffen hat, ist entweder überflüssig oder kaputt |

> **Die unbequeme Messung:** Ob die Regeln zum *Antwortverhalten* eingehalten werden,
> misst niemand, weil es Arbeit ist. Es lohnt trotzdem — eine Stichprobe über die letzten
> hundert Antworten sagt mehr über den Zustand des Fundaments als jede Dateiprüfung. In
> einem Fall zeigte genau diese Stichprobe, dass bei **47 % der Antworten mit Optionen
> die geforderte Empfehlung fehlte** — die Regel stand seit Wochen und galt faktisch nicht.

---

## Vorlage

### Die Dreiteilung, als Entscheidungstext für die eigene Regelfläche

Liegt in `vorlagen/regeln-grenzen.md`.

### Aufbau einer Regeldatei

```markdown
# <Name der Regel>

<Ein Satz: worum es geht.>

## Warum

<Der Auslöser. Was passiert ist oder passieren würde. Zwei bis vier Sätze.
Ohne diesen Abschnitt wird die Regel beim ersten Konflikt geopfert.>

## Was gilt

- <Vorschrift, nicht Verbot.>
- <So knapp wie möglich.>

## Ausnahmen

<Wann sie ausdrücklich nicht gilt. Wenn es keine gibt: "Keine." — aber prüf das,
Regeln ohne Ausnahmen sind selten.>
```

### Startempfehlung für das Ladefenster

Fünf Dateien reichen am Anfang:

1. **Arbeitsweise** — wie geantwortet wird, wie gearbeitet wird
2. **Wissenskonventionen** — das Ergebnis von Weiche 1
3. **Ablage-Wahrheit** — das Ergebnis von Weiche 3
4. **Übergabe** — das Ergebnis von Weiche 4
5. **Dateikonventionen** — Benennung, Versionen, Archiv

Alles Weitere auf Abruf.

---

## Die Lehren dahinter

- **Regel = Kontext, harte Grenze = Code.** Die wichtigste Unterscheidung überhaupt.
- **Eine Regel, die nicht einhaltbar ist, endet lautlos mit Erfolgsmeldung.**
- **Kopien driften, Verknüpfungen nicht.** Und gemessen wird der Inhalt, nicht das Datum.
- **Eine Liste, die es dreimal gibt, ist dreimal Gelegenheit, eine zu vergessen.**
- **Ein Wächter, dem niemand glaubt, ist schlechter als keiner.**
