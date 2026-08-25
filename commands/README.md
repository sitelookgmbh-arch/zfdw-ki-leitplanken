# Slash-Commands

Nach `.claude/commands/` kopieren, dann mit `/<dateiname>` aufrufen.

```bash
mkdir -p .claude/commands && cp commands/*.md .claude/commands/
```

| Command | Wann |
|---|---|
| [`/sprint-planen`](sprint-planen.md) | Ein Vorhaben steht an, das größer ist als ein Commit. Legt `PLAN.md` und die Sprint-Dateien an — **schreibt keinen Produktivcode** |
| [`/sprint-starten`](sprint-starten.md) | Vor der ersten Änderung eines Sprints: Preflight, Statuswechsel, Abweichungs-Eintrag |
| [`/sprint-abschliessen`](sprint-abschliessen.md) | Am Ende: Kriterien belegen, Write-Scope gegenprüfen, Ergebnis schreiben, dann `done` |
| [`/review-aenderungen`](review-aenderungen.md) | Diff prüfen — klassifiziert zuerst und skaliert den Aufwand, statt immer alles zu prüfen |

## Warum getrennte Commands statt eines großen

Jeder Command hat einen Zeitpunkt, an dem er richtig ist. `/sprint-starten` erzwingt den
Abweichungs-Eintrag **vor** der Arbeit — hinterher ist er wertlos, weil man dann begründet, was man ohnehin
getan hat. `/sprint-abschliessen` prüft den Write-Scope gegen den echten Diff, was vorher nicht geht.

Ein einzelner „mach den Sprint"-Command würde beides in dieselbe Sitzung legen und damit genau die
Reihenfolge aufheben, die den Nutzen ausmacht.
