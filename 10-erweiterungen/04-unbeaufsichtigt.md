# Erweiterung 4 · Unbeaufsichtigt arbeiten lassen

> **Anlass:** Es gibt einen echten Rückstand, und es gibt Stunden, in denen niemand am
> Rechner sitzt.

---

## Worum es geht

Eine Warteschlange von Aufgaben, die nachts oder in längeren Abwesenheiten abgearbeitet
wird. Das ist die anspruchsvollste Erweiterung und die einzige, die eine **Umstellung der
Arbeitsweise** verlangt: Der Rückstand muss als strukturierte Aufgaben geführt werden, nicht
als Merkzettel.

---

## Bestandsaufnahme — wenn schon etwas da ist

*Nur für den Durchlauf aus `INTEGRIEREN.md`. Beim Neuaufbau überspringen.*

**Sieh nach, bevor du redest:**

| Wonach | Wo typischerweise | Was der Fund bedeutet |
|---|---|---|
| Eine geführte Liste offener Aufgaben | `backlog/`, `TODO.md`, Issues in einem Tracker | Fehlt sie, gibt es noch nichts, das ein unbeaufsichtigter Lauf abarbeiten könnte — das ist dann der erste Schritt, nicht die Zeitsteuerung |
| Kopfangaben an diesen Aufgaben | die ersten Zeilen der Aufgabendateien, Felder in einem Tracker | Fehlen sie, lässt sich nichts ranken, auswählen oder abschließen — der teuerste fehlende Baustein |
| Ein zeitgesteuerter Lauf | Cron, launchd/Taskplaner, ein CI-Scheduled-Job, ein Automatisierungswerkzeug | Läuft schon etwas, geht es nur noch um die Absicherungen unten — nicht um den Aufbau von null |
| Ein Protokoll vergangener Läufe | Log-Dateien, ein Ergebnis-Ordner, Commits zur Nachtzeit | Fehlt es, wurde nie geprüft, ob ein Lauf tatsächlich etwas bewirkt hat |
| Ein Feld, das „fertig" anzeigt | eine Status-Spalte, eine Checkbox, ein Zustand in den Kopfangaben | Uneindeutig oder fehlend → genau die Falle aus „Wo der Abschluss steht" unten |

**Drei Ausgangslagen, die fast alles abdecken:**

- **Kein geführter Rückstand, nur Merkzettel oder Gedächtnis.** Der lohnendste erste
  Schritt ist die strukturierte Aufgabenliste mit Kopf — nicht die Zeitsteuerung. Ohne
  sie hat ein Lauf nichts, das er verlässlich auswählen und abschließen kann.
- **Eine Aufgabenliste existiert, aber ohne feste Kopfangaben.** Erster Schritt: die
  Kopfangaben nachrüsten, mindestens `stand` und das Feld, das den Abschluss zeigt.
  Zeitsteuerung kommt danach, nicht gleichzeitig.
- **Es läuft schon etwas zeitgesteuert**, aber niemand hat je nachgesehen, ob ein Lauf
  wirklich etwas bewirkt hat. Erster Schritt: die Erfolgsmessung — die objektive Spur,
  nicht die Selbstauskunft des Laufs.

> **Der häufigste Fehlgriff an dieser Stelle:** Gleich über Zeitfenster und Deckel reden,
> wenn noch keine einzige Aufgabe eine strukturierte Kopfangabe hat — dann fehlt die
> Grundlage, nicht die Feinjustierung.

---

## Die Voraussetzung, die man unterschätzt

**Aufgaben brauchen einen Kopf mit festen Angaben**, sonst lässt sich nichts ranken, nichts
auswählen und nichts abschließen:

```yaml
---
art: aufgabe
stand: offen | laufend | erledigt | plan_fertig
dringlichkeit: hoch | mittel | niedrig
aufwand: klein | mittel | gross
ausfuehrung: selbstaendig | nur_planen
ort: <wo gehört das hin>
abschluss_zeigt_sich_an: <welches feld sagt "fertig">
---
```

