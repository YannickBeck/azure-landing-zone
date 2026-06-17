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

---

## Design-Rhythmus – Logische Kapitelstruktur

> Damit Zuhörer unbewusst erkennen, wo sie in der Präsentation sind, folgt
> **jedes technische Kapitel demselben Folienmuster**. Die Reihenfolge der
> Layout-Typen ist das visuelle Signal – nicht nur der Text.

### Kapitel-Muster (5–7 Folien pro Kapitel)

```
 1. L6  – Divider       "Wo sind wir?"         → Kapitel-Nummer + Kernfrage
 2. L10 – Dark          "Was ist der Kern?"     → 1 Satz, starke Aussage   [max 1× pro 3 Kapitel]
 3. L20 – Big Picture   "Das große Bild"        → Architektur / Übersicht
 4. L27 – 3 Säulen      "Die drei Dimensionen"  → Gleichwertige Konzepte / Dienste
 5. L16 – Vergleich     "Vor und nach"          → Status quo vs. Ziel, A vs. B
 6. L14 – Details       "Die Fakten"            → Tiefe Bullet-Liste / Tabelle  [max 2× pro Kapitel]
 7. L9  – KPI           "Die Zahl"              → Kostengröße / Kennzahl  [optional]
```

**Nicht jeder Schritt ist Pflicht** – ein kurzes Kapitel kann L6 + L16 + L14 sein.
Die *Reihenfolge* ist entscheidend: Vom großen Bild (L20) ins Detail (L14), nie umgekehrt.

### Gesamt-Struktur einer 30–40-Folien-Präsentation

| Block | Layouts | Folien | Funktion |
|---|---|---|---|
| Eröffnung | L0, L5, L10 | 3 | Marke, Agenda, Kernbotschaft |
| Kapitel (je 5–7) | L6 + Mix | 5–7 × n | Fachinhalt |
| Abschluss | L10, L9, L6 | 3–4 | CTA, Kosten, Nächste Schritte |

### Anti-Patterns

| ❌ Falsch | ✅ Richtig |
|---|---|
| 3+ L14 hintereinander | Nach max. 2× L14 kommt L16, L20 oder L27 |
| L10 mehr als 3× gesamt | L10 höchstens 2–3× – sonst verliert es Wirkung |
| L9 ohne Kontext | Vor L9-KPI immer eine erklärende Folie (L16 oder L14) |
| L27 mit reinem Text, ohne Farbe | Bild-PH18/19/20 mit `colored_box()` füllen |
| Breadcrumb leer | PH1 immer mit `§X · Kapitelname` befüllen |
| Layout-Typ wechselt ohne Logik | Jedes Layout-Wechsel hat einen inhaltlichen Grund |

---

## Farbkodierung nach Architekturebene

> Wenn `colored_box()` in L27-Säulen oder Akzentflächen verwendet wird,
> signalisiert die Farbe konsistent die thematische Ebene. Zuhörer lernen
> nach 2–3 Folien das System intuitiv.

| Domäne | Farbe | Hex | Eingesetzt in |
|---|---|---|---|
| Governance / Policy | Dunkelgrün | `#075033` | L27 Governance-Säulen, L6 Divider |
| Netzwerk / Connectivity | Mittelgrün | `#23A96A` | L27 Netzwerk-Säulen, L20 Bild-Akzent |
| Sicherheit / Compliance | Limette | `#AADE0C` | L27 Security-Säulen, L9 KPI-Akzent |
| Monitoring / Logging | Cyan | `#27C9D1` | L27 Logging-Säulen |
| Identity / RBAC | Blau | `#346CEF` | L27 Identity-Säulen |
| Neutral / Übergreifend | Grau | `#595959` | Fließtext, Metainfo |

**Regel:** Innerhalb einer L27-Folie immer 3 *verschiedene* Farben –
eine pro Säule – aus der obigen Tabelle. Nie zweimal dieselbe.

```python
# Beispiel: Governance-Kapitel, L27 – 3 Säulen
C_DARK = RGBColor(0x07, 0x50, 0x33)   # Governance
C_MID  = RGBColor(0x23, 0xA9, 0x6A)   # Netzwerk
C_LIME = RGBColor(0xAA, 0xDE, 0x0C)   # Sicherheit

three_col(prs, "§ 3 · Governance", "Drei Säulen der ALZ", [
    ("Governance",  C_DARK, ["149 Policies", "12 MGs", "42 Initiativen"]),
    ("Netzwerk",    C_MID,  ["Hub-and-Spoke", "Private DNS", "Firewall"]),
    ("Sicherheit",  C_LIME, ["RBAC", "Defender", "Key Vault"]),
])
```

