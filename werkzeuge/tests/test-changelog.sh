#!/usr/bin/env bash
set -euo pipefail
hier=$(cd "$(dirname "$0")" && pwd)
sammler=${SAMMLER:-$hier/../changelog-sammeln.sh}
werkstatt=$(mktemp -d)
trap 'rm -rf "$werkstatt"' EXIT
export GIT_AUTHOR_NAME=Test GIT_AUTHOR_EMAIL=test@example.invalid
export GIT_COMMITTER_NAME=Test GIT_COMMITTER_EMAIL=test@example.invalid
nummer=0
ok() { nummer=$((nummer+1)); printf 'OK %s\n' "$*"; }
fail() { printf 'FEHLER %s\n' "$*" >&2; exit 1; }
neu() {
  repo="$werkstatt/repo-$nummer"
  mkdir -p "$repo"
  cd "$repo"
  git init -q
  git checkout -qb test-sammlung
  mkdir -p changelog.d unterordner
  printf '# Fragmente\n' > changelog.d/README.md
  cat > CHANGELOG.md <<'TEXT'
# Changelog

## [Unreleased]

### Fixed
- Bestehender Eintrag bleibt.

## [0.1.0] - 2026-01-01

### Added
- Alter Eintrag bleibt.
TEXT
}
sichern() { git add .; git commit -qm 'test: sichere Ausgangsstand'; }
ablehnen() {
  git status --porcelain --untracked-files=all > "$werkstatt/status-vor"
  git diff HEAD > "$werkstatt/diff-vor"
  cp CHANGELOG.md "$werkstatt/vor"
  if bash "$sammler" "$@" > "$werkstatt/ausgabe" 2>&1; then fail "Abbruch erwartet: $*"; fi
  cmp CHANGELOG.md "$werkstatt/vor" || fail 'Changelog bei Abbruch geaendert'
  git status --porcelain --untracked-files=all > "$werkstatt/status-nach"
  git diff HEAD > "$werkstatt/diff-nach"
  cmp "$werkstatt/status-vor" "$werkstatt/status-nach"
  cmp "$werkstatt/diff-vor" "$werkstatt/diff-nach"
}
neu
printf 'Fixed\n- Fehler behoben.\n' > changelog.d/a-fix.md
printf 'Added\n- Zweiter Zusatz.\n' > changelog.d/z-add.md
printf 'Added\n- Erster Zusatz.\n  Mit Fortsetzung.\n' > changelog.d/b-add.md
printf 'Security\n- Schutz verbessert.\n' > changelog.d/s.md
printf 'Changed\n- Verhalten angepasst.\n' > changelog.d/c.md
sichern
vor_head=$(git rev-parse HEAD)
bash "$sammler" --dry-run 1.2.3 > "$werkstatt/dry"
[ -z "$(git status --porcelain)" ] || fail 'Probelauf schreibt'
(cd unterordner && bash "$sammler" 1.2.3)
cat > "$werkstatt/erwartet" <<TEXT
# Changelog

## [Unreleased]

### Fixed
- Bestehender Eintrag bleibt.

## [1.2.3] - $(date +%F)

### Added
- Erster Zusatz.
  Mit Fortsetzung.

- Zweiter Zusatz.


### Changed
- Verhalten angepasst.


### Fixed
- Fehler behoben.


### Security
- Schutz verbessert.

## [0.1.0] - 2026-01-01

### Added
- Alter Eintrag bleibt.
TEXT
cmp "$werkstatt/erwartet" CHANGELOG.md || fail 'Inhalt oder Abschnitt falsch'
sed '/^DRY-RUN:/,$d' "$werkstatt/dry" > "$werkstatt/dry-inhalt"
printf '\n' >> "$werkstatt/erwartet"
cmp "$werkstatt/erwartet" "$werkstatt/dry-inhalt" || fail 'Probelauf weicht ab'
for name in a-fix z-add b-add s c; do
  [ ! -e "changelog.d/$name.md" ] || fail 'Fragment nicht verschoben'
  git show "HEAD:changelog.d/$name.md" > "$werkstatt/original"
  cmp "$werkstatt/original" "changelog.d/archive/1.2.3/$name.md"
