*&---------------------------------------------------------------------*
*& Report zset_userrole_manager
*&---------------------------------------------------------------------*
REPORT zset_userrole_manager.

CONSTANTS: lc_user_id   TYPE syuname        VALUE 'DEV-103',
           lc_fullname  TYPE c LENGTH 50    VALUE 'DEV-103',
           lc_module_id TYPE zde_module_id  VALUE 'ALL',
           lc_role      TYPE zde_role_level VALUE 'MANAGER'.

" Delete all existing rows for this user to avoid stale compound key entries
DELETE FROM zuserrole WHERE user_id = @lc_user_id.

" Insert fresh record with correct compound key
DATA(ls_role) = VALUE zuserrole(
  user_id    = lc_user_id
  fullname   = lc_fullname
  module_id  = lc_module_id
  role_level = lc_role
  is_active  = abap_true
  org_access = '*' ).

INSERT zuserrole FROM @ls_role.

IF sy-subrc = 0.
  COMMIT WORK.
  WRITE: / |OK — { lc_user_id } ({ lc_fullname }) → module={ lc_module_id }, role={ lc_role }.|.
ELSE.
  ROLLBACK WORK.
  WRITE: / |ERROR — INSERT failed. sy-subrc = { sy-subrc }.|.
ENDIF.
