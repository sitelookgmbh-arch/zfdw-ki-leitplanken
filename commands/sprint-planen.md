---
description: Zerlegt ein Vorhaben in docs/plan/PLAN.md und Sprint-Dateien mit Write-Scope — vor dem ersten Commit.
---

Zerlege das folgende Vorhaben in einen Plan und Sprint-Dateien. **Schreibe in diesem Lauf keinen
Produktivcode** — nur Planungsdateien.

Vorhaben: $ARGUMENTS

## Vorgehen

1. **Erst verstehen.** Lies, was es zum Thema im Repo schon gibt: bestehende Pläne in `docs/plan/`,
   Entscheidungen in `docs/decisions/`, die Anweisungsdatei. Nenne, was du gelesen hast.
   Ist ein Vorhaben bereits offen (`status:` ungleich `done`), frage nach, ob es fortgesetzt oder
   ersetzt wird — lege keinen Parallelplan an.

2. **Zuschnitt prüfen.** Ist das Vorhaben trivial — ein Commit, eine Zeile Beschreibung —, sage das
   und lege **keine** Dateien an. Zeremonie für Kleinkram entwertet die Methode.

3. **`docs/plan/PLAN.md` anlegen** nach der Vorlage: Ziel, Sprint-Liste, Reihenfolge und
   Abhängigkeiten, Annahmen, ausdrückliche Abgrenzung.

4. **Je Sprint eine Datei** `docs/plan/sprint-NN-<slug>.md` nach der Vorlage. Pro Sprint gilt:
   - **Ein Ziel.** Braucht die Zielbeschreibung ein „und", sind es zwei Sprints.
   - **Nicht-Ziele ausfüllen** — mindestens einen Punkt. Das ist der Scope-Schutz.
   - **Write-Scope vollständig.** Jede Datei, die der Sprint schreiben darf, steht drin. Heiße
     Dateien (`VERSION`, `CHANGELOG.md`, `README.md`, Anweisungsdatei, Plan-Dateien) bekommen genau
     einen Schreiber.
   - **Akzeptanzkriterien nachprüfbar.** Zu jedem gehört eine Zeile, die man ausführen, oder ein
     Schritt, den man ansehen kann. „Funktioniert wieder" ist kein Kriterium.
   - **Versions-Relevanz** setzen. `VERSION` fasst kein normaler Sprint an.

5. **Naht-Check.** Bevor du die Aufteilung vorlegst: ein Satz dazu, welches Querschnittsthema diese
   Aufteilung **verstecken** könnte. Fehler leben in den Nähten zwischen den Teilen — dort schaut
   sonst niemand hin. Wenn dir nichts einfällt, ist die Aufteilung wahrscheinlich zu grob.

6. **Parallelität prüfen.** Nur Sprints mit disjunktem Write-Scope dürfen `ausfuehrung: parallel`.
   Überschneidung ⇒ seriell, ohne Diskussion.

## Ausgabe

Die angelegten Dateien, dann eine kurze Zusammenfassung: Anzahl Sprints, welcher zuerst, welche
Annahme am wackeligsten ist. Keine Wiederholung des Dateiinhalts im Chat.

Wenn du auf eine Entscheidung stößt, die zwischen zwei tragfähigen Alternativen liegt: **planen bis
dorthin, dann fragen.** Nicht raten und weiterplanen.
