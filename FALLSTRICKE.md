# Fallstricke

*Zum Nachschlagen, nicht am Stück zu lesen. Die KI öffnet diese Datei, wenn eine
Entscheidung ansteht, zu der es hier etwas gibt — oder wenn jemand fragt, warum eine
Empfehlung so lautet, wie sie lautet.*

*Alles hier ist bezahlt worden. Die Zahlen sind echt.*

---

## Teil 1 — Die Muster, die immer wiederkommen

**Lies nur diesen Teil, wenn du wenig Zeit hast.** Die Einzelfälle darunter sind
Belege — das hier sind die Formen, in denen derselbe Fehler immer wieder auftritt.

### Muster 1 · Der stumme Wächter

> **Eine Prüfung, die einen Ort nicht kennt, ist dort nicht falsch — sie ist stumm.
> Sie meldet null. Und null liest sich wie „alles in Ordnung".**

Das häufigste Muster überhaupt, in einem einzigen Haushalt mindestens siebenmal
aufgetreten. Die Variante, die am meisten kostete: Eine Erhebung erkannte Wissensflächen
an einem Merkmal, das nicht die Zugehörigkeit anzeigte, sondern eine Gewohnheit. Als
beides auseinanderfiel, fehlte eine Fläche mit **433 Notizen und 1.896 Verweisen**
vollständig in jeder Auswertung. Auffallen konnte das nicht: Niemand zählt nach, was gar
nicht auftaucht, und alle Prüfungen meldeten dazu null.

**Wie man es verhindert:**
- Die Liste der Orte steht an **einer** Stelle, nicht in jedem Werkzeug neu.
- Eine leere Ortsliste ist selbst ein Befund — sonst ist die Ableitung stumm statt falsch,
  also genau der Fehler, den sie beheben soll.
- Bei jeder gemeldeten Null einmal fragen: Ist da wirklich nichts, oder schaut da niemand
  hin?

### Muster 2 · Die Liste, die es dreimal gibt

> **Nicht eine Liste war falsch gepflegt. Es gab sie dreimal.**

Eine Verteilliste stand im Verteilprogramm (vier Einträge), in der Prüfung (drei) und
faktisch im Ladefenster (sechs). Folge: Zwei Regeln erreichten die anderen Werkzeuge
**nie** — darunter ausgerechnet die, die das Schreiben an der Ablage-Wahrheit vorbei
verbot. Bemerkenswert dabei: Der Kommentar im Programm warnte ausdrücklich vor genau
diesem Fallstrick, und die Liste darunter war trotzdem schon wieder zwei Einträge im
Rückstand.

**Wie man es verhindert:** Ableiten statt führen. Was an einer Stelle schon steht, wird
nicht an einer zweiten wiederholt.

### Muster 3 · Der Fehler als Aussage über die Daten

> **Ein Fehler ist eine Aussage über die Verbindung, nicht über die Daten.**

Drei getrennte Vorfälle, dieselbe Verwechslung: Eine Fehlermeldung enthielt ein Wort, das
nach „gelöscht" klang → neu angelegt. Eine Abfrage scheiterte am Netz und gab „nichts
gefunden" zurück → neu angelegt. Ein Schreibvorgang lief in die Zeitüberschreitung, war
aber angekommen → wiederholt.

**Wie man es verhindert:** Fehler tragen Status und Code als **Felder**, nicht als Text
zum Lesen. „Konnte nicht fragen" ist keine Antwort. Schreibende Aufrufe werden nicht
automatisch wiederholt.

### Muster 4 · Der Deckel, der zum Zähler wurde

> **Ein Deckel darf die Liste kürzen, nie den Zähler.**

Eine Anzeige kürzte eine Liste auf fünfzehn Zeilen. Die Kennzahl daneben nannte deren
**Länge** als „offene Punkte". Acht von dreizehn Bereichen rissen den Deckel — also stand
bei jedem davon exakt „15 offen". Die eine Zahl, die beziffern sollte, wie viel auf
jemandem liegt, war ein Anzeigeparameter. Real waren es **2.588**.

