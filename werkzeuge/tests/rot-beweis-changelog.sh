#!/usr/bin/env bash
# Die Suite muss jeden gezielt eingebauten Defekt erkennen.
set -euo pipefail
hier=$(cd "$(dirname "$0")" && pwd)
original="$hier/../changelog-sammeln.sh"
werkstatt=$(mktemp -d)
trap 'rm -rf "$werkstatt"' EXIT
bash "$hier/test-changelog.sh" > "$werkstatt/original.log" 2>&1 || {
  cat "$werkstatt/original.log"; echo 'Original bereits rot'; exit 1;
}
anzahl=0
mutante() {
  local name=$1 programm=$2 erwartung=$3
  awk "$programm" "$original" > "$werkstatt/mutante.sh"
  cmp -s "$original" "$werkstatt/mutante.sh" && { echo "Mutation wirkungslos: $name"; exit 1; }
  bash -n "$werkstatt/mutante.sh"
  if SAMMLER="$werkstatt/mutante.sh" bash "$hier/test-changelog.sh" > "$werkstatt/test.log" 2>&1; then
    echo "BLIND: $name"; exit 1
  fi
  grep -q "$erwartung" "$werkstatt/test.log" || { cat "$werkstatt/test.log"; echo 'Unerwartete Fehlerursache'; exit 1; }
  echo "rot: $name erkannt"
  anzahl=$((anzahl+1))
}
mutante 'Fragment fehlt im Ergebnis' '/tail -n \+2/ {print "      :"; next} {print}' 'Inhalt oder Abschnitt falsch'
mutante 'Falscher Abschnitt' '{sub(/abschnitte\+=\("\$abschnitt"\)/, "abschnitte+=(\"Fixed\")"); print}' 'Inhalt oder Abschnitt falsch'
mutante 'Schmutziger Baum zugelassen' '/\[ -z "\$status" \]/ {print ":"; next} {print}' 'Abbruch erwartet'
echo "$anzahl erkannt, 0 blind"
