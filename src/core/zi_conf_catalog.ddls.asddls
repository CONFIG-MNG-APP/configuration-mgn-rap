@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Configuration Catalog Interface View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_CONF_CATALOG
  as select from zconfcatalog
  composition [0..*] of ZI_CONF_FIELD_DEF as _FieldDef
{
  key conf_id     as ConfId,
      module_id   as ModuleId,
      conf_name   as ConfName,
      conf_type   as ConfType,
      description as Description,
      target_cds  as TargetCds,
      is_active   as IsActive,

      @Semantics.user.createdBy: true
      created_by  as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at  as CreatedAt,
      @Semantics.user.lastChangedBy: true
      changed_by  as ChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      changed_at  as ChangedAt,

      _FieldDef
}