### Muster 5 · Die Regel, die niemand einhalten kann

> **Ein Auftrag, der etwas verlangt, das die Umgebung verbietet, endet ohne Fehler und
> ohne Wirkung.**

Ein Auftragstyp verlangte, ein Ergebnis in eine Datei zu schreiben — lief aber in einem
Modus, der Schreiben verbot. Fünf Aufträge liefen je viermal über fünf Tage, meldeten
jedes Mal Erfolg und hatten keine einzige Datei angefasst. Die erarbeiteten Ergebnisse,
darunter ein verifizierter Sicherheitsbefund, lagen in Protokolldateien, die niemand liest.

**Verwandt:** Ein Abschluss, der an einem Feld gemessen wird, das die betreffende
Aufgabenart nie erreicht. **40 von 40** Durchläufen standen als unfertig in der Bilanz,
jeder mit erledigter Arbeit.

### Muster 6 · Der Wächter, der die Mehrheit falsch rot färbt

> **Ein Wächter, der die Mehrheit eines Laufs zu Unrecht bemängelt, trainiert genau das
> Wegsehen, gegen das er gebaut wurde.**

Eine Grenzprüfung verlangte etwas, das nur ein einziger Auftragstyp gefordert hatte. **11
von 16 Läufen** standen als „Grenze verletzt" im Bericht — alle mit erledigter Arbeit.

**Die Geschwister dieses Musters:**
- Ein Statuswert, der wochenlang rot ist, weil drei Einträge dauerhaft scheitern, sagt
  irgendwann gar nichts mehr.
- Ein geprüfter Befund, der nicht verstummen kann, wird beim dritten Mal überblättert.
- Ein Wächter, dessen Hinweistext wie eine eingeschleuste Anweisung klingt, wird zu Recht
  verworfen. **Ein Wächter, dem niemand glaubt, ist schlechter als keiner.**

### Muster 7 · Die Erbschaft statt der Entscheidung

> **Was nicht ausdrücklich gewählt wird, wird geerbt — und niemand merkt es.**

Abgegebene Sitzungen bekamen kein Modell mitgegeben und erbten die interaktive
Voreinstellung: das stärkste und teuerste, für alles. **99 % der Arbeit** lief darauf, der
Verbrauch verdreifachte sich binnen einer Woche. Entschieden hatte das nie jemand.

In derselben Familie: Bei gefächerter Arbeit bekamen **37 von 49** Teilagenten das teure
Modell für reine Recherche — etwa fünffacher Verbrauch, identisches Ergebnis.

### Muster 8 · Die Reihenfolge, die bei Abbruch alles verliert

> **Erst sichern, dann prüfen.**

Die saubere Reihenfolge — bauen, prüfen, aufräumen, sichern — verliert bei einem Abbruch
alles, weil der Abbruch statistisch in die lange Prüfphase fällt und nicht in den kurzen
letzten Schritt. Belegt an drei Anläufen derselben Aufgabe: zwei wurden mitten im Prüfen
abgebrochen und hinterließen die fertige Arbeit ungesichert; der dritte drehte die
Reihenfolge um und lief durch.

### Muster 9 · Das Merkmal, das als Mangel gelesen wird

> **Ein leeres Merkmal ist nicht automatisch eine Lücke. Manchmal ist es die Bauart.**

Alle Orte wurden an derselben Checkliste gemessen. Ein reiner Wissensspeicher erschien
dadurch defizitär — „null Regeln" ausgerechnet bei der Regelquelle. Jedes fehlende Merkmal
las sich als Mangel statt als Absicht.

**Wie man es verhindert:** Je Ort zwei Listen — **erwartet** und **bewusst nicht**.

### Muster 10 · Die Ausstattung als Erkennungsmerkmal

> **Zugehörigkeit hängt nicht daran, was schon eingerichtet ist.**

Eine Trennlogik erkannte Bereiche daran, ob sie ein eigenes Konto und eigene Werkzeuge
hatten. Die zwei jüngsten Bereiche hatten beides noch nicht und wurden deshalb nicht
mitgezählt — also von genau der Prüfung ausgenommen, die ihre Vermischung verhindern
sollte.

