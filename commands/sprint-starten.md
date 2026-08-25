---
description: Startet einen Sprint — Preflight, Statuswechsel, Abweichungs-Eintrag vor der ersten Änderung.
---

Starte den Sprint: $ARGUMENTS
(Ohne Angabe: den nächsten mit `status: geplant` aus `docs/plan/PLAN.md`.)

## Preflight — vor der ersten Änderung

Alles hier **vor** dem ersten Schreibzugriff. Scheitert ein Punkt, halte an und melde ihn.

1. `git status` — sauber, oder nur erwartete Reste des Vorgänger-Sprints?
2. Sprint-Datei lesen. Ziel, Nicht-Ziele, Write-Scope, Akzeptanzkriterien laut vorlesen (kurz).
3. `PLAN.md` lesen: gelten die Annahmen noch? Eine geänderte Annahme wird im Plan korrigiert, nicht
   stillschweigend übergangen.
4. Kein anderer Sprint mit `status: laufend` beansprucht überlappende Dateien.

## Abweichungen — ebenfalls vorher eintragen

Wird ein vorgesehener Schritt ausgelassen, kommt **vor** der Arbeit eine Zeile in die
Tabelle `## Abweichungen und Risikoabnahme` der Sprint-Datei:

| Datum | Ausgelassen | Begründung | Restrisiko | Abgenommen von |
|---|---|---|---|---|

Die letzte Spalte braucht einen **Namen**. Ein Restrisiko ohne Person dahinter ist keine
Abnahme, sondern eine Hoffnung — und im Assessment wertlos.

Nicht ausgelassen werden dürfen, unabhängig vom Zeitdruck, die Prüfungen zu:
Berechtigungen und Rollen · Datenmodell, Migrationen, reale Daten · Schlüsselmaterial und
Zugänge · Release- und Auslieferungspfade · Schnittstellen zu Fremdsystemen.

Wer hier auslassen will, ändert nicht die Tabelle, sondern eskaliert.

## Dann arbeiten

- `status: laufend` setzen.
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
