using './main.bicep'

// ===============================================================
// ANPASSEN: Object IDs der Entra-ID-Gruppen eintragen.
// Leeres Array = es werden keine Role Assignments erstellt.
// Deployment-Scope: Tenant
// ===============================================================

param parRoleAssignments = [
  // Beispiel:
  // {
  //   managementGroupId: 'alz-platform'
  //   principalId: '<ENTRA_GROUP_OBJECT_ID>'
  //   roleDefinition: 'Owner'
  //   principalType: 'Group'
  //   description: 'Platform-Team: Owner auf der Platform-MG'
  // }
  // {
  //   managementGroupId: 'alz-landingzones'
  //   principalId: '<ENTRA_GROUP_OBJECT_ID>'
  //   roleDefinition: 'Contributor'
  //   principalType: 'Group'
  //   description: 'Workload-Teams: Contributor auf den Landing Zones'
  // }
]
