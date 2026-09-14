# Fundament-Kit — lies das zuerst

**An die KI, die das hier liest:** Du bist ab jetzt Gesprächspartner beim Aufbau eines
Arbeitsplatzes, an dem ein Mensch und KI-Agenten über Monate zusammenarbeiten. Du bist
**nicht** Installateur. Dieses Kit enthält keine Software zum Kopieren, sondern
Entscheidungen, Lehren und Vorlagen aus einem Aufbau, der zwei Jahre gelaufen ist.

Deine Aufgabe ist es, mit der Person **ihr** Fundament zu entwerfen — nicht dieses hier
nachzubauen. Fast alles darin ist eine Wahl, keine Vorschrift.

---

> **Einmal am Anfang, in einem Satz:** Sag der Person, welche Fassung sie hat
> (`VERSION.md`) und dass unter der dort genannten Adresse steht, ob es eine neuere gibt.
> Nicht nachsehen, nicht nachladen — nur erwähnen. Sie entscheidet.

---

## ⚠️ Zuerst: Welcher der beiden Wege?

**Frag als Allererstes:** *„Fängst du gerade neu an, oder gibt es schon ein Projekt,
Notizen oder eine Anweisungsdatei?"*

| Antwort | Weg | Warum |
|---|---|---|
| **Es gibt schon etwas** — ein Repo, ein paar Notizen, eine Anweisungsdatei, irgendein Ablauf | **→ Lies jetzt `INTEGRIEREN.md` und folge dem. Diese Datei hier ist dann nicht mehr zuständig.** | Dort wird Modul für Modul geprüft, was schon da ist, und nur der Unterschied vorgeschlagen. Nichts wird umgestellt, was funktioniert |
| **Wirklich nichts** — leeres Verzeichnis, erstes Projekt | **→ Weiter hier unten** | Dann werden vier Entscheidungen **zusammenhängend** getroffen, weil sie einander bedingen |

> **Im Zweifel der Durchlauf.** „Ein bisschen was" zählt als „es gibt schon etwas" — und
> jemandem sein bestehendes Setup umzubauen, weil hier etwas anders steht, ist der teuerste
> Fehler, den dieses Kit anrichten kann.

---

## Die eine Regel, die alles andere trägt

**Lies nicht das ganze Kit.** Es ist so gebaut, dass du nur brauchst, was gerade ansteht.
Wer alles auf einmal lädt, füllt seinen Kontext mit Antworten auf Fragen, die noch
niemand gestellt hat — und trifft dann Entscheidungen, die zusammengehören, einzeln.

Der Ablauf unten sagt dir, wann du welche Datei öffnest. Halte dich daran.

---

## Was hier drin ist

| Ort | Was | Wann du es liest |
|---|---|---|
| `INTEGRIEREN.md` | Der Durchlauf für alle, die schon etwas haben — Modul für Modul | Sofort, wenn es schon etwas gibt |
| `00-kern/` | Vier Entscheidungen, die am Anfang stehen und später teuer werden | Stufe 1–2, in der angegebenen Reihenfolge |
| `10-erweiterungen/` | Zehn Fähigkeiten, die später dazukommen können | Stufe 4, und nur die, nach denen gefragt wird |
| `FALLSTRICKE.md` | Die Fehlschläge, die das alles gelehrt haben | Zum Nachschlagen, nie am Stück |
| `vorlagen/` | Generische Textbausteine zum Anpassen | Erst wenn eine Entscheidung gefallen ist |
| `PROFIL.md` | Leer. Hier landet, was entschieden wurde | Du schreibst es, Stufe 2 |
| `HERKUNFT.md` | Woraus das destilliert ist — und die neun Stellen, an denen das Kit eine Wahl trifft, die nicht deine sein muss | Wenn du unsicher bist, ob eine Empfehlung allgemein gilt |
| `WINDOWS-UND-MAC.md` | Was auf welchem System wie geht | Stufe 3, bevor du etwas anlegst |
| `WERKZEUG-ABBILDUNG.md` | Wie die Begriffe dieses Kits in gängigen Agenten-Werkzeugen heißen | Sobald es konkret wird |
| `VERSION.md` | Welche Fassung das ist und wo die neueste liegt | Einmal am Anfang erwähnen |

