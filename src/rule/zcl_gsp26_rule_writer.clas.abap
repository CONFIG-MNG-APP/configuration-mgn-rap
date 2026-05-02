CLASS zcl_gsp26_rule_writer DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.

    TYPES tt_audit_logs TYPE STANDARD TABLE OF zauditlog WITH EMPTY KEY.

    CLASS-METHODS log_audit_entry
      IMPORTING iv_conf_id  TYPE sysuuid_x16
                iv_req_id   TYPE sysuuid_x16 OPTIONAL
                iv_mod_id   TYPE char10
                iv_act_type TYPE zde_action_type
                iv_tab_name TYPE char30
                iv_env_id   TYPE zde_env_id
                is_old_data TYPE any OPTIONAL
                is_new_data TYPE any OPTIONAL
      RAISING   cx_uuid_error.

    CLASS-METHODS flush_audit_logs
      IMPORTING it_logs TYPE tt_audit_logs.

    CLASS-METHODS write_back_mmss
      IMPORTING iv_req_id      TYPE sysuuid_x16
                iv_env_id      TYPE zde_env_id
                iv_now         TYPE timestampl
                iv_changed_by  TYPE syuname
      RETURNING VALUE(rt_logs) TYPE tt_audit_logs.

    CLASS-METHODS write_back_mmroute
      IMPORTING iv_req_id      TYPE sysuuid_x16
                iv_env_id      TYPE zde_env_id
                iv_now         TYPE timestampl
                iv_changed_by  TYPE syuname
      RETURNING VALUE(rt_logs) TYPE tt_audit_logs.

    CLASS-METHODS write_back_fi
      IMPORTING iv_req_id      TYPE sysuuid_x16
                iv_env_id      TYPE zde_env_id
                iv_now         TYPE timestampl
                iv_changed_by  TYPE syuname
      RETURNING VALUE(rt_logs) TYPE tt_audit_logs.

    CLASS-METHODS write_back_sd
      IMPORTING iv_req_id      TYPE sysuuid_x16
                iv_env_id      TYPE zde_env_id
                iv_now         TYPE timestampl
                iv_changed_by  TYPE syuname
      RETURNING VALUE(rt_logs) TYPE tt_audit_logs.

ENDCLASS.

