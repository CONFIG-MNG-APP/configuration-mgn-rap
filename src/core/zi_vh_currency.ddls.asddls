@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help - Currency'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_VH_CURRENCY
  as select from I_Currency as c
  left outer join I_CurrencyText as t
    on  t.Currency = c.Currency
    and t.Language = 'E'
{
  key c.Currency,
      t.CurrencyName
}
