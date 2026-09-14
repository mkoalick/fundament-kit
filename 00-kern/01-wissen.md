# Weiche 1 · Wissen

> **Die Frage:** Wo liegt, was länger gilt als ein Auftrag — und in wie vielen Ebenen?

---

## Worum es geht

Ein Arbeitsplatz, an dem KI mitarbeitet, erzeugt ständig Erkenntnisse: wie etwas
funktioniert, warum etwas so und nicht anders entschieden wurde, was beim letzten Mal
schiefging. Ohne einen Ort dafür verschwindet das mit der Sitzung. Mit dem falschen Ort
dafür verschwindet es auch — nur langsamer.

Hier wird entschieden, **wie viele Ebenen** es gibt, **was auf welche** gehört, **in
welche Richtung** verwiesen werden darf und **was jede Notiz mitbringen muss**.

---

## Bestandsaufnahme — wenn schon etwas da ist

*Nur für den Durchlauf aus `INTEGRIEREN.md`. Beim Neuaufbau überspringen.*

**Sieh nach, bevor du redest:**

| Wonach | Wo typischerweise | Was der Fund bedeutet |
|---|---|---|
| Notizdateien | `docs/`, `notes/`, `wiki/`, `knowledge/`, lose `.md` im Stamm | Es gibt schon einen Speicher — die Frage ist nur, ob er strukturiert ist |
| Kopfangaben in diesen Dateien | die ersten Zeilen einiger Notizen | Vorhanden → Entscheidung D ist teilweise getroffen. Fehlen → das ist der günstigste Hebel |
| Ein Verzeichnis oder eine Übersichtsdatei | `README`, `_index`, `INDEX`, `MOC` | Fehlt es, ist der Bestand für Mensch und KI unsichtbar |
| Verweise zwischen Notizen | `[[…]]`, relative Links | Gibt es sie, gilt Entscheidung C schon jetzt — auch wenn niemand sie aufgeschrieben hat |
| Ob beim Sitzungsstart etwas geladen wird | die Anweisungsdatei im Stamm, Startmechanismen | Das ist Entscheidung E. Sie fehlt fast immer |
| Ob Wissen und Dokumentation im selben Ordner liegen | siehe oben | Vermischt → das ist meist der erste lohnende Schritt |

**Drei Ausgangslagen, die fast alles abdecken:**

- **Lose Dateien ohne Struktur** (am häufigsten). Der lohnendste erste Schritt ist nicht
  die Ebenenfrage, sondern **ein Verzeichnis und ein Kopfbereich**. Die Ebenen kommen,
  wenn das zweite Projekt dazukommt.
- **Alles in einer großen Anweisungsdatei.** Dann ist die eigentliche Frage nicht „wie
  viele Ebenen", sondern **was davon Wissen ist und was Regel** — siehe Test 1 unten. Das
  ist eine halbe Stunde und wirkt sofort, weil die Datei danach kürzer ist.
- **Ein gewachsener Notizordner mit Struktur.** Dann geht es nur noch um Entscheidung C
  (Verweisrichtung) und E (Zustellung). Fass die vorhandene Struktur nicht an.

> **Der häufigste Fehlgriff an dieser Stelle:** Jemandem eine Ebenenstruktur vorschlagen,
> der zwölf Notizen hat. Zwölf Notizen brauchen ein Verzeichnis, keine Architektur.

---

## Entscheidung A — Wie viele Ebenen

**Zähl die Bereiche, die sich nichts teilen dürfen.** Nicht die Projekte. Bereiche:
getrennte Geschäfte, getrennte Kunden, Berufliches und Privates. Diese Zahl bestimmt die
Antwort fast allein.

### Eine Ebene — alles in einem Speicher

**Bringt:** Nichts einzuordnen, nichts zu verschieben, keine Frage „wohin damit". Für
einen einzelnen Bereich über Monate völlig ausreichend.
**Kostet:** Sobald ein zweiter Bereich dazukommt, ist die Trennung nachträglich zu
ziehen — und das heißt, jede Notiz einzeln zu beurteilen.
**Wann:** Ein Bereich, **ein bis zwei** Projekte, kein zweiter in Sicht — und nichts, was
schon heute in beiden gilt.

### Zwei Ebenen — allgemein + projektbezogen

