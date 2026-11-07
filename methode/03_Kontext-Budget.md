# 03 — Kontext-Budget

> **Kurz:** Die Anweisungsdatei wird bei jedem Turn vollständig geladen. Je länger sie wird, desto
> weniger wirkt jede einzelne Regel darin. Kürze ist hier kein Stil, sondern Funktion.

## Das Problem

Eine Anweisungsdatei (`CLAUDE.md`, `AGENTS.md`, wie auch immer das Werkzeug sie nennt) hat zwei
Eigenschaften, die sich beißen:

1. Sie ist **immer da** — das macht sie wertvoll für Regeln, die immer gelten.
2. Sie ist **immer da** — das macht jede zusätzliche Zeile teuer, auch bei der Änderung, für die sie
   irrelevant ist.

Wer das zweite ignoriert, bekommt eine Datei, die alles enthält und nichts bewirkt. Der typische
Verlauf: Ein Assistent macht einen Fehler → man ergänzt eine Regel → beim nächsten Fehler noch eine.
Nach drei Monaten steht dort ein Handbuch, und der Assistent hält sich an weniger davon als am
Anfang.

## Die Regel

**Richtwert 200 Zeilen.** Keine Naturkonstante — aber eine Zahl, die eine Entscheidung erzwingt,
sobald sie gerissen wird. Ohne Zahl wächst die Datei einfach weiter.

Beim Reißen des Richtwerts wird nicht gekürzt, sondern **umgelagert**: nach der Zuordnung aus
[02 — Schichten](02_Schichten-Anweisung-Hook-Skill.md). Was dort hin wandert, hinterlässt einen
Anker.

**Nicht duplizieren.** Eine Regel steht an genau einer Stelle. Wo sie an zweiter Stelle gebraucht
wird, steht ein Verweis. Zwei Fassungen derselben Regel driften — und beim Widerspruch glaubt der
Assistent der, die zufällig näher am Kontextende steht.

## Regeln altern mit dem Modell

Ein Teil der Regeln in einer Anweisungsdatei steht dort nicht wegen des Projekts, sondern wegen des
Modells: Es hat einmal etwas falsch gemacht, und eine Zeile soll das künftig verhindern. Solche
Regeln sind richtig, solange das Modell die Schwäche hat. Kommt ein neueres Modell, das sie nicht
mehr hat, bleibt die Regel trotzdem stehen — und schränkt es ein. Sie kostet Kontext, sie verbietet
womöglich genau das, was das neue Modell besser kann, und niemand merkt es, weil die Regel nie
Ärger macht.

**Darum bei jedem Wechsel des Standardmodells die Regeln einteilen:**

| Klasse | Die Regel steht dort wegen … | Beim Modellwechsel |
|---|---|---|
| **P** — Präferenz | Geschmack, Konvention, Arbeitsweise des Menschen | bleibt |
| **S** — Sicherheit | Irreversibles, Datenschutz, Produktivsystem | bleibt — und gehört ohnehin eher in einen Hook ([04](04_Deterministische-Guards.md)) |
| **K** — Korrektur | einer beobachteten Schwäche dieses Modells | wird Testkandidat |
| **M** — Mischform | Präferenz mit Korrektur-Anteil | den Korrektur-Anteil herauslösen und wie K behandeln |

**K-Regeln aus der Zeit vor dem Wechsel werden getestet, nicht mitgeschleppt:** Begründung und
Fallgeschichte kürzen, die Regel probeweise entschärfen, zwei Wochen beobachten, ob der Fehler
wiederkommt. Kommt er wieder, bleibt die Regel — jetzt mit Beleg, dass sie auch für dieses Modell
nötig ist. Kommt er nicht, fliegt sie. K-Regeln, die schon unter dem neuen Modell entstanden sind,
bleiben unangetastet.

