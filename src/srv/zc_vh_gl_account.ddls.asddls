@AbapCatalog.viewEnhancementCategory: [#NONE]                                                                                                           
  @AccessControl.authorizationCheck: #NOT_REQUIRED
  @EndUserText.label: 'Consumption - GL Account Value Help'
  @Metadata.ignorePropagatedAnnotations: true
  @ObjectModel.usageType:{
      serviceQuality: #X,
      sizeCategory: #S,
      dataClass: #MIXED
  }
  define view entity ZC_VH_GL_ACCOUNT as select from ZI_VH_GL_ACCOUNT
  {
    key GlAccount,
        Description
  }