CLASS zcl_gsp26_rule_writer IMPLEMENTATION.

  METHOD log_audit_entry.
    GET TIME STAMP FIELD DATA(lv_timestamp).
    DATA(lv_old_json) = /ui2/cl_json=>serialize( data = is_old_data ).
    DATA(lv_new_json) = /ui2/cl_json=>serialize( data = is_new_data ).
    DATA(ls_audit) = VALUE zauditlog(
      log_id      = cl_system_uuid=>create_uuid_x16_static( )
      req_id      = iv_req_id
      conf_id     = iv_conf_id
      module_id   = iv_mod_id
      action_type = iv_act_type
      table_name  = iv_tab_name
      env_id      = iv_env_id
      old_data    = lv_old_json
      new_data    = lv_new_json
      changed_by  = sy-uname
      changed_at  = lv_timestamp
    ).
    INSERT zauditlog FROM @ls_audit.
  ENDMETHOD.

  METHOD flush_audit_logs.
    CHECK it_logs IS NOT INITIAL.
    INSERT zauditlog FROM TABLE @it_logs.
  ENDMETHOD.

  METHOD write_back_mmss.
    SELECT * FROM zmmsafestock_req WHERE req_id = @iv_req_id INTO TABLE @DATA(lt_req).
    CHECK lt_req IS NOT INITIAL.

    LOOP AT lt_req ASSIGNING FIELD-SYMBOL(<ss>).
      DATA ls_log TYPE zauditlog.
      ls_log-client     = sy-mandt.
      TRY. ls_log-log_id = cl_system_uuid=>create_uuid_x16_static( ). CATCH cx_uuid_error. ENDTRY.
      ls_log-req_id     = iv_req_id.
      ls_log-conf_id    = <ss>-conf_id.
      ls_log-module_id  = 'MM'.
      ls_log-table_name = 'ZMMSAFESTOCK'.
      ls_log-env_id     = iv_env_id.
      ls_log-object_key = COND #( WHEN <ss>-action_type = 'C' OR <ss>-action_type = 'CREATE'
                                  THEN <ss>-item_id ELSE <ss>-source_item_id ).
      CASE <ss>-action_type.
        WHEN 'C' OR 'CREATE'.
          ls_log-action_type = 'CREATE'.
          ls_log-old_data    = '{}'.
          ls_log-new_data    = |\{"PLANT_ID":"{ <ss>-plant_id }","MAT_GROUP":"{ <ss>-mat_group }","MIN_QTY":"{ <ss>-min_qty }"\}|.
        WHEN 'U' OR 'UPDATE'.
          ls_log-action_type = 'UPDATE'.
          ls_log-old_data    = |\{"MIN_QTY":"{ <ss>-old_min_qty }"\}|.
          ls_log-new_data    = |\{"MIN_QTY":"{ <ss>-min_qty }"\}|.
        WHEN OTHERS.
          ls_log-action_type = 'DELETE'.
          ls_log-old_data    = |\{"ENV_ID":"{ iv_env_id }","PLANT_ID":"{ <ss>-old_plant_id }","MAT_GROUP":"{ <ss>-old_mat_group }","MIN_QTY":"{ <ss>-old_min_qty }"\}|.
          ls_log-new_data    = '{}'.
      ENDCASE.
      ls_log-changed_by = iv_changed_by.
      ls_log-changed_at = iv_now.
      APPEND ls_log TO rt_logs.

      CASE <ss>-action_type.
        WHEN 'U' OR 'UPDATE'.
          SELECT SINGLE @abap_true FROM zmmsafestock WHERE item_id = @<ss>-source_item_id INTO @DATA(lv_exists).
          IF lv_exists = abap_true.
            DATA(lv_new_ver) = <ss>-version_no + 1.
            UPDATE zmmsafestock SET
              min_qty    = @<ss>-min_qty,
              version_no = @lv_new_ver,
              req_id     = @iv_req_id,
              changed_by = @iv_changed_by,
              changed_at = @iv_now
            WHERE item_id = @<ss>-source_item_id.
          ENDIF.
        WHEN 'C' OR 'CREATE'.
          INSERT zmmsafestock FROM @( VALUE zmmsafestock(
            client     = sy-mandt
            item_id    = <ss>-item_id
            req_id     = iv_req_id
            env_id     = iv_env_id
            plant_id   = <ss>-plant_id
            mat_group  = <ss>-mat_group
            min_qty    = <ss>-min_qty
            version_no = 1
            created_by = <ss>-created_by
            created_at = iv_now
            changed_by = iv_changed_by
            changed_at = iv_now ) ).
        WHEN OTHERS.
          DELETE FROM zmmsafestock WHERE item_id = @<ss>-source_item_id.
      ENDCASE.
    ENDLOOP.

    UPDATE zmmsafestock_req SET
      line_status = 'APPROVED',
      changed_by  = @iv_changed_by,
      changed_at  = @iv_now
    WHERE req_id = @iv_req_id.
  ENDMETHOD.

  METHOD write_back_mmroute.
    SELECT * FROM zmmrouteconf_req WHERE req_id = @iv_req_id INTO TABLE @DATA(lt_req).
    CHECK lt_req IS NOT INITIAL.

    LOOP AT lt_req ASSIGNING FIELD-SYMBOL(<rt>).
      DATA ls_log TYPE zauditlog.
      ls_log-client     = sy-mandt.
      TRY. ls_log-log_id = cl_system_uuid=>create_uuid_x16_static( ). CATCH cx_uuid_error. ENDTRY.
      ls_log-req_id     = iv_req_id.
      ls_log-conf_id    = <rt>-conf_id.
      ls_log-module_id  = 'MM'.
      ls_log-table_name = 'ZMMROUTECONF'.
      ls_log-env_id     = iv_env_id.
      ls_log-object_key = COND #( WHEN <rt>-action_type = 'C' THEN <rt>-item_id ELSE <rt>-source_item_id ).
      CASE <rt>-action_type.
        WHEN 'C'.
          ls_log-action_type = 'CREATE'.
          ls_log-old_data    = '{}'.
          ls_log-new_data    = |\{"PLANT_ID":"{ <rt>-plant_id }","SEND_WH":"{ <rt>-send_wh }","RECEIVE_WH":"{ <rt>-receive_wh }","TRANS_MODE":"{ <rt>-trans_mode }","IS_ALLOWED":"{ <rt>-is_allowed }"\}|.
        WHEN 'U'.
          ls_log-action_type = 'UPDATE'.
          SELECT SINGLE is_allowed, inspector_id FROM zmmrouteconf
            WHERE item_id = @<rt>-source_item_id INTO @DATA(ls_rt_cur).
          ls_log-old_data = |\{"TRANS_MODE":"{ <rt>-old_trans_mode }","IS_ALLOWED":"{ ls_rt_cur-is_allowed }","INSPECTOR_ID":"{ ls_rt_cur-inspector_id }"\}|.
          ls_log-new_data = |\{"TRANS_MODE":"{ <rt>-trans_mode }","IS_ALLOWED":"{ <rt>-is_allowed }","INSPECTOR_ID":"{ <rt>-inspector_id }"\}|.
        WHEN OTHERS.
          ls_log-action_type = 'DELETE'.
          SELECT SINGLE is_allowed, inspector_id FROM zmmrouteconf
            WHERE item_id = @<rt>-source_item_id INTO @DATA(ls_rt_del).
          ls_log-old_data =
            |\{"ENV_ID":"{ iv_env_id }","PLANT_ID":"{ <rt>-old_plant_id }",| &&
            |"SEND_WH":"{ <rt>-old_send_wh }","RECEIVE_WH":"{ <rt>-old_receive_wh }",| &&
            |"TRANS_MODE":"{ <rt>-old_trans_mode }","IS_ALLOWED":"{ ls_rt_del-is_allowed }",| &&
            |"INSPECTOR_ID":"{ ls_rt_del-inspector_id }"\}|.
          ls_log-new_data = '{}'.
      ENDCASE.
      ls_log-changed_by = iv_changed_by.
      ls_log-changed_at = iv_now.
      APPEND ls_log TO rt_logs.

      CASE <rt>-action_type.
        WHEN 'U'.
          SELECT SINGLE @abap_true FROM zmmrouteconf WHERE item_id = @<rt>-source_item_id INTO @DATA(lv_exists).
          IF lv_exists = abap_true.
            UPDATE zmmrouteconf SET
              inspector_id = @<rt>-inspector_id,
              trans_mode   = @<rt>-trans_mode,
              is_allowed   = @<rt>-is_allowed,
              version_no   = @<rt>-version_no,
              req_id       = @iv_req_id,
              changed_by   = @iv_changed_by,
              changed_at   = @iv_now
            WHERE item_id = @<rt>-source_item_id.
          ENDIF.
        WHEN 'C'.
          INSERT zmmrouteconf FROM @( VALUE zmmrouteconf(
            client     = sy-mandt
            item_id    = <rt>-item_id
            req_id     = iv_req_id
            env_id     = iv_env_id
            plant_id   = <rt>-plant_id
            send_wh    = <rt>-send_wh
            receive_wh = <rt>-receive_wh
            trans_mode = <rt>-trans_mode
            is_allowed = <rt>-is_allowed
            version_no = 1
            created_at = iv_now
            changed_by = iv_changed_by
            changed_at = iv_now ) ).
        WHEN OTHERS.
          DELETE FROM zmmrouteconf WHERE item_id = @<rt>-source_item_id.
      ENDCASE.
    ENDLOOP.

    UPDATE zmmrouteconf_req SET
      line_status = 'APPROVED',
      changed_by  = @iv_changed_by,
      changed_at  = @iv_now
    WHERE req_id = @iv_req_id.
  ENDMETHOD.

  METHOD write_back_fi.
    SELECT * FROM zfilimitreq WHERE req_id = @iv_req_id INTO TABLE @DATA(lt_req).
    CHECK lt_req IS NOT INITIAL.

    LOOP AT lt_req ASSIGNING FIELD-SYMBOL(<fi>).
      DATA ls_log TYPE zauditlog.
      ls_log-client     = sy-mandt.
      TRY. ls_log-log_id = cl_system_uuid=>create_uuid_x16_static( ). CATCH cx_uuid_error. ENDTRY.
      ls_log-req_id     = iv_req_id.
      ls_log-conf_id    = <fi>-conf_id.
      ls_log-module_id  = 'FI'.
      ls_log-table_name = 'ZFILIMITCONF'.
      ls_log-env_id     = iv_env_id.
      ls_log-object_key = COND #( WHEN <fi>-action_type = 'C' THEN <fi>-item_id ELSE <fi>-source_item_id ).
      CASE <fi>-action_type.
        WHEN 'C'.
          ls_log-action_type = 'CREATE'.
          ls_log-old_data    = '{}'.
          ls_log-new_data    = |\{"EXPENSE_TYPE":"{ <fi>-expense_type }","GL_ACCOUNT":"{ <fi>-gl_account }","AUTO_APPR_LIM":"{ <fi>-auto_appr_lim }","CURRENCY":"{ <fi>-currency }"\}|.
        WHEN 'U'.
          ls_log-action_type = 'UPDATE'.
          ls_log-old_data    = |\{"AUTO_APPR_LIM":"{ <fi>-old_auto_appr_lim }","CURRENCY":"{ <fi>-old_currency }"\}|.
          ls_log-new_data    = |\{"AUTO_APPR_LIM":"{ <fi>-auto_appr_lim }","CURRENCY":"{ <fi>-currency }"\}|.
        WHEN OTHERS.
          ls_log-action_type = 'DELETE'.
          ls_log-old_data    = |\{"ENV_ID":"{ iv_env_id }","EXPENSE_TYPE":"{ <fi>-old_expense_type }","GL_ACCOUNT":"{ <fi>-old_gl_account }","AUTO_APPR_LIM":"{ <fi>-old_auto_appr_lim }","CURRENCY":"{ <fi>-old_currency }"\}|.
          ls_log-new_data    = '{}'.
      ENDCASE.
      ls_log-changed_by = iv_changed_by.
      ls_log-changed_at = iv_now.
      APPEND ls_log TO rt_logs.

      CASE <fi>-action_type.
        WHEN 'U'.
          SELECT SINGLE @abap_true FROM zfilimitconf WHERE item_id = @<fi>-source_item_id INTO @DATA(lv_exists).
          IF lv_exists = abap_true.
            UPDATE zfilimitconf SET
              auto_appr_lim = @<fi>-auto_appr_lim,
              currency      = @<fi>-currency,
              version_no    = @<fi>-version_no,
              req_id        = @iv_req_id,
              changed_by    = @iv_changed_by,
              changed_at    = @iv_now
            WHERE item_id = @<fi>-source_item_id.
          ENDIF.
        WHEN 'C'.
          INSERT zfilimitconf FROM @( VALUE zfilimitconf(
            client        = sy-mandt
            item_id       = <fi>-item_id
            req_id        = iv_req_id
            env_id        = iv_env_id
            expense_type  = <fi>-expense_type
            gl_account    = <fi>-gl_account
            auto_appr_lim = <fi>-auto_appr_lim
            currency      = <fi>-currency
            version_no    = 1
            created_at    = iv_now
            changed_by    = iv_changed_by
            changed_at    = iv_now ) ).
        WHEN OTHERS.
          DELETE FROM zfilimitconf WHERE item_id = @<fi>-source_item_id.
      ENDCASE.
    ENDLOOP.

    UPDATE zfilimitreq SET
      line_status = 'APPROVED',
      changed_by  = @iv_changed_by,
      changed_at  = @iv_now
    WHERE req_id = @iv_req_id.
  ENDMETHOD.

  METHOD write_back_sd.
    SELECT * FROM zsd_price_req WHERE req_id = @iv_req_id INTO TABLE @DATA(lt_req).
    CHECK lt_req IS NOT INITIAL.

    LOOP AT lt_req ASSIGNING FIELD-SYMBOL(<sd>).
      DATA ls_log TYPE zauditlog.
      ls_log-client     = sy-mandt.
      TRY. ls_log-log_id = cl_system_uuid=>create_uuid_x16_static( ). CATCH cx_uuid_error. ENDTRY.
      ls_log-req_id     = iv_req_id.
      ls_log-conf_id    = <sd>-conf_id.
      ls_log-module_id  = 'SD'.
      ls_log-table_name = 'ZSD_PRICE_CONF'.
      ls_log-env_id     = iv_env_id.
      ls_log-object_key = COND #( WHEN <sd>-action_type = 'C' THEN <sd>-item_id ELSE <sd>-source_item_id ).
      CASE <sd>-action_type.
        WHEN 'C'.
          ls_log-action_type = 'CREATE'.
          ls_log-old_data    = '{}'.
          ls_log-new_data    =
            |\{"BRANCH_ID":"{ <sd>-branch_id }","CUST_GROUP":"{ <sd>-cust_group }",| &&
            |"MATERIAL_GRP":"{ <sd>-material_grp }","MAX_DISCOUNT":"{ <sd>-max_discount }",| &&
            |"MIN_ORDER_VAL":"{ <sd>-min_order_val }","APPROVER_GRP":"{ <sd>-approver_grp }",| &&
            |"CURRENCY":"{ <sd>-currency }","VALID_FROM":"{ <sd>-valid_from }","VALID_TO":"{ <sd>-valid_to }"\}|.
        WHEN 'U'.
          ls_log-action_type = 'UPDATE'.
          SELECT SINGLE approver_grp, currency, valid_from, valid_to FROM zsd_price_conf
            WHERE item_id = @<sd>-source_item_id INTO @DATA(ls_sd_cur).
          ls_log-old_data =
            |\{"MAX_DISCOUNT":"{ <sd>-old_max_discount }","MIN_ORDER_VAL":"{ <sd>-old_min_order_val }",| &&
            |"APPROVER_GRP":"{ ls_sd_cur-approver_grp }","CURRENCY":"{ ls_sd_cur-currency }",| &&
            |"VALID_FROM":"{ ls_sd_cur-valid_from }","VALID_TO":"{ ls_sd_cur-valid_to }"\}|.
          ls_log-new_data =
            |\{"MAX_DISCOUNT":"{ <sd>-max_discount }","MIN_ORDER_VAL":"{ <sd>-min_order_val }",| &&
            |"APPROVER_GRP":"{ <sd>-approver_grp }","CURRENCY":"{ <sd>-currency }",| &&
            |"VALID_FROM":"{ <sd>-valid_from }","VALID_TO":"{ <sd>-valid_to }"\}|.
        WHEN OTHERS.
          ls_log-action_type = 'DELETE'.
          SELECT SINGLE approver_grp, currency, valid_from, valid_to FROM zsd_price_conf
            WHERE item_id = @<sd>-source_item_id INTO @DATA(ls_sd_del).
          ls_log-old_data =
            |\{"ENV_ID":"{ iv_env_id }","BRANCH_ID":"{ <sd>-old_branch_id }","CUST_GROUP":"{ <sd>-old_cust_group }",| &&
            |"MATERIAL_GRP":"{ <sd>-old_material_grp }","MAX_DISCOUNT":"{ <sd>-old_max_discount }",| &&
            |"MIN_ORDER_VAL":"{ <sd>-old_min_order_val }","APPROVER_GRP":"{ ls_sd_del-approver_grp }",| &&
            |"CURRENCY":"{ ls_sd_del-currency }","VALID_FROM":"{ ls_sd_del-valid_from }","VALID_TO":"{ ls_sd_del-valid_to }"\}|.
          ls_log-new_data = '{}'.
      ENDCASE.
      ls_log-changed_by = iv_changed_by.
      ls_log-changed_at = iv_now.
      APPEND ls_log TO rt_logs.

      CASE <sd>-action_type.
        WHEN 'U'.
          SELECT SINGLE @abap_true FROM zsd_price_conf WHERE item_id = @<sd>-source_item_id INTO @DATA(lv_exists).
          IF lv_exists = abap_true.
            UPDATE zsd_price_conf SET
              max_discount  = @<sd>-max_discount,
              min_order_val = @<sd>-min_order_val,
              approver_grp  = @<sd>-approver_grp,
              currency      = @<sd>-currency,
              valid_from    = @<sd>-valid_from,
              valid_to      = @<sd>-valid_to,
              version_no    = @<sd>-version_no,
              req_id        = @iv_req_id,
              changed_by    = @iv_changed_by,
              changed_at    = @iv_now
            WHERE item_id = @<sd>-source_item_id.
          ENDIF.
        WHEN 'C'.
          INSERT zsd_price_conf FROM @( VALUE zsd_price_conf(
            client        = sy-mandt
            item_id       = <sd>-item_id
            req_id        = iv_req_id
            env_id        = iv_env_id
            branch_id     = <sd>-branch_id
            cust_group    = <sd>-cust_group
            material_grp  = <sd>-material_grp
            max_discount  = <sd>-max_discount
            min_order_val = <sd>-min_order_val
            currency      = <sd>-currency
            valid_from    = <sd>-valid_from
            valid_to      = <sd>-valid_to
            version_no    = 1
            created_at    = iv_now
            changed_by    = iv_changed_by
            changed_at    = iv_now ) ).
        WHEN OTHERS.
          DELETE FROM zsd_price_conf WHERE item_id = @<sd>-source_item_id.
      ENDCASE.
    ENDLOOP.

    UPDATE zsd_price_req SET
      line_status = 'APPROVED',
      changed_by  = @iv_changed_by,
      changed_at  = @iv_now
    WHERE req_id = @iv_req_id.
  ENDMETHOD.

ENDCLASS.
