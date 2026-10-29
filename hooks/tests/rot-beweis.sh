#!/usr/bin/env bash
# Rot-Beweis fuer die Guard-Testsuite.
#
# Eine Suite, die gruen ist, beweist nur etwas, wenn sie auch rot werden kann.
# Dieses Skript baut absichtlich kaputte Fassungen des Guards ("Mutanten") und
# laesst die Suite gegen jede laufen. Jede Mutante muss mindestens einen
# Testfall rot machen. Bleibt die Suite bei einer Mutante gruen, hat sie an
# dieser Stelle einen blinden Fleck — dann fehlt ein Testfall, nicht ein Fix.
#
# Die Mutanten sind keine Zufallsauswahl: Jede ist der Rueckfall auf einen
# Fehler, den der Guard tatsaechlich einmal hatte oder haben koennte.
#
# Aufruf:  hooks/tests/rot-beweis.sh

set -uo pipefail
hier="$(cd "$(dirname "$0")" && pwd)"
original="$hier/../guard-geschuetzte-daten.sh"
suite="$hier/test-guard.sh"
werkstatt=$(mktemp -d)
trap 'rm -rf "$werkstatt"' EXIT
erkannt=0; blind=0

# Vorbedingung: Gegen das Original muss die Suite gruen sein. Sonst beweist
# ein Rot gegen die Mutanten nichts — es waere ohnehin rot.
if ! "$suite" >/dev/null 2>&1; then
  echo "Abbruch: Die Suite ist schon gegen den unveraenderten Guard rot."
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
  if GUARD="$datei" "$suite" >/dev/null 2>&1; then
    printf '  BLIND %-44s Suite bleibt gruen\n' "$name"; blind=$((blind+1))
  else
    printf '  rot   %-44s erkannt\n' "$name"; erkannt=$((erkannt+1))
  fi
}

echo "Mutanten gegen die Suite:"
# 1. Der Guard laesst alles durch (z. B. versehentlich auskommentiert).
mutante "laesst alles durch" 'NR==2{print "exit 0"} {print}'
# 2. Der Guard blockt alles (z. B. Muster zu breit) — wird in der Praxis abgeschaltet.
mutante "blockt alles" 'NR==2{print "exit 2"} {print}'
# 3. Fail-open: ohne jq still durchlassen statt blocken (frueheres Verhalten).
mutante "ohne jq still durchlassen" '/jq --version/{f=1} f && /exit 2/{sub(/exit 2/,"exit 0"); f=0} {print}'
# 4. git commit -a wird nicht mehr als Stage-Befehl erkannt (frueherer Stand).
mutante "commit -a nicht erkannt" '{sub(/ a\) alle=1 ;;/, " a) ;;")} {print}'
# 5. Schaetzen statt messen: --dry-run faellt weg, Rueckfall auf git status.
mutante "schaetzt mit git status" '{gsub(/roh=\$\(git add -(u|A) --dry-run 2>\/dev\/null\); rc=\$\?/, "roh=; rc=1")} {print}'
# 6. Pre-commit-Modus sieht den Index nicht (liest eine leere Kandidatenliste).
mutante "--staged sieht den Index nicht" '{sub(/git diff --cached --name-only --diff-filter=ACMR/, "true")} {print}'
# 7. Musterdatei unter .codex/ wird uebersehen (nur .claude/ gelesen).
mutante ".codex-Musterdatei uebersehen" '{sub(/ \.codex\/geschuetzte-pfade/, "")} {print}'
# 8. Alter Messweg: gezieltes git add misst wieder alles mit -A (Fehlalarm
#    bei harmlosem Pfad neben unverfolgter .env).
mutante "gezieltes add misst mit -A" '/add --dry-run \$\{mess_optionen/{print "    roh=$(git add -A --dry-run 2>/dev/null); rc=$?"; next} {print}'
# 9. Fail-closed beim Parsen entfernt: was sich nicht zerlegen laesst, wird
#    durchgelassen statt breit gemessen ($(…), Ketten).
mutante "unlesbarer Befehl durchgelassen" '{sub(/if zerlege "\$befehl" && /, "zerlege \"$befehl\" || exit 0; if ")} {print}'
# 10. Globale Optionen mit Wert (git -C <pfad> add) werden uebersprungen —
#     altes Erkennungsmuster.
mutante "git -C <pfad> add nicht erkannt" '/^  GIT_VOR=/{print; print "  GIT_VOR=\"(^|[;&|]|\\\\s)git\\\\s+(-[^ ]+\\\\s+)*\""; next} {print}'
# 11. git commit mit Pfadangaben stagt nichts (fruehere Annahme).
mutante "commit-Pfade nicht gemessen" '{sub(/mess_optionen\+=\(-u\); messart=gezielt/, "messart=keine")} {print}'
# 12. git -C <pfad> misst wieder im Repo-Stamm statt im Zielverzeichnis
#     (Fehlalarm bei git -C sub add . neben einer .env im Stamm).
mutante "git -C misst im Stamm" '{sub(/befehl_ort="\$ziel"; mit_c=1/, "mit_c=1")} {print}'
# 13. Relativer -C-Pfad gegen das Hook-Verzeichnis statt gegen cwd aufgeloest.
mutante "git -C relativ zum Hook statt cwd" '{sub(/ziel="\$befehl_ort\/\$\{tok\[2\]\}"/, "ziel=\"$PWD/${tok[2]}\"")} {print}'
# 14. Mehrere -C werden verrechnet, als zaehle nur das erste (fail-open:
#     git -C sub -C .. add . erfasst den Stamm, gemessen wuerde nur sub/).
mutante "mehrere -C: nur das erste zaehlt" '{sub(/tok=\(git "\$\{tok\[@\]:3\}"\)/, "tok=(git \"${tok[@]:3}\"); while [ \"${tok[1]:-}\" = -C ]; do tok=(git \"${tok[@]:3}\"); done")} {print}'

echo
echo "$erkannt erkannt, $blind blind"
[ "$blind" -eq 0 ]