done
[ -f changelog.d/README.md ] || fail 'README verschoben'
[ "$(git rev-parse HEAD)" = "$vor_head" ] || fail 'Commit entstanden'
[ -z "$(git tag)" ] || fail 'Tag entstanden'
ok 'Vollstaendige Eintraege, Abschnitte, Reihenfolge, Archiv und Probelauf'
sichern
ablehnen 1.2.3
ok 'Doppelte Version abgelehnt'
bash "$sammler" 1.2.4 | grep -q 'Keine offenen Fragmente'
[ -z "$(git status --porcelain)" ] || fail 'Leerlauf schreibt'
ok 'Keine offenen Fragmente: keine Aenderung'
neu
printf 'Added\n- Zusatz.\n' > changelog.d/a.md
sichern
ablehnen
ablehnen ../1.2.3
ablehnen 01.2.3
ablehnen 1.2.3 2.0.0
ok 'Fehlende und ungueltige Version abgelehnt'
printf 'schmutzig\n' >> CHANGELOG.md
ablehnen 1.2.3
grep -q 'Arbeitsbaum nicht sauber' "$werkstatt/ausgabe"
git restore CHANGELOG.md
printf 'neu\n' > unverfolgt
ablehnen --dry-run 1.2.3
grep -q 'Arbeitsbaum nicht sauber' "$werkstatt/ausgabe"
git add unverfolgt
ablehnen 1.2.3
grep -q 'Arbeitsbaum nicht sauber' "$werkstatt/ausgabe"
ok 'Geaenderte, unverfolgte und gestagte Dateien abgelehnt'
neu
printf 'Unknown\n- Zusatz.\n' > changelog.d/a.md
sichern
ablehnen 1.2.3
printf 'Added\n' > changelog.d/a.md
sichern
ablehnen 1.2.3
printf 'Added\nText ohne Listenpunkt\n' > changelog.d/a.md
sichern
ablehnen 1.2.3
ok 'Ungueltiger Abschnitt und fehlender Eintrag abgelehnt'
neu
printf 'Added\n- Zusatz.\n' > changelog.d/a.md
mkdir -p changelog.d/archive/1.2.3
printf 'belegt\n' > changelog.d/archive/1.2.3/alt.md
sichern
ablehnen 1.2.3
ok 'Belegtes Archiv abgelehnt'
neu
printf 'Added\n- Zusatz.\n' > changelog.d/a.md
sichern
git checkout -qb main
ablehnen 1.2.3
git checkout -q --detach
ablehnen 1.2.3
ok 'Hauptbranch und losgeloester HEAD abgelehnt'
neu
printf 'Added\n- Zusatz.\n' > changelog.d/a.md
printf '# Changelog\n' > CHANGELOG.md
sichern
ablehnen 1.2.3
ok 'Fehlender Unreleased-Anker abgelehnt'
neu
printf 'Added\n- Zusatz.\n' > changelog.d/a.md
# Kein alter Versionsabschnitt: neue Version muss am Ende entstehen.
printf '# Changelog\n\n## [Unreleased]\n' > CHANGELOG.md
sichern
bash "$sammler" 1.2.3 > /dev/null
grep -q '^## \[1.2.3\]' CHANGELOG.md
grep -q '^- Zusatz\.' CHANGELOG.md
ok 'Erste Version ohne alte Versionsabschnitte'
neu
sichern
basis=$(git rev-parse HEAD)
git checkout -qb beitrag-a
printf 'Added\n- Beitrag A.\n' > changelog.d/beitrag-a.md
sichern
git diff --name-only "$basis" HEAD > "$werkstatt/pfade-a"
printf 'changelog.d/beitrag-a.md\n' > "$werkstatt/erwartet"
cmp "$werkstatt/pfade-a" "$werkstatt/erwartet"
git checkout -qb beitrag-b "$basis"
printf 'Fixed\n- Beitrag B.\n' > changelog.d/beitrag-b.md
sichern
git diff --name-only "$basis" HEAD > "$werkstatt/pfade-b"
printf 'changelog.d/beitrag-b.md\n' > "$werkstatt/erwartet"
cmp "$werkstatt/pfade-b" "$werkstatt/erwartet"
git merge-tree --write-tree beitrag-a beitrag-b > "$werkstatt/merge-tree"
baum=$(head -n 1 "$werkstatt/merge-tree")
git cat-file -e "$baum:changelog.d/beitrag-a.md"
git cat-file -e "$baum:changelog.d/beitrag-b.md"
ok 'Zwei Branches mit je eigener Fragmentdatei: merge-tree konfliktfrei'
printf '%s Testgruppen bestanden\n' "$nummer"
