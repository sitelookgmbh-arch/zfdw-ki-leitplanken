#!/usr/bin/env bash
# Testsuite fuer guard-geschuetzte-daten.sh
#
# Enthaelt bewusst BEIDE Sorten Faelle: Treffer (muss blocken) und
# Nicht-Treffer (darf nicht blocken). Ein Guard mit Fehlalarmen wird umgangen
# und schuetzt danach gar nichts mehr.
#
# Aufruf:  hooks/tests/test-guard.sh

set -uo pipefail
GUARD="$(cd "$(dirname "$0")/.." && pwd)/guard-geschuetzte-daten.sh"
ok=0; fehl=0

arbeitsplatz=$(mktemp -d)
trap 'rm -rf "$arbeitsplatz"' EXIT
cd "$arbeitsplatz" || exit 1
git init -q .
git config user.email t@example.invalid
git config user.name Test
echo "inhalt" > harmlos.md
mkdir -p src && echo "code" > src/app.ts

pruefe() { # name  erwarteter_code  befehl
  local name="$1" erwartet="$2" befehl="$3" code
  printf '{"tool_name":"Bash","tool_input":{"command":%s}}' "$(printf '%s' "$befehl" | sed 's/\\/\\\\/g; s/"/\\"/g; s/^/"/; s/$/"/')" \
    | "$GUARD" >/dev/null 2>&1
  code=$?
  if [ "$code" -eq "$erwartet" ]; then
    printf '  ok    %-46s (Code %s)\n' "$name" "$code"; ok=$((ok+1))
  else
    printf '  FEHL  %-46s (Code %s, erwartet %s)\n' "$name" "$code" "$erwartet"; fehl=$((fehl+1))
  fi
}

echo "Nicht-Treffer (duerfen NICHT blocken):"
pruefe "kein git-Befehl"                    0 "ls -la"
pruefe "git status"                         0 "git status"
pruefe "git commit -m 'x'"                  0 "git commit -m 'add feature'"
pruefe "git add einer harmlosen Datei"      0 "git add harmlos.md"
pruefe "Bulk-Add ohne geschuetzte Datei"    0 "git add -A"

echo
echo "Treffer (muessen blocken):"
echo "GEHEIM=1" > .env
pruefe ".env vorhanden, Bulk-Add -A"        2 "git add -A"
pruefe ".env vorhanden, git add ."          2 "git add ."
pruefe ".env direkt benannt"                2 "git add .env"
pruefe "Add in Befehlskette"                2 "npm run build && git add -A"
rm -f .env

mkdir -p shared/data && echo "kunde" > shared/data/echt.json
pruefe "shared/data/ per Bulk-Add"          2 "git add -A"
rm -rf shared

echo "-----BEGIN KEY-----" > deploy.pem
pruefe "Schluesseldatei"                    2 "git add -A"
rm -f deploy.pem

echo
echo "Bekannte Ueberdeckung (bewusst so):"
echo "GEHEIM=1" > .env
pruefe "'git add' im Zitat blockt ebenfalls" 2 "echo 'bitte git add nicht vergessen'"
rm -f .env

echo
echo "Eigene Musterdatei:"
mkdir -p .claude && printf '# eigene Muster\nkunden-*.csv\n' > .claude/geschuetzte-pfade
echo "a,b" > kunden-liste.csv
pruefe "eigenes Muster greift"              2 "git add -A"
rm -f kunden-liste.csv
echo "GEHEIM=1" > .env
pruefe "Vorgaben inaktiv bei eigener Datei" 0 "git add -A"
rm -f .env .claude/geschuetzte-pfade

echo
echo "$ok bestanden, $fehl fehlgeschlagen"
[ "$fehl" -eq 0 ]
