---
entscheidung: {{KURZTITEL}}
datum: {{JJJJ-MM-TT}}
status: vorgeschlagen   # vorgeschlagen | entschieden | ersetzt durch {{VERWEIS}}
entschieden_von: {{NAME}}
---

# Entscheidung: {{KURZTITEL}}

> Fünf Felder, keines optional. Fehlt eines, ist die Entscheidung unterspezifiziert — dann nicht
> weiterbauen, sondern nachschärfen. „Keine" ist bei Feld 5 eine gültige Antwort, ein leeres Feld
> nicht.

## 1. Entscheidung

{{Ein bis drei Sätze: was gilt ab jetzt. Kein Hintergrund, keine Geschichte.}}

## 2. Verworfene Alternative

{{Mindestens eine, jeweils mit dem Grund, warum nicht. Eine Entscheidung ohne verworfene
Alternative war keine Entscheidung, sondern die erste Idee.}}

- **{{Alternative}}** — verworfen, weil {{Grund}}.

## 3. Randbedingungen

{{Was die Wahl erzwungen oder begrenzt hat: Termin, Budget, vorhandenes System, Vertrag,
Kompetenz im Team. Ändert sich eine davon, ist die Entscheidung neu zu prüfen.}}

## 4. Bewusst außerhalb des Umfangs

{{Was diese Entscheidung ausdrücklich nicht regelt. Verhindert, dass sie später für etwas
herangezogen wird, das niemand mitbedacht hat.}}

## 5. Betroffene Schnittstellen und Zusagen

{{Welche anderen Teile, Dateien, Personen oder Zusagen ändern sich dadurch? „Keine" ist erlaubt.}}

---

## Vor einer Gegenprüfung: Fakt oder Urteil?

Eine zweite Prüfinstanz — Mensch, zweites Modell, Review-Agent — lohnt nur für Aussagen, die
durch **Nachsehen** widerlegbar sind: Datei lesen, Befehl ausführen, Beleg ziehen. Verlangt die
Widerlegung einen **besseren Gegenentwurf** (Architektur, Gestaltung, Strategie), erzeugt eine
Prüfrunde nur selbstbewussten Konsens. Solche Punkte gehen an den Menschen, der entscheidet —
siehe Abschnitt 13 der Sprint-Vorlage.

| Aussage aus dieser Entscheidung | Fakt (nachsehbar) oder Urteil? | Wer prüft |
|---|---|---|
| {{…}} | {{Fakt / Urteil}} | {{Prüfinstanz / Mensch}} |

## Implementierungsnotizen (nach der Umsetzung)

Höchstens fünf Zeilen, geschrieben von dem, der umgesetzt hat. Die meisten Fehlschläge sind
nicht falsche Lösungen, sondern **verworfene richtige** — sichtbar gemacht, lassen sie sich im
Review gezielt nachsteuern.

- **Verworfen:** {{welcher Weg wurde beim Bauen ausprobiert oder erwogen und fallen gelassen — warum}}
- **Annahme ohne Beleg:** {{was wurde angenommen, ohne es nachgesehen zu haben}}
- **Bewusst weggelassen:** {{was gehörte eigentlich dazu und fehlt — mit Grund}}
