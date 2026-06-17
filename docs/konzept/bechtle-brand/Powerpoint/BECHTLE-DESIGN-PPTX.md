# Bechtle Design-System – PowerPoint

> Extrahiert aus `VORLAGE_Bechtle_Praesentation.pptx` (0 Folien, vollständiger Slide-Master).
> Alle Placeholder-Positionen per python-pptx ausgelesen (Juni 2026).

---

## Vorlage

| Datei | Verwendung |
|---|---|
| `VORLAGE_Bechtle_Praesentation.pptx` | Basis-Vorlage (0 Folien, 41 Layouts, Theme, Logos) |
| `Bechtle_Designvorlage_Grün_Teil1/2/3.pptx` | Referenz-Design-Kit – nur zur Ansicht |

```python
from pptx import Presentation
prs = Presentation("bechtle-brand/Powerpoint/VORLAGE_Bechtle_Praesentation.pptx")
# Folien hinzufügen:
slide = prs.slides.add_slide(prs.slide_masters[0].slide_layouts[14])
```

---

## Foliengröße

| Eigenschaft | Wert |
|---|---|
| Breite | 13,33" (33,87 cm) |
| Höhe | 7,50" (19,05 cm) |
| Format | Widescreen 16:9 |

---

## Farben (Theme)

| Rolle | Hex | Verwendung |
|---|---|---|
| accent1 – Dunkelgrün | `#075033` | Primärfarbe, Divider-/Titelfolie-Hintergrund |
| **Überschriften** | `#053B25` | Titel-Text auf hellen Folien |
| accent2 – Grün | `#23A96A` | Sekundär-Akzent, Hervorhebungen |
| accent3 – Limette | `#AADE0C` | Highlight / Call-out-Elemente |
| accent4 – Cyan | `#27C9D1` | Diagramm-Akzent |
| accent5 – Blau | `#346CEF` | Diagramm-Akzent / Links |
| Grau | `#595959` | Untertitel, Kopfzeile, Metatext |
| Hellgrau | `#C3C3C3` | Linien, dezente Elemente |
| Weiß | `#FFFFFF` | Text auf dunklem Hintergrund |
| Schwarz | `#000000` | Fließtext |

---

## Schrift

| Element | Schrift | Fallback |
|---|---|---|
| Hausschrift | **Bechtle Pro** | Arial |
| Titel (groß) | Bechtle Pro Bold | Arial Bold |
| Body / Bullets | Bechtle Pro | Arial |

---

## Defekte Layouts – NICHT verwenden

Indizes **17, 31–38, 40** haben defekte `rId`-Referenzen in der Quelldatei.
Direktzugriff per Index ist sicher; Iteration über alle Layouts wirft `KeyError`.

---

## Kritische Analyse der Layouts

> Die folgende Bewertung basiert auf dem konkreten Einsatz für technische
> Kundenpräsentationen (Azure Landing Zone, IT-Infrastruktur). Andere
> Präsentationstypen können zu anderen Gewichtungen führen.

### ✅ Empfohlen – aktiv einsetzen

| Idx | Name | Bewertung | Typischer Einsatz |
|---|---|---|---|
| 0 | Title Slide with Picture | **Pflicht** | Titelfolie jeder Präsentation |
| 4 | Agenda | **Pflicht** | Agenda-Folie |
| 6 | Divider Number / Icon | **Pflicht** | Kapitel-Trenner |
| 9 | Highlight | **Hoch** | Einzelner KPI / Kostenzahl / Empfehlung |
| 10 | Highlight Dark | **Hoch** | Key-Statement, CTA, Kapitel-Quintessenz |
| 14 | Titel und Inhalt | **Standard** | Bullet-Listen – aber sparsam einsetzen! |
| 16 | 2x Text | **Hoch** | Vergleiche, Vorteile/Nachteile, A-vs-B |
| 19 | Text + Medium Picture Right | **Hoch** | Text-links + Architekturdiagramm-rechts |
| 20 | Text + Big Picture Right | **Hoch** | Text-links + dominantes Diagramm-rechts |
| 27 | 3x Text + 3x Picture | **Mittel** | 3 gleichwertige Säulen mit Icons |
| 39 | Leer | **Situativ** | Vollbild-Diagramme, freies Layout |

### ⚡ Situativ – nur bei passendem Inhalt

