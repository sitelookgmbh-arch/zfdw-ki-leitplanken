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

## Prüfen

- [ ] Zeilenzahl unter dem Richtwert?
- [ ] Steht irgendeine Regel zweimal — in der Datei und in einer Doku?
- [ ] Gibt es eine Sektion, die bei den letzten zehn Änderungen kein einziges Mal relevant war?
- [ ] Hat jede ausgelagerte Sektion noch ihren Anker?
