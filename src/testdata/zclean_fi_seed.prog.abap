REPORT zclean_fi_seed.

  SELECT item_id, req_id, env_id, expense_type, gl_account
    FROM zfilimitconf
    WHERE req_id = '00000000000000000000000000000000'
    INTO TABLE @DATA(lt_seed).

  IF lt_seed IS INITIAL.
    WRITE: / 'No seed data found. Nothing to delete.'.
    RETURN.
  ENDIF.

  WRITE: / |Found { lines( lt_seed ) } seed record(s):|.
  LOOP AT lt_seed INTO DATA(ls).
    WRITE: / |  { ls-env_id } / { ls-expense_type } / { ls-gl_account }|.
  ENDLOOP.

  DELETE FROM zfilimitconf WHERE req_id = '00000000000000000000000000000000'.
  COMMIT WORK.

  WRITE: / |Deleted { sy-dbcnt } record(s) from ZFILIMITCONF.|.
