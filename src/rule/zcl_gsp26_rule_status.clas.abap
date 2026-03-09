CLASS zcl_gsp26_rule_status DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    " Hằng số trạng thái khớp với Business Blueprint (image_6fc715.png)
    CONSTANTS: cv_draft       TYPE string VALUE 'DRAFT',
               cv_submitted   TYPE string VALUE 'SUBMITTED',
               cv_approved    TYPE string VALUE 'APPROVED',
               cv_rejected    TYPE string VALUE 'REJECTED',
               cv_rolled_back TYPE string VALUE 'ROLLED_BACK'. " Trạng thái bổ sung cho Rollback

    CLASS-METHODS is_transition_valid
      IMPORTING iv_req_id      TYPE zconfreqh-req_id
                iv_next_status TYPE string
      RETURNING VALUE(rv_allowed) TYPE abap_bool.
ENDCLASS.

CLASS zcl_gsp26_rule_status IMPLEMENTATION.
  METHOD is_transition_valid.
    DATA lv_current_status TYPE string.
    rv_allowed = abap_false.

    " Lấy trạng thái hiện tại từ bảng Header (image_6fc715.png)
    SELECT SINGLE status FROM zconfreqh
      WHERE req_id = @iv_req_id
      INTO @lv_current_status.

    " Kiểm tra luồng chuyển đổi trạng thái chuẩn (image_6ee182.png)
    CASE lv_current_status.
      WHEN cv_draft.
        " Draft chỉ có thể Submit (Step 9 trong image_6fc715.png)
        IF iv_next_status = cv_submitted. rv_allowed = abap_true. ENDIF.

      WHEN cv_submitted.
        " Đang chờ Manager duyệt (Step 10 trong image_6fc715.png)
        IF iv_next_status = cv_approved OR iv_next_status = cv_rejected.
          rv_allowed = abap_true.
        ENDIF.

      WHEN cv_approved.
        " Cho phép Rollback sau khi đã Approve (image_6ee182.png)
        IF iv_next_status = cv_rolled_back.
          rv_allowed = abap_true.
        ENDIF.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
