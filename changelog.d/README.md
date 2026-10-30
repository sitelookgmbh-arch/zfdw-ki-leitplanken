# Changelog-Fragmente

Neue Pull-Requests schreiben ihren Eintrag ausschließlich in eine eigene Datei
`changelog.d/<slug>.md`. Einen eindeutigen, beschreibenden Namen wählen: So ändern
parallele Beiträge verschiedene Dateien und kollidieren nicht im gemeinsamen
`Unreleased`-Abschnitt. `CHANGELOG.md` bleibt bis zum Sammeln unverändert.

Die erste Zeile ist genau einer der Abschnittsnamen `Added`, `Changed`, `Fixed`
oder `Security` (ohne Markdown-Rauten). Danach folgen mindestens ein Listenpunkt
und bei Bedarf Leerzeilen oder mit zwei Leerzeichen eingerückte Fortsetzungen:

```markdown
Added
- **Neue Prüfung:** beschreibt die Änderung und ihren Nutzen.
  Eine Fortsetzung erklärt bei Bedarf die Grenze.
```

Eine Datei je PR, ein Abschnitt je Datei; den fachlich passendsten wählen.
Die Einträge folgen dem bisherigen Keep-a-Changelog-Stil. Fragmente sind öffentlich
und müssen dieselbe Herkunftsprüfung wie alle übrigen Beiträge bestehen.
`README.md` und Dateien unter `archive/` sind keine offenen Fragmente.

## Bewusst sammeln

Auf einem eigenen Arbeitsbranch mit sauberem Git-Arbeitsbaum (einschließlich
unverfolgter Dateien), aus dem Repo oder einem Unterordner:

```bash
bash werkzeuge/changelog-sammeln.sh --dry-run X.Y.Z
bash werkzeuge/changelog-sammeln.sh X.Y.Z
```

`X.Y.Z` durch die gewünschte numerische Version ersetzen. Der Probelauf zeigt die
vollständige geplante Datei, ohne den Arbeitsbaum zu ändern. Der Sammler prüft
zuerst alle Fragmente, sortiert nach `Added`, `Changed`, `Fixed`, `Security` und
innerhalb der Abschnitte nach Dateiname. Er fügt die neue datierte Version nach
dem bestehenden `Unreleased`-Inhalt und vor älteren Versionen ein. Bestehende
Einträge werden nicht automatisch übernommen. Die Fragmente wandern nach
`changelog.d/archive/<version>/`.

Fehlende/ungültige Version, schmutziger Baum, ungültige Fragmente, vorhandene
Version oder belegtes Archivziel führen zum Abbruch. Ohne Fragmente ist der Lauf
bei einer noch unbenutzten Version ein No-op. `main`, `master` und ein losgelöster
HEAD werden abgelehnt. Es entstehen weder Commit, Push noch Tag. Das Ergebnis
prüfen und als normalen Pull-Request einreichen. Bei einem Dateisystemfehler
während des Schreibens können Teiländerungen zurückbleiben; diese vor einem
neuen Lauf anhand von `git diff` und `git status` prüfen.

## Tests

```bash
bash werkzeuge/tests/test-changelog.sh
bash werkzeuge/tests/rot-beweis-changelog.sh
```
