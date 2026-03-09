@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Conf Req Header (Interface)'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZIR_CONF_REQ_H
  as select from zconfreqh

  composition [0..*] of ZI_CONF_REQ_I as _Items

  association [0..1] to ZI_ENV_DEF     as _Env on $projection.EnvId  = _Env.EnvId
{

  key req_id      as ReqId,

      env_id      as EnvId,
      module_id   as ModuleId,
      req_title   as ReqTitle,
      description as Description,
      status      as Status,
      reason      as Reason,

             /* Status Criticality for UI coloring */
      case status
        when 'D' then 0   -- Draft (Grey)
        when 'S' then 2   -- Submitted (Yellow)
        when 'A' then 3   -- Approved/Active (Green)
        when 'R' then 1   -- Rejected (Red)
        else 0
      end               as StatusCriticality,



      /* Admin */
      @Semantics.user.createdBy: true
      created_by  as CreatedBy,

      @Semantics.systemDateTime.createdAt: true
      created_at  as CreatedAt,

      @Semantics.user.lastChangedBy: true
      changed_by  as ChangedBy,

      @Semantics.systemDateTime.lastChangedAt: true
      changed_at  as ChangedAt,

      approved_by as ApprovedBy,
      approved_at as ApprovedAt,
      
      rejected_by as RejectedBy,
      rejected_at as RejectedAt,

      _Items,
      _Env
}
