#!/usr/bin/env bash
# stop-git-status.sh — Stop-Hook
#
# Zeigt am Ende eines Arbeitsschritts, was im Arbeitsbaum tatsaechlich anders
# ist. Zweck: der Assistent behauptet "fertig", dieser Hook zeigt die Wirkung —
# und zwar unabhaengig davon, was er behauptet hat.
#
# Einbindung (.claude/settings.json):
#   "hooks": { "Stop": [ { "hooks": [ { "type": "command",
#     "command": ".claude/hooks/stop-git-status.sh" } ] } ] }

set -uo pipefail
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

stand=$(git status --porcelain --untracked-files=all 2>/dev/null)
[ -z "$stand" ] && { echo "Arbeitsbaum sauber."; exit 0; }

echo "Geaendert / unverfolgt:"
printf '%s\n' "$stand" | sed 's/^/  /'
anzahl=$(printf '%s\n' "$stand" | wc -l | tr -d ' ')
echo "  ($anzahl Eintraege)"
exit 0
