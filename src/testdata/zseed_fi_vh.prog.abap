REPORT zseed_fi_vh.

  " --- Expense Types ---
  DELETE FROM zexpensetype.

  INSERT zexpensetype FROM TABLE @( VALUE #(
    ( client = sy-mandt expense_type = 'TRAVEL'     description = 'Travel Expenses'         is_active = abap_true )
    ( client = sy-mandt expense_type = 'OFFICE'     description = 'Office Supplies'          is_active = abap_true )
    ( client = sy-mandt expense_type = 'ENTERTAIN'  description = 'Entertainment Expenses'   is_active = abap_true )
    ( client = sy-mandt expense_type = 'TRAINING'   description = 'Training & Development'   is_active = abap_true )
    ( client = sy-mandt expense_type = 'MARKETING'  description = 'Marketing Expenses'       is_active = abap_true )
    ( client = sy-mandt expense_type = 'IT_EXPENSE' description = 'IT & Technology Expenses'  is_active = abap_true )
  ) ).

  " --- GL Accounts ---
  DELETE FROM zglaccount.

  INSERT zglaccount FROM TABLE @( VALUE #(
    ( client = sy-mandt gl_account = '600100' description = 'Travel Cost'               is_active = abap_true )
    ( client = sy-mandt gl_account = '600200' description = 'Office Supply Cost'         is_active = abap_true )
    ( client = sy-mandt gl_account = '600300' description = 'Entertainment Cost'         is_active = abap_true )
    ( client = sy-mandt gl_account = '600400' description = 'Training Cost'              is_active = abap_true )
    ( client = sy-mandt gl_account = '600500' description = 'Marketing Cost'             is_active = abap_true )
    ( client = sy-mandt gl_account = '600600' description = 'IT Cost'                    is_active = abap_true )
    ( client = sy-mandt gl_account = '610100' description = 'General Admin Cost'         is_active = abap_true )
    ( client = sy-mandt gl_account = '610200' description = 'Consulting & Legal Fees'    is_active = abap_true )
  ) ).

  COMMIT WORK.
  WRITE: / 'Seed data inserted for ZEXPENSETYPE and ZGLACCOUNT.'.
