# 12 — Lernschleife: Fehler werden Prüfregeln

> **Kurz:** Ein dokumentierter Fehler ist noch kein verhinderter Fehler. Aus belegten Vorfällen
> werden Vorschläge für technische Prüfungen. Assistenten dürfen diese vorschlagen; in Kraft
> setzt sie ein Mensch über den normalen Änderungsweg.

## Das Problem

Eine falsche Erfolgsmeldung wird korrigiert und als Notiz festgehalten. Beim nächsten Umbau tritt
sie wieder auf: Die Notiz war vorhanden, aber nichts hat das falsche Ergebnis verhindert.
Mehr Anweisungstext allein schließt diese Lücke nicht.

Das [Nahtstellen-Register](11_Nahtstellen-Register.md) hält Fallen fest, die ein Review an Dateien
prüfen kann. Fehler in Abläufen reichen darüber hinaus. Ein Runbook erklärt die richtige Bedienung;
die Lernschleife fragt zusätzlich, welche ausführbare Prüfung den nächsten Fehlversuch erkennt.

## Die Regel

**1. Jeden belegten Fehler erkennbar erfassen.** Eine markierte Protokollzeile, etwa mit `fehler:`,
oder eine begründete Rückgabe widersprüchlicher Anforderungen reicht als Eingang. Festgehalten
werden Auslöser, beobachtetes Ergebnis, erwartetes Ergebnis und ein nachprüfbarer Beleg.
Eine Vermutung bleibt ausdrücklich unbestätigt, bis der Beleg vorliegt.

Was ohne diese Regel schiefgeht: Der nächste Leser kann einen nachgewiesenen Fehler nicht von einer
Befürchtung unterscheiden. Unmarkierte Vorfälle verschwinden zwischen gewöhnlichen Statusmeldungen
und fehlen später bei der Auswertung.

**2. Aus den Belegen Vorschläge sammeln und Wiederholungen zählen.** Ein Sammler — zunächst auch
von Hand — ordnet zusammengehörige Vorfälle einer stabilen Eintrags-ID zu. Er schlägt neue Einträge
oder Ergänzungen vor, mit Belegverweisen, Datum jedes Auftretens und Wiederholungszahl. Derselbe
Beleg wird nur einmal gezählt. Dateibezogene Fallen gehören ins Register aus Methode 11; für
Ablauffehler wird eine getrennte Liste geführt, die bei Änderungen am Ablauf geprüft wird.

Was ohne diese Regel schiefgeht: Einzelne Notizen sehen wie voneinander unabhängige Pannen aus.
Das wiederkehrende Muster bleibt unsichtbar; doppelt eingelesene Meldungen können umgekehrt eine
Häufung vortäuschen. Ein Vorschlag braucht deshalb Prüfung, bevor er als Eintrag gilt.

**3. Jeden Eintrag mit genau einem konkreten technischen Gegenmittel versehen.** Benannt werden
Prüfung und Fundstelle: etwa ein Test, eine Lint-Regel, ein Hook, ein Werkzeug oder eine Prüfung
in der Oberfläche. Das Gegenmittel muss die beschriebene Fehlerform erkennen. Vor „abgesichert“
steht ein ausgeführter Gegenbeweis: Der fehlerhafte Fall fällt durch, ein zulässiger Fall passiert
(siehe [05 — Verifikation](05_Verifikation-statt-Behauptung.md)). Gibt es kein sinnvolles technisches
Gegenmittel, bleibt der Eintrag offen mit „ohne Gegenmittel, begründet“ und dem konkreten Grund.

Was ohne diese Regel schiefgeht: „Besser aufpassen“ wird als Lösung verbucht, obwohl sich am Ablauf
nichts geändert hat. Eine Anweisung oder Notiz allein zählt hier nicht als Gegenmittel:
[02 — Schichten](02_Schichten-Anweisung-Hook-Skill.md) erklärt den Ablageort,
[04 — Guards](04_Deterministische-Guards.md) die ausführbare Sicherung. Genau ein benanntes
Gegenmittel macht prüfbar, welcher Schutz den Eintrag absichert, statt Verantwortung auf eine
unscharfe Sammlung von Maßnahmen zu verteilen.

**4. Bei erneutem Auftreten einen abgesicherten Eintrag wieder öffnen.** Der neue Beleg und die
Wiederholung werden ergänzt; der Status wechselt von „abgesichert“ zu „offen“. Danach wird geprüft,
ob das Gegenmittel fehlte, umgangen wurde oder die Fehlerform nicht erfasst. Erst ein erneuter
Wirksamkeitsnachweis erlaubt wieder „abgesichert“.

