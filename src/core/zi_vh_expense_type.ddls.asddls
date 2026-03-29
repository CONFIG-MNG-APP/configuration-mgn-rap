 @AbapCatalog.viewEnhancementCategory: [#NONE]
  @AccessControl.authorizationCheck: #NOT_REQUIRED
  @EndUserText.label: 'Value Help - Expense Type'
  @Metadata.ignorePropagatedAnnotations: true
  @ObjectModel.usageType:{
      serviceQuality: #X,
      sizeCategory: #S,
      dataClass: #MIXED
  }
  define view entity ZI_VH_EXPENSE_TYPE as select from zexpensetype
  {
    key expense_type as ExpenseType,
        description  as Description,
        is_active    as IsActive
  }
