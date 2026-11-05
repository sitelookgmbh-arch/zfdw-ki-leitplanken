Security
- **Git-Zielkontext:** Der Guard misst wiederholte `-C` sowie `--git-dir`/`--work-tree` im tatsächlichen Zielarbeitsbaum und verwendet dessen Schutzmuster. Nicht sicher auflösbare Kontexte blockieren mit Begründung.
- Physische Pfadauflösung berücksichtigt Symlinks und `..`; verkettete Verzeichniswechsel und Shell-Wrapper blockieren. Harmlose Dollarzeichen führen im sauberen Repo nicht mehr pauschal zur Sperre.
