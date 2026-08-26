---
sprint: NN
slug: {{KURZ_SLUG}}
plan: docs/plan/PLAN.md
status: geplant            # geplant | laufend | pruefung | abgeschlossen | blockiert
schutzbedarf: normal       # normal | erhoeht | hoch  (bestimmt Freigabe und Nachweistiefe)
umgebung: test             # test | integration | produktiv
verantwortlich: {{NAME}}
freigabe: {{NAME_ODER_OFFEN}}
---

# Sprint NN — {{TITEL}}

> Diese Datei **ist** der Stand des Arbeitsabschnitts und zugleich sein Nachweis. Kein
> zweiter Zustandsspeicher daneben. Sie bleibt nach Abschluss liegen — sie ist die
> Begründungsspur zum Diff und das, was in einem Assessment vorgezeigt wird.

## 1. Auftrag

Ein Absatz: was nach diesem Abschnitt anders ist — nicht, was gebaut wird.

## 2. Schnitt

**Enthalten**
- Konkrete Aufgabe

**Ausdrücklich nicht enthalten**
- Was hier bewusst unterbleibt. Mindestens ein Punkt; „nichts" ist fast immer falsch.

Der zweite Block ist der wichtigere. Er ist die Grenze, an der ein Assistent anhält, und
die Antwort auf die Frage, warum etwas nicht mitgemacht wurde.

## 3. Schutzbedarf und Datenklassen

Welche Daten fasst dieser Abschnitt an?

| Klasse | Was | Regel |
|---|---|---|
| **A** — reale Sach- und Geschäftsdaten | Vorgangsnummern, Preise, Kundenstämme | nie versioniert; zur Laufzeit geladen, Abwesenheit muss der Code aushalten |
| **B** — reale Personendaten | Name, Kennung, Rolle | nur mit benannter Rechtsgrundlage, befristet, mit Ablösedatum |
| **C** — synthetische Daten | generierte Fixtures | uneingeschränkt versionierbar |

- [ ] Dieser Abschnitt berührt **keine** Daten der Klassen A oder B.
- [ ] Er berührt Klasse ___ . Rechtsgrundlage / Freigabe: ___ . Ablösedatum: ___ .

⚠️ **Ein Commit ist unwiderruflich.** Was einmal in der History steht, steht in jedem Klon,
jedem Fork, jedem CI-Cache und jedem Backup. Ein Löschbegehren ist dagegen praktisch nicht
durchsetzbar. Die Entscheidung, ob reale Daten versioniert werden, gehört deshalb nicht der
Person, die gerade committet.

## 4. Write-Scope — wer schreibt was

Das tragende Element. Jede Datei, die dieser Abschnitt **schreiben** darf, steht hier.

| Pfad / Muster | Schreiber | Schutzbedarf | Guard |
|---|---|---|---|
| `{{pfad}}` | {{NAME}} | normal | — |

Regeln:

- Schreiben außerhalb dieser Liste ⇒ **anhalten** und `außerhalb des Write-Scope` melden.
  Nicht stillschweigend erweitern; die Erweiterung ist eine Änderung dieser Datei.
- Dateien mit genau einem Schreiber und nie parallel: `VERSION`, `CHANGELOG.md`,
  Anweisungsdateien, Konfiguration der Auslieferung, diese Plan-Dateien.
- Steht in der Spalte **Guard** ein Hook, ist die Grenze deterministisch durchgesetzt.
  Steht dort ein Strich, hängt sie an der Disziplin — bei erhöhtem Schutzbedarf ist das
  zu wenig.
- Zwei Abschnitte parallel nur bei **disjunktem** Write-Scope.

## 5. Zugänge und Geheimnisse

| Gebraucht wird | Wer erteilt | Wie lange |
|---|---|---|
| — | — | — |

- [ ] Es werden **keine** zusätzlichen Zugänge gebraucht.
- Zugangsdaten, Schlüssel und Token tippt der Mensch. Nie in einen Chatverlauf, nie ins
  Repo, nie in eine Umgebungsvariable, die in einem Log landet.
- Ist ein Geheimnis versehentlich sichtbar geworden: **rotieren**, nicht löschen. Löschen
  entfernt es nicht aus der History, sondern nur aus der Sicht.
- Nach Abschluss: befristete Zugänge zurückgeben. Der Eintrag hier ist die Erinnerung daran.

## 6. Änderungsklasse und Freigabe

| Klasse | Wann | Freigabe durch |
|---|---|---|
| **Standard** | wiederkehrend, Verfahren erprobt, Rückweg bekannt | keine gesonderte |
| **Normal** | alles Übrige | benannte Person, vor Beginn |
| **Notfall** | Störungsbeseitigung unter Zeitdruck | nachträglich, binnen ___ , schriftlich |

Diese Änderung ist: **___** . Freigegeben durch **___** am **___** .

Eine Notfalländerung ohne nachgeholte Freigabe ist keine Notfalländerung, sondern eine
undokumentierte.

## 7. Nachweise

Nicht „Akzeptanzkriterien", sondern Kriterium **plus Beleg**. Ein Kriterium ohne Beleg gilt
als nicht erfüllt — im Review wie im Assessment.

**Form des Kriteriums:** *Gegeben* — Ausgangszustand · *wenn* — auslösende Handlung · *dann*
— beobachtbares Ergebnis. Wer ein Kriterium nicht in diese Form bringt, hat keines, sondern
eine Absicht. „Funktioniert wieder" nennt weder den Ausgangszustand noch das, was man danach
sehen können muss — und ist deshalb am Ende Verhandlungssache statt Prüfsache.

