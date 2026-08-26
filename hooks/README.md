# Hooks — Grenzen, die nicht abwägen

Ein Hook ist ein Skript, das vor (oder nach) einem Werkzeugaufruf läuft. Er liest keinen Kontext,
wägt nichts ab und lässt sich nicht überreden. Genau deshalb gehört dort hin, was **nie** passieren
darf. Begründung: [04 — Deterministische Guards](../methode/04_Deterministische-Guards.md).

## Inhalt

| Datei | Typ | Wirkung |
|---|---|---|
| `guard-geschuetzte-daten.sh` | PreToolUse (Bash) | Blockt `git add`, wenn eine geschützte Datei im Arbeitsbaum liegt — auch beim Bulk-Add, bei dem der Dateiname im Befehl gar nicht vorkommt |
| `stop-git-status.sh` | Stop | Zeigt am Ende jedes Schritts, was tatsächlich geändert wurde |
| `settings.json.vorlage` | — | Verdrahtung beider Hooks |
| `geschuetzte-pfade.vorlage` | — | Schutzmuster, projektspezifisch zu setzen |
| `tests/test-guard.sh` | — | 19 Fälle, davon 8 bewusste Nicht-Treffer |

## Einbau

```bash
mkdir -p .claude/hooks
cp hooks/guard-geschuetzte-daten.sh hooks/stop-git-status.sh .claude/hooks/
chmod +x .claude/hooks/*.sh
cp hooks/settings.json.vorlage .claude/settings.json
cp hooks/geschuetzte-pfade.vorlage .claude/geschuetzte-pfade
```

Dann die Schutzmuster auf das Projekt setzen — **das ist der Schritt, der zählt.** Die Vorgaben
decken Secrets ab, nicht deine Kundendaten.

Danach die Suite laufen lassen: `hooks/tests/test-guard.sh`

## Warum es Tests gibt

Der Guard ist die Komponente, die im Ernstfall als einzige zwischen Fehler und Schaden steht — und
er löst im Alltag nie aus. Wenn er kaputtgeht, merkt es niemand. Nach jeder Änderung an den
Schutzmustern: Suite laufen lassen.

Die Suite enthält bewusst **Nicht-Treffer**. Ein Guard mit Fehlalarmen wird umgangen, und danach
schützt er gar nichts mehr.

## Grenzen

- Der Guard prüft, was ein Befehl **bewirken** würde — nicht, was jemand meint. Gegen eine falsche
  fachliche Entscheidung hilft er nicht.
- Er unterscheidet nicht, ob `git add` ein Befehl oder Teil eines Zitats ist. Liegt gleichzeitig eine
  geschützte Datei im Arbeitsbaum, blockt er auch dann. Bewusst so.
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

Ohne diese Unterscheidung kommt ein Fehlalarm garantiert: `git add -u` bei gleichzeitig
herumliegender, unverfolgter `.env`. Ein **leeres** Messergebnis ist ein Ergebnis („nichts
betroffen"), kein Fehlschlag — auf `git status` fällt der Guard nur zurück, wenn `--dry-run` selbst
fehlschlägt.
