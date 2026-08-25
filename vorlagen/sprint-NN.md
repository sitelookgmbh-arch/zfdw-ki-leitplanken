---
sprint: NN
slug: {{KURZ_SLUG}}
plan: docs/plan/PLAN.md
status: planned            # planned | in-progress | review | done | blocked
ausfuehrung: seriell       # seriell | parallel (parallel nur bei disjunktem Write-Scope)
verantwortlich: {{NAME}}
---

# Sprint NN — {{TITEL}}

> Kopieren nach `docs/plan/sprint-NN-<slug>.md`. Diese Datei **ist** der Stand des Sprints — es gibt
> keinen zweiten Zustandsspeicher daneben.

## Ziel

Ein Absatz: was dieser Sprint erreicht, und warum jetzt.

## Umfang

- Konkrete Aufgabe 1
- Konkrete Aufgabe 2

## Ausdrücklich nicht Umfang

Was hier bewusst **nicht** passiert. Verhindert Scope-Drift und Kollisionen mit Nachbar-Sprints.
„Nichts" ist selten die richtige Antwort — mindestens ein Punkt.

## Write-Scope (wer schreibt was)

| Pfad / Muster | Schreiber | Anmerkung |
|---|---|---|
| `{{pfad}}` | {{NAME}} | |

Regeln:

- Jede Datei, die dieser Sprint **schreiben** darf, steht hier. Schreiben außerhalb ⇒ **anhalten**
  und `BLOCKED (scope)` melden, nicht stillschweigend erweitern.
- Heiße Dateien — `VERSION`, `CHANGELOG.md`, `README.md`, die Anweisungsdatei, Plan-Dateien — haben
  **genau einen** Schreiber und werden nie in parallelen Sprints angefasst.
- Vor jeder Parallelisierung: Write-Scopes gegeneinander halten. Überschneidung ⇒ seriell.

## Risiken

- Risiko → Gegenmaßnahme.
- Berührt der Sprint Realdaten, Secrets, Berechtigungen oder das Produktivsystem? Dann hier benennen.

## Akzeptanzkriterien

- [ ] Nachprüfbares Kriterium 1
- [ ] Nachprüfbares Kriterium 2

„Nachprüfbar" heißt: es gibt eine Zeile, die man ausführen, oder einen Schritt, den man ansehen kann
— nicht „funktioniert wieder".

## Verifikation

Wie das Ergebnis geprüft wird, mit den konkreten Zeilen (Build, Testlauf, Abruf, Konfigurationstest).
Bei Oberflächenänderungen: echter Start im Release-Zustand, nicht nur ein Statuscode.

## Routing-Log

Eine Zeile je Entscheidung über den Weg **und** je ausgelassenem Schritt — notiert **vorher**, nicht
hinterher:

```
- <Datum> | Weg: schlank|voll | Signale: <Risikosignale oder "keine"> | ausgelassen: <Schritt + Begründung, oder "keine">
```

Risikosignale, die den **vollen** Weg erzwingen (nichts abkürzen) — projektspezifisch anpassen:

- Authentifizierung, Berechtigungen, Rollenlogik
- Datenmodell, Migrationen, Seed- und Realdaten
- Build-/Release-Pipeline, Deploy-Pfade, Serverkonfiguration
- `VERSION`, `CHANGELOG.md`, Release-Artefakte
- neue Module, Schnittstellen zu Fremdsystemen, Breaking Changes

Beispiel:

```
- 2026-08-25 | Weg: schlank | Signale: keine | ausgelassen: Sicherheitsreview (reine Textänderung in docs/, nichts Ausgeliefertes betroffen)
- 2026-08-26 | Weg: voll | Signale: Auth-Dienst, VERSION | ausgelassen: keine
```

Ein ausgelassener Schritt **ohne** Zeile hier ist von einer übersehenen Lücke nicht zu unterscheiden
und gilt im Review als Mangel.

## Changelog-Notiz

Ein Stichpunkt für `CHANGELOG.md` `[Unreleased]` — eingetragen beim Abschluss, vom festgelegten
Changelog-Schreiber.

## Versions-Relevanz

`keine | patch | minor | major` — mit einer Zeile Begründung.

`VERSION` wird in einem normalen Sprint **nicht** angefasst. Der Release-Sprint sammelt diese Felder
ein und setzt die Zahl; die höchste Relevanz gewinnt.

## Preflight (beim Sprint-Start prüfen)

- [ ] `git status` sauber (oder nur erwartete Reste des Vorgänger-Sprints)
- [ ] `PLAN.md` noch gültig — Annahmen seit der Planung unverändert?
- [ ] Kein laufender Sprint beansprucht überlappende Dateien

## Ergebnis (beim Abschluss ausfüllen)

Was tatsächlich passiert ist, Abweichungen vom Plan, offene Folgepunkte. Erst danach `status: done`.

## Menschliche Entscheidungen

Was während des Sprints an den Menschen ging oder noch geht: Wahl zwischen tragfähigen Alternativen,
Geschmacksfrage ohne prüfbares Kriterium, widersprüchliche Anforderung. Je Eintrag: Optionen ·
Abwägung · Empfehlung · Entscheidung + Datum. „Keine" ist eine gültige Antwort.
