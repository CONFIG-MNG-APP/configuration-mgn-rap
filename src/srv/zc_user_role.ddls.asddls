@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'User Role - Projection View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZC_USER_ROLE
  provider contract transactional_query
  as projection on ZI_USER_ROLE
{
  key UserId,

  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_VH_MODULE', element: 'ModuleId' } }]
  @EndUserText.label: 'Module'
  key ModuleId,

  @EndUserText.label: 'Role Level'
  RoleLevel,

  @Search.defaultSearchElement: true
  Fullname,

  @EndUserText.label: 'Active'
  IsActive,

  OrgAccess
}
