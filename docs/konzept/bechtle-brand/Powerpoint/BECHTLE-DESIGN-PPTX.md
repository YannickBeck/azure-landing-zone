# Bechtle Design-System – PowerPoint

> Extrahiert aus den offiziellen Bechtle Designvorlagen
> `Bechtle_Designvorlage_Grün_Teil1/2/3.pptx`.
> Diese Datei beschreibt verbindlich das Bechtle-Layout für alle
> Kundenpräsentationen.

## Vorlage

| Datei | Verwendung |
|---|---|
| `VORLAGE_Bechtle_Praesentation.pptx` | Bereinigte Basis-Vorlage (0 Folien, vollständiger Slide-Master mit allen 41 Layouts, Theme, Logos in Header/Footer) |
| `Bechtle_Designvorlage_Grün_Teil1.pptx` | Vollständiges Design-Kit (74 Demo-Folien) – nur als Referenz |
| `Bechtle_Designvorlage_Grün_Teil2.pptx` | Weiteres Design-Kit – nur als Referenz |
| `Bechtle_Designvorlage_Grün_Teil3.pptx` | Weiteres Design-Kit – nur als Referenz |

**Empfohlenes Vorgehen (analog zu Word):**
```python
from pptx import Presentation
prs = Presentation("bechtle-brand/Powerpoint/VORLAGE_Bechtle_Praesentation.pptx")
# Folien hinzufügen mit prs.slides.add_slide(prs.slide_masters[0].slide_layouts[idx])
```
→ erbt automatisch Theme, Farben, Schriften, Logos, Header/Footer.

---

## Foliengröße

| Eigenschaft | Wert |
|---|---|
| Breite | 13,33" (33,87 cm) |
| Höhe | 7,50" (19,05 cm) |
| Format | Widescreen 16:9 |

---

## Farben (Theme)

Identisch mit dem Word-Corporate-Design:

| Rolle | Hex | Verwendung |
|---|---|---|
| accent1 – Dunkelgrün | `#075033` | Primärfarbe, Hintergrund Divider/Titelfolien |
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

> **Hinweis:** „Bechtle Pro" ist eine lizenzierte Hausschrift.
> Auf nicht-Bechtle-Rechnern rendert Arial als Fallback.

---

## Slide-Master: verfügbare Layouts

| Idx | Name | Verwendung |
|---|---|---|
| 0 | Title Slide with Picture | Titelfolie (Haupttitel + Bild rechts) |
| 1 | Title Slide with 2 Pictures + 2x Partner Logo | Titelfolie mit Partnerlogos |
| 2 | Title Slide with Picture + 3x Partner Logo | Titelfolie Variante |
| 3 | Title Slide + 3x Partner Logo | Titelfolie ohne Bild |
| 4 | Agenda | Agenda-Folie |
| 5 | Agenda 4 Topics | Agenda kompakt (4 Punkte) |
| 6 | Divider Number / Icon | Kapitel-Trenner |
| 7 | Divider Picture | Kapitel-Trenner mit Bild |
| 8 | Picture Highlight | Bild-Highlight |
| 9 | Highlight | Highlight (heller Hintergrund) |
| 10 | Highlight Dark | Highlight (dunkler Hintergrund) |
| 11 | Key message / Quote | Kernbotschaft / Zitat |
| 12 | Quote Light | Zitat (hell) |
| 13 | Nur Titel | Nur Titel (freier Inhaltsbereich) |
| 14 | Titel und Inhalt | Standard-Inhaltsfolie |
| 15 | Text Right | Text links + Bild rechts |
| 16 | 2x Text | Zweispaltig |
| 18 | Text + Small Picture Right | Text + kleines Bild |
| 19 | Text + Medium Picture Right | Text + mittleres Bild |
| 20 | Text + Big Picture Right | Text + großes Bild |
| 21 | Text + Small Picture Left | Text + kleines Bild links |
| 22 | Text + Medium Picture Left | Text + mittleres Bild links |
| 23 | Text + 5x Picture | Text + 5 Bilder |
| 24 | Text + 8x Picture | Text + 8 Bilder |
| 25 | 2x Text + 2x Picture | 2 Spalten + 2 Bilder |
| 26 | 3x Text + 2x Picture | 3 Spalten + 2 Bilder |
| 27 | 3x Text + 3x Picture | 3 Spalten + 3 Bilder |
| 28 | 4x Text + 3x Picture | 4 Spalten + 3 Bilder |
| 29 | 4x Text + 4x Picture | 4 Spalten + 4 Bilder |
| 30 | Text + 4x Picture | Text + 4 Bilder |
| 39 | Leer | Blanko-Folie |

> Indizes 17, 31–38, 40 haben defekte Referenzen in der Quelldatei –
> diese Layouts nicht verwenden.

---

## Platzhalter der wichtigsten Layouts

