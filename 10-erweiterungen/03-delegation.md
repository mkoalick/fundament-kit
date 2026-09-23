# Erweiterung 3 · Arbeit delegieren

> **Anlass:** Die eigene Sitzung wird zu voll, oder eine Aufgabe gehört erkennbar in einen
> anderen Zusammenhang als den, in dem man gerade steht.

---

## Worum es geht

Eine Aufgabe an eine eigene Sitzung im **richtigen Verzeichnis** zu geben, löst ein
Problem, das sonst nicht lösbar ist: Eine übergeordnete Stelle soll den Überblick haben,
aber nicht überall hineinschreiben. Die Antwort ist, das Schreiben an eine Sitzung
abzugeben, die am richtigen Ort steht — dort greifen deren Regeln, Riegel und Rechte.

Dasselbe Verfahren trägt auch die **parallele Arbeit**: mehrere Aufgaben gleichzeitig, von
mehreren Agenten, jeder in seinem Bereich.

---

## Bestandsaufnahme — wenn schon etwas da ist

*Nur für den Durchlauf aus `INTEGRIEREN.md`. Beim Neuaufbau überspringen.*

**Sieh nach, bevor du redest:**

| Wonach | Wo typischerweise | Was der Fund bedeutet |
|---|---|---|
| Mehrere gleichzeitig laufende Sitzungen oder Agenten | Terminal-Historie, mehrere offene Fenster oder Worktrees | Läuft das schon, fehlt meist nur die schriftliche Auftragsform, nicht die Praxis |
| Festgehaltene Aufträge | Chatverlauf, Notizen, Tickets | Fehlen sie, verschwindet jeder Auftrag mit der Sitzung, die ihn erteilt hat |
| Hintergrundläufe der aufrufenden Sitzung | `&`, `nohup`, Hintergrundprozesse in Skripten | Der teuerste Fund — er wird beim Sitzungsende mit abgeräumt, mitten in der Arbeit |
| Ein Zeitlimit je Aufgabe | Skripte, die Sitzungen starten | Fehlt es, kostet eine hängende Aufgabe alles, was danach kommen sollte |
| Ob mehrere Agenten schon dieselben Dateien anfassen | git-Historie, gleichzeitige Änderungen an denselben Pfaden | Das ist die eigentliche Fehlerquelle, nicht die Parallelität selbst |

**Zwei Ausgangslagen, die fast alles abdecken:**

- **Noch keine Delegation, eine Sitzung macht alles.** Lohnendster erster Schritt: die
  Auftragsvorlage — Umfang, Reihenfolge, Abbruchregel — einmal an einer einzelnen
  abgegebenen Aufgabe ausprobieren, bevor überhaupt parallelisiert wird.
- **Es wird schon delegiert oder parallel gearbeitet, aber ohne feste Auftragsform oder
  Zeitlimit.** Dann ist der lohnendste Schritt nicht der Aufbau, sondern die zwei Riegel,
  die am teuersten fehlen, ohne aufzufallen: ein Zeitlimit je Aufgabe und das Verbot, eine
  abgegebene Sitzung im Hintergrund der aufrufenden laufen zu lassen.

> **Der häufigste Fehlgriff an dieser Stelle:** Bei jemandem, der schon parallel arbeitet,
> ein komplett neues Delegationsverfahren vorschlagen — meist fehlen nur die zwei Riegel,
> nicht das Verfahren selbst.

---

## Die Entscheidung

**Wann wird gefächert?** Die Bedingung ist einfacher, als sie aussieht:

Überschneiden sich die **Arbeitsflächen**? „In die Quere kommen" heißt genau zweierlei —
dieselbe Datei, oder derselbe Ort beim Festschreiben.

- **Nein** → parallel starten, ohne Rückfrage.
- **Ja, auflösbar** → auflösen: je Agent eigene Dateien oder eigener Ort.
- **Ja, nicht auflösbar** → kurz fragen. Ein Satz reicht.

