# Hooks — Grenzen, die nicht abwägen

Ein Hook ist ein Skript, das vor (oder nach) einem Werkzeugaufruf läuft. Er liest keinen Kontext,
wägt nichts ab und lässt sich nicht überreden. Genau deshalb gehört dort hin, was **nie** passieren
darf. Begründung: [04 — Deterministische Guards](../methode/04_Deterministische-Guards.md).

## Inhalt

| Datei | Typ | Wirkung |
|---|---|---|
| `guard-geschuetzte-daten.sh` | PreToolUse (Bash) | Blockt `git add` und `git commit -a`/`git commit <pfad>`, wenn der Befehl eine geschützte Datei erfassen würde — auch beim Bulk-Add, bei dem der Dateiname im Befehl gar nicht vorkommt |
| `stop-git-status.sh` | Stop | Zeigt am Ende jedes Schritts, was tatsächlich geändert wurde |
| `settings.json.vorlage` | — | Verdrahtung beider Hooks für Claude Code |
| `codex-hooks.json.vorlage` | — | Verdrahtung des Guards für Codex (`.codex/hooks.json`) |
| `pre-commit.vorlage` | git pre-commit | Derselbe Guard mit `--staged`: prüft den Index, greift bei jedem, der committet |
| `geschuetzte-pfade.vorlage` | — | Schutzmuster, projektspezifisch zu setzen |
| `tests/test-guard.sh` | — | 48 Fälle, davon 15 bewusste Nicht-Treffer — inkl. gezieltem `git add`, `git -C`, Codex-Eingabeformat, `--staged` und der Verdrahtung beider Vorlagen aus einem Unterordner |
| `tests/rot-beweis.sh` | — | Rot-Beweis: 11 absichtlich kaputte Guards, die Suite muss jeden bemerken |

## Einbau

```bash
mkdir -p .claude/hooks
cp hooks/guard-geschuetzte-daten.sh hooks/stop-git-status.sh .claude/hooks/
chmod +x .claude/hooks/*.sh
cp hooks/settings.json.vorlage .claude/settings.json
cp hooks/geschuetzte-pfade.vorlage .claude/geschuetzte-pfade
```

**Die Vorlage ruft die Hooks über `"$CLAUDE_PROJECT_DIR"` auf, nicht über einen relativen Pfad.**
Claude Code startet einen Hook im aktuellen Arbeitsverzeichnis der Sitzung — nach einem `cd sub`
also in `sub/`. Ein relativer Pfad `.claude/hooks/…` wird dort nicht gefunden; der Hook endet mit
einem Fehler, und der ist nicht blockierend: Der Befehl läuft durch. Das ist fail-open, und zwar
still. `$CLAUDE_PROJECT_DIR` zeigt immer auf die Projektwurzel, in der die Sitzung begann. Die
Anführungszeichen gehören dazu, sonst bricht ein Pfad mit Leerzeichen. Die Codex-Vorlage löst
dasselbe über `$(git rev-parse --show-toplevel)`. Beide Verdrahtungen prüft
`tests/test-guard.sh` aus einem Unterordner heraus, mit Gegenprobe gegen den relativen Pfad.

