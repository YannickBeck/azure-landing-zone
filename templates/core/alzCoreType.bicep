// ================ //
// Definitions
// ================ //

@export()
type alzCoreType = {
  @description('Optional. Boolean to create or update the management group.')
  createOrUpdateManagementGroup: bool

  @description('The name of the management group to create or update.')
  managementGroupName: string?

  @description('The display name of the management group to create or update.')
  managementGroupDisplayName: string?

  @description('Policy assignments to set to DoNotEnforce mode.')
  managementGroupDoNotEnforcePolicyAssignments: array?

  @description('Policy assignments to exclude from the management group.')
  managementGroupExcludedPolicyAssignments: array?

  @description('The parent management group ID. Defaults to tenant root if not specified.')
  managementGroupParentId: string?

  @description('The intermediate root management group name for replacing resource IDs.')
  managementGroupIntermediateRootName: string?

  @description('Optional. Additional customer provided RBAC role definitions.')
  customerRbacRoleDefs: array?

  @description('Optional. Customer provided RBAC role assignments for the management group.')
  customerRbacRoleAssignments: array?

  @description('Optional. Additional customer provided policy definitions.')
  customerPolicyDefs: array?

  @description('Optional. Additional customer provided policy set definitions.')
  customerPolicySetDefs: array?

  @description('Optional. Customer provided policy assignments.')
  customerPolicyAssignments: array?

  @description('Optional. Subscription IDs to place in the management group.')
  subscriptionsToPlaceInManagementGroup: array?

  @description('Optional. Consistency wait counter before custom policy definitions.')
  waitForConsistencyCounterBeforeCustomPolicyDefinitions: int?

  @description('Optional. Consistency wait counter before custom policy set definitions.')
  waitForConsistencyCounterBeforeCustomPolicySetDefinitions: int?

  @description('Optional. Consistency wait counter before custom role definitions.')
  waitForConsistencyCounterBeforeCustomRoleDefinitions: int?

  @description('Optional. Consistency wait counter before policy assignments.')
  waitForConsistencyCounterBeforePolicyAssignments: int?

  @description('Optional. Consistency wait counter before role assignments.')
  waitForConsistencyCounterBeforeRoleAssignments: int?

  @description('Optional. Consistency wait counter before sub placement.')
  waitForConsistencyCounterBeforeSubPlacement: int?
}
