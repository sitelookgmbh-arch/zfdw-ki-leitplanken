# 07 — Verortung: SpecKit · BMAD · OpenSpec · GSD · Kiro

> **Kurz:** Diese Sammlung ist kein Spec-driven-Development-Framework und will keines ersetzen. Sie
> regelt, was die Frameworks offenlassen: **wer welche Datei schreiben darf**, **welche Grenze in
> Code gehört** und **womit „fertig" belegt ist**. Sie läuft neben jedem der fünf.

## Warum diese Seite existiert

Wer Spec-driven Development (SDD) kennt, ordnet ein, was er sieht — und ohne Einordnung landet
diese Sammlung im selben Fach wie fünf Werkzeuge, die etwas anderes tun. Diese Seite sagt, wo die
Grenze verläuft: was die Frameworks liefern, was hier stattdessen steht, und wann man besser zu
einem von ihnen greift.

**Stand: 26. August 2026.** Alle Angaben stammen aus den Projekt-Repositorien selbst und, bei Kiro,
von der Preisseite des Anbieters — an diesem Tag gelesen. Diese Seite driftet schneller als der
Rest der Sammlung; das ist genau der Mechanismus aus
[05 — Spec Drift](05_Verifikation-statt-Behauptung.md#spec-drift--was-verifikation-nicht-fängt).
Wer hier etwas Falsches liest: Issue aufmachen, das ist der Sinn eines Datums im Kopf.

## Das gemeinsame Grundmuster

Alle fünf folgen derselben Kette — **beschreiben → planen → in Aufgaben zerlegen → umsetzen** —
mit Kontrollpunkten dazwischen und Artefakten im Repo statt im Chat-Verlauf. Sie unterscheiden sich
darin, wie viel Zeremonie sie verlangen, ob die Spezifikation fortgeschrieben wird und wie viel
Werkzeug mitkommt.

| | Ablauf | Braucht | Lizenz |
|---|---|---|---|
| **[SpecKit](https://github.com/github/spec-kit)** (GitHub) | `constitution` → `specify` → `plan` → `tasks` → `implement` → `converge`, Schleife bis konvergiert | Python-CLI (`uv tool install specify-cli`) | MIT |
| **[BMAD](https://github.com/bmad-code-org/BMAD-METHOD)** | spezialisierte Rollen — Produkt, Architektur, UX, Entwicklung, Test — erzeugen nacheinander Briefs, Spezifikation, Architektur | Node (`npx bmad-method install`) | MIT |
| **[OpenSpec](https://github.com/Fission-AI/OpenSpec)** (Fission AI) | `propose` → `apply` → `archive`; Änderungen als Delta (`ADDED` / `MODIFIED` / `REMOVED`) gegen einen gepflegten Spec-Bestand | Node ≥ 20.19 (`@fission-ai/openspec`) | MIT |
| **[GSD Core](https://github.com/open-gsd/gsd-core)** | `discuss` → `plan` → `execute` → `verify`; Ausführung in Subagenten mit frischem Kontext | Node (`npx @opengsd/gsd-core`) | MIT |
| **[Kiro](https://kiro.dev/)** (AWS) | Requirements → Design → Tasks, in einer eigenen IDE | die IDE selbst; Tarife ab 20 $/Monat, Kontingent in Credits | proprietär |

Zwei Dinge, die man beim Vergleichen wissen sollte: Das ursprüngliche GSD-Repository
(`gsd-build/get-shit-done`) ist **archiviert**; das Projekt lebt als GSD Core weiter. Und SpecKit
ist nicht mehr die rein lineare Kette, als die es oft beschrieben wird — der `converge`-Schritt
läuft gegen Spezifikation, Plan und Aufgaben, bis er Konvergenz meldet.

## Was hier anders geschnitten ist

### 1. Kein Werkzeug

Vier der fünf bringen eine Installation mit, das fünfte eine ganze IDE. Diese Sammlung bringt
Dateien mit: kopieren, anpassen, fertig. Das ist keine Askese, sondern eine Folge des Zuschnitts —
was installiert werden muss, muss auch aktualisiert, versioniert und im Kundenprojekt genehmigt
werden. In manchen Umgebungen ist der Genehmigungsweg für ein npm-Paket länger als die Arbeit,
für die man es wollte.

### 2. Write-Scope: Zuständigkeit statt Reihenfolge

Die Frameworks regeln die **Reihenfolge** — was zuerst beschrieben, dann geplant, dann gebaut wird.
Sie sagen nicht, **welche Datei ein Abschnitt anfassen darf**. Das ist ein anderer Schnitt:
Ablaufplanung gegen Zugriffskontrolle auf Artefaktebene.

Solange ein Mensch mit einem Assistenten an einem Strang arbeitet, fällt der Unterschied nicht auf.
Er fällt in dem Moment an, in dem zwei Sitzungen, zwei Subagenten oder zwei Menschen parallel
laufen — dann kollidieren sie in `CHANGELOG.md`, `VERSION` und der Anweisungsdatei, und zwar
zuverlässig. [01 — Sprintplan mit Write-Scope](01_Sprintplan-und-Write-Scope.md) beschreibt die
Regel, [04](04_Deterministische-Guards.md) macht daraus, wo nötig, eine harte.

### 3. Nachweise statt Akzeptanzkriterien

Alle fünf kennen Akzeptanzkriterien. Keines verlangt **den Beleg dazu** — die Befehlsausgabe, den
Protokollauszug, den Fundort. Genauso wenig kennen sie Datenklassen, Zugangsrückgabe,
Änderungsklassen mit benannter Freigabe oder eine Tabelle für ausgelassene Schritte mit der Person,
die das Restrisiko abgenommen hat.

Das ist kein Versäumnis, sondern eine andere Zielgruppe. Die Frameworks sind für Entwicklungstempo
gebaut. Diese Sammlung ist in Kundenarbeit entstanden, in der jemand später fragt: Welche Daten?
Wer durfte schreiben? Wer hat freigegeben? Was wurde ausgelassen? Wer die Antworten erst in der
Woche vor dem Assessment rekonstruiert, zahlt sie doppelt.

### 4. Was nie passieren darf, steht in Code

SDD-Frameworks setzen auf Text: Spezifikationen, Regeln, Anweisungsdateien. Text ist ein Vorschlag
an ein Sprachmodell — er konkurriert mit allem anderen im Kontext und verliert manchmal. Deshalb
gibt es hier die Schichtung aus [02](02_Schichten-Anweisung-Hook-Skill.md) und den Guard aus
[04](04_Deterministische-Guards.md): Was nie passieren darf, wird geprüft, nicht gebeten.

### 5. Ein Zustand, kein zweiter daneben

GSD Core führt neben den Plänen eigene Zustandsdateien (`STATE.md`, `CONTEXT.md`), OpenSpec trennt
den gepflegten Spec-Bestand von den laufenden Änderungen. Beides ist konsistent gedacht. Hier gibt
es bewusst nur **eine** Datei je Abschnitt, die zugleich Plan, Stand und Nachweis ist — weil jeder
zweite Zustandsspeicher gegen das Repo driftet und im Widerspruchsfall niemand weiß, welcher gilt.

## Was die fünf besser können

Ehrlicherweise: eine ganze Menge.

- **BMAD** deckt ab, was vor dem Code passiert — Produktidee, Zielgruppe, Architekturentscheidung.
  Wer ein Vorhaben noch nicht durchdacht hat, bekommt hier Gesprächspartner. Diese Sammlung setzt
  voraus, dass jemand weiß, was gebaut werden soll.
- **OpenSpec** macht aus der Delta-Disziplin ein Werkzeug: Änderungen werden als Delta formuliert,
  beim Abschluss in den Spec-Bestand überführt und archiviert. Was hier Regel 8 ist, ist dort ein
  Kommando.
- **SpecKit** kommt von GitHub, wird gepflegt und deckt eine große Zahl von Assistenten ab. Die
  Konvergenzschleife ist mehr, als eine Checkliste leisten kann.
- **GSD Core** beantwortet Kontext-Rot auf Werkzeugebene — Ausführung in Subagenten mit frischem
  Kontextfenster. [03 — Kontext-Budget](03_Kontext-Budget.md) beschreibt dasselbe Problem und löst
  es mit Disziplin. Werkzeug schlägt Disziplin, wo es verfügbar ist.
- **Kiro** senkt die Einstiegshürde auf null: installieren, loslegen. Der Preis dafür ist die
  Bindung an eine proprietäre IDE und deren Modellauswahl.

## Wann du besser eines der fünf nimmst

| Lage | Nimm |
|---|---|
| Greenfield, das Produkt ist noch nicht durchdacht | **BMAD** |
| Viele kleine Änderungen an großem Bestand, Spezifikation soll dauerhaft gepflegt werden | **OpenSpec** |
| Solo an einem Projekt, Kontext-Rot ist das Hauptproblem, Werkzeug ist willkommen | **GSD Core** |
| Team ohne Lust auf Konfiguration, IDE-Wechsel ist verhandelbar | **Kiro** |
| Keine Installation möglich · geregelte Umgebung · parallele Agenten auf einem Repo | **diese Sammlung** |

## Kombinieren statt entscheiden

Der Vergleich legt eine Wahl nahe, die es nicht gibt. Write-Scope, Guard und Nachweistabelle sind
nicht an einen Ablauf gebunden — sie funktionieren neben `propose/apply/archive` genauso wie neben
`specify/plan/tasks/implement`. Wer OpenSpec fährt und zusätzlich einen Guard gegen geschützte
Pfade setzt, hat nichts Widersprüchliches getan, sondern eine Lücke geschlossen.

Die einzige Stelle, an der sich etwas beißt, ist der Zustand: Wer den Stand in einer Sprint-Datei
führt **und** in der Zustandsdatei eines Frameworks, hat zwei Quellen. Dann gilt die des
Frameworks, und die Sprint-Datei beschränkt sich auf das, was das Framework nicht kennt —
Write-Scope, Datenklassen, Freigabe, Abweichungen.

## Verwandt

- [01 — Sprintplan mit Write-Scope](01_Sprintplan-und-Write-Scope.md) — der Teil, den keines der
  fünf abdeckt.
- [04 — Deterministische Guards](04_Deterministische-Guards.md) — warum Text als Grenze nicht reicht.
- [05 — Verifikation statt Behauptung](05_Verifikation-statt-Behauptung.md) — Nachweis statt
  Akzeptanzkriterium, und Spec Drift als Fehlermodus dieser Seite selbst.
