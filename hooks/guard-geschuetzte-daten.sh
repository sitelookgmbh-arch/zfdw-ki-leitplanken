#!/usr/bin/env bash
# guard-geschuetzte-daten.sh — PreToolUse-Hook (Bash)
#
# Blockt Versuche, geschuetzte Dateien in die Versionsverwaltung zu bringen.
#
# Prueft die WIRKUNG des Befehls, nicht seinen Wortlaut: bei einem Bulk-Add
# (`git add -A`, `git add .`, `git add -u`, `git commit -am`) taucht der
# Dateiname im Befehl gar nicht auf — genau dort versagt jede textuelle Regel.
# Der Guard misst deshalb mit `git add --dry-run`, was der Befehl tatsaechlich
# stagen wuerde. Gemessen, nicht geschaetzt. Nennt ein schlichter Befehl
# woertliche Pfade (`git add notiz.md`, `git commit -m x datei`), misst er nur
# diese; alles, was er nicht sicher zerlegen kann, misst er breit wie bisher.
#
# Einbindung (.claude/settings.json):
#   "hooks": { "PreToolUse": [ { "matcher": "Bash",
#     "hooks": [ { "type": "command", "command": ".claude/hooks/guard-geschuetzte-daten.sh" } ] } ] }
#
# Codex liefert dasselbe Eingabeformat (tool_input.command, Exit 2 blockt):
#   .codex/hooks.json — siehe hooks/codex-hooks.json.vorlage
# Beide liefern zusaetzlich cwd: dort laeuft der Befehl, dort gelten seine Pfade.
#
# Als git pre-commit-Hook (fuer jeden Assistenten und fuer Menschen):
#   guard-geschuetzte-daten.sh --staged
# prueft dann, was bereits gestagt ist — siehe hooks/pre-commit.vorlage
#
# Schutzmuster: eine Zeile je glob-Muster, gesucht in dieser Reihenfolge:
# .claude/geschuetzte-pfade, .codex/geschuetzte-pfade, .geschuetzte-pfade
# (Kommentare mit #). Fehlt jede davon, gelten die Vorgaben unten.
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

modus=hook
[ "${1:-}" = "--staged" ] && modus=staged

