# 08 — Spezifikationsgüte

> **Kurz:** Eine Spezifikation ist ein Informationsmodell. Wofür es taugt, ist seit dreißig Jahren
> beschrieben — sechs Grundsätze, die älter sind als jedes Werkzeug, das heute Specs erzeugt.

## Das Problem

Werkzeuge sagen, **wie** eine Spec auszusehen hat: welche Abschnitte, welches Format, welche
Given/When/Then-Struktur. Keines sagt, **ob sie gut ist**.

Das rächt sich in beide Richtungen. Die Spec wird zu dünn, dann rät der Assistent — und rät
konsistent, was schlimmer ist als zu raten und zu straucheln. Oder sie wird zu dick, und dann
passiert, was in [03 — Kontext-Budget](03_Kontext-Budget.md) für die Anweisungsdatei beschrieben ist:
Sie enthält alles und bewirkt wenig.

Der typische Verlauf ist der zweite. Beim Schreiben wirkt jede Zeile wichtig, denn jede stand einmal
für eine Frage, die tatsächlich aufkam. Gestrichen wird nie, weil niemand ein Kriterium hat, um zu
sagen: *Das hier kann weg.* Nach drei Sprints ist die Spec ein Dokument, das niemand mehr ganz liest —
auch der Assistent nicht, der es zwar aufnimmt, aber unter Konkurrenz vieler gleich lauter Sätze.

Und noch etwas fehlt: Wenn zwei Specs unterschiedlich tief geschrieben sind, lässt sich der Abgleich
mit dem gebauten Zustand nicht mehr führen. Die Frage aus
[05 — Verifikation statt Behauptung](05_Verifikation-statt-Behauptung.md) — *ist das, was da steht,
auch das, was läuft?* — setzt voraus, dass beide Seiten vergleichbar sind.

## Die Herkunft

Die **Grundsätze ordnungsmäßiger Modellierung (GoM)** wurden 1995 in der Wirtschaftsinformatik
formuliert (Becker, Rosemann, Schütte) und bewusst an die *Grundsätze ordnungsgemäßer Buchführung*
angelehnt: Qualitätskriterien für Informationsmodelle, die man prüfen kann, ohne den Gegenstand zu
kennen.

Der Übertrag ist kein Kunstgriff. Eine Spec beschreibt einen Ausschnitt der Wirklichkeit für einen
bestimmten Zweck und eine bestimmte Leserschaft, in einer festgelegten Notation, mit Bezug zu
Nachbardokumenten. Das ist die Definition eines Informationsmodells. Was für Datenmodelle,
Prozessmodelle und Organigramme gilt, gilt auch hier.

## Die sechs Grundsätze, auf Specs gelesen

**Richtigkeit.** Zwei Ebenen: Beschreibt die Spec den Sachverhalt zutreffend (semantisch), und hält
sie die vereinbarte Form ein (syntaktisch)? Die zweite ist automatisierbar, die erste nicht — dafür
gibt es [05](05_Verifikation-statt-Behauptung.md).

**Relevanz.** Enthält die Spec, was dieser Zweck braucht — und **nichts**, dessen Entfernung sie nicht
schlechter machen würde? Das ist der Grundsatz, der in der Praxis am häufigsten verletzt wird, und
zugleich der mit dem schärfsten Test: *Was kann ich streichen, ohne dass es an Wert verliert?* Was
diese Frage übersteht, gehört hinein.

**Wirtschaftlichkeit.** Steht der Aufwand für die Spec in einem vernünftigen Verhältnis zu ihrem
Nutzen? Die Frage klingt banal und wird trotzdem nie gestellt. Sie ist die Gegenkraft zu dem Reflex,
lieber zu viel zu spezifizieren — denn auch das Schreiben kostet, und zwar an derselben Stelle wie
das Bauen.