### Layout 0 – Title Slide with Picture

| PH idx | Typ | Position (l / t / w / h) | Verwendung |
|---|---|---|---|
| 0 | CENTER_TITLE | 0,37" / 1,58" / 7,09" / 2,36" | Haupttitel |
| 1 | SUBTITLE | 0,37" / 4,73" / 3,94" / 0,79" | Untertitel |
| 14 | PICTURE | 4,18" / 0,00" / 9,15" / 6,70" | Bild rechts (Hintergrundfoto) |
| 15 | BODY | 0,37" / 6,31" / 3,15" / 0,39" | Kleintext (Kunde, Datum) |

### Layout 4 – Agenda

| PH idx | Typ | Position | Verwendung |
|---|---|---|---|
| 0 | TITLE | 0,37" / 0,40" / 8,66" / 0,79" | Titel „Agenda" |
| 13 | BODY | 0,37" / 1,59" / 8,66" / 5,51" | Agenda-Punkte (Bullet-Liste) |

### Layout 6 – Divider Number / Icon

| PH idx | Typ | Position | Verwendung |
|---|---|---|---|
| 0 | TITLE | 0,37" / 1,58" / 7,87" / 1,57" | Kapitel-Titel |
| 1 | SUBTITLE | 0,37" / 3,95" / 3,94" / 1,57" | Kurz-Beschreibung |
| 13 | BODY | 8,24" / 1,58" / 4,72" / 3,94" | Kennzahlen / Facts rechts |

### Layout 14 – Titel und Inhalt *(Standard-Inhaltsfolie)*

| PH idx | Typ | Position | Verwendung |
|---|---|---|---|
| 1 | SUBTITLE | 0,37" / 0,40" / 8,66" / 0,39" | Kopfzeile / Kapitel-Kontext |
| 0 | TITLE | 0,37" / 0,80" / 8,66" / 0,79" | Folien-Titel |
| 13 | BODY | 0,37" / 2,37" / 12,60" / 4,73" | Inhalt (Bullets, Text) |

### Layout 16 – 2x Text *(zweispaltig)*

| PH idx | Typ | Position | Verwendung |
|---|---|---|---|
| 1 | SUBTITLE | 0,37" / 0,40" / 8,66" / 0,39" | Kopfzeile |
| 0 | TITLE | 0,37" / 0,80" / 8,66" / 0,79" | Folien-Titel |
| 13 | BODY | 0,37" / 2,37" / 5,12" / 4,73" | Linke Spalte |
| 14 | BODY | 6,67" / 2,37" / 5,12" / 4,73" | Rechte Spalte |

### Layout 10 – Highlight Dark *(Statement-Folie)*

| PH idx | Typ | Position | Verwendung |
|---|---|---|---|
| 1 | SUBTITLE | 0,37" / 0,40" / 6,30" / 0,39" | Kopfzeile |
| 0 | TITLE | 0,37" / 0,80" / 6,30" / 1,57" | Statement-Text |
| 13 | BODY | 0,37" / 3,16" / 3,94" / 3,15" | Ergänzungstext |

---

## Erzeugung (für den nächsten Chat)

`python-pptx` ist verfügbar. Empfohlenes Vorgehen:

1. `VORLAGE_Bechtle_Praesentation.pptx` öffnen
   (`pptx.Presentation(pfad)`) → enthält 0 Folien, aber vollen Slide-Master.
2. Folien über die benannten Layouts hinzufügen:
   ```python
   layout = prs.slide_masters[0].slide_layouts[14]  # Titel und Inhalt
   slide = prs.slides.add_slide(layout)
   ```
3. Platzhalter per `placeholder_format.idx` befüllen (Tabelle oben).
4. Kein manuelles Farb-/Font-Setzen nötig – Theme wird automatisch vererbt.

```python
# Minimales Beispiel
from pptx import Presentation
from pptx.util import Pt

prs = Presentation("bechtle-brand/Powerpoint/VORLAGE_Bechtle_Praesentation.pptx")
master = prs.slide_masters[0]

# Titelfolie
slide = prs.slides.add_slide(master.slide_layouts[0])   # Title Slide with Picture
for ph in slide.placeholders:
    if ph.placeholder_format.idx == 0:
        ph.text = "Mein Titel"
    elif ph.placeholder_format.idx == 1:
        ph.text = "Mein Untertitel"

# Inhaltsfolie
slide2 = prs.slides.add_slide(master.slide_layouts[14])  # Titel und Inhalt
for ph in slide2.placeholders:
    if ph.placeholder_format.idx == 0:
        ph.text = "Folientitel"
    elif ph.placeholder_format.idx == 13:
        tf = ph.text_frame
        tf.text = "Erster Bullet"
        p = tf.add_paragraph()
        p.text = "Zweiter Bullet"
        p.level = 1

prs.save("output.pptx")
```
