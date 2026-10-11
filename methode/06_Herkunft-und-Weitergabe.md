# 06 — Herkunft und Weitergabe

> **Fassung 2 (Oktober 2026) — rechtliche Prüfung läuft.** Diese Fassung ersetzt die erste und ist
> vorsichtiger als sie. Sie ist keine Rechtsberatung; im Zweifel entscheidet eine Fachperson Recht.
>
> **Kurz:** Wer aus Kundenarbeit Erkenntnisse destilliert, braucht **vor** dem Aufschreiben eine Weiche: Gehört die Erkenntnis in die freie oder in die kundengebundene Sammlung? Allgemeines Erfahrungswissen kann frei beschrieben werden. Kundenspezifisches Know-how und geschützte Informationen brauchen eine andere Behandlung. Wer erst beim Veröffentlichen sortiert, hat bereits zwei driftende Fassungen — oder ein Problem.

## Das Problem

Eine Erkenntnis entsteht selten im luftleeren Raum. Oft entsteht sie, weil in einem Projekt etwas schiefging. Genau deshalb ist sie wertvoll — und genau deshalb kann Kontext daran haften:

- Der **Beleg** nennt ein System, eine Umgebung, eine Datei, manchmal eine Person.
- Der **Anlass** ist ein konkreter Fehlschlag, über den der Auftraggeber nicht unbedingt öffentlich lesen möchte.
- Die **Rechtslage** hängt nicht nur davon ab, wer etwas formuliert hat. Verträge, Nutzungsrechte und der Schutz vertraulicher Informationen können die Weitergabe begrenzen.

Wer das erst merkt, wenn das Repository öffentlich ist, merkt es zu spät. Und wer aus Vorsicht alles doppelt pflegt, hat bald zwei Fassungen derselben Regel, die einander widersprechen.

## Die Weiche — drei Fragen, vor dem Schreiben

**1. Nennt oder verrät es Kundenkontext?** Umgebung, Systemnamen, Vertragsdetails, Personen, Zahlen, Daten — oder eine Kombination, aus der sich der Zusammenhang erschließen lässt.

→ **Ja:** kundengebundene Sammlung. Namen ersetzen reicht nicht.

**2. Ist es ein allgemeines, eigenständig beschreibbares Muster?** Lässt es sich ohne vertrauliche Details erklären, mit einem synthetischen Fall belegen und unabhängig vom konkreten Projekt anwenden?

→ **Ja:** Kandidat für die freie Sammlung. Über die Veröffentlichung entscheiden erst die Selbstprüfung und das Herkunfts-Gate.

**3. Ist es beides?** Der Normalfall bei guten Erkenntnissen.

→ **Kern trennen.** Das allgemeine Muster wird neu formuliert und als Kategorie A geprüft. Der kundenspezifische Aufsatz — konkrete Pfade, Stack-Eigenheiten, vereinbarte Schwellen — bleibt gebunden und verweist auf den freien Kern, statt ihn zu wiederholen.

## Drei Kategorien für die Selbstprüfung

**A. Allgemeines Erfahrungswissen.** Eine fachliche Regel oder Vorgehensweise, die sich unabhängig von vertraulichen Einzelheiten erklären lässt.

*Synthetisches Beispiel:* In einem Demo-Repository erfasst `git add -A` auch eine unerwünschte Testdatei. Die allgemeine Erkenntnis: Vor dem Staging die tatsächlich betroffenen Pfade prüfen.

*Faustregel:* Frei veröffentlichen, wenn das Muster eigenständig formuliert ist, keine geschützten Inhalte offenlegt und das Herkunfts-Gate ohne ungeklärten Treffer besteht.

**B. Kundenspezifisches Know-how.** Besondere Konfigurationen, Abläufe, Schwellenwerte oder Zusammenhänge, die einen konkreten betrieblichen Kontext abbilden.

*Synthetisches Beispiel:* In einem erfundenen Demo-Ablauf gilt für eine bestimmte Konfigurationsdatei eine besondere Freigabegrenze. Die Idee einer Freigabeprüfung ist übertragbar; die konkrete Zuordnung und der Schwellenwert sind kontextgebunden.

