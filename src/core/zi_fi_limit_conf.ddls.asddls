@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'FI Expense Limit Configuration'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_FI_LIMIT_CONF
  as select from zfilimitreq
{
  key item_id       as ItemId,
      req_id        as ReqId,
      env_id        as EnvId,
      expense_type  as ExpenseType,
      gl_account    as GlAccount,
      @Semantics.amount.currencyCode: 'Currency'
      auto_appr_lim as AutoApprLim,
      currency      as Currency,
      version_no    as VersionNo,
      created_by    as CreatedBy,
      created_at    as CreatedAt,
      changed_by    as ChangedBy,
      changed_at    as ChangedAt
}