**Klarheit.** Versteht der **Adressat** es — mit möglichst wenig Methodenwissen? Hier weicht die
Anwendung vom Original ab: Die GoM setzen einen menschlichen Leser voraus. Bei uns sind es zwei
Adressaten mit unterschiedlichen Schwächen. Der Mensch überliest Widersprüche und ergänzt still, was
fehlt. Das Modell tut beides nicht — es nimmt den Widerspruch mit und füllt die Lücke mit einer
Annahme. **Klarheit wird dadurch nicht weicher, sondern strenger.**

**Vergleichbarkeit.** Gleiche Konventionen, gleicher Abstraktionsgrad über Specs hinweg. Ohne diesen
Grundsatz ist Drift nicht messbar, sondern nur zu ahnen: Wer Soll und Ist vergleichen will, braucht
zwei Beschreibungen derselben Flughöhe. Deshalb steht dieser Grundsatz vor dem Schreiben, nicht danach.

**Systematischer Aufbau.** Ein Modell zeigt immer nur einen Ausschnitt — es braucht definierte
Schnittstellen zu den Nachbarn. Bei uns: Wo verweist die Spec auf den Sprintplan, wo auf die
Anweisungsdatei, wo auf einen Guard? Die Zuordnung dieser Ebenen steht in
[02 — Schichten](02_Schichten-Anweisung-Hook-Skill.md).

## Warum das hier steht und nicht in einem Werkzeug

Die GoM sind **keine Erfindung dieser Methode** und auch nichts, das man patentieren könnte. Genau
das ist ihr Wert: Sie sind älter als die Werkzeuggeneration, die sie brauchen würde, kommen aus einer
Disziplin mit dreißig Jahren Prüfung, und sie sind an keinen Ablauf gebunden — wie Write-Scope, Guard
und Nachweis auch nicht (siehe [07 — Verortung](07_Verortung.md)).

Wer eine Spec nach diesen sechs Kriterien prüft, tut etwas, das kein SDD-Werkzeug anbietet: Er
bewertet **die Qualität** statt der Form.

## Die Grenze

Die Grundsätze sagen, ob eine Spec **taugt** — nicht, ob sie **stimmt**. Eine Spec kann relevant,
klar, wirtschaftlich, vergleichbar und systematisch aufgebaut sein und trotzdem das Falsche
beschreiben. Dagegen hilft nur der Abgleich mit der Wirklichkeit, und der ist Gegenstand von
[05](05_Verifikation-statt-Behauptung.md).

Zweitens: Sechs Kriterien sind eine Prüfliste, kein Messwerkzeug. Sie erzwingen ein Urteil, sie
ersetzen es nicht. Wer eine Zahl daraus machen will, hat sie missverstanden.

## Prüfen

- [ ] **Relevanz:** Welchen Abschnitt könnte ich streichen, ohne dass die Spec an Wert verliert?
- [ ] **Vergleichbarkeit:** Liegt diese Spec auf derselben Flughöhe wie die daneben?
- [ ] **Klarheit:** Steht irgendwo etwas, das ein Mensch stillschweigend richtig ergänzen würde — ein
      Modell aber nicht?
- [ ] **Systematischer Aufbau:** Verweist jede Aussage über Grenzen und Rechte auf die Stelle, die
      sie durchsetzt?
- [ ] **Wirtschaftlichkeit:** Hat das Schreiben länger gedauert als das, was beschrieben wird?
- [ ] **Richtigkeit:** Ist die Form geprüft — und wer prüft die Aussage?

---

**Herleitung.** Grundsätze ordnungsmäßiger Modellierung nach Becker, Rosemann, Schütte (1995);
ausführlich in Becker/Kugeler/Rosemann (Hrsg.), *Prozessmanagement — Ein Leitfaden zur
prozessorientierten Organisationsgestaltung*, 7. Auflage, Springer 2012, Kapitel 3.1.2. Die
Anwendung auf Spezifikationen für KI-gestützte Arbeit ist eigenständig; die Grundsätze selbst sind
dort nachzulesen und werden hier nicht wiedergegeben.
