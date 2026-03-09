@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View - Route Configuration'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_MM_ROUTE_CONF
  as select from zmmrouteconf

  association [1..1] to ZI_ENV_DEF    as _Env   on $projection.EnvId = _Env.EnvId
  association [0..1] to ZI_PLANT_UNIT as _Plant on $projection.PlantId = _Plant.PlantId
{
  key item_id      as ItemId,

      req_id       as ReqId,

      @EndUserText.label: 'Environment'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_ENV_DEF', element: 'EnvId' } }]
      env_id       as EnvId,

      @EndUserText.label: 'Plant'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_PLANT_UNIT', element: 'PlantId' } }]
      plant_id     as PlantId,

      send_wh      as SendWh,
      receive_wh   as ReceiveWh,
      inspector_id as InspectorId,
      trans_mode   as TransMode,
      is_allowed   as IsAllowed,
      version_no   as VersionNo,

      /* Admin */
      @Semantics.user.createdBy: true
      created_by   as CreatedBy,

      @Semantics.systemDateTime.createdAt: true
      created_at   as CreatedAt,

      @Semantics.user.lastChangedBy: true
      changed_by   as ChangedBy,

      @Semantics.systemDateTime.lastChangedAt: true
      changed_at   as ChangedAt,

      _Env,
      _Plant
}
