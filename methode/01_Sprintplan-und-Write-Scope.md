# 01 — Sprintplan mit Write-Scope

> **Kurz:** Arbeit, die größer ist als ein Commit, bekommt eine Datei. Diese Datei nennt das Ziel,
> die ausdrücklichen Nicht-Ziele und **welche Datei wer schreiben darf** — und sie ist zugleich der
> Stand. Damit überlebt das Vorhaben jeden Kontext-Reset.

## Das Problem

Ein KI-Assistent hat kein Gedächtnis über die Sitzung hinaus. Was nur im Chat-Verlauf steht, ist
nach `/clear`, nach einem Kontext-Kompakt oder am nächsten Morgen weg. Zurück bleibt der Code — und
der sagt nicht, was **nicht** dazugehören sollte.

Menschen haben dasselbe Problem, nur langsamer. Deshalb fällt es lange nicht auf.

Ohne schriftlich fixierte Arbeitsetappe passiert regelmäßig dasselbe:

- **Scope-Drift.** Aus „Login reparieren" wird nebenbei ein Umbau der Navigation. Niemand hat das
  entschieden, es ist einfach passiert.
- **Schreibkollisionen.** Zwei Sitzungen, zwei Menschen oder zwei Subagenten fassen dieselbe Datei
  an. Besonders teuer bei „heißen" Dateien — `CHANGELOG.md`, `VERSION`, `README.md`, die
  Assistenten-Anweisungsdatei: dort kollidiert praktisch jeder mit jedem.
- **Unsichtbare Auslassungen.** Ein übersprungener Schritt — kein Test, kein Review, keine
  Verifikation — ist im Nachhinein nicht von einer Lücke zu unterscheiden, die niemand bemerkt hat.
- **Versions-Vorgriff.** Die Zielversion wird zu Beginn festgelegt und stimmt am Ende nicht mehr.
  Danach wird entweder geschönt oder nachgezogen.

## Die Regel

### 1. Planen vor Ausführen

Nicht-triviale Arbeit bekommt **vor** dem ersten Commit einen Plan: `docs/plan/PLAN.md` — das
Vorhaben, die Sprint-Liste, die Reihenfolge — plus je Abschnitt eine `docs/plan/sprint-NN-<slug>.md`
nach [`vorlagen/sprint-NN.md`](../vorlagen/sprint-NN.md).

Trivial ist, was in einem Commit erledigt und in einer Zeile beschrieben ist: Tippfehler,
Link-Korrektur, Versions-Bump. Dafür kein Sprint. Alles andere schon.

> **Begriffswahl.** „Phase" ist in vielen Projekten schon für den Lebenszyklus vergeben (Alpha →
> Live, Pilot → Rollout). Der Arbeitsabschnitt heißt hier deshalb **Sprint**. Wer beides „Phase"
> nennt, produziert genau die Verwechslung, die diese Methode vermeiden soll.

### 2. Die Sprint-Datei ist der Zustand

`status: geplant | laufend | pruefung | abgeschlossen | blockiert` im Frontmatter, `## Ergebnis` am Ende.
Kein separater Zustandsspeicher, keine State-Datei, kein JSON, kein Board-Tool. Wer den Stand wissen
will, liest die Datei — Mensch wie KI, und beide sehen dasselbe.

Das ist die wichtigste Entscheidung dieser Methode. Ein zweiter Zustandsspeicher neben den Dateien
driftet **immer** gegen das Repo; die Frage ist nur, wie lange es dauert.

### 3. Write-Scope: jede Datei hat genau einen Schreiber

Der Sprint listet auf, was er anfassen darf. Wer außerhalb schreiben will, **hält an** und meldet
`BLOCKED (scope)` — statt es einfach zu tun.

- Heiße Dateien haben pro Sprint **einen** Schreiber und werden nie parallel bearbeitet.
- Zwei Sprints laufen nur gleichzeitig, wenn ihre Write-Scopes **disjunkt** sind. Sonst nacheinander.
- Bei parallelen Agenten auf überlappenden Dateien: getrennte Arbeitskopien (`git worktree`), nicht
  Hoffnung.

Der Write-Scope ist der Grund, warum diese Methode mit mehreren Agenten überhaupt funktioniert. Ohne
ihn ist Parallelität ein Merge-Konflikt mit Anlauf.

### 4. Abweichungen werden protokolliert, bevor sie passieren

Wer einen vorgesehenen Schritt überspringt, trägt ihn **vorher** in die Tabelle
`## Abweichungen und Risikoabnahme` ein: was ausgelassen wurde, warum, welches Restrisiko
bleibt — und **wer es abgenommen hat**.

Die letzte Spalte ist der eigentliche Mechanismus. Ein unprotokollierter Skip ist von einer
übersehenen Lücke nicht zu unterscheiden; ein protokollierter ohne Namen ist keine Abnahme,
sondern eine Hoffnung. Sparsam arbeiten: ja. Still: nein.

### 5. Die Version entscheidet der Release, nicht der Sprint

Jeder Sprint notiert nur seine **Versions-Relevanz** (`keine | patch | minor | major`, eine Zeile
Begründung). `VERSION` und der Tag werden erst im Release-Sprint gesetzt — höchste Relevanz gewinnt.

So darf sich der Umfang unterwegs ändern, ohne dass jemand eine falsche Zahl verteidigen muss.

