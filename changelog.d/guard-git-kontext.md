Security
- **Git-Zielkontext:** Der Guard misst wiederholte `-C` sowie `--git-dir`/`--work-tree` im tatsächlichen Zielarbeitsbaum und verwendet dessen Schutzmuster. Nicht sicher auflösbare Kontexte blockieren mit Begründung.
- Physische Pfadauflösung berücksichtigt Symlinks und `..`; verkettete Verzeichniswechsel und Shell-Wrapper blockieren. Zerlegbare Befehle mit wörtlichen Dollarzeichen in einfachen Anführungszeichen bleiben erlaubt; andere Git-Unterbefehle werden bei anschlagendem Vorfilter breit im Zielkontext gemessen.
- **Bewusste Verschärfung:** Nicht zerlegbare Git-Befehle mit Dollarzeichen oder Backticks blockieren auch im sauberen Repo, einschließlich `git commit -m "Preis 5$"` und Commit-Nachrichten über Heredoc-Substitution. Expansionen werden nicht ausgeführt.