### Muster 11 · Zuständigkeit an der Nähe statt an der Registrierung

> **„Liegt in der Nähe" ist keine Zugehörigkeit. An einem gemeinsamen übergeordneten
> Verzeichnis ist „irgendwo dazwischen" für alles gleichzeitig wahr.**

Der teuerste Einzelbefund im ganzen Bestand. Ein Mechanismus, der beim Sitzungsstart die
zuständige Wissensfläche laden sollte, prüfte die Zuständigkeit über eine ungebundene
Pfadbeziehung. Vom übergeordneten Nutzerverzeichnis aus ausgeführt, hielt er sich für
zuständig für **alle** Bereiche gleichzeitig — einschließlich eines als streng vertraulich
markierten — und legte dessen Inhalte offen.

**Genau der Mechanismus, der die Grenze durchsetzen sollte, wurde zum Leck.** Gefunden hat
ihn keine Testreihe, sondern eine unabhängige, gegnerisch angelegte Gegenprüfung; der
Betriebstest lief nur durch normale Verzeichnisse.

**Das Geschwister dazu:** Eine Trennung reinigt **Nebenspeicher nicht rückwirkend**. Nach
der Herauslösung des vertraulichen Bereichs lud das Sitzungsgedächtnis des
Herkunftsprojekts dessen Inhalte weiter automatisch mit — derselbe, gerade behobene Fehler,
eine Ebene daneben.

### Muster 12 · Der Zähler für „alles erledigt" und „nichts kommt nach" ist derselbe

> **Eine leere Warteschlange sieht aus wie Erfolg und kann Aushungern bedeuten.**

Eine mehrstufige Kette meldete wochenlang „nichts zu tun". Tatsächlich hatte niemand einen
Mechanismus gebaut, der ihr Nachschub liefert. Nur eine Messung des **Zuflusses** — nicht
nur des Abflusses — unterscheidet die beiden Fälle.

### Muster 13 · Der Prüfer ist auch nur ein Agent

> **Eine Gegenprüfung erhöht die Trefferquote. Sie ersetzt die Primärquelle nicht.**

Ein Prüfagent schlug vor, einen korrekt berechneten Wert zu senken, weil er einen
Referenzwert falsch erinnerte. Ein anderer Prüfdurchgang bewertete eine Übersetzung als
sauber, in der fünf unabhängige Prüfer mit festem Raster später elf Abweichungen auf rund
500 Aussagen fanden.

**Drei Folgerungen:**

1. Ein Prüfauftrag braucht ein **festes Bewertungsraster**, kein Gesamturteil. Ein Prüfer
   ohne Raster meldet Mängel, um seine Existenz zu rechtfertigen.
2. **Technisches Review und Faktencheck sind zwei Durchgänge.** Sie finden verschiedene
   Fehlerklassen.
3. **Ein Korrekturvorschlag wird geprüft wie ein Ergebnis** — gegen die Quelle, nicht
   gegen die Plausibilität.

---

## Teil 2 — Einzelfälle nach Thema

*Nachschlagewerk. Je Eintrag: der Merksatz, dann wofür bezahlt wurde.*

---

### Wissen und Ablage

**Grüne Prüfungen beweisen nur, dass die Prüfung läuft.**
Ein Audit gegen ein aufgeschriebenes Zielbild ergab: von elf Aussagen hielten drei ganz,
fünf teilweise, drei waren schlicht falsch — während alle zugehörigen automatischen
Prüfungen durchgehend null Befunde meldeten. Sie maßen nur ihre eigene, zu enge Definition
von Fehler.

**Die Art-Frage kommt vor der Ebenen-Frage.**
Machbarkeitsanalysen — Texte, die den Ist-Zustand nur als Sprungbrett für eine Empfehlung
beschreiben — wurden wie Systemdokumentation behandelt und in die kuratierte Wissensbasis
destilliert. Siebzehn Notizen mussten zurückgenommen werden. Die entstandene „Doku" wird
falsch, sobald jemand die Empfehlung umsetzt, und das merkt niemand, weil sie nirgends als
offene Entscheidung geführt wird.

