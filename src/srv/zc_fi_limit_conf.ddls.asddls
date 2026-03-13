@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'FI Limit Request Configuration'
@Metadata.allowExtensions: true
@Search.searchable: true

define root view entity ZC_FI_LIMIT_CONF
  provider contract transactional_query
  as projection on ZI_FI_LIMIT_CONF
{
  key ReqId,
  key ReqItemId,
  key ItemId,

      SourceItemId,
      ConfId,
      ActionType,

      @EndUserText.label: 'Environment'
      EnvId,

      @EndUserText.label: 'Expense Type'
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      ExpenseType,

      @EndUserText.label: 'G/L Account'
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      GlAccount,

      @EndUserText.label: 'Auto Approval Limit'
      @Semantics.amount.currencyCode: 'Currency'
      AutoApprLim,

      Currency,
      VersionNo,
      LineStatus,
      ChangeNote,

      OldEnvId,
      OldExpenseType,
      OldGlAccount,

      @Semantics.amount.currencyCode: 'OldCurrency'
      OldAutoApprLim,

      OldCurrency,
      OldVersionNo,

      CreatedBy,
      CreatedAt,
      ChangedBy,
      ChangedAt,

      _Env,
      _OldEnv
}