**Und immer aus einer Stelle koordiniert.** Mehrere unabhängige Sitzungen am selben
Gegenstand wissen nichts voneinander — das ist die Fehlerquelle, nicht die Parallelität
selbst.

---

## Was in jedem Fall gilt

### Mehr Agenten sind nicht automatisch besser

Der einzige zahlenmäßig belegte Vorteil paralleler Agenten stammt aus **Breitensuche** —
viele Orte gleichzeitig absuchen. Für Aufgaben mit geteiltem Zusammenhang und
Abhängigkeiten zwischen den Schritten, also die meisten Bau-Aufgaben, ist Aufteilen
ungeeignet.

Dazu zwei Beobachtungen, die man kennen sollte:

- **Ein prüfender Zweitagent meldet auch dann Mängel, wenn die Arbeit in Ordnung ist.**
  Er muss etwas finden, um seine Existenz zu rechtfertigen. Gegenmittel: ein **festes
  Bewertungsraster** statt eines pauschalen Gesamturteils. In einem Fall fanden fünf
  Prüfer mit Raster elf echte Abweichungen auf rund 500 Aussagen — beim erzeugenden
  Durchgang war alles „sauber" durchgerutscht.
- **Wiederkehrende Einzelentscheidungen werden einmal getroffen und dann mechanisch
  eingesetzt.** Zwei Agenten an derselben Aufgabe wählen für denselben Fall zwei
  verschiedene, beide plausible Lösungen — und an der Nahtstelle fällt das später nicht
  mehr auf.

### Jeder Subagent zahlt den vollen Startpreis neu

Ein Subagent bekommt nicht nur die eigentliche Teilaufgabe. Er lädt beim Start dieselben
Regeln, dieselbe Anweisungsdatei und dasselbe Gedächtnis wie die Hauptsitzung — ohne dass
sich Geschwister-Agenten davon irgendetwas teilen. **Gemessen: rund 77.000 bis 98.000 Token
je Subagent**, fast so viel wie eine ganze Hauptsitzung, allein für den Start.

**Also: erst schneiden, dann zählen.** Die Aufgabe wird zuerst in Pakete zerlegt, die sich
nicht überschneiden; die Zahl der Agenten folgt daraus und ist kein Ziel für sich. Nicht
feiner teilen als nötig — zwei Pakete, die dieselbe Datei lesen oder logisch aufeinander
aufbauen, sind ein Paket. Drei gut geschnittene Agenten schlagen zehn schlecht geschnittene.

**Wofür sich der Preis trotzdem lohnt:** Rohmaterial draußen halten, das sonst im Fenster
der Hauptsitzung landet und bei jedem weiteren Schritt erneut mitgelesen wird — Suchtreffer,
Dateiinhalte, Werkzeugausgaben. Gemessen an einem realen Lauf: Zehn Subagenten hielten
832.000 Zeichen Werkzeugausgabe draußen und lieferten 46.000 zurück, ein Verhältnis von 18:1.
Das gilt auch für reine Lesearbeit: Liegt die Antwort über viele Dateien verstreut, geht die
Suche an einen Subagenten — nicht weil sie dadurch schneller wäre, sondern weil seine
Werkzeugausgabe draußen bleibt.

**Das Modell ist dabei ein eigener Hebel:** Ohne ausdrückliche Angabe erbt jeder Subagent
das Modell der Hauptsitzung, meist das teuerste, auch für reine Faktenarbeit. Wie das Modell
je Aufgabenart oder Phase gesetzt wird, steht in `08-mehrere-motoren.md`.

### Nie im Hintergrund

Eine abgegebene Sitzung gehört **nicht** in einen Hintergrundlauf der aufrufenden Sitzung.
Endet die aufrufende, wird die abgegebene samt ihrer Prozessgruppe abgeräumt — mitten in
der Arbeit. Was bleibt, ist eine halbfertige Änderung am Zielort, die die nächste Sitzung
für fremde Arbeit hält und zu Recht nicht anfasst.

