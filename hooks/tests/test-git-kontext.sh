#!/usr/bin/env bash
# Zwei unabhaengige Repos; alle Proben rufen nur den Guard auf.
set -uo pipefail
GUARD="${GUARD:-$(cd "$(dirname "$0")/.." && pwd)/guard-geschuetzte-daten.sh}"
platz=$(mktemp -d)
trap 'rm -rf "$platz"' EXIT
mkdir -p "$platz/start" "$platz/ziel/sub" "$platz/leer"
git init -q "$platz/start"
git init -q "$platz/ziel"
printf 'start.dat\n' > "$platz/start/.geschuetzte-pfade"
# Das Startrepo bleibt auch laut git status sauber, ohne einen Index anzulegen.
mkdir -p "$platz/start/.git/info"
printf '.geschuetzte-pfade\next\n' > "$platz/start/.git/info/exclude"
[ -z "$(git -C "$platz/start" status --porcelain)" ] || exit 1
printf '.env\nziel.dat\n' > "$platz/ziel/.geschuetzte-pfade"
touch "$platz/ziel/.env" "$platz/ziel/ziel.dat" "$platz/ziel/start.dat"
fehl=0
probe() {
  local name="$1" soll="$2" ort="$3" befehl="$4" code index
  jq -n --arg cwd "$ort" --arg command "$befehl" '{cwd:$cwd,tool_input:{command:$command}}' |
    "$GUARD" >/dev/null 2>"$platz/meldung"
  code=$?
  if [ "$code" -ne "$soll" ] || { [ "$soll" -eq 2 ] && ! grep -q BLOCKIERT "$platz/meldung"; }; then
    echo "FEHL $name: Exit $code, erwartet $soll"; fehl=$((fehl+1))
  else echo "ok $name: Exit $code"; fi
  for index in start ziel; do
    if [ -n "$(git -C "$platz/$index" ls-files --stage)" ] || [ -e "$platz/$index/.git/index" ]; then
      echo "FEHL Index $index veraendert"; fehl=$((fehl+1))
    fi
  done
}
probe 'fremdes Repo .env' "${ALT_ERWARTET:-2}" "$platz/start" "git -C '$platz/ziel' add .env"
probe 'direkt .env' 2 "$platz/ziel" 'git add .env'
if [ "${NUR_ROTPROBE:-0}" = 1 ]; then
  echo "Indexe nach jeder Probe leer und ohne Indexdatei; Fehler: $fehl"
  [ "$fehl" -eq 0 ]; exit $?
fi
probe 'Zielmuster gilt' 2 "$platz/start" "git -C '$platz/ziel' add ziel.dat"
probe 'Startmuster gilt nicht' 0 "$platz/start" "git -C '$platz/ziel' add start.dat"
probe 'mehrere relative -C' 2 "$platz/start" 'git -C ../ziel -C sub -C .. add .env'
probe 'absolutes -C nach relativem' 2 "$platz/start" "git -C ../ziel/sub -C '$platz/ziel' add .env"
probe 'Unterordner gezielt' 0 "$platz/start" 'git -C ../ziel -C sub add .'
probe 'leeres -C bleibt' 2 "$platz/start" "git -C ../ziel -C '' add .env"
probe 'Ziel ohne Repo' 2 "$platz/start" "git -C '$platz/leer' add ."
probe 'commit im Ziel ohne Repo' 2 "$platz/start" "git -C '$platz/leer' commit -m x"
probe 'Start ohne Repo, Ziel gueltig' 2 "$platz/leer" "git -C '$platz/ziel' add .env"
probe 'Ziel fehlt' 2 "$platz/start" 'git -C ../fehlt add .'
probe 'Variable' 2 "$platz/start" 'git -C "$ZIEL" add .env'
probe 'Kette' 2 "$platz/start" 'true && git -C ../ziel add .env'
ln -s "$platz/ziel/sub" "$platz/start/ext"
probe 'Symlink mit ..' 2 "$platz/start" 'git -C ext/.. add .env'
probe 'logisches cwd mit ..' 2 "$platz/start/ext" 'git -C .. add .env'
probe 'git-dir/work-tree getrennt' 2 "$platz/start" "git --git-dir '$platz/ziel/.git' --work-tree '$platz/ziel' add .env"
probe 'relative Kontextoptionen nach -C' 2 "$platz/start" 'git --git-dir=.git --work-tree=. -C ../ziel add .env'
probe 'git-dir/work-tree harmlos' 0 "$platz/start" 'git -C ../ziel --git-dir=.git --work-tree=. add start.dat'
probe 'git-dir fehlt' 2 "$platz/start" 'git --git-dir=../fehlt --work-tree=../ziel add .env'
echo "Indexe nach jeder Probe leer und ohne Indexdatei; Fehler: $fehl"
[ "$fehl" -eq 0 ]
