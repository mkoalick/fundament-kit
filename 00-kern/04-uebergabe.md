# Weiche 4 · Die Übergabe zwischen Sitzungen

> **Die Frage:** Was hinterlässt eine Sitzung der nächsten — und wer darf es
> aufschreiben?

---

## Worum es geht

Eine Sitzung mit einer KI endet, und mit ihr endet alles, was sie wusste. Die nächste
fängt bei null an: Sie kennt den Stand nicht, weiß nicht, was versucht und verworfen
wurde, und beginnt oft damit, etwas ein zweites Mal zu tun.

Das lässt sich nicht verhindern, nur überbrücken. Und die **Bauweise** dieser Brücke ist
die eigentliche Entscheidung — nicht, ob es eine gibt.

**Warum sie zum Kern gehört, obwohl sie harmlos aussieht:** Sobald zwei Sitzungen
gleichzeitig laufen — zwei Fenster, ein Mensch und ein Hintergrundlauf, zwei verschiedene
Werkzeuge —, schreiben zwei Schreiber in dieselbe Datei. Dafür gibt es in einem
Arbeitsverzeichnis **keine Zusammenführung**: Die Versionsverwaltung greift erst beim
Festschreiben, davor gewinnt schlicht der Letzte. Wer das erst merkt, wenn es passiert
ist, hat schon Arbeit verloren.

---

## Bestandsaufnahme — wenn schon etwas da ist

*Nur für den Durchlauf aus `INTEGRIEREN.md`. Beim Neuaufbau überspringen.*

**Sieh nach, bevor du redest:**

| Wonach | Wo typischerweise | Was der Fund bedeutet |
|---|---|---|
| Eine Übergabe- oder Statusdatei | `HANDOVER.md`, `STATUS.md`, `NOTES.md`, ein `TODO.md` im Stamm | Vorhanden → prüf nach Entscheidung B, ob Zustand und Chronik vermischt sind. Fehlt sie → das ist der Ausgangspunkt |
| Eine Eingangskorb-Struktur | `inbox/`, `handover/inbox/`, mehrere datierte Dateien | Vorhanden → Bauweise aus Entscheidung A ist schon gewählt. Prüf, ob wirklich nur ein Zusammenfasser sie anfasst |
| Versionsverwaltung | ein `.git`-Ordner, Commit-Historie | Vorhanden → das Festschreiben ist der natürliche Punkt, um Zwischenstände zu sichern. Fehlt sie → die Übergabedatei trägt die ganze Last allein |
| Mehrere parallele Sitzungen oder Werkzeuge | mehrere offene Fenster, mehrere Agenten-Konfigurationen, Hintergrundläufe | Möglich oder üblich → Entscheidung A fällt fast von selbst auf den Eingangskorb |
| Länge und Alter der offenen Punkte | Zeilen unter „Offen"/„TODO", Datum der ältesten Zeile | Sehr lang oder undatiert → Verdacht auf „Anhängen heißt unbegrenzt" aus Entscheidung C |
| Spuren einer mitten in der Arbeit abgebrochenen Sitzung | uncommittete Änderungen, halbfertige Dateien im Baum | Vorhanden → das ist fremde unfertige Arbeit. Nicht anfassen, siehe „Was in jedem Fall gilt" |

**Drei Ausgangslagen, die fast alles abdecken:**

- **Keine Übergabedatei, nur die Chat-Historie selbst.** Lohnendster erster Schritt: eine
  einzige Datei mit „Offen" und „Chronik" — solange wirklich nur eine Sitzung gleichzeitig
  läuft.
- **Eine gewachsene Datei, die alles vermischt.** Offene Punkte neben Erledigtem, nie
  sortiert. Lohnendster erster Schritt: Zustand von Chronik trennen und die offenen Punkte
  einmal nach Alter sortieren, bevor etwas Neues dazukommt.
- **Mehrere Werkzeuge oder Sitzungen schreiben schon parallel.** Lohnendster erster
  Schritt: sofort auf den Eingangskorb umstellen — genau dieser Fall ist der, den eine
  einzelne Datei nicht übersteht.

> **Der häufigste Fehlgriff an dieser Stelle:** Einen automatischen Zusammenfasser bauen,
> obwohl noch nie zwei Sitzungen gleichzeitig liefen — ein Mechanismus für einen Fall, den
> es noch nicht gibt.

---

## Entscheidung A — Die Bauweise

