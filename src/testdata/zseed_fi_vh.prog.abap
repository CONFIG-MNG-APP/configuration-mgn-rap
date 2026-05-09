REPORT zseed_fi_vh.

  " --- Expense Types ---
  DELETE FROM zexpensetype.

  INSERT zexpensetype FROM TABLE @( VALUE #(
    ( client = sy-mandt expense_type = 'TRAVEL_DEALER'  description = 'Travel to Dealerships & Partners' is_active = abap_true )
    ( client = sy-mandt expense_type = 'CLIENT_MEALS'   description = 'Dealer Meals & Entertainment'     is_active = abap_true )
    ( client = sy-mandt expense_type = 'DEMO_EVENT'     description = 'Demo Days & Local Bike Expos'     is_active = abap_true )
    ( client = sy-mandt expense_type = 'DEMO_PARTS'     description = 'Parts & Spares for Demo Bikes'    is_active = abap_true )
    ( client = sy-mandt expense_type = 'CUSTOM_ACC'     description = 'Custom Accessories for VIP Deals' is_active = abap_true )
    ( client = sy-mandt expense_type = 'EMERGENCY_FIX'  description = 'Emergency On-road Repairs'        is_active = abap_true )
    ( client = sy-mandt expense_type = 'EBIKE_TRAINING' description = 'Internal E-Bike Sales Training'   is_active = abap_true )
  ) ).


  COMMIT WORK.
  WRITE: / 'Seed data inserted for ZEXPENSETYPE .'.
