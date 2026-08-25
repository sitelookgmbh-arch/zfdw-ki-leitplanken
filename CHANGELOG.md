# Changelog

Format nach [Keep a Changelog](https://keepachangelog.com/de/1.1.0/), Versionierung nach
[Semantic Versioning 2.0](https://semver.org/lang/de/).

## [Unreleased]

## [0.1.0] — 2026-08-25

Erstveröffentlichung.

### Added

- **Methode** — fünf Dokumente: Sprintplan mit Write-Scope · Schichten (Anweisung/Hook/Skill/Command)
  · Kontext-Budget · Deterministische Guards · Verifikation statt Behauptung.
- **Vorlagen** — `PLAN.md`, Sprint-Datei mit Write-Scope, Routing-Log und Versions-Relevanz, sowie
  eine schlanke Anweisungsdatei (`CLAUDE.md`) mit dem Richtwert 200 Zeilen.
- **Commands** — `/sprint-planen`, `/sprint-starten`, `/sprint-abschliessen`, `/review-aenderungen`.
- **Hooks** — `guard-geschuetzte-daten.sh` (prüft die Wirkung eines `git add`, nicht seinen Wortlaut
  — greift damit auch beim Bulk-Add, bei dem der Dateiname im Befehl nicht vorkommt),
  `stop-git-status.sh`, Verdrahtungs- und Musterdatei-Vorlagen sowie eine Testsuite mit 14 Fällen,
  davon 6 bewusste Nicht-Treffer.