**Getrennte Gedächtnisse verstecken bekannte Fallen voreinander.**
Ein riskanter Stolperstein war in einem Bereich seit Wochen dokumentiert. Ein anderes
Werkzeug im selben Themenfeld löste denselben Schaden trotzdem aus — es las aus einem
anderen Topf.

**Ein optionales Feld ohne Prüfung wird nicht ausgefüllt.**
Gemessene Adoption eines rein optional dokumentierten Kopffeldes: **4 %**. Umgekehrt kostet
ein nachträglich eingeführtes Pflichtfeld einen Nachtrag über den gesamten Bestand — in
einem Fall rund 300 Notizen in einem Zug.

**Die Selbstauskunft einer Notiz ist nicht ihr Inhalt.**
Ein Abgleich „Kopfangabe gegen Ort" meldete durchgehend sauber, während knapp vierzig
Dateien der allgemeinen Ebene inhaltlich vollständig an einer einzigen Geschäftseinheit
hingen.

**Ein frisches Änderungsdatum beweist keine Vollständigkeit.**
Ein Verzeichnis galt als aktuell, weil es kürzlich bearbeitet worden war — und fehlte gut
ein Zehntel seines eigenen Bestands. Ein Verweisvergleich fand das, ein Zeitstempelvergleich
nicht.

**Eine Falle gehört so hoch wie möglich.**
Eine Falle bei einem externen Dienst war in einem Projekt korrekt dokumentiert. Drei Wochen
später passierte derselbe Fehler im Nachbarprojekt — der zugestellte Speicher war
projektlokal.

**Verdichtetes Wissen lohnt sich ab einem Nutzungsvolumen, nicht ab einer Themenzahl.**
Durchgerechnet über fünfzig Abfragen: ein roher Notizenspeicher kostete rund 200.000
Kontexteinheiten, ein kuratiert verdichteter rund 65.000 plus einmalige Aufnahmekosten,
eine Suchindexlösung rund 100.000 plus laufende Kosten. Wer zu früh verdichtet, baut
Infrastruktur für einen Bestand, den niemand befragt.

---

### Regeln, Grenzen und Aufträge

**Eine Trennlinie, die nur als Regeltext existiert, wird irgendwann überschritten.**
Eine Grenze zwischen zwei sensiblen Bereichen stand lange nur als Text, bis sie zusätzlich
als technische Zugriffssperre nachgezogen wurde. Ein Modell kann eine Regel unter
Zielkonflikt verletzen; einen Riegel nicht.

**Der Berechtigungsmodus ist kein Werkzeug zur Eingrenzung des Auftrags.**
Ein Aufgabentyp lief bewusst im Nur-Lesen-Modus, sein Auftrag verlangte aber zu schreiben.
Wochenlang liefen die Läufe mit Erfolgsmeldung durch und bewirkten nichts. Der Umfang
gehört in den Auftragstext und wird hinterher objektiv geprüft.

**Eine Beispielliste wird als vollständige Liste befolgt.**
„Hier ein paar Beispiele, aber zähl selbst vollständig auf" führte dazu, dass genau die
Beispiele bearbeitet wurden. Gib entweder die geprüfte Liste oder den Befehl, der sie
erzeugt.

**Ein Agent sieht nur seinen Ausschnitt.**
Zwei Agenten meldeten unabhängig dieselbe Konfigurationsdatei als funktionslos. Sie
versorgte mehrere Vorgänge, die für beide unsichtbar waren. „Wird nirgends benutzt" ist
eine lokale Aussage.

**Vor dem endgültigen Schritt maschinell prüfen, nicht dem Protokoll glauben.**
Eine Vollständigkeitsprüfung unmittelbar vor dem Löschen eines Quellordners deckte auf,
dass beim Umzug mehrere Einträge übersehen worden waren.

**Ein Riegel am gemeinsamen Schritt schlägt einen Riegel je Werkzeug.**
Mehrere Werkzeuge im selben Umfeld lasen unterschiedliche Anweisungsdateien; ein reiner
Regeltext erreichte nicht alle. Ein Riegel, der am Festschreibe-Schritt selbst hängt,
erfasst jeden Akteur, der ihn ausführt.

