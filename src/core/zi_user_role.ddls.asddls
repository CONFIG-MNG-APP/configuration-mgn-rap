@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'User Role - Interface View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_USER_ROLE
  as select from zuserrole
{
  key user_id    as UserId,
  key module_id  as ModuleId,
      role_level as RoleLevel,
      fullname   as Fullname,
      is_active  as IsActive,
      org_access as OrgAccess
}
