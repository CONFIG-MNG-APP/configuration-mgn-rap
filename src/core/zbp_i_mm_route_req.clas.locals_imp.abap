CLASS lhc_RouteReq DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS approve FOR MODIFY
      IMPORTING keys FOR ACTION RouteReq~Approve RESULT result.
ENDCLASS.

CLASS lhc_RouteReq IMPLEMENTATION.
  METHOD approve.
    " 1. Đọc dữ liệu Request hiện tại đang được chọn duyệt
    READ ENTITIES OF zi_mm_route_req IN LOCAL MODE
      ENTITY RouteReq
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_requests).

    LOOP AT lt_requests INTO DATA(ls_request).
      " 2. Đổi trạng thái sang A (Approved)
      MODIFY ENTITIES OF zi_mm_route_req IN LOCAL MODE
        ENTITY RouteReq
          UPDATE
            FIELDS ( ReqStatus )
            WITH VALUE #( ( %tky      = ls_request-%tky
                            ReqStatus = 'A' ) ).

      " 3. Đẩy dữ liệu vào Bảng Cấu Hình Chính (Ví dụ Action Create)
      IF ls_request-Action = 'C'.
        MODIFY ENTITIES OF zi_mm_route_conf
          ENTITY RouteConf
            CREATE
              FIELDS ( EnvId PlantId SendWh ReceiveWh TransMode IsAllowed )
              WITH VALUE #( ( %cid       = 'CID_1'
                              EnvId      = ls_request-EnvId
                              PlantId    = ls_request-PlantId
                              SendWh     = ls_request-SendWh
                              ReceiveWh  = ls_request-ReceiveWh
                              TransMode  = ls_request-TransMode
                              IsAllowed  = ls_request-IsAllowed ) )
          FAILED DATA(ls_failed)
          REPORTED DATA(ls_reported).
      ENDIF.

      " Ghi nhận Result trả về UI
      APPEND VALUE #( %tky   = ls_request-%tky
                      %param = ls_request ) TO result.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
