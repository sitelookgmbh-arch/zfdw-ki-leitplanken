#!/usr/bin/env bash
# Testsuite fuer werkzeuge/herkunft-check.sh
#
# Das Gate soll eine Veroeffentlichung verhindern. Es darf deshalb nur dann
# "kein Treffer" melden, wenn die Pruefung wirklich stattfand. Die Suite
# enthaelt drei Sorten Faelle: Treffer (Code 1), Nicht-Treffer (Code 0) und
# Pruefungsfehler (Code 3) — ungueltiges Muster, fehlendes oder unlesbares
# Ziel, scheiterndes oder fehlendes grep. Bei den Fehlerfaellen prueft sie
# auch die Meldung: Ein Code ungleich 0 allein sagt nicht, ob der richtige
# Fehler erkannt wurde.
#
# Die Begriffe sind synthetisch und gehoeren zur Suite, nicht zu einem Projekt.
#
# Aufruf:  werkzeuge/tests/test-herkunft.sh

set -uo pipefail
WERKZEUGE="$(cd "$(dirname "$0")/.." && pwd)"
HERKUNFT="${HERKUNFT:-$WERKZEUGE/herkunft-check.sh}"
BASH_BIN="$(command -v bash)"
ok=0; fehl=0

arbeitsplatz=$(mktemp -d)
trap 'chmod -R u+rwx "$arbeitsplatz" 2>/dev/null; rm -rf "$arbeitsplatz"' EXIT

ist_root=0
[ "$(id -u)" -eq 0 ] && ist_root=1

# neuer_baum <begriff>... — frischer Arbeitsbaum mit Begriffsdatei
neuer_baum() {
  chmod -R u+rwx "$arbeitsplatz" 2>/dev/null
  rm -rf "$arbeitsplatz/baum"
  mkdir -p "$arbeitsplatz/baum"
  cd "$arbeitsplatz/baum" || exit 1
  : > .herkunft-begriffe
  local b
  for b in "$@"; do printf '%s\n' "$b" >> .herkunft-begriffe; done
  echo "harmloser Inhalt" > harmlos.md
}

# pruefe <name> <erwarteter_code> <stderr-muster|-> <befehl...>
pruefe() {
  local name="$1" erwartet="$2" muster="$3" code fehler
  shift 3
  fehler=$("$@" 2>&1 >/dev/null); code=$?
  if [ "$code" -ne "$erwartet" ]; then
    printf '  FEHL  %-48s (Code %s, erwartet %s)\n' "$name" "$code" "$erwartet"; fehl=$((fehl+1)); return
  fi
  if [ "$muster" != "-" ] && ! printf '%s' "$fehler" | grep -qE -e "$muster"; then
    printf '  FEHL  %-48s (Code %s, Meldung ohne /%s/)\n' "$name" "$code" "$muster"; fehl=$((fehl+1)); return
  fi
  printf '  ok    %-48s (Code %s)\n' "$name" "$code"; ok=$((ok+1))
}

ueberspringe() {
  printf '  skip  %-48s (%s)\n' "$1" "$2"
}

echo "Nicht-Treffer (Code 0):"
neuer_baum "musterkunde" "beispiel (gmbh|ag)"
# Die Begriffsdatei liegt im Baum und enthaelt jeden Begriff: kein Treffer.
pruefe "sauberer Baum, Begriffsdatei ausgenommen" 0 - "$HERKUNFT" .
mkdir -p .git && echo "musterkunde" > .git/notiz
pruefe ".git/ wird nicht durchsucht"           0 - "$HERKUNFT" .
pruefe "einzelne saubere Datei als Ziel"        0 - "$HERKUNFT" harmlos.md
pruefe "--liste"                                0 - "$HERKUNFT" --liste

echo
echo "Treffer (Code 1):"
neuer_baum "musterkunde" "beispiel (gmbh|ag)"
echo "Bericht fuer MusterKunde" > bericht.md
pruefe "Treffer, Gross-/Kleinschreibung egal"   1 "Treffer" "$HERKUNFT" .
neuer_baum "beispiel (gmbh|ag)"
echo "Vertrag mit Beispiel GmbH" > vertrag.md
pruefe "Begriff mit innerem Leerzeichen"        1 "Treffer" "$HERKUNFT" .
pruefe "Treffer in einzelner Datei als Ziel"   1 "Treffer" "$HERKUNFT" vertrag.md
neuer_baum "-intern"
echo "Kennung x-intern" > liste.md
pruefe "Begriff beginnt mit Bindestrich"        1 "Treffer" "$HERKUNFT" .

echo
echo "Keine Begriffe (Code 2):"
neuer_baum "# nur ein Kommentar"
pruefe "Begriffsdatei ohne aktive Begriffe"     2 "keine Begriffe" "$HERKUNFT" .

echo
echo "Pruefungsfehler (Code 3, nie 'kein Treffer'):"
neuer_baum "["
pruefe "ungueltiges Muster [ "                  3 'Ungueltiges Muster.*: \[$' "$HERKUNFT" .
neuer_baum "musterkunde" "kaputt(" "beispiel"
pruefe "ein ungueltiges unter gueltigen"        3 'Ungueltiges Muster.*: kaputt\($' "$HERKUNFT" .
neuer_baum "musterkunde"
pruefe "Ziel existiert nicht"                   3 "Ziel nicht gefunden: gibtsnicht" "$HERKUNFT" gibtsnicht
if [ "$ist_root" -eq 0 ]; then
  echo "geheim" > zu.md && chmod 000 zu.md
  pruefe "Ziel-Datei unlesbar"                  3 "Ziel nicht lesbar" "$HERKUNFT" zu.md
  chmod 644 zu.md && rm -f zu.md
  mkdir zu && chmod 000 zu
  pruefe "Ziel-Verzeichnis unlesbar"            3 "Ziel nicht lesbar" "$HERKUNFT" zu
  chmod 755 zu && rmdir zu
  echo "musterkunde" > versteckt.md && chmod 000 versteckt.md
  pruefe "unlesbare Datei im Baum (grep rc 2)"  3 "grep gescheitert" "$HERKUNFT" .
  chmod 644 versteckt.md
else
  ueberspringe "Ziel-Datei unlesbar"            "als root nicht pruefbar"
  ueberspringe "Ziel-Verzeichnis unlesbar"      "als root nicht pruefbar"
  ueberspringe "unlesbare Datei im Baum"        "als root nicht pruefbar"
fi
neuer_baum "musterkunde"
leer=$(mktemp -d "$arbeitsplatz/leer.XXXXXX")
pruefe "grep fehlt im PATH"                     3 "grep nicht gefunden" env PATH="$leer" "$BASH_BIN" "$HERKUNFT" .

echo
echo "$ok ok, $fehl fehlgeschlagen"
[ "$fehl" -eq 0 ]
