# Azure Landing Zone – Bicep (offizieller ALZ Accelerator)

[![license](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)

Dieses Repository basiert auf dem **offiziellen Microsoft Starter-Modul** für den
*Azure Landing Zones IaC Bicep Accelerator*
([Azure/alz-bicep-accelerator](https://github.com/Azure/alz-bicep-accelerator)).
Es wird über die `ALZ` PowerShell (`Deploy-Accelerator`) gebootstrappt und deployt
die Plattform-Landing-Zone mit **Azure Verified Modules (AVM)** und dem
**vollständigen ALZ-Policy-Set** (`avm/ptn/alz/empty`).

> **Migrationshinweis:** Die vorherige, schlanke Eigenimplementierung wurde nach
> [`legacy-custom/`](legacy-custom/) archiviert (Code-Historie bleibt erhalten). Sie
> ist nicht mehr der aktive Deployment-Pfad.

## Schnellstart

1. **Bootstrap-Runbook lesen:** [`docs/ACCELERATOR-BOOTSTRAP.md`](docs/ACCELERATOR-BOOTSTRAP.md)
   führt Schritt für Schritt durch `Deploy-Accelerator` (inkl. Single-Subscription-
   und Kosten-armer Variante).
2. **Konfiguration befüllen:** Kopiervorlagen liegen in [`config/`](config/) –
   `config/inputs-github.yaml` (Bootstrap) und `config/platform-landing-zone.yaml`
   (Starter-Modul). Die unveränderten Microsoft-Originale liegen in [`examples/`](examples/).
3. **Deployen:** `Deploy-Accelerator -inputs ./config/inputs-github.yaml ./config/platform-landing-zone.yaml`

## ⚠️ Kostenhinweis (wichtig)

Die **Microsoft-Standardwerte** in `templates/networking/hubnetworking/main.bicepparam`
aktivieren **alle** Netzwerk-Dienste in **beiden** Regionen:

| Dienst (Default = an) | Grobe Kosten/Monat |
|---|---|
| 2× Azure Firewall (Standard) | ~€2.200 |
| 2× Azure Bastion | ~€240 |
| 2× VPN Gateway (VpnGw1AZ) | ~€280 |
| 2× ExpressRoute Gateway | ~€560 |
| 1× DDoS Network Protection | ~€2.500 |
| 2× DNS Private Resolver | ~€50 |
| **Summe (ungefähr)** | **~€5.800** |

Für einen **kostenarmen Start / Smoke Run** die Schalter in der `.bicepparam`
(bzw. über die Konfiguration) auf `false` setzen – siehe Runbook, Abschnitt
„Kostenarme Variante". Management Groups + Policies + Logging bleiben praktisch kostenlos.

## Struktur

| Pfad | Inhalt |
|---|---|
| `templates/core/governance/` | Management Groups + **volles ALZ-Policy-Set** (`lib/alz/`, 319 Definitionen) |
| `templates/core/logging/` | Log Analytics / AMA (`avm/ptn/alz/ama`) |
| `templates/networking/hubnetworking/` | Hub-and-Spoke (Firewall, Bastion, DNS, Gateways, DDoS) |
| `templates/networking/virtualwan/` | Virtual WAN (Alternative) |
| `.config/ALZ-Powershell.config.json` | Accelerator-Orchestrierung (18 geordnete Deployment-Stufen) |
| `examples/` | Microsoft-Original-Konfigurationsvorlagen |
| `config/` | **Befüllte** Konfiguration für dieses Setup |
| `docs/` | Bootstrap-Runbook + Kickoff-Unterlagen |
| `legacy-custom/` | Archivierte Vorgänger-Implementierung |

---

## Attribution & Lizenz

Dieses Projekt basiert auf [Azure/alz-bicep-accelerator](https://github.com/Azure/alz-bicep-accelerator)
(MIT License, © Microsoft Corporation – siehe [`LICENSE`](LICENSE)).

This repository may contain trademarks or logos for projects, products, or services. Authorized
use of Microsoft trademarks or logos is subject to and must follow
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion
or imply Microsoft sponsorship.
