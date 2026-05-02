CLASS zcl_gsp26_rule_snapshot DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.

    TYPES: BEGIN OF ty_restore_result,
             success    TYPE abap_bool,
             message    TYPE string,
             table_name TYPE c LENGTH 30,
           END OF ty_restore_result.
    TYPES tt_restore_results TYPE STANDARD TABLE OF ty_restore_result WITH EMPTY KEY.

    CLASS-METHODS create_price_snapshot
      IMPORTING is_price_data TYPE zsd_price_conf.

    CLASS-METHODS restore_from_snapshot
      IMPORTING iv_req_id         TYPE sysuuid_x16
                iv_changed_by     TYPE syuname
      RETURNING VALUE(rt_results) TYPE tt_restore_results.

    CLASS-METHODS create_approve_snapshot
      IMPORTING iv_req_id         TYPE sysuuid_x16
                iv_changed_by     TYPE syuname
      RETURNING VALUE(rt_results) TYPE tt_restore_results.

    CLASS-METHODS increment_version
      IMPORTING iv_req_id         TYPE sysuuid_x16
      RETURNING VALUE(rt_results) TYPE tt_restore_results.

    CLASS-METHODS promote_mmss
      IMPORTING iv_req_id      TYPE sysuuid_x16
                iv_conf_id     TYPE sysuuid_x16
                iv_src_env_id  TYPE zde_env_id
                iv_tgt_env_id  TYPE zde_env_id
                iv_prd_ver     TYPE i
                iv_now         TYPE timestampl
                iv_changed_by  TYPE syuname
      RETURNING VALUE(rt_logs) TYPE zcl_gsp26_rule_writer=>tt_audit_logs.

    CLASS-METHODS promote_mmroute
      IMPORTING iv_req_id      TYPE sysuuid_x16
                iv_conf_id     TYPE sysuuid_x16
                iv_src_env_id  TYPE zde_env_id
                iv_tgt_env_id  TYPE zde_env_id
                iv_prd_ver     TYPE i
                iv_now         TYPE timestampl
                iv_changed_by  TYPE syuname
      RETURNING VALUE(rt_logs) TYPE zcl_gsp26_rule_writer=>tt_audit_logs.

    CLASS-METHODS promote_fi
      IMPORTING iv_req_id      TYPE sysuuid_x16
                iv_conf_id     TYPE sysuuid_x16
                iv_src_env_id  TYPE zde_env_id
                iv_tgt_env_id  TYPE zde_env_id
                iv_prd_ver     TYPE i
                iv_now         TYPE timestampl
                iv_changed_by  TYPE syuname
      RETURNING VALUE(rt_logs) TYPE zcl_gsp26_rule_writer=>tt_audit_logs.

    CLASS-METHODS promote_sd
      IMPORTING iv_req_id      TYPE sysuuid_x16
                iv_conf_id     TYPE sysuuid_x16
                iv_src_env_id  TYPE zde_env_id
                iv_tgt_env_id  TYPE zde_env_id
                iv_prd_ver     TYPE i
                iv_now         TYPE timestampl
                iv_changed_by  TYPE syuname
      RETURNING VALUE(rt_logs) TYPE zcl_gsp26_rule_writer=>tt_audit_logs.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_gsp26_rule_snapshot IMPLEMENTATION.

  METHOD create_price_snapshot.
    INSERT zsd_price_conf FROM is_price_data.
  ENDMETHOD.

  METHOD increment_version.

    " 1) Increment VERSION_NO for ZSD_PRICE_CONF
    SELECT MAX( version_no ) FROM zsd_price_conf
      WHERE req_id = @iv_req_id
      INTO @DATA(lv_max_price_ver).

    IF sy-subrc = 0.
      DATA(lv_new_price_ver) = lv_max_price_ver + 1.
      UPDATE zsd_price_conf
        SET version_no = @lv_new_price_ver
        WHERE req_id = @iv_req_id.

      IF sy-dbcnt > 0.
        APPEND VALUE #( success    = abap_true
                        message    = |SD Price version incremented to { lv_new_price_ver }|
                        table_name = 'ZSD_PRICE_CONF' )
          TO rt_results.
      ENDIF.
    ENDIF.

    " 2) Increment VERSION_NO for ZMMSAFESTOCK
    SELECT MAX( version_no ) FROM zmmsafestock
      WHERE req_id = @iv_req_id
      INTO @DATA(lv_max_stock_ver).

    IF sy-subrc = 0.
      DATA(lv_new_stock_ver) = lv_max_stock_ver + 1.
      UPDATE zmmsafestock
        SET version_no = @lv_new_stock_ver
        WHERE req_id = @iv_req_id.

      IF sy-dbcnt > 0.
        APPEND VALUE #( success    = abap_true
                        message    = |MM Safe Stock version incremented to { lv_new_stock_ver }|
                        table_name = 'ZMMSAFESTOCK' )
          TO rt_results.
      ENDIF.
    ENDIF.

    IF rt_results IS INITIAL.
      APPEND VALUE #( success    = abap_false
                      message    = 'No config records found to version' )
        TO rt_results.
    ENDIF.

  ENDMETHOD.

  METHOD create_approve_snapshot.
    DATA lt_logs TYPE STANDARD TABLE OF zauditlog.
    DATA ls_log TYPE zauditlog.

    " 1) Snapshot ZSD_PRICE_CONF records
    SELECT * FROM zsd_price_conf
      WHERE req_id = @iv_req_id
      INTO TABLE @DATA(lt_price).

    LOOP AT lt_price INTO DATA(ls_price).
      CLEAR ls_log.
      TRY.
          ls_log-log_id = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error.
          CONTINUE.
      ENDTRY.
      ls_log-req_id      = iv_req_id.
      ls_log-conf_id     = ls_price-item_id.
      ls_log-module_id   = 'SD'.
      ls_log-action_type = 'APPROVE'.
      ls_log-table_name  = 'ZSD_PRICE_CONF'.
      ls_log-env_id      = ls_price-env_id.
      ls_log-object_key  = ls_price-item_id.
      ls_log-changed_by  = iv_changed_by.
      GET TIME STAMP FIELD ls_log-changed_at.
      APPEND ls_log TO lt_logs.
    ENDLOOP.

    IF lt_price IS NOT INITIAL.
      APPEND VALUE #( success    = abap_true
                      message    = 'SD Price snapshot created'
                      table_name = 'ZSD_PRICE_CONF' )
        TO rt_results.
    ENDIF.

    " 2) Snapshot ZMMSAFESTOCK records
    SELECT * FROM zmmsafestock
      WHERE req_id = @iv_req_id
      INTO TABLE @DATA(lt_stock).

    LOOP AT lt_stock INTO DATA(ls_stock).
      CLEAR ls_log.
      TRY.
          ls_log-log_id = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error.
          CONTINUE.
      ENDTRY.
      ls_log-req_id      = iv_req_id.
      ls_log-conf_id     = ls_stock-item_id.
      ls_log-module_id   = 'MM'.
      ls_log-action_type = 'APPROVE'.
      ls_log-table_name  = 'ZMMSAFESTOCK'.
      ls_log-env_id      = ls_stock-env_id.
      ls_log-object_key  = ls_stock-item_id.
      ls_log-changed_by  = iv_changed_by.
      GET TIME STAMP FIELD ls_log-changed_at.
      APPEND ls_log TO lt_logs.
    ENDLOOP.

    IF lt_stock IS NOT INITIAL.
      APPEND VALUE #( success    = abap_true
                      message    = 'MM Safe Stock snapshot created'
                      table_name = 'ZMMSAFESTOCK' )
        TO rt_results.
    ENDIF.

    " Batch INSERT — 1 lần thay vì từng dòng
    IF lt_logs IS NOT INITIAL.
      INSERT zauditlog FROM TABLE @lt_logs.
    ENDIF.

    IF rt_results IS INITIAL.
      APPEND VALUE #( success    = abap_false
                      message    = 'No config data found for request' )
        TO rt_results.
    ENDIF.

  ENDMETHOD.
  METHOD restore_from_snapshot.

    DATA ls_log TYPE zauditlog.

    SELECT log_id, req_id, conf_id, module_id,
           action_type, table_name,
           old_data, new_data,
           env_id, object_key
      FROM zauditlog
      WHERE req_id = @iv_req_id
        AND ( action_type = 'PROMOTE'
           OR action_type = 'CREATE'
           OR action_type = 'UPDATE'
           OR action_type = 'DELETE' )
        AND table_name <> 'ZCONFREQH'
      INTO TABLE @DATA(lt_snapshots).

    IF lt_snapshots IS INITIAL.
      APPEND VALUE #( success = abap_false
                      message = 'No snapshot found for this request' )
        TO rt_results.
      RETURN.
    ENDIF.

    LOOP AT lt_snapshots INTO DATA(ls_snap).

      CASE ls_snap-table_name.
        WHEN 'ZSD_PRICE_CONF'.
          DATA ls_price TYPE zsd_price_conf.
          IF ls_snap-old_data IS NOT INITIAL AND ls_snap-old_data <> '{}'.
            /ui2/cl_json=>deserialize( EXPORTING json = ls_snap-old_data CHANGING data = ls_price ).
            IF ls_price-env_id IS NOT INITIAL.
              " Full row (rollback DELETE): re-insert the deleted row
              ls_price-item_id = ls_snap-object_key.
              ls_price-client  = sy-mandt.
              MODIFY zsd_price_conf FROM @ls_price.
            ELSE.
              " Partial data (rollback UPDATE): update only value fields in-place
              UPDATE zsd_price_conf SET
                max_discount  = @ls_price-max_discount,
                min_order_val = @ls_price-min_order_val,
                approver_grp  = @ls_price-approver_grp,
                currency      = @ls_price-currency,
                valid_from    = @ls_price-valid_from,
                valid_to      = @ls_price-valid_to
              WHERE item_id = @ls_snap-object_key.
            ENDIF.
            APPEND VALUE #( success    = abap_true
                            message    = 'SD Price Config restored'
                            table_name = 'ZSD_PRICE_CONF' ) TO rt_results.
          ELSE.
            DELETE FROM zsd_price_conf WHERE item_id = @ls_snap-object_key.
            APPEND VALUE #( success    = abap_true
                            message    = 'SD Price Config deleted (rollback create)'
                            table_name = 'ZSD_PRICE_CONF' ) TO rt_results.
          ENDIF.

        WHEN 'ZMMSAFESTOCK'.
          DATA ls_stock TYPE zmmsafestock.
          IF ls_snap-old_data IS NOT INITIAL AND ls_snap-old_data <> '{}'.
            /ui2/cl_json=>deserialize( EXPORTING json = ls_snap-old_data CHANGING data = ls_stock ).
            IF ls_stock-env_id IS NOT INITIAL.
              " Full row (rollback DELETE): re-insert the deleted row
              ls_stock-item_id = ls_snap-object_key.
              ls_stock-client  = sy-mandt.
              MODIFY zmmsafestock FROM @ls_stock.
            ELSE.
              " Partial data (rollback UPDATE): update only value fields in-place
              UPDATE zmmsafestock SET min_qty = @ls_stock-min_qty
                WHERE item_id = @ls_snap-object_key.
            ENDIF.
            APPEND VALUE #( success    = abap_true
                            message    = 'MM Safe Stock restored'
                            table_name = 'ZMMSAFESTOCK' ) TO rt_results.
          ELSE.
            DELETE FROM zmmsafestock WHERE item_id = @ls_snap-object_key.
            APPEND VALUE #( success    = abap_true
                            message    = 'MM Safe Stock deleted (rollback create)'
                            table_name = 'ZMMSAFESTOCK' ) TO rt_results.
          ENDIF.

        WHEN 'ZFILIMITCONF'.
          DATA ls_limit TYPE zfilimitconf.
          IF ls_snap-old_data IS NOT INITIAL AND ls_snap-old_data <> '{}'.
            /ui2/cl_json=>deserialize( EXPORTING json = ls_snap-old_data CHANGING data = ls_limit ).
            IF ls_limit-env_id IS NOT INITIAL.
              " Full row (rollback DELETE): re-insert the deleted row
              ls_limit-item_id = ls_snap-object_key.
              ls_limit-client  = sy-mandt.
              MODIFY zfilimitconf FROM @ls_limit.
            ELSE.
              " Partial data (rollback UPDATE): update only value fields in-place
              UPDATE zfilimitconf SET
                auto_appr_lim = @ls_limit-auto_appr_lim,
                currency      = @ls_limit-currency
              WHERE item_id = @ls_snap-object_key.
            ENDIF.
            APPEND VALUE #( success    = abap_true
                            message    = 'FI Limit restored'
                            table_name = 'ZFILIMITCONF' ) TO rt_results.
          ELSE.
            DELETE FROM zfilimitconf WHERE item_id = @ls_snap-object_key.
            APPEND VALUE #( success    = abap_true
                            message    = 'FI Limit deleted (rollback create)'
                            table_name = 'ZFILIMITCONF' ) TO rt_results.
          ENDIF.

        WHEN 'ZMMROUTECONF'.
          DATA ls_route TYPE zmmrouteconf.
          IF ls_snap-old_data IS NOT INITIAL AND ls_snap-old_data <> '{}'.
            /ui2/cl_json=>deserialize( EXPORTING json = ls_snap-old_data CHANGING data = ls_route ).
            IF ls_route-env_id IS NOT INITIAL.
              " Full row (rollback DELETE): re-insert the deleted row
              ls_route-item_id = ls_snap-object_key.
              ls_route-client  = sy-mandt.
              MODIFY zmmrouteconf FROM @ls_route.
            ELSE.
              " Partial data (rollback UPDATE): update only value fields in-place
              UPDATE zmmrouteconf SET
                trans_mode   = @ls_route-trans_mode,
                is_allowed   = @ls_route-is_allowed,
                inspector_id = @ls_route-inspector_id
              WHERE item_id = @ls_snap-object_key.
            ENDIF.
            APPEND VALUE #( success    = abap_true
                            message    = 'MM Route Config restored'
                            table_name = 'ZMMROUTECONF' ) TO rt_results.
          ELSE.
            DELETE FROM zmmrouteconf WHERE item_id = @ls_snap-object_key.
            APPEND VALUE #( success    = abap_true
                            message    = 'MM Route Config deleted (rollback create)'
                            table_name = 'ZMMROUTECONF' ) TO rt_results.
          ENDIF.

        WHEN OTHERS.
          CONTINUE.
      ENDCASE.


      CLEAR ls_log.
      TRY.
          ls_log-log_id = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error.
          CONTINUE.
      ENDTRY.
      ls_log-req_id      = iv_req_id.
      ls_log-conf_id     = ls_snap-conf_id.
      ls_log-module_id   = ls_snap-module_id.
      ls_log-action_type = 'ROLLBACK'.
      ls_log-table_name  = ls_snap-table_name.
      ls_log-old_data    = ls_snap-new_data.
      ls_log-new_data    = ls_snap-old_data.
      ls_log-env_id      = ls_snap-env_id.
      ls_log-object_key  = ls_snap-object_key.
      ls_log-changed_by  = iv_changed_by.
      GET TIME STAMP FIELD ls_log-changed_at.
      INSERT zauditlog FROM @ls_log.

    ENDLOOP.

  ENDMETHOD.

  METHOD promote_mmss.
    DATA ls_log    TYPE zauditlog.
    DATA ls_dl_log TYPE zauditlog.
    DATA lv_ver    TYPE i.
    DATA lv_new_id TYPE sysuuid_x16.

    " ── Propagate C/U rows from source env ──────────────────────────
    SELECT * FROM zmmsafestock
      WHERE req_id = @iv_req_id AND env_id = @iv_src_env_id
      INTO TABLE @DATA(lt_src).
    LOOP AT lt_src ASSIGNING FIELD-SYMBOL(<ss>).
      lv_ver = COND #( WHEN iv_prd_ver > 0 THEN iv_prd_ver ELSE <ss>-version_no ).
      SELECT SINGLE item_id, min_qty FROM zmmsafestock
        WHERE env_id = @iv_tgt_env_id AND plant_id = @<ss>-plant_id AND mat_group = @<ss>-mat_group
        INTO @DATA(ls_tgt).
      CLEAR ls_log.
      TRY. ls_log-log_id = cl_system_uuid=>create_uuid_x16_static( ). CATCH cx_uuid_error. ENDTRY.
      ls_log-client = sy-mandt. ls_log-req_id = iv_req_id. ls_log-conf_id = iv_conf_id.
      ls_log-module_id = 'MM'. ls_log-action_type = 'PROMOTE'. ls_log-table_name = 'ZMMSAFESTOCK'.
      ls_log-env_id = iv_tgt_env_id. ls_log-changed_by = iv_changed_by. ls_log-changed_at = iv_now.
      IF sy-subrc = 0.
        UPDATE zmmsafestock SET min_qty = @<ss>-min_qty, version_no = @lv_ver,
          req_id = @iv_req_id, changed_by = @iv_changed_by, changed_at = @iv_now
          WHERE item_id = @ls_tgt-item_id.
        ls_log-object_key = ls_tgt-item_id.
        ls_log-old_data   = |\{"MIN_QTY":"{ ls_tgt-min_qty }"\}|.
        ls_log-new_data   = |\{"MIN_QTY":"{ <ss>-min_qty }"\}|.
      ELSE.
        TRY. lv_new_id = cl_system_uuid=>create_uuid_x16_static( ). CATCH cx_uuid_error. ENDTRY.
        INSERT zmmsafestock FROM @( VALUE zmmsafestock(
          client = sy-mandt item_id = lv_new_id req_id = iv_req_id env_id = iv_tgt_env_id
          plant_id = <ss>-plant_id mat_group = <ss>-mat_group min_qty = <ss>-min_qty
          version_no = lv_ver created_at = iv_now changed_by = iv_changed_by changed_at = iv_now ) ).
        ls_log-object_key = lv_new_id.
        ls_log-old_data   = '{}'.
        ls_log-new_data   = |\{"PLANT_ID":"{ <ss>-plant_id }","MAT_GROUP":"{ <ss>-mat_group }","MIN_QTY":"{ <ss>-min_qty }"\}|.
      ENDIF.
      APPEND ls_log TO rt_logs.
    ENDLOOP.

    " ── Propagate DELETE rows ───────────────────────────────────────
    SELECT * FROM zmmsafestock_req
      WHERE req_id = @iv_req_id AND ( action_type = 'X' OR action_type = 'DELETE' )
      INTO TABLE @DATA(lt_del).
    LOOP AT lt_del ASSIGNING FIELD-SYMBOL(<d>).
      SELECT SINGLE item_id, min_qty FROM zmmsafestock
        WHERE env_id = @iv_tgt_env_id AND plant_id = @<d>-old_plant_id AND mat_group = @<d>-old_mat_group
        INTO @DATA(ls_del_tgt).
      CHECK sy-subrc = 0.
      DELETE FROM zmmsafestock WHERE item_id = @ls_del_tgt-item_id.
      CHECK sy-dbcnt > 0.
      CLEAR ls_dl_log.
      TRY. ls_dl_log-log_id = cl_system_uuid=>create_uuid_x16_static( ). CATCH cx_uuid_error. ENDTRY.
      ls_dl_log-client = sy-mandt. ls_dl_log-req_id = iv_req_id. ls_dl_log-conf_id = iv_conf_id.
      ls_dl_log-module_id = 'MM'. ls_dl_log-action_type = 'PROMOTE'. ls_dl_log-table_name = 'ZMMSAFESTOCK'.
      ls_dl_log-env_id = iv_tgt_env_id. ls_dl_log-object_key = ls_del_tgt-item_id.
      ls_dl_log-old_data = |\{"ENV_ID":"{ iv_tgt_env_id }","PLANT_ID":"{ <d>-old_plant_id }","MAT_GROUP":"{ <d>-old_mat_group }","MIN_QTY":"{ ls_del_tgt-min_qty }"\}|.
      ls_dl_log-new_data = '{}'. ls_dl_log-changed_by = iv_changed_by. ls_dl_log-changed_at = iv_now.
      APPEND ls_dl_log TO rt_logs.
    ENDLOOP.
  ENDMETHOD.

  METHOD promote_mmroute.
    DATA ls_log    TYPE zauditlog.
    DATA ls_dl_log TYPE zauditlog.
    DATA lv_ver    TYPE i.
    DATA lv_new_id TYPE sysuuid_x16.

    " ── Propagate C/U rows ──────────────────────────────────────────
    SELECT * FROM zmmrouteconf
      WHERE req_id = @iv_req_id AND env_id = @iv_src_env_id
      INTO TABLE @DATA(lt_src).
    LOOP AT lt_src ASSIGNING FIELD-SYMBOL(<rt>).
      lv_ver = COND #( WHEN iv_prd_ver > 0 THEN iv_prd_ver ELSE <rt>-version_no ).
      SELECT SINGLE item_id, trans_mode, is_allowed, inspector_id FROM zmmrouteconf
        WHERE env_id = @iv_tgt_env_id AND plant_id = @<rt>-plant_id
          AND send_wh = @<rt>-send_wh AND receive_wh = @<rt>-receive_wh
        INTO @DATA(ls_tgt).
      CLEAR ls_log.
      TRY. ls_log-log_id = cl_system_uuid=>create_uuid_x16_static( ). CATCH cx_uuid_error. ENDTRY.
      ls_log-client = sy-mandt. ls_log-req_id = iv_req_id. ls_log-conf_id = iv_conf_id.
      ls_log-module_id = 'MM'. ls_log-action_type = 'PROMOTE'. ls_log-table_name = 'ZMMROUTECONF'.
      ls_log-env_id = iv_tgt_env_id. ls_log-changed_by = iv_changed_by. ls_log-changed_at = iv_now.
      IF sy-subrc = 0.
        UPDATE zmmrouteconf SET inspector_id = @<rt>-inspector_id, trans_mode = @<rt>-trans_mode,
          is_allowed = @<rt>-is_allowed, version_no = @lv_ver, req_id = @iv_req_id,
          changed_by = @iv_changed_by, changed_at = @iv_now WHERE item_id = @ls_tgt-item_id.
        ls_log-object_key = ls_tgt-item_id.
        ls_log-old_data   = |\{"TRANS_MODE":"{ ls_tgt-trans_mode }","IS_ALLOWED":"{ ls_tgt-is_allowed }","INSPECTOR_ID":"{ ls_tgt-inspector_id }"\}|.
        ls_log-new_data   = |\{"TRANS_MODE":"{ <rt>-trans_mode }","IS_ALLOWED":"{ <rt>-is_allowed }","INSPECTOR_ID":"{ <rt>-inspector_id }"\}|.
      ELSE.
        TRY. lv_new_id = cl_system_uuid=>create_uuid_x16_static( ). CATCH cx_uuid_error. ENDTRY.
        INSERT zmmrouteconf FROM @( VALUE zmmrouteconf(
          client = sy-mandt item_id = lv_new_id req_id = iv_req_id env_id = iv_tgt_env_id
          plant_id = <rt>-plant_id send_wh = <rt>-send_wh receive_wh = <rt>-receive_wh
          trans_mode = <rt>-trans_mode is_allowed = <rt>-is_allowed inspector_id = <rt>-inspector_id
          version_no = lv_ver created_at = iv_now changed_by = iv_changed_by changed_at = iv_now ) ).
        ls_log-object_key = lv_new_id.
        ls_log-old_data   = '{}'.
        ls_log-new_data   = |\{"PLANT_ID":"{ <rt>-plant_id }","SEND_WH":"{ <rt>-send_wh }","RECEIVE_WH":"{ <rt>-receive_wh }","TRANS_MODE":"{ <rt>-trans_mode }","IS_ALLOWED":"{ <rt>-is_allowed }"\}|.
      ENDIF.
      APPEND ls_log TO rt_logs.
    ENDLOOP.

    " ── Propagate DELETE rows ───────────────────────────────────────
    SELECT * FROM zmmrouteconf_req
      WHERE req_id = @iv_req_id AND action_type = 'X'
      INTO TABLE @DATA(lt_del).
    LOOP AT lt_del ASSIGNING FIELD-SYMBOL(<d>).
      SELECT SINGLE item_id, trans_mode, is_allowed, inspector_id FROM zmmrouteconf
        WHERE env_id = @iv_tgt_env_id AND plant_id = @<d>-old_plant_id
          AND send_wh = @<d>-old_send_wh AND receive_wh = @<d>-old_receive_wh
        INTO @DATA(ls_del_tgt).
      CHECK sy-subrc = 0.
      DELETE FROM zmmrouteconf WHERE item_id = @ls_del_tgt-item_id.
      CHECK sy-dbcnt > 0.
      CLEAR ls_dl_log.
      TRY. ls_dl_log-log_id = cl_system_uuid=>create_uuid_x16_static( ). CATCH cx_uuid_error. ENDTRY.
      ls_dl_log-client = sy-mandt. ls_dl_log-req_id = iv_req_id. ls_dl_log-conf_id = iv_conf_id.
      ls_dl_log-module_id = 'MM'. ls_dl_log-action_type = 'PROMOTE'. ls_dl_log-table_name = 'ZMMROUTECONF'.
      ls_dl_log-env_id = iv_tgt_env_id. ls_dl_log-object_key = ls_del_tgt-item_id.
      ls_dl_log-old_data =
        |\{"ENV_ID":"{ iv_tgt_env_id }","PLANT_ID":"{ <d>-old_plant_id }",| &&
        |"SEND_WH":"{ <d>-old_send_wh }","RECEIVE_WH":"{ <d>-old_receive_wh }",| &&
        |"TRANS_MODE":"{ ls_del_tgt-trans_mode }","IS_ALLOWED":"{ ls_del_tgt-is_allowed }",| &&
        |"INSPECTOR_ID":"{ ls_del_tgt-inspector_id }"\}|.
      ls_dl_log-new_data = '{}'. ls_dl_log-changed_by = iv_changed_by. ls_dl_log-changed_at = iv_now.
      APPEND ls_dl_log TO rt_logs.
    ENDLOOP.
  ENDMETHOD.

  METHOD promote_fi.
    DATA ls_log    TYPE zauditlog.
    DATA ls_dl_log TYPE zauditlog.
    DATA lv_ver    TYPE i.
    DATA lv_new_id TYPE sysuuid_x16.

    " ── Propagate C/U rows ──────────────────────────────────────────
    SELECT * FROM zfilimitconf
      WHERE req_id = @iv_req_id AND env_id = @iv_src_env_id
      INTO TABLE @DATA(lt_src).
    LOOP AT lt_src ASSIGNING FIELD-SYMBOL(<fi>).
      lv_ver = COND #( WHEN iv_prd_ver > 0 THEN iv_prd_ver ELSE <fi>-version_no ).
      SELECT SINGLE item_id, auto_appr_lim, currency FROM zfilimitconf
        WHERE env_id = @iv_tgt_env_id AND expense_type = @<fi>-expense_type AND gl_account = @<fi>-gl_account
        INTO @DATA(ls_tgt).
      CLEAR ls_log.
      TRY. ls_log-log_id = cl_system_uuid=>create_uuid_x16_static( ). CATCH cx_uuid_error. ENDTRY.
      ls_log-client = sy-mandt. ls_log-req_id = iv_req_id. ls_log-conf_id = iv_conf_id.
      ls_log-module_id = 'FI'. ls_log-action_type = 'PROMOTE'. ls_log-table_name = 'ZFILIMITCONF'.
      ls_log-env_id = iv_tgt_env_id. ls_log-changed_by = iv_changed_by. ls_log-changed_at = iv_now.
      IF sy-subrc = 0.
        UPDATE zfilimitconf SET auto_appr_lim = @<fi>-auto_appr_lim, currency = @<fi>-currency,
          version_no = @lv_ver, req_id = @iv_req_id, changed_by = @iv_changed_by, changed_at = @iv_now
          WHERE item_id = @ls_tgt-item_id.
        ls_log-object_key = ls_tgt-item_id.
        ls_log-old_data   = |\{"AUTO_APPR_LIM":"{ ls_tgt-auto_appr_lim }","CURRENCY":"{ ls_tgt-currency }"\}|.
        ls_log-new_data   = |\{"AUTO_APPR_LIM":"{ <fi>-auto_appr_lim }","CURRENCY":"{ <fi>-currency }"\}|.
      ELSE.
        TRY. lv_new_id = cl_system_uuid=>create_uuid_x16_static( ). CATCH cx_uuid_error. ENDTRY.
        INSERT zfilimitconf FROM @( VALUE zfilimitconf(
          client = sy-mandt item_id = lv_new_id req_id = iv_req_id env_id = iv_tgt_env_id
          expense_type = <fi>-expense_type gl_account = <fi>-gl_account
          auto_appr_lim = <fi>-auto_appr_lim currency = <fi>-currency
          version_no = lv_ver created_at = iv_now changed_by = iv_changed_by changed_at = iv_now ) ).
        ls_log-object_key = lv_new_id.
        ls_log-old_data   = '{}'.
        ls_log-new_data   = |\{"EXPENSE_TYPE":"{ <fi>-expense_type }","GL_ACCOUNT":"{ <fi>-gl_account }","AUTO_APPR_LIM":"{ <fi>-auto_appr_lim }","CURRENCY":"{ <fi>-currency }"\}|.
      ENDIF.
      APPEND ls_log TO rt_logs.
    ENDLOOP.

    " ── Propagate DELETE rows ───────────────────────────────────────
    SELECT * FROM zfilimitreq
      WHERE req_id = @iv_req_id AND action_type = 'X'
      INTO TABLE @DATA(lt_del).
    LOOP AT lt_del ASSIGNING FIELD-SYMBOL(<d>).
      SELECT SINGLE item_id, auto_appr_lim, currency FROM zfilimitconf
        WHERE env_id = @iv_tgt_env_id AND expense_type = @<d>-old_expense_type AND gl_account = @<d>-old_gl_account
        INTO @DATA(ls_del_tgt).
      CHECK sy-subrc = 0.
      DELETE FROM zfilimitconf WHERE item_id = @ls_del_tgt-item_id.
      CHECK sy-dbcnt > 0.
      CLEAR ls_dl_log.
      TRY. ls_dl_log-log_id = cl_system_uuid=>create_uuid_x16_static( ). CATCH cx_uuid_error. ENDTRY.
      ls_dl_log-client = sy-mandt. ls_dl_log-req_id = iv_req_id. ls_dl_log-conf_id = iv_conf_id.
      ls_dl_log-module_id = 'FI'. ls_dl_log-action_type = 'PROMOTE'. ls_dl_log-table_name = 'ZFILIMITCONF'.
      ls_dl_log-env_id = iv_tgt_env_id. ls_dl_log-object_key = ls_del_tgt-item_id.
      ls_dl_log-old_data =
        |\{"ENV_ID":"{ iv_tgt_env_id }","EXPENSE_TYPE":"{ <d>-old_expense_type }",| &&
        |"GL_ACCOUNT":"{ <d>-old_gl_account }","AUTO_APPR_LIM":"{ ls_del_tgt-auto_appr_lim }",| &&
        |"CURRENCY":"{ ls_del_tgt-currency }"\}|.
      ls_dl_log-new_data = '{}'. ls_dl_log-changed_by = iv_changed_by. ls_dl_log-changed_at = iv_now.
      APPEND ls_dl_log TO rt_logs.
    ENDLOOP.
  ENDMETHOD.

  METHOD promote_sd.
    DATA ls_log    TYPE zauditlog.
    DATA ls_dl_log TYPE zauditlog.
    DATA lv_ver    TYPE i.
    DATA lv_new_id TYPE sysuuid_x16.

    " ── Propagate C/U rows ──────────────────────────────────────────
    SELECT * FROM zsd_price_conf
      WHERE req_id = @iv_req_id AND env_id = @iv_src_env_id
      INTO TABLE @DATA(lt_src).
    LOOP AT lt_src ASSIGNING FIELD-SYMBOL(<sd>).
      lv_ver = COND #( WHEN iv_prd_ver > 0 THEN iv_prd_ver ELSE <sd>-version_no ).
      SELECT SINGLE item_id, max_discount, min_order_val, approver_grp, currency, valid_from, valid_to
        FROM zsd_price_conf
        WHERE env_id = @iv_tgt_env_id AND branch_id = @<sd>-branch_id
          AND cust_group = @<sd>-cust_group AND material_grp = @<sd>-material_grp
        INTO @DATA(ls_tgt).
      CLEAR ls_log.
      TRY. ls_log-log_id = cl_system_uuid=>create_uuid_x16_static( ). CATCH cx_uuid_error. ENDTRY.
      ls_log-client = sy-mandt. ls_log-req_id = iv_req_id. ls_log-conf_id = iv_conf_id.
      ls_log-module_id = 'SD'. ls_log-action_type = 'PROMOTE'. ls_log-table_name = 'ZSD_PRICE_CONF'.
      ls_log-env_id = iv_tgt_env_id. ls_log-changed_by = iv_changed_by. ls_log-changed_at = iv_now.
      IF sy-subrc = 0.
        UPDATE zsd_price_conf SET max_discount = @<sd>-max_discount, min_order_val = @<sd>-min_order_val,
          approver_grp = @<sd>-approver_grp, currency = @<sd>-currency, valid_from = @<sd>-valid_from,
          valid_to = @<sd>-valid_to, version_no = @lv_ver, req_id = @iv_req_id,
          changed_by = @iv_changed_by, changed_at = @iv_now WHERE item_id = @ls_tgt-item_id.
        ls_log-object_key = ls_tgt-item_id.
        ls_log-old_data =
          |\{"MAX_DISCOUNT":"{ ls_tgt-max_discount }","MIN_ORDER_VAL":"{ ls_tgt-min_order_val }",| &&
          |"APPROVER_GRP":"{ ls_tgt-approver_grp }","CURRENCY":"{ ls_tgt-currency }",| &&
          |"VALID_FROM":"{ ls_tgt-valid_from }","VALID_TO":"{ ls_tgt-valid_to }"\}|.
        ls_log-new_data =
          |\{"MAX_DISCOUNT":"{ <sd>-max_discount }","MIN_ORDER_VAL":"{ <sd>-min_order_val }",| &&
          |"APPROVER_GRP":"{ <sd>-approver_grp }","CURRENCY":"{ <sd>-currency }",| &&
          |"VALID_FROM":"{ <sd>-valid_from }","VALID_TO":"{ <sd>-valid_to }"\}|.
      ELSE.
        TRY. lv_new_id = cl_system_uuid=>create_uuid_x16_static( ). CATCH cx_uuid_error. ENDTRY.
        INSERT zsd_price_conf FROM @( VALUE zsd_price_conf(
          client = sy-mandt item_id = lv_new_id req_id = iv_req_id env_id = iv_tgt_env_id
          branch_id = <sd>-branch_id cust_group = <sd>-cust_group material_grp = <sd>-material_grp
          max_discount = <sd>-max_discount min_order_val = <sd>-min_order_val
          approver_grp = <sd>-approver_grp currency = <sd>-currency
          valid_from = <sd>-valid_from valid_to = <sd>-valid_to
          version_no = lv_ver created_at = iv_now changed_by = iv_changed_by changed_at = iv_now ) ).
        ls_log-object_key = lv_new_id.
        ls_log-old_data = '{}'.
        ls_log-new_data =
          |\{"BRANCH_ID":"{ <sd>-branch_id }","CUST_GROUP":"{ <sd>-cust_group }",| &&
          |"MATERIAL_GRP":"{ <sd>-material_grp }","MAX_DISCOUNT":"{ <sd>-max_discount }",| &&
          |"MIN_ORDER_VAL":"{ <sd>-min_order_val }","APPROVER_GRP":"{ <sd>-approver_grp }",| &&
          |"CURRENCY":"{ <sd>-currency }","VALID_FROM":"{ <sd>-valid_from }","VALID_TO":"{ <sd>-valid_to }"\}|.
      ENDIF.
      APPEND ls_log TO rt_logs.
    ENDLOOP.

    " ── Propagate DELETE rows ───────────────────────────────────────
    SELECT * FROM zsd_price_req
      WHERE req_id = @iv_req_id AND action_type = 'X'
      INTO TABLE @DATA(lt_del).
    LOOP AT lt_del ASSIGNING FIELD-SYMBOL(<d>).
      SELECT SINGLE item_id, max_discount, min_order_val, approver_grp, currency, valid_from, valid_to
        FROM zsd_price_conf
        WHERE env_id = @iv_tgt_env_id AND branch_id = @<d>-old_branch_id
          AND cust_group = @<d>-old_cust_group AND material_grp = @<d>-old_material_grp
        INTO @DATA(ls_del_tgt).
      CHECK sy-subrc = 0.
      DELETE FROM zsd_price_conf WHERE item_id = @ls_del_tgt-item_id.
      CHECK sy-dbcnt > 0.
      CLEAR ls_dl_log.
      TRY. ls_dl_log-log_id = cl_system_uuid=>create_uuid_x16_static( ). CATCH cx_uuid_error. ENDTRY.
      ls_dl_log-client = sy-mandt. ls_dl_log-req_id = iv_req_id. ls_dl_log-conf_id = iv_conf_id.
      ls_dl_log-module_id = 'SD'. ls_dl_log-action_type = 'PROMOTE'. ls_dl_log-table_name = 'ZSD_PRICE_CONF'.
      ls_dl_log-env_id = iv_tgt_env_id. ls_dl_log-object_key = ls_del_tgt-item_id.
      ls_dl_log-old_data =
        |\{"ENV_ID":"{ iv_tgt_env_id }","BRANCH_ID":"{ <d>-old_branch_id }",| &&
        |"CUST_GROUP":"{ <d>-old_cust_group }","MATERIAL_GRP":"{ <d>-old_material_grp }",| &&
        |"MAX_DISCOUNT":"{ ls_del_tgt-max_discount }","MIN_ORDER_VAL":"{ ls_del_tgt-min_order_val }",| &&
        |"APPROVER_GRP":"{ ls_del_tgt-approver_grp }","CURRENCY":"{ ls_del_tgt-currency }",| &&
        |"VALID_FROM":"{ ls_del_tgt-valid_from }","VALID_TO":"{ ls_del_tgt-valid_to }"\}|.
      ls_dl_log-new_data = '{}'. ls_dl_log-changed_by = iv_changed_by. ls_dl_log-changed_at = iv_now.
      APPEND ls_dl_log TO rt_logs.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