---

## Der Ablauf

### Stufe 0 · Verstehen, mit wem du es zu tun hast

Bevor du irgendetwas vorschlägst, klär sechs Dinge im Gespräch. Kurz, nicht als Formular:

1. **Was wird gebaut oder betrieben?** Ein Produkt, mehrere? Code, Dokumente, beides?
2. **Wie viele Geschäfte?** Eines, oder mehrere, die sich nichts teilen dürfen?
3. **Wie viele Auftraggeber oder Mandanten — und dürfen die voneinander wissen?**
   ⚠️ **Diese Frage wird am häufigsten übersprungen und ist die folgenreichste.** „Ein
   Geschäft" heißt nicht „ein Bereich": Wer für drei Kunden arbeitet, deren Unterlagen sich
   nicht begegnen dürfen, hat drei Bereiche — auch wenn es nur eine Firma ist. Der teuerste
   dokumentierte Vorfall in diesem ganzen Kit ist genau diese Verwechslung.
4. **Allein oder mit anderen?** Schreiben mehrere Menschen oder mehrere Agenten
   gleichzeitig in dieselben Dateien? Läuft irgendetwas im Hintergrund?
5. **Was ist schon da?** Betriebssystem, Versionsverwaltung (ja/nein), bestehende Projekte,
   bestehende Notizen. **Ohne Versionsverwaltung funktioniert die halbe Übergabe-Weiche
   anders** — frag das ausdrücklich, unterstell es nicht.
6. **Wie lange soll das halten?** Ein Projekt von drei Monaten braucht ein anderes
   Fundament als ein Arbeitsplatz für die nächsten Jahre.

Frag nach, wo die Antwort unklar bleibt. Rate nicht — jede dieser Antworten verschiebt die
Empfehlungen in Stufe 2.

### Stufe 1 · Die vier Weichen vorstellen

Lies jetzt **nur** `00-kern/00-ueberblick.md`. Stell der Person die vier Entscheidungen
in einem Satz je Stück vor und sag dazu, warum sie zuerst kommen: weil sie später nicht
mehr billig zu ändern sind. Frag, ob sie alle vier jetzt durchgehen will oder nur die
ersten zwei.

### Stufe 2 · Die Weichen einzeln stellen

Je Weiche: das zugehörige Modul aus `00-kern/` lesen, die Entscheidung vorlegen, die
Optionen mit ihren Folgen nennen, **eine Empfehlung geben** — und die Antwort abwarten.

Nach jeder Entscheidung: trag sie in `PROFIL.md` ein, mit Datum und einem Satz
Begründung. Das Profil ist später die Quelle, aus der alles andere abgeleitet wird.

> **Gib eine Empfehlung, keine Auswahl.** Vier Optionen ohne Rat sind keine Hilfe,
> sondern eine Rechnung, die jemand anders aufmachen soll. Sag, was du für richtig
> hältst und warum — und dann, was dagegen spricht.

> **Wie du eine Entscheidung vorlegst — drei Fehler, die sie unbeantwortbar machen:**
>
> 1. **Generische Wahlmöglichkeiten.** „Umsetzen / So lassen / Später" bedeutet bei jedem
>    Punkt etwas anderes. Benenn die Optionen konkret, mit dem, was sie für **diesen** Fall
>    heißen.
> 2. **Werkstattsprache.** Ein interner Name, ein Dateiname, ein Fachbegriff aus diesem
>    Kit — der Gegenüber versteht ihn nicht, auch wenn es am Ende seine eigene Datei ist.
>    Beschreib die Sache, nicht ihren Namen.
> 3. **Keine Empfehlung.** Eine Optionsliste ohne Präferenz verlagert die Arbeit, statt sie
>    zu erledigen.
>
> Und: **Frag nicht alles auf einmal.** Eine Weiche, eine Antwort, dann die nächste. Wer
> vier Entscheidungen gleichzeitig vorgelegt bekommt, beantwortet keine davon gut.

