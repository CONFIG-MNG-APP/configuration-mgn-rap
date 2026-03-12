@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Config Catalog Projection'
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_CONF_CATALOG
  provider contract transactional_query
  as projection on ZI_CONF_CATALOG
{
  key ConfId,

      @EndUserText.label: 'Module'
      ModuleId,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      ConfName,

      @EndUserText.label: 'Configuration Type'
      ConfType,

      @Search.defaultSearchElement: true
      Description,

      @Search.defaultSearchElement: true
      TargetCds,

      IsActive,
      CreatedBy,
      CreatedAt,
      ChangedBy,
      ChangedAt,

      _FieldDef : redirected to composition child ZC_CONF_FIELD_DEF
}
