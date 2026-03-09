*&---------------------------------------------------------------------*
*& Report zseed_mm_route_conf
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zseed_mm_route_conf.

DATA: lt_env    TYPE STANDARD TABLE OF zenvdef,
      lt_plant  TYPE STANDARD TABLE OF zplantunit,
      lt_route  TYPE STANDARD TABLE OF zmmrouteconf,
      lv_ts     TYPE timestampl.

GET TIME STAMP FIELD lv_ts.

"----------------------------------------------------------------------
" Seed ZENVDEF
"----------------------------------------------------------------------
SELECT SINGLE @abap_true FROM zenvdef INTO @DATA(lv_env_exists).
IF sy-subrc <> 0.

  APPEND VALUE zenvdef(
    client      = sy-mandt
    env_id      = 'DEV'
    description = 'Development'
    next_env    = 'QAS'
    is_active   = abap_true
  ) TO lt_env.

  APPEND VALUE zenvdef(
    client      = sy-mandt
    env_id      = 'QAS'
    description = 'Quality Assurance'
    next_env    = 'PRD'
    is_active   = abap_true
  ) TO lt_env.

  APPEND VALUE zenvdef(
    client      = sy-mandt
    env_id      = 'PRD'
    description = 'Production'
    next_env    = ''
    is_active   = abap_true
  ) TO lt_env.

  INSERT zenvdef FROM TABLE @lt_env.
  WRITE: / |Seeded { sy-dbcnt } row(s) into ZENVDEF.|.

ELSE.
  WRITE: / 'ZENVDEF already has data. Skip seeding.'.
ENDIF.

"----------------------------------------------------------------------
" Seed ZPLANTUNIT
"----------------------------------------------------------------------
SELECT SINGLE @abap_true FROM zplantunit INTO @DATA(lv_plant_exists).
IF sy-subrc <> 0.

  APPEND VALUE zplantunit(
    client      = sy-mandt
    plant_id    = 'PL01'
    plant_type  = 'FACTORY'
    description = 'Main Plant'
    parent_org  = 'ORG01'
  ) TO lt_plant.

  APPEND VALUE zplantunit(
    client      = sy-mandt
    plant_id    = 'PL02'
    plant_type  = 'FACTORY'
    description = 'North Plant'
    parent_org  = 'ORG01'
  ) TO lt_plant.

  APPEND VALUE zplantunit(
    client      = sy-mandt
    plant_id    = 'PL03'
    plant_type  = 'DC'
    description = 'Distribution Hub'
    parent_org  = 'ORG02'
  ) TO lt_plant.

  INSERT zplantunit FROM TABLE @lt_plant.
  WRITE: / |Seeded { sy-dbcnt } row(s) into ZPLANTUNIT.|.

ELSE.
  WRITE: / 'ZPLANTUNIT already has data. Skip seeding.'.
ENDIF.

"----------------------------------------------------------------------
" Seed ZMMROUTECONF
"----------------------------------------------------------------------
SELECT SINGLE @abap_true FROM zmmrouteconf INTO @DATA(lv_route_exists).
IF sy-subrc <> 0.

  TRY.

      APPEND VALUE zmmrouteconf(
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

      APPEND VALUE zmmrouteconf(
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

      APPEND VALUE zmmrouteconf(
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

      APPEND VALUE zmmrouteconf(
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

      APPEND VALUE zmmrouteconf(
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

  INSERT zmmrouteconf FROM TABLE @lt_route.
  WRITE: / |Seeded { sy-dbcnt } row(s) into ZMMROUTECONF.|.

ELSE.
  WRITE: / 'ZMMROUTECONF already has data. Skip seeding.'.
ENDIF.

COMMIT WORK.

WRITE: / 'Seed MM Route completed.'.
