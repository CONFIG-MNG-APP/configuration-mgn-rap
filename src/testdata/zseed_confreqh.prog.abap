*&---------------------------------------------------------------------*
*& Report ZSEED_CONFREQH
*&---------------------------------------------------------------------*
REPORT zseed_confreqh.

DATA: lt_header TYPE STANDARD TABLE OF zconfreqh,
      lv_ts     TYPE timestampl.

GET TIME STAMP FIELD lv_ts.

" Skip if data already exists
SELECT SINGLE @abap_true FROM zconfreqh INTO @DATA(lv_exists).
IF sy-subrc = 0.
  WRITE: / 'ZCONFREQH already has data. Skip seeding.'.
  RETURN.
ENDIF.

TRY.
    " 1) DRAFT request
    APPEND VALUE zconfreqh(
      client      = sy-mandt
      req_id      = cl_system_uuid=>create_uuid_x16_static( )
      env_id      = 'DEV'
      module_id   = 'FI'
      req_title   = 'Update Expense Limit for Travel'
      description = 'Change auto-approval limit from 5000 to 8000'
      status      = 'DRAFT'
      reason      = 'Business policy update'
      created_by  = sy-uname
      created_at  = lv_ts
      changed_by  = sy-uname
      changed_at  = lv_ts
    ) TO lt_header.

    " 2) SUBMITTED request
    APPEND VALUE zconfreqh(
      client      = sy-mandt
      req_id      = cl_system_uuid=>create_uuid_x16_static( )
      env_id      = 'DEV'
      module_id   = 'SD'
      req_title   = 'Add Discount Rule for VIP'
      description = 'New pricing rule for VIP customers'
      status      = 'SUBMITTED'
      reason      = 'New customer segment'
      created_by  = sy-uname
      created_at  = lv_ts
      changed_by  = sy-uname
      changed_at  = lv_ts
    ) TO lt_header.

    " 3) APPROVED request
    APPEND VALUE zconfreqh(
      client      = sy-mandt
      req_id      = cl_system_uuid=>create_uuid_x16_static( )
      env_id      = 'QAS'
      module_id   = 'MM'
      req_title   = 'Add Warehouse Route HCM-HN'
      description = 'New route from Ho Chi Minh to Ha Noi'
      status      = 'APPROVED'
      reason      = 'Logistics expansion'
      created_by  = sy-uname
      created_at  = lv_ts
      changed_by  = sy-uname
      changed_at  = lv_ts
      approved_by = sy-uname
      approved_at = lv_ts
    ) TO lt_header.

    " 4) REJECTED request
    APPEND VALUE zconfreqh(
      client      = sy-mandt
      req_id      = cl_system_uuid=>create_uuid_x16_static( )
      env_id      = 'DEV'
      module_id   = 'FI'
      req_title   = 'Remove GL Account 600100'
      description = 'Request to deactivate unused GL account'
      status      = 'REJECTED'
      reason      = 'Account still in use by 3 cost centers'
      created_by  = sy-uname
      created_at  = lv_ts
      changed_by  = sy-uname
      changed_at  = lv_ts
      rejected_by = 'MANAGER01'
      rejected_at = lv_ts
    ) TO lt_header.

    " 5) ACTIVE request
    APPEND VALUE zconfreqh(
      client      = sy-mandt
      req_id      = cl_system_uuid=>create_uuid_x16_static( )
      env_id      = 'PRD'
      module_id   = 'SD'
      req_title   = 'Update Min Order Value'
      description = 'Increase minimum order value to 1000 USD'
      status      = 'ACTIVE'
      reason      = 'Applied to production'
      created_by  = sy-uname
      created_at  = lv_ts
      changed_by  = sy-uname
      changed_at  = lv_ts
      approved_by = sy-uname
      approved_at = lv_ts
    ) TO lt_header.

  CATCH cx_uuid_error INTO DATA(lx_uuid).
    WRITE: / |UUID generation failed: { lx_uuid->get_text( ) }|.
    RETURN.
ENDTRY.

INSERT zconfreqh FROM TABLE @lt_header.
COMMIT WORK.

WRITE: / |Seed done. Inserted { sy-dbcnt } row(s) into ZCONFREQH.|.
