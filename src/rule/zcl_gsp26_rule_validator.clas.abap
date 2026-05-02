CLASS zcl_gsp26_rule_validator DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_validation_error,
        conf_id TYPE zconfcatalog-conf_id,
        field   TYPE zconffielddef-field_name,
        message TYPE string,
      END OF ty_validation_error,
      tt_validation_errors TYPE STANDARD TABLE OF ty_validation_error WITH EMPTY KEY.

    " Check whether a catalog entry exists
    CLASS-METHODS check_catalog_existence
      IMPORTING iv_conf_id       TYPE zconfcatalog-conf_id
      RETURNING VALUE(rv_exists) TYPE abap_bool.

    " Check whether a catalog entry is active
    CLASS-METHODS check_catalog_active
      IMPORTING iv_conf_id       TYPE zconfcatalog-conf_id
      RETURNING VALUE(rv_active) TYPE abap_bool.

    " Validate that all required fields (defined in zconffielddef) are filled
    CLASS-METHODS check_required_fields
      IMPORTING iv_conf_id       TYPE zconfcatalog-conf_id
                is_data          TYPE any
      RETURNING VALUE(rt_errors) TYPE tt_validation_errors.

    " Validate that numeric fields stay within their configured min/max range
    CLASS-METHODS check_field_ranges
      IMPORTING iv_conf_id       TYPE zconfcatalog-conf_id
                is_data          TYPE any
      RETURNING VALUE(rt_errors) TYPE tt_validation_errors.

    " Catalog-level validation for a single request item (status, action, env)
    CLASS-METHODS validate_request_item
      IMPORTING iv_conf_id       TYPE zconfcatalog-conf_id
                iv_action        TYPE zde_action_type
                iv_target_env_id TYPE zde_env_id
                is_data          TYPE any OPTIONAL
      RETURNING VALUE(rt_errors) TYPE tt_validation_errors.

    " Pre-write DB validation before approve: checks all 4 modules for
    " duplicate business keys, already-existing CREATE rows, and missing source rows
    CLASS-METHODS validate_approve_pre_write
      IMPORTING iv_req_id        TYPE sysuuid_x16
                iv_env_id        TYPE zde_env_id
      RETURNING VALUE(rt_errors) TYPE tt_validation_errors.

ENDCLASS.


