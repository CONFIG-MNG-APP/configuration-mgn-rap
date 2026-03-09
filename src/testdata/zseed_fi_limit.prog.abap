REPORT zseed_fi_limit.

DATA: lt_data TYPE STANDARD TABLE OF zfilimitconf,
      lv_ts   TYPE timestampl.

GET TIME STAMP FIELD lv_ts.

SELECT SINGLE @abap_true FROM zfilimitconf INTO @DATA(lv_exists).
IF sy-subrc = 0.
  WRITE: / 'ZFILIMITCONF already has data. Skip.'.
  RETURN.
ENDIF.

TRY.
    " 1) Travel expense limit
    APPEND VALUE zfilimitconf(
      client      = sy-mandt
      item_id     = cl_system_uuid=>create_uuid_x16_static( )
      env_id      = 'DEV'
      expense_type = 'TRAVEL'
      gl_account  = '600100'
      auto_appr_lim = '5000.00'
      currency    = 'VND'
      version_no  = 1
      created_by  = sy-uname
      created_at  = lv_ts
      changed_by  = sy-uname
      changed_at  = lv_ts
    ) TO lt_data.

    " 2) Office supply limit
    APPEND VALUE zfilimitconf(
      client      = sy-mandt
      item_id     = cl_system_uuid=>create_uuid_x16_static( )
      env_id      = 'DEV'
      expense_type = 'OFFICE'
      gl_account  = '600200'
      auto_appr_lim = '2000.00'
      currency    = 'VND'
      version_no  = 1
      created_by  = sy-uname
      created_at  = lv_ts
      changed_by  = sy-uname
      changed_at  = lv_ts
    ) TO lt_data.

    " 3) Entertainment limit
    APPEND VALUE zfilimitconf(
      client      = sy-mandt
      item_id     = cl_system_uuid=>create_uuid_x16_static( )
      env_id      = 'QAS'
      expense_type = 'ENTERTAIN'
      gl_account  = '600300'
      auto_appr_lim = '10000.00'
      currency    = 'VND'
      version_no  = 1
      created_by  = sy-uname
      created_at  = lv_ts
      changed_by  = sy-uname
      changed_at  = lv_ts
    ) TO lt_data.

    " 4) Training limit
    APPEND VALUE zfilimitconf(
      client      = sy-mandt
      item_id     = cl_system_uuid=>create_uuid_x16_static( )
      env_id      = 'PRD'
      expense_type = 'TRAINING'
      gl_account  = '600400'
      auto_appr_lim = '15000.00'
      currency    = 'VND'
      version_no  = 1
      created_by  = sy-uname
      created_at  = lv_ts
      changed_by  = sy-uname
      changed_at  = lv_ts
    ) TO lt_data.

  CATCH cx_uuid_error INTO DATA(lx_uuid).
    WRITE: / |UUID error: { lx_uuid->get_text( ) }|.
    RETURN.
ENDTRY.

INSERT zfilimitconf FROM TABLE @lt_data.
COMMIT WORK.

WRITE: / |Seed done. Inserted { sy-dbcnt } row(s) into ZFILIMITCONF.|.