*Faustregel:* Gebunden halten. Ein abgetrennter allgemeiner Kern wird wie Kategorie A geprüft. Trägt der zur Veröffentlichung vorgesehene Text weiterhin kundenspezifische Elemente oder bleibt ein Zweifel, gilt Stufe 2.

**C. Vertraglich oder gesetzlich geschützte Informationen.** Etwa Informationen unter einer Vertraulichkeitsvereinbarung (NDA), mögliche Geschäftsgeheimnisse oder Inhalte mit beschränkten Nutzungsrechten.

*Synthetisches Beispiel:* Eine erfundene Schnittstellenspezifikation wird in einer Übungsvereinbarung als vertraulich bezeichnet. Ein neu formulierter Text, der ihre nicht öffentlichen Regeln offenlegt, bleibt problematisch — auch ohne Namen oder wörtliche Übernahme.

*Faustregel:* Nicht veröffentlichen, solange die Zulässigkeit nicht geklärt und eine gegebenenfalls erforderliche Zustimmung nicht eingeholt ist.

Die Kategorien sind **Prüfkategorien**, keine wasserdichten Schubladen. Kundenspezifisches Know-how kann zugleich vertraulich oder als Geschäftsgeheimnis geschützt sein. Im Zweifel bleibt der betroffene Inhalt gebunden, bis die Frage geklärt ist.

## Richtung der Abhängigkeit: frei ist die Basis

Die kundengebundene Sammlung ist ein **Overlay** auf der freien, nie eine Kopie davon.

```text
frei (Basis)          allgemeines Muster, keine Herkunftsdetails
   ^
   | verweist
gebunden (Overlay)    Stack-Pfade, Schwellen, Vertragsbezug
```

Andersherum entsteht Drift: Zwei vollständige Fassungen werden gepflegt, bis eine vergessen wird. Danach gilt oft die Fassung, die jemand zuerst findet.

Praktisch heißt das: Wenn ein Muster in beiden Sammlungen gebraucht wird, schrumpft der gebundene Teil auf Titel, Verweis und die wenigen Zeilen, die tatsächlich projektspezifisch sind. Voraussetzung ist, dass der freie Kern veröffentlicht werden darf.

## Die Einbahnstraße

**Von frei nach gebunden: erlaubt.** Eine permissive Lizenz (Apache-2.0, MIT) erlaubt genau das — Inhalte in eigene und Kundenprojekte übernehmen. Bei einer Weitergabe unter Apache-2.0 sind insbesondere der Lizenztext, einschlägige Hinweise aus einer vorhandenen `NOTICE`-Datei und die Kennzeichnung geänderter Dateien zu beachten.

**Von gebunden nach frei: nie ohne Prüfung.** Eine eigene Formulierung beseitigt keine vertraglichen Pflichten und keine Rechte Dritter. Auch das Aufschreiben aus der Erinnerung kann geschützte Informationen offenlegen.

Der gangbare Weg ist **neu schreiben aus dem Verstandenen** — aber nicht als Trick, um eine gebundene Quelle umzubenennen:

- **Vertretbar als Arbeitsprinzip:** Aus eigener Berufserfahrung wird ein allgemeines Verfahren in eigenen Worten entwickelt. Es lässt sich ohne Kundendokumente, vertrauliche Einzelheiten oder rekonstruierte Sonderregeln erklären und anhand eines eigenständigen, synthetischen Beispiels prüfen. Es sind keine einschlägigen Nutzungs- oder Offenlegungsbeschränkungen erkennbar.
- **Nicht vertretbar ohne weitere Klärung:** Der neue Text übernimmt oder rekonstruiert vertrauliche Abläufe, nicht öffentliche Parameter, geschützte Ausdrucksformen oder andere Informationen, deren Nutzung oder Offenlegung begrenzt ist — auch wenn keine Datei kopiert und kein Name genannt wird.

Die Erfahrung kann der **Anlass** sein. Sie ist keine pauschale Veröffentlichungserlaubnis. Entscheidend ist, **was** der neue Text offenlegt und welchen Pflichten diese Information unterliegt.

## Das Herkunfts-Gate vor jeder Veröffentlichung

