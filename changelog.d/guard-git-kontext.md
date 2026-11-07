Security
- **Git-Zielkontext:** Der Guard misst wiederholte `-C` sowie `--git-dir`/`--work-tree` im tatsächlichen Zielarbeitsbaum und verwendet dessen Schutzmuster. Physische Pfadauflösung berücksichtigt Symlinks und `..`; nicht auflösbare Kontexte blockieren mit Exit 2.
- Shell-Ausdrücke und `cd`-/`pushd`-Ketten werden weiterhin im Repo aus `cwd` gemessen.
- Die Kontextprüfung unterscheidet globale Optionswerte vom Git-Unterbefehl und sperrt gleichnamige Optionen anderer Programme nicht.
