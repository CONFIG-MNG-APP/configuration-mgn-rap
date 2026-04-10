*&---------------------------------------------------------------------*
*& Report zseed_mm_safestock
*& Seed baseline data for ZMMSAFESTOCK — 3 rows per record (DEV/QAS/PRD)
*& Each business key (plant_id + mat_group) must exist in all 3 envs
*& so that approve() UPDATE and promote() UPDATE have a target row.
*&---------------------------------------------------------------------*
REPORT zseed_mm_safe_stock.

DATA: lt_data TYPE STANDARD TABLE OF zmmsafestock,
      lv_ts   TYPE timestampl.

GET TIME STAMP FIELD lv_ts.

" Skip if main table already has data
SELECT SINGLE @abap_true FROM zmmsafestock INTO @DATA(lv_exists).
IF sy-subrc = 0.
  WRITE: / 'ZMMSAFESTOCK already has data. Skip.'.
  RETURN.
ENDIF.

" Clean req staging table
DELETE FROM zmmsafestock_req.

TRY.
    " ── Record 1: PL01 / FOOD ─────────────────────────────────────────
    APPEND VALUE zmmsafestock(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'DEV'  plant_id = 'PL01'  mat_group = 'FOOD'
      min_qty = '100'  version_no = 1
      created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.
    APPEND VALUE zmmsafestock(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'QAS'  plant_id = 'PL01'  mat_group = 'FOOD'
      min_qty = '100'  version_no = 1
      created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.
    APPEND VALUE zmmsafestock(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'PRD'  plant_id = 'PL01'  mat_group = 'FOOD'
      min_qty = '100'  version_no = 1
      created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.

    " ── Record 2: PL01 / ELEC ─────────────────────────────────────────
    APPEND VALUE zmmsafestock(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'DEV'  plant_id = 'PL01'  mat_group = 'ELEC'
      min_qty = '50'  version_no = 1
      created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.
    APPEND VALUE zmmsafestock(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'QAS'  plant_id = 'PL01'  mat_group = 'ELEC'
      min_qty = '50'  version_no = 1
      created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.
    APPEND VALUE zmmsafestock(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'PRD'  plant_id = 'PL01'  mat_group = 'ELEC'
      min_qty = '50'  version_no = 1
      created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.

    " ── Record 3: PL02 / CHEM ─────────────────────────────────────────
    APPEND VALUE zmmsafestock(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'DEV'  plant_id = 'PL02'  mat_group = 'CHEM'
      min_qty = '200'  version_no = 1
      created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.
    APPEND VALUE zmmsafestock(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'QAS'  plant_id = 'PL02'  mat_group = 'CHEM'
      min_qty = '200'  version_no = 1
      created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.
    APPEND VALUE zmmsafestock(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'PRD'  plant_id = 'PL02'  mat_group = 'CHEM'
      min_qty = '200'  version_no = 1
      created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.

    " ── Record 4: PL03 / PACK ─────────────────────────────────────────
    APPEND VALUE zmmsafestock(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'DEV'  plant_id = 'PL03'  mat_group = 'PACK'
      min_qty = '300'  version_no = 1
      created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.
    APPEND VALUE zmmsafestock(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'QAS'  plant_id = 'PL03'  mat_group = 'PACK'
      min_qty = '300'  version_no = 1
      created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.
    APPEND VALUE zmmsafestock(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'PRD'  plant_id = 'PL03'  mat_group = 'PACK'
      min_qty = '300'  version_no = 1
      created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.

  CATCH cx_uuid_error INTO DATA(lx_uuid).
    WRITE: / |UUID error: { lx_uuid->get_text( ) }|.
    RETURN.
ENDTRY.

INSERT zmmsafestock FROM TABLE @lt_data.
COMMIT WORK.

WRITE: / |Seed done. Inserted { sy-dbcnt } row(s) into ZMMSAFESTOCK (4 records x 3 envs).|.
