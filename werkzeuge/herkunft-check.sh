#!/usr/bin/env bash
# herkunft-check.sh — Herkunfts-Gate vor einer Veroeffentlichung
#
# Durchsucht den Arbeitsbaum nach Begriffen, die nicht nach draussen sollen:
# Kundennamen, Systemnamen, Domains, Fachvokabular, Personennamen.
#
# Das ist die UNTERE Schranke, nicht die Abnahme. Ein leerer Lauf heisst
# "kein Namensbezug gefunden" — nicht "unbedenklich". Belege, die ein Projekt
# ohne Namen erkennbar machen, findet nur ein Mensch.
# Siehe methode/06_Herkunft-und-Weitergabe.md.
#
# Begriffe: eine Zeile je Begriff (erweiterter regulaerer Ausdruck, Gross-/
# Kleinschreibung egal) in .herkunft-begriffe. Kommentare mit #.
#
# Aufruf:  werkzeuge/herkunft-check.sh [pfad]     Standard: .
#          werkzeuge/herkunft-check.sh --liste    zeigt die geladenen Begriffe
#
# Rueckgabe: 0 = kein Treffer, 1 = Treffer, 2 = keine Begriffsdatei.

set -uo pipefail

ziel="."
nur_liste=0
case "${1:-}" in
  --liste) nur_liste=1 ;;
  "") ;;
  *) ziel="$1" ;;
esac

begriffsdatei=".herkunft-begriffe"
[ -f "$begriffsdatei" ] || begriffsdatei="$(dirname "$0")/herkunft-begriffe.vorlage"

if [ ! -f "$begriffsdatei" ]; then
  echo "Keine Begriffsdatei gefunden (.herkunft-begriffe)." >&2
  echo "Vorlage kopieren: cp werkzeuge/herkunft-begriffe.vorlage .herkunft-begriffe" >&2
  exit 2
fi

begriffe=()
while IFS= read -r zeile; do
  zeile="${zeile%%#*}"
  # fuehrende/abschliessende Leerzeichen weg, innere erhalten
  zeile="$(printf '%s' "$zeile" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
  [ -n "$zeile" ] && begriffe+=("$zeile")
done < "$begriffsdatei"

if [ ${#begriffe[@]} -eq 0 ]; then
  echo "Begriffsdatei $begriffsdatei enthaelt keine Begriffe." >&2
  exit 2
fi

if [ "$nur_liste" -eq 1 ]; then
  echo "Begriffe aus $begriffsdatei (${#begriffe[@]}):"
  printf '  %s\n' "${begriffe[@]}"
  exit 0
fi

muster=$(IFS='|'; printf '%s' "${begriffe[*]}")

treffer=$(grep -rinE "$muster" "$ziel" \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude="$begriffsdatei" \
  --exclude="herkunft-begriffe.vorlage" \
  --exclude="herkunft-check.sh" 2>/dev/null)

if [ -z "$treffer" ]; then
  echo "Herkunfts-Gate: kein Treffer (${#begriffe[@]} Begriffe, Ziel: $ziel)."
  echo "Untere Schranke bestanden. Die Belege liest trotzdem ein Mensch."
  exit 0
fi

anzahl=$(printf '%s\n' "$treffer" | wc -l | tr -d ' ')
echo "Herkunfts-Gate: $anzahl Treffer — NICHT veroeffentlichen." >&2
echo >&2
printf '%s\n' "$treffer" | sed 's/^/  /' >&2
exit 1
