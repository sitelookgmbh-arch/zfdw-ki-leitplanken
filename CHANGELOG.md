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
- **Akzeptanzkriterien in der Form *gegeben / wenn / dann***. Abschnitt 7 der Sprint-Vorlage
  verlangte bisher Kriterium plus Beleg, ließ das Kriterium selbst aber frei formuliert — und
  ein frei formuliertes Kriterium bleibt am Ende Verhandlungssache. Die Vorlage nennt jetzt die
  Form und zeigt sie an einem Beispiel; `/sprint-planen` fordert sie beim Anlegen ein.
- **Abschnitt 6 der Anweisungs-Vorlage von einer Stufe auf drei erweitert** — *immer · erst
  fragen · nie*. Bisher gab es dort nur die harte Grenze. Damit war der gesamte Graubereich
  ungeregelt, also genau die Fälle mit Außenwirkung, in denen ein Assistent anhalten und fragen
  soll. Stufe *nie* bleibt Hook-pflichtig.

### Added

- **Reifegrad-Einordnung im README: diese Sammlung ist *Spec-anchored*.** Ordnet die Methode in
  das übliche Raster des Spec-driven Development ein (Spec-first · Spec-anchored ·
  Spec-as-Source) und begründet, warum die beiden Nachbarstufen hier nicht taugen. Methode 01
  nennt den Begriff an der Stelle, an der die Entscheidung tatsächlich fällt (Regel 2).
- **Methode 05 um *Spec Drift* ergänzt** — der Fehlermodus, den Verifikation gerade nicht fängt:
  Beschreibung und Code driften auseinander, alle Prüfungen bleiben grün, die Dokumentation ist
  trotzdem falsch. Gegenmittel als Commit-Regel (dieselbe Änderung, derselbe Commit), plus die
  Prüffrage „welche Beschreibung wird durch diesen Diff falsch?".
- **Methode 01, Regel 8: Folge-Sprints beschreiben das Delta** — was hinzukommt, sich ändert
  oder entfällt, statt den Gesamtzustand erneut zu beschreiben. Kopierter Gesamtzustand driftet
  gegeneinander, verdeckt im Diff die eigentliche Änderung und füllt den Kontext.


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
