# Weiche 3 · Die Quelle der Wahrheit

> **Die Frage:** Wenn zwei Orte dasselbe behaupten und sich widersprechen — welcher hat
> recht, und wer sorgt dafür, dass man das noch weiß?

---

## Worum es geht

Jeder Arbeitsplatz entwickelt binnen Wochen Doppelablagen. Eine Aufgabenliste in Dateien
und eine im Projektwerkzeug. Wissen im Ordner und in der Wissensdatenbank. Was der Code
tut und was die Dokumentation behauptet. Eine Liste der Projekte im Skript und eine im
Kopf.

Das ist nicht vermeidbar und auch nicht schlimm — solange **vorher** feststeht, welcher
Ort die Wahrheit ist und welcher nur eine Ansicht davon. Steht es nicht fest, entsteht
kein Konflikt, sondern etwas Schlimmeres: **stilles Auseinanderlaufen.** Beide Seiten
sehen richtig aus. Nur eine ist es.

---

## Bestandsaufnahme — wenn schon etwas da ist

*Nur für den Durchlauf aus `INTEGRIEREN.md`. Beim Neuaufbau überspringen.*

**Sieh nach, bevor du redest:**

| Wonach | Wo typischerweise | Was der Fund bedeutet |
|---|---|---|
| Aufgabenliste UND ein Projektwerkzeug gleichzeitig | `TODO.md`/`backlog/` neben Jira, Linear, Notion, Trello | Beides vorhanden → Entscheidung A greift sofort. Prüf, welche Seite wirklich aktuell ist |
| Notizen/Wissen UND ein Wiki | `docs/`, `notes/` neben Confluence, Notion, Obsidian Publish | Beide gepflegt → Verdacht auf stilles Auseinanderlaufen. Eine Stichprobe zeigt schnell, ob sie noch übereinstimmen |
| Dokumentation zum Code | `README`, `docs/`-Ordner, Kommentare | Liegt sie im selben Repo → guter Ausgangspunkt. Liegt sie in einem getrennten Doku-System → der Trenntest aus Entscheidung A ist schwerer zu leben |
| Liste der Projekte, Repos oder Umgebungen | in einem Skript, in einer `README`, nur im Kopf | Mehrfach genannt → laut diesem Modul die teuerste Stelle. Zuerst prüfen |
| Sync- oder Export-Skripte zwischen zwei Systemen | `scripts/`, `migration/`, Workflow-Dateien mit „sync"/„export" im Namen | Vorhanden → Richtung prüfen. Läuft der Abgleich wirklich nur in eine Richtung? |
| Änderungsdatum gegen tatsächlichen Inhalt | letzte Bearbeitung einer Übersichts- oder Indexdatei | Ein frisches Datum beweist keine Vollständigkeit — das ist die bekannte Falle |

**Drei Ausgangslagen, die fast alles abdecken:**

- **Nur ein Ort pro Inhaltsart, kein zweites System.** Diese Weiche ist dann im Grunde
  erledigt. Trag die Tabelle aus Entscheidung A einfach ins Profil ein und geh weiter.
- **Zwei Orte ohne festgelegte Richtung** — etwa Notizen sowohl in Dateien als auch im
  Wiki, beide von Hand gepflegt. Lohnendster erster Schritt: für jede Inhaltsart einmal
  festlegen, wer gewinnt, und den Hinweis sichtbar in die Ansicht schreiben.
- **Zwei Orte mit einem bestehenden, aber unbeobachteten Sync.** Lohnendster erster
  Schritt: die Fehlerbehandlung darin lesen. Genau dort liegt laut diesem Modul der
  teuerste wiederkehrende Fehler.

> **Der häufigste Fehlgriff an dieser Stelle:** Eine Fehlermeldung des Sync-Mechanismus
> wird als Aussage über die Daten gelesen, statt als Aussage über die Verbindung.

---

## Entscheidung A — Wo liegt die Wahrheit

Für jede Art von Inhalt genau eine Antwort. Die bewährte Verteilung:

| Inhalt | Wahrheit | Ansicht | Warum so |
|---|---|---|---|
| **Wissen, Notizen, Konventionen** | Dateien neben der Arbeit | Jede Datenbank, jedes Wiki | Dateien sind versionierbar, durchsuchbar, überleben jedes Werkzeug |
| **Wie etwas funktioniert** | Der gebaute Gegenstand selbst | Die Dokumentation | Dokumentation altert, der Gegenstand nicht |
| **Rückstand, Aufgaben** | Eine Stelle, frei wählbar | Alles andere | Hier ist die Wahl offen — die Einheitlichkeit zählt mehr als der Ort |
| **Welche Projekte/Orte es gibt** | Eine einzige Registrierungsdatei | Jede Erwähnung in Prosa | Siehe unten, das ist die teuerste Stelle |
| **Was entschieden wurde** | Das Profil / die Entscheidungsdatei | Jede Umsetzung davon | Sonst ist die Entscheidung nach Monaten nicht mehr auffindbar |

> **Die Faustregel:** Wahrheit liegt dort, wo sie **versioniert**, **durchsuchbar** und
> **ohne Konto lesbar** ist. Alles, was nur über eine Oberfläche erreichbar ist, ist
> Ansicht — auch wenn es hübscher aussieht.

---

## Entscheidung B — In welche Richtung abgeglichen wird

**Eine Richtung. Immer.**

