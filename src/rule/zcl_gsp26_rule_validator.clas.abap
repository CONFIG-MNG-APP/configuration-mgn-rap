CLASS zcl_gsp26_rule_validator DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
  TYPES: BEGIN OF ty_validation_error,
             conf_id  TYPE zconfcatalog-conf_id,
             field    TYPE zconffielddef-field_name,
             message  TYPE string,
           END OF ty_validation_error,
           tt_validation_errors TYPE STANDARD TABLE OF ty_validation_error WITH EMPTY KEY.
    " Kiểm tra CONF_ID có tồn tại trong danh mục không
    CLASS-METHODS check_catalog_existence
      IMPORTING iv_conf_id TYPE zconfcatalog-conf_id
      RETURNING VALUE(rv_exists) TYPE abap_bool.

     " Kiểm tra CONF_ID tồn tại và đang active
    CLASS-METHODS check_catalog_active
      IMPORTING iv_conf_id       TYPE zconfcatalog-conf_id
      RETURNING VALUE(rv_active) TYPE abap_bool.

    " Kiểm tra required fields từ field definition
    CLASS-METHODS check_required_fields
      IMPORTING iv_conf_id       TYPE zconfcatalog-conf_id
                is_data          TYPE any
      RETURNING VALUE(rt_errors) TYPE tt_validation_errors.

    " Validate toàn bộ cho 1 request item
    CLASS-METHODS validate_request_item
      IMPORTING iv_conf_id       TYPE zconfcatalog-conf_id
                iv_action        TYPE zde_action_type
                iv_target_env_id TYPE zde_env_id
      RETURNING VALUE(rt_errors) TYPE tt_validation_errors.
ENDCLASS.

CLASS zcl_gsp26_rule_validator IMPLEMENTATION.
  METHOD check_catalog_existence.
    SELECT SINGLE @abap_true
      FROM zconfcatalog
      WHERE conf_id = @iv_conf_id
      INTO @rv_exists.
  ENDMETHOD.

  METHOD check_catalog_active.
    SELECT SINGLE @abap_true
      FROM zconfcatalog
      WHERE conf_id  = @iv_conf_id
        AND is_active = @abap_true
      INTO @rv_active.
  ENDMETHOD.

  METHOD check_required_fields.
    " Lấy danh sách required fields từ catalog field definition
    SELECT field_name, field_label
      FROM zconffielddef
      WHERE conf_id     = @iv_conf_id
        AND is_required = @abap_true
      INTO TABLE @DATA(lt_required_fields).
    IF lt_required_fields IS INITIAL.
      RETURN.
    ENDIF.

    " Với mỗi required field, check trong data xem có giá trị không
    DATA lo_struct TYPE REF TO cl_abap_structdescr.
    lo_struct ?= cl_abap_typedescr=>describe_by_data( is_data ).
    LOOP AT lt_required_fields INTO DATA(ls_field).
      " Check field có tồn tại trong structure
      READ TABLE lo_struct->components WITH KEY name = to_upper( ls_field-field_name )
        TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        CONTINUE. " Field không tồn tại trong structure, skip
      ENDIF.
      ASSIGN COMPONENT ls_field-field_name OF STRUCTURE is_data TO FIELD-SYMBOL(<value>).
      IF sy-subrc = 0 AND <value> IS INITIAL.
        APPEND VALUE #(
          conf_id = iv_conf_id
          field   = ls_field-field_name
          message = |Field '{ ls_field-field_label }' is required|
        ) TO rt_errors.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_request_item.
    " 1. Check conf_id tồn tại
    IF check_catalog_existence( iv_conf_id ) = abap_false.
      APPEND VALUE #(
        conf_id = iv_conf_id
        message = 'Configuration ID does not exist in catalog'
      ) TO rt_errors.
      RETURN. " Không cần check tiếp
    ENDIF.
    " 2. Check conf_id active
    IF check_catalog_active( iv_conf_id ) = abap_false.
      APPEND VALUE #(
        conf_id = iv_conf_id
        message = 'Configuration is not active'
      ) TO rt_errors.
    ENDIF.
    " 3. Check action không rỗng
    IF iv_action IS INITIAL.
      APPEND VALUE #(
        conf_id = iv_conf_id
        field   = 'ACTION'
        message = 'Action is required'
      ) TO rt_errors.
    ENDIF.
    " 4. Check target_env_id không rỗng
    IF iv_target_env_id IS INITIAL.
      APPEND VALUE #(
        conf_id = iv_conf_id
        field   = 'TARGET_ENV_ID'
        message = 'Target Environment is required'
      ) TO rt_errors.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
