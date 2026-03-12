CLASS zcl_test_rap_flow DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_test_rap_flow IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA: lt_failed   TYPE RESPONSE FOR FAILED zir_conf_req_h,
          lt_reported TYPE RESPONSE FOR REPORTED zir_conf_req_h.

    out->write( '=== BẮT ĐẦU KIỂM TRA LUỒNG BUSINESS ===' ).

    " 1. Tìm xem có Request DRAFT nào sẵn không
    SELECT SINGLE req_id FROM zconfreqh WHERE status = 'DRAFT' INTO @DATA(lv_req_id).

    " 2. Nếu không có, tự động Insert cứng 1 dòng vào DB cho an toàn tuyệt đối
    IF sy-subrc <> 0.
      out->write( '-> Không có sẵn DRAFT. Đang tự động tạo 1 dữ liệu mẫu...' ).
      TRY.
          lv_req_id = cl_system_uuid=>create_uuid_x16_static( ).
          DATA(ls_new_req) = VALUE zconfreqh(
            client      = sy-mandt
            req_id      = lv_req_id
            status      = 'DRAFT'
            description = 'Dữ liệu sinh ra từ Class Test'
          ).
          INSERT zconfreqh FROM @ls_new_req.
          COMMIT WORK.
          out->write( |-> PASS: Đã tạo xong Request giả lập ID: { lv_req_id }| ).
        CATCH cx_root.
          out->write( '-> FAIL: Lỗi khi tạo dữ liệu mẫu!' ).
          RETURN.
      ENDTRY.
    ELSE.
      out->write( |-> Đang test với Request ID có sẵn: { lv_req_id }| ).
    ENDIF.

    out->write( '-------------------------------------------------------' ).

    " =========================================================================
    " BÀI TEST 1: CỐ TÌNH BẤM APPROVE KHI ĐANG Ở DRAFT (Kỳ vọng: Chặn lại)
    " =========================================================================
    out->write( '[TEST 1] Cố tình bấm Approve khi đang ở DRAFT...' ).

    MODIFY ENTITIES OF zir_conf_req_h
      ENTITY Req
      EXECUTE approve FROM VALUE #( ( ReqId = lv_req_id ) )
      FAILED lt_failed
      REPORTED lt_reported.

    IF lt_failed IS NOT INITIAL.
      out->write( '-> PASS: Hệ thống đã chặn thành công việc bấm sai nút!' ).
      " Check IS BOUND để tránh lỗi sập ngầm (Short Dump) như lần trước
      LOOP AT lt_reported-req INTO DATA(ls_rep).
        IF ls_rep-%msg IS BOUND.
          out->write( |-> Báo lỗi ra UI: "{ ls_rep-%msg->if_message~get_text( ) }"| ).
        ENDIF.
      ENDLOOP.
    ELSE.
      out->write( '-> FAIL: Hệ thống KHÔNG chặn, luồng đang bị hổng!' ).
    ENDIF.

    out->write( '-------------------------------------------------------' ).

    " =========================================================================
    " BÀI TEST 2: BẤM SUBMIT HỢP LỆ (Kỳ vọng: Đổi sang SUBMITTED)
    " =========================================================================
    out->write( '[TEST 2] Bấm nút Submit hợp lệ...' ).
    CLEAR: lt_failed, lt_reported.

    MODIFY ENTITIES OF zir_conf_req_h
      ENTITY Req
      EXECUTE submit FROM VALUE #( ( ReqId = lv_req_id ) )
      FAILED lt_failed
      REPORTED lt_reported.

    IF lt_failed IS INITIAL.
      out->write( '-> PASS: Nút Submit hoạt động trơn tru.' ).

      COMMIT ENTITIES. " Lưu trạng thái xuống DB

      " Đọc lại DB để xem Status đã thực sự chuyển sang SUBMITTED chưa
      SELECT SINGLE status FROM zconfreqh WHERE req_id = @lv_req_id INTO @DATA(lv_new_status).
      out->write( |-> Trạng thái mới cập nhật trong DB: '{ lv_new_status }'| ).
    ELSE.
      out->write( '-> FAIL: Submit bị lỗi mất rồi!' ).
      LOOP AT lt_reported-req INTO ls_rep.
        IF ls_rep-%msg IS BOUND.
          out->write( |-> Chi tiết lỗi: { ls_rep-%msg->if_message~get_text( ) }| ).
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