### Ein Zeitlimit je Aufgabe

Eine hängende Sitzung kostet sonst alles, was danach kommen sollte. Beim Reißen des Limits
muss die **ganze Prozessgruppe** enden, nicht nur der oberste Prozess.

### Der Auftrag muss ausführbar sein

Ein Auftrag, der Schreiben verlangt, während der Modus Schreiben verbietet, endet ohne
Fehler und ohne Wirkung. **Gelernt an:** Fünf Aufträge liefen je viermal über fünf Tage,
meldeten jedes Mal Erfolg und hatten keine Datei angefasst. Die erarbeiteten Ergebnisse
lagen in Protokolldateien, die niemand liest.

### Eine gestufte Freigabe muss ein echter Modus sein, kein Hinweis

„Nur planen" als Textanweisung ist keine Stufe. Und „nur planen" als Nur-Lesen-Modus ist
keine, wenn der Plan irgendwo hingeschrieben werden soll. **Die Stufe muss als tatsächliches
Recht durchgesetzt sein und trotzdem das erlauben, was der Auftrag verlangt** — sonst
entsteht eine Stufe, die vorgibt zu planen und strukturell nichts festhalten kann.

### Ein gestufter Auftrag statt eines ganzen

„Erreichst du nur Schritt 2, ist der Auftrag erfüllt." So hinterlässt ein Abbruch einen
Teilerfolg statt eines Fehlschlags.

### Eine Beispielliste wird als vollständige Liste gelesen

**Gelernt an:** Ein Auftrag nannte einige Fälle als Beispiel und schrieb ausdrücklich dazu:
„zähl selbst vollständig auf". Bearbeitet wurden **genau die genannten Beispiele**, mehrere
echte Fälle blieben liegen.

**Also:** Entweder eine geprüfte, vollständige Liste mitgeben — oder den Befehl, mit dem
die Liste **selbst erzeugt** wird. Nie ein Beispiel neben der Aufforderung zur
Vollständigkeit.

### Ein Agent sieht nur seinen Ausschnitt

Seine Aussage „das wird nirgends benutzt" gilt **nur lokal**. **Gelernt an:** Zwei Agenten
meldeten unabhängig voneinander dieselbe Konfigurationsdatei als funktionslos — sie
versorgte mehrere Vorgänge, die für beide unsichtbar waren.

**Also:** Vor jedem Löschen eine Gegenprüfung außerhalb des zugewiesenen Ausschnitts. Und
vor jedem endgültigen Schritt nach einem Umzug maschinell prüfen, dass **jede Quelle ein
bestätigtes Ziel hat** — nie dem Bewegungsprotokoll allein vertrauen.

### Prüf zuerst, ob es wirklich ein Übergriff war

**Gelernt an:** Ein unerwarteter Änderungsschritt zwischen zwei beauftragten Schritten
wurde als Grenzüberschreitung gewertet — er stammte von einer zweiten, unabhängig
laufenden, ordnungsgemäßen Tätigkeit. Bei parallelen Läufen sind Spuren nicht eindeutig
zuzuordnen.

### Was zurückkommt, ist nicht geprüft — auch nicht vom Prüfer

Die folgenden fünf Beobachtungen stammen aus echter Arbeit mit mehreren Agenten und
betreffen eine Fehlerklasse, die kein Exit-Code und keine Erfolgsmeldung berührt.

**Agenten erfinden beim Umformulieren Zusagen.** Beim Übertragen, Kürzen oder
Ausformulieren von Text entstehen systematisch zusätzliche Zusicherungen,
Hilfsbereitschaft und Verbindlichkeit, die im Original nicht standen. In einem Fall stand
in einem Entwurf ein Wort, das faktisch ein Zugeständnis zu einem strittigen Punkt gewesen
wäre. **Bei allem, was nach außen geht oder bindet, gehört ein eigener Prüfschritt auf
Wortebene dazu.**

