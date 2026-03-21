REPORT zfix_userrole.

UPDATE zuserrole
  SET role_level = 'IT_ADMIN'
  WHERE user_id = 'DEV-098'.

IF sy-subrc = 0.
  WRITE: / 'Updated DEV-098 to IT ADMIN. Rows:', sy-dbcnt.
  COMMIT WORK.
ELSE.
  WRITE: / 'No record found for DEV-098'.
ENDIF.