### Alle schreiben in eine Datei

**Bringt:** Denkbar einfach. Eine Datei, jeder hängt unten an.
**Kostet:** Bei gleichzeitigem Schreiben verliert einer alles. Lautlos.
**Wann:** Nur, wenn wirklich nie zwei Sitzungen gleichzeitig laufen — und das lässt sich
schwerer garantieren, als es klingt.

### Eingangskorb, ein Zusammenfasser

**Bringt:** Jede Sitzung schreibt eine **neue** Datei in einen Eingangsordner. Zwei
gleichzeitige Sitzungen schreiben zwei verschiedene Dateien und stören sich nicht. Ein
Programm faltet sie in die gemeinsame Übersicht — und ist der **einzige**, der die
anfasst.
**Kostet:** Ein Zwischenschritt, der laufen muss. Und die Dateinamen müssen eindeutig
sein, sonst hat man das Problem eine Ebene tiefer.
**Wann:** Sobald mehr als eine Sitzung denkbar ist. Das ist früher, als man denkt.

> **Empfehlung — und sie hängt an einer einzigen Frage:** *Kann es vorkommen, dass zwei
> Sitzungen gleichzeitig laufen?* Zwei Fenster, ein Hintergrundlauf neben der Arbeit, ein
> zweiter Mensch, ein zweites Werkzeug.
>
> **Nein, und es ist auch nichts geplant** → eine Datei. Bau keinen Mechanismus für einen
> Fall, den es nicht gibt; das ist genau der Fehler, vor dem die Erweiterungen warnen.
> Schreib aber **in die Übergabe-Konvention hinein**, ab wann umgestellt wird — sonst
> merkt es niemand, wenn der Fall eintritt.
>
> **Ja, oder schon absehbar** → Eingangskorb, von Anfang an. Dann kostet er eine
> Viertelstunde. Später kostet er zusätzlich alle Gewohnheiten, die sich um die eine Datei
> gebildet haben.

> ⚠️ **Der Zusammenfasser ist selbst die gefährlichste Stelle.** Beim Ausrollen eines
> solchen Mechanismus auf sieben Umgebungen erzeugte er **drei eigene Datenverluste**:
> eine fremde Abschnittsstruktur wurde verworfen statt übernommen, Fließtext hinter einer
> Tabelle ging verloren, Platzhalterzeilen wurden fälschlich als Dubletten zusammengefasst.
> Ursache war jedes Mal dieselbe stille Annahme: *„Alle Zieldateien sehen aus wie die, an
> der ich entwickelt habe."*
>
> **Also:** Der Zusammenfasser braucht einen Riegel, der abbricht, wenn die Datei nach dem
> Lauf wesentlich kürzer wäre als vorher. Und dieser Riegel darf Überschriften und
> Erklärtexte **nicht als Substanz zählen** — in einer kleinen Datei sind sie sonst der
> größte Teil, und dann blockiert er den richtigen Lauf.

---

## Entscheidung B — Was drinsteht

Zwei Dinge, die **nicht** vermischt werden dürfen:

| | Was | Altert |
|---|---|---|
| **Zustand** | Was ist offen, wer wartet worauf, was läuft gerade | Nein — er ist die Gegenwart |
| **Chronik** | Was wurde wann getan | Sofort — sie ist nur für Rückfragen da |

**Und Zustand wird ersetzt, nicht ergänzt.** „Was gerade läuft" ist keine Chronik — wer
dort anhängt, sammelt nach kurzer Zeit nur noch längst beendete Vorgänge, und dann weiß
niemand mehr, welcher Hinweis noch gilt.

**Bezeichner müssen eindeutig sein.** Ein Übergabepunkt verwies auf eine Datei mit einem
Namen, den es in mehreren Projekten gibt. Die lesende Sitzung suchte im falschen Projekt,
fand nichts und hielt den Inhalt für nicht existent — samt mehrerer daran hängender
Punkte.

Der Zustand steht **oben** und wird gelesen. Die Chronik steht **unten** und wird
gelegentlich durchsucht. Wer beides mischt, bekommt eine Datei, in der man scrollen muss,
um zu erfahren, was zu tun ist — und dann liest sie niemand mehr.

**Die Chronik rotiert** in ein Archiv, sobald sie eine Handvoll Wochen alt ist. Der
Zustand rotiert nicht.

---

## Entscheidung C — Was mit dem Offenen passiert

