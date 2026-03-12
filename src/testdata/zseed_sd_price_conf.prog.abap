REPORT zseed_sd_price_conf.

DATA: lt_price TYPE STANDARD TABLE OF zsd_price_req,
      lv_ts    TYPE timestampl.

GET TIME STAMP FIELD lv_ts.

SELECT SINGLE @abap_true FROM zsd_price_req INTO @DATA(lv_exists).
IF sy-subrc <> 0.
  TRY.
      APPEND VALUE zsd_price_req(
        client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
        env_id = 'DEV'  branch_id = 'HCM'  cust_group = 'VIP'
        material_grp = 'ELEC'  max_discount = '10.00'  min_order_val = 1000
        approver_grp = 'SD_APPROVER'  currency = 'VND'
        valid_from = '20260101'  valid_to = '20261231'  version_no = 1
        created_by = sy-uname  created_at = lv_ts  changed_by = sy-uname  changed_at = lv_ts
      ) TO lt_price.

      APPEND VALUE zsd_price_req(
        client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
        env_id = 'DEV'  branch_id = 'HCM'  cust_group = 'RETAIL'
        material_grp = 'PHONE'  max_discount = '5.00'  min_order_val = 500
        approver_grp = 'SD_APPROVER'  currency = 'VND'
        valid_from = '20260101'  valid_to = '20261231'  version_no = 1
        created_by = sy-uname  created_at = lv_ts  changed_by = sy-uname  changed_at = lv_ts
      ) TO lt_price.

      APPEND VALUE zsd_price_req(
        client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
        env_id = 'DEV'  branch_id = 'HN'  cust_group = 'WHOLESALE'
        material_grp = 'ACCES'  max_discount = '15.00'  min_order_val = 2000
        approver_grp = 'SD_MGR'  currency = 'VND'
        valid_from = '20260301'  valid_to = '20261231'  version_no = 1
        created_by = sy-uname  created_at = lv_ts  changed_by = sy-uname  changed_at = lv_ts
      ) TO lt_price.

      APPEND VALUE zsd_price_req(
        client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
        env_id = 'QAS'  branch_id = 'HCM'  cust_group = 'VIP'
        material_grp = 'ELEC'  max_discount = '10.00'  min_order_val = 1000
        approver_grp = 'SD_APPROVER'  currency = 'VND'
        valid_from = '20260101'  valid_to = '20261231'  version_no = 2
        created_by = sy-uname  created_at = lv_ts  changed_by = sy-uname  changed_at = lv_ts
      ) TO lt_price.

      APPEND VALUE zsd_price_req(
        client = sy-mandt  item_id = cl_system_uuid=>create_uuid_x16_static( )
        env_id = 'PRD'  branch_id = 'HCM'  cust_group = 'VIP'
        material_grp = 'ELEC'  max_discount = '8.00'  min_order_val = 1500
        approver_grp = 'SD_APPROVER'  currency = 'VND'
        valid_from = '20260101'  valid_to = '20261231'  version_no = 3
        created_by = sy-uname  created_at = lv_ts  changed_by = sy-uname  changed_at = lv_ts
      ) TO lt_price.

    CATCH cx_uuid_error INTO DATA(lx_uuid).
      WRITE: / |UUID generation failed: { lx_uuid->get_text( ) }|.
      RETURN.
  ENDTRY.
  INSERT zsd_price_req FROM TABLE @lt_price.
  WRITE: / |Seeded { sy-dbcnt } row(s) into ZSD_PRICE_REQ.|.
ELSE.
  WRITE: / 'ZSD_PRICE_REQ already has data. Skip seeding.'.
ENDIF.
COMMIT WORK.
WRITE: / 'Seed SD Price Request completed.'.
