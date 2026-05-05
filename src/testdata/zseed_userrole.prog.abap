*&---------------------------------------------------------------------*
*& Report zseed_userrole
*&---------------------------------------------------------------------*
*& Seed test data for ZUSERROLE (compound key: user_id + module_id)
*& Run AFTER activating the updated table definition
*&---------------------------------------------------------------------*
REPORT zseed_userrole.

DATA lt_roles TYPE TABLE OF zuserrole.
DATA ls_role  TYPE zuserrole.

" ── Helper macro ────────────────────────────────────────────────────
DEFINE add_role.
  CLEAR ls_role.
  ls_role-user_id    = &1.
  ls_role-module_id  = &2.
  ls_role-role_level = &3.
  ls_role-fullname   = &4.
  ls_role-is_active  = abap_true.
  ls_role-org_access = '*'.
  APPEND ls_role TO lt_roles.
END-OF-DEFINITION.

" ── Test data: 1 user per role type per module ──────────────────────
" KEY USER: can create/submit requests
add_role sy-uname   'FI' 'KEY USER' 'Current User (FI Key User)'.
add_role 'KEYUSER1' 'FI' 'KEY USER' 'FI Key User'.
add_role 'KEYUSER2' 'MM' 'KEY USER' 'MM Key User'.
add_role 'KEYUSER3' 'SD' 'KEY USER' 'SD Key User'.

" MANAGER: can approve/reject requests
add_role 'MANAGER1' 'FI' 'MANAGER'  'FI Manager'.
add_role 'MANAGER2' 'MM' 'MANAGER'  'MM Manager'.
add_role 'MANAGER3' 'SD' 'MANAGER'  'SD Manager'.

" IT_ADMIN: can promote/rollback/apply configs
add_role 'ITADMIN1' 'ALL' 'IT ADMIN' 'IT Admin'.

" ── SoD example: same user, different modules ───────────────────────
add_role 'MULTIUSER' 'FI' 'KEY USER' 'Multi-Module User'.
add_role 'MULTIUSER' 'MM' 'MANAGER'  'Multi-Module User'.

" ── Delete existing and re-insert ───────────────────────────────────
DELETE FROM zuserrole.
INSERT zuserrole FROM TABLE @lt_roles.
COMMIT WORK.

IF sy-subrc = 0.
  WRITE: / |Done. { lines( lt_roles ) } role records inserted.|.
  LOOP AT lt_roles INTO ls_role.
    WRITE: / |  { ls_role-user_id } / { ls_role-module_id } → { ls_role-role_level }|.
  ENDLOOP.
ELSE.
  WRITE: / |Error inserting roles. sy-subrc = { sy-subrc }.|.
ENDIF.
