*&---------------------------------------------------------------------*
*& Report zseed_fi_limit
*& Seed baseline data for ZFILIMITCONF — 3 rows per record (DEV/QAS/PRD)
*& Each business key (expense_type + gl_account) must exist in all 3 envs
*& so that approve() UPDATE and promote() UPDATE have a target row.
*&---------------------------------------------------------------------*
REPORT zseed_fi_limit.

DATA: lt_data TYPE STANDARD TABLE OF zfilimitconf,
      lv_ts   TYPE timestampl.

GET TIME STAMP FIELD lv_ts.

" Skip if main table already has data
SELECT SINGLE @abap_true FROM zfilimitconf INTO @DATA(lv_exists).
IF sy-subrc = 0.
  WRITE: / 'ZFILIMITCONF already has data. Skip.'.
  RETURN.
ENDIF.

TRY.
    " ── Record 1: TRAVEL / 600100 ─────────────────────────────────────
    APPEND VALUE zfilimitconf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'DEV'  expense_type = 'TRAVEL'  gl_account = '600100'
      auto_appr_lim = '5000.00'  currency = 'VND'  version_no = 1
      created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.
    APPEND VALUE zfilimitconf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'QAS'  expense_type = 'TRAVEL'  gl_account = '600100'
      auto_appr_lim = '5000.00'  currency = 'VND'  version_no = 1
      created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.
    APPEND VALUE zfilimitconf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'PRD'  expense_type = 'TRAVEL'  gl_account = '600100'
      auto_appr_lim = '5000.00'  currency = 'VND'  version_no = 1
      created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.

    " ── Record 2: OFFICE / 600200 ─────────────────────────────────────
    APPEND VALUE zfilimitconf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'DEV'  expense_type = 'OFFICE'  gl_account = '600200'
      auto_appr_lim = '2000.00'  currency = 'VND'  version_no = 1
      created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.
    APPEND VALUE zfilimitconf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'QAS'  expense_type = 'OFFICE'  gl_account = '600200'
      auto_appr_lim = '2000.00'  currency = 'VND'  version_no = 1
      created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.
    APPEND VALUE zfilimitconf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'PRD'  expense_type = 'OFFICE'  gl_account = '600200'
      auto_appr_lim = '2000.00'  currency = 'VND'  version_no = 1
      created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.

    " ── Record 3: ENTERTAIN / 600300 ──────────────────────────────────
    APPEND VALUE zfilimitconf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'DEV'  expense_type = 'ENTERTAIN'  gl_account = '600300'
      auto_appr_lim = '10000.00'  currency = 'VND'  version_no = 1
      created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.
    APPEND VALUE zfilimitconf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'QAS'  expense_type = 'ENTERTAIN'  gl_account = '600300'
      auto_appr_lim = '10000.00'  currency = 'VND'  version_no = 1
      created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.
    APPEND VALUE zfilimitconf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'PRD'  expense_type = 'ENTERTAIN'  gl_account = '600300'
      auto_appr_lim = '10000.00'  currency = 'VND'  version_no = 1
      created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.

    " ── Record 4: TRAINING / 600400 ───────────────────────────────────
    APPEND VALUE zfilimitconf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'DEV'  expense_type = 'TRAINING'  gl_account = '600400'
      auto_appr_lim = '15000.00'  currency = 'VND'  version_no = 1
      created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.
    APPEND VALUE zfilimitconf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'QAS'  expense_type = 'TRAINING'  gl_account = '600400'
      auto_appr_lim = '15000.00'  currency = 'VND'  version_no = 1
      created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.
    APPEND VALUE zfilimitconf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'PRD'  expense_type = 'TRAINING'  gl_account = '600400'
      auto_appr_lim = '15000.00'  currency = 'VND'  version_no = 1
      created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.

  CATCH cx_uuid_error INTO DATA(lx_uuid).
    WRITE: / |UUID error: { lx_uuid->get_text( ) }|.
    RETURN.
ENDTRY.

INSERT zfilimitconf FROM TABLE @lt_data.
COMMIT WORK.

WRITE: / |Seed done. Inserted { sy-dbcnt } row(s) into ZFILIMITCONF (4 records x 3 envs).|.