Eine Prüfung, die man ausführen kann, nicht nur vornehmen will:

1. **Greppen.** Nach Kunden-, Produkt-, System- und Personennamen, Domains und kundenspezifischem Fachvokabular suchen. Die Begriffsliste bleibt intern und wird nicht mitveröffentlicht — sie wird länger, als man denkt.

   ```bash
   grep -rinE "kunde|produktname|systemname|fachbegriff|domain\.tld" . --exclude-dir=.git
   ```

   Im Repository erledigt das `werkzeuge/herkunft-check.sh` mit einer lokalen, nicht eingecheckten Begriffsliste (`.herkunft-begriffe`, Vorlage `werkzeuge/herkunft-begriffe.vorlage`). Eine eigene Testsuite hat das Werkzeug bisher nicht. Leere Ausgabe bedeutet nur: kein Treffer auf diese Suchmuster. Das ist die untere Schranke, nicht die Freigabe.

2. **Belege lesen.** Jeden projektspezifischen Beleg darauf prüfen, ob er eine allgemeine Aussage trägt. Wenn ja: einen neuen, synthetischen Beleg herstellen. Der Beleg wird dadurch schwächer — das ist der Preis, und er ist angemessen. Wenn nein: Aussage gebunden halten.

3. **Herkunft benennen.** Bei zulässig nutzbaren öffentlichen Quellen die Quelle nennen und angeben, was **nicht** übernommen wurde. Vertrauliche Herkunft nicht durch eine Quellenangabe offenlegen.

4. **Rechte prüfen, bevor übernommen wird.** Fremde Texte, Code und Vorlagen nur im Umfang vorhandener Rechte und Lizenzen übernehmen. Eine neue Formulierung ersetzt nicht die Prüfung möglicherweise geschützter Inhalte.

5. **Erkennbarkeit prüfen.** Könnte jemand den konkreten Zusammenhang aus Branche, Ablauf, Zahlen oder ungewöhnlichen Details erschließen? Wenn ja: Inhalt gebunden halten oder Stufe 2 auslösen.

6. **Informieren oder Zustimmung einholen.** Eine freiwillige Information kann die Zusammenarbeit erleichtern, ersetzt aber keine erforderliche Zustimmung. Besteht eine Zustimmungspflicht oder ist sie unklar, wird das **vor** der Veröffentlichung geklärt — nicht danach.

## Die Freigabeprüfung — zwei Stufen

**Stufe 1: Selbstprüfung, immer.** Vor jedem freien Text die drei Kategorien anwenden und das Herkunfts-Gate durchlaufen. Das Ergebnis kurz festhalten: *allgemeines Muster / keine erkennbaren Beschränkungen / Gate ohne ungeklärten Treffer* — oder den konkreten Klärungsbedarf notieren.

→ **Ohne erkennbaren Treffer:** interne Freigabe nach dokumentierter Selbstprüfung. Keine pauschale Rechtsprüfung für jede allgemein formulierte Methode.

**Stufe 2: Fachperson Recht, nur bei Treffer.** Einschalten, wenn eine einschlägige Nutzungsbeschränkung oder NDA besteht, der zur Veröffentlichung vorgesehene Text kundenspezifisches Know-how enthält, ein gesetzlicher Schutz naheliegt oder Zweifel an Herkunft, Rechten oder Erkennbarkeit bleiben.

→ **Bis zur Klärung:** den betroffenen Inhalt nicht veröffentlichen. Eine rechtliche Einschätzung ersetzt keine erforderliche Zustimmung. Andere, unbedenkliche Methoden können weiter erscheinen.

So wird aus Sorgfalt keine allgemeine Veröffentlichungssperre. Die Prüfung richtet sich nach dem konkreten Risiko, nicht nach der bloßen Tatsache, dass eine Erkenntnis im Berufsalltag entstanden ist.

## Was stattdessen oft versucht wird

