#!/usr/bin/env python3
"""Vergleicht den Guard mit dem Ausgangsstand, ohne Shell-Code auszuführen."""
import json
import os
from pathlib import Path
import shlex
import subprocess
import tempfile

root = Path(__file__).resolve().parents[2]
new = Path(os.environ.get('GUARD', root / 'hooks/guard-geschuetzte-daten.sh')).resolve()
with tempfile.TemporaryDirectory() as tmp:
    tmp = Path(tmp)
    old = tmp / 'alt.sh'
    old.write_bytes(subprocess.check_output(['git', 'show', 'e983bd6:hooks/guard-geschuetzte-daten.sh'], cwd=root))
    old.chmod(0o755)
    log = tmp / 'vergleich.log'
    log.touch()
    wrapper = tmp / 'vergleich.sh'
    wrapper.write_text('''#!/bin/bash
input=$(/bin/cat)
printf '%s' "$input" | /bin/bash "$VERGLEICH_ALT" "$@" >/dev/null 2>&1
alt=$?
printf '%s' "$input" | /bin/bash "$VERGLEICH_NEU" "$@" >/dev/null 2>&1
neu=$?
if printf '%s' "$input" | jq -r '.tool_input.command // empty' | /usr/bin/grep -qE -- '(^|[;&|[:space:]])git[[:space:]]+(-C|--git-dir|--work-tree)([=[:space:]]|$)'; then
  art=Kontext
else
  art=Vergleich
fi
printf '%s %s %s\\n' "$art" "$alt" "$neu" >> "$VERGLEICH_LOG"
# Die Verdrahtungsprobe erwartet neben dem Exitcode eine Ausgabe.
echo "BLOCKIERT Vergleich: $art" >&2
exit "$neu"
''')
    wrapper.chmod(0o755)
    env = dict(os.environ, GUARD=str(wrapper), VERGLEICH_ALT=str(old), VERGLEICH_NEU=str(new), VERGLEICH_LOG=str(log))
    suite = tmp / 'suite.sh'
    source = subprocess.check_output(['git', 'show', 'e983bd6:hooks/tests/test-guard.sh'], cwd=root, text=True)
    source = source.replace('VORLAGEN="$(cd "$(dirname "$0")/.." && pwd)"', 'VORLAGEN=' + shlex.quote(str(root / 'hooks')))
    suite.write_text(source)
    result = subprocess.run(['bash', str(suite)], env=env, capture_output=True, text=True)
    print(result.stdout, end='')
    if result.returncode:
        raise SystemExit(result.returncode)
    repo = tmp / 'repo'
    repo.mkdir()
    subprocess.run(['git', 'init', '-q', str(repo)], check=True)
    commands = ["grep -rn 'TODO$' --exclude-dir=.git .", "git commit -m 'Preis 5$'",
                'echo x; git add "$f"', 'cd ../b && git add .env', '(git add .env)',
                'x=$(git rev-parse HEAD)', 'pushd ../b && git add .env',
                'make -C "$X"', 'tar -C "$d" -xf x', 'grep -C 3 "$m" f',
                'git --unknown add .env', 'git -c core.worktree=../b add *.dat']
    for protected in (False, True):
        if protected:
            (repo / '.env').touch()
        for command in commands:
            subprocess.run([str(wrapper)], input=json.dumps({'cwd': str(repo), 'tool_input': {'command': command}}),
                           text=True, env=env, capture_output=True)
    rows = [line.split() for line in log.read_text().splitlines()]
    compared = [row for row in rows if row[0] == 'Vergleich']
    failures = [row for row in compared if row[1] != row[2]]
    print(f'{len(compared)} Exitcode-Vergleiche ohne Kontextoption, {len(failures)} Abweichungen; '
          f'{len(rows) - len(compared)} Kontextaufrufe separat geprüft.')
    if failures:
        print(failures)
        raise SystemExit(1)