Das letzte Feld ist das, an das niemand denkt. Siehe unten.

---

## Was in jedem Fall gilt

### Der Erfolg wird gemessen, nicht gemeldet

**Dass ein Programm sauber endet, heißt nur, dass es nicht abgestürzt ist.** Wenn eine
Sitzung ihr eigenes Ticket schließt, ist das kein Nachweis.

Erheb stattdessen die **objektive Spur**: Hat sich der festgeschriebene Stand bewegt? Hat
sich die Aufgabendatei geändert? Steht sie auf abgeschlossen? Welche Dateien wurden
berührt? Daraus wird ein Urteil:

| Urteil | Bedeutet |
|---|---|
| **erledigt** | Abschluss-Zustand **und** festgeschriebene Änderung |
| **behauptet** | Sagt fertig, nichts festgeschrieben |
| **fortschritt** | Etwas passiert, nicht fertig |
| **spurlos** | Keine Spur. Der interessanteste Fall |
| **grenze verletzt** | Hat angefasst, was nicht erlaubt war |
| **abgebrochen** | Zeitlimit oder Kontingent |

Das ist rein rechnerisch und kostet nichts — kein zweiter Agent, der selbst wieder
unzuverlässig wäre.

### Wo der Abschluss steht, ist nicht überall gleich

**Gelernt an, und das ist die lehrreichste Panne:** Eine Aufgabenart schließt ab, indem
sie aufhört, diese Art zu sein — ihr Typ ändert sich. Gemessen wurde aber ein anderes
Feld, das bei dieser Art per Entwurf auf „nein" steht. Ein Abschluss war damit
**strukturell unerreichbar**: **40 von 40** Durchläufen standen als „unfertig" in der
Bilanz, jeder einzelne mit ordentlich erledigter Arbeit.

**Also:** Je Aufgabenart ausdrücklich festhalten, **welches Feld** den Abschluss anzeigt.
Und für unbekannte Arten einen Standard wählen, der eher zu wenig als zu viel behauptet.

### Wiederholt folgenlose Aufgaben müssen aussteigen

Sonst frisst dieselbe Aufgabe jede Nacht Kontingent. Zwei folgenlose oder drei unfertige
Versuche → raus aus der Warteschlange. **Und der Ausstieg endet von selbst, sobald sich
die Aufgabe ändert** — kein Freischaltbefehl, den man kennen müsste.

### Ein Wächter, der die Mehrheit falsch rot färbt, trainiert das Wegsehen

**Gelernt an:** Eine Grenzprüfung verlangte etwas, das nur ein einziger Auftragstyp
überhaupt gefordert hatte. Folge: **11 von 16 Läufen** standen als „Grenze verletzt" im
Morgenbericht — alle mit erledigter Arbeit, keiner mit dem entsprechenden Auftrag.

**Also:** Gemessen wird nur, was der Auftrag verlangt hat.

### Der Deckel ist nicht der Schutz, den man meint

Eine Obergrenze je Lauf schützt vor Überlast. Sie wird zum Problem, sobald sie das
Zeitfenster vorzeitig beendet, während noch Kapazität da wäre. Und mehrere Deckel, die
aufeinander folgen, müssen **gemeinsam** bewegt werden — wer einen dreht, staut die
nächste Stufe.

### Der Engpass ist meistens der Anfang, nicht das Ende

**Gelernt an:** Ein Lauf durfte sieben Stunden arbeiten, begann aber erst, wenn eine
Weile niemand aktiv war — in einer beobachteten Nacht um 3:51. Von sieben Stunden blieben
zwei. Wer dann das Ende verlängert, behandelt das falsche Ende.

### Der Auslöser muss öfter prüfen, als er wartet