**Bringt:** Was überall gilt (Arbeitsweise, Konventionen, Handwerk), liegt einmal und
wirkt überall. Was nur ein Projekt angeht, liegt bei ihm.
**Kostet:** Bei jeder neuen Notiz eine Frage: gilt das nur hier? Das ist wenig, aber es
ist jedes Mal.
**Wann:** Der Normalfall, **ab dem dritten Projekt** oder sobald etwas in zweien davon
gilt. Auch bei mehreren Bereichen, solange die noch klein sind.

> **Der Grenzfall, der in der Praxis am häufigsten auftritt:** ein Bereich, zwei bis drei
> Projekte. Beide Antworten sind vertretbar. Entscheidend ist nicht die Projektzahl,
> sondern eine einzige Frage: **Gibt es heute schon etwas, das in mehr als einem Projekt
> gilt?** Ja → zwei Ebenen. Nein → eine, und die zweite kommt, wenn das erste Mal etwas
> doppelt aufgeschrieben wird.

### Drei Ebenen — allgemein + Bereich + Projekt

**Bringt:** Bereiche können eigenes Wissen haben, ohne dass es in die allgemeine Ebene
sickert. Die mittlere Ebene ist der Ort für alles, was „in diesem Geschäft gilt" —
Kundenkonventionen, Marktwissen, hauseigene Abläufe.
**Kostet:** Deutlich mehr Einordnungsarbeit, und eine neue Fehlerquelle: Wissen landet
auf der mittleren Ebene, das eigentlich allgemein ist, und ist dann für die anderen
Bereiche unsichtbar. Das passiert **häufig** und fällt nicht auf.
**Wann:** Erst, wenn mindestens zwei Bereiche je mehrere Projekte haben und beide
genug eigenes Wissen tragen, dass die mittlere Ebene sich füllt. Vorher ist sie eine
leere Ebene, die trotzdem jede Einordnung verkompliziert.

> **Empfehlungslogik für dich:** Im Zweifel **zwei**. Eine dritte Ebene lässt sich
> später einziehen, indem man die allgemeine aufteilt — das ist Arbeit, aber
> überschaubare. Eine Ebene zu viel dagegen wird nie wieder entfernt, weil das Entfernen
> genauso viel Arbeit ist und niemand den Gewinn sieht.

**Später ändern kostet:** Eine mittlere Ebene nachträglich einzuziehen heißt, den
**gesamten Bestand auf seinen tatsächlichen Geltungsbereich zu prüfen** — nicht auf die
Selbstauskunft, sondern auf den Inhalt —, Namenskollisionen aufzulösen und jeden Verweis
neu auszurichten. Belegt als mehrtägige Sanierung mit hunderten betroffenen Verweisen.

---

## Entscheidung B — Was gehört auf welche Ebene

Zwei Tests, in dieser Reihenfolge. **Der erste wird fast immer übersprungen und ist der
wichtigere.**

### Test 1 — Ist das überhaupt Wissen?

Bevor gefragt wird „welche Ebene", muss geklärt sein „welche Art". Vier Dinge werden
regelmäßig verwechselt:

| Art | Erkennungsmerkmal | Gehört |
|---|---|---|
| **Wissen** | Gilt über den Anlass hinaus, jemand liest es später nach | in den Wissensspeicher |
| **Dokumentation** | Beschreibt, wie etwas Gebautes funktioniert | neben das Gebaute |
| **Aufgabe** | Hat einen Zustand: offen, erledigt | in den Rückstand |
| **Regel** | Soll Verhalten ändern, nicht informieren | in die Regelfläche (Weiche 2) |

Der Trenntest zwischen Wissen und Dokumentation: **Lösch das Gebaute — ist der Text noch
wahr?** Ja → Wissen. Nein → Dokumentation, und sie gehört zum Gebauten, nicht in den
Speicher.

### Test 2 — Auf welche Ebene

Eine Frage: **Wäre das noch wahr, wenn der Bereich ein anderer wäre?**

- Ja → höchste Ebene.
- Nein, aber es gilt in allen Projekten dieses Bereichs → mittlere Ebene.
- Nein, es gilt nur hier → Projektebene.

**Die Falle dabei:** Ein Beispiel aus einem Bereich macht einen Text nicht
bereichsgebunden. Ein eigener *Abschnitt* über einen Bereich schon. Die Trennlinie ist
brauchbar als Faustregel: ein Satz mit Beispiel darf oben stehen, eine Überschrift mit
Firmennamen nicht.

