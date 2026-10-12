# Erweiterung 11 · Sessions im Blick behalten

> **Anlass:** Mehrere Sessions laufen gleichzeitig, und die Frage „wer wartet gerade auf
> mich" lässt sich nicht mehr beantworten, ohne jedes Fenster einzeln durchzusehen.

---

## Worum es geht

Ab der zweiten, dritten parallelen Session passiert immer dasselbe: Eine davon stellt
eine Rückfrage oder meldet sich fertig, und das merkt niemand, weil gerade ein anderes
Fenster offen ist. Die Arbeit liegt, bis jemand zufällig hinschaut.

**Dieses Modul ist anders als die zehn davor.** Es bringt nicht nur eine Konvention mit,
sondern den Quelltext einer kleinen macOS-App - die **KI-Leiste**: eine Leiste direkt
unter der Menüleiste, über die volle Breite des größten Bildschirms, plus ein Symbol in der
Menüleiste. Jede laufende **Claude-Code**- und **Codex**-Session ist darin ein Chip mit
Kurzname und Modell-Kennung, gruppiert nach Git-Repository, in einer oder zwei Zeilen,
nie zum Scrollen. Ein Chip zeigt einen von fünf Zuständen: wartet auf dich, arbeitet,
fertig/bereit, blockiert, unklar. Ein Klick darauf zeigt Frage, Ergebnis und Modell im
Klartext. Bei einer Rückfrage und bei „fertig" kommt zusätzlich eine macOS-Mitteilung.

Genau weil hier etwas gebaut und auf dem Rechner installiert wird, gilt für dieses Modul
eine schärfere Zustimmungsregel als für die anderen zehn - dazu unten mehr.

---

## Bestandsaufnahme - wenn schon etwas da ist

*Nur für den Durchlauf aus `../INTEGRIEREN.md`. Beim Neuaufbau überspringen. Diese Liste
ist bewusst rein lesend gehalten - sie ist dieselbe, die `../EINSTIEG.md` Schritt 2 für
die stille Schnellprüfung benutzt.*

**Sieh nach, bevor du redest:**

| Wonach | Wo typischerweise | Was der Fund bedeutet |
|---|---|---|
| Betriebssystem | macOS-Version prüfen | Unter macOS 13 oder neuer trägt das Modul. Unter Windows oder Linux entfällt es ganz - siehe `../WINDOWS-UND-MAC.md` |
| Zahl gleichzeitig offener Sessions | Terminal- und Editor-Fenster mit Claude Code oder Codex, über die letzten Tage betrachtet | Nur eine Session zur Zeit → das Modul ist verfrüht. Zwei oder mehr, öfter als gelegentlich → genau der Anlass |
| Vorhandene Claude-Code-Einstellungen | `~/.claude/settings.json` | Vorhanden → vor dem Einrichten prüfen, ob dort schon eigene `hooks`-Einträge stehen, die nicht überschrieben werden dürfen |
| Vorhandene eigene Lösung für denselben Zweck | ein selbstgebautes Skript, das Sessions auflistet, die Statuszeile aus `09-arbeitsplatz.md` | Vorhanden und ausreichend → das Modul bringt nichts Neues, bleib bei der eigenen Lösung |
| Command Line Tools | `xcode-select -p` | Fehlen sie, ist das der erste Schritt vor jedem Bauen, nicht Teil dieses Moduls selbst |
| Freigaben, die die Platzierung braucht | Systemeinstellungen › Datenschutz & Sicherheit › Bedienungshilfen | Nur relevant, wenn später „Fenster darunter schieben" gewählt wird |

**Drei Ausgangslagen, die fast alles abdecken:**

- **Nie mehr als eine Session gleichzeitig.** Das Modul ist verfrüht - der Überblick
  kostet noch nichts, weil es nichts zu überblicken gibt. Nicht vorschlagen, nur merken,
  ab wann sich das ändert.
- **Mehrere Sessions laufen schon parallel, aber ohne jede Übersicht.** Genau der
  vorgesehene Fall. Lohnendster erster Schritt: einmal bauen, ohne Hooks einzutragen -
  dann zeigt die Leiste nur, was der Rückfall ohnehin schon findet, und die Person sieht
  vor der zweiten Zustimmung, ob ihr das etwas bringt.
- **Es gibt schon ein eigenes, kleineres Skript dafür.** Dann geht es nicht um Ersatz,
  sondern um einen Vergleich: Deckt die KI-Leiste etwas ab, das dem eigenen Skript fehlt
  (macOS-Mitteilungen, Gruppierung nach Repo, Codex zusätzlich zu Claude Code)? Nur dann
  lohnt sich der Umbau.

> **Der häufigste Fehlgriff an dieser Stelle:** Die App einrichten und im selben Zug die
> Hooks eintragen, weil „das gehört doch zusammen". Das sind zwei verschiedene Eingriffe
> mit unterschiedlicher Tragweite - der eine betrifft nur `~/Applications/`, der andere
> eine Datei, die die Person selbst pflegt.

