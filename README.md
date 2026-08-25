# zfdw-arbeitsweise

**Eine Arbeitsweise für Projekte, in denen ein KI-Assistent mitbaut.** Kein Framework, keine
Installation, keine Abhängigkeiten — fünf Methoden-Dokumente, drei Vorlagen, vier Slash-Commands und
zwei Hooks, die man einzeln übernehmen kann.

| | |
|---|---|
| **Version** | v0.1.0 |
| **Werkzeug** | geschrieben für [Claude Code](https://claude.com/claude-code); die Methode gilt für jeden Assistenten mit Dateizugriff |
| **Sprache** | Deutsch |
| **Lizenz** | [Apache-2.0](LICENSE) — frei nutzbar, auch kommerziell |
| **Herausgeber** | **ZfdW** — Zentrum für digitale Wirkarchitektur · sitelook GmbH, Neuss |

---

## Wofür das gut ist

Ein KI-Assistent, der Code schreibt, ist nach zwei Wochen produktiver Nutzung an denselben vier
Stellen unzuverlässig:

1. **Er vergisst das Vorhaben.** Was im Chat-Verlauf steht, ist nach einem Kontext-Reset weg.
2. **Er baut mehr, als vereinbart war.** Aus „Login reparieren" wird ein Umbau der Navigation.
3. **Er hält sich nicht an Regeln, die nur als Text existieren.** Nicht aus Ungehorsam — die Regel
   konkurriert mit 600 anderen Zeilen im Kontext.
4. **Er meldet „fertig", wo „ungeprüft" richtig wäre.** Ein Statuscode 200 beweist nichts, ein
   Prüfskript ohne Voraussetzung meldet Grün.

Alle vier sind lösbar, und zwar mit Dateien im Repo statt mit Disziplin. Genau das steht hier.

## Der Kern in fünf Sätzen

1. Arbeit, die größer ist als ein Commit, bekommt eine **Sprint-Datei** — und diese Datei ist
   zugleich der Stand, nicht bloß ihre Beschreibung.
2. Jede Datei, die ein Sprint schreiben darf, steht in seinem **Write-Scope**. Wer außerhalb
   schreiben will, hält an.
3. Jede Regel hat einen richtigen Ort: **Anweisungsdatei, Hook, Skill oder Command** — und am
   falschen Ort wirkt sie nicht.
4. Was **nie** passieren darf, gehört in einen Hook. Ein Text ist ein Vorschlag an ein Sprachmodell.
5. Wer einen Schritt auslässt, **nennt ihn vorher.** Ein unprotokollierter Skip ist von einer
   übersehenen Lücke nicht zu unterscheiden.

## Was drin ist

```
methode/     die fünf Dokumente — das Warum
vorlagen/    PLAN.md, Sprint-Datei, Anweisungsdatei — das Was
commands/    /sprint-planen · /sprint-starten · /sprint-abschliessen · /review-aenderungen
hooks/       Guard gegen geschützte Daten + Turn-Ende-Signal, mit Testsuite
```

| Dokument | Beantwortet |
|---|---|
| [01 — Sprintplan mit Write-Scope](methode/01_Sprintplan-und-Write-Scope.md) | Wie überlebt ein Vorhaben den Kontext-Reset? |
| [02 — Schichten: Anweisung, Hook, Skill, Command](methode/02_Schichten-Anweisung-Hook-Skill.md) | Wohin gehört welche Regel, damit sie wirkt? |
| [03 — Kontext-Budget](methode/03_Kontext-Budget.md) | Warum eine lange Anweisungsdatei weniger bewirkt als eine kurze |
| [04 — Deterministische Guards](methode/04_Deterministische-Guards.md) | Was gehört in Code statt in einen Text? |
| [05 — Verifikation statt Behauptung](methode/05_Verifikation-statt-Behauptung.md) | Wann ist „fertig" belegt? |

## Anfangen — der kleinste sinnvolle Schritt

Nicht alles auf einmal. Die Reihenfolge, die sich bewährt hat:

**1. Der Guard, bevor irgendetwas anderes.** Er ist der einzige Teil, dessen Fehlen echten Schaden
anrichten kann:

```bash
mkdir -p .claude/hooks
cp hooks/guard-geschuetzte-daten.sh hooks/stop-git-status.sh .claude/hooks/
chmod +x .claude/hooks/*.sh
cp hooks/settings.json.vorlage .claude/settings.json
cp hooks/geschuetzte-pfade.vorlage .claude/geschuetzte-pfade
hooks/tests/test-guard.sh
```

Dann die Schutzmuster auf dein Projekt setzen. Die Vorgaben decken Secrets ab, **nicht deine
Kundendaten**.

**2. Die Anweisungsdatei kürzen.** Vorlage nach `CLAUDE.md`, Richtwert 200 Zeilen. Was rausfliegt,
wandert in einen Skill und hinterlässt einen Anker.

**3. Der erste Sprint.** Beim nächsten Vorhaben, das größer ist als ein Commit:

```bash
mkdir -p docs/plan
cp vorlagen/PLAN.md vorlagen/sprint-NN.md docs/plan/
cp commands/*.md .claude/commands/
```

Dann `/sprint-planen <dein Vorhaben>`.

**4. Alles andere später.** Wer mit allen vier Schritten gleichzeitig anfängt, hört nach dem zweiten
auf.

## Woher das kommt

**ZfdW** steht für *Zentrum für digitale Wirkarchitektur*. Wirkarchitektur heißt: Strukturen bauen,
die tatsächlich etwas bewirken — nicht solche, die im Dokument richtig aussehen. Diese Sammlung ist
die Arbeitsweise dahinter, und sie ist entlang derselben Frage geschnitten: **wirkt die Regel dort,
wo sie steht?** Eine Vorschrift in einer 600-Zeilen-Datei wirkt nicht. Ein Guard, der die Wirkung
eines Befehls prüft, wirkt.

Der Stoff kommt aus der Praxis eines Ein-Personen-Beratungsbetriebs, der Kundensoftware mit
KI-Unterstützung baut — also aus Projekten, in denen es keine zweite Person gibt, die den Fehler bemerkt, und kein Team,
das Prozess-Disziplin erzwingt. Deshalb der Zuschnitt: **so wenig Zeremonie wie möglich, aber die
harten Grenzen in Code.**

Der Sprintplan-Gedanke ist angeregt durch die Plan-First-Orchestrierung von
[CC_GodMode](https://github.com/cubetribe/ClaudeCode_GodMode-On) (Dennis Westermann) — dort
eingebettet in ein umfangreiches Agenten-System mit eigener Toolchain. Was hier steht, ist eine
eigenständige, deutlich schlankere Umsetzung ohne Laufzeit, ohne Agenten-Ensemble und ohne
Zustandsschema: die Datei im Repo ist der Zustand.

## Mitmachen

Verbesserungen gern als Pull-Request, Kritik als Issue. Was hier steht, ist bewusst **schmal und
begründet** — ein Vorschlag wird eher aufgenommen, wenn er einen konkreten Fehlschlag beschreibt, den
er verhindert hätte. Siehe [CONTRIBUTING.md](CONTRIBUTING.md).

## Was das hier nicht ist

- **Kein Agenten-Framework.** Es installiert nichts und startet nichts.
- **Kein Ersatz für Code-Review.** Es sorgt dafür, dass es etwas Prüfbares gibt.
- **Keine Garantie.** Apache-2.0, ohne Gewährleistung — wie jede Methode gilt sie, bis sie in deinem
  Projekt nicht mehr gilt. Dann gehört sie angepasst, nicht befolgt.
