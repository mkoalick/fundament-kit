# Erweiterung 10 · Web und Medien

> **Anlass:** Es entstehen Websites oder es sollen Bilder und Videos in eine Seite.

---

## Worum es geht

Ein Randgebiet, das nur relevant ist, wenn es zutrifft. Drei Dinge daraus sind aber
allgemeiner, als sie aussehen.

---

## Bestandsaufnahme — wenn schon etwas da ist

*Nur für den Durchlauf aus `INTEGRIEREN.md`. Beim Neuaufbau überspringen.*

**Sieh nach, bevor du redest:**

| Wonach | Wo typischerweise | Was der Fund bedeutet |
|---|---|---|
| Projektordner mit Web-Code | `html`, `css`, Frontend-Ordner, `kunden/`, `sites/` | Erst dann trifft dieses Modul überhaupt zu |
| Medien-Rohdateien | unbearbeitete Bilder/Videos, große Dateien ohne Zweitfassung | Zeigt, ob die Formatfrage schon ein Problem ist oder noch nicht |
| Eine vorhandene Design- oder Schwellenprüfung | Kontrastwerte, Tippzielgrößen, Abstandsraster, ein Lint dafür | Fehlt sie meist — Design wird dann nach Gefühl beurteilt |
| Hosting- oder Deploy-Konfiguration | Build-Skripte, Deploy-Ziel, Hosting-Doku | Gehört zum Projekt, nicht zum Fundament — nur der Vollständigkeit halber prüfen |
| Spuren früherer Web-/Medienarbeit | Ordnernamen, Notizen, Commit-Historie | Fehlen sie ganz, trifft das Modul nicht zu |

**Drei Ausgangslagen, die fast alles abdecken:**

- **Es gibt weder eine Website noch Medienarbeit im Bestand.** Dann trifft das Modul
  schlicht nicht zu — sag das so und geh weiter. Das ist keine Lücke, die geschlossen
  werden müsste.
- **Es gibt eine Website, aber keine Schwellenprüfung** — Kontrast, Tippziele, Bewegung,
  Anzahl Schriftgrößen. Der lohnendste erste Schritt ist, die Zahlen-Prüfung einmal gegen
  den bestehenden Stand laufen zu lassen, bevor irgendetwas am Design geändert wird, nicht
  danach.
- **Es werden schon Bilder oder Videos eingebunden, aber ohne Zweitfassungen oder ein
  Werkzeug dafür.** Bevor daraus ein Werkzeug (Erweiterung 7) wird, zuerst die Frage vor
  der Frage stellen: Muss es überhaupt ein Video sein, oder tut es eine Bildfolge oder
  reines CSS zum Bruchteil der Ladezeit?

> **Der häufigste Fehlgriff an dieser Stelle:** Das ganze Modul durchgehen, obwohl gar
> keine Website existiert — dann kostet es nur Lesezeit, ohne dass am Ende etwas zu
> entscheiden war.

---

## Was übertragbar ist

### Design wird gegen Schwellen geprüft, nicht gegen Geschmack

Eine Prüfung, die **Zahlen** misst — Kontrastverhältnis, Größe von Tippzielen, Einhaltung
eines Abstandsrasters, Anzahl verwendeter Schriftgrößen, Anzahl verwendeter Farben, Dauer
und Menge von Bewegung — macht aus „gefällt mir nicht" eine überprüfbare Aussage. Das
funktioniert unabhängig vom Geschmack und ist der teilbarste Teil dieses Gebiets.

Dazu gehört eine zweite, ungewöhnlichere Liste: **die typischen Zeichen generischer
KI-Gestaltung.** Wer eine KI gestalten lässt, bekommt ohne solche Gegenprüfung sehr
zuverlässig dasselbe Ergebnis wie alle anderen.

### Die Frage vor der Frage

Bevor ein Video eingebaut wird: Muss es überhaupt eines sein? Eine Bildfolge, ein
gerenderter Effekt oder reine Gestaltungsregeln liefern oft dasselbe bei einem Bruchteil
der Ladezeit. Diese Frage einmal ausdrücklich zu stellen, spart mehr als jede
Optimierung danach.

### Medien brauchen mehrere Fassungen, und das ist Handarbeit für ein Werkzeug

Ein Video für eine Seite heißt in der Praxis: zwei bis drei Formate, ein Standbild, eine
Fassung für kleine Bildschirme, das passende Markup. Das ist der klassische Fall für ein
Werkzeug (Erweiterung 7) — wiederholt sich, hat Schritte, hat einen erkennbaren Anlass.

---

## Was nicht übertragbar ist

Alles, was an einem bestimmten Server, einer bestimmten Hosting-Form oder einer bestimmten
Werkzeugkette hängt. Wer das übernimmt, übernimmt fremde Infrastruktur.

**Die Entscheidung über den Technikstapel gehört zum Projekt, nicht zum Fundament.** Ein
Fundament, das vorschreibt, womit Websites gebaut werden, ist beim zweiten Projekt im Weg.

---

## Woran man merkt, dass es bricht

| Zu messen | Bricht, wenn |
|---|---|
| Seiten, die die Schwellenprüfung nicht bestehen | > 0 vor einer Abnahme |
| Mediendateien ohne die nötigen Zweitfassungen | > 0 |

---

**Im Profil vermerken:** ob das Gebiet überhaupt zutrifft, und wenn ja, welche Schwellen
gelten.
