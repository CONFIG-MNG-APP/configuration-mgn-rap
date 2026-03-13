@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'SD Price Request Configuration'
@Metadata.allowExtensions: true
@Search.searchable: true

define root view entity ZC_SD_PRICE_CONF
  provider contract transactional_query
  as projection on ZI_SD_PRICE_CONF
{
  key ReqId,
  key ReqItemId,
  key ItemId,

      SourceItemId,
      ConfId,
      ActionType,

      @EndUserText.label: 'Branch'
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      BranchId,

      @EndUserText.label: 'Environment'
      EnvId,

      @EndUserText.label: 'Customer Group'
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      CustGroup,

      @EndUserText.label: 'Material Group'
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      MaterialGrp,

      @EndUserText.label: 'Max Discount'
      @Semantics.amount.currencyCode: 'Currency'
      MaxDiscount,

      @EndUserText.label: 'Min Order Value'
      MinOrderVal,

      @EndUserText.label: 'Approver Group'
      ApproverGrp,

      Currency,
      ValidFrom,
      ValidTo,
      VersionNo,
      LineStatus,
      ChangeNote,

      OldBranchId,
      OldEnvId,
      OldCustGroup,
      OldMaterialGrp,

      @Semantics.amount.currencyCode: 'OldCurrency'
      OldMaxDiscount,

      OldMinOrderVal,
      OldApproverGrp,
      OldCurrency,
      OldValidFrom,
      OldValidTo,
      OldVersionNo,

      CreatedBy,
      CreatedAt,
      ChangedBy,
      ChangedAt,

      _Env,
      _OldEnv
}
