# 11 — Nahtstellen-Register

> **Kurz:** Ein Review sieht den eigenen Diff. Die teuren Fehler entstehen aber dort, wo zwei
> Dinge aufeinandertreffen, die einzeln korrekt sind. Was an einer Nahtstelle schon einmal
> schiefging, gehört in ein Register, das jedes Review vor der Freigabe lesen muss.

## Das Problem

Je mehr Arbeit Assistenten und Automatik übernehmen, desto mehr Übergaben gibt es: von einem Lauf
zum nächsten, von einem Werkzeug zum anderen, vom gemergten Stand zum laufenden. Jede Seite für sich
ist geprüft. Der Fehler liegt dazwischen, und dort schaut kein Review hin, weil es keinen Diff dafür gibt.

Typische Formen:

- **Veraltete Basis.** Zwei Änderungen sind offen. Die erste wird übernommen, die zweite liegt jetzt
  hinter dem Hauptstand. Ein Review, das vor dem Nachziehen läuft, prüft einen Stand, den es so nie
  geben wird, und meldet Grün.
- **Übernommen ist nicht laufend.** Eine Korrektur ist im Hauptstand, aber der Prozess, der sie
  ausführen soll, läuft aus einer älteren Kopie oder hat sie noch nicht neu geladen. Alle Prüfungen
  sind grün, die Wirkung bleibt aus.
- **Neustart mitten in der Arbeit.** Ein Dienst wird neu gestartet, um eine Änderung zu laden, und
  bricht dabei einen laufenden Auftrag ab, der nichts mit der Änderung zu tun hat.
- **Stillschweigend seriell.** Zwei Aufgaben sollten nebeneinander laufen, teilen sich aber einen
  synchronen Ablauf. Die lange blockiert die kurze, und niemand merkt es, weil am Ende doch alles fertig wird.
- **Sperre am falschen Ort.** Eine Schutzregel (etwa „nur aus sauberem Stand starten“) ist richtig,
  blockiert aber genau den Fall, der einen bestimmten Zwischenstand braucht.

Solche Fehler wiederholen sich. Wer sie nur im Gedächtnis eines Menschen oder einer Sitzung ablegt,
trifft sie beim nächsten Umbau wieder, denn der nächste Umbau wird von jemandem geprüft, der sie nicht kennt.

## Die Regel

**1. Jede Nahtstellen-Falle bekommt einen Eintrag mit festen Feldern:**

| Feld | Inhalt |
|---|---|
| ID | fortlaufend, nie wiederverwendet |
| Auslöser | was passiert sein muss, damit die Falle zuschnappt |
| Symptom | was man sieht, auch wenn man sie nicht kennt |
| Betroffene Dateien | Pfade, bei Code mit Zeile |
| Gegenmittel | Test, Regel oder Prüfung mit Fundstelle, sonst ausdrücklich „fehlt“ |
| Beleg | Datum und Verweis auf Protokoll oder Änderung |
| Status | offen oder abgesichert |

„Abgesichert“ heißt nur: Der benannte Schutz existiert und ist belegt. Nicht belegbare Aussagen
werden als „nicht bestätigt“ markiert und nicht weggelassen. Ein Register, das nur Gesichertes
enthält, verliert genau die Fälle, die es braucht.

**2. Das Register liegt dort, wo das Review es lesen muss.** Gemeint ist nicht ein Wiki daneben,
sondern die Stelle, die der Prüfer ohnehin lädt (siehe 02 — Schichten). Berührt eine Änderung eine
Datei, die in einem Eintrag steht, nimmt das Review zu diesem Eintrag ausdrücklich Stellung.

**3. Wer eine neue Falle bemerkt, trägt sie im nächsten Änderungsschritt ein,** egal ob Mensch,
Assistent oder Meldung der Automatik. Ein eigener Dienst dafür ist nicht nötig. Das Register ist
eine Datei, kein Prozess.

**4. Offene Einträge prüft man, wenn man ohnehin an der Datei arbeitet.**

**5. Ins Register gehört nur, was ein Review an einer Datei erkennen kann.** Abläufe und
Bedienfehler gehören ins Runbook. Ein Register, das alles aufnimmt, liest bald niemand mehr.

## Grenzen

Ein Register verhindert keinen neuen Fehler. Es verhindert den zweiten Fehler gleicher Bauart.
Und es wirkt nur, wenn das Review es tatsächlich liest. Das belegt man so wie jeden Wächter (05 —
Rot-Beweis): mit einer Probeänderung an einer eingetragenen Datei, die eine Stellungnahme erzwingen muss.

## Prüfen

- [ ] Gibt es eine Stelle, an der Nahtstellen-Fehler festgehalten werden, außerhalb von Köpfen und Chatverläufen?
- [ ] Liest das Review diese Stelle, und ist das mit einer Probeänderung belegt?
- [ ] Hat jeder Eintrag ein Gegenmittel oder ein ausdrückliches „fehlt“?
- [ ] Wird nach einer Übernahme geprüft, ob der laufende Prozess den neuen Stand wirklich ausführt?
