# Erweiterung 2 · Mehrere Projekte überblicken

> **Anlass:** Eine Frage wie „wo liegt eigentlich X" oder „welche Projekte haben Y"
> lässt sich nicht mehr beantworten, ohne zehn Dateien zu öffnen.

---

## Worum es geht

Ab etwa vier, fünf Projekten entsteht ein eigenes Problem: Der Überblick kostet mehr als
die Arbeit. Und die naheliegende Lösung — eine KI liest sich durch — ist die teuerste:
Sie kostet bei jeder Frage erneut, liefert jedes Mal ein etwas anderes Ergebnis und füllt
den Kontext mit Dingen, die man nicht behalten wollte.

**Der Grundsatz:** *Inventarisieren ist Script-Arbeit, keine Modell-Arbeit.* Ein
deterministisches Programm erhebt den Bestand in eine Datei; Fragen werden aus dieser
Datei beantwortet.

---

## Bestandsaufnahme — wenn schon etwas da ist

*Nur für den Durchlauf aus `INTEGRIEREN.md`. Beim Neuaufbau überspringen.*

**Sieh nach, bevor du redest:**

| Wonach | Wo typischerweise | Was der Fund bedeutet |
|---|---|---|
| Anzahl der Projektordner | eine Ebene unterhalb des Arbeitsverzeichnisses | Unter vier, fünf trägt der Aufwand aus diesem Modul meist noch nicht |
| Eine Übersichtsdatei oder ein Dashboard | README im Stamm, ein eigener `inventory`- oder `projects`-Ordner | Fehlt sie, wird jede Übersicht neu erlesen — das ist der teuerste Fall |
| Wie projektübergreifende Fragen bisher beantwortet werden | die letzten Sitzungen, in denen „welche Projekte haben X" gefragt wurde | Wird dafür jedes Mal durch alle Projekte gelesen, ist genau das der Punkt, den dieses Modul abstellt |
| Eine Registrierungsdatei mit Orten | `.yml`/`.json` im Stamm | Fehlt sie, ist jede spätere Automatisierung an neuen Orten stumm |
| Unterschiedliche Projektarten (Produkt, Wissen, Steuerung) | Ordnernamen, README-Beschreibungen | Werden alle an derselben Checkliste gemessen, erscheinen Wissensordner fälschlich als defizitär |

**Zwei Ausgangslagen, die fast alles abdecken:**

- **Viele Projektordner, keine Übersicht, Fragen laufen über Vorlesen** — der häufigste
  Fall. Lohnendster erster Schritt: eine schlichte Registrierungsdatei (Name, Pfad, Rolle)
  anlegen, aus der ein kurzes Skript eine Bestandsdatei erzeugt. Nicht mehr erheben, als
  tatsächlich gefragt wird.
- **Es gibt schon eine Liste oder ein Dashboard, aber sie wird von Hand gepflegt.** Dann
  geht es nicht um den Aufbau, sondern ums Erzeugen statt Pflegen: Ein Skript, das die
  Datei aus dem echten Bestand erzeugt, ersetzt die Handarbeit und veraltet nicht mehr.

> **Der häufigste Fehlgriff an dieser Stelle:** Eine Erhebungsmaschine für zwei oder drei
> Projekte vorschlagen — darunter trägt der Aufwand nicht, und Nachsehen von Hand ist
> schneller als jedes Skript.

---

## Die Entscheidung

**Was wird erhoben?** Nicht alles, was geht — sondern das, wonach wirklich gefragt wird.
Ein brauchbarer Startumfang:

- Welche Projekte gibt es, und wo liegen sie
- Welche Werkzeuge, Regeln und Riegel hat jedes
- Wann wurde zuletzt gearbeitet, was ist offen
- Welche Konventionsverstöße gibt es (die Messungen aus den Weichen)

**Zwei Eigenschaften sind wichtiger als der Umfang:**

1. **Es kennt seine Orte aus einer Registrierungsdatei**, nicht aus einer Suche und nicht
   aus einer eingebauten Liste. Sonst ist es an neuen Orten stumm.
2. **Es weiß, was ein Ort haben *soll*** — und was er bewusst nicht hat. Ohne das misst
   man jeden Ort an derselben Liste, und ein reiner Wissensspeicher erscheint mit „null
   Werkzeugen" als defizitär, obwohl das seine Bauart ist.

---

## Was in jedem Fall gilt

### Ein leeres Merkmal ist nicht automatisch ein Mangel

Führ je Ort zwei Listen: **erwartet** und **bewusst nicht**. Das kostet einmal zehn
Minuten und verhindert dauerhaft Fehlalarme, die niemand mehr liest.

### Der Zähler und die Anzeige sind zwei verschiedene Dinge

Eine Übersicht kürzt lange Listen — das ist richtig. Aber die **Kennzahl daneben** muss
echt zählen. Wird sie aus der gekürzten Liste abgeleitet, zeigt sie irgendwann bei jedem
Ort denselben Wert, nämlich die Kürzungsgrenze. Das ist keine Theorie: Genau so stand in
einer Übersicht bei acht von dreizehn Orten exakt „15 offen", während es real über
zweitausend waren.

### Alter vor Inhalt

Jede Übersicht zeigt, **wie alt ihre Daten sind**. Eine Oberfläche, die am saubersten
aussieht, wenn die Erhebung seit drei Tagen nicht mehr läuft, ist schlimmer als keine.

### Kein Block verschwindet, wenn es gut steht

Ein Warnbereich, der bei null Befunden ausgeblendet wird, ist von einem kaputten nicht zu
unterscheiden. Er meldet mit einem Haken, dass er geprüft hat.

---

## Woran man merkt, dass es bricht

| Zu messen | Bricht, wenn |
|---|---|
| Orte, die die Registrierung nicht kennt | > 0 |
| Alter der letzten Erhebung | älter als zwei Takte |
| Kennzahlen, die aus gekürzten Listen stammen | > 0 — prüf das einmal bewusst nach |

---

## Vorlage

```yaml
# orte.yml
orte:
  - name: <projektname>
    pfad: <pfad>
    rolle: produkt | wissen | steuerung
    bereich: <bereich>
    erwartet: [regeln, uebergabe, wissen]
    bewusst_nicht: [eigene_regelquelle, automatik]
```

Dazu ein Erhebungsprogramm, das diese Datei liest und **nichts** außerhalb seines eigenen
Ortes verändert. Nur lesen.

**Im Profil vermerken:** was erhoben wird, in welchem Takt, wo das Ergebnis liegt.
