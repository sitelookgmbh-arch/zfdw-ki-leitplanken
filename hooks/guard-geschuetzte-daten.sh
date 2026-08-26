#!/usr/bin/env bash
# guard-geschuetzte-daten.sh — PreToolUse-Hook (Bash)
#
# Blockt Versuche, geschuetzte Dateien in die Versionsverwaltung zu bringen.
#
# Prueft die WIRKUNG des Befehls, nicht seinen Wortlaut: bei einem Bulk-Add
# (`git add -A`, `git add .`, `git add -u`, `git commit -am`) taucht der
# Dateiname im Befehl gar nicht auf — genau dort versagt jede textuelle Regel.
# Der Guard misst deshalb mit `git add --dry-run`, was der Befehl tatsaechlich
# stagen wuerde. Gemessen, nicht geschaetzt.
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

# jq ist Pflicht — und zwar funktionierendes jq, nicht nur vorhandenes.
# Ohne jq laesst sich die Kommandozeile nicht sauber aus dem Werkzeug-Aufruf
# lesen; der Guard wuerde auf Rohtext raten und im Zweifel nichts finden. Ein
# Guard, der auf einem frisch aufgesetzten Rechner unbemerkt abgeschaltet ist,
# ist schlimmer als keiner — deshalb blockt er hier, statt still durchzulassen.
if ! jq --version >/dev/null 2>&1; then
  {
    echo "BLOCKIERT — Guard nicht einsatzfaehig: jq fehlt oder ist defekt."
    echo "Ohne jq prueft dieser Hook nichts mehr, ohne dass es auffaellt."
    echo "Installieren: brew install jq (macOS) bzw. apt install jq, dann erneut versuchen."
  } >&2
  exit 2
fi

befehl=$(printf '%s' "$eingabe" | jq -r '.tool_input.command // empty' 2>/dev/null)
[ -z "$befehl" ] && befehl="$eingabe"

# Nur Befehle interessieren, die etwas in die Versionsverwaltung bringen
# koennen: git add in jeder Form — und git commit -a, das Aenderungen an
# bereits verfolgten Dateien selbst stagt.
printf '%s' "$befehl" | grep -qE '(^|[;&|]|\s)git\s+(-[^ ]+\s+)*add(\s|$)' \
  || printf '%s' "$befehl" | grep -qE '(^|[;&|]|\s)git\s+commit([^;&|]*)?\s-[A-Za-z]*a' \
  || exit 0

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

# Kandidaten: was der Befehl TATSAECHLICH stagen wuerde — gemessen mit
# `git add --dry-run`, nicht geschaetzt mit `git status`. Der Unterschied ist
# nicht kosmetisch: `git status` weiss nichts darueber, ob eine Datei vom
# Befehl ueberhaupt erfasst wuerde, und beruecksichtigt .gitignore nicht.
#
#   -u / --update / commit -a  -> nur bereits Verfolgtes
#   alles andere               -> auch Unverfolgtes
#
# Ohne diese Unterscheidung kommt ein Fehlalarm garantiert: `git add -u` bei
# gleichzeitig herumliegender, unverfolgter .env. Und ein Guard, der grundlos
# blockt, wird abgeschaltet — danach schuetzt er gar nichts mehr.
if printf '%s' "$befehl" | grep -qE '(^|[;&|]|\s)git\s+(-[^ ]+\s+)*add\s+(-u|--update)(\s|$)' \
   || printf '%s' "$befehl" | grep -qE '(^|[;&|]|\s)git\s+commit([^;&|]*)?\s-[A-Za-z]*a'; then
  roh=$(git add -u --dry-run 2>/dev/null); rc=$?
else
  roh=$(git add -A --dry-run 2>/dev/null); rc=$?
fi

if [ "$rc" -ne 0 ]; then
  # Rueckfall nur bei echtem Fehlschlag (alter git, Sonderzustand). Ein LEERES
  # Messergebnis ist kein Fehlschlag, sondern die Aussage "nichts betroffen".
  kandidaten=$(git status --porcelain --untracked-files=all 2>/dev/null | sed 's/^...//' | sed 's/.* -> //')
else
  # Zeilenformat: add 'pfad' / remove 'pfad'. Nur Hinzufuegen interessiert.
  kandidaten=$(printf '%s\n' "$roh" | sed -n "s/^add '\(.*\)'$/\1/p")
fi
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
