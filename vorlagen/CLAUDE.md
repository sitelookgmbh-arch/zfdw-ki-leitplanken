# {{PROJEKT}} — Anweisungen für den KI-Assistenten

**Stand:** {{JJJJ-MM-TT}} · **Umfang:** {{KURZBESCHREIBUNG}}

> **Kontext-Budget.** Diese Datei wird bei **jedem** Turn vollständig geladen. Je länger sie wird,
> desto weniger wirkt jede Regel darin. Richtwert: **≤ 200 Zeilen**.
>
> | Gilt … | gehört … |
> |---|---|
> | bei fast jeder Änderung | **hierher** |
> | nie verhandelbar (Datenschutz, Secrets, Prod) | in einen **Hook** |
> | nur bei bestimmter Arbeit | in einen **Skill**, mit Anker hier |
> | auf Zuruf mit klarem Auftrag | in einen **Slash-Command** |
>
> Hintergrund: [Kontext-Budget](https://github.com/sitelookgmbh-arch/zfdw-ki-leitplanken/blob/main/methode/03_Kontext-Budget.md) ·
> [Schichten](https://github.com/sitelookgmbh-arch/zfdw-ki-leitplanken/blob/main/methode/02_Schichten-Anweisung-Hook-Skill.md)

---

## 1. Arbeitsweise (verbindlich)

1. **Verstehen** — erst lesen und prüfen, bevor etwas verändert wird.
2. **Zeigen** — den geplanten Schritt oder Befehl nennen.
3. **Ausführen.**
4. **Verifizieren** — mit der konkreten Prüfzeile. Erst bei Grün weiter.

**Irreversibles zweistufig:** erst zeigen, was passieren würde, dann auf Bestätigung ausführen.

**Nichts erfinden.** Pfade, Namen, Nummern, Versionen nicht raten — nachsehen oder fragen. Bei
Unsicherheit sauber abbrechen statt plausibel klingen. Jeder Befund mit Fundstelle (`Datei:Zeile`).

**Vorhaben > ein Commit ⇒ Sprint-Datei.** Was über mehrere Dateien, mehrere Sitzungen oder einen
Kontext-Reset läuft, bekommt **vor** dem ersten Commit `docs/plan/PLAN.md` plus je Abschnitt eine
`docs/plan/sprint-NN-<slug>.md`. Die Datei nennt Ziel, **Write-Scope**, Akzeptanzkriterien und
Versions-Relevanz — und ist zugleich der Stand. Schreiben außerhalb des Write-Scope: anhalten und
`BLOCKED (scope)` melden. `VERSION` fasst nur der Release-Sprint an.

**Secrets tippt der Mensch.** Passphrasen, Token, Zugangsdaten kommen nie in einen Chat und nie ins
Repo. Bei Versehen: rotieren, nicht nur löschen.

---

## 2. Was dieses Projekt ist

{{DREI_SAETZE}}

**Stack:** {{TECH}} · **Ausführung:** {{WO_LAEUFT_ES}} · **Daten:** {{DATENQUELLE}}

---

## 3. Rollen und Berechtigungen

{{TABELLE_ODER_ENTFERNEN}}

---

## 4. Repo-Layout

```
{{BAUM}}
```

---

## 5. Branches, Commits, Releases

- **`main` ist auslieferbar.** Branches: `feature/<kurz>`, `fix/<kurz>`. Kein Force-Push auf `main`.
- **Commits:** [Conventional Commits](https://www.conventionalcommits.org/de/v1.0.0/), ein Thema pro
  Commit.
- **Release:** {{RELEASE_WEG}}

---

## 6. Harte Grenzen

- {{GRENZE}} — durchgesetzt per Hook `{{HOOK}}`, nicht nur durch diesen Text.

---

## 7. Werkzeuge in diesem Projekt

**Hooks** (`.claude/hooks/`, deterministisch): {{LISTE}}
**Skills** (`.claude/skills/`, on demand): {{LISTE}}
**Commands** (`.claude/commands/`, auf Zuruf): {{LISTE}}
**Arbeitsplanung:** `docs/plan/` — Vorhaben und Sprints. Der Stand steht dort, nicht im Chat.

---

## 8. Wo alles andere steht

| Thema | Ort |
|---|---|
| Warum etwas so entschieden wurde | `docs/decisions/` |
| Was als Nächstes passiert | `docs/plan/` |
| Betrieb, Deploy, Notfall | `docs/runbook/` |
| Fachliche Konzepte, Datenmodell | `docs/concept/` |
