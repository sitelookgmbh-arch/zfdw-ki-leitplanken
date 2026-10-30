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
| `tests/test-guard.sh` | — | 72 Fälle, davon 19 mit erwartetem Exit 0 — inkl. gezieltem `git add`, `git -C <pfad>` (gemessen im Zielverzeichnis), Codex-Eingabeformat, `--staged` und der Verdrahtung beider Vorlagen aus einem Unterordner |
| `tests/rot-beweis.sh` | — | Rot-Beweis: 17 absichtlich kaputte Guards, die Suite muss jeden bemerken |

## Einbau

Werkzeug-Guard und pre-commit-Hook sind das **Standardpaar** — der eine ohne den anderen lässt
eine bekannte Lücke offen (siehe [Grenzen](#grenzen)):

```bash
mkdir -p .claude/hooks
cp hooks/guard-geschuetzte-daten.sh hooks/stop-git-status.sh .claude/hooks/
chmod +x .claude/hooks/*.sh
cp hooks/settings.json.vorlage .claude/settings.json
cp hooks/geschuetzte-pfade.vorlage .claude/geschuetzte-pfade
cp hooks/pre-commit.vorlage .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
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
- **Er prüft den Befehl, nicht den Index.** Ein schlichtes `git commit -m …` über eine geschützte
  Datei, die bereits gestagt ist, lässt er durch (Exit 0) — der Befehl selbst fügt nichts hinzu.
  Diesen Fall fängt der pre-commit-Hook (`--staged`), der den Index prüft. Deshalb gehören beide
  zusammen.
- **Deshalb ist er eine Schicht, nicht die Sicherung.** Der pre-commit-Hook schließt einen Teil der
  Lücke, weil er bei jedem Commit greift, egal wer ihn auslöst — und ist wie jeder lokale Hook mit
  `git commit --no-verify` umgehbar. Was garantiert nicht ins entfernte Repo gelangen darf, braucht
  die Schicht darüber auf dem Server: Secret-Scanning mit Push-Schutz, ein Secret-Scanner in CI
  (z. B. gitleaks) als verpflichtender Statuscheck und Branch-Schutz, der ohne diese Prüfung nicht
  mergen lässt. Auch alle Schichten zusammen sind keine Sperre gegen jeden Datenabfluss: Was nicht
  über `git add`/`git commit` läuft, sehen sie nicht (siehe oben).
- Der Guard prüft, was ein Befehl **bewirken** würde — nicht, was jemand meint. Gegen eine falsche
  fachliche Entscheidung hilft er nicht.
- Er unterscheidet nicht, ob `git add` ein Befehl oder Teil eines Zitats ist. Liegt gleichzeitig eine
  geschützte Datei im Arbeitsbaum, blockt er auch dann. Bewusst so.
- **`git -C <pfad> add` außerhalb des eigenen Repos** misst er im Repo aus `cwd`, nicht im
  fremden. Erkannt und breit gemessen wird der Befehl, gegen ein fremdes Repo schützt er nicht.
- **Expansionen werden nicht ausgewertet.** Sobald `$` oder Backticks im Befehl stehen,
  misst er breit mit `-A`, auch ohne wörtlich erkennbares `git add`. Das erfasst unquotierte
  Substitutionen mit Leerzeichen und variable Unterbefehle, kann aber auch harmlose Befehle
  oder wörtlich zitierte Dollarzeichen blockieren. Das Ziel einer dynamischen Verzeichniswahl
  außerhalb des Repos aus `cwd` kann diese Messung nicht bestimmen. Liegt `cwd` außerhalb
  eines Repos, blockt er deshalb auch Befehle ohne git wie `echo "$HOME"` mit Exit 2
  und einer Begründung auf stderr.
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
| `git -C <ziel> add <pfad> …` · `git -C <ziel> add .` | nur diese Pfade, relativ zu `<ziel>` | `git -C <ziel> add --dry-run -- <pfad> …` |
| `git commit <pfad> …` · `-i`/`-o <pfad>` | nur diese Pfade, nur Verfolgtes | `git add -u --dry-run -- <pfad> …` |
| `$` oder Backticks, mit oder ohne Anführungszeichen | unbekannt | `git add -A --dry-run` im Repo aus `cwd` |
| alles andere, was sich nicht sicher zerlegen lässt | unbekannt | wie oben breit: `-A` (bzw. `-u` bei `-u`/`commit`) |

Ohne diese Unterscheidung kommt ein Fehlalarm garantiert: `git add -u` bei gleichzeitig
herumliegender, unverfolgter `.env` — und ebenso `git add notiz.md` neben derselben `.env`.

**Gezielt messen heißt nicht raten.** Gezielt gemessen wird nur ein schlichter Befehl
`git add|commit …` mit wörtlichen Pfaden. Kette (`&&`, `;`, `|`), Umleitung, `$VARIABLE`, `$(…)`,
Backticks, Backslash, Platzhalter (`*`, `?`, `[`), Tilde, Pathspec-Magie (`:/`), `.`,
`xargs`, vorangestellte globale Optionen oder unbekannte Optionen: Dann misst der Guard so breit
wie zuvor. Einzige gelesene globale Option ist **genau ein** `git -C <ziel>` mit wörtlichem Pfad
zu einem vorhandenen Verzeichnis: Dann misst der Guard in `<ziel>` (relativ zu `cwd`), und dort
gilt auch `.` als gezielt messbar — `git -C sub add .` erfasst eine `.env` im Stamm nicht und
blockt deshalb auch nicht. Mehrere `-C`, `-C` neben weiteren globalen Optionen, ein `-C`-Pfad aus
Variable oder Substitution oder ein fehlendes Zielverzeichnis: breit wie zuvor. Der Fix darf Fehlalarme abbauen, aber nie Schutz. Den Ort des
Befehls liest er aus dem Feld `cwd`. Auch die breite Messung und die Suche nach Schutzmustern
verwenden dieses Repo. Fehlt `cwd`, ist es kein absolutes vorhandenes Verzeichnis oder liegt
es außerhalb eines Repos, blockt der Guard einen prüfpflichtigen Befehl (Exit 2 mit Begründung auf stderr). Nebenbei erfasst die gezielte Messung `git add -f` auf eine
ignorierte Datei, die die breite Messung übersieht. Ein **leeres** Messergebnis ist ein Ergebnis („nichts
betroffen"), kein Fehlschlag — auf `git status` fällt der Guard nur zurück, wenn `--dry-run` selbst
fehlschlägt.
