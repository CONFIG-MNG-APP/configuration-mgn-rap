@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'User Email - Projection View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZC_USER_MAIL
  provider contract transactional_query
  as projection on ZI_USER_MAIL
{
  key UserId,

  @EndUserText.label: 'Email Address'
  Email
}
