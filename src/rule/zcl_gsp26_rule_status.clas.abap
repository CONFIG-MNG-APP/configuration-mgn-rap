CLASS zcl_gsp26_rule_status DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    " Các hằng số trạng thái chuẩn
    CONSTANTS: cv_draft       TYPE string VALUE 'DRAFT',
               cv_submitted   TYPE string VALUE 'SUBMITTED',
               cv_approved    TYPE string VALUE 'APPROVED',
               cv_rejected    TYPE string VALUE 'REJECTED',
               cv_promoted    TYPE string VALUE 'PROMOTED',
               cv_rolled_back TYPE string VALUE 'ROLLED_BACK'.

    CLASS-METHODS is_transition_valid
      IMPORTING iv_req_id      TYPE sysuuid_x16
                iv_next_status TYPE string
      RETURNING VALUE(rv_allowed) TYPE abap_bool.
ENDCLASS.

CLASS zcl_gsp26_rule_status IMPLEMENTATION.
  METHOD is_transition_valid.
    DATA lv_current_status TYPE string.
    rv_allowed = abap_false.

    " Lấy trạng thái hiện tại từ bảng Header của Request
    SELECT SINGLE status FROM zconfreqh
      WHERE req_id = @iv_req_id
      INTO @lv_current_status.

    CASE lv_current_status.
      WHEN cv_draft.
        " Chỉ cho phép Submit từ DRAFT
        IF iv_next_status = cv_submitted. rv_allowed = abap_true. ENDIF.

      WHEN cv_submitted.
        " Chỉ cho phép Approve/Reject từ SUBMITTED
        IF iv_next_status = cv_approved OR iv_next_status = cv_rejected.
          rv_allowed = abap_true.
        ENDIF.

      WHEN cv_approved.
        " Từ APPROVED có thể Promote hoặc Rollback
        IF iv_next_status = cv_promoted OR iv_next_status = cv_rolled_back.
          rv_allowed = abap_true.
        ENDIF.

      WHEN cv_promoted.
        " Đã Promote vẫn có thể Rollback nếu có lỗi trên hệ thống thực tế
        IF iv_next_status = cv_rolled_back. rv_allowed = abap_true. ENDIF.

    ENDCASE.
  ENDMETHOD.
ENDCLASS.