---

## Folienzahl-Budget (30–40-Folien-Deck)

| Layout | Name | Min | Max | Empfehlung |
|---|---|---|---|---|
| L0 | Title Slide | 1 | 1 | Pflicht |
| L5 | Agenda 4 Topics | 0 | 1 | 1× wenn ≥ 4 Kapitel |
| L4 | Agenda | 0 | 1 | Alternative zu L5 |
| L6 | Divider | n_kap | n_kap+2 | 1 pro Kapitel + Abschluss |
| L9 | Highlight (KPI) | 0 | 4 | 1–2 pro Präsentation |
| L10 | Highlight Dark | 1 | 3 | Eröffnung + max. 2 weitere |
| L11 | Key Message | 0 | 2 | 1 starkes Zitat |
| L14 | Titel und Inhalt | 0 | **40 %** | Nie > 40 % aller Folien |
| L16 | 2x Text | 2 | 10 | 1–2 pro Kapitel |
| L19 | Text + Medium Pic | 0 | 4 | Für Diagramme mit viel Erklärtext |
| L20 | Text + Big Pic | 0 | 4 | Für dominante Architekturdiagramme |
| L25 | 2x Bild + 2x Text | 0 | 3 | Feature-Paare, Service-Vergleiche |
| L26 | 3x (asym.) | 0 | 2 | Wenn 2 Screenshots + Erklärung links |
| L27 | 3x Text + 3x Bild | 0 | 5 | 1 pro Architekturebene |
| L39 | Leer | 0 | 2 | Nur für Vollbild-Diagramme |

---

## Erweiterte Layout-Palette (bisher wenig genutzt)

### Layout 1 – Title Slide with 2 Pictures + 2x Partner Logo *(Co-Branding)*

| PH | Typ | Position (l/t/w/h) | Verwendung |
|---|---|---|---|
| 0 | CENTER_TITLE | 0,37"/1,58"/6,30"/2,36" | Haupttitel |
| 1 | SUBTITLE | 0,37"/4,73"/3,94"/0,79" | Untertitel |
| 14 | PICTURE | 5,36"/0,00"/5,97"/6,70" | Bild Mitte-rechts |
| 16 | PICTURE | 9,03"/0,00"/4,30"/6,70" | Bild ganz rechts |
| 17 | BODY | 0,37"/6,31"/3,15"/0,39" | Kleintext: Datum/Kunde |
| 18 | OBJECT | 3,36"/0,40"/1,30"/0,39" | Partner-Logo 1 |
| 19 | OBJECT | 4,86"/0,40"/1,30"/0,39" | Partner-Logo 2 |

> **Einsatz:** Titelfolie für Microsoft–Bechtle-Co-Sell-Präsentationen.
> Zwei Bildslots eignen sich für Referenz-Screenshots oder Architekturbilder.
> Partner-Logo-Slots (PH18/19) für Kunden- oder Microsoft-Logo.

### Layout 11 – Key message / Quote *(Kernbotschaft zentriert)*

| PH | Typ | Position (l/t/w/h) | Verwendung |
|---|---|---|---|
| 0 | TITLE | 2,73"/1,98"/7,87"/3,54" | Großes Zitat (zentriert) |
| 1 | SUBTITLE | 5,90"/0,80"/1,53"/0,28" | Quelle / Autor (klein) |

> **Einsatz:** 1× pro Präsentation für eine einzige, starke Aussage – z. B.
> als Einstieg in das Sicherheitskapitel oder als Abschluss-Statement.
> Der Titel ist mittig auf der Folie – maximale Aufmerksamkeit.
>
> Beispiel: `PH0 = "Security by default, nicht by accident."` /
> `PH1 = "Microsoft ALZ Design-Prinzip"`

```python
slide = prs.slides.add_slide(sl(prs, 11))
set_text(slide, 1, "Microsoft ALZ Design-Prinzip", size=10)
set_text(slide, 0, "Security by default,\nnicht by accident.", size=28, bold=True)
```

