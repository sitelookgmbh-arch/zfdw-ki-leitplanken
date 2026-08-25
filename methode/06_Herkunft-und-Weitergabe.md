# 06 — Herkunft und Weitergabe

> **Kurz:** Wer aus Kundenarbeit Erkenntnisse destilliert, braucht **vor** dem Aufschreiben eine
> Weiche: gehört das in die freie Sammlung oder in die kundengebundene? Wer die Weiche erst beim
> Veröffentlichen stellt, hat schon zwei driftende Fassungen — oder ein Problem.

## Das Problem

Eine Erkenntnis entsteht selten im luftleeren Raum. Sie entsteht, weil in einem Kundenprojekt etwas
schiefging. Genau deshalb ist sie wertvoll — und genau deshalb klebt Kundenkontext daran:

- Der **Beleg** nennt das System, die Umgebung, die Datei, manchmal die Person.
- Der **Anlass** ist ein konkreter Fehlschlag, über den der Kunde nicht unbedingt öffentlich lesen
  möchte.
- Die **Rechtslage** ist oft eine andere, als man denkt: Wer selbst geschrieben hat, ist Urheber —
  aber wer die Inhalte zuvor unter eine gemeinsame Nutzungsregelung gestellt hat, hat sich
  möglicherweise selbst gebunden.

Wer das erst merkt, wenn das Repo öffentlich ist, merkt es zu spät. Und wer es umgeht, indem er alles
doppelt pflegt, hat in einem Jahr zwei Fassungen derselben Regel, die einander widersprechen.

## Die Weiche — drei Fragen, vor dem Schreiben

**1. Nennt es Kundenkontext?** Umgebung, Systemnamen, Vertragsdetails, Personen, Zahlen, Daten.
→ Ja: kundengebundene Sammlung. Ohne Wenn und Aber.

**2. Hätte ich das auch ohne diesen Kunden gewusst?** Ist die Regel unabhängig von Branche, Stack und
Vertrag gültig, und ist der Kunde nur der Ort, an dem sie mir aufgefallen ist?
→ Ja: freie Sammlung. Der Fehlschlag wird dabei so beschrieben, dass er in jedem Projekt hätte
passieren können — das ist keine Verschleierung, sondern die eigentliche Abstraktionsleistung.

**3. Ist es beides?** Der Normalfall bei guten Erkenntnissen.
→ **Kern trennen.** Das allgemeine Muster geht in die freie Sammlung. Der kundenspezifische Aufsatz —
konkrete Pfade, Stack-Eigenheiten, vereinbarte Schwellen — bleibt gebunden und **verweist** auf den
Kern, statt ihn zu wiederholen.

## Richtung der Abhängigkeit: frei ist die Basis

Die kundengebundene Sammlung ist ein **Overlay** auf der freien, nie eine Kopie davon.

```
frei (Basis)          allgemeines Muster, keine Herkunftsdetails
   ^
   | verweist
gebunden (Overlay)    Stack-Pfade, Schwellen, Vertragsbezug
```

Andersherum entsteht Drift: Zwei vollständige Fassungen werden gepflegt, bis eine vergessen wird.
Danach glaubt jeder der, die er zufällig zuerst liest.

Praktisch heißt das: Wenn ein Muster in beiden gebraucht wird, schrumpft der gebundene Teil auf
Titel, Link und die drei Zeilen, die tatsächlich projektspezifisch sind.

## Die Einbahnstraße

**Von frei nach gebunden: erlaubt.** Eine permissive Lizenz (Apache-2.0, MIT) erlaubt genau das —
Inhalte in eigene und Kundenprojekte übernehmen.

**Von gebunden nach frei: nie ohne Prüfung.** Was unter einer gemeinsamen Nutzungsregelung liegt,
gehört nicht dir allein — auch dann nicht, wenn du jede Zeile geschrieben hast. Typische Klauseln
verbieten die Weitergabe an Dritte ohne Zustimmung beider Seiten, und „Dritte" schließt Kunden,
Subunternehmer und die Öffentlichkeit ein.

Der gangbare Weg ist deshalb nicht Kopieren, sondern **neu schreiben aus dem Verstandenen**. Was du
im Kopf hast, gehört dir. Was als Datei unter der Vereinbarung liegt, bleibt dort liegen.

## Das Herkunfts-Gate vor jeder Veröffentlichung

Eine Prüfung, die man ausführen kann, nicht nur vornehmen will:

1. **Greppen.** Kundennamen, Produktnamen, Systemnamen, Domains, Fachvokabular des Kunden,
   Personennamen. Eine Liste je Kunde pflegen — sie wird länger, als man denkt.
   ```bash
   grep -rinE "kunde|produktname|systemname|fachbegriff|domain\.tld" . --exclude-dir=.git
   ```
   Ausgabe leer heißt: kein Namensbezug. Das ist die untere Schranke, nicht die Abnahme.
2. **Belege lesen.** Jeden Satz, der mit „in Projekt X hat sich gezeigt" beginnt: umschreiben auf
   das, was gezeigt wurde. Der Beleg wird dadurch schwächer — das ist der Preis, und er ist
   angemessen.
3. **Fremde Herkunft benennen.** Was von außen angeregt ist — anderes Projekt, fremdes Repo,
   Fachliteratur —, wird genannt, mit Link und mit der Angabe, was **nicht** übernommen wurde.
   Das ist keine Höflichkeit: Es macht überprüfbar, wo die eigene Leistung liegt.
4. **Lizenz prüfen, bevor kopiert wird.** Ein proprietär lizenziertes Repo darf angeregt haben. Sein
   Text darf nicht mitkommen.
5. **Informieren, nicht um Erlaubnis bitten** — wenn das Verhältnis es trägt. Zwei Sätze an den
   Partner, dass eine allgemeine Fassung erscheint und das Gemeinsame unberührt bleibt, kosten
   nichts. Sie später erklären zu müssen, kostet mehr.

## Was stattdessen oft versucht wird

| Statt dessen … | … und das passiert |
|---|---|
| **Alles doppelt pflegen.** | Zwei Fassungen, die auseinanderlaufen. Nach einem Jahr weiß niemand, welche gilt. |
| **„Ich hab's ja selbst geschrieben."** | Stimmt urheberrechtlich — sagt aber nichts darüber, was du vertraglich zugesagt hast. |
| **Namen ersetzen und veröffentlichen.** | Der Kontext bleibt erkennbar. Wer die Branche kennt, erkennt das Projekt an drei Details. |
| **Erst schreiben, dann sortieren.** | Sortieren nach dem Schreiben heißt umschreiben. Die Weiche steht vor dem ersten Satz. |
| **Aus Vorsicht gar nichts veröffentlichen.** | Auch eine Entscheidung — nur eine, die man selten bewusst trifft. Der abstrahierte Kern ist fast immer unbedenklich. |

## Prüfen

- [ ] Steht vor dem Aufschreiben fest, in welche der beiden Sammlungen es geht?
- [ ] Existiert dieselbe Regel irgendwo zweimal vollständig — statt einmal plus Verweis?
- [ ] Läuft das Herkunfts-Gate als Befehl, oder nur als guter Vorsatz?
- [ ] Ist bei jedem extern angeregten Inhalt Quelle **und** Abgrenzung genannt?
- [ ] Ist geklärt, was die gemeinsame Nutzungsregelung des gebundenen Teils zur Weitergabe sagt?
