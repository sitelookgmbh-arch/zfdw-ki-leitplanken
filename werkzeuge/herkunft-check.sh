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
# Rueckgabe: 0 = geprueft, kein Treffer
#            1 = Treffer
#            2 = keine Begriffsdatei oder keine aktiven Begriffe
#            3 = Pruefungsfehler: ungueltiges Muster, Ziel fehlt oder ist
#                unlesbar, grep fehlt oder scheitert (rc > 1)
#
# Fail-closed: Exit 0 gibt es nur, wenn grep jeden Begriff gegen ein lesbares
# Ziel tatsaechlich geprueft hat. Eine Pruefung, die nicht stattfand, meldet
# nie "kein Treffer".

set -uo pipefail

if ! command -v grep >/dev/null 2>&1; then
  echo "Herkunfts-Gate: grep nicht gefunden — Pruefung nicht moeglich." >&2
  exit 3
fi

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

if [ ! -r "$begriffsdatei" ]; then
  echo "Herkunfts-Gate: Begriffsdatei $begriffsdatei nicht lesbar — Pruefung nicht moeglich." >&2
  exit 3
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

# Jeden Begriff einzeln pruefen, bevor gesucht wird: Ein ungueltiges Muster
# laesst grep mit rc 2 scheitern, und die Meldung soll den Begriff nennen.
ungueltig=0
for begriff in "${begriffe[@]}"; do
  grep -iE -e "$begriff" </dev/null >/dev/null 2>&1
  rc=$?
  if [ "$rc" -gt 1 ]; then
    echo "Herkunfts-Gate: Ungueltiges Muster in $begriffsdatei: $begriff" >&2
    ungueltig=$((ungueltig+1))
  fi
done
if [ "$ungueltig" -gt 0 ]; then
  echo "Herkunfts-Gate: $ungueltig ungueltige(s) Muster — Pruefung nicht moeglich." >&2
  exit 3
fi

if [ ! -e "$ziel" ]; then
  echo "Herkunfts-Gate: Ziel nicht gefunden: $ziel — Pruefung nicht moeglich." >&2
  exit 3
fi
if [ ! -r "$ziel" ] || { [ -d "$ziel" ] && [ ! -x "$ziel" ]; }; then
  echo "Herkunfts-Gate: Ziel nicht lesbar: $ziel — Pruefung nicht moeglich." >&2
  exit 3
fi

muster=$(IFS='|'; printf '%s' "${begriffe[*]}")

fehlerdatei=$(mktemp) || { echo "Herkunfts-Gate: mktemp gescheitert." >&2; exit 3; }
trap 'rm -f "$fehlerdatei"' EXIT

# -e vor dem Muster: Ein Begriff, der mit "-" beginnt, ist sonst eine Option.
treffer=$(grep -rinE \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude="$begriffsdatei" \
  --exclude="herkunft-begriffe.vorlage" \
  --exclude="herkunft-check.sh" \
  -e "$muster" "$ziel" 2>"$fehlerdatei")
rc=$?

# rc 0 = Treffer, 1 = keiner, alles darueber = grep ist gescheitert (z. B.
# unlesbare Datei im Baum). Dann ist die Trefferliste unvollstaendig.
if [ "$rc" -gt 1 ]; then
  echo "Herkunfts-Gate: grep gescheitert (rc $rc) — Pruefung unvollstaendig, NICHT veroeffentlichen." >&2
  sed 's/^/  /' "$fehlerdatei" >&2
  exit 3
fi

if [ "$rc" -eq 1 ] && [ -z "$treffer" ]; then
  echo "Herkunfts-Gate: kein Treffer (${#begriffe[@]} Begriffe, Ziel: $ziel)."
  echo "Untere Schranke bestanden. Die Belege liest trotzdem ein Mensch."
  exit 0
fi

anzahl=$(printf '%s\n' "$treffer" | wc -l | tr -d ' ')
echo "Herkunfts-Gate: $anzahl Treffer — NICHT veroeffentlichen." >&2
echo >&2
printf '%s\n' "$treffer" | sed 's/^/  /' >&2
exit 1
