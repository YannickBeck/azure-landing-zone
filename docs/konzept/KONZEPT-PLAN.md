# Konzept-Plan: Azure Landing Zone – Kundenkonzept

> **Zweck dieser Datei:** Strukturplan (Outline) für das vollständige Kundenkonzept
> „Azure Landing Zone" im Bechtle-Design. Im nächsten Chat wird auf Basis dieses Plans
> das fertige Word-Dokument (und optional PPTX) erzeugt.
>
> **Design:** verbindlich nach `bechtle-brand/BECHTLE-DESIGN.md` (Bechtle Pro,
> Grüntöne #075033/#053B25, Logos, Header/Footer wie Vorlage).
>
> **Quellen im Repo** (technische Fakten – nicht neu erfinden, von dort ziehen):
> - `docs/PROJEKT-STATUS.md` – Gesamtstatus, Zahlen, Kosten, Subscriptions
> - `docs/TECHNICAL-REFERENCE.md` – granular: 22 AVM-Module, 123 Assignments, 149 Policies
> - `docs/ACCELERATOR-BOOTSTRAP.md` – Bootstrap-/Deployment-Runbook
> - `config/inputs-github.yaml`, `config/platform-landing-zone.yaml` – konkrete Konfig
> - `.config/ALZ-Powershell.config.json` – 18 Deploy-Stufen
> - `templates/**` – die echten Bicep-Templates

---

## Dokument-Metadaten

| Feld | Wert |
|---|---|
| Titel | **Azure Landing Zone – Konzept und Umsetzungsfahrplan** |
| Untertitel | Zielbild, Governance, Netzwerk, Sicherheit, Betrieb und Roadmap auf Basis des Microsoft ALZ Bicep Accelerator |
| Kunde | `<KUNDE>` (Platzhalter, im Header) |
| Ersteller | Bechtle GmbH & Co. KG |
| Dokumenttyp (Footer) | „Bechtle \| Azure Landing Zone – Konzept" |
| Leistungsgrenze-Hinweis | Konzept + Pilotierung; produktive Vollmigration, Anwendungs-Onboarding und Betrieb sind eigene Folgeschritte. |

---

## Kapitelstruktur

### 0. Deckblatt + Management Summary *(Heading 1)*
- Adresszeile oben („Standard klein"), Titel, Untertitel, Leistungsgrenze-Hinweis.
- **Management Summary** (½–1 Seite, entscheidungsorientiert):
  - Was ist eine Azure Landing Zone und warum (skalierbare, governance-konforme
    Azure-Grundstruktur „ab Tag 1").
  - Ansatz: **offizieller Microsoft ALZ Bicep Accelerator** (kein Eigenbau) →
    Wartbarkeit, Microsoft-Standard, Updates.
  - Kernnutzen in 4 Punkten: Governance/Policies, Netzwerk-Hub, Sicherheit/Defender,
    Automatisierung (IaC + Pipelines).
  - Klarer Hinweis auf **Kostensteuerung** (Default ≈ €5.800/Monat vs. kostenarmer
    Start). → Quelle: `PROJEKT-STATUS.md` §4.
  - Empfohlener Einstieg: Pilot mit 1 Subscription, `network_type: none`, Policies im
    `DoNotEnforce`-Modus.

### 1. Ausgangslage und Zielsetzung *(Heading 1)*
- Ausgangslage Kunde: 0 Azure-Vorerfahrung, 1 Subscription, kein Kickoff erfolgt.
  → Quelle: `PROJEKT-STATUS.md` §14.
- Zielbild: standardisierte, mandantenweite Grundstruktur (Management Groups, Policies,
  Netzwerk, Logging, Sicherheit) als Fundament für künftige Workloads.
- Abgrenzung zu Workload-/Applikationsmigration (das ist Folgeprojekt).
- Erfolgskriterien (messbar): Hierarchie steht, Policies greifen, Logging zentral,
  Netzwerk-Hub bereit, IaC + Pipeline reproduzierbar.

### 2. Methodik und Vorgehen *(Heading 1)*
- **Microsoft ALZ Bicep Accelerator** erklärt: `Deploy-Accelerator`, AVM-Module aus MCR.
  → Quelle: `PROJEKT-STATUS.md` §2, `ACCELERATOR-BOOTSTRAP.md`.
- Infrastructure as Code (Bicep) + GitHub-Pipelines + OIDC (passwortlos).
- 18 geordnete Deployment-Stufen (Tabelle). → Quelle: `PROJEKT-STATUS.md` §6.
- „Build offline gegen MCR" als Qualitätssicherung (20/20 Templates grün).

### 3. Zielarchitektur *(Heading 1)*
#### 3.1 Management-Group-Hierarchie *(Heading 2)*
- 12 Management Groups (alz → platform/landingzones/sandbox/decommissioned + Sub-MGs).
  → Diagramm + Tabelle. Quelle: `PROJEKT-STATUS.md` §7.
#### 3.2 Subscription-Strategie *(Heading 2)*
- Single-Subscription-Start → spätere Trennung in 4 Platform-Subs (management,
  connectivity, identity, security). → Quelle: `PROJEKT-STATUS.md` §3.
- Anforderungen: EA/MCA/PAYG, kein Free Tier, Resource-Provider automatisch.
- **Randthemen-Muster:** Zu prüfen / Mögliche Folgestufe / Abgrenzung.
#### 3.3 Namens- und Regionskonzept *(Heading 2)*
- Regionen `germanywestcentral` (primär) + `northeurope` (sekundär).
- Naming: Microsoft-Standard-IDs. → Quelle: `config/platform-landing-zone.yaml`.

### 4. Governance und Policies *(Heading 1)*
- Volles ALZ-Policy-Set über `avm/ptn/alz/empty:0.3.6`:
  **149 Policy-Definitionen, 42 Initiativen, 123 Assignments, 5 Custom-Rollen.**
  → Quelle: `PROJEKT-STATUS.md` §2, `TECHNICAL-REFERENCE.md`.
- Assignment-Verteilung je MG-Ebene (Tabelle: alz 17 / landingzones 53 / platform 40 …).
- **DoNotEnforce-Modus** für sanftes Onboarding (Audit-first statt Deny).
- Was die Policies konkret bewirken (Beispiele: Standorte, Verschlüsselung,
  Diagnostics, Defender-Aktivierung).
- Hinweis: Defender for Cloud wird per Policy automatisch aktiviert (Kostenfolge).

### 5. Netzwerk-Architektur *(Heading 1)* — *Schwerpunkt für Netzwerker-Runde*
#### 5.1 Hub-and-Spoke-Topologie *(Heading 2)*
- Hub-VNets 10.0.0.0/22 (primär) + 10.1.0.0/22 (sekundär), Spokes via Peering.
#### 5.2 Subnetze und Dienste *(Heading 2)*
- Subnetz-Tabelle (AzureFirewallSubnet /26, Bastion /26, GatewaySubnet /27,
  DNS-Resolver In/Out /28 …). → Quelle: `PROJEKT-STATUS.md` §7.
- Dienste: Azure Firewall Premium, Bastion, VPN-GW, ExpressRoute-GW, DDoS, Private DNS,
  DNS Private Resolver.
#### 5.3 DNS-Konzept *(Heading 2)*
- Private DNS Zones (alle Azure-Standardzonen) + Resolver.
#### 5.4 Alternative: Virtual WAN *(Heading 2)*
- `network_type: vwanConnectivity` als Option; Entscheidungskriterien.
- **Randthemen-Muster** (ExpressRoute/VPN-Anbindung On-Prem, IP-Adresskonzept,
  Peering zu bestehenden Netzen).

### 6. Sicherheit *(Heading 1)*
- Microsoft Defender for Cloud (Plan-Aktivierung via Policy), Security Contacts.
- Zentrales Logging als Sicherheits-Backbone (Activity Logs, Diagnostics → LAW).
- Optional: Sentinel-Onboarding (Roadmap).
- → Quelle: `PROJEKT-STATUS.md` §13 (Punkt C, Security-Baseline).

### 7. Monitoring und zentrales Logging *(Heading 1)*
- `avm/ptn/alz/ama:0.2.0`: Log Analytics Workspace `law-alz-<region>` (PerGB2018,
  365 Tage), 3 Data Collection Rules, Managed Identity, ChangeTracking.
  → Quelle: `PROJEKT-STATUS.md` §7, `templates/core/logging/main.bicepparam`.

### 8. Identity und RBAC *(Heading 1)*
- 5 Custom-Rollen, RBAC-Stufen (landingzones/platform/connectivity).
- Identity-Subscription/MG, Entra-ID-Anbindung (Roadmap-Hinweis).

### 9. Automatisierung, CI/CD und Betrieb *(Heading 1)*
- Bootstrap Phase 0 (Terraform): GitHub-Repo + OIDC + Pipelines.
  → Quelle: `ACCELERATOR-BOOTSTRAP.md`.
- Deployment via Pipelines mit What-If → Approval-Gate (`apply_approvers`).
- Betriebsmodell: GitOps, Pull-Request-Workflow, wiederholbare Deployments.

### 10. Kosten und Kostensteuerung *(Heading 1)*
- Default-Kostentabelle (≈ €5.800/Monat) mit Einzelposten. → `PROJEKT-STATUS.md` §4.
- Kostenarme Varianten: `network_type: none` (≈ €0) bzw. Dienste-Schalter aus.
- Empfehlung gestaffelt: Pilot kostenarm → schrittweise Aktivierung nach Bedarf.
- **DDoS-Hinweis** (teuerster Einzelposten, bewusst entscheiden).

### 11. Roadmap, Phasen und Gates *(Heading 1)*
- Phasenmodell (in Anlehnung an Bechtle-Vorlage):
  1. **Beratung/Kickoff** (Discovery, Anforderungen, Subscription-Strategie)
  2. **Bootstrap & Grundgerüst** (MGs + Policies im DoNotEnforce + Logging, kostenarm)
  3. **Netzwerk-Pilot** (Hub minimal, On-Prem-Anbindung prüfen)
  4. **Sicherheit & Enforcement** (Defender, Policies auf Enforce)
  5. **Workload-Onboarding** (erste Landing Zones / Spokes)
  6. **Betrieb & Optimierung** (Kosten, Monitoring, Weiterentwicklung)
- **Gates** je Phase (Entscheidungspunkte, What-If-Review, Approval).

### 12. Risiken, offene Punkte und Entscheidungsbedarf *(Heading 1)*
- Tabelle: Risiko / Auswirkung / Maßnahme.
- Offene Punkte aus `PROJEKT-STATUS.md` §13 (A1 DNS-Resolver, A2 Decommissioned-Guardrail,
  A3 Sandbox-Exemption, B Smoke Run, C Security-Baseline).
- Entscheidungsbedarf Kunde: Subscriptions-Modell, Region(en), Netzwerk-Typ,
  Enforcement-Zeitpunkt, DDoS ja/nein, On-Prem-Anbindung.

### 13. Ergänzende Randthemen und Abhängigkeiten *(Heading 1)*
> Muster wie Bechtle-Vorlage: je Thema *Zu prüfen / Mögliche Folgestufe / Abgrenzung*.
- **Entra ID / Identity** (Tenant-Struktur, PIM, Conditional Access).
- **On-Premises-Anbindung** (ExpressRoute/VPN, Bandbreite, IP-Planung).
- **Backup & DR** (Recovery Vaults, Geo-Redundanz).
- **Kostenmanagement** (Budgets, Tagging-Pflicht, Cost Alerts).
- **Compliance/Regulatorik** (Datenresidenz DE, branchenspezifisch).
- **Workload-Migration** (eigener Scope, nicht Teil ALZ-Grundaufbau).

### 14. Nächste Schritte und Empfehlung *(Heading 1)*
- Konkrete Sofort-Maßnahmen (Kickoff-Termin, Subscription bereitstellen, PAT erzeugen).
- Empfohlener kostenarmer Pilot-Pfad (Schritt-für-Schritt, Verweis Runbook).
- Angebot Bechtle: Begleitung Bootstrap + Pilot.

### Anhang *(Heading 1)*
- A: 18 Deployment-Stufen (Volltabelle). → `.config/ALZ-Powershell.config.json`.
- B: AVM-Modul-Liste mit Versionen. → `TECHNICAL-REFERENCE.md`.
- C: Glossar (ALZ, AVM, MG, Hub-Spoke, OIDC, DINE-Policy, DoNotEnforce …).
- D: Referenzen (Microsoft ALZ Docs, Accelerator, Repo).

---

## Hinweise zur Erzeugung (nächster Chat)

1. **Design:** Vorlage `bechtle-brand/VORLAGE_Bechtle_Management_Summary.docx` als Basis
   öffnen (erbt Stile/Theme/Logos/Header/Footer), Beispielinhalte ersetzen.
   Details: `bechtle-brand/BECHTLE-DESIGN.md`.
2. **Inhalte:** Fakten ausschließlich aus den oben genannten Repo-Quellen ziehen
   (Zahlen konsistent halten: 12 MGs, 123 Assignments, 149 Policies, 42 Initiativen,
   5 Rollen, 18 Stufen, ≈ €5.800/Monat Default).
3. **Output:** `docs/konzept/Azure-Landing-Zone-Konzept.docx`; optional Generator-Skript
   `docs/konzept/generate-konzept.py` (analog zu `docs/kickoff/generate*.py`).
4. **Tonalität:** beratend, entscheidungsorientiert, deutsch; Management Summary
   nicht-technisch, Detailkapitel technisch präzise.
5. **Platzhalter** `<KUNDE>` erst setzen, wenn der Kundenname final ist.
