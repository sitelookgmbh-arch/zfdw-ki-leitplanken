# Changelog

Format nach [Keep a Changelog](https://keepachangelog.com/de/1.1.0/), Versionierung nach
[Semantic Versioning 2.0](https://semver.org/lang/de/).

## [Unreleased]

### Changed

- **Sprint-Vorlage vollständig neu geschnitten — nachweisgeführt statt ablaufgeführt.** Die
  bisherige Fassung folgte Abschnitt für Abschnitt der Vorlage aus CC_GodMode; das war eine
  Übersetzung, keine Eigenleistung, und bei proprietär lizenziertem Original der falsche Weg.
  Die neue Fassung ist entlang der Fragen geschnitten, die in Informationssicherheits-
  Assessments, Datenschutz-Nachweisen und Kundenaudits tatsächlich gestellt werden:
  **Schutzbedarf und Datenklassen** (A/B/C, mit dem Hinweis, dass ein Commit unwiderruflich
  ist) · **Write-Scope** nach vorn gezogen, um Guard-Spalte erweitert · **Zugänge und
  Geheimnisse** samt Rückgabe · **Änderungsklasse und Freigabe** (Standard/Normal/Notfall) ·
  **Nachweise** statt bloßer Akzeptanzkriterien (Kriterium + Beleg + Fundort) ·
  **Abweichungen und Risikoabnahme** als Tabelle mit benannter abnehmender Person, an Stelle
  des früheren Routing-Logs · **Auditspur**, was dauerhaft liegen bleibt. Am Ende eine
  Grobzuordnung der Abschnitte zu den üblichen Prüffeldern (VDA ISA / TISAX, ISO/IEC 27001)
  — bewusst ohne Control-Nummern, die gehören gegen den geltenden Katalog abgeglichen.
- **Statuswerte auf Deutsch**: `geplant | laufend | pruefung | abgeschlossen | blockiert`.
- **`/sprint-starten` und `/sprint-abschliessen`** auf die Abweichungstabelle umgestellt; der
  Startbefehl benennt jetzt die Prüfungen, die unabhängig vom Zeitdruck nicht ausgelassen
  werden dürfen.
- **Methode 01** um Abschnitt 7 ergänzt: Belege entstehen beim Arbeiten, nicht in der Woche
  vor dem Audit.
- **Herkunftsangabe im README präzisiert.** Übernommen ist der Grundgedanke „ein
  Arbeitsabschnitt = eine Datei, die zugleich der Zustand ist". Schnitt, Nachweislogik und
  Umsetzung stammen aus Kundenarbeit in geregelten Umgebungen.


## [0.1.0] — 2026-08-25

Erstveröffentlichung.

### Added

- **Methode** — sechs Dokumente: Sprintplan mit Write-Scope · Schichten (Anweisung/Hook/Skill/Command)
  · Kontext-Budget · Deterministische Guards · Verifikation statt Behauptung · Herkunft und
  Weitergabe (die Weiche zwischen freier und kundengebundener Sammlung: drei Fragen vor dem
  Schreiben, Overlay statt Kopie, Einbahnstraße frei→gebunden, ausführbares Herkunfts-Gate).
- **Vorlagen** — `PLAN.md`, Sprint-Datei mit Write-Scope, Abweichungstabelle und Versions-Relevanz, sowie
  eine schlanke Anweisungsdatei (`CLAUDE.md`) mit dem Richtwert 200 Zeilen.
- **Commands** — `/sprint-planen`, `/sprint-starten`, `/sprint-abschliessen`, `/review-aenderungen`.
- **Hooks** — `guard-geschuetzte-daten.sh` (prüft die Wirkung eines `git add`, nicht seinen Wortlaut
  — greift damit auch beim Bulk-Add, bei dem der Dateiname im Befehl nicht vorkommt),
  `stop-git-status.sh`, Verdrahtungs- und Musterdatei-Vorlagen sowie eine Testsuite mit 14 Fällen,
  davon 6 bewusste Nicht-Treffer.
- **Werkzeuge** — `herkunft-check.sh`: prüft den Arbeitsbaum vor einer Veröffentlichung gegen eine
  gepflegte Begriffsliste (Kunden, Systeme, Domains, Fachvokabular, Personen). Untere Schranke, kein
  Ersatz für das Lesen der Belege.
