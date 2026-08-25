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
| `tests/test-guard.sh` | — | 14 Fälle, davon 6 bewusste Nicht-Treffer |

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
- Ohne `jq` fällt er auf den Rohtext der Werkzeug-Eingabe zurück: gröber, aber nicht blind.