Für Codex und für den pre-commit-Hook: siehe [Mit anderen Assistenten](../README.md#mit-anderen-assistenten).
Die Schutzmuster sucht der Guard in `.claude/geschuetzte-pfade`, `.codex/geschuetzte-pfade` oder
`.geschuetzte-pfade` — die erste gefundene gilt.

Dann die Schutzmuster auf das Projekt setzen — **das ist der Schritt, der zählt.** Die Vorgaben
decken Secrets ab, nicht deine Kundendaten.

Danach die Suite laufen lassen: `hooks/tests/test-guard.sh` — und nach Änderungen an der Suite selbst `hooks/tests/rot-beweis.sh`.
In diesem Repo laufen beide zusätzlich bei jedem PR und jedem Push auf `main` unter Linux
(`.github/workflows/tests.yml`).

## Warum es Tests gibt

Der Guard ist die Komponente, die im Ernstfall als einzige zwischen Fehler und Schaden steht — und
er löst im Alltag nie aus. Wenn er kaputtgeht, merkt es niemand. Nach jeder Änderung an den
Schutzmustern: Suite laufen lassen.

Die Suite enthält bewusst **Nicht-Treffer**. Ein Guard mit Fehlalarmen wird umgangen, und danach
schützt er gar nichts mehr.

## Grenzen

- **Er sieht nur, was über das Werkzeug des Assistenten läuft.** Ein `PreToolUse`-Hook prüft
  Befehle, die der Assistent über sein Shell-Werkzeug absetzt. Ein Mensch im Terminal, ein anderes
  Werkzeug, eine IDE-Integration oder ein Skript, das selbst `git` aufruft, laufen an ihm vorbei.
- **Er prüft das Hinzufügen, nicht das Hinausgehen.** `git push` von Dateien, die bereits verfolgt
  sind, Kopieren, Hochladen, Einfügen in ein Chatfenster, Netzwerkaufrufe: Datenabfluss außerhalb
  von `git add`/`git commit` deckt er nicht ab.
- **Deshalb ist er eine Schicht, nicht die Sicherung.** Der pre-commit-Hook (`--staged`) schließt
  einen Teil der Lücke, weil er bei jedem Commit greift, egal wer ihn auslöst — und ist mit
  `--no-verify` umgehbar. Was garantiert nicht ins entfernte Repo gelangen darf, braucht zusätzlich
  eine serverseitige Prüfung: ein Secret-Scanner in CI (z. B. gitleaks) und Branch-Schutz, der
  Pushes ohne diese Prüfung abweist.
- Der Guard prüft, was ein Befehl **bewirken** würde — nicht, was jemand meint. Gegen eine falsche
  fachliche Entscheidung hilft er nicht.
- Er unterscheidet nicht, ob `git add` ein Befehl oder Teil eines Zitats ist. Liegt gleichzeitig eine
  geschützte Datei im Arbeitsbaum, blockt er auch dann. Bewusst so.
- **`git -C <pfad> add` außerhalb des eigenen Repos** misst er im Repo, in dem er läuft, nicht im
  fremden. Erkannt und breit gemessen wird der Befehl, gegen ein fremdes Repo schützt er nicht.
- **Ohne `jq` blockt er.** Ohne geparste Kommandozeile prüft er nichts — und ein Guard, der auf einem
  frisch aufgesetzten Rechner unbemerkt abgeschaltet ist, ist schlimmer als keiner. Fail-closed ist
  hier die einzige vertretbare Richtung.

## Gemessen, nicht geschätzt

Bei den breiten Formen fragt der Guard `git add --dry-run`, was der Befehl **tatsächlich** stagen
würde — statt `git status` zu lesen und daraus zu schließen. `git status` weiß nichts darüber, ob
eine Datei vom Befehl überhaupt erfasst würde, und kennt die Wirkung von `.gitignore` in diesem
Zusammenhang nicht.

| Befehl | Was er anfasst | Womit gemessen |
|---|---|---|
| `git add -A` · `.` · `--all` · `:/` | auch Unverfolgtes | `git add -A --dry-run` |
| `git add -u` · `--update` | nur bereits Verfolgtes | `git add -u --dry-run` |
| `git commit -a` · `-am` | nur bereits Verfolgtes | `git add -u --dry-run` |
| `git add <pfad> …` · `git add -- <pfad>` | nur diese Pfade | `git add --dry-run -- <pfad> …` |
| `git commit <pfad> …` · `-i`/`-o <pfad>` | nur diese Pfade, nur Verfolgtes | `git add -u --dry-run -- <pfad> …` |
| alles, was sich nicht sicher zerlegen lässt | unbekannt | wie oben breit: `-A` (bzw. `-u` bei `-u`/`commit`) |

Ohne diese Unterscheidung kommt ein Fehlalarm garantiert: `git add -u` bei gleichzeitig
herumliegender, unverfolgter `.env` — und ebenso `git add notiz.md` neben derselben `.env`.

**Gezielt messen heißt nicht raten.** Gezielt gemessen wird nur ein schlichter Befehl
`git add|commit …` mit wörtlichen Pfaden. Kette (`&&`, `;`, `|`), Umleitung, `$VARIABLE`, `$(…)`,
Backticks, Backslash, Platzhalter (`*`, `?`, `[`), Tilde, Pathspec-Magie (`:/`), `.`,
`xargs`, vorangestellte globale Optionen (`git -C <pfad> add`) oder unbekannte Optionen: Dann misst
der Guard so breit wie zuvor. Der Fix darf Fehlalarme abbauen, aber nie Schutz. Den Ort des
Befehls liest er aus dem Feld `cwd`, das Claude Code und Codex mitliefern; ohne dieses Feld gilt das
Arbeitsverzeichnis des Hooks. Nebenbei erfasst die gezielte Messung `git add -f` auf eine
ignorierte Datei, die die breite Messung übersieht. Ein **leeres** Messergebnis ist ein Ergebnis („nichts
betroffen"), kein Fehlschlag — auf `git status` fällt der Guard nur zurück, wenn `--dry-run` selbst
fehlschlägt.