**Hier ist der teuerste stille Fehler dieses ganzen Bereichs.**

Offene Punkte werden angehängt. Gestrichen werden sie nur von dem, der die Sache erledigt
— und tut er es nicht, steht der Punkt für immer da. „Anhängen" heißt dann in der Praxis
„unbegrenzt".

**Gelernt an:** Über dreizehn Arbeitsbereiche gezählt wuchs die Liste offener Punkte von
**923 auf 2.542 in dreißig Tagen** — monoton, kein einziger Bereich schrumpfte. Die Liste
war damit faktisch unlesbar. Und ein unlesbarer Rückstand versteckt seine dringenden
Zeilen genauso gut wie ein gelöschter.

**Die Lösung ist nicht Löschen, sondern Sortieren:** Was älter ist als eine feste Frist,
wandert in einen Abschnitt „Altbestand" **derselben Datei**. Nichts geht verloren, der Weg
zurück nach oben ist ein Handgriff — aber oben steht nur, was aktuell ist.

> **Der Merksatz dazu, der weit über die Übergabe hinaus gilt:**
> **Ein Deckel darf die Liste kürzen, nie den Zähler.**
>
> In demselben Fall kürzte eine Anzeige die Liste auf fünfzehn Zeilen, und die
> Statusmeldung nannte diese fünfzehn als „offene Punkte". Acht von dreizehn Bereichen
> rissen den Deckel — also stand bei jedem davon exakt „15 offen". Die eine Zahl, die
> beziffern sollte, wie viel auf jemandem liegt, war ein Anzeigeparameter. Real waren es
> **2.588**.

---

## Entscheidung D — Was beim Abschluss geprüft wird

Eine Sitzung, die endet, ist der einzige Moment, in dem noch jemand weiß, was gerade
passiert ist. Nutz ihn für zwei Fragen — und stell sie **automatisch**, nicht als Vorsatz:

1. **Gehört zu dem, was geändert wurde, eine Dokumentation, die nicht mitgezogen wurde?**
2. **Ist dabei etwas gelernt worden, das länger gilt als dieser Auftrag?** Wenn ja: Gibt
   es dazu schon eine Notiz?

**Bau das auf den Unterschied zum letzten Stand, nicht auf Ereignisse während der
Arbeit.** Ein Mechanismus, der beim Schreiben einer Datei auslöst, sieht nur die eigene
Arbeit — die Arbeit anderer Werkzeuge und anderer Menschen sieht er nie. Der Unterschied
zum letzten festgeschriebenen Stand sieht alles.

Die Prüfung entscheidet dabei **nichts inhaltlich**. „Ist das neues Verhalten oder ein
Fehlerfix?" und „ist das dasselbe Thema wie die bestehende Notiz?" bleiben beim Menschen
oder beim Modell. Der Mechanismus liefert nur die Liste.

---

## Entscheidung E — Was die nächste Sitzung davon sieht

Eine perfekte Übergabe, die niemand öffnet, ist keine. **Leg den Zustand in den
Startkontext** — nicht die ganze Datei, nur den offenen Teil.

Das ist dieselbe Lehre wie bei Weiche 1, Entscheidung E, und sie gilt hier genauso:
*Die Ablage war nie kaputt, der Abruf hatte keinen Mechanismus.*

---

## Was in jedem Fall gilt

### Fremde unfertige Arbeit ist tabu

Wer parallel arbeitet, findet Änderungen im Arbeitsverzeichnis, die nicht von ihm sind.
Das sind **keine Überreste**, sondern jemandes unfertige Arbeit.

- Nicht zurücksetzen, nicht wegräumen, nicht beiseitelegen.
- Nie pauschal alles zum Festschreiben vormerken — nur die selbst geänderten Wege.
- Wer genau eine dieser Dateien braucht: fragen, nicht übernehmen.

Und: Der Blick auf den Stand des Arbeitsverzeichnisses gehört **vor den ersten Eingriff**,
nicht vor die Abschlussmeldung. Am Ende ist er Dokumentation, am Anfang Vorbeugung.

### Was unerledigt ist, gehört in die Liste — nie nur in die Chronik

