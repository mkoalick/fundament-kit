# Herkunft — und was daran nicht zu übernehmen ist

*Für die KI: Lies das, wenn jemand fragt „woher kommt das eigentlich" oder wenn du
unsicher bist, ob eine Empfehlung im Kit allgemein gilt oder nur dort galt, wo sie
entstanden ist.*

---

## Woraus das destilliert ist

Ein über zwei Jahre gewachsener Arbeitsplatz: mehrere streng getrennte Geschäftsbereiche,
dreizehn Ablagen, ein Wissensspeicher mit rund 1.700 Notizen, ein täglicher Spiegel in ein
Team-Wiki, unbeaufsichtigte nächtliche Läufe, mehrere Modelle und Programme nebeneinander.

Die Zahlen in `FALLSTRICKE.md` stammen aus dessen Protokollen und Messungen. Sie sind echt
und nicht gerundet worden, um besser zu klingen.

---

## Die neun Stellen, an denen dieses Kit eine Wahl trifft, die nicht deine sein muss

**Lies das als Warnliste.** Überall hier stand im Ursprungssystem eine Entscheidung, die
für **dessen** Lage richtig war. Wer sie übernimmt, ohne sie zu prüfen, übernimmt fremde
Verhältnisse.

### 1 · Drei Wissens-Ebenen

Das Ursprungssystem hat drei. Das ist die aufwendigste Stelle im ganzen Bau und lohnt sich
nur bei mehreren getrennten Bereichen mit je mehreren Projekten. **Bei einem Bereich reichen
zwei**, und die Verweisregel wird dann trivial. Siehe `00-kern/01-wissen.md`, Entscheidung A.

### 2 · Mehrere getrennte Geschäftsbereiche

Sechs davon, jeder mit eigener Ablage, eigener Wissensfläche, teils eigenem Konto.
Übertragbar ist die Idee — **eine harte Grenze zwischen unvereinbaren Zusammenhängen,
technisch durchgesetzt statt nur vorgenommen**. Die Anzahl ist frei, und für viele ist sie
eins.

### 3 · Ein Team-Wiki als Spiegel

Die halbe Ablage-Wahrheit-Weiche existiert nur, weil ein bestimmtes Team-Werkzeug als
Lesefläche gewählt wurde. **Wer kein Team hat, das mitliest, lässt die gesamte Spiegelebene
weg** — und verliert nichts Wichtiges. Dann entfallen auch Seitenregeln und
Vorlagenklassen.

### 4 · Ein bestimmtes Notizprogramm

Der Wissensspeicher liegt in einem Markdown-Programm mit Verweisen und Graphansicht.
**Jeder Ordner voller Textdateien mit Volltextsuche erfüllt dieselbe Funktion.** Die
Konventionen im Kit sind werkzeugneutral formuliert.

### 5 · Die Modell- und Motorlandschaft

Produktnamen, Preismodelle und Vergleichszahlen veralten binnen Monaten. Übertragbar ist
ausschließlich die **Entscheidungslogik** — Entdeckbarkeit eines Fehlers als Achse, Modell
je Phase ausdrücklich setzen. Nicht die Rangliste.

### 6 · Die Antwortform

Der Aufbau in `vorlagen/arbeitsweise.md` ist auf Deutsch und auf einen sehr direkten
Umgangston zugeschnitten. **Das Prinzip ist sprachunabhängig** — Ergebnis vor Weg, eine
Empfehlung vor den Optionen, Fertiges und Offenes getrennt. Wortlaut, Symbole und Tonfall
gehören angepasst, sonst wird die Regel nicht eingehalten, weil sie jemand anderem gehört.

### 7 · Das Namensschema für Dateien

Deutsches Kurzdatum, deutsche Versionskürzel. **Jedes einheitliche Schema erfüllt denselben
Zweck.** Die Notwendigkeit einer Konvention ist universell, ihre Form nicht.

### 8 · Betriebswissen zu bestimmten Anbietern

Einzelne Lehren stammen aus der Arbeit mit bestimmten Hosting-, Speicher- und
Cloud-Diensten. Die Prinzipien dahinter gelten anbieterübergreifend — die genannten
Befehle und Fehlerbilder nicht.

### 9 · Die Betriebssystem-Bindung

Fokus-Riegel, Zeitsteuerung, Wachhalten und das Einhängen der gemeinsamen Ebene sind an ein
bestimmtes System gebunden. **Die Prinzipien sind plattformneutral, die Umsetzung ist es
nicht.**

Betroffen sind genau vier Mechanismen, und für jeden steht das Gegenstück in
`WINDOWS-UND-MAC.md`. Der Rest des Kits läuft überall unverändert.

---

## Was ausdrücklich **nicht** ins Fundament gehört

Das Ursprungssystem hat eine übergeordnete Steuerungsebene: eine Stelle, die alle Projekte
erhebt, Aufgaben ins richtige Projekt leitet und nachts unbeaufsichtigt abarbeitet.

**Das ist mächtig und für den Einstieg falsch.** Es setzt die Wissens-Ebenen und die
Bereichstrennung bereits voraus und ergibt nur Sinn, wenn jemand mehrere Projekte parallel
mit Agenten betreibt. Im Kit steht es deshalb als Erweiterung 2 bis 4 — nicht im Kern.

Wer damit anfängt, baut das Dach vor dem Fundament.

---

## Was nicht drin ist

Keine Geschäfts-, Kunden- oder Personendaten. Keine Zugangsdaten. Keine Namen von Firmen,
Kunden oder Beteiligten. Wo eine Lehre ohne solchen Zusammenhang nicht verständlich
gewesen wäre, steht sie nicht hier.