# Im Hook-Modus kommt der Werkzeugaufruf als JSON ueber stdin. Im Modus
# --staged (git pre-commit) gibt es keinen Befehl zu lesen, nur den Index.
if [ "$modus" = hook ]; then
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
  # Wo der Befehl laeuft: Claude Code und Codex liefern das Feld cwd. Relative
  # Pfade im Befehl gelten dort, nicht zwingend im Arbeitsverzeichnis des Hooks.
  befehl_ort=$(printf '%s' "$eingabe" | jq -r '.cwd // empty' 2>/dev/null)
  mess_ort="$befehl_ort"

  # Nur Befehle interessieren, die etwas in die Versionsverwaltung bringen
  # koennen: git add in jeder Form — und git commit, das mit -a oder mit
  # Pfadangaben selbst stagt. GIT_VOR deckt globale Optionen vor dem
  # Unterbefehl ab, auch solche mit Wert (`git -C <pfad> add`, `git -c k=v add`).
  # Lieber eine Option zu viel als Wert lesen als einen git-Aufruf uebersehen.
  GIT_VOR='(^|[;&|]|\s)git\s+(-\S*(\s+("[^"]*"|'"'"'[^'"'"']*'"'"'|[^-[:space:];&|]\S*))?\s+)*'
  # Expansionen werden nie ausgefuehrt. Sie koennen auch den Unterbefehl
  # liefern; deshalb unabhaengig vom woertlichen git-Muster breit messen.
  substitution=0
  case "$befehl" in *['$`']*) substitution=1 ;; esac
  [ "$substitution" -eq 1 ] \
    || printf '%s' "$befehl" | grep -qE "${GIT_VOR}add(\s|$)" \
    || printf '%s' "$befehl" | grep -qE "${GIT_VOR}commit(\s|$)" \
    || exit 0
  case "$mess_ort" in
    /*) [ -d "$mess_ort" ] || exit 2 ;;
    *) echo "BLOCKIERT — cwd fehlt oder ist ungueltig." >&2; exit 2 ;;
  esac
fi

# zerlege BEFEHL — zerlegt einen EINFACHEN Befehl in Woerter (Array tok).
# Rueckgabe 1, sobald etwas nicht sicher zu lesen ist: Kette, Pipe, Umleitung,
# Subshell, $Variable, $(…), Backticks, Backslash, Glob, Klammern, Tilde,
# Kommentar, Zeilenumbruch ausserhalb von Anfuehrungszeichen. Bewusst eine
# Positivliste: Was hier nicht ausdruecklich erlaubt ist, gilt als unlesbar —
# und unlesbar heisst: so breit messen wie vor der gezielten Messung.
zerlege() {
  local rest="$1" teil lauf wort="" begonnen=0
  tok=()
  # Stueckweise statt zeichenweise: bash 3.2 (macOS) braucht fuer ${s:i:1}
  # lineare Zeit je Zugriff — bei langen Commit-Nachrichten waeren das Sekunden.
  while [ -n "$rest" ]; do
    case "$rest" in
      [' '$'\t']*)
        if [ "$begonnen" -eq 1 ]; then tok+=("$wort"); wort=""; begonnen=0; fi
        rest="${rest:1}" ;;
      "'"*)
        teil="${rest:1}"
        case "$teil" in *"'"*) ;; *) return 1 ;; esac
        wort+="${teil%%\'*}"; begonnen=1; rest="${teil#*\'}" ;;
      '"'*)
        teil="${rest:1}"
        case "$teil" in *'"'*) ;; *) return 1 ;; esac
        lauf="${teil%%\"*}"
        case "$lauf" in *['$`\']*) return 1 ;; esac
        wort+="$lauf"; begonnen=1; rest="${teil#*\"}" ;;
      [A-Za-z0-9._/@+,=:%-]*)
        lauf="${rest%%[!A-Za-z0-9._/@+,=:%-]*}"
        wort+="$lauf"; begonnen=1; rest="${rest#"$lauf"}" ;;
      *) return 1 ;;
    esac
  done
  [ "$begonnen" -eq 1 ] && tok+=("$wort")
  return 0
}

# Eine Pfadangabe, die gezielt gemessen werden darf: woertlich, ohne
# git-Pathspec-Magie (:/, :(glob)…), ohne Platzhalter, nicht "." und nicht leer.
# Alles andere misst der Guard breit.
# Ausnahme: Nach einem gelesenen `git -C <pfad>` gilt "." als messbar. Dann
# misst der Guard ohnehin im Zielverzeichnis, und "." ist genau dieses.
gezielt_messbar() {
  case "$1" in
    .) [ "$mit_c" -eq 1 ] && return 0; return 1 ;;
    '' | :* | *[*?[]*) return 1 ;;
  esac
  return 0
}

# messart: alt | breit_A | breit_u | gezielt | keine
#   alt     — Befehl nicht sicher zerlegbar: Regeln wie vor der gezielten Messung
#   gezielt — `git add|commit … -- <pfade>`: nur diese Pfade messen
messart=alt
mess_optionen=()
pfade=()
mit_c=0   # 1, wenn genau ein woertliches `git -C <pfad>` gelesen wurde

pruefe_add() { # wertet tok[2..] eines `git add` aus
  local a nach_dd=0 zwang=0 nur_verfolgt=0 breit=0
  for a in "${tok[@]:2}"; do
    if [ "$nach_dd" -eq 0 ]; then
      case "$a" in
        --) nach_dd=1; continue ;;
        -f | --force) zwang=1; continue ;;
        -u | --update) nur_verfolgt=1; continue ;;
        -v | --verbose) continue ;;
        -*) messart=alt; return ;;   # -A, --all, -p, -N, --pathspec-from-file …
      esac
    fi
    gezielt_messbar "$a" || breit=1
    pfade+=("$a")
  done
  if [ "${#pfade[@]}" -eq 0 ] || [ "$breit" -eq 1 ]; then
    if [ "$nur_verfolgt" -eq 1 ]; then messart=breit_u; else messart=breit_A; fi
    return
  fi
  [ "$zwang" -eq 1 ] && mess_optionen+=(-f)
  [ "$nur_verfolgt" -eq 1 ] && mess_optionen+=(-u)
  messart=gezielt
}

pruefe_commit() { # wertet tok[2..] eines `git commit` aus
  local a b j nach_dd=0 wert_folgt=0 alle=0 breit=0
  for a in "${tok[@]:2}"; do
    if [ "$wert_folgt" -eq 1 ]; then wert_folgt=0; continue; fi
    if [ "$nach_dd" -eq 1 ]; then
      gezielt_messbar "$a" || breit=1; pfade+=("$a"); continue
    fi
    case "$a" in
      --) nach_dd=1 ;;
      --all) alle=1 ;;
      --pathspec-from-file | --pathspec-from-file=*) breit=1 ;;
      # Optionen mit Wert im naechsten Wort. Eine hier fehlende Option wird als
      # Pfad gelesen und gemessen — die sichere Richtung.
      --message | --file | --reuse-message | --reedit-message | --fixup | --squash | \
      --author | --date | --template | --cleanup | --trailer) wert_folgt=1 ;;
      --*) ;;
      -?*)
        b="${a#-}"
        for ((j = 0; j < ${#b}; j++)); do
          case "${b:j:1}" in
            a) alle=1 ;;
            m | F | C | c | t) [ $((j + 1)) -lt ${#b} ] || wert_folgt=1; break ;;
            S | u) break ;;   # optionaler Wert, nur angehaengt
          esac
        done ;;
      *) gezielt_messbar "$a" || breit=1; pfade+=("$a") ;;
    esac
  done
  # commit stagt nur bereits Verfolgtes: mit -a alles, mit Pfaden diese Pfade.
  if [ "$alle" -eq 1 ] || [ "$breit" -eq 1 ]; then messart=breit_u
  elif [ "${#pfade[@]}" -gt 0 ]; then mess_optionen+=(-u); messart=gezielt
  else messart=keine
  fi
}

if [ "$modus" = hook ]; then
  if [ "$substitution" -eq 0 ] && zerlege "$befehl" && [ "${tok[0]:-}" = git ]; then
    # Genau ein vorangestelltes `git -C <pfad>` mit woertlichem Pfad: git
    # wechselt vor dem Unterbefehl in <pfad>, dort gelten Pfade und ".". Der
    # Guard misst dann ebenda. Nur wenn das Verzeichnis existiert; sonst bleibt
    # tok unveraendert, tok[1] ist "-C", und es gilt messart=alt (breit).
    # Ein zweites -C oder eine weitere globale Option steht danach in tok[1]
    # und faellt ebenso auf alt — mehrere -C werden nicht verrechnet.
    if [ "${tok[1]:-}" = -C ] && [ "${#tok[@]}" -ge 4 ] && [ -n "${tok[2]}" ]; then
      case "${tok[2]}" in
        /*) ziel="${tok[2]}" ;;
        *) ziel="$befehl_ort/${tok[2]}" ;;
      esac
      if [ -d "$ziel" ]; then
        befehl_ort="$ziel"; mit_c=1
        tok=(git "${tok[@]:3}")
      fi
    fi
    case "${tok[1]:-}" in
      add) pruefe_add ;;
      commit) pruefe_commit ;;
    esac
  fi
  # Nicht zerlegbar oder kein schlichtes `git add|commit`: messart bleibt alt.
  [ "$messart" = keine ] && exit 0
fi

if [ "$modus" = hook ]; then
  cd "$mess_ort" || exit 2
fi
repo_wurzel=$(git rev-parse --show-toplevel 2>/dev/null) || {
  [ "$modus" = hook ] && exit 2
  exit 0
}
cd "$repo_wurzel" || exit 0

musterdatei=".claude/geschuetzte-pfade"
for kandidat in .claude/geschuetzte-pfade .codex/geschuetzte-pfade .geschuetzte-pfade; do
  if [ -f "$kandidat" ]; then musterdatei="$kandidat"; break; fi
done
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
if [ "$modus" = staged ]; then
  # Was schon im Index liegt — hinzugefuegt oder geaendert.
  kandidaten=$(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null)
else
  if [ "$messart" = alt ]; then
    # Wie vor der gezielten Messung: -u bzw. commit -a misst Verfolgtes, jedes
    # andere git add alles, ein unlesbares git commit (Pfade moeglich) Verfolgtes.
    if [ "$substitution" -eq 1 ]; then
      messart=breit_A
    elif printf '%s' "$befehl" | grep -qE "${GIT_VOR}add\s+(-u|--update)(\s|$)" \
       || printf '%s' "$befehl" | grep -qE "${GIT_VOR}commit([^;&|]*)?\s-[A-Za-z]*a"; then
      messart=breit_u
    elif printf '%s' "$befehl" | grep -qE "${GIT_VOR}add(\s|$)"; then
      messart=breit_A
    else
      messart=breit_u
    fi
  fi

  if [ "$messart" = gezielt ] \
     && [ "$(git -C "$befehl_ort" rev-parse --show-toplevel 2>/dev/null)" != "$repo_wurzel" ]; then
    # Der Befehl laeuft nicht in diesem Repo: nicht gezielt messbar.
    messart=breit_A
  fi

  if [ "$messart" = gezielt ]; then
    # Nur die Pfade des Befehls, gemessen dort, wo der Befehl laeuft. Ausgabe
    # ist relativ zur Repo-Wurzel. Fehlt ein Pfad, scheitert der Trockenlauf
    # (rc != 0) — dann greift unten der Rueckfall auf den ganzen Arbeitsbaum.
    roh=$(git -C "$befehl_ort" add --dry-run ${mess_optionen[@]+"${mess_optionen[@]}"} -- "${pfade[@]}" 2>/dev/null); rc=$?
  elif [ "$messart" = breit_u ]; then
    roh=$(git add -u --dry-run 2>/dev/null); rc=$?
  else
    roh=$(git add -A --dry-run 2>/dev/null); rc=$?
  fi

  if [ "$rc" -ne 0 ]; then
    # Rueckfall nur bei echtem Fehlschlag (alter git, Sonderzustand, Pfad
    # existiert nicht). Ein LEERES Messergebnis ist kein Fehlschlag, sondern
    # die Aussage "nichts betroffen".
    kandidaten=$(git status --porcelain --untracked-files=all 2>/dev/null | sed 's/^...//' | sed 's/.* -> //')
  else
    # Zeilenformat: add 'pfad' / remove 'pfad'. Nur Hinzufuegen interessiert.
    kandidaten=$(printf '%s\n' "$roh" | sed -n "s/^add '\(.*\)'$/\1/p")
  fi
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
  if [ "$modus" = staged ]; then echo "BLOCKIERT — geschuetzte Datei im Index:"; else echo "BLOCKIERT — geschuetzte Datei im Arbeitsbaum:"; fi
  for t in "${treffer[@]}"; do echo "  - $t"; done
  echo
  if [ "$modus" = staged ]; then
    echo "Sie liegt bereits im Index — dieser Commit wuerde sie aufnehmen."
    echo "Aus dem Index nehmen: git restore --staged <datei>"
  else
    echo "Dieser Befehl koennte sie der Versionsverwaltung hinzufuegen."
  fi
  echo "Erst .gitignore ergaenzen oder die Datei aus dem Arbeitsbaum nehmen,"
  echo "dann erneut versuchen. Schutzmuster: $musterdatei"
} >&2
exit 2
