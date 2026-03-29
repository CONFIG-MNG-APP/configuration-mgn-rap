@AbapCatalog.viewEnhancementCategory: [#NONE]
  @AccessControl.authorizationCheck: #NOT_REQUIRED
  @EndUserText.label: 'Consumption - Expense Type Value Help'
  @Metadata.ignorePropagatedAnnotations: true
  @ObjectModel.usageType:{
      serviceQuality: #X,
      sizeCategory: #S,
      dataClass: #MIXED
  }
  define view entity ZC_VH_EXPENSE_TYPE as select from ZI_VH_EXPENSE_TYPE
  {
    key ExpenseType,
        Description
  }
