# Erweiterung 5 · In ein anderes Werkzeug spiegeln

> **Anlass:** Jemand soll mitlesen, der keine Dateien öffnet — oder es wird eine Ansicht
> gebraucht, die sortieren und filtern kann.

---

## Worum es geht

Die **Grundsatzentscheidung** ist schon gefallen: Weiche 3 hat festgelegt, wo die Wahrheit
liegt und in welche Richtung abgeglichen wird. Hier steht die Umsetzung — und die ist
länger, als sie aussieht. **Ohne die Abschnitte unten baut man zuverlässig einen
Dublettengenerator.**

Falls Weiche 3 noch nicht entschieden ist: erst dorthin.

---

## Bestandsaufnahme — wenn schon etwas da ist

*Nur für den Durchlauf aus `INTEGRIEREN.md`. Beim Neuaufbau überspringen.*

**Sieh nach, bevor du redest:**

| Wonach | Wo typischerweise | Was der Fund bedeutet |
|---|---|---|
| Ein zweites System | Wiki, Projektwerkzeug (Notion, Confluence, Jira, Trello), eine Datenbank, ein Team-Kalender | Kein zweites System → das Modul ist noch nicht dran, es gibt nichts zu spiegeln |
| Wer dort schreibt | Einträge im Zielwerkzeug selbst, ihre Änderungshistorie | Wird von Hand gepflegt, ist das die Richtung, die der Spiegel ablösen oder ergänzen soll — nie umgekehrt |
| Ein bestehender Abgleich | ein Skript, ein Export-Knopf, ein Plugin, eine Automatisierung | Gibt es schon einen, prüf zuerst seine Richtung — schreibt er zurück in die Quelle, widerspricht das der Grundsatzentscheidung aus Weiche 3 |
| Eine Zuordnungstabelle | eine State-Datei, eine ID-Spalte, ein Mapping-Ordner | Fehlt sie, legt vermutlich jeder Lauf neu an — Dubletten sind dann schon unterwegs, nicht erst zu erwarten |
| Eine Vorlage je Zielort drüben | Templates, Seitenvorlagen im Zielwerkzeug | Fehlt sie, entstehen Zielseiten ohne einheitliche Form, eine je Lauf anders |

**Drei Ausgangslagen, die fast alles abdecken:**

- **Kein zweites System im Einsatz.** Dann ist dieses Modul noch nicht dran — die
  Grundsatzentscheidung aus Weiche 3 reicht, bis es eines gibt.
- **Ein zweites System existiert und wird von Hand gepflegt, aber es gibt keinen
  Abgleich.** Der lohnendste erste Schritt ist nicht das Skript, sondern die
  Zuordnungstabelle und die Richtung — bevor überhaupt etwas automatisch schreibt.
- **Es gibt schon einen Abgleich**, aber er prüft nur eine Richtung oder räumt nie ab.
  Erster Schritt: die Gegenrichtung — welcher Eintrag drüben hat keine Quelle mehr.

> **Der häufigste Fehlgriff an dieser Stelle:** Einen Abgleich aufsetzen, ohne vorher zu
> prüfen, ob im Zielwerkzeug schon von Hand geschrieben wird — der erste Lauf überschreibt
> dann genau das, was dort eigentlich gepflegt wurde.

---

## Die Entscheidung

**Was wird gespiegelt?** Nicht alles. Ein Spiegel kostet Laufzeit proportional zur Menge
der **Änderungen**, nicht zum Bestand — aber jeder gespiegelte Inhalt ist einer, der
drüben altern, Kommentare sammeln und Erwartungen wecken kann.

**Faustregel:** Spiegle, was jemand anders lesen soll. Nicht, was vollständig wäre.

**Wie wird zugeordnet, was wohin gehört?** Über eine Angabe im Kopf der Quelle — die
**Art**. Jede Art hat genau ein Ziel drüben. Das hat zwei Folgen, die man kennen muss:

1. Eine Quelle **ohne** bekannte Art hat kein Ziel — sie wird still nicht gespiegelt. Miss
   das, sonst fehlen Inhalte, ohne dass jemand es merkt. In einem beobachteten Fall waren
   das über vierhundert Notizen.
