*&---------------------------------------------------------------------*
*& Report zseed_mm_route_conf
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zseed_mm_route_conf.

DATA: lt_env    TYPE STANDARD TABLE OF zenvdef,
      lt_plant  TYPE STANDARD TABLE OF zplantunit,
      lt_route  TYPE STANDARD TABLE OF zmmrouteconf_req,
      lv_ts     TYPE timestampl.

GET TIME STAMP FIELD lv_ts.

"----------------------------------------------------------------------
" Seed ZMMROUTECONF
"----------------------------------------------------------------------
SELECT SINGLE @abap_true FROM zmmrouteconf_req INTO @DATA(lv_route_exists).
IF sy-subrc <> 0.

  TRY.

      APPEND VALUE zmmrouteconf_req(
        client       = sy-mandt
        item_id      = cl_system_uuid=>create_uuid_x16_static( )
        req_id       = ''
        env_id       = 'DEV'
        plant_id     = 'PL01'
        send_wh      = 'WHA'
        receive_wh   = 'WHB'
        inspector_id = 'DEV-056'
        trans_mode   = 'TRUCK'
        is_allowed   = abap_true
        version_no   = 1
        created_by   = sy-uname
        created_at   = lv_ts
        changed_by   = sy-uname
        changed_at   = lv_ts
      ) TO lt_route.

      APPEND VALUE zmmrouteconf_req(
        client       = sy-mandt
        item_id      = cl_system_uuid=>create_uuid_x16_static( )
        req_id       = ''
        env_id       = 'DEV'
        plant_id     = 'PL01'
        send_wh      = 'WHA'
        receive_wh   = 'WHC'
        inspector_id = 'DEV-056'
        trans_mode   = 'VAN'
        is_allowed   = abap_false
        version_no   = 1
        created_by   = sy-uname
        created_at   = lv_ts
        changed_by   = sy-uname
        changed_at   = lv_ts
      ) TO lt_route.

      APPEND VALUE zmmrouteconf_req(
        client       = sy-mandt
        item_id      = cl_system_uuid=>create_uuid_x16_static( )
        req_id       = ''
        env_id       = 'DEV'
        plant_id     = 'PL02'
        send_wh      = 'WHD'
        receive_wh   = 'WHE'
        inspector_id = 'DEV-057'
        trans_mode   = 'INTERNAL'
        is_allowed   = abap_true
        version_no   = 1
        created_by   = sy-uname
        created_at   = lv_ts
        changed_by   = sy-uname
        changed_at   = lv_ts
      ) TO lt_route.

      APPEND VALUE zmmrouteconf_req(
        client       = sy-mandt
        item_id      = cl_system_uuid=>create_uuid_x16_static( )
        req_id       = ''
        env_id       = 'QAS'
        plant_id     = 'PL01'
        send_wh      = 'WHA'
        receive_wh   = 'WHB'
        inspector_id = 'QA-001'
        trans_mode   = 'TRUCK'
        is_allowed   = abap_true
        version_no   = 2
        created_by   = sy-uname
        created_at   = lv_ts
        changed_by   = sy-uname
        changed_at   = lv_ts
      ) TO lt_route.

      APPEND VALUE zmmrouteconf_req(
        client       = sy-mandt
        item_id      = cl_system_uuid=>create_uuid_x16_static( )
        req_id       = ''
        env_id       = 'PRD'
        plant_id     = 'PL01'
        send_wh      = 'WHA'
        receive_wh   = 'WHB'
        inspector_id = 'PRD-001'
        trans_mode   = 'TRUCK'
        is_allowed   = abap_true
        version_no   = 3
        created_by   = sy-uname
        created_at   = lv_ts
        changed_by   = sy-uname
        changed_at   = lv_ts
      ) TO lt_route.

    CATCH cx_uuid_error INTO DATA(lx_uuid).
      WRITE: / |UUID generation failed: { lx_uuid->get_text( ) }|.
      RETURN.
  ENDTRY.

  INSERT zmmrouteconf_req FROM TABLE @lt_route.
  WRITE: / |Seeded { sy-dbcnt } row(s) into ZMMROUTECONF.|.

ELSE.
  WRITE: / 'ZMMROUTECONF already has data. Skip seeding.'.
ENDIF.

COMMIT WORK.

WRITE: / 'Seed MM Route completed.'.
