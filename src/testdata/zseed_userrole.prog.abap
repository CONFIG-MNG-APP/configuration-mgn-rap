REPORT zseed_userrole.

SELECT SINGLE @abap_true FROM zuserrole INTO @DATA(lv_exists).
IF sy-subrc = 0.
  WRITE: / 'ZUSERROLE already has data. Skip.'.
  RETURN.
ENDIF.

DATA lt_roles TYPE STANDARD TABLE OF zuserrole.

" Current user = MANAGER (để test Approve/Reject)
APPEND VALUE zuserrole(
  client     = sy-mandt
  user_id    = sy-uname
  fullname   = 'Current Test User'
  module_id  = 'ALL'
  role_level = 'MANAGER'
  is_active  = abap_true
  org_access = '*'
) TO lt_roles.

INSERT zuserrole FROM TABLE @lt_roles.
COMMIT WORK.

WRITE: / |Seed done. Inserted { sy-dbcnt } row(s) into ZUSERROLE.|.
WRITE: / |User { sy-uname } assigned role MANAGER.|.
