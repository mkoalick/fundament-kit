# Der Durchlauf — ein Modul nach dem anderen

**An die KI:** Dieser Weg ist für jemanden, der **schon etwas hat** — ein Repo, ein paar
Notizen, vielleicht eine Anweisungsdatei. Nicht für den Neuaufbau auf leerer Fläche; dafür
gibt es `START-HIER.md`.

Der Unterschied ist wichtig: Hier wird **nichts entschieden, was schon entschieden ist.**
Du prüfst, was da ist, hältst es gegen das, was in diesem Kit steht, und schlägst genau die
Unterschiede vor, die sich lohnen.

---

## Die Grundhaltung

> **Was schon läuft und niemanden stört, bleibt.**

Ein Fundament ist kein Wettbewerb. Wer bereits eine funktionierende Lösung für ein Modul
hat, bekommt von dir keine zweite — höchstens einen Hinweis auf eine Falle, die seine
Lösung noch nicht kennt.

Der häufigste Fehler an dieser Stelle ist nicht, zu wenig vorzuschlagen. Es ist,
**Bestehendes durch Gleichwertiges zu ersetzen**, weil es hier anders steht.

---

## Der Ablauf je Modul — vier Schritte, immer dieselben

### Schritt 1 · Bestandsaufnahme — was ist schon da?

**Du schaust nach, du fragst nicht.** Jedes Modul nennt unter „Bestandsaufnahme" konkret,
wonach du suchst — Dateien, Ordner, Muster. Sieh selbst nach, bevor du redest.

Danach fasst du in **drei bis fünf Zeilen** zusammen, was du gefunden hast. In
Alltagssprache, ohne Wertung:

> „Du hast eine Anweisungsdatei im Projektstamm, 40 Zeilen, hauptsächlich Tonfall und
> Testbefehle. Notizen liegen in einem `docs/`-Ordner, 12 Dateien, keine mit einem
> Kopfbereich. Eine Übergabe zwischen Sitzungen gibt es nicht."

Ist nichts da, sag das genauso klar: „Zu diesem Modul gibt es bei dir bisher nichts." Das
ist kein Mangel, sondern der Ausgangspunkt.

### Schritt 2 · Was das Modul mitbringt

Jetzt liest du das Modul und nennst **nur die Erkenntnisse, die für seine Lage neu sind.**
Höchstens drei bis fünf, je zwei bis drei Sätze, jede mit dem Fehler, der sie gelehrt hat.

**Nicht das ganze Modul referieren.** Wer schon eine Übergabe hat, braucht nicht zu hören,
wozu Übergaben gut sind — er braucht den einen Punkt, den seine Lösung noch nicht abdeckt.

### Schritt 3 · Der Vorschlag — in drei Töpfen

Sortier alles, was das Modul hergibt, in genau drei Gruppen. **Alle drei nennen, auch die
leeren nicht als Überschrift, sondern gar nicht.**

| Topf | Was hineingehört |
|---|---|
| **Lohnt sich** | Konkrete Ergänzung. Mit einem Satz, was sie ihm bringt, und wie lange sie dauert |
| **Brauchst du nicht** | Was für seine Lage überdimensioniert ist — **mit Grund**. Das ist der wichtigste Topf: Er zeigt, dass du seine Lage verstanden hast, und verhindert, dass er es später doch einbaut |
| **Später, wenn X passiert** | Was erst ab einem konkreten Anlass sinnvoll wird. Nenn den Anlass, nicht den Zeitpunkt |

Dann **eine Empfehlung**, welcher Punkt aus „lohnt sich" zuerst dran ist — und warum
dieser.

### Schritt 4 · Zusammenführen

Erst nach seiner Zustimmung. Drei Regeln:

1. **Ergänzen statt ersetzen.** Wenn er eine Anweisungsdatei hat, kommt ein Abschnitt dazu
   — die Datei wird nicht neu geschrieben. Was er formuliert hat, bleibt in seinen Worten.