| # | Kriterium | Beleg | Liegt wo |
|---|---|---|---|
| 1 | Gegeben ein Konto ohne Rolle *Prüfer*, wenn es `/freigabe` aufruft, dann Antwort 403 und **kein** Eintrag im Freigabeprotokoll | Befehlsausgabe + Protokollauszug | `docs/plan/sprint-07/` |
| 2 | | Befehlsausgabe / Screenshot / Protokolleintrag | |

## 8. Verifikation

Die konkreten Zeilen, mit denen geprüft wird. Drei Fallen, die regelmäßig zuschlagen:

- **Ein Statuscode beweist nichts.** Viele Auslieferungen antworten auf unbekannte Pfade mit
  200. Was zählt, ist der echte Aufruf im Zielzustand.
- **Ein Prüfskript ohne Voraussetzung darf nicht Grün melden.** Fehlt das Werkzeug, die
  Datei, die Variable, ist das Ergebnis „unbekannt", nicht „bestanden".
- **Debug ist nicht Release.** Optimierung und abgeschaltete Entwicklerhilfen verändern das
  Verhalten. Was nur im Auslieferungszustand auftritt, ist im Debug-Modus nicht zu finden.

Läuft die Änderung durch mehrere Umgebungen, gehört zu jeder eine **eigene Testfrage** —
in der Testumgebung „funktioniert die Fachlogik", in der Integration „trägt die Anbindung".
Dieselbe Frage zweimal zu stellen kostet Zeit und findet nichts.

## 9. Abweichungen und Risikoabnahme

Wer einen vorgesehenen Schritt auslässt, trägt ihn **vorher** hier ein — mit Namen, nicht
mit „aus Zeitgründen". Ein unprotokollierter Skip ist von einer übersehenen Lücke nicht zu
unterscheiden.

| Datum | Ausgelassen | Begründung | Restrisiko | Abgenommen von |
|---|---|---|---|---|
| | | | niedrig / mittel / hoch | |

Die letzte Spalte ist der Punkt. Ein Restrisiko ohne Namen dahinter ist keine Abnahme,
sondern eine Hoffnung.

## 10. Auditspur — was liegen bleibt

Was dieser Abschnitt an dauerhaften Belegen hinterlässt:

- [ ] Entscheidung von Tragweite → als Entscheidungsdokument in `docs/decisions/`
- [ ] Störung, Fehlschlag, Rückbau → Nachbetrachtung in `docs/postmortems/`
- [ ] Protokollierung angefasst? Dann: **was** wird protokolliert, **wie lange** aufbewahrt,
      **wer** darf es lesen. Ein Protokoll über Personen ist selbst eine Verarbeitung.
- [ ] Diese Sprint-Datei bleibt unverändert liegen. Nicht nachträglich glätten.

## 11. Versions-Relevanz

`keine | patch | minor | major` — mit einer Zeile Begründung.

Die Zahl setzt der Release-Abschnitt, nicht dieser. Der Umfang darf sich unterwegs ändern;
eine früh festgelegte Zielversion muss am Ende entweder verteidigt oder korrigiert werden.

## 12. Ergebnis

Beim Abschluss ausfüllen: was tatsächlich passiert ist, Abweichungen vom Plan, offene
Folgepunkte. Ehrlich — „Kriterium 3 offen, weil …" ist ein brauchbarer Abschluss, ein
geglättetes „alles grün" nicht.

Erst danach `status: abgeschlossen`.

## 13. Menschliche Entscheidungen

Was an den Menschen ging oder noch geht: Wahl zwischen mehreren tragfähigen Alternativen,
Geschmacksfrage ohne prüfbares Kriterium, widersprüchliche Anforderung, Risikoabnahme.

Je Eintrag: Optionen · Abwägung · Empfehlung · Entscheidung + Datum + Name.

Einigkeit unter Prüfinstanzen hebt das nicht auf. Was durch Nachsehen widerlegbar ist, darf
eine Prüfinstanz entscheiden; was einen besseren Gegenentwurf verlangt, nicht.

---

## Wozu die Abschnitte im Assessment taugen

Grobzuordnung zu den üblichen Prüffeldern eines Informationssicherheits-Assessments
(VDA ISA / TISAX, ISO/IEC 27001). **Die konkreten Control-Nummern gehören gegen den jeweils
geltenden Katalog abgeglichen** — diese Tabelle ordnet Themen zu, nicht Nummern.

| Abschnitt | Prüffeld |
|---|---|
| 3 Schutzbedarf und Datenklassen | Informationsklassifizierung · Umgang mit personenbezogenen Daten |
| 4 Write-Scope | Zugriffskontrolle auf Ebene der Artefakte · Trennung von Zuständigkeiten |
| 5 Zugänge und Geheimnisse | Identitäts- und Zugriffsverwaltung · Umgang mit Schlüsselmaterial |
| 6 Änderungsklasse und Freigabe | Änderungsmanagement · Freigabeverfahren |
| 7 Nachweise · 8 Verifikation | Prüfung vor Inbetriebnahme · Trennung von Entwicklung und Betrieb |
| 9 Abweichungen und Risikoabnahme | Risikobehandlung mit benannter Verantwortung |
| 10 Auditspur | Protokollierung · Ereignisbehandlung · Dokumentation von Entscheidungen |

Der Nutzen liegt nicht darin, ein Assessment zu bestehen. Er liegt darin, dass die Belege
**beim Arbeiten** entstehen statt in der Woche davor rekonstruiert zu werden.
