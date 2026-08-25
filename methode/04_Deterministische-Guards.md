# 04 — Deterministische Guards statt advisory Regeln

> **Kurz:** Eine Anweisungsdatei ist ein Vorschlag an ein Sprachmodell. Wo eine Grenze **nie** fallen
> darf, gehört sie in Code, der nicht abwägt.

## Das Problem

Ein Assistent, der eine Regel in 99 von 100 Fällen befolgt, ist beeindruckend — und für
personenbezogene Daten, Secrets oder ein Produktivsystem trotzdem unbrauchbar. Der hundertste Fall
ist der, der zählt.

Dazu kommt: Der Regelbruch sieht selten aus wie ein Regelbruch. Er sieht aus wie ein hilfreicher
Zwischenschritt.

Das klassische Beispiel ist nicht `git add kundendaten.json` — davor warnt jede Anweisungsdatei
erfolgreich. Es ist `git add -A` nach einem Arbeitsschritt, bei dem die Datei nicht im `.gitignore`
stand. **Der Dateiname taucht im Befehl gar nicht auf.** Eine textuelle Regel, die auf den Dateinamen
zielt, greift hier prinzipiell nicht — sie hat nichts zu prüfen.

## Die Regel

Für jede Grenze zwei Fragen:

1. **Was passiert im schlimmsten Fall, wenn sie einmal fällt?** Ärger, Nacharbeit, Peinlichkeit →
   advisory reicht. Meldepflicht, Vertragsbruch, Datenabfluss, kaputtes Produktivsystem → Hook.
2. **Kann man den Verstoß maschinell erkennen, bevor er wirkt?** Wenn ja, gehört er in einen
   `PreToolUse`-Hook. Wenn nein, gehört er in einen menschlichen Freigabeschritt — nicht in eine
   Bitte an das Modell.

Ein Hook ist eine schlichte Sache: ein Skript, das vor dem Werkzeugaufruf läuft, den Befehl ansieht
und ihn ablehnt. Kein Modell, keine Abwägung, kein Kontext, der ihn verdrängen könnte.

## Was einen Guard brauchbar macht

**Auf die Wirkung prüfen, nicht auf die Formulierung.** Nicht „steht der verbotene Dateiname im
Befehl?", sondern „welche Dateien würde dieser Befehl der Versionsverwaltung hinzufügen?". Der
Unterschied ist der ganze Punkt — siehe `git add -A` oben.

**Fehlalarme kosten mehr als sie scheinen.** Ein Guard, der zu oft grundlos blockt, wird umgangen —
und danach schützt er gar nichts mehr. Zur Testsuite gehören deshalb ausdrücklich die Fälle, die
**nicht** greifen dürfen.

**Der Guard braucht Tests.** Er ist die Komponente, die im Ernstfall als einzige zwischen Fehler und
Schaden steht, und er wird nie im Alltag ausgelöst — also merkt niemand, wenn er kaputtgeht. Nach
jeder Änderung an den Schutzmustern die Suite laufen lassen.

**Der Guard ersetzt die Regel nicht, er ergänzt sie.** In der Anweisungsdatei steht weiterhin, was
gilt und warum — sonst arbeitet der Assistent gegen eine Wand, deren Grund er nicht kennt, und sucht
Umwege.

## Grenzen

Ein Guard prüft, was ein Werkzeugaufruf tut. Er prüft nicht, was jemand meint. Gegen eine falsche
fachliche Entscheidung, ein schlechtes Datenmodell oder eine unklare Anforderung hilft kein Hook —
dafür gibt es das Mensch-Gate aus [01 — Sprintplan](01_Sprintplan-und-Write-Scope.md#6-ein-gate-das-kein-agent-aufmacht).

## Prüfen

- [ ] Gibt es eine Regel mit Rechts- oder Datenschutzfolge, die nur als Text existiert?
- [ ] Prüft der Guard die Wirkung des Befehls — oder nur dessen Wortlaut?
- [ ] Existiert eine Testsuite, und enthält sie bewusste Nicht-Treffer?
- [ ] Weiß der Assistent aus der Anweisungsdatei, warum er blockiert wird?