**Nicht nur Regeln driften — Anleitungen in Werkzeugen auch, und unabhängig davon.**
Eine Werkzeug-Anleitung wies an, direkt in eine gemeinsam genutzte Datei zu schreiben —
genau das, was die zugehörige Konvention verbietet. Die Regel war überall korrekt, die
Anleitung nicht. Ein Regeltext-Abgleich meldete grün.

**Prüf den Zustand eines fremden Arbeitsbaums, bevor du schreibst — nicht danach.**
Ein Testfall legte ein Verzeichnis versehentlich innerhalb eines produktiven Codebaums an.
Das nachfolgende Aufräumen löschte rund **200 reale Dateien**. Die Wiederherstellung gelang
nur, weil sie zufällig unverändert und gesichert waren.

**Prüf erst, ob es wirklich ein Übergriff war.**
Ein unerwarteter Änderungsschritt zwischen zwei beauftragten Schritten wurde als
Grenzüberschreitung gewertet. Er stammte von einer zweiten, ordnungsgemäß laufenden
Tätigkeit. Bei parallelen Läufen sind Spuren nicht eindeutig zuzuordnen.

---

### Übergabe und Parallelarbeit

**Der Zusammenfasser ist gefährlicher als das Problem, das er löst.**
Beim Ausrollen auf sieben Umgebungen erzeugte er drei eigene Datenverluste — verworfene
Abschnittsstruktur, verlorener Fließtext hinter einer Tabelle, fälschlich zusammengefasste
Platzhalter. Ursache jedes Mal: *„Alle Zieldateien sehen aus wie die, an der ich entwickelt
habe."*

**Ein Übergabedokument altert in Stunden — auch seine Vermutungen.**
Eine morgens geschriebene und verifizierte Übergabe stimmte abends in zwei von drei Punkten
nicht mehr. In einem anderen Fall empfahl eine ausdrücklich als Vermutung markierte
Ursachenanalyse eine Notlösung; die echte Ursache war zum Lesezeitpunkt längst anders
behoben.

**Ein delegierter Lauf gehört nicht in den Hintergrund.**
Ein im Hintergrund gestarteter Lauf wurde nach dem ersten von mehreren Schritten abgeräumt.
Der zweite blieb unfertig und ungesichert im Zielbereich liegen — für die nächste Sitzung
nicht von fremder Arbeit zu unterscheiden.

---

### Abgleich mit anderen Systemen

**Ein Spiegel ohne echten Aktualisierungspfad erzeugt bei jeder Änderung eine Kopie.**
Ein Werkzeug konnte anlegen, aber nicht aktualisieren. Die Zieldatenbank lief voll
Dubletten, deren Bereinigung mit jeder Woche aufwendiger wurde.

**Löschen gegen ein bereits gelöschtes Ziel ist ein Erfolg, kein Fehler.**
Ein Löschbefehl lief in eine Zeitüberschreitung, wirkte aber. Der automatische Versuch
danach traf ein bereits entferntes Objekt und meldete einen Fehler, den es nicht gab.

**Externe Schutzschichten weisen Inhalte ab, ohne es zu sagen.**
Bestimmte Textinhalte lösten bei einem Dienst eine allgemeine Fehlerseite statt einer
Antwort aus. Erst eine gezielte, nebenwirkungsfreie Testreihe zeigte, welches Muster den
Ausschlag gab. Die naheliegenden Erklärungen — Rechte, Netz — waren alle geprüft und
verworfen worden.

---

### Unbeaufsichtigte Läufe

**Der Prüftakt muss kleiner sein als die geforderte Wartezeit.**
Ein Lauf sollte nach dreißig Minuten Ruhe starten und prüfte alle zwanzig. Er startete fast
nie, und niemand verstand warum.

**Wachhalten wirkt oft nur am Netzteil.**
Zwei Nächte fielen vollständig aus, weil das Gerät auf Akku hing — ohne jeden Alarm.