2. Jedes Ziel drüben braucht eine **Vorlage**, die sagt, wie eine Seite dort aussieht.
   Sonst gibt es fünf Vorlagen für neunzehn Ziele, und die Lücke steht nirgends.

---

## Entscheidung C — Was den Abgleich zusammenhält

Wer zwei Orte verbindet, braucht drei Dinge. Sie sehen nach Kleinkram aus und sind der
ganze Unterschied zwischen einem Abgleich und einem Dublettengenerator.

### 1 · Eine Zuordnung, die überlebt

Welche Datei entspricht welchem Eintrag drüben? Das muss irgendwo stehen, und dieses
Irgendwo ist selbst eine Wahrheit. Geht sie verloren, legt der nächste Lauf **alles**
neu an.

**Schreib sie atomar.** Die naheliegende Art, eine solche Datei zu speichern — öffnen,
leeren, neu schreiben — hat ein Fenster von Sekundenbruchteilen, in dem sie leer ist. Ein
Abbruch genau dort kostet die komplette Zuordnung. Schreib in eine Nebendatei und benenn
sie um; das ist eine Zeile mehr und der Unterschied zwischen einem Ärgernis und einem
verlorenen Tag.

### 2 · Ein Lauf zur Zeit

Zwei gleichzeitige Läufe überschreiben einander die Zuordnung. Bei reinen
Aktualisierungen folgenlos — aber wenn im verlorenen Zweig ein **Neuanlegen** lag, fehlt
dessen Zuordnung, und der nächste Lauf legt ein zweites Mal an.

Nimm eine Sperre, die beim Abbruch von selbst aufgeht. Eine Sperrdatei, die liegenbleibt,
wenn der Lauf hart beendet wird, sperrt den nächsten Termin aus — und das ist genau der
Ausfall, der verhindert werden sollte.

### 3 · Ein Lebenszeichen

Ein ehrlicher Abgleich dauert lang. „Dauert lange" und „hängt" sind von außen nicht
unterscheidbar, wenn nichts protokolliert wird — und die Ausgabe eines Programms wird oft
gepuffert und erscheint erst am Ende.

Schreib regelmäßig ein Lebenszeichen und **brich nach dessen Alter ab, nicht nach der
Gesamtdauer**. Die Gesamtdauer ist nur die äußere Notbremse, damit ein Lauf nicht in den
nächsten Termin läuft.

---

## Entscheidung D — Wer räumt auf

**Ein Abgleich legt an und aktualisiert. Er räumt nie ab.** Das ist keine Nachlässigkeit,
sondern die Folge der Einseitigkeit: Eine gelöschte Quelle taucht nirgends mehr auf, also
gibt es nichts, was das Löschen auslösen könnte.

**Gelernt an:** Eine Prüfung maß, ob jede Notiz drüben angekommen war, und meldete
vollständig. Gleichzeitig standen **37 verwaiste Einträge** in der Ansicht, deren Quelle
längst gelöscht oder verschoben war. Beide Seiten meldeten grün, weil beide nur eine
Richtung maßen.

**Also:** Eine zweite Prüfung, die die Gegenrichtung stellt — welcher Eintrag drüben hat
keine Quelle mehr? Und zwei Verben statt einem: **umhängen** (die Quelle ist nur
umgezogen, der Eintrag bleibt samt seiner Kommentare) und **archivieren** (die Quelle ist
weg). Bei Unklarheit: melden, nichts anfassen.

---

---

## Wer räumt auf

**Ein Abgleich legt an und aktualisiert. Er räumt nie ab.** Das ist keine Nachlässigkeit,
sondern die Folge der Einseitigkeit: Eine gelöschte Quelle taucht nirgends mehr auf, also
gibt es nichts, was das Löschen auslösen könnte.

**Gelernt an:** Eine Prüfung maß, ob jede Notiz drüben angekommen war, und meldete
vollständig. Gleichzeitig standen **37 verwaiste Einträge** in der Ansicht, deren Quelle
längst gelöscht oder verschoben war. Beide Seiten meldeten grün, weil beide nur eine
Richtung maßen.

