# Bechtle Design-System (Corporate Design)

> Extrahiert aus der Original-Vorlage
> `VORLAGE_Bechtle_Management_Summary.docx` (MDF AG, Office-LTSC-Projekt).
> Diese Datei beschreibt verbindlich das Bechtle-Layout für alle Kundendokumente.

## Logos

| Datei | Verwendung |
|---|---|
| `bechtle-logo.png` / `.svg` | Hauptlogo (grünes Rauten-Icon + Wortmarke „bechtle") – Kopfzeile |
| `bechtle-com.png` / `.svg` | Kompaktmarke „bechtle.com" – Fußzeile/klein |

SVG bevorzugen (skaliert verlustfrei); PNG als Fallback.

## Schrift

| Element | Schrift | Größe |
|---|---|---|
| Hausschrift (Haupt + Brot) | **Bechtle Pro** | – |
| Fallback (falls nicht installiert) | Arial / Segoe UI | – |
| Aufzählungen | Arial | 9 pt |
| Fließtext (Standard) | Bechtle Pro | 11 pt |
| Kleintext („Standard klein") | Bechtle Pro | 8 pt |

> **Hinweis:** „Bechtle Pro" ist eine lizenzierte Hausschrift. Ist sie auf dem
> Generierungs-Rechner nicht installiert, im Word-Dokument trotzdem als Schriftname
> setzen (Bechtle-Rechner rendern korrekt) und Arial als Fallback hinterlegen.

## Farben (Theme)

| Rolle | Hex | Verwendung |
|---|---|---|
| accent1 – Dunkelgrün | `#075033` | Primärfarbe, Logo, Akzente |
| **Überschriften** | `#053B25` | H1–H5 (sehr dunkles Grün) |
| accent2 – Grün | `#23A96A` | Sekundär-Akzent, Hervorhebungen |
| accent3 – Limette | `#AADE0C` | Highlight / Call-out |
| accent4 – Cyan | `#27C9D1` | Diagramm-Akzent |
| accent5 – Blau | `#346CEF` | Diagramm-Akzent / Links |
| Grau (Subtitle/Sekundärtext) | `#595959` | Untertitel, H6/H7, Metatext |
| Hellgrau | `#C3C3C3` | Linien, Tabellenrahmen |
| Schwarz | `#000000` | Fließtext |
| Weiß | `#FFFFFF` | Hintergrund |

## Absatz-Formate (Word-Stile)

| Stil | Größe | Farbe | Hinweis |
|---|---|---|---|
| `Title` | 28 pt | #053B25 | Dokumenttitel |
| `Subtitle` | 14 pt | #595959 | Untertitel unter Titel |
| `Heading 1` | 20 pt | #053B25 | Hauptkapitel |
| `Heading 2` | 16 pt | #053B25 | Unterkapitel |
| `Heading 3` | 14 pt | #053B25 | Abschnitt |
| `Standard klein` | 8 pt | – | Adresszeile, Leistungsgrenze-Hinweis |
| `Bechtle Aufzählung` | 9 pt (Arial) | #000000 | Bullet-Listen |

## Seiten-Layout

**Kopfzeile (Header):** Bechtle-Logo + Projektkontext rechts/links, z. B.
`<KUNDE> | <Projekttitel>` — im Muster: `MDF AG | Office LTSC zu Microsoft 365 Apps`.
Für ALZ: `<KUNDE> | Azure Landing Zone`.

**Fußzeile (Footer):**
- Mittig/links: `Bechtle | <Dokumenttyp> | Seite X von Y`
- Adressblock (Stil „Standard klein"):
  ```
  Bechtle GmbH & Co. KG · Gottlieb-Daimler-Straße 2 · 68165 Mannheim
  T +49 621 87503-0 · www.bechtle.com
  ```

**Erste Seite:** Adresszeile oben („Standard klein"), dann Titel, Untertitel, und
ein **Leistungsgrenze-Hinweis** (kursiv/klein) der Scope und Abgrenzung klärt.

## Bewährte Dokument-Bausteine (aus der Vorlage)

1. **Management Summary** zuerst – knapp, entscheidungsorientiert.
2. **Leistungsgrenze / Scope-Hinweis** direkt unter dem Untertitel (was ist NICHT Teil
   der Umsetzung).
3. **Randthemen-Muster** je Unterkapitel mit drei Bullets:
   - *Zu prüfen:* …
   - *Mögliche Folgestufe:* …
   - *Abgrenzung:* …
   Dieses Muster sauber für ALZ-Themen übernehmen (z. B. Netzwerk, Identity, Kosten).

## Erzeugung (für den nächsten Chat)

`python-docx` ist verfügbar. Empfohlenes Vorgehen:
1. Vorlage `VORLAGE_Bechtle_Management_Summary.docx` als **Basis öffnen**
   (`docx.Document(pfad)`) → erbt automatisch Stile, Theme, Header/Footer, Logos.
2. Beispielinhalte entfernen, ALZ-Inhalte über die **vorhandenen benannten Stile**
   einfügen (`Title`, `Subtitle`, `Heading 1/2/3`, `Bechtle Aufzählung`, `Standard klein`).
3. Header-Text auf `<KUNDE> | Azure Landing Zone` ändern.
4. So bleibt das Corporate Design 1:1 erhalten, ohne Farben/Fonts manuell zu setzen.
