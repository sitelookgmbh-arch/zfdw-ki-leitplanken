# 05 — Verifikation statt Behauptung

> **Kurz:** „Fertig" ist keine Statusmeldung, sondern eine Behauptung. Zu jedem Arbeitsschritt gehört
> die Zeile, mit der man ihn nachprüft — und die Prüfung muss das messen, was tatsächlich zählt.

## Das Problem

Ein Assistent, der etwas gebaut hat, ist der schlechteste Prüfer dafür. Nicht aus Unehrlichkeit: Er
prüft mit denselben Annahmen, mit denen er gebaut hat. Was er übersehen hat, übersieht er wieder.

Dazu kommt die Prüfung, die zwar läuft, aber nichts beweist:

- **Ein HTTP 200 beweist bei einer Single-Page-App gar nichts.** Viele Server liefern bei unbekannten
  Pfaden die `index.html` aus — mit Status 200. Die Anwendung kann komplett kaputt sein, der Prüfer
  meldet Grün. Was zählt, ist der echte Start im Browser: rendert die Oberfläche, ist die Konsole
  leer, funktioniert der erste Klick?
- **Ein Prüfskript, dessen Voraussetzung fehlt, darf nicht Grün melden.** Wenn das Werkzeug nicht
  installiert, die Datei nicht da, die Umgebungsvariable nicht gesetzt ist — dann ist das Ergebnis
  „unbekannt", nicht „bestanden". Ein Skript, das in diesem Fall `exit 0` sagt, ist schlimmer als
  keines: es erzeugt Vertrauen ohne Deckung.
- **Lokales Debug-Verhalten ist nicht das Release-Verhalten.** Optimierung, Bündelung,
  Baumschnitt-Verfahren und abgeschaltete Entwicklerhilfen verändern das Verhalten der Anwendung.
  Ein Fehler, der nur im Release auftritt, lässt sich im Debug-Modus nicht reproduzieren — und wird
  dann als „nicht reproduzierbar" abgelegt.

## Die Regel

**Vier Schritte, in dieser Reihenfolge:**

1. **Verstehen** — erst lesen und prüfen, bevor etwas verändert wird.
2. **Zeigen** — den geplanten Schritt oder Befehl nennen, bevor er läuft.
3. **Ausführen.**
4. **Verifizieren** — mit der konkreten Prüfzeile. Erst bei Grün weiter.

**Irreversibles immer zweistufig:** erst zeigen, was passieren würde, dann auf Bestätigung
ausführen. Das gilt für Löschungen, Migrationen, Deployments, alles mit `--force`.

**Jeder Befund braucht einen Beleg.** `Datei:Zeile`, eine Befehlsausgabe, ein Screenshot. Ein Befund
ohne Fundstelle ist eine Vermutung — und Vermutungen, die wie Befunde formatiert sind, sind teurer
als gar keine Prüfung.

**Nichts erfinden.** Pfade, Namen, Nummern, Normverweise, Versionen nicht raten. Nicht belegt →
weglassen oder fragen. Bei Unsicherheit sauber abbrechen ist besser als plausibel klingen.

## Die Realität mitdenken

Eine Prüfung, die den falschen Zustand annimmt, produziert Fehlalarme — und Fehlalarme trainieren
allen ab, auf Prüfungen zu achten.

Läuft eine Anwendung noch ohne eigenes Backend, mit lokal simulierten Diensten, sind server-seitige
Angriffsklassen schlicht nicht anwendbar. Das ist kein Befund, sondern der Bauzustand. Das reale
Risiko liegt dann woanders: in dem, was im ausgelieferten Paket beim Anwender landet.

Wer prüft, muss also erst wissen, **wo das Projekt gerade steht** — und darf den Prüfumfang danach
zuschneiden. Was ausgelassen wird, wird benannt (siehe Routing-Log in
[01 — Sprintplan](01_Sprintplan-und-Write-Scope.md)).

## Prüfen

- [ ] Hat jeder abgeschlossene Schritt eine benannte Prüfzeile — nicht nur ein „läuft"?
- [ ] Kann die Prüfung überhaupt fehlschlagen, oder meldet sie bei fehlender Voraussetzung Grün?
- [ ] Misst sie das, was zählt — oder nur das, was leicht zu messen ist?
- [ ] Wurde eine Oberflächenänderung im Release-Zustand angesehen, nicht nur im Debug-Modus?
- [ ] Hat jeder Befund eine Fundstelle?
