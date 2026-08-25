# Mitmachen

Verbesserungen sind willkommen. Bitte in dieser Form:

## Issues

Am nützlichsten ist ein Issue, das einen **konkreten Fehlschlag** beschreibt: Was ist passiert, was
hätte die Methode verhindern sollen, an welcher Stelle hat sie es nicht getan. Daraus lässt sich
etwas machen.

Weniger nützlich: „könnte man nicht auch …". Doch, könnte man fast immer. Die Frage ist, was es
kostet.

## Pull-Requests

- **Ein Thema pro PR.** Commits nach [Conventional Commits](https://www.conventionalcommits.org/de/v1.0.0/).
- **Deutsch.** Die Sammlung ist durchgehend deutsch; gemischte Sprachen driften auseinander.
- **Begründung statt Behauptung.** Jede Regel hier hat einen Absatz, der sagt, was ohne sie schiefgeht.
  Eine neue Regel ohne diesen Absatz wird nicht aufgenommen — auch wenn sie richtig ist.
- **Am Guard geändert?** `hooks/tests/test-guard.sh` laufen lassen und, wenn du ein Muster
  hinzufügst, einen Testfall dazu. Auch einen Nicht-Treffer, wenn das Muster breit ist.

## Was hier nicht hineingehört

- **Werkzeug-Abhängigkeiten.** Die Sammlung soll ohne Installation funktionieren. Ein Skript ist ok,
  eine Laufzeitumgebung nicht.
- **Projekt- oder Kundenspezifisches.** Was nur in einem Projekt gilt, gehört in dessen
  `docs/decisions/`.
- **Regeln ohne Fehlschlag dahinter.** Die Sammlung ist bewusst schmal. Jede zusätzliche Seite senkt
  die Wahrscheinlichkeit, dass die vorhandenen gelesen werden — genau der Mechanismus, den
  [03 — Kontext-Budget](methode/03_Kontext-Budget.md) beschreibt.

## Reifegrad

Was hier steht, stammt aus produktiver Arbeit, aber aus **wenigen** Projekten. Wer eine dieser
Methoden in einem anderen Umfeld anwendet und dabei feststellt, dass sie nicht trägt: bitte melden.
Ein belegtes Gegenbeispiel ist wertvoller als eine weitere Regel.
