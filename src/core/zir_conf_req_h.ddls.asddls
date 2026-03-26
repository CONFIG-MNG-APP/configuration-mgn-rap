@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Conf Req Header (Interface)'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZIR_CONF_REQ_H
  as select from zconfreqh as h
     left outer join zuserrole as r
       on  r.user_id   = $session.user
       and r.is_active = 'X'

  composition [0..*] of ZI_CONF_REQ_I   as _Items

  association [0..1] to ZI_ENV_DEF      as _Env     on $projection.EnvId = _Env.EnvId

  association [0..1] to ZI_CONF_CATALOG as _Catalog on $projection.ConfId = _Catalog.ConfId
{

  key h.req_id            as ReqId,
      h.conf_id           as ConfId,
      h.env_id            as EnvId,
      h.module_id         as ModuleId,
      h.req_title         as ReqTitle,
      h.description       as Description,
      h.status            as Status,
      case h.status
        when 'S' then 2 -- Màu vàng: Chờ duyệt (Submitted)
        when 'A' then 3 -- Màu xanh lá: Đã duyệt (Approved)
        when 'R' then 1 -- Màu đỏ: Từ chối (Rejected)
        else 0          -- Không màu/Xám: Nháp (Draft)
      end                 as StatusCriticality,
      h.reason            as Reason,

      _Catalog.ConfName   as ConfName,
      _Catalog.TargetCds  as TargetCds,

      /* Admin */
      @Semantics.user.createdBy: true
      h.created_by        as CreatedBy,

      @Semantics.systemDateTime.createdAt: true
      h.created_at        as CreatedAt,

      @Semantics.user.lastChangedBy: true
      h.changed_by        as ChangedBy,

      @Semantics.systemDateTime.lastChangedAt: true
      h.changed_at        as ChangedAt,

      h.approved_by       as ApprovedBy,
      h.approved_at       as ApprovedAt,

      h.rejected_by       as RejectedBy,
      h.rejected_at       as RejectedAt,

      _Items,
      _Env
}
where h.created_by = $session.user   -- Key User: chỉ thấy request của mình
   or r.role_level  = 'MANAGER'      -- Manager: thấy tất cả
   or r.role_level  = 'IT ADMIN'     -- IT Admin: thấy tất cả