**Das Sicherheitsnetz braucht ein eigenes Lebenszeichen.**
Ein Rettungsjob prüfte nur, ob die Sperre des Hauptlaufs belegt war, und wies sich deshalb
selbst ab. Der Hauptlauf hing fest.

**Eine leergelaufene Stufe sieht aus wie eine fertige.**
Eine mehrstufige Kette meldete „nichts zu tun". Tatsächlich hatte niemand einen Mechanismus
gebaut, der ihr neue Eingaben nachliefert.

**Aufeinanderfolgende Stufen brauchen zueinander passende Deckel.**
Eine schnellere Stufe vor einer langsameren produzierte mehr, als die nächste je
verarbeiten konnte. Der Rückstand dazwischen fiel nicht auf, weil jede Stufe für sich
funktionierte.

---

### Modelle und Motoren

**Das stärkste Modell gehört an die Stelle, die prüft — nicht an die, die erzeugt.**
Ein Prüfschritt existiert genau deshalb, weil das Erstgutachten unzuverlässig ist. Ein
schwächerer Zweitgutachter macht die Stufe wertlos statt billig.

**Rechne nach, ob der zweite Motor wirklich billiger ist.**
Ein Zweitmotor sollte ein Pauschalkontingent entlasten. Da das Hauptabo bereits bezahlt
war und der Zweitmotor echtes Zusatzgeld kostete, verschlechterte die Umstellung die
Gesamtkosten.

**Prüf die Rücksetz-Taktung deines Kontingents nach, statt sie anzunehmen.**
Ein Wochenlimit wurde für „setzt zum Monatsende zurück" gehalten. Es setzte zur
Monatsmitte zurück — die geplante Drosselung war unnötig.

**Preis und Vertrauenswürdigkeit sind zwei Achsen.**
Ein niedriger Preis senkt die Hemmschwelle, breit und autonom laufen zu lassen. Genau
daraus entsteht das Risiko, nicht aus dem Modell. Ein günstiger Agent braucht dieselben
Leitplanken wie ein teurer, nicht weniger.

**Werkzeuge gehören dem Programm, nicht dem Modell.**
Ein alternatives Agentenprogramm wurde geprüft, um ein anderes Modell zu nutzen — und
hätte dabei sämtliche vorhandenen Werkzeuge verloren, die am ursprünglichen Programm
hingen.

---

### Werkzeuge bauen

**Prüf vor jeder Fenster-Automation, ob es auch ohne Fenster geht.**
Eine Oberfläche fernzusteuern, um ein Bild zu bekommen, löste ständig Fokusdiebstahl und
Berechtigungsdialoge aus. Dasselbe ohne grafische Sitzung brauchte keins von beidem.

**Positionelle Kennungen sind keine Identität.**
Ein per Nummer angesprochener Bildschirm verschob sich, sobald ein Monitor an- oder
abgesteckt wurde. Dieselbe Nummer traf plötzlich ein anderes Gerät.

**Nur ein Prozess darf auf einen Nachrichtenkanal horchen.**
Zwei gleichzeitige Horcher stahlen sich gegenseitig die eingehenden Nachrichten. Das
Symptom — Ausgang funktioniert, Eingang wirkt tot — war stundenlang nicht zu deuten.

**Wenn eine Systembibliothek defekt wirkt, prüf zuerst, welcher Interpreter im Pfad steht.**
Eine als defekt geltende Funktion lief einwandfrei mit der vorinstallierten Fassung — nur
die im Pfad bevorzugte, separat installierte hatte die Anbindung nicht.

**Weitergegebene Werkzeuge sind ab diesem Moment eine Abzweigung, keine Verbindung.**
Ein Paket wurde einmalig als Kopie weitergegeben. Verbesserungen erreichen sie nicht, und
ihre Anpassungen kommen nicht zurück.

---

### Berichten und Entscheiden

**Ergebnis vor Herleitung — sonst ist nicht erkennbar, ob jemand etwas tun muss.**
Eine technisch korrekte, aber herleitungslastige Meldung erzeugte die Reaktion „mir ist
nicht klar, ob da noch was zu tun ist". Die Reihenfolge war das Problem, nicht die Länge.

