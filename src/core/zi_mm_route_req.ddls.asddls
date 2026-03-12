@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View - Route Request'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_MM_ROUTE_REQ as select from zmmreq_route {
  key req_id as ReqId,
  item_id as ItemId,
  action as Action,
  status as ReqStatus,
  
  // --- Data Fields ---
  env_id as EnvId,
  plant_id as PlantId,
  send_wh as SendWh,
  receive_wh as ReceiveWh,
  inspector_id as InspectorId,
  trans_mode as TransMode,
  is_allowed as IsAllowed,
  version_no as VersionNo,
  // --- Admin Fields ---
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  changed_by as ChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  changed_at as ChangedAt
}