**Gelernt an:** Ein Lauf sollte starten, sobald eine halbe Stunde niemand aktiv war —
geprüft wurde alle zwanzig Minuten. Wachte der Rechner zwischendurch kurz auf, blieb die
gemessene Ruhezeit bei den folgenden Prüfungen **systematisch knapp unter der Schwelle**.
Der Lauf startete fast nie, und niemand verstand zunächst, warum.

**Die Regel:** Der Prüftakt muss deutlich kleiner sein als die geforderte Wartezeit. Sonst
ist die Bedingung rechnerisch kaum erreichbar.

### Was den Rechner wachhält, wirkt oft nur am Netzteil

**Gelernt an:** Ein Nachtlauf fiel an zwei aufeinanderfolgenden Nächten vollständig aus,
weil das Gerät auf Akku hing und der Wachhalte-Mechanismus dort wirkungslos ist — **ohne
jeden Alarm**. Prüf den Stromzustand ausdrücklich und warne, statt dich auf den
Wachhalte-Befehl zu verlassen.

### Ein Sicherheitsnetz braucht ein eigenes Lebenszeichen

**Gelernt an:** Ein Rettungsjob, der einen hängenden Hauptlauf ablösen sollte, prüfte nur,
ob dessen Sperre noch belegt war — und wies sich deshalb selbst ab. Der Hauptlauf hing
tatsächlich fest. **Das Netz versagte genau in dem Fall, für den es gebaut war.**

Prüf das **Alter des Lebenszeichens**, nicht die Existenz der Sperre.

### Es muss von allein aufhören

Ein Lauf, der weiterläuft, wenn jemand zurückkommt, frisst das Kontingent, das dieser
gerade selbst braucht. Prüf vor **jeder** Aufgabe, ob das Fenster noch offen ist — an
derselben Stelle, an der die Zeit geprüft wird. Mehrere Abschaltgründe, ein Zustand: drei
Bedingungen an drei Stellen sind drei Gelegenheiten, eine zu vergessen.

**Und den laufenden Vorgang nicht abwürgen** — ein Abbruch hinterlässt halbfertige Arbeit.
Begrenz stattdessen das Zeitlimit je Aufgabe.

### Die Freigabe-Einheit ist so fein wie die kleinste entscheidbare Sache

**Gelernt an:** Über hundert verifizierte Befunde lagen wochenlang unbearbeitet — **null
von mehreren gebündelten Themen freigegeben**, seit Wochen. Der Grund war nicht Trägheit,
sondern der Schnitt: Jedes „Thema" bündelte drei bis acht Einzelbefunde quer über alle
Risikoklassen. **Wer das Harmlose nur zusammen mit dem Hochkritischen freigeben kann, gibt
gar nichts frei.**

Ein Befund, eine Aufgabe, eine Entscheidung.

### Ein Zeitlimit auf einer monotonen Uhr greift im Schlafmodus nicht

**Gelernt an:** Eine Obergrenze „läuft höchstens N Stunden" griff über Nacht nie — die
zugrunde liegende Uhr steht im Schlafmodus still. Mehrere Läufe zwischen anderthalb und
knapp zwölf Stunden meldeten alle „nicht abgelaufen", der längste lief noch am Vormittag.

**Nimm zusätzlich eine echte Uhrzeit-Grenze.** Zwei Uhren, weil sie verschiedene Dinge
messen.

### Wenn Agenten Fehler beheben sollen: nach Entdeckbarkeit trennen, nicht nach Schwere

Ein „schwerer, aber lauter" Fehler ist für automatische Behebung **ungefährlicher** als ein
„mittlerer, aber leiser" — etwa einer, der still eine falsche Berechtigung setzt. Trenn
also:

| Klasse | Merkmal | Behandlung |
|---|---|---|
| **A** | Ein Fehlgriff kracht sofort | darf unbeaufsichtigt behoben werden |
| **B** | Ein Fehlgriff greift still daneben — Rechte, Grenzen, Beträge, Datenmigrationen | nur Test und Plan schreiben, nicht beheben |

