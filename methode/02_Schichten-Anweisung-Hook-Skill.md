# 02 — Schichten: Anweisung, Hook, Skill, Command

> **Kurz:** Vier Orte, an denen eine Regel für einen KI-Assistenten stehen kann. Die Wahl des Ortes
> entscheidet darüber, **ob die Regel überhaupt wirkt** — nicht ihre Formulierung.

## Das Problem

Die häufigste Ursache dafür, dass ein Assistent eine Regel „ignoriert", ist nicht Ungehorsam. Es ist
der falsche Ablageort:

- Eine Regel in der Anweisungsdatei ist **advisory**. Sie konkurriert mit allem anderen im Kontext.
  Bei einer 600-Zeilen-Datei konkurriert sie mit 599 anderen Zeilen.
- Eine Regel, die nur in einer Doku steht, die niemand lädt, existiert nicht.
- Eine Regel, die nie verhandelbar ist — Datenschutz, Secrets, Produktivsystem —, gehört nicht in
  einen Text, den ein Sprachmodell abwägen darf.

## Die Zuordnung

| Die Regel gilt … | … gehört … | Warum dort |
|---|---|---|
| **bei fast jeder Änderung** | in die **Anweisungsdatei** (`CLAUDE.md` o. ä.) | Immer präsent — und genau deshalb kurz zu halten |
| **nie verhandelbar** (Datenschutz, Secrets, Prod-Schutz) | in einen **Hook** | Deterministisch. Code fragt nicht nach, ob die Regel diesmal passt |
| **nur bei bestimmter Arbeit** (Design-System, Screen-Specs, Fachkataloge) | in einen **Skill** | Lädt on demand, belastet den Kontext sonst nicht |
| **auf Zuruf, mit klarem Auftrag** („prüf mir das") | in einen **Slash-Command** | Der Mensch löst aus, der Auftrag hat eine Checkliste und ein Ende |

## Die drei Fehler

**1. Alles in die Anweisungsdatei.** Sie wächst auf 400, 600, 900 Zeilen. Jede einzelne Regel darin
verliert an Wirkung, weil sie mit allen anderen um Aufmerksamkeit konkurriert — und die Datei wird
bei *jedem* Turn vollständig geladen, auch beim Tippfehler-Fix. Siehe [03 — Kontext-Budget](03_Kontext-Budget.md).

**2. Eine Rechtsfolge advisory formulieren.** „Bitte niemals die Kundendatei committen" ist eine
Bitte. Sie wird meistens befolgt. „Meistens" ist bei personenbezogenen Daten keine Kategorie. Siehe
[04 — Deterministische Guards](04_Deterministische-Guards.md).

**3. Selten gebrauchtes Wissen dauerhaft laden.** Der 200-Zeilen-Katalog der Fachbegriffe ist bei
Screen-Arbeit Gold und bei jeder anderen Arbeit Ballast. Das ist ein Skill.

## Der Anker-Trick

Wandert eine Sektion aus der Anweisungsdatei in einen Skill, bleibt an ihrer Stelle ein **Anker**:
drei Zeilen — Zweck, die immer geltenden Kernwerte, Verweis auf den Skill.

Ersatzloses Streichen führt dazu, dass der Assistent gar nicht weiß, dass es das Wissen gibt. Ein
Skill wird über seine `description` ausgewählt; steht nirgends, dass er existiert und wofür, ist das
Wissen faktisch verloren — es liegt nur noch im Repo herum.

**Konsequenz für die `description`:** Sie ist kein Titel, sondern der Auswahlmechanismus. Sie gehört
so geschrieben, dass sie die Auslöser enthält, bei denen der Skill greifen soll — die Wörter, die ein
Mensch tatsächlich sagt.

## Abgrenzung Skill ↔ Slash-Command

Beide laden Wissen bei Bedarf. Der Unterschied liegt im Auslöser:

- **Skill:** Das Modell entscheidet anhand der Arbeit, dass es das Wissen braucht. Passives Wissen.
- **Slash-Command:** Der Mensch entscheidet und ruft auf. Aktiver Auftrag mit Anfang und Ende.

Faustregel: Beschreibt es **wie etwas ist** (Design-System, Datenmodell, Fachsprache) → Skill.
Beschreibt es **was zu tun ist** (prüfe, baue, veröffentliche) → Command.

## Prüfen

- [ ] Ist die Anweisungsdatei unter dem gesetzten Richtwert (Vorschlag: 200 Zeilen)?
- [ ] Steht in ihr eine Regel, deren Verletzung eine Rechts- oder Datenschutzfolge hätte? → Hook.
- [ ] Steht in ihr eine Sektion, die bei den meisten Änderungen irrelevant ist? → Skill, mit Anker.
- [ ] Hat jeder Skill eine `description`, die die tatsächlichen Auslöser-Wörter enthält?
