#!/usr/bin/env bash
# guard-geschuetzte-daten.sh — PreToolUse-Hook (Bash)
#
# Blockt Versuche, geschuetzte Dateien in die Versionsverwaltung zu bringen.
#
# Prueft die WIRKUNG des Befehls, nicht seinen Wortlaut: bei einem Bulk-Add
# (`git add -A`, `git add .`, `git add -u`) taucht der Dateiname im Befehl gar
# nicht auf — genau dort versagt jede textuelle Regel. Der Guard sieht deshalb
# nach, welche Dateien im Arbeitsbaum tatsaechlich betroffen waeren.
#
# Einbindung (.claude/settings.json):
#   "hooks": { "PreToolUse": [ { "matcher": "Bash",
#     "hooks": [ { "type": "command", "command": ".claude/hooks/guard-geschuetzte-daten.sh" } ] } ] }
#
# Schutzmuster: eine Zeile je glob-Muster in .claude/geschuetzte-pfade
# (Kommentare mit #). Fehlt die Datei, gelten die Vorgaben unten.
#
# Bekannte Ueberdeckung: Der Guard unterscheidet nicht, ob "git add" ein Befehl
# oder Teil eines Zitats ist. Liegt gleichzeitig eine geschuetzte Datei im
# Arbeitsbaum, blockt er auch dann. Bewusst so — ein Fehlalarm kostet eine
# Nachfrage, ein Datenabfluss kostet mehr. Wer das anders gewichtet, verschaerft
# das Muster in der Zeile unten.
#
# Rueckgabe: 0 = durchlassen, 2 = blocken (Begruendung nach stderr).

set -uo pipefail

VORGABE_MUSTER=(
  '*.env'
  '.env'
  '.env.*'
  '*.pem'
  '*.key'
  '*.p12'
  '*.pfx'
  'id_rsa*'
  '*secrets*'
  '*credentials*'
  '.herkunft-begriffe'
  'shared/data/*'
  'seed/real/*'
)

eingabe=$(cat)

# Werkzeug-Eingabe kann als JSON kommen; ohne jq faellt der Guard auf den
# Rohtext zurueck — lieber grob pruefen als gar nicht.
if command -v jq >/dev/null 2>&1; then
  befehl=$(printf '%s' "$eingabe" | jq -r '.tool_input.command // empty' 2>/dev/null)
else
  befehl=""
fi
[ -z "$befehl" ] && befehl="$eingabe"

# Nur git-add-artige Befehle interessieren.
printf '%s' "$befehl" | grep -qE '(^|[;&|]|\s)git\s+(-[^ ]+\s+)*add(\s|$)' || exit 0

repo_wurzel=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$repo_wurzel" || exit 0

musterdatei=".claude/geschuetzte-pfade"
muster=()
if [ -f "$musterdatei" ]; then
  while IFS= read -r zeile; do
    zeile="${zeile%%#*}"
    zeile="$(printf '%s' "$zeile" | tr -d '[:space:]')"
    [ -n "$zeile" ] && muster+=("$zeile")
  done < "$musterdatei"
fi
[ ${#muster[@]} -eq 0 ] && muster=("${VORGABE_MUSTER[@]}")

# Kandidaten = alles, was ein Add ueberhaupt erfassen koennte:
# geaenderte und unverfolgte Dateien im Arbeitsbaum.
kandidaten=$(git status --porcelain --untracked-files=all 2>/dev/null | sed 's/^...//' | sed 's/.* -> //')
[ -z "$kandidaten" ] && exit 0

treffer=()
while IFS= read -r pfad; do
  [ -z "$pfad" ] && continue
  pfad="${pfad%\"}"; pfad="${pfad#\"}"
  basis="${pfad##*/}"
  for m in "${muster[@]}"; do
    # shellcheck disable=SC2053
    if [[ "$pfad" == $m || "$basis" == $m ]]; then
      treffer+=("$pfad")
      break
    fi
  done
done <<< "$kandidaten"

[ ${#treffer[@]} -eq 0 ] && exit 0

{
  echo "BLOCKIERT — geschuetzte Datei im Arbeitsbaum:"
  for t in "${treffer[@]}"; do echo "  - $t"; done
  echo
  echo "Dieser Befehl koennte sie der Versionsverwaltung hinzufuegen."
  echo "Erst .gitignore ergaenzen oder die Datei aus dem Arbeitsbaum nehmen,"
  echo "dann erneut versuchen. Schutzmuster: $musterdatei"
} >&2
exit 2