> **Und die Selbstauskunft einer Notiz ist nicht ihr Inhalt.** Ein Abgleich „was steht im
> Kopf gegen wo liegt sie" meldete durchgehend sauber, während knapp **vierzig Dateien der
> allgemeinen Ebene inhaltlich vollständig an einer einzigen Geschäftseinheit hingen**. Der
> tragfähige Trennwert war am Ende ein **struktureller** — ein eigener Abschnitt mit eigenem
> Ergebnis ist eine Analyse und gehört tiefer —, kein inhaltlich-subjektiver.

---

## Entscheidung C — Verweisrichtung

**Das ist keine Wahl. Verweise zeigen nur nach oben.**

Projekt darf auf Bereich verweisen, Bereich auf allgemein. Niemals umgekehrt, niemals
quer zwischen zwei Bereichen.

**Warum so hart:** Sobald die allgemeine Ebene ihre Nutzer kennt, ist sie nicht mehr
allgemein. Sie lässt sich dann nicht mehr an einen anderen Bereich ausleihen, nicht mehr
weitergeben und nicht mehr aufteilen. Und praktisch: Ein Verweis auf etwas, das in einem
anderen Bereich liegt, löst sich nicht auf, sobald jemand nur diesen Bereich geöffnet
hat — er zeigt ins Leere.

**Gelernt an:** Eine Fassung der Konventionen erlaubte bereichsübergreifende Verweise.
Die Korrektur beseitigte an einem Tag **741 tote Verweise**. Sie waren monatelang da und
niemandem aufgefallen, weil ein toter Verweis nichts kaputtmacht — er tut einfach nichts.

**Eine Ausnahme, die man kennen muss:** Texte, die *über* etwas schreiben — eine Analyse,
eine Untersuchung, ein Rückblick — müssen ihren Gegenstand benennen dürfen, auch nach
unten. Sonst analysieren sie nichts. Nimm diese Textarten von der Regel aus, aber zähl
sie getrennt mit, denn der Verweis löst trotzdem nicht auf. **Denk sie von Anfang an mit** —
nachträglich muss man sonst echte Verstöße von technischen Fehlmeldungen des eigenen
Prüfwerkzeugs trennen, und das ist mühsamer als die Regel selbst.

**Später ändern kostet:** Ein Durchgang über jeden bestehenden Verweis. Die Korrektur in
einem beobachteten Fall senkte die toten Verweise **von über 1.400 auf rund 750** — in
einem einzigen Lauf.

---

## Entscheidung D — Was jede Notiz mitbringen muss

Jede Notiz bekommt einen Kopf mit festen Angaben. Halte ihn **kurz** — jedes Pflichtfeld
wird bei jeder Notiz ausgefüllt, und was lästig ist, wird schlampig ausgefüllt oder
erzwingt ein Werkzeug.

**Das Minimum, das sich bewährt hat:**

| Feld | Wofür | Ohne das passiert |
|---|---|---|
| `titel` | Anzeige, Auffindbarkeit | Die Datei heißt wie ihr Dateiname und ist nicht durchsuchbar |
| `art` | Welche der vier Arten oben | Kein Werkzeug kann sie einsortieren |
| `ebene` | Selbstauskunft, wohin sie gehört | Eine falsch abgelegte Notiz ist nicht auffindbar |
| `stand` | Entwurf, gültig, überholt | Überholtes wird gelesen, als gälte es |
| `aktualisiert` | Datum | Nichts verfällt sichtbar |

**Später ändern kostet:** Ein Pflichtfeld nachträglich einzuführen heißt, den gesamten
Bestand nachzutragen — in einem beobachteten Fall **rund 300 Notizen in einem Zug**. Und
wenn das Vokabular nicht vorher feststeht, entstehen für denselben Begriff mehrere
Schreibweisen, die ein zweiter Durchgang vereinheitlichen muss. **Umgekehrt gilt:** Ein
optionales Feld, das keine Prüfung verlangt, wird nicht ausgefüllt — gemessene Adoption
eines solchen Feldes: **4 %**.

**Zwei optionale, die mehr bringen als sie kosten:**

- `herkunft` — woher stammt das? Selbst erarbeitet, aus einer Quelle, von einer KI
  erschlossen? Eine von einer KI erschlossene Behauptung, die später wie eine gemessene
  Tatsache gelesen wird, ist eine der teuersten Fehlerquellen überhaupt.
- `prüfen_nach_tagen` — wie lange gilt das vermutlich? Ohne Verfallsdatum altert ein
  Speicher still, und still alterndes Wissen ist schlimmer als fehlendes.