Was ohne diese Regel schiefgeht: Die Liste behauptet weiterhin Schutz, obwohl der Betrieb bereits
das Gegenteil gezeigt hat. Der alte grüne Prüflauf verdeckt die neue Lücke, statt ihre Untersuchung
auszulösen.

**5. Assistenten schlagen vor, Menschen setzen in Kraft.** Änderungen an Regeln, Hooks und Guards
laufen über den üblichen Änderungsweg: nachvollziehbarer Diff, Tests, Review und menschliche
Freigabe vor der Aktivierung. Der Sammler darf weder seine Vorschläge automatisch aktivieren noch
Schutzregeln eigenständig abschwächen. Das gilt auch für Änderungen an ihm selbst.

Was ohne diese Regel schiefgeht: Ein fehlerhafter oder durch Fremdtext beeinflusster Assistent kann
einen störenden Schutz als Fehler einstufen und ihn selbst beseitigen. Die Lernschleife würde dann
ihre eigenen Sicherungen abbauen. Ein Vorschlag ist deshalb keine Berechtigung zur Änderung des
laufenden Schutzes.

## Synthetisches Beispiel

Ein erfundenes Exportwerkzeug meldet „erfolgreich“, obwohl das Schreiben der Ausgabedatei
fehlgeschlagen ist. Eine markierte Fehlermeldung enthält den reproduzierbaren Aufruf und das
fehlende Ergebnis. Der Sammler schlägt einen Eintrag vor; eine zweite, eigenständige Beobachtung
wird derselben ID als Wiederholung zugeordnet.

Als einziges Gegenmittel erhält der Eintrag einen Integrationstest: Bei einem simulierten
Schreibfehler muss der Export fehlschlagen und darf keine Erfolgsmeldung ausgeben. Der Test wird
gegen die fehlerhafte und die korrigierte Fassung ausgeführt; ein erfolgreicher Export dient als
Gegenprobe. Nach Review und menschlicher Freigabe wird die Änderung übernommen und der Eintrag
mit dem Prüfnachweis auf „abgesichert“ gesetzt. Tritt dieselbe falsche Erfolgsmeldung später über
einen anderen Ausgabepfad auf, wird dieser Eintrag wieder geöffnet und der Test um den Fall ergänzt.

## Grenzen

- Die Erfassung sieht nur, was jemand markiert und belegt. Wenige Einträge beweisen keinen
  fehlerfreien Betrieb.
- Vorschläge können rauschen: Ähnliche Symptome können unterschiedliche Ursachen haben.
  Zusammenführen und Trennen von Einträgen braucht Prüfung; Belege müssen dabei erhalten bleiben.
- Nicht jeder Fehler lässt sich sinnvoll technisch erkennen. „Ohne Gegenmittel, begründet“ hält
  diese Grenze sichtbar; eine erzwungene Scheinprüfung würde nur falsches Vertrauen erzeugen.
- Eine vorhandene Prüfung wirkt nur dort, wo sie tatsächlich ausgeführt wird. Menschliche
  Freigabe und ein grüner Test garantieren keine vollständige Abdeckung aller Ausführungspfade.
- Reale Belege können vertrauliche Inhalte tragen. Vor Weitergabe gilt
  [06 — Herkunft und Weitergabe](06_Herkunft-und-Weitergabe.md); dieses Beispiel enthält keine
  realen Vorfälle oder Betriebsdaten.

## Prüfen

- [ ] Hat jeder erfasste Fehler einen Beleg und jeder Eintrag eine stabile ID?
- [ ] Werden Vorschläge geprüft und doppelte Belege beim Zählen ausgeschlossen?
- [ ] Nennt jeder Eintrag genau ein technisches Gegenmittel mit Fundstelle oder ausdrücklich
      „ohne Gegenmittel, begründet“?
- [ ] Ist für „abgesichert“ der fehlerhafte Fall tatsächlich abgewiesen und ein zulässiger Fall
      erfolgreich geprüft worden?
- [ ] Öffnet ein erneuter Vorfall den Eintrag wieder, einschließlich Beleg und Wiederholungszahl?
- [ ] Werden Änderungen an Regeln, Hooks und Guards erst nach menschlicher Freigabe wirksam?
- [ ] Wie groß ist der Anteil der Einträge mit vorhandenem technischem Gegenmittel an allen
      bestätigten Einträgen? Zähler, Nenner und Stichtag nennen; bei leerer Liste ist der Anteil
      nicht bestimmbar. Begründete Ausnahmen im Nenner lassen und gesondert ausweisen.
- [ ] Wie entwickeln sich die Wiederholungen je Eintrag in vergleichbaren Zeiträumen, besonders
      seit Aktivierung des Gegenmittels? Ausführungshäufigkeit und Erfassungslücken mitbetrachten:
      Weniger Betrieb kann ebenfalls weniger Vorfälle bedeuten.