**Ein Befund ohne Einordnung ist Rauschen.**
Mehrere zutreffende Nebenbefunde wurden ohne die Frage „was heißt das für den Empfänger"
angehängt. Ergebnis: deutliche Unzufriedenheit und die Gewöhnung, Nebenbemerkungen zu
überlesen.

**Eine Liste offener Entscheidungen wird nicht abgearbeitet — eine Oberfläche mit
Knöpfen schon.**
Zwölf offene Punkte blieben als Text- und Dateiliste vollständig liegen. Dieselben zwölf
als Seite mit Schaltflächen und eigenem Protokoll waren in wenigen Minuten entschieden.
Der Unterschied lag nicht am Inhalt, sondern daran, dass eine Liste einen zusätzlichen
Schritt vom Lesen zum Handeln verlangt.

**Generische Wahlmöglichkeiten und Werkstattsprache machen einen Vorschlag
unbeantwortbar.**
Dieselben drei generischen Schaltflächen für alle Punkte — „so lassen" hieß bei jedem etwas
anderes. Und ein interner Dateiname als vermeintlich selbstverständlicher Begriff, den der
Entscheider nicht verstand, obwohl es seine eigene Datei war.

**Ein vermeintlicher Probelauf war ein echter Schreib-Lauf.**
Ein Skript kannte genau ein Prüf-Flag und ignorierte jedes andere stillschweigend — auch
ein plausibel klingendes, das anderswo im selben System existierte. Statt eines Probelaufs
lief der volle Schreibvorgang über mehrere maschinenweite Dateien. Ob dabei etwas
kaputtging, entschied der Zufall.

**Ein Zeitlimit auf einer monotonen Uhr greift im Schlafmodus nicht.**
Mehrere Läufe zwischen anderthalb und knapp zwölf Stunden meldeten alle „nicht abgelaufen"
— die zugrunde liegende Uhr steht im Schlaf still. Der längste lief noch am Vormittag.

**Eine Freigabe, die bündelt, wird nie erteilt.**
Über hundert verifizierte Befunde lagen wochenlang unbearbeitet, null von mehreren Themen
freigegeben. Jedes Thema bündelte drei bis acht Befunde quer über alle Risikoklassen.

**Ein Status, der mit einem anderen zusammenfällt, macht Arbeit unsichtbar.**
„Fertig, wartet auf Freigabe" fiel auf dieselbe Anzeigeoption wie „läuft gerade". Sechzehn
fertige Pläne, vier davon Sicherheitsthemen, standen wochenlang ununterscheidbar daneben.

**Eine neue Messung ohne Stichtag ertrinkt sofort in Altlasten.**
Und wird dann nie wieder gelesen. Miss ab dem Tag, an dem die Konvention gilt; zähl den
Altbestand getrennt.

**Eine Korrektur, die nur in einer Notiz steht, hilft nur der Sitzung, die sie zufällig
lädt.**
Die Lösung zu einem falschen Pfad stand längst in einer Notiz, während das zugehörige
Werkzeug weiterhin die alte, falsche Behebung empfahl.

---

### Was Agenten liefern

**Beim Umformulieren entstehen Zusagen, die im Original nicht standen.**
Systematisch beim Übertragen, Kürzen und Ausformulieren beobachtet. In einem Fall stand in
einem Entwurf ein Wort, das faktisch ein Zugeständnis zu einem strittigen Punkt gewesen
wäre — entfernt erst in einer späteren Prüfrunde.

**Belegstellen werden plausibel erfunden.**
Eine Massenprüfung über hunderte Einträge fand ein erfundenes Aktenzeichen und eine nicht
existierende Norm. Beide sahen richtig aus; nur der Direktabruf der Quelle entlarvte sie.

**Ein Teilagent kann Platzhaltertext abliefern.**
Bei einem breit gefächerten Lauf taten das mehrere von vielen Beauftragten. Erkannt haben
es nur unabhängig eingesetzte Gegenprüfer, nicht die Fertigmeldungen.

