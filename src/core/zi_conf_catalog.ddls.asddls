@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Configuration Catalog Interface View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_CONF_CATALOG
  as select from zconfcatalog
  composition [0..*] of ZI_CONF_FIELD_DEF as _FieldDef
{
  key conf_id     as ConfId,
      @ObjectModel.text.element: ['ModuleText']
      module_id   as ModuleId,

      case module_id
        when 'MM'     then 'Materials Management'
        when 'SD'     then 'Sales & Distribution'
        when 'FI'     then 'Finance'
        when 'GEN'    then 'Generic Configuration'
        when 'TECH'   then 'Technical/System'
        when 'CUSTOM' then 'Custom/Extension'
        else module_id
      end         as ModuleText,

      conf_name   as ConfName,

      @ObjectModel.text.element: ['ConfTypeText']
      conf_type   as ConfType,

      case conf_type
        when 'TABLE' then 'Table Configuration'
        when 'API'   then 'API Configuration'
        when 'PARAM' then 'Parameter Configuration'
        else conf_type
      end         as ConfTypeText,

      description as Description,

      target_cds  as TargetCds,

      case target_cds
        when 'ZI_MM_ROUTE_CONF' then 'ZMMRouteConf'
        when 'ZI_MM_SAFE_STOCK' then 'ZMMSafeStock'
        when 'ZI_SD_PRICE_CONF' then 'ZSDPriceConf'
        when 'ZI_FI_LIMIT_CONF' then 'ZFILimitConf'
        else ''
      end         as SemanticObject,

      case target_cds
        when 'ZI_MM_ROUTE_CONF' then 'manage'
        when 'ZI_MM_SAFE_STOCK' then 'manage'
        when 'ZI_SD_PRICE_CONF' then 'manage'
        when 'ZI_FI_LIMIT_CONF' then 'manage'
        else ''
      end         as SemanticAction,

      is_active   as IsActive,
      case
      when is_active = 'X' then 3
      else 1
      end         as ActiveCriticality,


      /* Admin Data */
      @Semantics.user.createdBy: true
      created_by  as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at  as CreatedAt,
      @Semantics.user.lastChangedBy: true
      changed_by  as ChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      changed_at  as ChangedAt,

      /* Associations */
      _FieldDef
}
