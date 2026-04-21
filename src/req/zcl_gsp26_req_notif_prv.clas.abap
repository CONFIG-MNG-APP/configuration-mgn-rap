CLASS zcl_gsp26_req_notif_prv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES /iwngw/if_notif_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_gsp26_req_notif_prv IMPLEMENTATION.

  METHOD /iwngw/if_notif_provider~get_notification_parameters.
    " Đã sửa iv_type_id -> iv_type_key
    IF iv_type_key = 'REQ_APPROVED' OR iv_type_key = 'REQ_REJECTED' OR iv_type_key = 'REQ_SUBMITTED'.
      APPEND VALUE #( name = 'ReqTitle'
                      type = /iwngw/if_notif_provider=>gcs_parameter_types-type_string
                      is_sensitive = abap_false ) TO et_parameter.
    ENDIF.
  ENDMETHOD.

  METHOD /iwngw/if_notif_provider~get_notification_type.
    " Đã sửa: Gán trực tiếp vào cấu trúc đơn ES_NOTIFICATION_TYPE thay vì append bảng
    CASE iv_type_key.
      WHEN 'REQ_APPROVED' OR 'REQ_REJECTED' OR 'REQ_SUBMITTED'.
        es_notification_type-type_key      = iv_type_key.
        es_notification_type-version       = '1'.
        " Đã bỏ is_actionable để tương thích với phiên bản SAP Gateway hiện tại
    ENDCASE.
  ENDMETHOD.

  METHOD /iwngw/if_notif_provider~get_notification_type_text.
    " Đã sửa: Gán vào ES_TYPE_TEXT và bỏ trường LANGUAGE
    CASE iv_type_key.
      WHEN 'REQ_APPROVED'.
        es_type_text-template_public    = ' Phê duyệt: Phiếu cấu hình {ReqTitle} đã được sếp duyệt!'.
        es_type_text-template_sensitive = ' Phê duyệt: Phiếu cấu hình {ReqTitle} đã được sếp duyệt!'.

      WHEN 'REQ_REJECTED'.
        es_type_text-template_public    = ' Từ chối: Phiếu {ReqTitle} của bạn không được duyệt.'.
        es_type_text-template_sensitive = ' Từ chối: Phiếu {ReqTitle} của bạn không được duyệt.'.

      WHEN 'REQ_SUBMITTED'.
        es_type_text-template_public    = ' Chờ duyệt: Có yêu cầu cấu hình mới {ReqTitle}.'.
        es_type_text-template_sensitive = ' Chờ duyệt: Có yêu cầu cấu hình mới {ReqTitle}.'.
    ENDCASE.
  ENDMETHOD.

  METHOD /iwngw/if_notif_provider~handle_action.
  ENDMETHOD.

  METHOD /iwngw/if_notif_provider~handle_bulk_action.
  ENDMETHOD.

ENDCLASS.
