@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MM Route Configuration Projection'
@Metadata.allowExtensions: true

define root view entity ZC_MM_ROUTE_CONF
  provider contract transactional_query
  as projection on ZI_MM_ROUTE_CONF
{
  key ItemId,

      ReqId,

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

      @EndUserText.label: 'Created By'
      CreatedBy,

      @EndUserText.label: 'Created At'
      CreatedAt,

      @EndUserText.label: 'Changed By'
      ChangedBy,

      @EndUserText.label: 'Changed At'
      ChangedAt,
      _Env,
      _Plant
}
