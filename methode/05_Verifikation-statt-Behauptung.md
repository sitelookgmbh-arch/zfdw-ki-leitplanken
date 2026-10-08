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

## Rot-Beweis — kann die Prüfung überhaupt fehlschlagen?

Ein Test, ein Guard, eine Lint-Regel, eine Monitoring-Schwelle: Sie alle melden im Normalfall Grün.
Grün heißt aber nur dann „in Ordnung", wenn dieselbe Prüfung bei einem Fehler Rot gemeldet hätte.
Das ist keine Selbstverständlichkeit. Eine Prüfung kann aus vielen Gründen immer Grün sein: Das
Suchmuster trifft die Fehlerform nicht, die Prüfung läuft gegen die falsche Datei, der Fix, den sie
absichern soll, ist wirkungslos — und nichts davon fällt auf, weil Grün nie hinterfragt wird.

**Die Regel: Wer einen Wächter baut, zeigt, dass er rot werden kann.** Nicht durch Lesen, sondern
durch Ausführen:

- **Für einen Fix:** den Fix probehalber wieder entfernen. Wird jetzt ein Test rot? Wenn nicht, ist
  der Fix unbelegt — er kann wirkungslos sein, ohne dass es je jemand merkt.
- **Für einen Guard oder eine Prüfregel:** ein Gegenbeispiel bauen, das gegen die Regel verstößt,
  und die Prüfung darauf loslassen. Das Gegenbeispiel bleibt als Testfall in der Suite.
