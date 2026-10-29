#!/usr/bin/env bash
# Rot-Beweis fuer die Testsuite des Herkunfts-Gates.
#
# Gleiches Prinzip wie hooks/tests/rot-beweis.sh: absichtlich kaputte
# Fassungen von herkunft-check.sh ("Mutanten") bauen und die Suite gegen jede
# laufen lassen. Jede Mutante muss mindestens einen Testfall rot machen.
# Bleibt die Suite gruen, hat sie dort einen blinden Fleck.
#
# Die meisten Mutanten sind Rueckfaelle auf fail-open: eine Pruefung, die nicht
# stattfand, meldet "kein Treffer".
#
# Aufruf:  werkzeuge/tests/rot-beweis.sh

set -uo pipefail
hier="$(cd "$(dirname "$0")" && pwd)"
original="$hier/../herkunft-check.sh"
suite="$hier/test-herkunft.sh"
werkstatt=$(mktemp -d)
trap 'rm -rf "$werkstatt"' EXIT
erkannt=0; blind=0

# Vorbedingung: Gegen das Original muss die Suite gruen sein.
if ! "$suite" >/dev/null 2>&1; then
  echo "Abbruch: Die Suite ist schon gegen das unveraenderte Gate rot."
  exit 1
fi

mutante() { # name  awk-programm
  local name="$1" programm="$2" datei
  datei="$werkstatt/$(printf '%s' "$name" | tr -c 'a-z0-9' '_').sh"
  awk "$programm" "$original" > "$datei"
  chmod +x "$datei"
  if cmp -s "$datei" "$original"; then
    printf '  ????  %-44s Mutation hat nichts geaendert — Mutante pruefen\n' "$name"
    blind=$((blind+1)); return
  fi
  if HERKUNFT="$datei" "$suite" >/dev/null 2>&1; then
    printf '  BLIND %-44s Suite bleibt gruen\n' "$name"; blind=$((blind+1))
  else
    printf '  rot   %-44s erkannt\n' "$name"; erkannt=$((erkannt+1))
  fi
}

echo "Mutanten gegen die Suite:"
# 1. Das Gate meldet immer gruen (z. B. versehentlich kurzgeschlossen).
mutante "meldet immer gruen" 'NR==2{print "exit 0"} {print}'
# 2. Rueckgabecode von grep ignoriert: Ein gescheitertes grep (rc 2) mit
#    leerer Trefferliste gilt als "kein Treffer" (frueheres Verhalten).
mutante "grep-rc ignoriert" '/^if \[ "\$rc" -gt 1 \]; then/{print "if false; then"; next} {print}'
# 3. Ziel nicht geprueft: Ein Ziel, das es nicht gibt, wird durchsucht.
mutante "Ziel-Existenz nicht geprueft" '/^if \[ ! -e "\$ziel" \]; then/{print "if false; then"; next} {print}'
# 4. Lesbarkeit des Ziels nicht geprueft.
mutante "Ziel-Lesbarkeit nicht geprueft" '/^if \[ ! -r "\$ziel" \]/{print "if false; then"; next} {print}'
# 5. Muster nicht validiert: ungueltiger Begriff wird nicht benannt.
mutante "Muster nicht validiert" '/grep -iE -e "\$begriff" <\/dev\/null/{print "  true"; next} {print}'
# 6. Vorpruefung auf grep entfernt.
mutante "grep-Vorpruefung entfernt" '/^if ! command -v grep/{print "if false; then"; next} {print}'
# 7. Muster ohne -e: Ein Begriff mit fuehrendem "-" wird zur Option.
mutante "Muster ohne -e uebergeben" '{sub(/^  -e "\$muster" /, "  \"$muster\" ")} {print}'
# 8. Begriffsdatei nicht ausgenommen: Sie trifft sich selbst (Fehlalarm, das
#    Gate wird dann umgangen).
mutante "Begriffsdatei nicht ausgenommen" '/--exclude="\$begriffsdatei"/{next} {print}'
# 9. Fehlercode 3 auf 0 zurueckgestuft (Fehler nur gemeldet, nicht gestoppt).
mutante "Pruefungsfehler mit Exit 0" '{gsub(/exit 3/, "exit 0")} {print}'

echo
echo "$erkannt erkannt, $blind blind"
[ "$blind" -eq 0 ]
