@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MM Safe Stock Main Table (Read-Only)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #M,
    dataClass: #MIXED
}
define view entity ZC_MM_SAFE_STOCK_MAIN
  as select from zmmsafestock
{
  key item_id    as ItemId,
      req_id     as ReqId,
      env_id     as EnvId,
      plant_id   as PlantId,
      mat_group  as MatGroup,
      min_qty    as MinQty,
      version_no as VersionNo,
      created_by as CreatedBy,
      created_at as CreatedAt
}