2. **Eine Sache pro Schritt, und dazwischen sichern.** Nicht das ganze Modul in einem Zug.
3. **Sag, was du geändert hast**, in einer Zeile je Datei. Er muss sein eigenes Fundament
   erklären können.

Danach: ein Eintrag in `PROFIL.md` — was übernommen wurde, was bewusst nicht, und der
Grund. **Besonders das Abgelehnte.** Ohne diese Zeile wird dieselbe Sache in sechs Monaten
erneut vorgeschlagen, diskutiert und erneut abgelehnt.

---

## Welches Modul zuerst?

Frag ihn, was ihn gerade stört. Wenn er nichts nennt, ist das hier die Reihenfolge — sie
folgt der Abhängigkeit, nicht der Wichtigkeit:

| # | Modul | Wofür | Erkennst du den Bedarf an |
|---|---|---|---|
| 1 | **Arbeitsweise** (`vorlagen/arbeitsweise.md`) | Wie die KI antwortet und arbeitet | Immer der beste Einstieg: wirkt sofort, kostet 20 Minuten, ändert jede weitere Antwort |
| 2 | **Übergabe** (`00-kern/04-uebergabe.md`) | Was eine Sitzung der nächsten hinterlässt | Er erklärt Dinge zweimal · es gibt keine Datei mit offenen Punkten |
| 3 | **Wissen** (`00-kern/01-wissen.md`) | Wo liegt, was länger gilt | Notizen ohne Struktur · dieselbe Erkenntnis steht an zwei Stellen |
| 4 | **Regeln und Grenzen** (`00-kern/02-regeln-und-grenzen.md`) | Bitte, Werkzeug oder Riegel | Eine Anweisungsdatei, die immer länger wird · etwas ist trotz Regel passiert |
| 5 | **Quelle der Wahrheit** (`00-kern/03-quelle-der-wahrheit.md`) | Wer hat recht bei Widerspruch | Dieselbe Sache wird an zwei Orten gepflegt |
| 6–15 | **Die Erweiterungen** (`10-erweiterungen/`) | Einzeln, auf Nachfrage | Siehe `10-erweiterungen/00-ueberblick.md` |

> **Ein Modul pro Sitzung.** Zwei gehen auch, drei nicht. Nach dem dritten erinnert sich
> niemand mehr, was beim ersten entschieden wurde — und dann steht ein Fundament da, das
> ihm nicht gehört.

---

## Was du nicht tun sollst

- **Nicht mehrere Module in einem Rutsch.** Auch wenn er es will. Sag, warum: Was in einer
  Sitzung entschieden wird, wird in derselben Sitzung wieder vergessen.
- **Nicht ersetzen, was funktioniert.** Auch wenn deine Variante eleganter wäre.
- **Nicht vollständig sein wollen.** Ein Modul, von dem drei Punkte ankommen, hat mehr
  bewirkt als eines, von dem zwölf vorgetragen wurden.
- **Nicht raten, was da ist.** Schritt 1 heißt nachsehen. Eine Bestandsaufnahme aus
  Vermutungen ist schlimmer als keine, weil sie alles Folgende falsch ausrichtet.
- **Keine Werkstattsprache.** Sag nicht „dein Ladefenster ist überfüllt", sondern „deine
  Anweisungsdatei ist so lang, dass die hinteren Teile faktisch nicht mehr wirken".

---

## Wenn er gar nichts hat

Dann ist der Durchlauf trotzdem richtig — Schritt 1 fällt nur kürzer aus. Der Unterschied
zu `START-HIER.md`: Dort werden vier Entscheidungen **zusammenhängend** getroffen, weil
sie einander bedingen. Hier wird Modul für Modul ergänzt.

**Faustregel:** Wer bei null anfängt und es ordentlich will → `START-HIER.md`. Wer schon
arbeitet und nicht alles umstellen will → dieser Weg.
