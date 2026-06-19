using './main.bicep'

// ================================================================ //
// ALZ RBAC – Role Assignments
//
// ANPASSEN: Object IDs der Entra-ID-Gruppen eintragen.
// Gruppen werden vom Kunden in Entra ID erstellt und gepflegt.
// Leeres Array = keine Assignments (No-Op, kein Deployment-Fehler).
//
// Voraussetzung: Stufe 1 (Governance Intermediate Root) muss
// bereits gelaufen sein, damit die ALZ-Custom-Rollen existieren.
// ================================================================ //

param parRoleAssignments = [

  // ── Platform-Admins ────────────────────────────────────────────
  // Vollständige Kontrolle über alle Plattform-Subscriptions.
  // Gruppe: z. B. "SG-ALZ-Platform-Admins"
  {
    managementGroupId: 'alz-platform'
    principalId:       '<OBJECT_ID_PLATFORM_ADMINS>'
    roleDefinition:    'Subscription-Owner'
    principalType:     'Group'
    description:       'Platform-Admins: Subscription-Owner auf alz-platform'
  }

  // ── Network-Team ───────────────────────────────────────────────
  // Verwaltung von VNets, NSGs, UDRs, Firewalls auf Plattformebene.
  // Gruppe: z. B. "SG-ALZ-Network-Team"
  {
    managementGroupId: 'alz-platform-connectivity'
    principalId:       '<OBJECT_ID_NETWORK_TEAM>'
    roleDefinition:    'Network-Management'
    principalType:     'Group'
    description:       'Network-Team: Network-Management auf alz-platform-connectivity'
  }

  // ── Security-Team ──────────────────────────────────────────────
  // Horizontale Sicherheitssicht über alle Subscriptions.
  // Gruppe: z. B. "SG-ALZ-Security-Ops"
  {
    managementGroupId: 'alz'
    principalId:       '<OBJECT_ID_SECURITY_TEAM>'
    roleDefinition:    'Security-Operations'
    principalType:     'Group'
    description:       'Security-Team: Security-Operations auf alz (Root)'
  }

  // ── App-Team A (Beispiel) ──────────────────────────────────────
  // Contributor-Rechte auf Resource-Group-Ebene für ein Applikations-Team.
  // Gruppe: z. B. "SG-ALZ-App-Team-A"
  {
    managementGroupId: 'alz-landingzones-corp'
    principalId:       '<OBJECT_ID_APP_TEAM_A>'
    roleDefinition:    'Application-Owners'
    principalType:     'Group'
    description:       'App-Team A: Application-Owners auf alz-landingzones-corp'
  }

  // ── Netzwerk-Ops (Subnet-Ebene) ────────────────────────────────
  // Granulare Subnet-Verwaltung ohne vollständige Netzwerk-Rechte.
  // Gruppe: z. B. "SG-ALZ-Network-Ops"
  {
    managementGroupId: 'alz-landingzones'
    principalId:       '<OBJECT_ID_NETWORK_OPS>'
    roleDefinition:    'Network-Subnet-Contributor'
    principalType:     'Group'
    description:       'Network-Ops: Network-Subnet-Contributor auf alz-landingzones'
  }

  // ── Read-Only (Beispiel für Audit/Compliance-Team) ─────────────
  // Built-in Reader auf Root-Ebene für Lesezugriff auf alles.
  // {
  //   managementGroupId: 'alz'
  //   principalId:       '<OBJECT_ID_AUDIT_TEAM>'
  //   roleDefinition:    'Reader'
  //   principalType:     'Group'
  //   description:       'Audit-Team: Reader auf alz (Root)'
  // }
]
