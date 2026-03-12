@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'SD Price Configuration Projection'
@Metadata.allowExtensions: true

define root view entity ZC_SD_PRICE_CONF
  provider contract transactional_query
  as projection on ZI_SD_PRICE_CONF
{
  key ItemId,

      ReqId,

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
      MaxDiscount,

      @EndUserText.label: 'Min Order Value'
      MinOrderVal,

      @EndUserText.label: 'Approver Group'
      ApproverGrp,

      @EndUserText.label: 'Currency'
      Currency,

      @EndUserText.label: 'Valid From'
      ValidFrom,

      @EndUserText.label: 'Valid To'
      ValidTo,

      @EndUserText.label: 'Version'
      VersionNo,

      @EndUserText.label: 'Created By'
      CreatedBy,

      @EndUserText.label: 'Created At'
      CreatedAt,

      @EndUserText.label: 'Changed By'
      ChangedBy,

      @EndUserText.label: 'Changed At'
      ChangedAt
}
