REPORT zseed_mm_safe_stock.

DATA: lt_data TYPE STANDARD TABLE OF zmmsafestock, lv_ts TYPE timestampl.
GET TIME STAMP FIELD lv_ts.

DELETE FROM zmmsafestock.
DELETE FROM zmmsafestock_req.

TRY.
    " ── Record 1: US02 / EBIK ─────────────────────────────────────────
    APPEND VALUE zmmsafestock( client = sy-mandt
      item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'DEV' plant_id = 'US02' mat_group = 'EBIK' min_qty = '500'
      version_no = 1 created_by = sy-uname created_at = lv_ts ) TO lt_data.

    APPEND VALUE zmmsafestock( client = sy-mandt
      item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'QAS' plant_id = 'US02' mat_group = 'EBIK' min_qty = '500'
      version_no = 1 created_by = sy-uname created_at = lv_ts ) TO lt_data.

    APPEND VALUE zmmsafestock( client = sy-mandt
      item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'PRD' plant_id = 'US02' mat_group = 'EBIK' min_qty = '500'
      version_no = 1 created_by = sy-uname created_at = lv_ts ) TO lt_data.

    " ── Record 2: VN02 / PART ─────────────────────────────────────────
    APPEND VALUE zmmsafestock( client = sy-mandt
      item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'DEV' plant_id = 'VN02' mat_group = 'PART' min_qty = '10000'
      version_no = 1 created_by = sy-uname created_at = lv_ts ) TO lt_data.

    APPEND VALUE zmmsafestock( client = sy-mandt
      item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'QAS' plant_id = 'VN02' mat_group = 'PART' min_qty = '10000'
      version_no = 1 created_by = sy-uname created_at = lv_ts ) TO lt_data.

    APPEND VALUE zmmsafestock( client = sy-mandt
      item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'PRD' plant_id = 'VN02' mat_group = 'PART' min_qty = '10000'
      version_no = 1 created_by = sy-uname created_at = lv_ts ) TO lt_data.

    " ── Record 3: US01 / MTB (Mountain Bikes at Factory) ──────────────
    APPEND VALUE zmmsafestock( client = sy-mandt
      item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'DEV' plant_id = 'US01' mat_group = 'MTB' min_qty = '1200'
      version_no = 1 created_by = sy-uname created_at = lv_ts ) TO lt_data.

    APPEND VALUE zmmsafestock( client = sy-mandt
      item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'QAS' plant_id = 'US01' mat_group = 'MTB' min_qty = '1200'
      version_no = 1 created_by = sy-uname created_at = lv_ts ) TO lt_data.

    APPEND VALUE zmmsafestock( client = sy-mandt
      item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'PRD' plant_id = 'US01' mat_group = 'MTB' min_qty = '1200'
      version_no = 1 created_by = sy-uname created_at = lv_ts ) TO lt_data.

    " ── Record 4: TW01 / PART (Components at Taiwan) ──────────────────
    APPEND VALUE zmmsafestock( client = sy-mandt
      item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'DEV' plant_id = 'TW01' mat_group = 'PART' min_qty = '50000'
      version_no = 1 created_by = sy-uname created_at = lv_ts ) TO lt_data.

    APPEND VALUE zmmsafestock( client = sy-mandt
      item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'QAS' plant_id = 'TW01' mat_group = 'PART' min_qty = '50000'
      version_no = 1 created_by = sy-uname created_at = lv_ts ) TO lt_data.

    APPEND VALUE zmmsafestock( client = sy-mandt
      item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'PRD' plant_id = 'TW01' mat_group = 'PART' min_qty = '50000'
      version_no = 1 created_by = sy-uname created_at = lv_ts ) TO lt_data.

    " ── Record 5: VN01 / ROAD (Road Bikes at VN Factory) ──────────────
    APPEND VALUE zmmsafestock( client = sy-mandt
      item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'DEV' plant_id = 'VN01' mat_group = 'ROAD' min_qty = '800'
      version_no = 1 created_by = sy-uname created_at = lv_ts ) TO lt_data.

    APPEND VALUE zmmsafestock( client = sy-mandt
      item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'QAS' plant_id = 'VN01' mat_group = 'ROAD' min_qty = '800'
      version_no = 1 created_by = sy-uname created_at = lv_ts ) TO lt_data.

    APPEND VALUE zmmsafestock( client = sy-mandt
      item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'PRD' plant_id = 'VN01' mat_group = 'ROAD' min_qty = '800'
      version_no = 1 created_by = sy-uname created_at = lv_ts ) TO lt_data.

    " ── Record 6: HQ01 / GEAR (HQ Merchandise & Gear) ─────────────────
    APPEND VALUE zmmsafestock( client = sy-mandt
      item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'DEV' plant_id = 'HQ01' mat_group = 'GEAR' min_qty = '2500'
      version_no = 1 created_by = sy-uname created_at = lv_ts ) TO lt_data.

    APPEND VALUE zmmsafestock( client = sy-mandt
      item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'QAS' plant_id = 'HQ01' mat_group = 'GEAR' min_qty = '2500'
      version_no = 1 created_by = sy-uname created_at = lv_ts ) TO lt_data.

    APPEND VALUE zmmsafestock( client = sy-mandt
      item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'PRD' plant_id = 'HQ01' mat_group = 'GEAR' min_qty = '2500'
      version_no = 1 created_by = sy-uname created_at = lv_ts ) TO lt_data.

  CATCH cx_uuid_error INTO DATA(lx_uuid).
    WRITE: / |UUID error: { lx_uuid->get_text( ) }|. RETURN.
ENDTRY.

INSERT zmmsafestock FROM TABLE @lt_data.
COMMIT WORK.
WRITE: / |Seed done: ZMMSAFESTOCK (6 records x 3 envs).|.
