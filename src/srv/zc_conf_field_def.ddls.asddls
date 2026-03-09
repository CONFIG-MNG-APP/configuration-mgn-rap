@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Field Definition Projection View'
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_CONF_FIELD_DEF
  as projection on ZI_CONF_FIELD_DEF
{
  key ConfId,
  key FieldName,
      FieldLabel,
      DataType,
      IsRequired,
      ValueHelpType,

      _Catalog : redirected to parent ZC_CONF_CATALOG
}