### Layout 12 – Quote Light *(Zitat, hell)*

| PH | Typ | Position (l/t/w/h) | Verwendung |
|---|---|---|---|
| 0 | TITLE | 0,37"/0,80"/7,09"/3,94" | Zitat-Text (linksbündig) |
| 13 | BODY | 0,37"/6,31"/2,36"/0,79" | Autor / Quelle |

> **Einsatz:** Für externe Quellen – Analysten-Statements, Kunden-Zitate,
> Microsoft-Dokumentation. Heller Hintergrund im Gegensatz zu L11.

### Layout 15 – Text Right *(Titel prominent links, Inhalt rechts)*

| PH | Typ | Position (l/t/w/h) | Verwendung |
|---|---|---|---|
| 1 | SUBTITLE | 0,37"/0,40"/4,72"/0,39" | Breadcrumb |
| 0 | TITLE | 0,37"/0,80"/4,72"/2,36" | Großer Titel links (2,36" hoch) |
| 13 | BODY | 0,37"/3,55"/4,72"/3,54" | Zusatztext links unten |
| 15 | BODY | 6,67"/0,80"/3,94"/6,30" | Hauptinhalt rechts |

> **Einsatz:** Wenn der Titel selbst die Hauptbotschaft trägt und der Inhalt
> rechts die Details liefert. Gut für „Was bekommt der Kunde?"-Folien:
> Links `"Was Sie bekommen"`, rechts die konkrete Leistungsliste.
>
> Tipp: PH15 (rechts) mit Bullets füllen, PH0 als großes Statement.

```python
slide = prs.slides.add_slide(sl(prs, 15))
set_text(slide, 1, "§ 8 · Identity & RBAC", size=11)
set_text(slide, 0, "Klare Rollen,\nklare Grenzen.", size=28, bold=True)
set_text(slide, 13, "Jeder Zugriff ist dokumentiert,\nbegründet und widerrufbar.", size=12)
set_bullets(slide, 15, [
    "Reader / Contributor / Owner auf MG-Ebene",
    "5 Custom-Rollen für ALZ-Betrieb",
    "Entra ID Gruppen-gesteuert",
    "PIM für privilegierte Aktionen",
], size=12)
```

### Layout 25 – 2x Text + 2x Picture *(Feature-Paare)*

| PH | Typ | Position (l/t/w/h) | Verwendung |
|---|---|---|---|
| 1 | SUBTITLE | 0,37"/0,40"/8,66"/0,39" | Breadcrumb |
| 0 | TITLE | 0,37"/0,80"/8,66"/0,79" | Folientitel |
| 18 | PICTURE | 0,37"/2,37"/5,91"/2,76" | Bild links oben |
| 19 | PICTURE | 6,67"/2,37"/5,91"/2,76" | Bild rechts oben |
| 13 | BODY | 0,37"/5,52"/5,91"/1,58" | Text links unten |
| 14 | BODY | 6,67"/5,52"/5,91"/1,58" | Text rechts unten |

> **Einsatz:** Zwei gleichwertige Azure-Dienste oder Features nebeneinander.
> Schema: Bild oben (Screenshot / Architektur-Snippet) + Kurztext unten.
> Text-Bereich ist niedrig (1,58") – nur Kurzaussagen, max. 2–3 Zeilen.
>
> Beispiel: Links `Azure Monitor` + `"VM-Metriken in Echtzeit"`,
> rechts `Log Analytics` + `"Zentrales Query-Interface"`.

```python
slide = prs.slides.add_slide(sl(prs, 25))
set_text(slide, 1, "§ 7 · Monitoring & Logging")
set_text(slide, 0, "Zwei Werkzeuge – ein Überblick")
# Bilder einfügen:
for ph in slide.placeholders:
    if ph.placeholder_format.idx == 18:
        ph.insert_picture("images/azure-monitor.png")
    elif ph.placeholder_format.idx == 19:
        ph.insert_picture("images/log-analytics.png")
set_bullets(slide, 13, ["VM-Metriken · Alerts · Dashboards"], size=12)
set_bullets(slide, 14, ["KQL-Queries · DCRs · Workbooks"], size=12)
```

### Layout 26 – 3x Text + 2x Picture *(Text links + 2 Screenshots)*

| PH | Typ | Position (l/t/w/h) | Verwendung |
|---|---|---|---|
| 1 | SUBTITLE | 0,37"/0,40"/3,94"/0,39" | Breadcrumb |
| 0 | TITLE | 0,37"/0,80"/3,94"/2,36" | Großer Titel links |
| 13 | BODY | 0,37"/3,16"/3,94"/3,94" | Haupttext links (groß) |
| 18 | PICTURE | 4,70"/0,80"/3,94"/4,33" | Bild Mitte |
| 14 | BODY | 4,70"/5,52"/3,94"/1,58" | Kurztext unter Mitte |
| 19 | PICTURE | 9,03"/0,80"/3,94"/4,33" | Bild rechts |
| 20 | BODY | 9,03"/5,52"/3,94"/1,58" | Kurztext unter Rechts |

> **Einsatz:** Wenn ein erklärender Absatz links gebraucht wird und rechts
> zwei Service-Screenshots oder Diagramm-Ausschnitte stehen.
> Asymmetrisch – links dominiert der Text, rechts die Bilder.
>
> Ideal für: „Wie funktioniert DINE?" (links erklärt) + Screenshots von
> DeployIfNotExists-Policy und Compliance-Dashboard (rechts).

### Layout 28 – 4x Text + 3x Picture *(Kompakte 3-Dienste-Übersicht)*

| PH | Typ | Position (l/t/w/h) | Verwendung |
|---|---|---|---|
| 1 | SUBTITLE | 0,37"/0,40"/3,94"/0,39" | Breadcrumb |
| 0 | TITLE | 0,37"/0,80"/3,94"/2,36" | Titel links |
| 13 | BODY | 0,37"/3,16"/3,94"/3,94" | Haupttext links |
| 18 | PICTURE | 5,09"/0,80"/2,36"/3,15" | Screenshot Dienst 1 |
| 14 | BODY | 5,09"/4,34"/2,36"/2,76" | Text Dienst 1 |
| 19 | PICTURE | 7,85"/0,80"/2,36"/3,15" | Screenshot Dienst 2 |
| 20 | BODY | 7,85"/4,34"/2,36"/2,76" | Text Dienst 2 |
| 21 | PICTURE | 10,60"/0,80"/2,36"/3,15" | Screenshot Dienst 3 |
| 22 | BODY | 10,60"/4,34"/2,36"/2,76" | Text Dienst 3 |

> **Einsatz:** Drei Azure-Dienste kompakt: Bild oben, Text unten, Erklärung links.
> Ähnlich wie L27 aber mit echten Screenshots statt farbigen Boxen.
> Screenshots-Slots sind schmal (2,36") – UI-Ausschnitte, keine Diagramme.

### Layout 29 – 4x Text + 4x Picture *(4er-Grid)*

| PH | Typ | Position (l/t/w/h) | Verwendung |
|---|---|---|---|
| 1 | SUBTITLE | 0,37"/0,40"/8,66"/0,39" | Breadcrumb |
| 0 | TITLE | 0,37"/0,80"/8,66"/0,79" | Folientitel |
| 18 | PICTURE | 0,37"/2,37"/2,76"/2,76" | Bild 1 (oben links) |
| 19 | PICTURE | 3,52"/2,37"/2,76"/2,76" | Bild 2 |
| 20 | PICTURE | 6,67"/2,37"/2,76"/2,76" | Bild 3 |
| 22 | PICTURE | 9,82"/2,37"/2,76"/2,76" | Bild 4 (oben rechts) |
| 13 | BODY | 0,37"/5,52"/2,76"/1,58" | Text 1 |
| 14 | BODY | 3,52"/5,52"/2,76"/1,58" | Text 2 |
| 21 | BODY | 6,67"/5,52"/2,76"/1,58" | Text 3 |
| 23 | BODY | 9,82"/5,52"/2,76"/1,58" | Text 4 |

> **Einsatz:** Kompakte Referenzfolie mit 4 gleichwertigen Diensten/Features.
> Jeder Slot: Icon oder UI-Screenshot oben, 1–2 Zeilen Text unten.
> Gut für: „4 Kernkomponenten der ALZ", „4 Phasen des Projekts".

### Layout 30 – Text + 4x Picture *(Text links + 2×2 Screenshot-Grid)*

| PH | Typ | Position (l/t/w/h) | Verwendung |
|---|---|---|---|
| 1 | SUBTITLE | 0,37"/0,40"/3,94"/0,39" | Breadcrumb |
| 0 | TITLE | 0,37"/0,80"/4,72"/1,57" | Folientitel |
| 13 | BODY | 0,37"/2,37"/4,72"/4,73" | Haupttext links |
| 18 | PICTURE | 6,67"/0,80"/2,95"/2,36" | Screenshot oben links |
| 21 | PICTURE | 10,01"/0,80"/2,95"/2,36" | Screenshot oben rechts |
| 22 | PICTURE | 6,67"/3,95"/2,95"/2,36" | Screenshot unten links |
| 23 | PICTURE | 10,01"/3,95"/2,95"/2,36" | Screenshot unten rechts |
| 14 | BODY | 6,67"/3,36"/2,95"/0,39" | Label oben links |
| 30 | BODY | 10,01"/3,36"/2,95"/0,39" | Label oben rechts |
| 31 | BODY | 6,67"/6,51"/2,95"/0,39" | Label unten links |
| 32 | BODY | 10,01"/6,51"/2,95"/0,39" | Label unten rechts |

> **Einsatz:** Wenn 4 Screenshots zu einem Thema gehören und links ein
> erklärender Absatz steht. Gut für: Portal-Walkthrough mit 4 UI-Screens,
> „Monitoring-Dashboards im Überblick".

---

## Konkrete Sequenz-Empfehlung pro Kapiteltyp

### Governance-Kapitel (Policy, MGs, Compliance)
```
L6  Divider:      "§ 4 · Governance"  /  "149 Policies. 12 Management Groups."
L11 Key Message:  "Compliance ist kein Projekt – sie ist der Betriebszustand."
L20 Big Pic:      MG-Hierarchie-Diagramm + 3 Key-Facts links
L27 3 Säulen:     Definitionen (dunkelgrün) / Initiativen (mittelgrün) / Assignments (limette)
L16 Vergleich:    Ohne ALZ (manuell) vs. Mit ALZ (Policy-as-Code)
L14 Details:      Policy-Effekte: Audit / Deny / DINE / DoNotEnforce
L9  KPI:          "149 Policies – 0 manuelle Konfigurationen"
```

### Netzwerk-Kapitel (Hub-and-Spoke, Firewall, DNS)
```
L6  Divider:      "§ 5 · Netzwerk"  /  "Hub-and-Spoke. Zero-Trust-ready."
L20 Big Pic:      Hub-Spoke-Topologie (dominantes Diagramm)
L27 3 Säulen:     Connectivity (grün) / Sicherheit (limette) / DNS (cyan)
L16 Vergleich:    Microsoft-Standard (links) vs. Bechtle-Empfehlung (rechts)
L19 Med Pic:      Firewall-Regelwerk + Erklärung links
L9  KPI:          "~€1.050 / Monat – Variante B"
```

### Kosten-Kapitel (Varianten, ROI)
```
L6  Divider:      "§ 10 · Kosten"  /  "4 Varianten. Eine Empfehlung."
L9  KPI:          "~€1.050 / Monat"  (Bechtle-Empfehlung)
L16 Vergleich:    Variante A (links: minimal) vs. Variante D (rechts: voll)
L14 Details:      Kostentabelle alle 4 Varianten
L10 Dark:         "Investition in Sicherheit – nicht in Betrieb."
```

---

## Breadcrumb-Konventionen

> PH1 (SUBTITLE) ist auf fast allen Layouts das Breadcrumb-Feld.
> Es gibt der Folie Kontext und hilft beim Handout.

| Format | Beispiel |
|---|---|
| Kapitel-Kontext | `"§ 4 · Governance"` |
| Unterabschnitt | `"§ 4 · Governance – Policy-Effekte"` |
| Kapitelübergreifend | `"Management Summary"` |
| Divider (PH1 = Kernfrage) | `"Wie sieht Sicherheit als Code aus?"` |

**Regeln:**
- Immer `§X` + Kapitelname + optional Unterabschnitt
- Maximal eine Zeile, ≤ 50 Zeichen
- Nicht auf L10 (dunkel) – dort ist PH1 winzig und als Breadcrumb schwer lesbar