---

## Entscheidung E — Wie das Wissen zurückkommt

**Das ist die Entscheidung, die am häufigsten vergessen wird, und sie entwertet alle
anderen.**

Ein Speicher, aus dem niemand von allein etwas liest, existiert für die tägliche Arbeit
nicht. Es genügt nicht, dass ein Agent theoretisch nachsehen *könnte* — er tut es nicht,
weil er nicht weiß, dass es etwas zu finden gibt.

**Gelernt an, und die Zahlen sind eindeutig:** Über rund tausend Sitzungen gemessen kamen
**automatisch zugestellte Regeln auf etwa 1.400 Erwähnungen**, die meistgenutzte frei zu
suchende Wissensnotiz auf **406** — und **85 % aller Notizen wurden nie gelesen**. Die
Diagnose: *Die Ablage war nie kaputt, der Abruf hatte keinen Mechanismus.*

**Die Wahl:**

| Weg | Bringt | Kostet |
|---|---|---|
| **Inhaltsverzeichnis beim Start** | Der Agent sieht beim Sitzungsbeginn, welche Kategorien es gibt und was ungefähr drinsteht. Er schlägt dann gezielt nach. | Ein paar hundert Wörter Startkontext, jede Sitzung |
| **Auf Zuruf** | Kostet nichts | Wird nicht genutzt. Keine Theorie — beobachtet |
| **Alles in den Startkontext** | Nichts wird übersehen | Nach wenigen Dutzend Notizen unbezahlbar |

**Empfehlung:** Das Inhaltsverzeichnis. Kategorien und ein Satz je Kategorie, kein
Volltext. Wenn der Speicher noch klein ist, ist das eine Datei von zwanzig Zeilen — und
genau dann gewöhnt man es sich an.

> **Die zweite Hälfte davon:** Ein Inhaltsverzeichnis, das von Hand gepflegt wird, ist
> nach vier Wochen falsch. Entweder es wird erzeugt, oder es wird gemessen — siehe unten.
> Und **ein frisches Änderungsdatum beweist keine Vollständigkeit**: Ein Verzeichnis galt
> als aktuell, weil es kürzlich bearbeitet worden war, und fehlte trotzdem gut ein Zehntel
> seines eigenen Bestands. Miss die Verweise, nicht das Datum — spätestens wenn beim Start
> nur noch das Verzeichnis geladen wird, heißt „fehlt im Verzeichnis" gleich „existiert
> nicht".

### Zwei Arten von Wissen, zwei Zustellwege

Die Unterscheidung lohnt sich früh:

| Art | Erkennungsmerkmal | Gehört |
|---|---|---|
| **Falle** | Fällt erst auf, wenn der Schaden da ist | in den **zugestellten** Speicher — ungefragt, jede Sitzung |
| **Referenz** | Die Aufgabe zwingt selbst zum Nachschlagen | in den **durchsuchbaren** Speicher |

Dieselbe Sache kann beide Formen brauchen.

**Gelernt an:** Eine Falle bei einem externen Dienst — ein Schreibaufruf auf einen
Einzeleintrag löscht die Nachbareinträge — war in einem Projekt korrekt dokumentiert. Drei
Wochen später passierte derselbe Fehler im Nachbarprojekt erneut: Der zugestellte Speicher
war projektlokal und kannte ihn nicht. **Fallen gehören so hoch wie möglich.**

---

## Was in jedem Fall gilt

Unabhängig von allen Antworten oben:

1. **Eine Notiz, die kein Verzeichnis erreicht, ist unsichtbar.** Für Menschen wie für
   Agenten. Prüf regelmäßig, welche Datei von keinem Index aus erreichbar ist.
2. **Nichts löschen, sondern archivieren.** Ein Archivordner kostet nichts und ersetzt
   die Versionshistorie dort, wo es keine gibt.
3. **Vor dem Anlegen suchen.** Doppelte Notizen zum selben Thema sind der häufigste
   Verfall, und sie entstehen nicht aus Nachlässigkeit, sondern weil niemand weiß, dass
   es das schon gibt — siehe Entscheidung E.
4. **Eine Notiz hat eine Frage, die sie beantwortet.** Beantwortet sie zwei, wird sie
   zwei Notizen. Beantwortet sie keine, ist sie ein Protokoll und gehört woanders hin.

---

## Woran man merkt, dass es bricht

