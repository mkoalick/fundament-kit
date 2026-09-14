# Erweiterung 6 · Dokumente erzeugen

> **Anlass:** Tabellen, Folien oder Berichte sollen nicht von Hand gebaut werden.
> Unabhängig von allem anderen — diese Erweiterung setzt nichts voraus.

---

## Worum es geht

Office-Dateien lassen sich auf zwei Wegen erzeugen: indem man das Office-Programm
fernsteuert, oder indem man die Datei direkt schreibt. **Der zweite Weg ist der richtige,
und der Grund ist kein ästhetischer.**

Fernsteuerung holt bei **jedem einzelnen Schritt** das Fenster nach vorn. Ein Abgleich über
mehrere Mappen sind hunderte davon, und für deren Dauer ist der Rechner nicht mehr
benutzbar. Dazu kommt: Fernsteuerung braucht das installierte Programm, eine Lizenz und
eine grafische Sitzung — auf einem Server läuft davon nichts.

**Also:** Bibliotheken, die die Dateiformate direkt schreiben. Für Tabellen, Textdokumente
und Präsentationen gibt es sie in jeder verbreiteten Programmiersprache.

**Die Ausnahme, die es wirklich gibt:** Makros, Neuberechnung von Formeln, layoutgetreuer
Druck. Das geht nur über das Programm. Sag es vorher an und hol dafür eine ausdrückliche
Zustimmung — Ausnahme, nicht Normalfall.

---

## Bestandsaufnahme — wenn schon etwas da ist

*Nur für den Durchlauf aus `INTEGRIEREN.md`. Beim Neuaufbau überspringen.*

**Sieh nach, bevor du redest:**

| Wonach | Wo typischerweise | Was der Fund bedeutet |
|---|---|---|
| Erzeugte Tabellen, Texte oder Folien | ein Ausgabeordner, Anhänge, ein `reports/`- oder `exports/`-Verzeichnis | Gibt es sie schon, zeigt sich sofort, welcher der beiden Wege gewählt wurde |
| Wie sie entstehen | Skripte mit Bibliotheksaufrufen gegen Fernsteuerung des Office-Programms (AppleScript, COM, UI-Automation) | Fernsteuerung → das ist der Punkt, der zuerst korrigiert gehört, aus dem Grund oben, nicht aus Geschmack |
| Gestaltungsvorgaben | eine eigene Vorlagendatei, Farb- und Schriftwerte im Code selbst, ein Corporate-Design-Dokument | Stehen sie im Code verstreut, ist das der teuerste Umbau, wenn er erst später kommt — jetzt ist er günstig |
| Eine Namenskonvention | Dateinamen bestehender Ausgaben, eine Vorgabe dazu in einer Anweisungsdatei | Uneinheitliche Namen → kein Archiv, keine Versionierung, jede Ausgabe ein Einzelstück |
| Fassungen und Archiv | mehrere Versionen im selben Ordner, ein `00-archiv/`- oder `alt/`-Unterordner | Fehlt die Trennung, wird vermutlich überschrieben statt versioniert |

**Drei Ausgangslagen, die fast alles abdecken:**

- **Noch keine erzeugten Dokumente, alles wird von Hand gebaut.** Der lohnendste erste
  Schritt ist, direkt mit der schreibenden Bibliothek anzufangen und Gestaltung von
  Anfang an von der Mechanik zu trennen — das spart den Umbau, der sonst später fällig wird.
- **Dokumente entstehen per Fernsteuerung** (ein Makro, AppleScript, COM). Erster Schritt:
  auf die schreibende Bibliothek umstellen — nicht aus Ästhetik, sondern weil die
  Fernsteuerung den Rechner für ihre Dauer blockiert.
- **Dokumente werden schon direkt geschrieben**, aber Gestaltung steckt im Code verstreut
  und es gibt keine Namenskonvention. Erster Schritt: Gestaltungsregeln auslagern und die
  Namenskonvention einführen, bevor der Bestand weiter wächst.

> **Der häufigste Fehlgriff an dieser Stelle:** Die Umstellung auf die schreibende
> Bibliothek anmahnen, wenn gar keine Fernsteuerung mehr im Spiel ist — dann fehlt nur
> die Namenskonvention oder die Trennung der Gestaltung, nicht der ganze Ansatz.

---

## Die Entscheidung

**Wie werden Gestaltung und Mechanik getrennt?** Das ist die ganze Kunst hier.

