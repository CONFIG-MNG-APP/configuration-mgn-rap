@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Current User Role Info'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZI_CURRENT_USER_ROLE
  as select from zuserrole
{
  key user_id    as UserId,
  key module_id  as ModuleId,
      role_level as RoleLevel,
      is_active  as IsActive,
      org_access as OrgAccess,


      cast(
        case when user_id = $session.user then 'X' else ' ' end
        as abap.char( 1 )
      )          as IsCurrentUser
}


      // Backend tự tính: row này có thuộc về session user không?
      // Frontend filter bằng IsCurrentUser eq 'X' thay vì cần biết username
