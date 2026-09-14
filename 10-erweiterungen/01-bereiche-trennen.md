# Erweiterung 1 · Mehrere Bereiche trennen

> **Anlass:** Es gibt einen zweiten Bereich — ein zweites Geschäft, einen zweiten Kunden,
> Berufliches neben Privatem — und die beiden dürfen sich nichts teilen.

---

## Worum es geht

Das ist die **wertvollste Einzelentscheidung** aus dem Bestand, aus dem dieses Kit
destilliert ist — und diejenige, deren Fehlen am teuersten nachzuholen ist.

Bereiche zu trennen heißt: eigene Ablage, eigene Regeln, eigene Zugänge, eigene Sitzungen.
Kein Wissen sickert von einem in den anderen. Die **einzige** gemeinsame Fläche ist die
allgemeine Ebene — und die ist deshalb bereichsneutral zu halten.

---

## Bestandsaufnahme — wenn schon etwas da ist

*Nur für den Durchlauf aus `INTEGRIEREN.md`. Beim Neuaufbau überspringen.*

**Sieh nach, bevor du redest:**

| Wonach | Wo typischerweise | Was der Fund bedeutet |
|---|---|---|
| Mehrere Geschäfte oder Kunden im selben Ordner | Projektstamm, ein gemeinsames `docs/` oder `notes/` | Die Trennung existiert höchstens als Unterordner — das zählt hier nicht als getrennt |
| Eigene Zugänge je Bereich (Konten, Logins, Repos) | `.env`-Dateien, separate Repos, getrennte Logins | Vorhanden → die Trennung ist technisch schon halb gebaut, nur nicht als Regel festgehalten |
| Firmen- oder Kundennamen in der gemeinsamen Ebene | Überschriften und Abschnitte der obersten Anweisungsdatei | Verstößt gegen die Bereichsneutralität, auch wenn es nur ein Abschnitt ist |
| Eine Liste der Bereiche | irgendwo als Fließtext, README, Kommentar | Fast nie maschinenlesbar — das ist der günstigste erste Schritt |
| Alte, überholte Bereichsnamen | Umbenennungen in der Historie, alte Ordnernamen | Als Alias weitergeführt sind sie ein Fehler, kein Komfort |

**Drei Ausgangslagen, die fast alles abdecken:**

- **Alles liegt in einem Ordner, ohne bewussten Schnitt.** Der lohnendste erste Schritt ist
  nicht Zugriffstechnik, sondern die **Liste der Bereiche** — schon das Aufschreiben, wer
  sich was nicht teilen darf, zeigt meist sofort, wo die gemeinsame Ebene heute schon
  Bereichsnamen trägt.
- **Ein Bereich wohnt im Speicher eines anderen**, meist als Unterordner „kommt später
  raus". Das sieht nach Trennung aus und ist keine. Lohnendster Schritt: den Umzug an einen
  eigenen Ort einplanen — nicht die Unterordnerform behalten und nur die Regeln
  nachschärfen.
- **Schon technisch getrennt** — eigene Repos, eigene Konten —, aber die Bereichsliste
  existiert nur als Prosa oder gar nicht. Lohnendster Schritt: die Liste als
  maschinenlesbare Datei nachziehen, sonst hat jede spätere Prüfung nichts, wogegen sie
  messen kann.

> **Der häufigste Fehlgriff an dieser Stelle:** Eine Unterordner-Trennung als ausreichend
> durchgehen lassen, weil sie ordentlich aussieht — sie ist keine Trennung, nur eine
> Bequemlichkeit, die mit jedem Monat teurer wird.

---

## Die Entscheidung

**Woran hängt die Trennung?** Zwei Möglichkeiten, und nur eine funktioniert:

| Weg | Was passiert |
|---|---|
| **An der Zugehörigkeit** — jeder Bereich ist als solcher benannt und geführt | Trägt. Ein Bereich ohne eigene Werkzeuge ist trotzdem ein Bereich |
| **An der Ausstattung** — was ein eigenes Konto und eigene Werkzeuge hat, gilt als Bereich | Trägt nicht. Junge Bereiche haben beides noch nicht und fallen aus jeder Zählung |

**Gelernt an:** Eine Trennlogik machte die Zugehörigkeit an der Ausstattung fest. Folge:
Die zwei jüngsten Bereiche wurden nicht mitgezählt — sie hatten noch kein eigenes Konto.
Sie waren damit von genau der Prüfung ausgenommen, die ihre Vermischung hätte verhindern
sollen.

---

## Was in jedem Fall gilt

1. **Ein Bereich, der im Speicher eines anderen wohnt, ist nicht getrennt** — auch wenn
   ein Unterordner ihn abgrenzt. Das passiert regelmäßig aus Bequemlichkeit („kommt später
   raus") und wird mit jedem Monat teurer.
2. **Die gemeinsame Ebene ist bereichsneutral.** Kein Bereichsname in einer Überschrift.
   Ein Beispiel im Fließtext ist erlaubt, ein eigener Abschnitt nicht.
3. **Die Liste der Bereiche steht an genau einer Stelle** — maschinenlesbar, nicht in
   Prosa. Eine Aufzählung, die von Hand in Fließtext lebt, altert still. In einem
   beobachteten Fall stand sie in dreizehn Kopien und war vier Wochen falsch.
4. **Kein Alias für überholte Namen.** Wird ein Bereich umbenannt, ist der alte Name kein
   gültiger Zweitname — die Umbenennung ist genau das, was auffallen soll.

---

## Woran man merkt, dass es bricht

| Zu messen | Bricht, wenn |
|---|---|
| Verweise, die von einem Bereich in einen anderen zeigen | > 0 |
| Bereichsnamen in Überschriften der gemeinsamen Ebene | > 0 |
| Orte, die in keiner Bereichsliste stehen | > 0 |
| Abweichungen zwischen der Bereichsliste und ihren Erwähnungen in Texten | > 0 |

---

## Vorlage

```yaml
# bereiche.yml — die einzige Quelle
bereiche:
  - name: <Anzeigename>
    kuerzel: <kurz>
    schreibweisen: [<name>, <alternative schreibweise>]   # keine überholten Namen
    orte: [<pfad>, <pfad>]
    zugaenge: [<welche konten gehören dazu>]
    vertraulich: ja | nein
```

**Im Profil vermerken:** wie viele Bereiche, woran die Trennung hängt, was die gemeinsame
Ebene tragen darf.
