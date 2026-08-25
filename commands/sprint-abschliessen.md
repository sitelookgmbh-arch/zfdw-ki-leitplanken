---
description: Schließt einen Sprint ab — Akzeptanzkriterien prüfen, Ergebnis schreiben, Changelog-Notiz, Status auf done.
---

Schließe den Sprint ab: $ARGUMENTS
(Ohne Angabe: den Sprint mit `status: laufend`.)

## Reihenfolge — `status: abgeschlossen` kommt zuletzt

1. **Akzeptanzkriterien durchgehen.** Jedes einzeln, mit Beleg: die ausgeführte Zeile und ihre
   Ausgabe, oder die angesehene Stelle. Ein Kriterium ohne Beleg gilt als nicht erfüllt.
   Nicht erfüllte Kriterien werden **nicht** abgehakt, sondern im Ergebnis benannt.

2. **Write-Scope gegenprüfen.** `git diff --name-only <basis>...HEAD` gegen die Write-Scope-Tabelle
   halten. Jede Datei im Diff, die dort nicht steht, wird benannt — mit einer Erklärung, wie sie
   hineingekommen ist. Das ist kein Formalismus: genau hier zeigt sich Scope-Drift.

3. **Abweichungen prüfen.** Hat jeder ausgelassene Schritt seine Zeile? Fehlt eine, jetzt nachtragen —
   mit dem Hinweis, dass sie nachgetragen wurde.

4. **`## Ergebnis` schreiben.** Was tatsächlich passiert ist, Abweichungen vom Plan, offene
   Folgepunkte. Ehrlich: „Kriterium 3 offen, weil …" ist ein brauchbarer Sprint-Abschluss, ein
   geschöntes „alles grün" nicht.

5. **Changelog-Notiz** aus der Sprint-Datei nach `CHANGELOG.md` unter `[Unreleased]` übertragen —
   nur, wenn du der festgelegte Changelog-Schreiber bist. Sonst melden, dass sie ansteht.

6. **Versions-Relevanz** ist gesetzt (`keine | patch | minor | major`). `VERSION` bleibt unangetastet
   — die Zahl setzt der Release-Sprint.

7. **`status: abgeschlossen`** — erst jetzt.

## Ausgabe

Drei Zeilen: was erreicht wurde, was offen blieb, was als Nächstes ansteht. Und ausdrücklich: ob der
Diff den Write-Scope verlassen hat.