### 6. Ein Gate, das kein Agent aufmacht

An den Menschen gehen:

- Entscheidungen zwischen **mehreren tragfähigen** Alternativen — zwei valide Schnittebenen, zwei
  valide Rollenmodelle. Nicht richtig/falsch, sondern Abwägung.
- Geschmacksfragen ohne prüfbares Kriterium: Benennung öffentlicher Schnittstellen, UX-Urteile ohne
  Style-Guide.
- Der Verdacht, dass die **Anforderung selbst** widersprüchlich ist — der „Bugfix", der sich als
  Konstruktionsfehler entpuppt.

Nicht als Blockade: ein Absatz mit Optionen, Abwägung und Empfehlung, dann weiter, sobald entschieden
ist.

**Einigkeit unter Prüfern hebt dieses Gate nicht auf.** Mehrere KI-Prüfinstanzen teilen
Trainingsstand und blinde Flecken; ihre Übereinstimmung ist korrelierte, nicht unabhängige Evidenz.
Die Trennlinie ist scharf: Was durch **Nachsehen** widerlegbar ist — grep, Testlauf, Log, Beleg —,
darf eine Prüfinstanz entscheiden. Was einen **besseren Gegenentwurf** verlangt, nicht.

### 7. Belege entstehen beim Arbeiten, nicht danach

Ein Akzeptanzkriterium ohne Beleg ist eine Behauptung. Zu jedem gehört deshalb, **womit** es
belegt ist und **wo** der Beleg liegt: Befehlsausgabe, Protokolleintrag, Bildschirmfoto.

Das kostet beim Arbeiten Minuten und spart sie in dem Moment, in dem jemand fragt: ein
Kunde, ein Prüfer, oder man selbst ein halbes Jahr später. Wer in geregelten Umgebungen
arbeitet — Informationssicherheits-Assessments, Datenschutz-Nachweise, Kundenaudits —, kennt
die Alternative: die Woche vor dem Termin, in der aus Commit-Verläufen rekonstruiert wird,
was damals geprüft wurde. Diese Rekonstruktion ist teuer und im Zweifel nicht belastbar.

Dieselbe Logik trägt die übrigen Nachweisfelder der Vorlage: welche **Datenklasse** ein
Abschnitt anfasst, welche **Zugänge** er braucht und wann sie zurückgehen, welche
**Änderungsklasse** er hat und wer freigegeben hat. Das sind keine Formulare — das sind die
vier Fragen, die im Ernstfall ohnehin gestellt werden.

## Was stattdessen oft versucht wird

| Statt dessen … | … und das passiert |
|---|---|
| **Der Chat-Verlauf als Plan.** „Steht doch oben im Kontext." | Überlebt kein `/clear`, keinen Sitzungswechsel, keinen zweiten Menschen. |
| **Ein zentraler Zustandsspeicher** neben den Dateien — JSON-State, Datenbank, Ticket-Board. | Zweite Quelle der Wahrheit. Driftet gegen das Repo, und beim Widerspruch glaubt jeder der falschen. |
| **Write-Scope erst beim Konflikt klären.** | Der Konflikt ist der Merge — also nach der Arbeit, wenn Rückbau am teuersten ist. |
| **Zielversion beim Start festlegen.** | Der Umfang ändert sich, die Zahl nicht. Am Ende stimmt das Changelog nicht mehr. |
| **Sprint-Dateien für jede Kleinigkeit.** | Zeremonie ohne Ertrag. Die Vorlage wird als Bürokratie erlebt und dann für die großen Fälle *auch* nicht mehr benutzt. |
| **Noch ein Prüf-Durchlauf statt einer Entscheidung.** | Erzeugt selbstbewussten Konsens-Irrtum. Mehr Runden desselben Urteils sind nicht mehr Evidenz. |

## Prüfen, ob es eingehalten wurde

- [ ] `docs/plan/sprint-NN-<slug>.md` existiert, und `status` entspricht der Realität.
- [ ] `git diff --name-only main...HEAD` gegen die Write-Scope-Tabelle gehalten: keine Datei im Diff,
      die dort nicht steht. Handarbeit, zehn Sekunden — ein Skript dafür ist mehr Wartungslast als
      Ertrag.
- [ ] Jedes Akzeptanzkriterium ist abgehakt **oder** im `## Ergebnis` als bewusst offen benannt.
- [ ] Jeder ausgelassene Schritt hat eine Zeile in der Abweichungstabelle.
- [ ] `## Ergebnis` ist gefüllt, **bevor** `status: abgeschlossen` gesetzt wird.
- [ ] `VERSION` wurde außerhalb des Release-Sprints nicht angefasst.

## Verwandt

- [02 — Schichten: Anweisung, Hook, Skill](02_Schichten-Anweisung-Hook-Skill.md) — wo eine Regel
  hingehört, damit sie überhaupt wirkt.
- [03 — Kontext-Budget](03_Kontext-Budget.md) — die Sprint-Datei entlastet die Anweisungsdatei:
  Vorhaben-Wissen wird gelesen, wenn es gebraucht wird, nicht bei jedem Turn.
- [04 — Deterministische Guards](04_Deterministische-Guards.md) — der Write-Scope ist advisory. Wo
  eine Grenze nie fallen darf, gehört sie zusätzlich in einen Hook.