**Zwei Verben statt einem:** **umhängen** (die Quelle ist nur umgezogen — der Eintrag
bleibt samt seiner Kommentare, nur die Zuordnung wandert) und **archivieren** (die Quelle
ist weg). Bei Unklarheit: melden, nichts anfassen. Ohne diese Unterscheidung macht jede
Umsortierung der Quelle aus einem sauberen Umzug zwei Karteileichen.

⚠️ **Und Archivieren ist bei manchen Systemen nicht wiederholbar** — ein zweiter Versuch
auf ein bereits archiviertes Objekt meldet einen Fehler. Wer den als echten Fehler wertet,
lässt den Zuordnungseintrag für immer stehen.

---

## Was in jedem Fall gilt

### Was übersprungen wird, korrigiert sich nie

Wer aus Sparsamkeit nur abgleicht, was sich geändert hat, braucht eine Vergleichsmarke.
**Diese Marke muss das Ergebnis der Umwandlung einschließen, nicht nur die Quelle.** Sonst
bleibt jede Änderung an der Umwandlungslogik wirkungslos — übersprungen wird ja, was sich
„nicht geändert hat". Der Preis für die richtige Marke ist eine einmalig volle Runde.

### Ein einzelner Eintrag darf nie den ganzen Lauf reißen

Ein Sonderzeichen, eine zu lange Zeile, ein unbekanntes Format — und der Lauf bricht ab,
oder schlimmer: Er läuft weiter und lässt genau diesen einen Eintrag still aus. In einem
beobachteten Fall scheiterten drei Einträge über **mehrere Wochen in jedem Lauf**, weil
ihr Inhalt an einer Schutzschranke hängenblieb; weil sie den Gesamtstatus rot färbten,
sagte die Statusmeldung irgendwann gar nichts mehr aus.

**Fang einzelne Einträge ab, meld sie namentlich, lauf weiter.** Und kürz Fehlermeldungen
nicht — die entscheidende Stelle steht erfahrungsgemäß hinter dem Schnitt.

### Ein Fehler ist eine Aussage über die Verbindung, nicht über die Daten

Drei getrennte, teure Vorfälle gingen auf dieselbe Verwechslung zurück:

- Eine Fehlermeldung enthielt ein Wort, das nach „gelöscht" klang. Der Aufrufer schloss
  daraus „existiert nicht mehr" und legte neu an.
- Eine Abfrage scheiterte am Netz und gab „nichts gefunden" zurück → neu angelegt.
- Ein Schreibvorgang lief in eine Zeitüberschreitung, war aber angekommen. Die
  automatische Wiederholung traf auf einen bereits veränderten Stand.

**Dreifache Konsequenz:** Fehler tragen **Status und Code als Felder**, nicht als Text zum
Lesen. „Konnte nicht fragen" ist **keine Antwort** — wirf den Fehler, statt ihn zu „nichts
gefunden" einzuebnen. Und **schreibende Aufrufe sind nicht wiederholbar**: nur bei
Überlastung erneut versuchen, nie bei Zeitüberschreitung.

### Ein einzelner Eintrag darf nie den ganzen Lauf reißen

Ein Sonderzeichen, eine zu lange Zeile, ein unbekanntes Format — und der Lauf bricht ab,
oder schlimmer: Er läuft weiter und lässt genau diesen Eintrag still aus. In einem Fall
scheiterten drei Einträge über **mehrere Wochen in jedem Lauf**; weil sie den Gesamtstatus
rot färbten, sagte die Statusmeldung irgendwann gar nichts mehr aus.

**Fang einzelne Einträge ab, meld sie namentlich, lauf weiter.** Und **kürz
Fehlermeldungen nicht** — die entscheidende Stelle steht erfahrungsgemäß hinter dem
Schnitt.

> **Ein Statuswert, der immer rot ist, ist kein Statuswert.** Zähl wiederkehrende Fehler
> getrennt von neuen.

### Der Takt richtet sich nach der Änderungsmenge

Ein Zwei-Tage-Takt staut an, was dann in einem Lauf abzuarbeiten ist. Täglich und kurz ist
besser als selten und lang.

