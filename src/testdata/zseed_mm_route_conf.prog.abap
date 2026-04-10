*&---------------------------------------------------------------------*
*& Report zseed_mm_route_conf
*& Seed baseline data for ZMMROUTECONF — 3 rows per record (DEV/QAS/PRD)
*& Each business key (plant+send_wh+receive_wh) must exist in all 3 envs
*& so that approve() UPDATE and promote() UPDATE have a target row.
*&---------------------------------------------------------------------*
REPORT zseed_mm_route_conf.

DATA: lt_data TYPE STANDARD TABLE OF zmmrouteconf,
      lv_ts   TYPE timestampl.

GET TIME STAMP FIELD lv_ts.

" Skip if main table already has data
SELECT SINGLE @abap_true FROM zmmrouteconf INTO @DATA(lv_exists).
IF sy-subrc = 0.
  WRITE: / 'ZMMROUTECONF already has data. Skip.'.
  RETURN.
ENDIF.

" Clean req staging table
DELETE FROM zmmrouteconf_req.

TRY.
    " ── Record 1: PL01 / WH-A01 → WH-B01 ─────────────────────────────
    " DEV
    APPEND VALUE zmmrouteconf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'DEV'  plant_id = 'PL01'  send_wh = 'WH-A01'  receive_wh = 'WH-B01'
      trans_mode = 'TRUCK'  is_allowed = abap_true  inspector_id = ''
      version_no = 1  created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.
    " QAS
    APPEND VALUE zmmrouteconf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'QAS'  plant_id = 'PL01'  send_wh = 'WH-A01'  receive_wh = 'WH-B01'
      trans_mode = 'TRUCK'  is_allowed = abap_true  inspector_id = ''
      version_no = 1  created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.
    " PRD
    APPEND VALUE zmmrouteconf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'PRD'  plant_id = 'PL01'  send_wh = 'WH-A01'  receive_wh = 'WH-B01'
      trans_mode = 'TRUCK'  is_allowed = abap_true  inspector_id = ''
      version_no = 1  created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.

    " ── Record 2: PL01 / WH-A01 → WH-C01 ─────────────────────────────
    " DEV
    APPEND VALUE zmmrouteconf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'DEV'  plant_id = 'PL01'  send_wh = 'WH-A01'  receive_wh = 'WH-C01'
      trans_mode = 'RAIL'  is_allowed = abap_true  inspector_id = ''
      version_no = 1  created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.
    " QAS
    APPEND VALUE zmmrouteconf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'QAS'  plant_id = 'PL01'  send_wh = 'WH-A01'  receive_wh = 'WH-C01'
      trans_mode = 'RAIL'  is_allowed = abap_true  inspector_id = ''
      version_no = 1  created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.
    " PRD
    APPEND VALUE zmmrouteconf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'PRD'  plant_id = 'PL01'  send_wh = 'WH-A01'  receive_wh = 'WH-C01'
      trans_mode = 'RAIL'  is_allowed = abap_true  inspector_id = ''
      version_no = 1  created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.

    " ── Record 3: PL02 / WH-A02 → WH-B02 ─────────────────────────────
    " DEV
    APPEND VALUE zmmrouteconf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'DEV'  plant_id = 'PL02'  send_wh = 'WH-A02'  receive_wh = 'WH-B02'
      trans_mode = 'AIR'  is_allowed = abap_true  inspector_id = ''
      version_no = 1  created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.
    " QAS
    APPEND VALUE zmmrouteconf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'QAS'  plant_id = 'PL02'  send_wh = 'WH-A02'  receive_wh = 'WH-B02'
      trans_mode = 'AIR'  is_allowed = abap_true  inspector_id = ''
      version_no = 1  created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.
    " PRD
    APPEND VALUE zmmrouteconf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'PRD'  plant_id = 'PL02'  send_wh = 'WH-A02'  receive_wh = 'WH-B02'
      trans_mode = 'AIR'  is_allowed = abap_true  inspector_id = ''
      version_no = 1  created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.

    " ── Record 4: PL03 / WH-A01 → WH-B01 ─────────────────────────────
    " DEV
    APPEND VALUE zmmrouteconf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'DEV'  plant_id = 'PL03'  send_wh = 'WH-A01'  receive_wh = 'WH-B01'
      trans_mode = 'TRUCK'  is_allowed = abap_true  inspector_id = ''
      version_no = 1  created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.
    " QAS
    APPEND VALUE zmmrouteconf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'QAS'  plant_id = 'PL03'  send_wh = 'WH-A01'  receive_wh = 'WH-B01'
      trans_mode = 'TRUCK'  is_allowed = abap_true  inspector_id = ''
      version_no = 1  created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.
    " PRD
    APPEND VALUE zmmrouteconf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'PRD'  plant_id = 'PL03'  send_wh = 'WH-A01'  receive_wh = 'WH-B01'
      trans_mode = 'TRUCK'  is_allowed = abap_true  inspector_id = ''
      version_no = 1  created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.

  CATCH cx_uuid_error INTO DATA(lx_uuid).
    WRITE: / |UUID error: { lx_uuid->get_text( ) }|.
    RETURN.
ENDTRY.

INSERT zmmrouteconf FROM TABLE @lt_data.
COMMIT WORK.

WRITE: / |Seed done. Inserted { sy-dbcnt } row(s) into ZMMROUTECONF (4 records x 3 envs).|.
