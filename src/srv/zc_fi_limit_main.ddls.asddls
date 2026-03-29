@AbapCatalog.viewEnhancementCategory: [#NONE]
  @AccessControl.authorizationCheck: #NOT_REQUIRED
  @EndUserText.label: 'FI Limit Main Table (Read-Only Display)'
  @Metadata.ignorePropagatedAnnotations: true
  @ObjectModel.usageType:{
      serviceQuality: #X,
      sizeCategory: #M,
      dataClass: #MIXED
  }
  define view entity ZC_FI_LIMIT_MAIN
    as select from zfilimitconf
  {
    key item_id       as ItemId,
        req_id as ReqId,    
        env_id        as EnvId,
        expense_type  as ExpenseType,
        gl_account    as GlAccount,
        auto_appr_lim as AutoApprLim,
        currency      as Currency,
        version_no    as VersionNo,
        created_by     as CreatedBy,
      created_at     as CreatedAt
  }