| Idx | Name | Bedingung |
|---|---|---|
| 5 | Agenda 4 Topics | Wenn Agenda genau 4 Kapitel hat |
| 7 | Divider Picture | Wenn passendes Foto verfügbar |
| 11 | Key message / Quote | Starkes Einzelzitat oder Motto |
| 12 | Quote Light | Kundenzitat, externe Quelle |
| 15 | Text Right | Linke Erklärung + rechte Detail-Box |
| 25 | 2x Text + 2x Picture | Zwei Dienste/Features mit Screenshots |
| 26 | 3x Text + 2x Picture | 3 Punkte mit 2 Bildern (asymmetrisch) |

### ❌ Nicht empfohlen – für technische IT-Präsentationen ungeeignet

| Idx | Name | Begründung |
|---|---|---|
| 8 | Picture Highlight | Benötigt hochwertiges Vollbild-Foto – keine IT-Architekturdiagramme geeignet |
| 18 | Text + Small Picture Right | Bild-Slot zu schmal (4,31") für Diagramme; Icons fehlen |
| 21 | Text + Small Picture Left | Gleiche Einschränkung wie 18, gespiegelt |
| 22 | Text + Medium Picture Left | Sinnvoll nur wenn Bild explizit links erwartet wird |
| 23 | Text + 5x Picture | Fünf sinnvolle Bilder selten verfügbar |
| 24 | Text + 8x Picture | Zu viele Bild-Slots; wirkt leer wenn nicht alle gefüllt |
| 28 | 4x Text + 3x Picture | Zu komplex; Lesbarkeit leidet stark |
| 29 | 4x Text + 4x Picture | Nur für Referenzseiten mit vielen kleinen Elementen |
| 30 | Text + 4x Picture | Spezialfall; kaum sinnvoll ohne passendes Bildmaterial |

---

## Vollständige Placeholder-Referenz

> Format: `PH<idx> <Typ>: left"/top"/width"/height"`
> Nur Layouts mit tatsächlichem Inhalt (DATE/FOOTER/SLIDE_NUMBER weggelassen).

### Layout 0 – Title Slide with Picture

| PH | Typ | Position (l/t/w/h) | Verwendung |
|---|---|---|---|
| 0 | CENTER_TITLE | 0,37"/1,58"/7,09"/2,36" | Haupttitel (groß, fett) |
| 1 | SUBTITLE | 0,37"/4,73"/3,94"/0,79" | Untertitel |
| 14 | PICTURE | 4,18"/0,00"/9,15"/6,70" | Hintergrundfoto rechts |
| 15 | BODY | 0,37"/6,31"/3,15"/0,39" | Kleintext: Kunde · Datum |

### Layout 4 – Agenda

| PH | Typ | Position | Verwendung |
|---|---|---|---|
| 0 | TITLE | 0,37"/0,40"/8,66"/0,79" | „Agenda" |
| 13 | BODY | 0,37"/1,59"/8,66"/5,51" | Agenda-Liste (Bullets) |

### Layout 5 – Agenda 4 Topics *(4-Spalten-Agenda)*

| PH | Typ | Position | Verwendung |
|---|---|---|---|
| 0 | TITLE | 0,37"/0,40"/8,66"/0,79" | „Agenda" |
| 20 | BODY | 0,37"/1,58"/2,76"/5,51" | Spalte 1 |
| 21 | BODY | 3,52"/1,58"/2,76"/5,51" | Spalte 2 |
| 22 | BODY | 6,67"/1,58"/2,76"/5,51" | Spalte 3 |
| 23 | BODY | 9,82"/1,58"/2,76"/5,51" | Spalte 4 |

> **Kritik:** Nur sinnvoll wenn exakt 4 Kapitel existieren und jeder Bereich
> gleich viel Raum verdient. Flexibler als Layout 4 für strukturierte Agenda.

### Layout 6 – Divider Number / Icon

| PH | Typ | Position | Verwendung |
|---|---|---|---|
| 0 | TITLE | 0,37"/1,58"/7,87"/1,57" | Kapitel-Titel |
| 1 | SUBTITLE | 0,37"/3,95"/3,94"/1,57" | Kurz-Beschreibung |
| 13 | BODY | 8,24"/1,58"/4,72"/3,94" | Kennzahlen / Facts rechts |

### Layout 7 – Divider Picture

| PH | Typ | Position | Verwendung |
|---|---|---|---|
| 0 | TITLE | 0,37"/1,98"/7,87"/1,57" | Kapitel-Titel |
| 1 | SUBTITLE | 0,37"/4,35"/3,94"/1,57" | Kurz-Beschreibung |
| 13 | BODY | 0,37"/0,40"/1,58"/0,79" | Kapitel-Nummer oben links |
| 14 | PICTURE | 6,95"/0,00"/6,38"/6,70" | Foto rechts (halbe Folie) |

> **Kritik:** Nur einsetzen wenn ein thematisch passendes Foto verfügbar ist.
> Architekturdiagramme wirken hier fehlplatziert – lieber Layout 6 nehmen.

### Layout 9 – Highlight *(heller Hintergrund)*

| PH | Typ | Position | Verwendung |
|---|---|---|---|
| 1 | SUBTITLE | 0,37"/0,80"/5,51"/0,79" | Breadcrumb / Kontext |
| 0 | TITLE | 0,37"/1,58"/5,51"/3,15" | Große Aussage / KPI |

> **Empfehlung:** Ideal für einzelne Kostenzahlen oder Empfehlungen:
> `PH0 = "~€1.050 / Monat"`, `PH1 = "Bechtle-Empfehlung"`.
> Rechte Hälfte der Folie bleibt frei – bewusster Weißraum für Wirkung.

### Layout 10 – Highlight Dark *(dunkler Hintergrund)*

| PH | Typ | Position | Verwendung |
|---|---|---|---|
| 1 | SUBTITLE | 0,37"/0,40"/6,30"/0,39" | Breadcrumb (hell auf dunkel) |
| 0 | TITLE | 0,37"/0,80"/6,30"/1,57" | Statement / Kernaussage |
| 13 | BODY | 0,37"/3,16"/3,94"/3,15" | Ergänzungstext links unten |

> **Empfehlung:** Stärkste visuelle Wirkung aller Layouts. Einsetzen für:
> - Management Summary Kernaussage
> - Abschluss-Statement jedes Kapitels
> - „Warum Bechtle"-Botschaft
> Nicht mehr als 2–3× pro Präsentation verwenden – sonst Gewöhnungseffekt.

### Layout 11 – Key message / Quote

| PH | Typ | Position | Verwendung |
|---|---|---|---|
| 1 | SUBTITLE | 5,90"/0,80"/1,53"/0,28" | Kleines Label (Quelle/Autor) |
| 0 | TITLE | 2,73"/1,98"/7,87"/3,54" | Großes Zitat / Kernbotschaft |

> **Kritik:** Sehr minimalistisch – nur für eine einzige, starke Aussage.
> Der Titel ist zentriert und nimmt die gesamte Folie ein.
> Gut geeignet als Einstieg in ein Kapitel oder als Abschluss-Statement.

### Layout 12 – Quote Light

| PH | Typ | Position | Verwendung |
|---|---|---|---|
| 0 | TITLE | 0,37"/0,80"/7,09"/3,94" | Großes Zitat (linksbündig) |
| 13 | BODY | 0,37"/6,31"/2,36"/0,79" | Autor / Quellenangabe |

### Layout 13 – Nur Titel *(freier Inhaltsbereich)*

| PH | Typ | Position | Verwendung |
|---|---|---|---|
| 1 | SUBTITLE | 0,37"/0,40"/8,66"/0,39" | Breadcrumb |
| 0 | TITLE | 0,37"/0,80"/8,66"/0,79" | Folientitel |

> **Kritik:** Kein Body-Placeholder – alles unterhalb des Titels muss manuell
> hinzugefügt werden. Sinnvoll wenn das Layout komplett selbst gestaltet wird.
> Für Diagramm-Folien ist **Layout 19 oder 20 besser**, da deren Bild-Placeholder
> automatisch in den Master-Stil eingebettet sind.

### Layout 14 – Titel und Inhalt *(Standard-Inhaltsfolie)*

| PH | Typ | Position | Verwendung |
|---|---|---|---|
| 1 | SUBTITLE | 0,37"/0,40"/8,66"/0,39" | Breadcrumb / Kapitel-Kontext |
| 0 | TITLE | 0,37"/0,80"/8,66"/0,79" | Folientitel |
| 13 | BODY | 0,37"/2,37"/12,60"/4,73" | Inhalt (Bullets, Text) |

> **Kritik:** Wird in vielen Präsentationen für ALLES verwendet – das ist ein Fehler.
> Layout 14 ist optimal für reine Bullet-Listen. Für Vergleiche → Layout 16,
> für Statements → Layout 10, für Diagramme → Layout 19/20.
> Faustegel: Nicht mehr als 40 % aller Folien sollten Layout 14 verwenden.

### Layout 15 – Text Right

| PH | Typ | Position | Verwendung |
|---|---|---|---|
| 1 | SUBTITLE | 0,37"/0,40"/4,72"/0,39" | Breadcrumb |
| 0 | TITLE | 0,37"/0,80"/4,72"/2,36" | Großer Titel links oben |
| 13 | BODY | 0,37"/3,55"/4,72"/3,54" | Ergänzungstext links unten |
| 15 | BODY | 6,67"/0,80"/3,94"/6,30" | Hauptinhalt rechts (groß) |

> **Empfehlung:** Gut wenn der Titel bewusst groß wirken soll (Marketing-Stil)
> und der Inhalt rechts steht. Für technische Listen weniger geeignet.

### Layout 16 – 2x Text *(zweispaltig)* ⭐ Hochwertig

| PH | Typ | Position | Verwendung |
|---|---|---|---|
| 1 | SUBTITLE | 0,37"/0,40"/8,66"/0,39" | Breadcrumb |
| 0 | TITLE | 0,37"/0,80"/8,66"/0,79" | Folientitel |
| 13 | BODY | 0,37"/2,37"/5,12"/4,73" | Linke Spalte |
| 14 | BODY | 6,67"/2,37"/5,12"/4,73" | Rechte Spalte |

> **Empfehlung:** Eines der nützlichsten Layouts für technische Präsentationen.
> Einsatz für:
> - Kostenvergleich Option A vs. Option B
> - Vorteile (links) vs. Nachteile (rechts)
> - Microsoft-Default (links) vs. Bechtle-Empfehlung (rechts)
> - On-Premises (links) vs. Azure (rechts)
> Beide Spalten sind symmetrisch (5,12" breit) – ideal für echte Gegenüberstellungen.

### Layout 19 – Text + Medium Picture Right ⭐ Hochwertig

| PH | Typ | Position | Verwendung |
|---|---|---|---|
| 1 | SUBTITLE | 0,37"/0,40"/4,72"/0,39" | Breadcrumb |
| 0 | TITLE | 0,37"/0,80"/4,72"/0,79" | Folientitel |
| 13 | BODY | 0,37"/2,37"/4,72"/4,73" | Erklärtext / Bullets links |
| 14 | PICTURE | 6,67"/0,00"/6,67"/7,50" | Diagramm / Screenshot rechts (50 %) |

> **Empfehlung:** Perfekt für Architekturdiagramme mit erklärendem Text.
> Das Bild läuft randlos von oben nach unten (0" bis 7,5") – sehr professionell.
> Einsatz: Hub-and-Spoke + Erklärung, MG-Hierarchie + Kontext.
> **Besser als manuelles Bild auf Layout 39** weil der Bild-Placeholder
> automatisch den richtigen Clip-Bereich und Shadow-Stil erbt.

### Layout 20 – Text + Big Picture Right ⭐ Hochwertig

| PH | Typ | Position | Verwendung |
|---|---|---|---|
| 1 | SUBTITLE | 0,37"/0,40"/3,15"/0,39" | Breadcrumb |
| 0 | TITLE | 0,37"/0,80"/3,15"/0,79" | Folientitel (kompakt) |
| 13 | BODY | 0,37"/2,37"/3,15"/4,73" | Wenige Key-Points links |
| 14 | PICTURE | 4,30"/0,00"/9,03"/7,50" | Dominantes Diagramm rechts (68 %) |

> **Empfehlung:** Wenn das Diagramm das Hauptelement sein soll.
> Links nur 3 Bullet-Points oder eine kurze Aussage – Bild dominiert.
> Ideal für: Vollständige ALZ-Architektur mit 3 Key-Facts links.

### Layout 21 – Text + Small Picture Left

| PH | Typ | Position | Verwendung |
|---|---|---|---|
| 1 | SUBTITLE | 5,09"/0,40"/5,51"/0,39" | Breadcrumb |
| 0 | TITLE | 5,09"/0,80"/5,51"/0,79" | Folientitel |
| 13 | BODY | 5,09"/2,37"/5,51"/4,73" | Haupttext rechts |
| 14 | PICTURE | 0,00"/0,00"/4,30"/7,50" | Schmales Bild/Icon links |

### Layout 22 – Text + Medium Picture Left

| PH | Typ | Position | Verwendung |
|---|---|---|---|
| 1 | SUBTITLE | 7,45"/0,40"/3,94"/0,39" | Breadcrumb |
| 0 | TITLE | 7,45"/0,80"/4,72"/0,79" | Folientitel |
| 13 | BODY | 7,45"/2,37"/4,72"/4,73" | Haupttext rechts |
| 14 | PICTURE | 0,00"/0,00"/6,67"/7,50" | Bild links (50 %) |

### Layout 25 – 2x Text + 2x Picture

| PH | Typ | Position | Verwendung |
|---|---|---|---|
| 1 | SUBTITLE | 0,37"/0,40"/8,66"/0,39" | Breadcrumb |
| 0 | TITLE | 0,37"/0,80"/8,66"/0,79" | Folientitel |
| 18 | PICTURE | 0,37"/2,37"/5,91"/2,76" | Bild links oben |
| 19 | PICTURE | 6,67"/2,37"/5,91"/2,76" | Bild rechts oben |
| 13 | BODY | 0,37"/5,52"/5,91"/1,58" | Text links unten |
| 14 | BODY | 6,67"/5,52"/5,91"/1,58" | Text rechts unten |

> **Kritik:** Schema Bild oben / Text unten ist visuell stark, aber der Text-Bereich
> ist mit 1,58" sehr niedrig – nur Kurzaussagen passen. Gut für Feature-Paare.

### Layout 26 – 3x Text + 2x Picture

| PH | Typ | Position | Verwendung |
|---|---|---|---|
| 1 | SUBTITLE | 0,37"/0,40"/3,94"/0,39" | Breadcrumb |
| 0 | TITLE | 0,37"/0,80"/3,94"/2,36" | Großer Titel links |
| 13 | BODY | 0,37"/3,16"/3,94"/3,94" | Haupttext links |
| 18 | PICTURE | 4,70"/0,80"/3,94"/4,33" | Bild Mitte |
| 14 | BODY | 4,70"/5,52"/3,94"/1,58" | Kurztext unter Mitte-Bild |
| 19 | PICTURE | 9,03"/0,80"/3,94"/4,33" | Bild rechts |
| 20 | BODY | 9,03"/5,52"/3,94"/1,58" | Kurztext unter Rechts-Bild |

### Layout 27 – 3x Text + 3x Picture ⭐ Hochwertig für 3-Säulen

| PH | Typ | Position | Verwendung |
|---|---|---|---|
| 1 | SUBTITLE | 0,37"/0,40"/8,66"/0,39" | Breadcrumb |
| 0 | TITLE | 0,37"/0,80"/8,66"/0,79" | Folientitel |
| 18 | PICTURE | 0,37"/2,37"/3,94"/2,76" | Bild Spalte 1 |
| 19 | PICTURE | 4,70"/2,37"/3,94"/2,76" | Bild Spalte 2 |
| 20 | PICTURE | 9,03"/2,37"/3,94"/2,76" | Bild Spalte 3 |
| 13 | BODY | 0,37"/5,52"/3,94"/1,58" | Text Spalte 1 |
| 14 | BODY | 4,70"/5,52"/3,94"/1,58" | Text Spalte 2 |
| 21 | BODY | 9,03"/5,52"/3,94"/1,58" | Text Spalte 3 |

> **Empfehlung:** Ideal für 3-Säulen-Darstellungen (Icon + Kurztext):
> Governance · Netzwerk · Sicherheit  oder  Plan · Deploy · Operate.
> Die Bild-Slots (3,94"×2,76") sind groß genug für Icons oder Screenshots.

### Layout 39 – Leer

| PH | Typ | Verwendung |
|---|---|---|
| – | – | Vollständig freies Layout |

> **Kritik:** Nur nutzen wenn kein anderes Layout passt. Alle Elemente müssen
> manuell positioniert werden – erhöhter Pflegeaufwand. Besser: Layout 13
> (Nur Titel) oder 19/20 für Bild+Text-Kombinationen.

---

## Einsatzmatrix: Inhalt → Layout

| Inhalt-Typ | Empfohlenes Layout | Alternativen |
|---|---|---|
| Titelfolie | 0 | – |
| Agenda (Liste) | 4 | 5 (4 Themen) |
| Kapitel-Trenner | 6 | 7 (mit Foto) |
| Reine Bullet-Liste | 14 | – |
| Vergleich A vs. B | **16** | 14 (notfalls) |
| Einzelner KPI / Zahl | **9** | 10 |
| Key-Statement / CTA | **10** | 11 |
| Diagramm + wenig Text | **20** | 19 |
| Diagramm + mehr Text | **19** | 13 + manuell |
| 3 Säulen mit Icons | **27** | 26 |
| Vollbild-Diagramm | 39 | 13 |
| Zitat / externes Statement | 11 | 12 |

---

## Code-Beispiele

### Layout 9 – Highlight (KPI-Folie)

```python
slide = prs.slides.add_slide(master.slide_layouts[9])
for ph in slide.placeholders:
    if ph.placeholder_format.idx == 1:
        ph.text = "Bechtle-Empfehlung"   # Breadcrumb
    elif ph.placeholder_format.idx == 0:
        ph.text = "~€1.050 / Monat"      # Große Zahl
```

### Layout 10 – Highlight Dark (Statement-Folie)

```python
slide = prs.slides.add_slide(master.slide_layouts[10])
for ph in slide.placeholders:
    if ph.placeholder_format.idx == 1:
        ph.text = "Management Summary"
    elif ph.placeholder_format.idx == 0:
        ph.text = "Governance. Netzwerk. Sicherheit.\nAls Code – reproduzierbar."
    elif ph.placeholder_format.idx == 13:
        ph.text = "ALZ Bicep Accelerator · Microsoft-Standard · Bechtle-Umsetzung"
```

### Layout 16 – 2x Text (Vergleichs-Folie)

```python
slide = prs.slides.add_slide(master.slide_layouts[16])
for ph in slide.placeholders:
    if ph.placeholder_format.idx == 1:
        ph.text = "Kosten und Kostensteuerung"
    elif ph.placeholder_format.idx == 0:
        ph.text = "Microsoft-Default vs. Bechtle-Empfehlung"
    elif ph.placeholder_format.idx == 13:          # Linke Spalte
        tf = ph.text_frame
        tf.text = "Microsoft-Default (~€5.800)"
        for line in ["Firewall Premium 2×", "DDoS Plan", "2 Regionen"]:
            p = tf.add_paragraph(); p.text = line; p.level = 1
    elif ph.placeholder_format.idx == 14:          # Rechte Spalte
        tf = ph.text_frame
        tf.text = "Bechtle-Empfehlung (~€1.050)"
        for line in ["Firewall Standard 1×", "kein DDoS", "1 Region"]:
            p = tf.add_paragraph(); p.text = line; p.level = 1
```

### Layout 19 – Text + Medium Picture Right (Diagramm-Folie)

```python
from pptx.util import Inches
slide = prs.slides.add_slide(master.slide_layouts[19])
for ph in slide.placeholders:
    if ph.placeholder_format.idx == 1:
        ph.text = "Zielarchitektur"
    elif ph.placeholder_format.idx == 0:
        ph.text = "Hub-and-Spoke-Topologie"
    elif ph.placeholder_format.idx == 13:
        tf = ph.text_frame
        tf.text = "Connectivity Subscription"
        for pt in ["Azure Firewall Standard", "Azure Bastion", "VPN Gateway", "DNS Private Resolver"]:
            p = tf.add_paragraph(); p.text = pt; p.level = 1
    elif ph.placeholder_format.idx == 14:          # PICTURE-Placeholder
        ph.insert_picture("images/alz-hub-spoke.png")
```

### Layout 20 – Text + Big Picture Right (dominantes Diagramm)

```python
slide = prs.slides.add_slide(master.slide_layouts[20])
for ph in slide.placeholders:
    if ph.placeholder_format.idx == 0:
        ph.text = "ALZ Zielarchitektur"
    elif ph.placeholder_format.idx == 13:
        tf = ph.text_frame
        tf.text = "Kernpunkte"
        for pt in ["12 Management Groups", "Hub-and-Spoke", "~€1.050/Mon."]:
            p = tf.add_paragraph(); p.text = pt; p.level = 0
    elif ph.placeholder_format.idx == 14:          # PICTURE-Placeholder (68 % der Folie)
        ph.insert_picture("images/alz-hub-spoke.png")
```

---

## Häufige Fehler

| Fehler | Ursache | Lösung |
|---|---|---|
| `KeyError: 'rId18'` | Layouts 17/31–38/40 iteriert | Nur per direktem Index zugreifen |
| Bild nicht skaliert | `add_picture` ohne Größe | `width=Inches(x)` angeben oder PH14 nutzen |
| Text zu groß für Box | Zu viele Bullets in Layout 16 | Max. 5 Zeilen pro Spalte; Schriftgröße ≤ 12pt |
| Folie wirkt monoton | Nur Layout 14 verwendet | Abwechslung: 10 für Statement, 16 für Vergleich, 20 für Diagramm |
| Bild überlappt Text | Layout 39 + manuelles Bild | Layout 19 oder 20 nutzen – Bild-PH begrenzt automatisch |
