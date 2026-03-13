@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View - Price Configuration'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_SD_PRICE_CONF
  as select from zsd_price_req
  association [1..1] to ZI_ENV_DEF as _Env    on $projection.EnvId = _Env.EnvId
  association [1..1] to ZI_ENV_DEF as _OldEnv on $projection.OldEnvId = _OldEnv.EnvId
{
  key req_id            as ReqId,
  key req_item_id       as ReqItemId,
  key item_id           as ItemId,

      source_item_id    as SourceItemId,
      conf_id           as ConfId,
      action_type       as ActionType,

      branch_id         as BranchId,

      @EndUserText.label: 'Environment'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_ENV_DEF', element: 'EnvId' } }]
      env_id            as EnvId,

      cust_group        as CustGroup,
      material_grp      as MaterialGrp,

      @Semantics.amount.currencyCode: 'Currency'
      max_discount      as MaxDiscount,

      min_order_val     as MinOrderVal,
      approver_grp      as ApproverGrp,
      currency          as Currency,
      valid_from        as ValidFrom,
      valid_to          as ValidTo,
      version_no        as VersionNo,

      line_status       as LineStatus,
      change_note       as ChangeNote,

      // Old snapshot
      old_branch_id     as OldBranchId,
      old_env_id        as OldEnvId,
      old_cust_group    as OldCustGroup,
      old_material_grp  as OldMaterialGrp,

      @Semantics.amount.currencyCode: 'OldCurrency'
      old_max_discount  as OldMaxDiscount,

      old_min_order_val as OldMinOrderVal,
      old_approver_grp  as OldApproverGrp,
      old_currency      as OldCurrency,
      old_valid_from    as OldValidFrom,
      old_valid_to      as OldValidTo,
      old_version_no    as OldVersionNo,

      @Semantics.user.createdBy: true
      created_by        as CreatedBy,

      @Semantics.systemDateTime.createdAt: true
      created_at        as CreatedAt,

      @Semantics.user.lastChangedBy: true
      changed_by        as ChangedBy,

      @Semantics.systemDateTime.lastChangedAt: true
      changed_at        as ChangedAt,

      _Env,
      _OldEnv
}
