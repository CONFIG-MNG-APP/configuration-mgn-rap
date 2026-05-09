CLASS zcl_fill_expense_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_fill_expense_data IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    DATA lt_expense_types TYPE TABLE OF zexpensetype.

    " 1. Xóa dữ liệu cũ để làm sạch bảng
    DELETE FROM zexpensetype.

    " 2. Chuẩn bị bộ dữ liệu Sale Xe đạp (Đã bổ sung chi phí Linh kiện)
    lt_expense_types = VALUE #(
      ( expense_type = 'TRAVEL_DEALER'  description = 'Travel to Dealerships & Partners' is_active = abap_true )
      ( expense_type = 'CLIENT_MEALS'   description = 'Dealer Meals & Entertainment'     is_active = abap_true )
      ( expense_type = 'DEMO_EVENT'     description = 'Demo Days & Local Bike Expos'     is_active = abap_true )
      ( expense_type = 'DEMO_PARTS'     description = 'Parts & Spares for Demo Bikes'    is_active = abap_true ) " Chi phí linh kiện bảo dưỡng
      ( expense_type = 'CUSTOM_ACC'     description = 'Custom Accessories for VIP Deals' is_active = abap_true ) " Phụ kiện tặng kèm
      ( expense_type = 'EMERGENCY_FIX'  description = 'Emergency On-road Repairs'        is_active = abap_true ) " Sửa xe dọc đường
      ( expense_type = 'EBIKE_TRAINING' description = 'Internal E-Bike Sales Training'   is_active = abap_false ) " Mã khóa để test Validate
    ).

    " 3. Insert xuống Database
    INSERT zexpensetype FROM TABLE @lt_expense_types.

    " 4. Thông báo kết quả ra Console
    IF sy-subrc = 0.
      out->write( |Tuyệt vời! Đã nạp thành công { lines( lt_expense_types ) } dòng (Bao gồm nhóm Linh kiện) vào bảng ZEXPENSETYPE.| ).
    ELSE.
      out->write( 'Lỗi! Không thể chèn dữ liệu.' ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
