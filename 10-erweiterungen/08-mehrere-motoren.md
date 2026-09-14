# Erweiterung 8 · Mehrere Modelle nutzen

> **Anlass:** Ein Kontingent ist zum Engpass geworden, oder eine Aufgabenart läuft
> erkennbar besser woanders.

---

## Worum es geht

Mehrere Modelle oder Programme nebeneinander, jedes mit eigenem Zugang. Die Frage ist
nicht „welches ist besser", sondern **„welche Aufgabe gehört wohin"** — und die hat ein
klares Kriterium.

---

## Bestandsaufnahme — wenn schon etwas da ist

*Nur für den Durchlauf aus `INTEGRIEREN.md`. Beim Neuaufbau überspringen.*

**Sieh nach, bevor du redest:**

| Wonach | Wo typischerweise | Was der Fund bedeutet |
|---|---|---|
| Einstellungen, die ein Modell oder Programm festlegen | `--model`-Flags in Scripts, `settings.json`, Nightly-/CI-Konfiguration | Vorhanden → die Wahl ist schon einmal getroffen worden, nur vielleicht nicht bewusst |
| Mehr als ein Programm oder Konto im Einsatz | zwei CLI-Werkzeuge, zwei Abos, ein zweiter Anbieter-Zugang | Erst dann trifft dieses Modul überhaupt zu |
| Hinweise auf Kontingent-Probleme | Fehlermeldungen zu Rate-Limit/Kontingent in Logs, Notizen, Erinnerung | Sagt, ob Entscheidung B schon einmal real gebraucht wurde |
| Eine Stelle, die begründet, warum ein Modell für eine Aufgabenart gewählt wurde | Kommentare im Script, eine Notiz, ein Skill | Fehlt sie, ist die Wahl vermutlich geerbt, nicht entschieden |
| Weitergabe des Modells an Unteraufgaben | Scripts, die Subprozesse oder Teilagenten starten | Wird dort nichts gesetzt, läuft alles auf der Voreinstellung |

**Drei Ausgangslagen, die fast alles abdecken:**

- **Es läuft genau ein Motor, nie ein Engpass.** Dann ist das Modul verfrüht — es lohnt
  sich erst, wenn ein zweiter Zugang wirklich da ist oder ein Kontingent schon einmal eng
  wurde. Nichts vorschlagen, nur das Kriterium im Kopf behalten für später.
- **Mehrere Motoren sind im Einsatz, aber kein Script setzt das Modell ausdrücklich** —
  jede Sitzung und jeder Hintergrundlauf erbt einfach die Voreinstellung. Der lohnendste
  erste Schritt ist, das Modell **je Aufgabenart** einmal explizit hinzuschreiben, nicht
  global umzuschalten.
- **Ein Kontingent ist schon einmal ausgegangen und hat einen Lauf beendet.** Dann zuerst
  klären, ob „darf nicht mehr" (Zeitfenster) und „kann nicht mehr" (Kontingent) im Bestand
  überhaupt unterschieden werden — meist wird bei Erschöpfung gleich alles gestoppt,
  obwohl der zweite Motor noch könnte.

> **Der häufigste Fehlgriff an dieser Stelle:** Jemandem, der genau ein Modell nutzt,
> gleich eine Motoren-Architektur mit Positivliste und Phasenverteilung vorschlagen — das
> lohnt sich erst ab zwei echten Zugängen.

---

## Die Entscheidung — das Kriterium

**Nicht Bestenlisten. Entdeckbarkeit.**

> Ein anderer Motor darf ran, wo ein Fehlgriff **sofort kracht**. Wo er **still
> danebengreift** — Rechte, Grenzen zwischen Mandanten, Beträge, Migrationen von
> Bestandsdaten, Schemaänderungen —, bleibt es beim stärksten Modell.
>
> Im Zweifel beim stärksten.

Das Kriterium taugt auch für die Wahl **innerhalb** einer Modellfamilie: Wo das Ergebnis
ein belastbares **Urteil** sein muss, das niemand nachrechnet, nimm das stärkere. Wo es
Faktenarbeit ist, die sich prüfen lässt, nimm das günstigere.

---

## Die zweite Entscheidung — Programm oder Modell

