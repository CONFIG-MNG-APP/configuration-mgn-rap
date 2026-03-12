CLASS lhc_RouteConf DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR RouteConf RESULT result.

    METHODS set_defaults FOR DETERMINE ON MODIFY
      IMPORTING keys FOR RouteConf~set_defaults.

    METHODS validate_business FOR VALIDATE ON SAVE
      IMPORTING keys FOR RouteConf~validate_business.

    METHODS validate_mandatory FOR VALIDATE ON SAVE
      IMPORTING keys FOR RouteConf~validate_mandatory.

ENDCLASS.

CLASS lhc_RouteConf IMPLEMENTATION.

  METHOD get_global_authorizations.
    result = VALUE #(
      %create = if_abap_behv=>auth-allowed
      %update = if_abap_behv=>auth-allowed
      %delete = if_abap_behv=>auth-allowed ).
  ENDMETHOD.

  METHOD set_defaults.

    READ ENTITIES OF zi_mm_route_conf IN LOCAL MODE
      ENTITY RouteConf
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_data).

    MODIFY ENTITIES OF zi_mm_route_conf IN LOCAL MODE
      ENTITY RouteConf
      UPDATE FIELDS ( IsAllowed VersionNo ActionType )
      WITH VALUE #(
        FOR r IN lt_data (
          %tky       = r-%tky
          IsAllowed  = COND abap_boolean(
                         WHEN r-IsAllowed IS INITIAL THEN abap_true
                         ELSE r-IsAllowed )
          VersionNo  = COND i(
                         WHEN r-VersionNo IS INITIAL THEN 1
                         ELSE r-VersionNo )
          ActionType = COND #(
                         WHEN r-ActionType IS INITIAL THEN 'CREATE'
                         ELSE r-ActionType )
        )
      ).

  ENDMETHOD.

  METHOD validate_mandatory.

    READ ENTITIES OF zi_mm_route_conf IN LOCAL MODE
      ENTITY RouteConf
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_data).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<r>).
      IF <r>-ReqId IS INITIAL OR
         <r>-EnvId IS INITIAL OR
         <r>-PlantId IS INITIAL OR
         <r>-SendWh IS INITIAL OR
         <r>-ReceiveWh IS INITIAL OR
         <r>-TransMode IS INITIAL.

        APPEND VALUE #( %tky = <r>-%tky ) TO failed-RouteConf.

        APPEND VALUE #(
          %tky = <r>-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = |Mandatory fields missing (ReqId/Env/Plant/SendWH/ReceiveWH/TransMode).| ) )
          TO reported-RouteConf.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validate_business.

    READ ENTITIES OF zi_mm_route_conf IN LOCAL MODE
      ENTITY RouteConf
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_data).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<r>).

      IF <r>-SendWh IS NOT INITIAL AND
         <r>-ReceiveWh IS NOT INITIAL AND
         <r>-SendWh = <r>-ReceiveWh.

        APPEND VALUE #( %tky = <r>-%tky ) TO failed-RouteConf.

        APPEND VALUE #(
          %tky = <r>-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = |Send Warehouse must be different from Receive Warehouse.| ) )
          TO reported-RouteConf.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