*Keine Konvention ohne die Messung, die sie prüft. Alles hier ist mit einfachen Mitteln
zählbar — schon ein Skript von dreißig Zeilen reicht.*

| Zu messen | Bricht, wenn |
|---|---|
| Notizen ohne Pflichtangaben | > 0, und die Zahl steigt |
| Verweise, die nicht auflösen | > 0 |
| Verweise, die nach unten oder quer zeigen | > 0 |
| Notizen, die von keinem Verzeichnis erreichbar sind | > 0 |
| Notizen, deren `ebene` nicht zu ihrem Ort passt | > 0 |
| Verzeichnisse, die älter sind als ihre jüngste Notiz | > 0 |
| Notizen, die dieselbe Frage beantworten | nach Prüfung, mit Möglichkeit zum Stummschalten |

> **Die wichtigste Eigenschaft einer solchen Messung:** Sie muss **wissen, wo sie
> hinschauen soll**. Eine Prüfung, die einen Ort nicht kennt, meldet dort nicht „Fehler",
> sondern **null** — und null liest sich wie „alles in Ordnung". In einem Fall fehlten
> einer Erhebung über vierhundert Notizen, weil die Ortsliste einen Eintrag nicht hatte;
> alle Prüfungen meldeten grün. Halte die Liste der Orte an **einer** Stelle, nicht an
> fünf.

> **Die zweitwichtigste: Eine neue Messung gegen einen alten Bestand braucht einen
> Stichtag.** Sonst meldet sie beim ersten Lauf hunderte Altlasten, das Signal ertrinkt
> sofort, und niemand schaut je wieder hin. Miss ab dem Tag, an dem die Konvention gilt —
> den Altbestand getrennt zählen und getrennt abarbeiten.

> **Die drittwichtigste:** Ein geprüfter Befund muss verstummen können. Wer einen Fund
> untersucht und bewusst so lässt, braucht einen Ort für diese Entscheidung — sonst
> meldet die Prüfung ihn morgen wieder, und übermorgen schaut niemand mehr hin.

---

## Vorlage

*Erst ausfüllen, wenn A bis E entschieden sind. Die Platzhalter in spitzen Klammern
kommen aus `PROFIL.md`.*

### Ordnerbild

```
<ebene-1-name>/            # gilt überall
  <kategorie>/
    _index.md              # das Inhaltsverzeichnis dieser Kategorie
    <notiz>.md
  KONVENTIONEN.md          # diese Regeln, in der gewählten Fassung
  INDEX.md                 # das Verzeichnis der Verzeichnisse

<projekt>/
  wissen/                  # gilt nur hier
    _index.md
    <notiz>.md
  <link auf ebene-1>       # eingehängt, nicht kopiert
```

### Kopf einer Notiz

```yaml
---
titel: <ein Satz, keine Überschrift>
art: wissen | doku | regel | aufgabe
ebene: <name der gewählten ebene>
stand: entwurf | gueltig | ueberholt
aktualisiert: JJJJ-MM-TT
herkunft: erarbeitet | quelle | erschlossen      # optional, empfohlen
pruefen_nach_tagen: <zahl>                        # optional
---
```

### Die Konventionsdatei — Rohtext zum Anpassen

Liegt in `vorlagen/wissens-konventionen.md`. Sie enthält die obigen Entscheidungen als
ausformulierte Regeln mit Platzhaltern. Setz die Antworten ein, streich, was nicht
gewählt wurde, und leg sie auf die höchste Ebene.

---

## Die Lehren dahinter

*Kurzfassung. Ausführlich mit Belegen in `../FALLSTRICKE.md`.*

- **Die Ablage war nie kaputt, der Abruf hatte keinen Mechanismus.** Der teuerste Fehler
  in diesem Bereich ist nicht schlechte Ordnung, sondern fehlende Zustellung.
- **Ein Wächter, der einen Ort nicht kennt, ist dort stumm statt falsch.** Null Befunde
  sind kein Beweis.
- **Die Art-Frage kommt vor der Ebenen-Frage.** Die meisten Einordnungsfehler sind in
  Wahrheit Verwechslungen zwischen Wissen, Doku, Aufgabe und Regel.
- **Verweise zeigen nur nach oben.** Sonst kennt der Kern seine Nutzer und ist keiner mehr.
- **Eine Konvention ohne Messung ist ein Vorsatz.** Und ein Befund ohne Stummschalter
  trainiert das Wegsehen.
