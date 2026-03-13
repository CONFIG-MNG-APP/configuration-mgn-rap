@EndUserText.label: 'Projection View for MM Safe Stock'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_MM_SAFE_STOCK
  provider contract transactional_query
  as projection on ZI_MM_SAFE_STOCK
{
  key ReqId,
  key ReqItemId,
  key ItemId,
      SourceItemId,
      ConfId,
      ActionType,

      EnvId,
      PlantId,
      MatGroup,
      MinQty,

      VersionNo,

      LineStatus,
      ChangeNote,

      OldEnvId,
      OldPlantId,
      OldMatGroup,
      OldMinQty,
      OldVersionNo,

      CreatedBy,
      CreatedAt,
      ChangedBy,
      ChangedAt,

      _Env,
      _OldEnv
}