Voraussetzung ist, dass man einer Regel ihre Klasse ansieht. Wer beim Anlegen einer Korrektur-Regel
den Anlass mit Datum notiert („seit Modell X, Fall vom …"), kann sie beim nächsten Wechsel finden.
Wer das nicht tut, steht vor einer Datei, in der Präferenzen und Altlasten gleich aussehen.

Dasselbe gilt für Einstellungen, die mit dem Modell gewählt wurden: Ein Denkaufwand, der für ein
älteres Modell richtig war, ist für ein neueres zu hoch oder zu niedrig. Faustregel, die sich bisher
gehalten hat: Prüfarbeit (Review, Sicherheit, Planprüfung) auf hohe Stufe, Routine (Umsetzung nach
klarer Vorgabe, Doku, Aufräumen) auf mittlere — und diese Zuordnung beim Modellwechsel ebenfalls
nachprüfen, nicht erben.

## Was in die Anweisungsdatei gehört

Der Test ist nicht „ist es wichtig?", sondern **„gilt es bei fast jeder Änderung?"**:

- Was das Projekt ist, in drei Sätzen
- Der verbindliche Ablauf (z. B.: verstehen → zeigen → ausführen → verifizieren)
- Rollen und Berechtigungen, wenn sie fast jede Änderung betreffen
- Namenskonventionen
- Die harten Grenzen, mit Verweis auf den Hook, der sie durchsetzt
- Wo alles andere steht

Was **nicht** hineingehört: Begründungen. Die Regel gehört in die Datei, das Warum in ein
Methoden-Dokument mit Link. Begründungen sind lang und werden selten gebraucht — aber wenn sie
fehlen, wird die Regel beim nächsten Zweifel wegdiskutiert. Deshalb: verlinken, nicht streichen.

## Kontext an Übergaben begrenzen

Eine Verarbeitungskette kann dieselbe Eingabe mehrfach interpretieren: erst beim Erfassen,
dann beim Zuordnen und nochmals beim Empfänger. Das kostet Laufzeit und Modellaufrufe; außerdem
können Zahlen, Negationen oder Freigabevorbehalte bei jeder Interpretation abweichen. Eine kürzere
Nachricht allein belegt deshalb weder eine Einsparung noch gleichbleibende Qualität.

**Einmal strukturiert erfassen, danach vorhandene Felder verwenden.** Ein versioniertes Schema
beschreibt den Arbeitsstand. Nachgelagerte Schritte übernehmen belegte Werte deterministisch.
Fehlende oder widersprüchliche Angaben werden als solche behandelt; eine erneute Modellanalyse
braucht einen benannten Anlass. Ungeprüfte Extraktion wird durch die Struktur nicht automatisch wahr.

**Je Ziel nur das erforderliche Paket bilden.** Aufgabe, notwendige Fakten, Einschränkungen,
Freigabevorbehalte und Referenz auf den Arbeitsstand müssen erhalten bleiben. Rohtext und
Gesamthistorie werden nicht standardmäßig angehängt. Zusätzlicher Kontext wird bei einer konkreten
Referenz oder einer festgestellten Informationslücke nachgeladen. Ob das Ziel die Daten erhalten
darf, prüft die Übergabegrenze nach [10 — Fremdtext ist Daten](10_Fremdtext-ist-Daten.md).

**Den gesamten fachlichen Auftrag vergleichen.** Eingabe-, Ausgabe- und Cache-Tokens sowie
Wiederholungen und Modellaufrufe der Vorverarbeitung getrennt erfassen, soweit verfügbar.
Laufzeit je Stufe und Ende zu Ende mit Median und p95 ausweisen; Stichprobengröße und
Messbedingungen nennen. Fehlende Messwerte bleiben unbekannt und werden nicht als null gewertet.
Verglichen werden dieselben synthetischen Aufgaben bei vergleichbarer Ergebnisqualität;
Zeichenzahlen und einzelne schnelle Läufe ersetzen diesen Nachweis nicht.

*Synthetischer Prüffall:* Ein Demo-Auftrag enthält eine Zahl, eine Negation und einen
Freigabevorbehalt. Nach der strukturierten Erfassung müssen diese in jeder erforderlichen
Zielprojektion erhalten bleiben. Eine Wiederholung der semantischen Analyse wird separat gezählt.

## Prüfen

- [ ] Zeilenzahl unter dem Richtwert?
- [ ] Steht irgendeine Regel zweimal — in der Datei und in einer Doku?
- [ ] Gibt es eine Sektion, die bei den letzten zehn Änderungen kein einziges Mal relevant war?
- [ ] Hat jede ausgelagerte Sektion noch ihren Anker?
- [ ] Ist bei jeder Korrektur-Regel erkennbar, gegen welches Modell und welchen Fall sie entstand?
- [ ] Wurden nach dem letzten Modellwechsel die K-Regeln aus der Zeit davor getestet?

- [ ] Verwenden nachgelagerte Schritte vorhandene strukturierte Werte, statt sie ohne Anlass erneut zu interpretieren?
- [ ] Bleiben Zahlen, Negationen und Freigabevorbehalte in den erforderlichen Zielpaketen erhalten?
- [ ] Sind Gesamtverbrauch, Wiederholungen und Laufzeit bei vergleichbarer Qualität gemessen oder ausdrücklich unbekannt?
