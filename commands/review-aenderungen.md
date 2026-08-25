---
description: Prüft den aktuellen Diff — klassifiziert ihn und wendet nur die passenden Prüfdimensionen auf die geänderten Stellen an.
---

Prüfe die aktuellen Änderungen. Umfang: $ARGUMENTS (ohne Angabe: `git diff` gegen `main`).

## 1. Klassifizieren

Sieh dir zuerst an, **was** sich geändert hat: `git diff --stat` und die Dateiliste. Dann ordne ein:

| Art der Änderung | Prüfdimensionen |
|---|---|
| reine Doku / Kommentare | Korrektheit der Aussagen, tote Links |
| Oberfläche / Darstellung | Zustände (leer, Fehler, Ladezeit), Bedienbarkeit, Release-Verhalten |
| Logik im Anwendungskern | Korrektheit, Randfälle, Fehlerbehandlung, Tests |
| Datenmodell / Migration | Rückwärtskompatibilität, Datenverlust, Wiederanlauf |
| Abhängigkeiten | Herkunft, Aktualität, Lizenz, Lockfile-Konsistenz |
| Build / Pipeline / Deploy | Reproduzierbarkeit, Secrets, Rechte, Rückfallweg |

**Unabhängig von der Diff-Größe immer voll prüfen:** Authentifizierung und Berechtigungen,
Secrets-Handhabung, alles was personenbezogene Daten berührt, und alles, was am Deploy hängt.

## 2. Aufwand skalieren

Ein Zweizeilen-Diff bekommt keine Vollprüfung. Ein Diff über zwanzig Dateien bekommt keine
Stichprobe. Nenne in einer **Routing-Tabelle**, welche Dimension du geprüft hast und welche du
übersprungen hast — mit einer Zeile Begründung je Auslassung.

Eine übersprungene Dimension ohne Begründung gilt als Mangel des Reviews, nicht als Ersparnis.

## 3. Realität mitdenken

Prüfe gegen den **tatsächlichen** Bauzustand, nicht gegen eine gedachte Zielarchitektur. Läuft die
Anwendung noch ohne eigenes Backend, sind server-seitige Angriffsklassen nicht anwendbar — das ist
kein Befund, sondern der Bauzustand. Das reale Risiko liegt dann in dem, was ausgeliefert wird.

Fehlalarme sind teuer: Sie trainieren allen ab, auf Befunde zu achten.

## 4. Befunde melden

- Jeder Befund mit **`Datei:Zeile`**. Ohne Fundstelle keine Meldung.
- Nach Schwere sortiert, nicht nach Reihenfolge im Diff.
- Was **nicht** belegbar ist, wird als Vermutung gekennzeichnet oder weggelassen. Nichts erfinden:
  keine Normverweise, Versionen, Funktionsnamen oder Zahlen ohne Beleg aus dem Code.
- Zu jedem Befund ein konkreter nächster Schritt — nicht „sollte man mal ansehen".

Ändere in diesem Lauf **nichts**. Das hier ist ein Bericht, keine Reparatur.
