# Erweiterung 7 · Eigene Werkzeuge bauen

> **Anlass:** Derselbe Ablauf wurde zum dritten Mal von Hand erklärt.

---

## Worum es geht

Ein Werkzeug — je nach Programm „Skill", „Command", „Prompt-Vorlage" — ist ein Ablauf, der
sich lädt, wenn er gebraucht wird, und sonst nichts kostet. Das ist die dritte Form aus
Weiche 2, neben Regel und Riegel.

**Die Abgrenzung entscheidet über den Nutzen:** Was immer gilt, ist eine Regel. Was nur bei
einer bestimmten Tätigkeit gilt, ist ein Werkzeug. Wer das verwechselt, hat entweder einen
überfüllten Startkontext oder ein Werkzeug, das nie auslöst.

---

## Bestandsaufnahme — wenn schon etwas da ist

*Nur für den Durchlauf aus `INTEGRIEREN.md`. Beim Neuaufbau überspringen.*

**Sieh nach, bevor du redest:**

| Wonach | Wo typischerweise | Was der Fund bedeutet |
|---|---|---|
| Ordner mit fertigen Abläufen | `.claude/skills/`, `.cursor/commands/`, `prompts/`, `commands/`, lose `.md`-Dateien mit Ablaufschritten | Es gibt schon Werkzeuge — die Frage ist, ob sie auch laden |
| Eine Beschreibung je Ablauf | Kopfbereich oder erste Zeile der Datei | Fehlt sie oder ist sie vage, ist genau das der Grund, warum ein Werkzeug „nie auslöst" |
| Dieselbe Anleitung an mehreren Stellen | Notizen, README, Chat-Verlauf, ein zweites Skill mit ähnlichem Namen | Kopien driften auseinander — welche gilt? |
| Ein „Wann nicht"-Hinweis | Ende der Beschreibung, eigener Abschnitt | Fehlt fast immer, auch wenn das Werkzeug sonst gut ist |
| Spuren, ob ein Werkzeug je genutzt wurde | Protokolle, Erwähnungen in Sitzungen, schlicht: Erinnerung | Ungenutzt und unauffindbar sind hier oft dasselbe Problem |

**Zwei Ausgangslagen, die fast alles abdecken:**

- **Es gibt noch kein einziges Werkzeug, aber derselbe Ablauf wurde erkennbar schon
  mehrfach erklärt** — in Notizen, in Sitzungen, im Kopf. Der lohnendste erste Schritt ist
  nicht, gleich mehrere Werkzeuge zu bauen, sondern genau den einen häufigsten Ablauf zu
  fassen, mit einer Beschreibung, die wie eine Suchanfrage klingt, und einem
  „Fallstricke"-Abschnitt für das, was beim letzten Mal schiefging.
- **Es gibt schon Werkzeuge, aber sie werden kaum geladen oder existieren doppelt.** Dann
  ist der erste Schritt keine Neuentwicklung, sondern eine Bestandsprüfung: Welche
  Beschreibung ist so vage, dass sie nie trifft? Welche Anleitung steht an zwei Stellen,
  und welche davon ist die Quelle?

> **Der häufigste Fehlgriff an dieser Stelle:** Ein neues Werkzeug vorschlagen, obwohl
> drei ähnliche schon existieren — und die eigentliche Lücke nur eine schärfere
> Beschreibung ist.

---

## Die Entscheidung

**Wann lohnt sich eines?** Drei Bedingungen, alle drei:

1. Der Ablauf wiederholt sich (Faustregel: dreimal).
2. Er hat **Schritte**, nicht nur eine Anweisung. Für einen Einzeiler genügt eine Regel.
3. Der Anlass ist **erkennbar** — es gibt Wörter, bei denen klar ist, dass es dran ist.

Fehlt die dritte, wird das Werkzeug gebaut und nie geladen. Das ist der häufigste
Fehlschlag in diesem Bereich, und er fällt nicht auf: Ein Werkzeug, das nie auslöst,
meldet sich nicht.

---

## Was in jedem Fall gilt

### Die Beschreibung ist wichtiger als der Inhalt

Sie entscheidet, ob das Werkzeug überhaupt geladen wird. Sie gehört geschrieben wie eine
Suchanfrage: **Welche Wörter benutzt jemand, der das braucht?** Nicht, wie der Ablauf
heißt — sondern wie das Problem klingt.

Nenn ausdrücklich auch, **wann es nicht gilt**. Ein Werkzeug, das zu oft auslöst, wird
ebenso abgeschaltet wie eines, das nie auslöst.

### Werkzeuge driften wie Regeln — und das wiegt schwerer

