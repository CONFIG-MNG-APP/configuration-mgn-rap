CLASS zcl_gsp26_rule_version DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    " Tính version mới dựa trên bảng cụ thể (ví dụ ZSD_PRICE_CONF)
    CLASS-METHODS get_next_version
      IMPORTING iv_table_name TYPE string
                iv_item_id    TYPE uuid
      RETURNING VALUE(rv_version) TYPE i.
ENDCLASS.

CLASS zcl_gsp26_rule_version IMPLEMENTATION.
  METHOD get_next_version.
    SELECT MAX( version_no ) FROM (iv_table_name)
      WHERE item_id = @iv_item_id
      INTO @rv_version.

    rv_version = rv_version + 1.
  ENDMETHOD.
ENDCLASS.