**Und der Zeitpunkt ist keine Kleinigkeit:** Ein Termin früh am Morgen trifft einen
Rechner, der gerade aufwacht — ohne Netz, ohne Namensauflösung. In einem beobachteten Fall
riss das an zwei Tagen **alle** Konten Sekunden nach dem Start.

### Ein Nachlauf von Hand braucht einen anderen Weg als aus einer Sitzung heraus

Ein Hintergrundvorgang, den eine Agenten-Sitzung startet, wird beim Ende dieser Sitzung
samt Prozessgruppe abgeräumt — auch mitten in einem Schreibvorgang. Für den Nachlauf aus
einer Sitzung heraus braucht es einen Weg über die Zeitsteuerung des Systems, nicht über
einen Hintergrundstart.

### Formatgrenzen des Ziels sind echte Grenzen

Zielsysteme haben Beschränkungen, die nirgends stehen: erlaubte Sprachbezeichner für
Code-Blöcke, Höchstzahlen von Textteilen je Absatz, Schutzschranken gegen bestimmte
Zeichenfolgen. Eine einzige verletzte Grenze kann **den ganzen Eintrag** abweisen.

**Behandle das als Übersetzungsaufgabe, nicht als Fehler:** Unbekanntes Format → auf
etwas Neutrales zurückfallen. Zu viele Teile → zusammenfassen, Auszeichnung darf verloren
gehen, Text nie. Und wenn die Quelle etwas enthält, das drüben anstößt: **die Quelle
bleibt unberührt** — sie ist die Wahrheit, der Spiegel nur eine Ansicht. Entschärft wird
im Spiegel, mit einem sichtbaren Hinweis darauf.

### Ein Status ist eine Aussage, kein Etikett

**Gelernt an:** Der Zustand „fertig, wartet auf Freigabe" wurde im Spiegel auf dieselbe
Anzeigeoption abgebildet wie „läuft gerade". Folge: **sechzehn fertige Pläne, vier davon
Sicherheitsthemen, standen wochenlang ununterscheidbar neben laufender Arbeit** — und
niemand zählte sie, weil nichts sie als wartend auswies.

Wer Zustände auf weniger Anzeigeoptionen abbildet, als es Zustände gibt, macht eine ganze
Klasse Arbeit unsichtbar. **Vor allem die, die auf einen Menschen wartet.**

Wenn das Ziel die passende Option nicht kennt: eine Kette angeben und die erste nehmen, die
es gibt — ein ungenauer Status ist besser als gar keiner, aber die Ungenauigkeit gehört
benannt.

### Zwei verschiedene Quellen dürfen gleich heißen

Eine Doppelerkennung, die nach Titeln gruppiert, erklärt zwei berechtigte Einträge zu
einer Dublette und blockiert dann alles. Gruppier nach der **Quelle**, nicht nach dem
Titel — und mach aus dem Namensgleichklang eine eigene, nicht blockierende Meldung.

---

## Woran man merkt, dass es bricht

| Zu messen | Bricht, wenn |
|---|---|
| Quellen ohne Eintrag drüben | > 0 |
| Einträge drüben ohne Quelle | > 0 |
| Doppelte Einträge zur selben Quelle | > 0 |
| Quellen ohne bekannte Art | > 0 |
| Ziele drüben ohne Vorlage | > 0 |
| Alter des letzten erfolgreichen Laufs | älter als zwei Takte |
| Einzelne Einträge, die wiederholt scheitern | > 0 über mehr als einen Lauf |
| Laufzeit je Lauf | wächst über Wochen |

---

## Vorlage

```yaml
# spiegel.yml
quelle: <wo die wahrheit liegt>
ziel: <welches werkzeug, welches konto>
richtung: nur_hin
takt: taeglich <uhrzeit — nicht direkt nach dem aufwachen>
zuordnung:
  <art>: <ziel drüben>
  <art>: <ziel drüben>
vorlagen:
  <ziel drüben>: <welche seitenvorlage>
```

**Im Profil vermerken:** was gespiegelt wird, wohin, in welchem Takt, welche Arten es gibt.