Im Zweifel B. Ein falsch als A eingestuftes Problem ist der **einzige** Weg, auf dem das
Verfahren Schaden anrichtet.

**Drei Absicherungen, die zusammengehören:**

1. **Der rote Test zuerst, einzeln gesichert.** Wenn derselbe Akteur Fix und Test schreibt,
   beweist „alles grün" nichts — ein gemeinsames Missverständnis geht durch beide hindurch.
   Nur rot-dann-grün beweist beides.
2. **Ein harter Größendeckel auf die Änderung — als Test der Einordnung selbst.** Reißt er,
   war es nie Klasse A. Abbrechen ist dann der Erfolg, nicht das Scheitern.
3. **Ein Zweitgutachter, der nie blockiert.** Fällt er aus, hinterlässt er ein leeres Feld,
   nicht einen verworfenen Fix. Sonst wird die Absicherung selbst zur Schwachstelle.

**Und getrennte Deckel je Klasse.** Ein gemeinsamer Deckel lässt die risikoärmere Klasse
die riskantere systematisch verdrängen.

### Zwei Betriebsdetails, die teuer waren

**Zweig immer vom stabilen Ausgangspunkt ab, ausdrücklich.** Ohne Angabe hängte sich ein
Lauf an den Zwischenstand seines Vorgängers — samt dessen **absichtlich fehlschlagender**
Tests. „Alle Tests grün" wurde damit unerreichbar, und wer das übernommen hätte, hätte den
Hauptstand kaputtgemacht.

**Gib den Läufen einen eigenen Arbeitsort außerhalb des Projektraums.** Ohne den legten sie
acht Hilfsverzeichnisse direkt neben die echten Projekte — und wurden dort für neue
Projekte gehalten. Das war die richtige Lesart: Dort standen Projekte.

⚠️ **Aber: Wer den Arbeitsort verlegt, muss auch dort messen.** Misst die Erfolgsprüfung
weiter am alten Ort, der sich nicht mehr bewegt, misst sie **nichts** — und jede Aufgabe
gilt als halbfertig.

---

## Woran man merkt, dass es bricht

| Zu messen | Bricht, wenn |
|---|---|
| Anteil „spurlos" an allen Läufen | über ein Zehntel |
| Anteil „erledigt" | fällt deutlich unter die Hälfte |
| Aufgaben im Ausstieg | steigt |
| Alter des letzten Laufergebnisses | älter als ein Takt — das heißt „ausgefallen", nicht „nichts zu tun" |
| Läufe, die am Kontingent endeten | steigt → falscher Motor oder zu große Aufgaben |

> **Wichtig:** Prüf die **Frische** des letzten Ergebnisses, nicht nur seinen Inhalt. Ein
> Absturz vor dem Schreiben des Ergebnisses liest sich sonst als ganz normaler Vortag.

---

## Vorlage — der Auftragstext für unbeaufsichtigte Läufe

Zusätzlich zum Auftragstext aus Erweiterung 3:

```markdown
## Besonderheiten dieses Laufs
- Warte Hintergrundvorgänge aktiv ab. Endet die Sitzung, sterben sie.
- Schreib in Zwischenschritten fest. Ein Abbruch kostet dann nur den letzten Schritt.
- **Erst festschreiben, dann prüfen.** Fehler behebst du in einem weiteren Schritt.
- Wirst du nicht fertig: Stand bleibt "offen", schreib einen Abschnitt
  "## Zwischenstand" in die Aufgabendatei und schreib sie fest.
  (Ein Zwischenstatus wie "laufend" fällt aus der Warteschlange und kommt nie wieder.)
- Nichts veröffentlichen. Nichts zurücksetzen, was du nicht selbst geändert hast.
```

**Im Profil vermerken:** Zeitfenster, Deckel, wo die Warteschlange liegt, welche Urteile
zum Ausstieg führen.
