CLASS zcl_test_end_to_end DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_test_end_to_end IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA: lt_failed   TYPE RESPONSE FOR FAILED zir_conf_req_h,
          lt_reported TYPE RESPONSE FOR REPORTED zir_conf_req_h.

    out->write( '========== TEST TOÀN TẬP: APPROVE & PROMOTE ==========' ).

    " 1. CHUẨN BỊ DỮ LIỆU ĐẦY ĐỦ
    DATA(lv_req_id)  = cl_system_uuid=>create_uuid_x16_static( ).
    DATA(lv_item_id) = cl_system_uuid=>create_uuid_x16_static( ).
    DATA(lv_conf_id) = cl_system_uuid=>create_uuid_x16_static( ).

    INSERT zconfcatalog FROM @( VALUE #( client = sy-mandt conf_id = lv_conf_id is_active = abap_true ) ).
    INSERT zconfreqh FROM @( VALUE #( client = sy-mandt req_id = lv_req_id status = 'SUBMITTED' module_id = 'FI' env_id = 'DEV' ) ).
    INSERT zconfreqi FROM @( VALUE #( client = sy-mandt req_item_id = lv_item_id req_id = lv_req_id conf_id = lv_conf_id action = 'CREATE' target_env_id = 'PRD' ) ).
    COMMIT WORK.

    out->write( |-> Đã tạo xong Request ID: { lv_req_id } (Status: SUBMITTED)| ).

    " =========================================================================
    " 2. THỰC THI APPROVE (Dùng IF thay cho GOTO để tránh lỗi cú pháp)
    " =========================================================================
    out->write( |[1] Đang thực thi APPROVE...| ).
    MODIFY zuserrole FROM @( VALUE #( client = sy-mandt user_id = sy-uname role_level = 'MANAGER' is_active = abap_true ) ).
    COMMIT WORK.

    MODIFY ENTITIES OF zir_conf_req_h ENTITY Req EXECUTE approve FROM VALUE #( ( ReqId = lv_req_id ) )
      FAILED lt_failed REPORTED lt_reported.

    IF lt_failed IS INITIAL.
      out->write( '-> PASS: Approve thành công!' ).
      COMMIT ENTITIES.

      " =========================================================================
      " 3. THỰC THI PROMOTE (Chỉ chạy nếu Approve thành công)
      " =========================================================================
      out->write( |[2] Đang thực thi PROMOTE...| ).
      CLEAR: lt_failed, lt_reported.
      MODIFY zuserrole FROM @( VALUE #( client = sy-mandt user_id = sy-uname role_level = 'IT ADMIN' is_active = abap_true ) ).
      COMMIT WORK.

      MODIFY ENTITIES OF zir_conf_req_h ENTITY Req EXECUTE promote FROM VALUE #( ( ReqId = lv_req_id ) )
        FAILED lt_failed REPORTED lt_reported.

      IF lt_failed IS INITIAL.
        out->write( '-> PASS: Promote thành công!' ).
        COMMIT ENTITIES.
      ELSE.
        out->write( '-> FAIL: Promote thất bại!' ).
      ENDIF.

    ELSE.
      out->write( '-> FAIL: Approve thất bại. Chi tiết lỗi:' ).
      LOOP AT lt_reported-req INTO DATA(ls_rep).
        IF ls_rep-%msg IS BOUND. out->write( |   *** { ls_rep-%msg->if_message~get_text( ) }| ). ENDIF.
      ENDLOOP.
    ENDIF.

    " =========================================================================
    " 4. DỌN DẸP DỮ LIỆU (Luôn chạy ở cuối)
    " =========================================================================
    DELETE FROM zconfreqi WHERE req_item_id = @lv_item_id.
    DELETE FROM zconfreqh WHERE req_id = @lv_req_id.
    DELETE FROM zconfcatalog WHERE conf_id = @lv_conf_id.
    DELETE FROM zuserrole WHERE user_id = @sy-uname.
    COMMIT WORK.
    out->write( '========== HOÀN TẤT KIỂM TRA ==========' ).

  ENDMETHOD.
ENDCLASS.
