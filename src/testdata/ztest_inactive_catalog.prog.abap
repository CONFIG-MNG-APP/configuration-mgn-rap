*&---------------------------------------------------------------------*
*& Report ztest_inactive_catalog
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ztest_inactive_catalog.

DATA lv_ts TYPE timestampl.
GET TIME STAMP FIELD lv_ts.

TRY.
    INSERT zconfcatalog FROM @( VALUE #(
      client      = sy-mandt
      conf_id     = cl_system_uuid=>create_uuid_x16_static( )
      module_id   = 'SD'
      conf_name   = 'Customer Credit Limit'
      conf_type   = 'TABLE'
      target_cds  = 'ZI_SD_PRICE_CONF'
      description = 'Credit limit configuration — pending approval from Finance team'
      is_active   = abap_false
      created_by  = sy-uname
      created_at  = lv_ts
    ) ).
    COMMIT WORK.
    WRITE: / 'Done. Inserted 1 inactive catalog entry.'.
  CATCH cx_uuid_error.
    WRITE: / 'UUID error'.
ENDTRY.