**Gelernt an:** Ein fertig ausformulierter, mit Quellen belegter Text samt Ablageanweisung
stand nur in einem Chronik-Eintrag und auf keiner Liste offener Punkte. Die routinemäßige
Rotation schob ihn ins Archiv — dorthin, wo ihn niemand mehr gezielt sucht. Aufwendige,
fertige Arbeit, spurlos verschwunden durch einen Mechanismus, der nur harmlosen Verlauf
wegräumen sollte.

**Die Chronik rotiert. Was rotieren darf, darf nichts Unerledigtes enthalten.**

### Nur die eigenen Pfade sichern — und die Nebenwirkung kennen

Die Regel „nur den selbst geänderten Pfad vormerken" schützt den geteilten Arbeitsbaum. Sie
hat aber eine scharfe Kehrseite: **Neu angelegte, noch nicht erfasste Dateien werden dabei
ausgelassen**, und ein bereits entferntes Objekt kann ungewollt zurückkehren. Dieselbe
Falle traf an einem Tag zwei unabhängige Sitzungen in verschiedenen Projekten.

Prüf nach dem Sichern, ob wirklich drin ist, was drin sein sollte.

### Zwischenstände festschreiben, und zwar früh

Eine Sitzung kann jederzeit enden — Zeitlimit, Kontingent, Absturz, ein geschlossenes
Fenster. Was nicht festgeschrieben ist, ist dann weg, und schlimmer: Es liegt als
halbfertige Änderung im Verzeichnis und sieht für die nächste Sitzung wie fremde Arbeit
aus, die sie nicht anfassen darf.

**Die unbequeme Reihenfolge:** Erst festschreiben, dann prüfen — nicht bauen, prüfen,
aufräumen, festschreiben. Die saubere Reihenfolge verliert bei einem Abbruch alles, weil
der Abbruch statistisch in die lange Prüfphase fällt und nicht in den kurzen letzten
Schritt. **Ein vorschnell festgeschriebener Stand ist nachbesserbar, verlorene Arbeit
nicht.**

### Ein Übergabedokument altert schneller, als man glaubt

Was es über den Zustand behauptet, kann binnen Stunden falsch sein. Wer auf seiner
Grundlage etwas Eingreifendes tut, misst vorher neu.

---

## Woran man merkt, dass es bricht

| Zu messen | Bricht, wenn |
|---|---|
| Sitzungen ohne hinterlassenen Stand | > 0 |
| Offene Punkte gesamt — **echt gezählt**, nicht die angezeigte Länge | wächst über Wochen monoton |
| Anteil offener Punkte älter als die Frist | über die Hälfte |
| Dateien im Eingangskorb, die nicht eingefaltet wurden | > 0 |
| Dokumentation zu geänderten Stellen, nicht mitgezogen | > 0 |

---

## Vorlage

### Aufbau der Übersicht

```markdown
# Übergabe — <Bereich>

## Offen

| Was | Wo | Anmerkung | Sitzung |
|---|---|---|---|
| | | | |

### Altbestand — N Punkte, älter als <frist> Tage
<Nichts gelöscht, nur einsortiert. Wer einen Punkt wieder oben haben will,
schiebt seine Zeile hoch.>

| Was | Wo | Anmerkung | Sitzung |
|---|---|---|---|
| | | | |

## Läuft gerade

| Was | Wer/Wo | Seit |
|---|---|---|

---

## Chronik

### <Datum> · <Sitzungskürzel>
<Was getan wurde. Drei bis zehn Zeilen. Rotiert nach <frist> ins Archiv.>
```

### Was eine Sitzung in den Eingangskorb legt

```markdown
---
sitzung: <JJMMTT-HHMM>
werkzeug: <welcher agent/welches programm>
---

## Getan
- <ein Halbsatz je Punkt>

## Offen
| Was | Wo | Anmerkung |
|---|---|---|

## Gelernt
<Nur, wenn es länger gilt als dieser Auftrag. Sonst weglassen —
ein Pflichtfeld hier erzeugt Füllsätze.>
```

---

## Die Lehren dahinter

- **Im Arbeitsverzeichnis gibt es keine Zusammenführung.** Ein Eingangskorb löst das,
  eine gemeinsame Datei nicht.
- **Ein Deckel darf die Liste kürzen, nie den Zähler.**
- **Anhängen heißt unbegrenzt**, wenn niemand streicht. Sortieren statt löschen.
- **Erst festschreiben, dann prüfen.**
- **Fremde unfertige Arbeit im Verzeichnis ist tabu** — und der Blick darauf gehört an
  den Anfang, nicht ans Ende.