---

## Die Entscheidung

Im Kern gibt es nur eine: **Wird gebaut und eingerichtet, oder nicht.** Daran hängen drei
kleinere Entscheidungen, die sich erst beim Einrichten klären müssen:

- **Stil** - „Ruhig" (nur Wartendes ist farbig, der Rest zurückhaltend) oder „Kräftig".
  Reine Geschmacksfrage, jederzeit nachträglich änderbar.
- **Platzierung** - „Fenster darunter schieben" (braucht die Freigabe Bedienungshilfen)
  oder „Über den Fenstern schweben" (braucht keine Sonderrechte). Wer die Freigabe nicht
  erteilen will oder kann, nimmt die zweite Option - funktional gleichwertig.
- **Quelle** - nur die offiziellen Hooks, oder zusätzlich der abschaltbare Rückfall über
  Claudes undokumentierte Session-Liste. Siehe dazu den nächsten Abschnitt.

---

## Was in jedem Fall gilt

### Dokumentierte Quelle vor stiller Annahme

Für Claude Code gibt es offizielle, dokumentierte **Hooks**
(https://code.claude.com/docs/en/hooks): `SessionStart`, `UserPromptSubmit`,
`PreToolUse` (nur für `AskUserQuestion`), `PostToolUse`, `Notification`, `Stop`,
`SessionEnd`. Das ist die Quelle, auf die sich die Leiste in erster Linie stützt - sie
ist vom Hersteller zugesichert und bleibt es über Versionen hinweg.

Der **Rückfall** - Claudes interne, **undokumentierte** Session-Liste `~/.claude/sessions`
plus das Ende des Transkripts - ist ausdrücklich abschaltbar. Er kann sich mit jeder
Claude-Version ändern, ohne Vorwarnung. Bricht er, fehlen nur die Fälle, die er abdeckt;
die Hook-gestützte Anzeige bleibt davon unberührt. Genau deshalb ist er ein Rückfall und
keine zweite Hauptquelle.

Codex hat **keine** Hooks. Dort liest die Leiste die Rollout-Dateien in
`~/.codex/sessions` und die offenen Dateien des laufenden Prozesses - bestmöglich, nicht
zugesichert. Eine `codex exec`-Session wird deshalb gar nicht angezeigt.

### Kein Netzwerk, kein Polling

Die App sendet nichts und enthält keinen Netzwerk-Code. Sie reagiert auf Dateiereignisse
und prüft nur alle zehn Sekunden per Takt, ob eine Session noch lebt - das ist keine
Abfrageschleife über den Zustand, sondern ausschließlich eine Lebendprüfung.

### Eine fremde Datei wird nie einfach überschrieben

Das Eintragen der Hooks ändert `~/.claude/settings.json` - eine Datei, die der Person
gehört und die sie selbst weiterschreibt. Der Riegel dahinter hält sich an dieselben vier
Eigenschaften, die `../00-kern/02-regeln-und-grenzen.md` für jeden Riegel verlangt:

- Er **ergänzt nur eigene Einträge**, erkennbar am Kommentar `# ki-leiste-hook` am Ende
  des Befehls, und lässt jedes andere Byte der Datei unverändert - das wird vor dem
  Schreiben geprüft, nicht erst danach vermutet.
- Er legt **vorher eine Sicherung** an, unter
  `~/Library/Application Support/com.koalick-capital.ki-leiste/backups/`.
- Er **verweigert das Schreiben**, wenn die Datei kein gültiges JSON ist, statt etwas zu
  reparieren, was er nicht versteht.
- Entfernen nimmt **genau diese** Einträge wieder heraus, nicht mehr und nicht weniger.

Claude Code lädt Hook-Änderungen live, ohne Neustart. Ein einzelner Hook-Aufruf kostet
rund 16 Millisekunden.

### Der Einbau ist zweistufig - und die Hooks sind eine eigene Zustimmung

Für den Einbau gilt derselbe Ablauf wie für jedes andere Modul im Durchlauf
(`../INTEGRIEREN.md`): Bestandsaufnahme, was das Modul mitbringt, Vorschlag, Zustimmung
abwarten, erst dann einbauen. Bei diesem Modul zerfällt der letzte Schritt in zwei Teile,
die **getrennt** freigegeben werden:

**Erste Zustimmung - bauen und einrichten:**

1. Command Line Tools sicherstellen: `xcode-select --install`, falls noch nicht da. Kein
   Xcode-Projekt nötig.
2. Bauen: `sh ~/fundament-kit/vorlagen/ki-leiste/scripts/build.sh` - rund eine Minute,
   erzeugt `vorlagen/ki-leiste/build/KI-Leiste.app`.
3. Optional prüfen: `sh ~/fundament-kit/vorlagen/ki-leiste/Tests/run.sh`.
4. Nach `~/Applications/` kopieren. Lokal gebaut heißt: kein Download-Quarantäne-Vermerk,
   keine Gatekeeper-Warnung.
5. App öffnen - das öffnet nur ein Symbol in der Menüleiste, kein Fenster.
6. Platzierung wählen (siehe „Die Entscheidung" oben).
7. Mitteilungen erlauben über den Menüpunkt „Mitteilungen erlauben …".
8. Autostart nur, wenn gewünscht: Einstellungen, Reiter „Verhalten", „Bei der Anmeldung
   öffnen". Bei einer unsignierten App kann das scheitern - dann zeigt die Einstellung
   selbst den Fehler, und der Rückweg ist ein eigener LaunchAgent (siehe
   `09-arbeitsplatz.md`, Abschnitt „Sitzungen überleben den Neustart") oder die App von
   Hand zu starten.

Damit zeigt die Leiste bereits etwas - gestützt auf den Rückfall und auf das, was Codex
ohne Hooks liefert. Das reicht, um zu beurteilen, ob sich der zweite Schritt überhaupt
lohnt.

**Zweite, eigene Zustimmung - die Hooks eintragen:**

Erst danach, als eigens benannter Schritt: über den Knopf „Hooks installieren" in
Einstellungen › Quellen, über den Menüpunkt „Claude-Code-Hooks einrichten …", oder auf der
Kommandozeile:

```
"~/Applications/KI-Leiste.app/Contents/MacOS/ki-leiste-hook" hooks install
```

Status prüfen mit `hooks status`, entfernen mit `hooks uninstall` oder dem Knopf „Hooks
entfernen". Erst ab hier zeigt die Leiste auch die dokumentierten Zustände - wartet,
arbeitet, fertig, blockiert, unklar - zuverlässig, statt nur aus dem Rückfall geraten zu
müssen.

**Warum getrennt:** Der erste Schritt betrifft nur `~/Applications/` und den eigenen
Datenordner der App. Der zweite ändert eine Datei, die die Person selbst schreibt und von
der andere Werkzeuge ebenfalls lesen. Wer dafür nur einmal gefragt wird, merkt eine
unerwartete Zeile darin erst beim nächsten eigenen Blick in die Datei - zu spät, um noch
„nein" zu sagen.

### Ausdrücklich melden statt raten

Ein Turn-Ende allein heißt in der Leiste nur „bereit", nicht „fertig" - die Leiste zeigt
beides gelb, eine Mitteilung kommt beim bloßen Turn-Ende aber erst nach mindestens
60 Sekunden Arbeit (einstellbar). „Fertig" gibt es nur auf ausdrückliche Meldung, und
ausdrücklich heißt: eine Zeile

```
SESSION_REPORT: {"status":"done","result":"…"}
```

(oder `"status":"waiting"` mit `"question"`, oder `"blocked"`). Das ist dieselbe Lehre wie
in `../00-kern/04-uebergabe.md`: **Wer abschließt, meldet ausdrücklich** - ein bloßes
Verstummen ist keine Übergabe.

### Der Rückweg

Entfernen, in dieser Reihenfolge: zuerst die Hooks entfernen (Knopf oder
`hooks uninstall`), dann die App beenden, dann `~/Applications/KI-Leiste.app` löschen,
optional zusätzlich den Datenordner
`~/Library/Application Support/com.koalick-capital.ki-leiste`.

**Grenzen, die dabei bleiben:**

- Nur macOS - kein Gegenstück unter Windows, siehe `../WINDOWS-UND-MAC.md`.
- Codex-Freigabedialoge werden nicht erkannt.
- Die undokumentierte Claude-Liste kann sich mit jeder Version ändern - dann fehlen nur
  die Rückfall-Fälle, nicht die Hook-gestützte Anzeige.
- Fenster schieben klappt nicht bei Fenstern, die ihre Größe nicht ändern lassen, und
  nicht im Vollbild. „Über den Fenstern schweben" ist dann der Ausweg.
- Autostart über „Bei der Anmeldung öffnen" kann bei einer unsignierten App scheitern -
  siehe oben, Schritt 8.

---

## Woran man merkt, dass es bricht

| Zu messen | Bricht, wenn |
|---|---|
| Bytes in `~/.claude/settings.json` ohne den Kommentar `# ki-leiste-hook`, die sich nach einer Installation trotzdem geändert haben | > 0 |
| Sicherungen unter `backups/`, die nach einer Installation fehlen | > 0 |
| Chips, die „wartet auf dich" zeigen, obwohl die Frage längst beantwortet ist | öfter als gelegentlich |
| Netzwerkverbindungen der App | > 0 - sie soll keine haben |

---

**Im Profil vermerken:** ob eingebaut wurde, mit welcher Platzierung und welchem Stil, ob
die Hooks eingetragen sind oder nur der Rückfall läuft - und falls bewusst nicht
eingebaut, der Grund (meist: nie mehr als eine Session gleichzeitig).