| Weg | Folge |
|---|---|
| Farben, Schriften, Abstände **im Werkzeug** | Jede Gestaltungsänderung ist eine Änderung am Werkzeug. Nach drei Runden traut sich niemand mehr ran |
| Gestaltung in **eigenen Regeldateien**, Werkzeug liest sie | Die Marke ist austauschbar, ohne das Werkzeug anzufassen. Ein zweiter Bereich bekommt eine zweite Regeldatei |

**Empfehlung:** Trennen, von Anfang an. Es kostet beim Bauen eine halbe Stunde und macht
den Unterschied zwischen einem Werkzeug und einem Einzelstück.

---

## Was in jedem Fall gilt

1. **Die erzeugte Datei wird geprüft, nicht angenommen** — und zwar **als Bild, nicht nur
   als Zahlen**. Eine Kennzahlen-Mappe bestand alle Formel- und Summenprüfungen; erst das
   Ansehen jeder Seite fand eine fast leere Seite, ein falsches Zahlenformat und
   fehlerhafte Diagrammbalken. Ein zweites kleines Werkzeug, das die fertige Datei gegen
   die Gestaltungsregeln misst, findet den Rest.

   ⚠️ **Und wenn doch einmal ein Programm ferngesteuert wird: Fernsteuerung kann Inhalte
   unsichtbar beschädigen, ohne einen Fehler zu werfen.** Ein Befehl zum Setzen eines
   Signatur-Logos wandelte ein eingebettetes Bild in einen bloßen Verweis um, ohne die
   Bilddaten mitzuschreiben. Der Entwurf zeigte einen toten Platzhalter, keine
   Fehlermeldung — aufgedeckt erst durch eine tatsächlich versendete und zurückgeholte
   Testnachricht.
2. **Benennung und Ablage folgen einer Konvention** — Datum, Beschreibung, Version;
   ein Ordner je Dokument; Ausrangiertes ins Archiv statt in den Papierkorb.
3. **Eine fertige Fassung wird nie überschrieben.** Sie bekommt eine eigene Kennzeichnung,
   und weitere Änderungen werden zu einer neuen Fassung.
4. ⚠️ **Manche Markenwerte stecken im Dateiformat selbst, nicht in deiner Konfiguration.**
   Firmenname und Vorlagenname liegen in Office-Vorlagen als Text **im eingebetteten
   Archiv**. Eine zentrale Gestaltungsdatei erreicht sie nicht — man ändert die
   Konfiguration, hält alles für angepasst, und die alte Marke taucht in jeder erzeugten
   Datei wieder auf. Dafür braucht es einen eigenen Schritt, der direkt im Archiv ersetzt
   — **samt aller Schreibweisen**, Kleinschreibung eingeschlossen.
5. **Nach dem Erzeugen im Hintergrund öffnen**, nicht im Vordergrund. Wer gerade arbeitet,
   will nicht, dass ein Fenster aufspringt.

---

## Woran man merkt, dass es bricht

| Zu messen | Bricht, wenn |
|---|---|
| Erzeugte Dateien, die die Namenskonvention verletzen | > 0 |
| Ordner mit mehr als zwei Arbeitsfassungen | > 0 |
| Gestaltungsvorgaben, die im Werkzeug stehen statt in der Regeldatei | > 0 |

---

## Vorlage

### Namensschema

```
JJMMTT_Beschreibung_V01.ext
```

Keine Leerzeichen, keine Umlaute, keine Sonderzeichen im Dateinamen. Unterstriche als
Trenner. Das Versionskürzel einheitlich wählen und nicht mischen.

### Ordnerbild

```
<beschreibung>/
  JJMMTT_Beschreibung_V02.pptx     ← aktuell
  JJMMTT_Beschreibung_V01.pptx     ← vorletzte
  00-archiv/                        ← alles ältere, nichts gelöscht
```

### Gestaltungsregeln, getrennt vom Werkzeug

```markdown
# Gestaltung — <Bereich>

## Farben
Akzent: <hex> · Text: <hex> · Fläche: <hex>
Genau ein Akzent. Farbe nie als einziger Bedeutungsträger.

## Schrift
Überschrift: <name>, <größe> · Fließtext: <name>, <größe>

## Raster
Ränder: <maß> · Abstand zwischen Blöcken: <maß>

## Verboten
<Was ausdrücklich nicht vorkommt.>
```

**Im Profil vermerken:** welche Formate, wo die Gestaltungsregeln liegen, welches
Versionskürzel.