| Stattdessen … | … und das passiert |
|---|---|
| **Alles doppelt pflegen.** | Zwei Fassungen laufen auseinander. Nach einem Jahr weiß niemand, welche gilt. |
| **„Ich hab's ja selbst geschrieben.“** | Die eigene Formulierung sagt nichts über Vertraulichkeit, Nutzungsrechte oder Offenlegungsverbote. |
| **Namen ersetzen und veröffentlichen.** | Der Zusammenhang bleibt womöglich erkennbar. Drei besondere Details reichen manchmal. |
| **Aus der Erinnerung umschreiben.** | Neu formuliert heißt nicht automatisch frei verwendbar. Entscheidend ist der Inhalt. |
| **Erst schreiben, dann sortieren.** | Sortieren nach dem Schreiben heißt umschreiben. Die Weiche steht vor dem ersten Satz. |
| **Aus Vorsicht gar nichts veröffentlichen.** | Eine überzogene Sperre. Allgemeine Muster können nach Stufe 1 erscheinen; konkrete Treffer gehen in Stufe 2. |

## Prüfen

- [ ] Steht vor dem Aufschreiben fest, ob der Inhalt frei, gebunden oder rechtlich klärungsbedürftig ist?
- [ ] Ist allgemeines Erfahrungswissen von kundenspezifischem Know-how und geschützten Informationen getrennt?
- [ ] Existiert dieselbe Regel irgendwo zweimal vollständig — statt einmal plus Verweis?
- [ ] Läuft das Herkunfts-Gate als Befehl **und** als inhaltliche Prüfung?
- [ ] Ist die neue Fassung eigenständig, oder rekonstruiert sie gebundene Inhalte?
- [ ] Sind bei fremden Quellen Rechte, Lizenzbedingungen und zulässige Herkunftsangaben geklärt?
- [ ] Ist die Stufe-1-Entscheidung dokumentiert? Wurde bei NDA, Nutzungsbeschränkung, kundenspezifischem Know-how im Text oder Zweifeln Stufe 2 ausgelöst?
- [ ] Liegen erforderliche Zustimmungen vor, bevor veröffentlicht wird?

## Annahmen und offene Prüfpunkte

- Die Beispiele sind vollständig synthetisch. Sie begründen keine Freigabe realer Projektinformationen.
- Einschlägige Verträge, Vertraulichkeitsvereinbarungen und Rechte an Arbeitsergebnissen wurden nicht geprüft.
- `werkzeuge/herkunft-check.sh` ist vorhanden und im Einsatz, hat aber keine eigene Testsuite.
- Ob die zweistufige Prüfung im konkreten Veröffentlichungskontext rechtlich ausreicht, ist offen. Dieser Entwurf ist **keine Rechtsberatung**.

## Fragen an die Fachperson Recht

1. **Vertragsgrenzen:** Welche NDA-, Nutzungsrechts- und Vertraulichkeitsklauseln können auch allgemeine Methoden oder später neu formulierte Erkenntnisse erfassen?
2. **Erfahrungswissen:** Unter welchen Voraussetzungen darf fachliches Wissen aus einem Auftrag für eine eigenständige, allgemein gefasste Methode genutzt werden — und wann bleibt selbst die sinngemäße Offenlegung untersagt?
3. **Geschäftsgeheimnisse:** Wie sind die Voraussetzungen des § 2 GeschGehG und die Verbote des § 4 GeschGehG im Einzelfall zu prüfen, auch wenn Informationen nur aus der Erinnerung wiedergegeben werden?
4. **Kundenspezifisches Know-how:** Welche Merkmale oder Kombinationen scheinbar harmloser Details können einen abstrahierten Text weiterhin vertraulich oder einem Auftrag zurechenbar machen?
5. **Rechte an Arbeitsergebnissen:** Welche vertraglichen Nutzungsrechte, Urheberrechte oder sonstigen Rechte können einer eigenständigen Veröffentlichung entgegenstehen, auch ohne Übernahme eines Originaldokuments?
6. **Zustimmung:** In welchen Fällen reicht eine Information an den Vertragspartner, und wann ist vorab eine ausdrückliche Zustimmung erforderlich?
7. **Verfahren:** Ist die zweistufige Prüfung mit dokumentierter Selbstentscheidung und gezielter rechtlicher Eskalation für diesen Veröffentlichungskontext angemessen? Welche Mindestnachweise sollten aufbewahrt werden?
