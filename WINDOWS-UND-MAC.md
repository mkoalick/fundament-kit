# Windows und Mac

*Gelesen in Stufe 3, bevor etwas angelegt wird. Und immer dann, wenn ein Modul einen
Mechanismus empfiehlt, der nach Betriebssystem klingt.*

---

## Die ehrliche Ausgangslage

Der Bau, aus dem dieses Kit destilliert ist, lief auf macOS. **Die Entscheidungen sind
plattformneutral, ein Teil der Umsetzungen nicht.** Diese Datei nennt für jeden betroffenen
Mechanismus das Gegenstück — nicht als fertiges Rezept, aber so konkret, dass die Suche
danach kurz wird.

**Vier Bereiche sind betroffen. Der Rest des Kits ist plattformneutral.**

---

## 1 · Die gemeinsame Ebene in mehrere Projekte einhängen

Das Kit empfiehlt durchgehend **Verknüpfung statt Kopie** — weil Kopien driften.

| | macOS / Linux | Windows |
|---|---|---|
| **Verknüpfung** | `ln -s` — funktioniert immer | Braucht **Entwicklermodus** (Einstellungen → System → Für Entwickler) oder Administratorrechte. Danach `mklink /D` bzw. `New-Item -ItemType SymbolicLink` |
| **Alternative** | — | **Verzeichnisverbindung** (`mklink /J`) — braucht keine Sonderrechte, funktioniert nur auf demselben Laufwerk |
| **Wenn beides ausscheidet** | — | Kopie plus ein Abgleichschritt, der **Inhalte vergleicht** — und ein Eintrag in der Messtabelle, der die Abweichung zählt |

> **Der Weg, der beides erspart:** Wer ohnehin unter WSL arbeitet, hat den Unix-Fall. Wer
> nicht, nimmt die Verzeichnisverbindung.

⚠️ **Wenn eine Kopie unvermeidlich ist, ist die Messung Pflicht, nicht Kür.** Eine Kopie
ohne Abgleichsmessung ist der Fall, für den im Kit steht: *Kopien driften. Immer. Nur eine
Frage der Zeit.*

---

## 2 · Etwas zu einer festen Zeit laufen lassen

| | macOS | Windows |
|---|---|---|
| **Zeitgesteuert starten** | `launchd` (Benutzeragent) oder `cron` | **Aufgabenplanung** (`schtasks`, oder die Oberfläche) |
| **Nach dem Aufwachen nachholen** | launchd holt nach | Aufgabenplanung: „Aufgabe so schnell wie möglich nach einem verpassten Start ausführen" — **muss angehakt werden**, ist es per Voreinstellung nicht |
| **Nur bei Netzbetrieb** | über die Eigenschaften des Auftrags | Aufgabenplanung: „Aufgabe nur starten, falls Computer im Netzbetrieb ausgeführt wird" — **standardmäßig aktiv**, also aufpassen |

> **Die Lehre aus dem Kit gilt hier doppelt:** *Ein Auslöser und die ausgelöste Arbeit
> haben zwei getrennte Rechteprüfungen.* Unter Windows kommt hinzu, dass eine Aufgabe in
> einer anderen Sitzung läuft als die eigene — Umgebungsvariablen und Pfade sind dort
> **nicht** dieselben. Das ist die häufigste Ursache für „läuft von Hand, aber nicht nach
> Plan".

---

## 3 · Den Rechner wach halten

| | macOS | Windows |
|---|---|---|
| **Wachhalten** | `caffeinate` | `powercfg /requests` zeigt an, wer wach hält; einen Energieplan setzen, oder ein kleines Programm, das die Anforderung hält |
| **Akku erkennen** | über die Stromversorgung abfragen | `WMIC Path Win32_Battery Get BatteryStatus` oder die entsprechende PowerShell-Abfrage |

**Die Lehre bleibt dieselbe, unabhängig vom System:** Was den Rechner wachhält, wirkt oft
nur am Netzteil — und scheitert auf Akku **lautlos**. Prüf den Stromzustand ausdrücklich
und warne.

---

## 4 · Riegel, die einen Vorgang abweisen

Das ist der einzige Bereich, in dem die Umsetzung stärker vom **Agenten-Werkzeug** abhängt
als vom Betriebssystem — siehe `WERKZEUG-ABBILDUNG.md`. Was plattformabhängig bleibt:

- **Die Skriptsprache.** Ein Riegel in Python läuft überall; einer in einer Shell-Sprache
  nicht. **Nimm Python oder etwas ähnlich Neutrales**, auch wenn eine Zeile Shell kürzer
  wäre.
- **Der Fokus-Riegel** (nichts holt ungefragt ein Fenster nach vorn) hat unter Windows kein
  direktes Gegenstück zur macOS-Mechanik. Praktikabel ist, ihn am **Befehl** anzusetzen:
  alles, was ein Fenster öffnen würde, wird abgewiesen, außer es trägt eine ausdrückliche
  Markierung.

---

## 5 · Einen Agenten ohne Berechtigungsabfragen starten

| | macOS / Linux | Windows |
|---|---|---|
| **Abkürzung mit Geländer** | Shell-Funktion, siehe `10-erweiterungen/09-arbeitsplatz.md` | PowerShell-Funktion, gleiches Geländer |
| **Prüfen, ob interaktiv** | `[[ -o interactive ]]` | `[Environment]::UserInteractive` — meldet nicht exakt dasselbe, taugt aber als Näherung |
| **Umgebung vor dem Start aktivieren** | `source .venv/bin/activate` | `.venv\Scripts\Activate.ps1` |

```powershell
function Start-AgentYolo {
    $safe = Join-Path $HOME "<projekt-wurzel>"   # anpassen
    $here = (Get-Location).Path
    if ($here -ne $safe -and -not $here.StartsWith("$safe\")) {
        Write-Warning "Startet OHNE Berechtigungsabfragen."
        Write-Warning "Arbeitsverzeichnis: $here - liegt ausserhalb von $safe."
        if ((Read-Host "Trotzdem starten? [y/N]") -ne "y") { return }
    }
    $activate = Join-Path $PWD ".venv\Scripts\Activate.ps1"
    if (Test-Path $activate) { & $activate }
    claude --dangerously-skip-permissions @args
}
```

> Dieselbe Lehre wie im Modul: Ein Editor, der seine Aktivierungszeile verzögert ins
> Terminal schickt, trifft unter Windows dieselbe Falle — die Umgebung deshalb auch hier
> **vor** dem Start und **in derselben Funktion** aktivieren, nicht dem Editor überlassen.

---

## Was das für die Erweiterungen heißt

| Erweiterung | Windows |
|---|---|
| 1 Bereiche trennen · 2 Projekte überblicken · 3 Delegation | unverändert |
| 4 Unbeaufsichtigt | Aufgabenplanung statt launchd, Akku-Prüfung anders — Konzepte gleich |
| 5 Spiegel | unverändert, außer dem Zeitplan |
| 6 Dokumente | unverändert — die Bibliotheken laufen überall |
| 7 Werkzeugbau · 8 Motoren | unverändert |
| 9 Arbeitsplatz | die Registrier-Idee bleibt gleich; die Abkürzung „ohne Rückfragen" braucht eine PowerShell-Fassung (siehe oben), der Kontext-Wächter ist reines Python und läuft unverändert |
| 10 Web und Medien | unverändert |

---

*Wenn hier etwas fehlt, das gebraucht wird: Es ist eine Suchanfrage, kein Hindernis. Die
Entscheidung darüber, **was** laufen soll, steht im Modul — diese Datei sagt nur, **womit**.*