**Belegstellen werden erfunden, und zwar plausibel.** Eine Massenprüfung fand ein
erfundenes Aktenzeichen und eine nicht existierende Norm — beide sahen völlig richtig aus.
Nur der **Direktabruf der Originalquelle** entlarvte sie. Plausibilitätsprüfung reicht
nicht.

**„Keine Aussage möglich" muss ausdrücklich erlaubt sein.** Sonst füllt ein Agent eine
Datenlücke mit einer plausibel klingenden Empfehlung. Schreib die Erlaubnis in den Auftrag.

**Manche Teilagenten liefern Platzhaltertext.** Bei einem breit gefächerten Lauf gaben
mehrere von vielen Beauftragten Füllmaterial statt Ergebnissen ab. Erst unabhängig
eingesetzte Gegenprüfer erkannten das. **Eine Fertigmeldung ist keine Lieferung.**

**Auch der Prüfer irrt.** In einem mehrstufigen Verfahren schlug ein Prüfagent vor, einen
korrekt berechneten Wert zu senken — er erinnerte einen Referenzwert falsch. Der Fehler
fiel erst beim Abgleich mit der Originalquelle auf. **Ein Korrekturvorschlag wird geprüft
wie ein Ergebnis**, auch wenn er amtlich klingt.

> **Und: Ein technisches Review ist kein Faktencheck.** Die beiden finden verschiedene
> Fehlerklassen und müssen als **getrennte Durchgänge** laufen. Ein spezialisierter
> Faktencheck fand wiederholt zweistellige Zahlen unbelegter Aussagen, die das technische
> Review zuvor nicht gemeldet hatte.

### Vage Aufträge werden interpretiert, nicht ausgeführt

Eine Vorgabe, die „sinngemäß" umgesetzt werden soll, wird anders gebaut als gemeint. Nur
**konkrete Zahlen, Werte oder Grenzen im Auftrag** erzwingen das Gemeinte. Wer an
„fast richtig"-Ergebnissen iteriert, hat meist keine Modell-, sondern eine
Auftragsformulierungs-Frage.

Das gilt auch in die andere Richtung: **Unspezifisches negatives Feedback genügt nicht
für einen zweiten Versuch.** Ohne den konkreten Grund oder ein Referenzbeispiel rät der
nächste Anlauf blind weiter — und trifft wieder daneben.

### Der Erfolg wird gemessen, nicht gemeldet

Siehe Erweiterung 4. Wenn eine Sitzung ihr eigenes Ergebnis beurteilt, ist das keine
Prüfung.

---

## Woran man merkt, dass es bricht

| Zu messen | Bricht, wenn |
|---|---|
| Abgegebene Aufgaben ohne jede Spur im Zielort | > 0 |
| Aufgaben, die das Zeitlimit rissen | steigt |
| Halbfertige Änderungen in Zielorten, älter als ein Tag | > 0 |

---

## Vorlage — der Auftragstext

```markdown
## Auftrag
<Was zu tun ist, in zwei bis vier Sätzen.>

## Umfang
Du darfst ändern: <genau diese Dateien/Bereiche>
Du darfst nicht: veröffentlichen · zurücksetzen, was du nicht selbst geändert hast ·
andere Bereiche anfassen

## Reihenfolge
1. <Schritt> — **danach festschreiben**
2. <Schritt> — danach festschreiben
3. Prüfen. Fehler in einem weiteren Schritt beheben.

Erreichst du nur Schritt <N>, ist der Auftrag erfüllt. Schreib dann den Stand
in <ort> und hör auf.

## Wenn du nicht weiterkommst
Schreib auf, woran es lag, und hör auf. Fang nichts Zweites an.
```

**Im Profil vermerken:** wer delegiert, wohin, mit welchen Grenzen, mit welchem Zeitlimit.
