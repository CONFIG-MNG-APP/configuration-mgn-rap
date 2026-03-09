CLASS lhc_catalog DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR catalog RESULT result.

    METHODS validatemoduleid FOR VALIDATE ON SAVE
      IMPORTING keys FOR catalog~validatemoduleid.

    METHODS validatetargettable FOR VALIDATE ON SAVE
      IMPORTING keys FOR catalog~validatetargettable.

    METHODS validateDeleteCatalog FOR VALIDATE ON SAVE
      IMPORTING keys FOR catalog~validateDeleteCatalog.

ENDCLASS.

CLASS lhc_catalog IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD validatemoduleid.
    READ ENTITIES OF zi_conf_catalog IN LOCAL MODE
    ENTITY Catalog
      FIELDS ( ModuleId ) WITH CORRESPONDING #( keys )
    RESULT DATA(catalogs).
    LOOP AT catalogs INTO DATA(catalog).
      IF catalog-ModuleId IS INITIAL.
        APPEND VALUE #( %tky = catalog-%tky ) TO failed-catalog.
        APPEND VALUE #( %tky = catalog-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Module ID is required' )
                      ) TO reported-catalog.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validatetargettable.
    READ ENTITIES OF zi_conf_catalog IN LOCAL MODE
    ENTITY Catalog
      FIELDS ( TargetCds ) WITH CORRESPONDING #( keys )
    RESULT DATA(catalogs).
    LOOP AT catalogs INTO DATA(catalog).
      IF catalog-TargetCds IS INITIAL.
        APPEND VALUE #( %tky = catalog-%tky ) TO failed-catalog.
        APPEND VALUE #( %tky = catalog-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Target Table is required' )
                      ) TO reported-catalog.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateDeleteCatalog.

    READ ENTITIES OF zi_conf_catalog IN LOCAL MODE
      ENTITY Catalog
        FIELDS ( ConfId ConfName ) WITH CORRESPONDING #( keys )
      RESULT DATA(catalogs).
    IF catalogs IS INITIAL.
      RETURN.
    ENDIF.

    DATA lt_conf_ids TYPE RANGE OF zconfcatalog-conf_id.
    LOOP AT catalogs INTO DATA(catalog).
      APPEND VALUE #( sign = 'I' option = 'EQ' low = catalog-ConfId ) TO lt_conf_ids.
    ENDLOOP.

    SELECT conf_id, COUNT(*) AS cnt
      FROM zconfreqi
      WHERE conf_id IN @lt_conf_ids
      GROUP BY conf_id
      INTO TABLE @DATA(lt_used).

    LOOP AT catalogs INTO catalog.
      READ TABLE lt_used WITH KEY conf_id = catalog-ConfId INTO DATA(ls_used).
      IF sy-subrc = 0.
        APPEND VALUE #( %tky = catalog-%tky ) TO failed-catalog.
        APPEND VALUE #(
          %tky = catalog-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text = |Cannot delete '{ catalog-ConfName }': used by { ls_used-cnt } request item(s)| )
        ) TO reported-catalog.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