**Gelernt an:** Drei von sieben verteilten Werkzeugen standen auf einem älteren Stand als
ihre Quelle. Eines davon wies an, eine Datei **direkt** zu bearbeiten — genau das, was die
Übergabe-Konvention wegen des Last-Write-Wins-Problems verbietet. Eine Regeltextprüfung
hätte davon nichts gesehen: Die falsche Anweisung stand in keiner Regel.

**Also:** Werkzeuge haben eine Quelle, und Kopien werden gegen sie gemessen — inhaltlich.

### Drei Fehler, die Prüf- und Verdichtungswerkzeuge regelmäßig machen

**Ein Werkzeug darf seinen eigenen Bericht nicht als Fundstelle zählen.** Ein
Verweis-Prüfer zählte die Erwähnungen defekter Verweise in seinem eigenen vorherigen
Bericht als neue Treffer — Befunde, die niemand beheben konnte, ohne den Bericht zu
zerstören.

**Wenn ein Budget zur Kürzung zwingt, sind „ob gekürzt wird" und „was zuerst" zwei
getrennte Entscheidungen.** Eine Fassung, die das Budget stur in Dokumentreihenfolge
füllte, ließ eine kleine Kategorie am Anfang systematisch eine größere, wichtigere weiter
unten verdrängen. Die Information verschwand nicht, weil sie unwichtig war, sondern weil
sie an der falschen Stelle stand.

**Eine geprüfte Ausnahme braucht eine Obergrenze, wenn das Gemessene wachsen kann.** Eine
Dublette bleibt eine Dublette; eine Datei wächst. Eine Ausnahme ohne Obergrenze macht das
Werkzeug dort **für immer blind**.

### ⚠️ Unbekannte Argumente müssen einen Abbruch auslösen, nicht ignoriert werden

**Der gefährlichste Einzelfehler in diesem Bereich.** Ein Verteilskript kannte genau ein
Prüf-Flag. Bei jedem anderen — auch bei einem plausibel klingenden, das anderswo im selben
System tatsächlich existierte — ignorierte es das Argument stillschweigend und führte den
**vollen Schreib-Lauf** über mehrere maschinenweite Dateien aus.

**Ein vermeintlicher Probelauf war in Wahrheit ein echter Lauf.** Ob dabei etwas
kaputtging, entschied der Zufall.

**Also:** Jedes Werkzeug, das einen Schreib- und einen Lesemodus hat, bricht bei einem
unbekannten Argument ab. Und der **sichere** Modus ist die Voreinstellung, nie der
schreibende.

### Eine Korrektur gehört ins Werkzeug, nicht in eine Sitzungsnotiz

Eine Lösung, die nur im Gedächtnis oder in einer Notiz steht, hilft der Sitzung, die sie
zufällig geladen hat. **Gelernt an:** Eine Korrektur zu einem falschen Pfad stand längst
in einer Notiz, während das zugehörige Werkzeug weiterhin die alte, falsche Behebung
empfahl. Jede neue Sitzung entdeckte denselben Fehler neu und behob ihn neu falsch.

Der Abschnitt „Fallstricke" im Werkzeug ist der Ort dafür — er ist der Grund, warum es ein
Werkzeug ist und keine Regel.

### Ein Werkzeug hat einen Rückweg

Was es anlegt, muss auch wieder zu entfernen sein. Schreib das in das Werkzeug hinein.

### Werkzeuge sind meist an ihr Programm gebunden, nicht an das Modell

Wer das Modell wechselt, behält seine Werkzeuge. Wer das Programm wechselt, verliert sie.
Das ist bei der Wahl eines zweiten Motors der entscheidende Punkt — siehe Erweiterung 8.

---

## Woran man merkt, dass es bricht

| Zu messen | Bricht, wenn |
|---|---|
| Werkzeuge, die seit Monaten nie geladen wurden | > 0 → Beschreibung überarbeiten oder löschen |
| Werkzeugkopien gegen ihre Quelle, inhaltlich | Unterschied > 0 |
| Werkzeuge ohne Beschreibung, wann sie **nicht** gelten | > 0 |

---

## Vorlage

```markdown
---
name: <kurzer-name>
beschreibung: >
  <Was es tut, in einem Satz.> Einsetzen bei: <die Wörter, die jemand
  benutzt, der das braucht — großzügig aufzählen>. NICHT für: <die
  Nachbarfälle, bei denen es nicht gelten soll>.
---

# <Name>

## Wann das hier gilt
<Ein Absatz. Und wann nicht.>

## Ablauf
1. <Schritt>
2. <Schritt>

## Fallstricke
<Was beim letzten Mal schiefging. Der wertvollste Abschnitt —
er ist der Grund, warum das ein Werkzeug ist und keine Regel.>

## Rückweg
<Wie man rückgängig macht, was hier angelegt wurde.>
```

**Im Profil vermerken:** wo Werkzeuge liegen, wie sie verteilt werden, wie Kopien gemessen
werden.