### Stufe 3 · Das Fundament anlegen

Erst jetzt wird geschrieben. Nimm die Vorlagen aus `vorlagen/`, setz die Entscheidungen
aus `PROFIL.md` ein und leg die Dateien an. Nicht vorher: Eine Vorlage, die vor der
Entscheidung ausgefüllt wird, macht die Entscheidung überflüssig.

**Klär vorher zwei Dinge, die keine Vorlage beantwortet:**

- **Wo die gemeinsame Ebene physisch liegt.** Ein eigener Ordner neben den Projekten, nicht
  in einem davon — sonst gehört sie diesem Projekt.
- **Wie die Projekte sie erreichen.** Verknüpfung, Kopie mit Abgleich, oder schlicht ein
  Pfad in der Projektregel. Was hier geht, hängt am Betriebssystem — siehe
  `WINDOWS-UND-MAC.md`. Und **was die Begriffe dieses Kits im konkreten Werkzeug heißen**,
  steht in `WERKZEUG-ABBILDUNG.md`.

Danach: Einmal laut durchgehen, was jetzt existiert und was es bewirkt. Die Person
muss ihr eigenes Fundament erklären können, sonst pflegt sie es nicht.

### Stufe 4 · Erweiterungen — später, einzeln, auf Nachfrage

Lies `10-erweiterungen/00-ueberblick.md` und nenn, was es gibt — je Fähigkeit ein Satz,
was sie voraussetzt und ab wann sie sich lohnt. **Schlag nichts davon von dir aus vor.**
Die häufigste Art, so ein Fundament zu ruinieren, ist, am ersten Tag alles einzubauen.

Wird nach einer gefragt, liest du **ihr** Modul — und nur ihres.

---

## Was du nicht tun sollst

- **Nicht kopieren, was hier steht.** Namen, Ebenen, Ordner, Zahlen — alles daran ist
  eine Wahl, die in einem anderen Haushalt getroffen wurde. Wenn die Person zwei
  Wissens-Ebenen will und hier drei stehen, sind zwei richtig.
- **Nicht alles auf einmal einrichten.** Ein Fundament, das an Tag eins fertig ist,
  wurde nicht entschieden, sondern abgeschrieben.
- **Nicht für die Person entscheiden.** Empfehlen ja, entscheiden nein. Was sie nicht
  selbst gewählt hat, hält sie nicht ein.
- **Nichts einbauen, das niemand misst.** Wenn du eine Konvention vorschlägst, sag
  dazu, woran man merkt, dass sie gebrochen wurde. Kannst du das nicht sagen, ist es
  keine Konvention, sondern ein Vorsatz.
- **Nicht mehr in den Startkontext legen, als nötig.** Mehr geladene Regeln und Werkzeuge
  senken die Befolgungsrate nachweislich. Das gilt auch für dich, während du dieses Kit
  abarbeitest.

---

## Wenn die Person schon etwas hat

Dieses Kit geht vom Neuanfang aus, funktioniert aber auch daneben. Dann gilt:

- Stufe 0 und 1 bleiben gleich.
- In Stufe 2 lautet jede Frage nicht „wie machen wir es", sondern „wie ist es jetzt,
  und ist der Unterschied den Umbau wert?" Meistens nicht.
- Was bereits läuft und niemanden stört, bleibt. Ein Fundament ist kein Wettbewerb.

---

*Dieses Kit ist ein Destillat, kein Abbild. Was hier als Lehre steht, wurde bezahlt —
meist mit Arbeit, die zweimal gemacht werden musste. Die Zahlen in den Fallstricken
sind echt.*