**Ein Exit-Code sagt nichts über die Richtigkeit eines erzeugten Inhalts.**
Ein Durchlauf erzeugte zwei Dutzend Ausgabedateien, alle als erfolgreich gemeldet. Ein
erheblicher Teil war inhaltlich falsch — erkennbar nur am Ergebnis, nicht am Protokoll.

**Bei Dokumenten ersetzt die Zahlenprüfung nicht den Blick auf die Seite.**
Eine Kennzahlen-Mappe bestand alle Formel- und Summenprüfungen. Erst das Ansehen jeder
Seite als Bild fand eine fast leere Seite, ein falsches Zahlenformat und fehlerhafte
Diagrammbalken.

---

### Der Rechner selbst

**Ein Auslöser und die ausgelöste Arbeit haben zwei getrennte Rechteprüfungen.**
Scheitert die erste, hinterlässt das in der Arbeit keine Spur — kein Protokoll, keine
Ausführung, keine Fehlermeldung. Von innen sieht es aus wie „es gab nichts zu tun". Die
einzige Stelle mit einem Befund ist der Auslöser selbst.

**Bei einem Eigentümerwechsel bleibt zurück, was am Namensraum hängt.**
Zwölf umgezogene Ablagen zeigten drei stille Rückstände: Abbilder, die am alten
Namensraum hingen; kontogebundene Schlüssel, die sofort und ohne Vorwarnung brachen; und
der bisherige Eigentümer, automatisch als Mitarbeiter mit Schreibrecht eingetragen, ohne
dass das irgendwo stand.

**Der einzige belastbare Nachweis für öffentliche Sichtbarkeit ist ein Abruf ohne
Anmeldung.**
Eine Auswertung über die Verwaltungsoberfläche erzeugte einen Fehlalarm über tausende
Freigaben, die es nie gab — eine einzige Freigabe am übergeordneten Ordner erscheint in
der Suche als viele Einzeltreffer. Dazu eine Rechteaktualisierung, die Minuten braucht.

**Ein Exit-Code durch eine Pipe ist der Code des letzten Glieds.**
Ein Skript prüfte den Testerfolg über eine gefilterte Ausgabe und bekam den Status des
Filters zurück, nicht den der Tests. Rot ging als grün durch.

**Ein Aufräumbefehl nach Namensmuster trifft fremde Prozesse.**
Ein pauschales Beenden „alles mit diesem Namen" legte einmal einen völlig anderen,
gleichzeitig laufenden Vorgang lahm.

**Eine vergessene Umgebungsvariable hat Vorrang und lähmt still.**
Ein Zugang scheiterte tagelang, weil eine längst vergessene zweite Zugangsvariable immer
zuerst griff. Alle Fehlermeldungen deuteten woanders hin.

**Ein Neustart ohne vorheriges Aktualisieren rollt zurück.**
Ein Dienst wurde neu gestartet, ohne den aktuellen Stand zu ziehen — der ältere lokale
Stand kannte bereits angewendete Änderungen nicht mehr, mehrere Dienste starteten gar
nicht mehr.

**Beim Ausgliedern eines vertraulichen Bereichs bleibt die Historie.**
Der Arbeitsstand kann sauber sein und das Material trotzdem für jeden mit Zugriff
durchsuchbar. Das ist ein eigener, separat zu planender Schritt — nicht Teil des Umzugs.

**Einen sporadisch fehlschlagenden Test messen, bevor man ihn stummschaltet.**
Zwei Tests fielen im vollen Lauf gelegentlich aus. Wiederholte Läufe unter Last zeigten
eine gleichmäßige Verlangsamung aller Phasen um denselben Faktor — eine Diagnose, die eine
Ja/Nein-Beobachtung nie geliefert hätte. Ein Wächter, der aus fremden Gründen rot wird,
bringt allen bei, Rot zu ignorieren.

**Eine Komfort-Automation wird gegen ihr konkretes Symptom getestet, bevor sie bleibt.**
Eine Automation gegen Fokusdiebstahl löste das Problem nicht, für das sie gebaut war, und
störte zusätzlich bei absichtlichen Fensterwechseln. Am Ende wieder entfernt.
