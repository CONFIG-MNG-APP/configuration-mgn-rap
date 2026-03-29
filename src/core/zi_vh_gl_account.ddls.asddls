@AbapCatalog.viewEnhancementCategory: [#NONE]                                                                                                           
  @AccessControl.authorizationCheck: #NOT_REQUIRED                                                                                                          @EndUserText.label: 'Value Help - GL Account'                                                                                                           
  @Metadata.ignorePropagatedAnnotations: true                                                                                                             
  @ObjectModel.usageType:{
      serviceQuality: #X,
      sizeCategory: #S,
      dataClass: #MIXED
  }
  define view entity ZI_VH_GL_ACCOUNT as select from zglaccount
  {
    key gl_account  as GlAccount,
        description as Description,
        is_active   as IsActive
  }
