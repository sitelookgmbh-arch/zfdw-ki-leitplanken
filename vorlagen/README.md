# Vorlagen

Zum Kopieren ins eigene Projekt. Platzhalter in `{{DOPPELTEN_KLAMMERN}}` ersetzen.

| Vorlage | Ziel im Projekt | Zweck |
|---|---|---|
| [`PLAN.md`](PLAN.md) | `docs/plan/PLAN.md` | Das Vorhaben: Ziel, Sprint-Liste, Reihenfolge, Annahmen |
| [`sprint-NN.md`](sprint-NN.md) | `docs/plan/sprint-NN-<slug>.md` | Ein Arbeitsabschnitt: Write-Scope, Akzeptanzkriterien, Routing-Log, Ergebnis |
| [`CLAUDE.md`](CLAUDE.md) | `CLAUDE.md` (Repo-Wurzel) | Anweisungsdatei, schlank gehalten — Richtwert 200 Zeilen |

## `docs/plan/` neben `docs/decisions/`

Zwei Ordner, zwei Zeitachsen:

- **`docs/decisions/`** — warum etwas so entschieden wurde. Dauerhaft, wird selten geändert.
- **`docs/plan/`** — was als Nächstes passiert und wer welche Datei anfasst. Arbeitsbegleitend,
  ändert sich täglich, bleibt danach als Begründungsspur zum Diff liegen.

Ein leerer `docs/plan/` ist kein Mangel. Ein Vorhaben ohne Plan schon.

## Lebenszyklus einer Sprint-Datei

`planned` → `in-progress` → `review` → `done`
(oder `blocked` — mit einer Zeile, **worauf** gewartet wird).

Beim Abschluss: `## Ergebnis` füllen, Changelog-Notiz übertragen, **dann erst** `status: done`.
