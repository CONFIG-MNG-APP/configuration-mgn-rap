@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MM Route Configuration Projection'
@Metadata.allowExtensions: true
@Search.searchable: true

define root view entity ZC_MM_ROUTE_CONF
  provider contract transactional_query
  as projection on ZI_MM_ROUTE_CONF
{
  key ReqId,
  key ReqItemId,
  key ItemId,

      SourceItemId,
      ConfId,
      ActionType,

      @EndUserText.label: 'Environment'
      EnvId,

      @EndUserText.label: 'Plant'
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      PlantId,

      @EndUserText.label: 'Sending Warehouse'
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      SendWh,

      @EndUserText.label: 'Receiving Warehouse'
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      ReceiveWh,

      @EndUserText.label: 'Inspector'
      @Search.defaultSearchElement: true
      InspectorId,

      @EndUserText.label: 'Transport Mode'
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      TransMode,

      @EndUserText.label: 'Allowed'
      IsAllowed,

      @EndUserText.label: 'Version'
      VersionNo,

      @EndUserText.label: 'Line Status'
      LineStatus,

      @EndUserText.label: 'Change Note'
      ChangeNote,

      // Compare fields
      OldEnvId,
      OldPlantId,
      OldSendWh,
      OldReceiveWh,
      OldInspectorId,
      OldTransMode,
      OldIsAllowed,
      OldVersionNo,

      CreatedBy,
      CreatedAt,
      ChangedBy,
      ChangedAt,

      _Env,
      _Plant,
      _OldEnv,
      _OldPlant
}
