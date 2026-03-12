@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View - Route Request'
@Metadata.allowExtensions: true
define root view entity ZC_MM_ROUTE_REQ provider contract transactional_query 
  as projection on ZI_MM_ROUTE_REQ {
    key ReqId,
    ItemId,
    Action,
    ReqStatus,
    
    EnvId,
    PlantId,
    SendWh,
    ReceiveWh,
    InspectorId,
    TransMode,
    IsAllowed,
    VersionNo,
    
    CreatedBy,
    CreatedAt,
    ChangedBy,
    ChangedAt
}
