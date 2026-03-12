@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View - Price Configuration'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_SD_PRICE_CONF
  as select from zsd_price_req
{
  key item_id       as ItemId,
      req_id        as ReqId,
      branch_id     as BranchId,
      env_id        as EnvId,
      cust_group    as CustGroup,
      material_grp  as MaterialGrp,
      @Semantics.amount.currencyCode: 'Currency'
      max_discount  as MaxDiscount,
      min_order_val as MinOrderVal,
      approver_grp  as ApproverGrp,
      currency      as Currency,
      valid_from    as ValidFrom,
      valid_to      as ValidTo,
      version_no    as VersionNo,
      created_by    as CreatedBy,
      created_at    as CreatedAt,
      changed_by    as ChangedBy,
      changed_at    as ChangedAt
}
