CLASS zcl_test_rule_classes DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_test_rule_classes IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    out->write( '========== KIỂM TRA PACKAGE RULE ==========' ).
    DATA(lv_req_id)  = cl_system_uuid=>create_uuid_x16_static( ).
    DATA(lv_conf_id) = cl_system_uuid=>create_uuid_x16_static( ).

    " =========================================================================
    " 1. KIỂM TRA WRITER: JSON, USER, TIMESTAMP
    " =========================================================================
    out->write( |\n[1] TEST ZCL_GSP26_RULE_WRITER...| ).
    TRY.
        TYPES: BEGIN OF ty_mock, price TYPE i, currency TYPE string, END OF ty_mock.
        DATA(ls_old) = VALUE ty_mock( price = 100 currency = 'VND' ).
        DATA(ls_new) = VALUE ty_mock( price = 500 currency = 'VND' ).

        " Đã bổ sung đủ các tham số bắt buộc theo cấu trúc của bạn
        zcl_gsp26_rule_writer=>log_audit_entry(
          iv_conf_id  = lv_conf_id
          iv_req_id   = lv_req_id
          iv_mod_id   = 'MOD01'
          iv_act_type = 'UPDATE'
          iv_tab_name = 'TEST_TAB'
          iv_env_id   = 'DEV'
          is_old_data = ls_old
          is_new_data = ls_new
        ).
        COMMIT WORK. WAIT UP TO 1 SECONDS.

        SELECT SINGLE old_data, new_data, changed_by, changed_at FROM zauditlog WHERE req_id = @lv_req_id INTO @DATA(ls_log).
        IF sy-subrc = 0.
          out->write( '-> PASS: Đã ghi log thành công!' ).
          out->write( |-> OLD_DATA: { ls_log-old_data }| ).
          out->write( |-> NEW_DATA: { ls_log-new_data }| ).
        ELSE.
          out->write( '-> FAIL: Không tìm thấy log trong DB!' ).
        ENDIF.
      CATCH cx_root INTO DATA(lx_err_writer).
        out->write( |-> FAIL: Code Writer bị lỗi: { lx_err_writer->get_text( ) }| ).
    ENDTRY.

    " =========================================================================
    " 2. KIỂM TRA VALIDATOR: Mandatory & Range Check
    " =========================================================================
    out->write( |\n[2] TEST ZCL_GSP26_RULE_VALIDATOR...| ).
    TRY.
        " Bơm Catalog giả để qua bài test check_catalog_existence
        INSERT zconfcatalog FROM @( VALUE #( client = sy-mandt conf_id = lv_conf_id is_active = abap_true ) ).
        " Bơm cấu hình trường giả: PRICE bắt buộc, min = 10, max = 100
        INSERT zconffielddef FROM @( VALUE #( client = sy-mandt conf_id = lv_conf_id field_name = 'PRICE' field_label = 'Giá bán' is_required = abap_true min_val = '10' max_val = '100' ) ).
        COMMIT WORK.

        DATA(ls_data_empty) = VALUE ty_mock( currency = 'VND' ). " Price rỗng
        DATA(lt_err1) = zcl_gsp26_rule_validator=>validate_request_item( iv_conf_id = lv_conf_id iv_action = 'CREATE' iv_target_env_id = 'DEV' is_data = ls_data_empty ).
        IF line_exists( lt_err1[ message = `Field 'Giá bán' is required` ] ).
          out->write( '-> PASS Mandatory Check: Chặn thành công lỗi để trống.' ).
        ELSE.
          out->write( '-> FAIL Mandatory Check: Cho phép dữ liệu rỗng lọt qua!' ).
        ENDIF.

        DATA(ls_data_out_range) = VALUE ty_mock( price = 5 currency = 'VND' ).
        DATA(lt_err2) = zcl_gsp26_rule_validator=>validate_request_item( iv_conf_id = lv_conf_id iv_action = 'CREATE' iv_target_env_id = 'DEV' is_data = ls_data_out_range ).
        IF line_exists( lt_err2[ field = 'PRICE' ] ).
          out->write( '-> PASS Range Check: Chặn thành công dữ liệu ngoài vùng (nhỏ hơn 10).' ).
        ELSE.
          out->write( '-> FAIL Range Check: Cho phép dữ liệu sai vùng lọt qua!' ).
        ENDIF.

      CATCH cx_root INTO DATA(lx_err_val).
        out->write( |-> FAIL: Code Validator bị lỗi: { lx_err_val->get_text( ) }| ).
    ENDTRY.

    " Dọn dẹp Database
    DELETE FROM zconffielddef WHERE conf_id = @lv_conf_id.
    DELETE FROM zconfcatalog WHERE conf_id = @lv_conf_id.
    COMMIT WORK.
    out->write( |\n========== HOÀN TẤT KIỂM TRA ==========| ).
  ENDMETHOD.
ENDCLASS.
