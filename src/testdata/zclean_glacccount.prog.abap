*&---------------------------------------------------------------------*
*& Report zclean_glacccount
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

 REPORT zclean_glacccount.
  DATA: lv_total TYPE i VALUE 0.


  DELETE FROM zglaccount.
  lv_total = lv_total + sy-dbcnt.
  WRITE: / |ZGLACCOUNT: { sy-dbcnt } rows deleted.|.

  WRITE: / '-------------------------------------------'.

  INSERT zglaccount FROM TABLE @( VALUE #(
    ( client = sy-mandt gl_account = '410000' description = 'Cost of Bicycles Sold'           is_active = abap_true )
    ( client = sy-mandt gl_account = '410100' description = 'Cost of Spare Parts Sold'        is_active = abap_true )
    ( client = sy-mandt gl_account = '410200' description = 'Cost of Accessories Sold'        is_active = abap_true )
    ( client = sy-mandt gl_account = '420000' description = 'Freight & Shipping Cost'         is_active = abap_true )
    ( client = sy-mandt gl_account = '430000' description = 'Warranty & After-Sales Cost'     is_active = abap_true )
    ( client = sy-mandt gl_account = '500000' description = 'Sales Staff Salary'              is_active = abap_true )
    ( client = sy-mandt gl_account = '500100' description = 'Sales Commission'                is_active = abap_true )
    ( client = sy-mandt gl_account = '510000' description = 'Showroom Rental'                 is_active = abap_true )
    ( client = sy-mandt gl_account = '520000' description = 'Marketing & Advertising'         is_active = abap_true )
    ( client = sy-mandt gl_account = '520100' description = 'Trade Show & Event Cost'         is_active = abap_true )
    ( client = sy-mandt gl_account = '530000' description = 'Travel & Customer Visit'         is_active = abap_true )
    ( client = sy-mandt gl_account = '540000' description = 'Dealer Discount & Rebate'        is_active = abap_true )
    ( client = sy-mandt gl_account = '600000' description = 'Office & Admin Expense'          is_active = abap_true )
    ( client = sy-mandt gl_account = '800000' description = 'Revenue - Road Bikes'            is_active = abap_true )
    ( client = sy-mandt gl_account = '800100' description = 'Rev    enue - Mountain Bikes'        is_active = abap_true )
    ( client = sy-mandt gl_account = '800200' description = 'Revenue - E-Bikes'               is_active = abap_true )
    ( client = sy-mandt gl_account = '800300' description = 'Revenue - Kids Bikes'            is_active = abap_true )
    ( client = sy-mandt gl_account = '810000' description = 'Revenue - Spare Parts'           is_active = abap_true )
    ( client = sy-mandt gl_account = '810100' description = 'Revenue - Accessories'           is_active = abap_true )
    ( client = sy-mandt gl_account = '820000' description = 'Revenue - Repair Service'        is_active = abap_true )
    ( client = sy-mandt gl_account = '900000' description = 'Other Income'                    is_active = abap_true )
  ) ).

  lv_total = sy-dbcnt.
  WRITE: / |ZGLACCOUNT: { lv_total } rows inserted.|.

  COMMIT WORK.

  WRITE: / '-------------------------------------------'.
  WRITE: / 'Done: Clean + Seed GL Account (Bicycle Sales).'.