**Werkzeuge gehören dem Programm, nicht dem Modell.** Wer ein zweites *Programm* einführt,
hat dort keine seiner Werkzeuge, keine seiner Riegel und eine andere Art, Regeln zu laden.
Wer nur ein zweites *Modell* im selben Programm nutzt, behält alles.

Das ist der Grund, warum ein anbieterfremdes Modell über eine kompatible Schnittstelle im
gewohnten Programm fast immer die bessere Wahl ist als ein zweites Programm.

---

## Was in jedem Fall gilt

### Das Modell ist eine Entscheidung, keine Erbschaft

**Gelernt an:** Abgegebene Sitzungen bekamen kein Modell mitgegeben und erbten deshalb die
interaktive Voreinstellung — das stärkste und teuerste, für alles. Eine Auswertung über
zwei Wochen zeigte: **99 % der Arbeit lief darauf**, und der Verbrauch hatte sich binnen
einer Woche verdreifacht. Entschieden hatte das nie jemand.

**Also:** Modell je Aufgabenart ausdrücklich setzen. Bei gefächerter Arbeit **je Phase**,
nicht global — in einem Fall bekamen 37 von 49 Teilagenten das teure Modell für reine
Recherchearbeit, mit **etwa fünffachem Verbrauch** und identischem Ergebnis.

Eine brauchbare Startverteilung:

| Phase | Modell |
|---|---|
| Recherche, Faktenarbeit, Quellenprüfung | das günstige |
| Gegenargumentieren, mechanisches Widerlegen | das günstige |
| Zusammenfassen, Strukturieren, Schreiben | das günstige |
| Die eine abschließende Urteilsentscheidung | das starke |

### Buchung und Auswahl sind zwei Fragen

„Wessen Kontingent fällt normalerweise" und „wer kann heute noch" sind verschiedene Dinge.
Wer sie zusammenlegt, bucht eine Ausweichnacht dem falschen Konto zu.

**Und ein einmal gewählter Motor wird durchgereicht**, nicht an der nächsten Stelle erneut
ermittelt — sonst kommt dort wieder die Voreinstellung heraus.

### Kontingentgrenzen gelten je Motor, nicht je Lauf

**Gelernt an:** Solange alles an einem Konto hing, war „Kontingent erschöpft" ein Grund,
den ganzen Lauf zu beenden. Mit einem zweiten Konto ist das falsch: In einem Zeitraum
endeten **41 von 676** Läufen des einen Motors am Kontingent, gegenüber **21 von 1.591**
beim anderen — und jeder dieser 41 Fälle beendete einen Lauf, in dem der andere noch
stundenlang hätte arbeiten können.

Unterscheide: **„darf nicht mehr"** (Zeitfenster zu, Tageslauf beendet) gilt für alle.
**„Kann nicht mehr"** (Kontingent) gilt nur für einen.

### Wohin ein fremder Motor darf, ist eine Positivliste

Nicht eine Liste der verbotenen Orte, sondern eine der erlaubten. **Beide Fehler sind
möglich, nur einer ist harmlos:** Bei einer Verbotsliste heißt „vergessen", dass etwas
Vertrauliches auf dem fremden Motor läuft. Bei einer Erlaubnisliste heißt es, dass eine
Aufgabe vertagt wird.

---

## Woran man merkt, dass es bricht

| Zu messen | Bricht, wenn |
|---|---|
| Verteilung der Arbeit auf Modelle | ein Modell hat über 90 % ohne Entscheidung |
| Läufe, die am Kontingent endeten, je Motor | steigt |
| Aufgaben auf einem fremden Motor außerhalb der Erlaubnisliste | > 0 |

---

## Vorlage

```yaml
# motoren.yml
motoren:
  - name: <motor>
    konto: <eigenes konto?>
    staerke: <wofür>
    erlaubte_orte: [<ort>, <ort>]      # Positivliste, nie Ausschlussliste
    erlaubte_arten: [<art>, <art>]

modell_je_phase:
  recherche: <günstig>
  widerlegen: <günstig>
  schreiben: <günstig>
  urteil: <stark>
```

**Im Profil vermerken:** welche Motoren, welches Kriterium, welche Erlaubnisliste.