**Bringt:** Es gibt keine Konflikte, weil es nichts zu verschmelzen gibt. Die Ansicht wird
überschrieben, die Wahrheit nicht angefasst.
**Kostet:** Wer in der Ansicht etwas ändert, verliert es beim nächsten Abgleich. Das muss
allen klar sein, die dort schreiben können — und es muss in der Ansicht selbst stehen,
nicht nur in einer Regel.

**Die Versuchung, es beidseitig zu machen, ist groß und der Fehler teuer.** Beidseitiger
Abgleich braucht Konflikterkennung, Konfliktauflösung und eine Antwort auf „wer hat
zuletzt geschrieben" — das ist ein eigenes Produkt, kein Skript.

**Die dazugehörige Regel, die man ausdrücklich aufschreiben muss:** Nie in der Ansicht
anlegen, was es in der Wahrheit nicht gibt. Sonst entsteht ein Eintrag ohne Herkunft, und
der nächste Abgleich weiß nicht, ob er ihn löschen oder stehenlassen soll.

---

## Wenn es (noch) keinen zweiten Ort gibt

**Dann ist diese Weiche hier zu Ende.** Trag die Tabelle aus Entscheidung A ins Profil ein
und geh weiter. Alles Weitere — wie ein Abgleich technisch zusammengehalten wird, wer
aufräumt, was bei Fehlern passiert — gehört zu `10-erweiterungen/05-spiegel.md` und wird
gelesen, wenn tatsächlich ein zweites System dazukommt.

Die Entscheidung **jetzt** zu treffen lohnt trotzdem: Wer später einen Spiegel anschließt
und dann erst festlegt, wo die Wahrheit liegt, hat inzwischen an beiden Orten geschrieben.

---

## Was in jedem Fall gilt

### Ein Fehler ist eine Aussage über die Verbindung, nicht über die Daten

Das ist die wertvollste einzelne Zeile in diesem Modul. Drei getrennte, teure Vorfälle
gingen auf dieselbe Verwechslung zurück:

- Eine Fehlermeldung enthielt ein Wort, das nach „gelöscht" klang. Der Aufrufer schloss
  daraus „existiert nicht mehr" und legte neu an.
- Eine Abfrage scheiterte am Netz und gab „nichts gefunden" zurück. Der Aufrufer las das
  als „gibt es nicht" und legte neu an.
- Ein Schreibvorgang lief in eine Zeitüberschreitung, war aber drüben angekommen. Die
  automatische Wiederholung traf auf einen bereits veränderten Stand.

**Die Konsequenz, dreifach:**
1. Fehler tragen **Status und Code als Felder**, nicht als Text zum Lesen.
2. „Konnte nicht fragen" ist **keine Antwort**. Wirf den Fehler, statt ihn zu „nichts
   gefunden" einzuebnen.
3. **Schreibende Aufrufe sind nicht wiederholbar.** Wiederhol sie nur bei Überlastung,
   nie bei Zeitüberschreitung — eine Zeitüberschreitung heißt nicht „ist nicht passiert".

---

## Woran man merkt, dass es bricht

| Zu messen | Bricht, wenn |
|---|---|
| Stellen, an denen dieselbe Sache zweimal gepflegt wird | > 0 |
| Dokumentation, die zu geänderten Stellen gehört und nicht mitgezogen wurde | > 0 |
| Entscheidungen, die nur noch in ihrer Umsetzung stehen, nicht im Profil | > 0 |

*Sobald ein Abgleich mit einem zweiten System läuft, kommen dessen Messungen dazu — sie
stehen in `10-erweiterungen/05-spiegel.md`.*

---

## Vorlage

### Die Wahrheitstabelle für den eigenen Haushalt

```markdown
# Wo die Wahrheit liegt

| Inhalt | Wahrheit | Ansicht | Abgleich |
|---|---|---|---|
| Wissen und Notizen | <ort> | <ort> | <richtung, takt> |
| Aufgaben und Rückstand | <ort> | <ort> | <richtung, takt> |
| Wie etwas funktioniert | <ort> | <ort> | — |
| Welche Orte es gibt | <eine datei> | — | — |
| Entschiedenes | <profil> | — | — |

## Was das heißt

- In einer **Ansicht** geänderte Inhalte gehen beim nächsten Abgleich verloren.
- Nie in der Ansicht anlegen, was es in der Wahrheit nicht gibt.
- Bei Widerspruch gewinnt immer die Wahrheit — ohne Diskussion.
```

### Der Hinweis in der Ansicht selbst

Setz ihn sichtbar an jede gespiegelte Seite. Eine Regel, die nur in einer Datei steht,
erreicht niemanden, der die Ansicht öffnet:

> *Diese Seite ist ein Spiegel. Änderungen hier gehen beim nächsten Abgleich verloren.
> Die Quelle liegt in `<ort>`.*

---

## Die Lehren dahinter

- **Stilles Auseinanderlaufen ist schlimmer als ein Konflikt.** Beide Seiten sehen richtig
  aus; nur eine ist es.
- **Wahrheit liegt dort, wo sie versioniert, durchsuchbar und ohne Konto lesbar ist.**
- **Eine Richtung. Immer.** Beidseitiger Abgleich ist ein eigenes Produkt, kein Skript.
- **Was entschieden wurde, gehört an einen Ort** — sonst ist die Entscheidung nach Monaten
  nicht mehr auffindbar, nur noch ihre Folgen.
