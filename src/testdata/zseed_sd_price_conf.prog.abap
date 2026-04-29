*&---------------------------------------------------------------------*
*& Report zseed_sd_price_conf
*& Seed baseline data for ZSD_PRICE_CONF — 3 rows per record (DEV/QAS/PRD)
*& Each business key (branch_id + cust_group + material_grp) must exist
*& in all 3 envs so that approve() UPDATE and promote() UPDATE work.
*&---------------------------------------------------------------------*
REPORT zseed_sd_price_conf.

DATA: lt_data TYPE STANDARD TABLE OF zsd_price_conf,
      lv_ts   TYPE timestampl.

GET TIME STAMP FIELD lv_ts.

" Skip if main table already has data
SELECT SINGLE @abap_true FROM zsd_price_conf INTO @DATA(lv_exists).
IF sy-subrc = 0.
  WRITE: / 'ZSD_PRICE_CONF already has data. Skip.'.
  RETURN.
ENDIF.

TRY.
    " ── Record 1: HCM / VIP / ELEC ────────────────────────────────────
    APPEND VALUE zsd_price_conf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'DEV'  branch_id = 'HCM'  cust_group = 'VIP'  material_grp = 'ELEC'
      max_discount = '10'  min_order_val = 1000  approver_grp = 'SD_APPROVER'
      currency = 'VND'  valid_from = '20260101'  valid_to = '20261231'
      version_no = 1  created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.
    APPEND VALUE zsd_price_conf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'QAS'  branch_id = 'HCM'  cust_group = 'VIP'  material_grp = 'ELEC'
      max_discount = '10'  min_order_val = 1000  approver_grp = 'SD_APPROVER'
      currency = 'VND'  valid_from = '20260101'  valid_to = '20261231'
      version_no = 1  created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.
    APPEND VALUE zsd_price_conf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'PRD'  branch_id = 'HCM'  cust_group = 'VIP'  material_grp = 'ELEC'
      max_discount = '10'  min_order_val = 1000  approver_grp = 'SD_APPROVER'
      currency = 'VND'  valid_from = '20260101'  valid_to = '20261231'
      version_no = 1  created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.

    " ── Record 2: HCM / RETAIL / PHONE ────────────────────────────────
    APPEND VALUE zsd_price_conf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'DEV'  branch_id = 'HCM'  cust_group = 'RETAIL'  material_grp = 'PHONE'
      max_discount = '5'  min_order_val = 500  approver_grp = 'SD_APPROVER'
      currency = 'VND'  valid_from = '20260101'  valid_to = '20261231'
      version_no = 1  created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.
    APPEND VALUE zsd_price_conf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'QAS'  branch_id = 'HCM'  cust_group = 'RETAIL'  material_grp = 'PHONE'
      max_discount = '5'  min_order_val = 500  approver_grp = 'SD_APPROVER'
      currency = 'VND'  valid_from = '20260101'  valid_to = '20261231'
      version_no = 1  created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.
    APPEND VALUE zsd_price_conf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'PRD'  branch_id = 'HCM'  cust_group = 'RETAIL'  material_grp = 'PHONE'
      max_discount = '5'  min_order_val = 500  approver_grp = 'SD_APPROVER'
      currency = 'VND'  valid_from = '20260101'  valid_to = '20261231'
      version_no = 1  created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.

    " ── Record 3: HN / WHOLESALE / ACCES ──────────────────────────────
    APPEND VALUE zsd_price_conf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'DEV'  branch_id = 'HN'  cust_group = 'WHOLESALE'  material_grp = 'ACCES'
      max_discount = '15'  min_order_val = 2000  approver_grp = 'SD_MGR'
      currency = 'VND'  valid_from = '20260301'  valid_to = '20261231'
      version_no = 1  created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.
    APPEND VALUE zsd_price_conf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'QAS'  branch_id = 'HN'  cust_group = 'WHOLESALE'  material_grp = 'ACCES'
      max_discount = '15'  min_order_val = 2000  approver_grp = 'SD_MGR'
      currency = 'VND'  valid_from = '20260301'  valid_to = '20261231'
      version_no = 1  created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.
    APPEND VALUE zsd_price_conf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'PRD'  branch_id = 'HN'  cust_group = 'WHOLESALE'  material_grp = 'ACCES'
      max_discount = '15'  min_order_val = 2000  approver_grp = 'SD_MGR'
      currency = 'VND'  valid_from = '20260301'  valid_to = '20261231'
      version_no = 1  created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.

    " ── Record 4: HCM / GRP01 / AUDIO ─────────────────────────────────
    APPEND VALUE zsd_price_conf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'DEV'  branch_id = 'PL02'  cust_group = 'GRP01'  material_grp = 'AUDIO'
      max_discount = '20'  min_order_val = 500  approver_grp = 'SD_APPROVER'
      currency = 'VND'  valid_from = '20260101'  valid_to = '20261231'
      version_no = 1  created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.
    APPEND VALUE zsd_price_conf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'QAS'  branch_id = 'PL02'  cust_group = 'GRP01'  material_grp = 'AUDIO'
      max_discount = '20'  min_order_val = 500  approver_grp = 'SD_APPROVER'
      currency = 'VND'  valid_from = '20260101'  valid_to = '20261231'
      version_no = 1  created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.
    APPEND VALUE zsd_price_conf(
      client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
      env_id = 'PRD'  branch_id = 'PL02'  cust_group = 'GRP01'  material_grp = 'AUDIO'
      max_discount = '20'  min_order_val = 500  approver_grp = 'SD_APPROVER'
      currency = 'VND'  valid_from = '20260101'  valid_to = '20261231'
      version_no = 1  created_by = sy-uname  created_at = lv_ts
      changed_by = sy-uname  changed_at = lv_ts
    ) TO lt_data.

  CATCH cx_uuid_error INTO DATA(lx_uuid).
    WRITE: / |UUID error: { lx_uuid->get_text( ) }|.
    RETURN.
ENDTRY.

INSERT zsd_price_conf FROM TABLE @lt_data.
COMMIT WORK.

WRITE: / |Seed done. Inserted { sy-dbcnt } row(s) into ZSD_PRICE_CONF (4 records x 3 envs).|.
