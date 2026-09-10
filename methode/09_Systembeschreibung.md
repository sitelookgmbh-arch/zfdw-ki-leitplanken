# 09 — Systembeschreibung

> **Kurz:** Die Anweisungsdatei ist zu klein für ein Datenmodell, der Code zu groß zum Lesen.
> Dazwischen fehlt eine Ebene — und sie besteht aus vier Dateien, die vier verschiedene Fragen
> beantworten. Wer sie zu einer zusammenzieht, bekommt keine davon beantwortet.

## Das Problem

Ein Assistent mit Schreibrecht kennt zwei Zustände: die Anweisungsdatei, die immer mitläuft, und
das, was er gerade geöffnet hat. Dazwischen liegt alles, was eine gewachsene Anwendung ausmacht —
wie die Dinge heißen, wer sie schreiben darf, welche Quelle bei Widerspruch gilt.

Die naheliegenden zwei Wege führen beide in dieselbe Sackgasse.

Wer es in die Anweisungsdatei schreibt, verletzt [03 — Kontext-Budget](03_Kontext-Budget.md): Ein
Schema mit neunzig Feldern kostet in jedem einzelnen Zug Aufmerksamkeit, auch in den neunundneunzig
von hundert, in denen es nicht gebraucht wird. Wer es weglässt, bekommt die andere Hälfte des
Problems: Der Assistent liest drei Dateien, bildet daraus eine Vorstellung vom Ganzen und arbeitet
konsequent nach dieser Vorstellung weiter. Sie ist plausibel, sie ist zusammenhängend, und sie
stimmt an genau den Stellen nicht, an denen die Anwendung von der naheliegenden Bauart abweicht —
also überall dort, wo es teuer wird.

Der Code beantwortet die Frage nicht. Er sagt, was passiert, nicht was es sein soll. Eine
Spaltenbezeichnung im Zielsystem, ein Feld, das absichtlich niemand schreibt, eine Quelle, die bei
Konflikt gewinnt — nichts davon steht im Code, und alles davon entscheidet, ob eine Änderung
richtig oder falsch ist.

## Vier Fragen, vier Dateien

Die Ebene dazwischen ist keine Datei, sondern vier. Sie zu trennen ist kein Ordnungssinn, sondern
Notwendigkeit: Jede hat eine andere Lebensdauer und einen anderen Prüfweg.

| Frage | Datei | Ändert sich | Geprüft wird gegen |
|---|---|---|---|
| Was ist das für ein System? | Systembeschreibung | selten | den Zweck, nicht den Code |
| Wie heißen die Dinge? | Schema | je Feature | den Quelltext |
| Wo stehen sie wirklich? | Mapping | je Umgebung | das laufende Zielsystem |
| Was kommt als Nächstes? | Sprintbogen | je Sprint | [01 — Sprintplan](01_Sprintplan-und-Write-Scope.md) |

**Die Systembeschreibung** beantwortet, was der Code nie beantwortet: wozu das Ganze da ist, wer es
benutzt, welche Abläufe es trägt und wo es absichtlich aufhört. Sie ist die Datei, die ein neuer
Mensch und ein neuer Kontext zuerst lesen. Sie enthält keine Feldnamen.

**Das Schema** ist die eine Stelle, an der steht, wie die Dinge heißen und wer sie schreiben darf.
Es ist Quelle der Wahrheit für die Benennung — nicht der Code, nicht die Anweisungsdatei, nicht ein
Kommentar.

**Das Mapping** ist die unbequeme Datei. Sie hält fest, wie das Schema sich zum tatsächlich
laufenden Zielsystem verhält: welche Bezeichnung dort abweicht, welcher Typ nicht passt, welche
Spalte noch fehlt. Sie existiert, weil Schema und Wirklichkeit auseinanderlaufen, sobald jemand
außerhalb des Repos etwas anlegt.

**Der Sprintbogen** sagt nur, welche Abschnitte es gibt und in welcher Reihenfolge sie kommen. Der
Stand eines Abschnitts steht in seiner eigenen Datei — das ist der Kern von
[01](01_Sprintplan-und-Write-Scope.md) und gilt hier unverändert.

## Die Schichtung der Wahrheit

Der Abschnitt, der in der Praxis am meisten trägt und am häufigsten fehlt, steht in der
Systembeschreibung und ist eine einzige Tabelle: **Welche Schicht ist wofür die Wahrheit, und wer
schreibt sie.**

```
Vorsystem     Wahrheit der gelesenen Felder      niemand sonst schreibt sie
Zielsystem    Wahrheit der eigenen Felder        die Anwendung, über den Schreibweg
Read-Model    Ableitung, periodisch erzeugt      ein Dienst, nie ein Mensch
Client-Puffer optimistische Überlagerung         nie Wahrheit, jederzeit verwerfbar
```

Ohne diese vier Zeilen rät der Assistent bei jedem Schreibpfad neu — und rät plausibel, nämlich
auf die einfachste Bauart: eine Quelle, alles schreibbar. Genau das ist bei jedem System falsch,
das an einem Vorsystem hängt.