- **Für eine ganze Testsuite:** absichtlich kaputte Fassungen des Prüflings bauen („Mutanten") und
  zeigen, dass die Suite jede davon bemerkt. Eine Mutante, die die Suite grün lässt, markiert einen
  blinden Fleck: Dort fehlt ein Testfall.

Gegen den eigenen Bestand zu prüfen reicht dafür nie. Die Fehlerform, gegen die ein Wächter schützen
soll, kommt im Bestand oft gar nicht vor — genau deshalb soll er sie ja abfangen. Wer nur prüft, ob
der Wächter auf den vorhandenen Stellen grün ist, prüft den Bestand, nicht den Wächter. Ein
Gegenbeispiel muss man deshalb **konstruieren**: die Fehlerform mit einer Zwischenzeile, in anderer
Schreibweise, an einer anderen Stelle im Befehl.

Und eine Gegenprüfung, die den Wächter nicht ausführt, sondern sein Suchmuster im Kopf nachbildet,
belegt nichts über den Wächter. Sie belegt nur, dass zwei Leser dasselbe gedacht haben.

**Beispiel in dieser Sammlung:** [`hooks/tests/rot-beweis.sh`](../hooks/tests/rot-beweis.sh) baut
sieben Mutanten des Guards — lässt alles durch, blockt alles, ohne `jq` still durchlassen, `commit -a`
nicht erkannt, schätzt mit `git status` statt zu messen, sieht im pre-commit-Modus den Index nicht,
übersieht die Codex-Musterdatei — und verlangt, dass die Testsuite jede davon
rot meldet. Jede Mutante ist der Rückfall auf einen Fehler, den der Guard tatsächlich hatte oder
haben könnte. Vorher prüft das Skript, ob die Suite gegen das Original grün ist; sonst bewiese ein
Rot gegen die Mutanten nichts.

## Stiller Erfolg — die Befundklasse, die niemand meldet

Ein Vorgang meldet Erfolg, obwohl ein Nebenpfad fehlgeschlagen ist: Die Hauptaktion lief durch, aber
das Protokoll wurde nicht geschrieben, die Benachrichtigung nicht verschickt, der Eintrag in der
Warteschlange ging verloren. Der Aufrufer sieht Grün, der Nutzer sieht Grün — und die Lücke wird erst
bemerkt, wenn jemand den Nachweis braucht, den es nicht gibt.

Das ist keine Spielart von „Fehler", sondern eine eigene Klasse, und sie verdient einen eigenen
Prüfschritt. Fehler, die laut werden, findet man von selbst. Stille Erfolge findet nur, wer bei jedem
Pfad fragt: **Was passiert, wenn der Nebenpfad scheitert — und wer erfährt davon?** Die richtige
Antwort ist selten „niemand". Sie ist: Der Gesamtvorgang meldet einen Teilerfolg, ausdrücklich.

## Geprüfte Fläche und blinder Fleck

Eine Vermutung, die zufällig stimmt, sieht im Text genauso aus wie eine geprüfte Tatsache. Am
deutlichsten bei Nein-Aussagen: „Kein Befund", „kommt nirgends vor", „wird nicht verwendet".

Deshalb trägt jede Tatsachenbehauptung, die jemand anderem als Grundlage dient, zwei Angaben mit:

- **Geprüfte Fläche:** wo gesucht wurde, womit, in welchem Stand. „Volltextsuche über `src/` und
  `docs/`, Stand Commit X."
- **Blinder Fleck:** was dabei nicht gesehen werden konnte. „Generierter Code, Konfiguration im
  Zielsystem, andere Repos."

Ein „nein" ohne genannte Suchfläche ist eine Vermutung. Das gilt für den Assistenten wie für jeden
Prüfer — und besonders für eine zweite Prüfinstanz, deren „kein Befund" sonst schwerer wiegt, als es
belegt ist.

## Die Realität mitdenken

Eine Prüfung, die den falschen Zustand annimmt, produziert Fehlalarme — und Fehlalarme trainieren
allen ab, auf Prüfungen zu achten.

Läuft eine Anwendung noch ohne eigenes Backend, mit lokal simulierten Diensten, sind server-seitige
Angriffsklassen schlicht nicht anwendbar. Das ist kein Befund, sondern der Bauzustand. Das reale
Risiko liegt dann woanders: in dem, was im ausgelieferten Paket beim Anwender landet.

Wer prüft, muss also erst wissen, **wo das Projekt gerade steht** — und darf den Prüfumfang danach
zuschneiden. Was ausgelassen wird, wird benannt (siehe Abweichungstabelle in
[01 — Sprintplan](01_Sprintplan-und-Write-Scope.md)).

## Spec Drift — was Verifikation nicht fängt

Verifikation prüft die Implementierung gegen das Kriterium. Sie prüft **nicht**, ob das Kriterium
noch beschreibt, was das System tut. Läuft die Beschreibung der Implementierung hinterher, sind alle
Prüfungen grün und die Dokumentation trotzdem falsch. Dieser Zustand ist teurer als eine offene
Lücke, weil er wie Ordnung aussieht: Der nächste, der die Beschreibung liest — ein Kollege, ein
Prüfer, ein Assistent im nächsten Kontextfenster — baut auf ihr auf.

Für dieses Auseinanderdriften von Beschreibung und Code hat sich der Begriff **Spec Drift**
eingebürgert. Er trifft nicht nur Spezifikationen: Ablaufdiagramme, Datenmodelle, Rollenmatrizen und
Runbooks driften genauso, nur unauffälliger.

Das Gegenmittel ist kein weiterer Test, sondern eine Regel über den Commit:

- Wer den Code ändert, ändert **im selben Commit** die Stelle der Beschreibung, die ihn beschreibt.
  Getrennte Commits werden getrennt vergessen.
- Liegt die Beschreibung in einem **anderen Repo** oder außerhalb der Versionierung, ist der
  Abgleich ein eigener Nachweis in Abschnitt 7 der Sprint-Datei — mit Datum. „Wird nachgezogen" ist
  kein Nachweis.
- Beim Prüfen einer Änderung gehört die Frage dazu: **Welche Beschreibung wird durch diesen Diff
  falsch?** Fällt niemandem eine ein, ist entweder nichts Fachliches passiert — oder es hat niemand
  nachgesehen.

## Prüfen

- [ ] Hat jeder abgeschlossene Schritt eine benannte Prüfzeile — nicht nur ein „läuft"?
- [ ] Kann die Prüfung überhaupt fehlschlagen, oder meldet sie bei fehlender Voraussetzung Grün?
- [ ] Gibt es einen Rot-Beweis — ein ausgeführtes Gegenbeispiel, das die Prüfung rot macht?
- [ ] Wird ein Fix rot, wenn man ihn probehalber wieder entfernt?
- [ ] Was passiert, wenn ein Nebenpfad scheitert — meldet der Vorgang dann trotzdem Erfolg?
- [ ] Nennt jede Nein-Aussage ihre geprüfte Fläche und ihren blinden Fleck?
- [ ] Misst sie das, was zählt — oder nur das, was leicht zu messen ist?
- [ ] Wurde eine Oberflächenänderung im Release-Zustand angesehen, nicht nur im Debug-Modus?
- [ ] Hat jeder Befund eine Fundstelle?
- [ ] Welche Beschreibung wird durch diesen Diff falsch — und wurde sie im selben Commit angefasst?