CLASS zcl_gsp26_rule_validator IMPLEMENTATION.

  METHOD check_catalog_existence.
    SELECT SINGLE @abap_true FROM zconfcatalog
      WHERE conf_id = @iv_conf_id
      INTO @rv_exists.
  ENDMETHOD.

  METHOD check_catalog_active.
    SELECT SINGLE @abap_true FROM zconfcatalog
      WHERE conf_id  = @iv_conf_id
        AND is_active = @abap_true
      INTO @rv_active.
  ENDMETHOD.

  METHOD check_required_fields.
    SELECT field_name, field_label FROM zconffielddef
      WHERE conf_id    = @iv_conf_id
        AND is_required = @abap_true
      INTO TABLE @DATA(lt_required_fields).

    IF lt_required_fields IS INITIAL. RETURN. ENDIF.

    DATA lo_struct TYPE REF TO cl_abap_structdescr.
    lo_struct ?= cl_abap_typedescr=>describe_by_data( is_data ).

    LOOP AT lt_required_fields INTO DATA(ls_field).
      " Skip fields that do not exist on the passed structure
      READ TABLE lo_struct->components
        WITH KEY name = to_upper( ls_field-field_name )
        TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0. CONTINUE. ENDIF.

      ASSIGN COMPONENT ls_field-field_name OF STRUCTURE is_data TO FIELD-SYMBOL(<value>).
      IF sy-subrc = 0 AND <value> IS INITIAL.
        APPEND VALUE #(
          conf_id = iv_conf_id
          field   = ls_field-field_name
          message = |Field '{ ls_field-field_label }' is required|
        ) TO rt_errors.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_field_ranges.
    SELECT field_name, min_val, max_val, field_label FROM zconffielddef
      WHERE conf_id = @iv_conf_id
        AND ( min_val IS NOT INITIAL OR max_val IS NOT INITIAL )
      INTO TABLE @DATA(lt_range).

    IF lt_range IS INITIAL. RETURN. ENDIF.

    LOOP AT lt_range INTO DATA(ls_range).
      ASSIGN COMPONENT ls_range-field_name OF STRUCTURE is_data TO FIELD-SYMBOL(<r_val>).
      IF sy-subrc = 0 AND <r_val> IS NOT INITIAL.
        IF ( ls_range-min_val IS NOT INITIAL AND <r_val> < ls_range-min_val ) OR
           ( ls_range-max_val IS NOT INITIAL AND <r_val> > ls_range-max_val ).
          APPEND VALUE #(
            conf_id = iv_conf_id
            field   = ls_range-field_name
            message = |Field '{ ls_range-field_label }' is out of allowed range ({ ls_range-min_val } - { ls_range-max_val })|
          ) TO rt_errors.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_request_item.
    SELECT SINGLE is_active FROM zconfcatalog
      WHERE conf_id = @iv_conf_id
      INTO @DATA(lv_is_active).

    IF sy-subrc <> 0.
      APPEND VALUE #(
        conf_id = iv_conf_id
        message = 'Configuration ID does not exist in catalog'
      ) TO rt_errors.
      RETURN.
    ENDIF.

    IF lv_is_active <> abap_true.
      APPEND VALUE #( conf_id = iv_conf_id message = 'Configuration is not active' ) TO rt_errors.
    ENDIF.
    IF iv_action IS INITIAL.
      APPEND VALUE #( conf_id = iv_conf_id field = 'ACTION' message = 'Action is required' ) TO rt_errors.
    ENDIF.
    IF iv_target_env_id IS INITIAL.
      APPEND VALUE #( conf_id = iv_conf_id field = 'TARGET_ENV_ID' message = 'Target environment is required' ) TO rt_errors.
    ENDIF.

    IF is_data IS SUPPLIED AND is_data IS NOT INITIAL.
      APPEND LINES OF check_required_fields( iv_conf_id = iv_conf_id is_data = is_data ) TO rt_errors.
      APPEND LINES OF check_field_ranges(    iv_conf_id = iv_conf_id is_data = is_data ) TO rt_errors.
    ENDIF.
  ENDMETHOD.

  METHOD validate_approve_pre_write.

    " ── MM Safe Stock ──────────────────────────────────────────────────────────
    SELECT * FROM zmmsafestock_req
      WHERE req_id = @iv_req_id
      INTO TABLE @DATA(lt_ss).

    DATA lt_ss_bkeys TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    LOOP AT lt_ss INTO DATA(ls_ss).
      DATA(lv_ss_bkey) = |{ ls_ss-plant_id }\|{ ls_ss-mat_group }|.

      CASE ls_ss-action_type.
        WHEN 'C' OR 'CREATE'.
          IF ls_ss-plant_id IS INITIAL OR ls_ss-mat_group IS INITIAL.
            APPEND VALUE #( message = 'MMSS CREATE: PlantId and MatGroup are required' ) TO rt_errors.
          ENDIF.

          " Duplicate business key within the same request
          READ TABLE lt_ss_bkeys WITH KEY table_line = lv_ss_bkey TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            APPEND VALUE #(
              message = |MMSS CREATE: Duplicate key Plant={ ls_ss-plant_id } MatGrp={ ls_ss-mat_group } in same request|
            ) TO rt_errors.
          ELSE.
            APPEND lv_ss_bkey TO lt_ss_bkeys.
          ENDIF.

          " Row already exists in the main table
          SELECT SINGLE @abap_true FROM zmmsafestock
            WHERE env_id    = @iv_env_id
              AND plant_id  = @ls_ss-plant_id
              AND mat_group = @ls_ss-mat_group
            INTO @DATA(lv_ss_dup).
          IF lv_ss_dup = abap_true.
            APPEND VALUE #(
              message = |MMSS CREATE: Plant={ ls_ss-plant_id } MatGrp={ ls_ss-mat_group } already exists|
            ) TO rt_errors.
          ENDIF.

        WHEN 'U' OR 'UPDATE' OR 'X' OR 'DELETE'.
          IF ls_ss-source_item_id IS INITIAL.
            APPEND VALUE #( message = |MMSS { ls_ss-action_type }: source_item_id is missing| ) TO rt_errors.
          ELSE.
            " Source row must still exist in the main table
            SELECT SINGLE @abap_true FROM zmmsafestock
              WHERE item_id = @ls_ss-source_item_id
              INTO @DATA(lv_ss_src).
            IF lv_ss_src <> abap_true.
              APPEND VALUE #(
                message = |MMSS { ls_ss-action_type }: source row not found (may have been deleted)|
              ) TO rt_errors.
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    " ── MM Routes ──────────────────────────────────────────────────────────────
    SELECT * FROM zmmrouteconf_req
      WHERE req_id = @iv_req_id
      INTO TABLE @DATA(lt_rt).

    DATA lt_rt_bkeys TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    LOOP AT lt_rt INTO DATA(ls_rt).
      DATA(lv_rt_bkey) = |{ ls_rt-plant_id }\|{ ls_rt-send_wh }\|{ ls_rt-receive_wh }|.

      CASE ls_rt-action_type.
        WHEN 'C' OR 'CREATE'.
          IF ls_rt-plant_id IS INITIAL OR ls_rt-send_wh IS INITIAL OR ls_rt-receive_wh IS INITIAL.
            APPEND VALUE #( message = 'MM Route CREATE: PlantId, SendWh, and ReceiveWh are required' ) TO rt_errors.
          ENDIF.

          READ TABLE lt_rt_bkeys WITH KEY table_line = lv_rt_bkey TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            APPEND VALUE #(
              message = |MM Route CREATE: Duplicate key Plant={ ls_rt-plant_id } SendWh={ ls_rt-send_wh } RecvWh={ ls_rt-receive_wh } in same request|
            ) TO rt_errors.
          ELSE.
            APPEND lv_rt_bkey TO lt_rt_bkeys.
          ENDIF.

          SELECT SINGLE @abap_true FROM zmmrouteconf
            WHERE env_id      = @iv_env_id
              AND plant_id    = @ls_rt-plant_id
              AND send_wh     = @ls_rt-send_wh
              AND receive_wh  = @ls_rt-receive_wh
            INTO @DATA(lv_rt_dup).
          IF lv_rt_dup = abap_true.
            APPEND VALUE #(
              message = |MM Route CREATE: Plant={ ls_rt-plant_id } SendWh={ ls_rt-send_wh } RecvWh={ ls_rt-receive_wh } already exists|
            ) TO rt_errors.
          ENDIF.

        WHEN 'U' OR 'X'.
          IF ls_rt-source_item_id IS INITIAL.
            APPEND VALUE #( message = |MM Route { ls_rt-action_type }: source_item_id is missing| ) TO rt_errors.
          ELSE.
            SELECT SINGLE @abap_true FROM zmmrouteconf
              WHERE item_id = @ls_rt-source_item_id
              INTO @DATA(lv_rt_src).
            IF lv_rt_src <> abap_true.
              APPEND VALUE #(
                message = |MM Route { ls_rt-action_type }: source row not found (may have been deleted)|
              ) TO rt_errors.
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    " ── FI Limit ───────────────────────────────────────────────────────────────
    SELECT * FROM zfilimitreq
      WHERE req_id = @iv_req_id
      INTO TABLE @DATA(lt_fi).

    DATA lt_fi_bkeys TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    LOOP AT lt_fi INTO DATA(ls_fi).
      DATA(lv_fi_bkey) = |{ ls_fi-expense_type }\|{ ls_fi-gl_account }|.

      CASE ls_fi-action_type.
        WHEN 'C' OR 'CREATE'.
          IF ls_fi-expense_type IS INITIAL OR ls_fi-gl_account IS INITIAL.
            APPEND VALUE #( message = 'FI Limit CREATE: ExpenseType and GlAccount are required' ) TO rt_errors.
          ENDIF.

          READ TABLE lt_fi_bkeys WITH KEY table_line = lv_fi_bkey TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            APPEND VALUE #(
              message = |FI Limit CREATE: Duplicate key ExpType={ ls_fi-expense_type } GlAcc={ ls_fi-gl_account } in same request|
            ) TO rt_errors.
          ELSE.
            APPEND lv_fi_bkey TO lt_fi_bkeys.
          ENDIF.

          SELECT SINGLE @abap_true FROM zfilimitconf
            WHERE env_id        = @iv_env_id
              AND expense_type  = @ls_fi-expense_type
              AND gl_account    = @ls_fi-gl_account
            INTO @DATA(lv_fi_dup).
          IF lv_fi_dup = abap_true.
            APPEND VALUE #(
              message = |FI Limit CREATE: ExpType={ ls_fi-expense_type } GlAcc={ ls_fi-gl_account } already exists|
            ) TO rt_errors.
          ENDIF.

        WHEN 'U' OR 'X'.
          IF ls_fi-source_item_id IS INITIAL.
            APPEND VALUE #( message = |FI Limit { ls_fi-action_type }: source_item_id is missing| ) TO rt_errors.
          ELSE.
            SELECT SINGLE @abap_true FROM zfilimitconf
              WHERE item_id = @ls_fi-source_item_id
              INTO @DATA(lv_fi_src).
            IF lv_fi_src <> abap_true.
              APPEND VALUE #(
                message = |FI Limit { ls_fi-action_type }: source row not found (may have been deleted)|
              ) TO rt_errors.
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    " ── SD Price ───────────────────────────────────────────────────────────────
    SELECT * FROM zsd_price_req
      WHERE req_id = @iv_req_id
      INTO TABLE @DATA(lt_sd).

    DATA lt_sd_bkeys TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    LOOP AT lt_sd INTO DATA(ls_sd).
      DATA(lv_sd_bkey) = |{ ls_sd-branch_id }\|{ ls_sd-cust_group }\|{ ls_sd-material_grp }|.

      CASE ls_sd-action_type.
        WHEN 'C' OR 'CREATE'.
          IF ls_sd-branch_id IS INITIAL OR ls_sd-cust_group IS INITIAL OR ls_sd-material_grp IS INITIAL.
            APPEND VALUE #( message = 'SD Price CREATE: BranchId, CustGroup, and MaterialGrp are required' ) TO rt_errors.
          ENDIF.

          READ TABLE lt_sd_bkeys WITH KEY table_line = lv_sd_bkey TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            APPEND VALUE #(
              message = |SD Price CREATE: Duplicate key Branch={ ls_sd-branch_id } CustGrp={ ls_sd-cust_group } MatGrp={ ls_sd-material_grp } in same request|
            ) TO rt_errors.
          ELSE.
            APPEND lv_sd_bkey TO lt_sd_bkeys.
          ENDIF.

          SELECT SINGLE @abap_true FROM zsd_price_conf
            WHERE env_id        = @iv_env_id
              AND branch_id     = @ls_sd-branch_id
              AND cust_group    = @ls_sd-cust_group
              AND material_grp  = @ls_sd-material_grp
            INTO @DATA(lv_sd_dup).
          IF lv_sd_dup = abap_true.
            APPEND VALUE #(
              message = |SD Price CREATE: Branch={ ls_sd-branch_id } CustGrp={ ls_sd-cust_group } MatGrp={ ls_sd-material_grp } already exists|
            ) TO rt_errors.
          ENDIF.

        WHEN 'U' OR 'X'.
          IF ls_sd-source_item_id IS INITIAL.
            APPEND VALUE #( message = |SD Price { ls_sd-action_type }: source_item_id is missing| ) TO rt_errors.
          ELSE.
            SELECT SINGLE @abap_true FROM zsd_price_conf
              WHERE item_id = @ls_sd-source_item_id
              INTO @DATA(lv_sd_src).
            IF lv_sd_src <> abap_true.
              APPEND VALUE #(
                message = |SD Price { ls_sd-action_type }: source row not found (may have been deleted)|
              ) TO rt_errors.
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