Die Tabelle kostet zehn Minuten und beantwortet die Frage, an der sonst jede zweite
Konfliktentscheidung hängt.

## Der Fehler, den drei Dateien erst sichtbar machen

Ein Feld wurde in der Oberfläche gesperrt dargestellt, mit dem Hinweis, sein Wert komme aus dem
Vorsystem. Die Spalte war im Zielsystem angelegt und im Mapping verzeichnet. In der Liste der
Felder, die tatsächlich aus dem Vorsystem geliefert werden, stand sie nicht.

Drei Dokumente, drei Aussagen über dasselbe Feld, und keine widersprach der anderen offen — sie
schwiegen nur jeweils an unterschiedlicher Stelle. Die Lücke lag Monate unentdeckt und wurde als
Verzögerung der Datenlieferung geführt. Tatsächlich war nie eine Lieferung vereinbart worden.
Gefunden wurde sie erst, als jemand die drei Dateien nebeneinander legte.

Zwei Lehren, und beide gehören in die Methode:

**Der Nutzen dieser Ebene entsteht nicht beim Schreiben, sondern beim Gegenlesen.** Vier getrennte
Dateien sind nicht deshalb besser, weil sie ordentlicher sind, sondern weil ein Widerspruch
zwischen ihnen auffällt. In einer einzigen Datei hätte niemand etwas bemerkt.

**Ein Feld ohne benannte Quelle ist ein offener Punkt, kein Feld.** Wo etwas herkommt, gehört ins
Schema — und wenn die Antwort „von außen" lautet, muss es in der Liste dessen stehen, was von außen
kommt. Sonst wartet die Anwendung auf einen Wert, den niemand schuldet.

## Wer wen überstimmt

Vier Dateien heißen vier mögliche Widersprüche. Die Rangfolge gehört in die Dateien selbst, nicht
in den Kopf dessen, der sie zuletzt angefasst hat:

- Das **Mapping** überstimmt das **Schema**, wo es um den tatsächlichen Zustand geht. Es ist gegen
  ein laufendes System geprüft; das Schema ist eine Absicht.
- Das **Schema** überstimmt die **Systembeschreibung** in allen Benennungsfragen. Die
  Systembeschreibung soll gar keine Feldnamen führen — tut sie es doch, veraltet sie zuerst dort.
- Die **Systembeschreibung** überstimmt beide in der Frage, **wozu** etwas da ist. Diese Frage
  beantwortet kein Schema.

Praktisch heißt das: Jede der Dateien trägt im Kopf, gegen was sie geprüft wurde und wann. Ein
Schema-Dokument, das seit vier Releases nicht angefasst wurde, ist nicht wertlos — aber es muss
selbst sagen, wer es inzwischen überstimmt. Das ist eine Zeile und erspart die Frage, ob man dem
Dokument noch glauben darf.

## Die Grenze

Diese vier Dateien beschreiben, **was** ein System ist — nicht, **ob es stimmt**. Der Abgleich mit
dem Laufenden bleibt Gegenstand von
[05 — Verifikation statt Behauptung](05_Verifikation-statt-Behauptung.md); die Frage, ob die
Beschreibung taugt, beantwortet [08 — Spezifikationsgüte](08_Spezifikationsguete.md).

Und: Vier ist eine Obergrenze, keine Vorgabe. Ein Vorhaben ohne Vorsystem braucht kein Mapping. Ein
Werkzeug ohne Datenhaltung braucht kein Schema. Wer die vier Dateien anlegt, weil sie hier stehen,
hat [08](08_Spezifikationsguete.md) nicht gelesen — die Frage lautet in jedem Einzelfall, was ihr
Fehlen kosten würde.

## Prüfen

- [ ] Kann der Assistent nach dem Lesen **einer** Datei sagen, wozu das System da ist — ohne den
      Code zu öffnen?
- [ ] Steht für jedes Feld, wer es schreiben darf und woher sein Wert kommt?
- [ ] Gibt es für jedes Feld, dessen Wert „von außen" kommt, eine Gegenstelle, die diese Lieferung
      führt?
- [ ] Trägt jede der Dateien im Kopf, gegen was und wann sie zuletzt geprüft wurde?
- [ ] Ist die Schichtung der Wahrheit als Tabelle da — oder steht sie nur in der Erinnerung
      derjenigen, die dabei waren?
- [ ] Enthält die Systembeschreibung Feldnamen? Dann gehören sie ins Schema.

---

**Herleitung.** Die Aufteilung ist aus der Arbeit an einer gewachsenen Fachanwendung entstanden,
die an einem Vorsystem hängt und über vier Sprints nach dieser Methode fortgeschrieben wurde. Der
Abschnitt *Schichtung der Wahrheit* geht auf eine Entscheidung zurück, die dort getroffen werden
musste, weil ohne sie kein Schreibweg entworfen werden konnte. Der beschriebene Fehler ist ein
tatsächlicher Befund aus derselben Anwendung; er wurde beim Gegenlesen der drei Dateien gefunden,
nicht beim Testen.
