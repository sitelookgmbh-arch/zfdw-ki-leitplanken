#!/usr/bin/env bash
# Sammelt oeffentliche Changelog-Fragmente; erstellt weder Commit noch Tag.
set -euo pipefail
export LC_ALL=C
fehler() { printf 'Abbruch: %s\n' "$*" >&2; exit 1; }
dry=0
version=
for arg in "$@"; do
  case "$arg" in
    --dry-run) dry=1 ;;
    *) [ -z "$version" ] || fehler 'Genau eine Version angeben'; version=$arg ;;
  esac
done
[[ "$version" =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]] || fehler 'Version als X.Y.Z angeben'
root=$(git rev-parse --show-toplevel) || fehler 'Kein Git-Arbeitsbaum'
cd "$root"
status=$(git status --porcelain --untracked-files=all) || fehler 'Git-Status nicht lesbar'
[ -z "$status" ] || fehler 'Arbeitsbaum nicht sauber'
branch=$(git symbolic-ref --quiet --short HEAD) || fehler 'Arbeitsbranch erforderlich'
case "$branch" in main|master) fehler 'Eigenen Arbeitsbranch verwenden' ;; esac
[ -f CHANGELOG.md ] && [ ! -L CHANGELOG.md ] || fehler 'CHANGELOG.md fehlt oder ist ein Link'
[ -d changelog.d ] && [ ! -L changelog.d ] || fehler 'changelog.d fehlt oder ist ein Link'
[ "$(grep -c '^## \[Unreleased\]$' CHANGELOG.md)" = 1 ] || fehler 'Genau ein Unreleased-Abschnitt erforderlich'
if grep -Fq "## [$version]" CHANGELOG.md; then fehler 'Version bereits vorhanden'; fi
archive="changelog.d/archive/$version"
[ ! -L changelog.d/archive ] || fehler 'Archiv ist ein Link'
[ ! -e "$archive" ] && [ ! -L "$archive" ] || fehler 'Archivziel bereits belegt'
shopt -s nullglob
fragmente=()
abschnitte=()
for datei in changelog.d/*.md; do
  [ "$datei" != changelog.d/README.md ] || continue
  [ -f "$datei" ] && [ ! -L "$datei" ] || fehler "Kein regulaeres Fragment: $datei"
  # Kopf ist genau der Abschnittsname; mindestens ein Aufzaehlungspunkt.
  if ! awk '
    NR==1 {if ($0 !~ /^(Added|Changed|Fixed|Security)$/) exit 1; next}
    /^- [^[:space:]]/ {punkte++; next}
    /^$/ {next}
    /^  [^[:space:]]/ {if (!punkte) exit 1; next}
    {exit 1}
    END {if (!punkte) exit 1}
  ' "$datei"; then fehler "Ungueltiges Fragment: $datei"; fi
  IFS= read -r abschnitt < "$datei"
  fragmente+=("$datei")
  abschnitte+=("$abschnitt")
done
[ "${#fragmente[@]}" -gt 0 ] || { echo 'Keine offenen Fragmente'; exit 0; }
# Erst nach allen Vorpruefungen temporaere Ausgabe erzeugen.
werkstatt=$(mktemp -d)
trap 'rm -rf "$werkstatt"' EXIT
block="$werkstatt/block"
{
  printf '## [%s] - %s\n' "$version" "$(date +%F)"
  for abschnitt in Added Changed Fixed Security; do
    kopf=0
    for ((i=0; i<${#fragmente[@]}; i++)); do
      [ "${abschnitte[i]}" = "$abschnitt" ] || continue
      if [ "$kopf" -eq 0 ]; then printf '\n### %s\n' "$abschnitt"; kopf=1; fi
      tail -n +2 "${fragmente[i]}"
      printf '\n'
    done
  done
} > "$block"
# Bestehendes Unreleased bleibt erhalten; neue Version vor der ersten alten.
awk -v block="$block" '
  /^## \[Unreleased\]$/ {unreleased=1}
  unreleased && /^## \[/ && $0 != "## [Unreleased]" && !eingefuegt {
    while ((getline zeile < block)>0) print zeile
    close(block); eingefuegt=1
  }
  {print}
  END {if (!eingefuegt) {print ""; while ((getline zeile < block)>0) print zeile; close(block)}}
' CHANGELOG.md > "$werkstatt/CHANGELOG.md"
if [ "$dry" -eq 1 ]; then
  cat "$werkstatt/CHANGELOG.md"
  printf '\nDRY-RUN: %s Fragment(e) nach %s; keine Dateien geaendert.\n' "${#fragmente[@]}" "$archive"
  exit 0
fi
mkdir -p "$archive"
cp "$werkstatt/CHANGELOG.md" CHANGELOG.md
for datei in "${fragmente[@]}"; do mv "$datei" "$archive/"; done
printf '%s Fragment(e) gesammelt: %s\n' "${#fragmente[@]}" "$archive"
