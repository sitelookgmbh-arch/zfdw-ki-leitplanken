---
description: Startet einen Sprint — Preflight, Statuswechsel, Routing-Log-Eintrag vor der ersten Änderung.
---

Starte den Sprint: $ARGUMENTS
(Ohne Angabe: den nächsten mit `status: planned` aus `docs/plan/PLAN.md`.)

## Preflight — vor der ersten Änderung

Alles hier **vor** dem ersten Schreibzugriff. Scheitert ein Punkt, halte an und melde ihn.

1. `git status` — sauber, oder nur erwartete Reste des Vorgänger-Sprints?
2. Sprint-Datei lesen. Ziel, Nicht-Ziele, Write-Scope, Akzeptanzkriterien laut vorlesen (kurz).
3. `PLAN.md` lesen: gelten die Annahmen noch? Eine geänderte Annahme wird im Plan korrigiert, nicht
   stillschweigend übergangen.
4. Kein anderer Sprint mit `status: in-progress` beansprucht überlappende Dateien.

## Routing-Eintrag — ebenfalls vorher

Trage **eine Zeile** in den `## Routing-Log` der Sprint-Datei ein, bevor du arbeitest:

```
- <Datum> | Weg: schlank|voll | Signale: <Risikosignale oder "keine"> | ausgelassen: <Schritt + Begründung, oder "keine">
```

Den **vollen** Weg (nichts abkürzen) erzwingt jedes dieser Signale — die Liste steht in der
Sprint-Datei und ist projektspezifisch: Authentifizierung und Berechtigungen · Datenmodell,
Migrationen, Realdaten · Build-/Release-Pipeline und Deploy · `VERSION`/`CHANGELOG.md` · neue Module,
Fremdschnittstellen, Breaking Changes.

Ohne Signal genügt der schlanke Weg. Aber: **jeder ausgelassene Schritt braucht seine Zeile.** Ein
unprotokollierter Skip ist von einer übersehenen Lücke nicht zu unterscheiden.

## Dann arbeiten

- `status: in-progress` setzen.
- Nur innerhalb des Write-Scope schreiben. Muss eine Datei außerhalb angefasst werden: **anhalten**,
  `BLOCKED (scope)` melden, den Write-Scope mit dem Menschen erweitern — nicht einfach tun.
- `VERSION` nicht anfassen.
- Nach jedem sinnvollen Zwischenstand: die Prüfzeile aus `## Verifikation` laufen lassen, nicht erst
  am Ende.
- Bei einer Entscheidung zwischen tragfähigen Alternativen, einer Geschmacksfrage ohne Kriterium
  oder einer widersprüchlichen Anforderung: Eintrag unter `## Menschliche Entscheidungen`, Optionen
  und Empfehlung nennen, fragen. Nicht selbst entscheiden, auch nicht mit einer zweiten Prüfrunde.
- Nach drei erfolglosen Korrekturrunden am selben Problem: abbrechen und den Menschen holen. Die
  vierte Runde findet erfahrungsgemäß nicht die Lösung, sondern eine neue Begründung.
