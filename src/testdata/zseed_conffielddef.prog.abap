REPORT zseed_conffielddef.

DATA: lt_field    TYPE STANDARD TABLE OF zconffielddef,
      lv_conf_id  TYPE zconfcatalog-conf_id.

*----------------------------------------------------------------------*
* Helper macro: skip if conf_id not found
*----------------------------------------------------------------------*
DEFINE add_field.
  IF lv_conf_id IS NOT INITIAL.
    APPEND VALUE zconffielddef(
      client          = sy-mandt
      conf_id         = lv_conf_id
      field_name      = &1
      field_label     = &2
      data_type       = &3
      is_required     = &4
      value_help_type = &5
    ) TO lt_field.
  ENDIF.
END-OF-DEFINITION.

*======================================================================*
* MM – Warehouse Route
*======================================================================*
SELECT SINGLE conf_id FROM zconfcatalog
  WHERE target_cds = 'ZI_MM_ROUTE_CONF'
  INTO @lv_conf_id.

add_field 'ENV_ID'      'Environment'         'CHAR10'  abap_true  'ENV'.
add_field 'PLANT_ID'    'Plant'               'CHAR10'  abap_true  'PLANT'.
add_field 'SEND_WH'     'Sending Warehouse'   'CHAR10'  abap_true  'WAREHOUSE'.
add_field 'RECEIVE_WH'  'Receiving Warehouse' 'CHAR10'  abap_true  'WAREHOUSE'.
add_field 'INSPECTOR_ID' 'Inspector'          'CHAR20'  abap_false ''.
add_field 'TRANS_MODE'  'Transport Mode'      'CHAR10'  abap_true  'TRANSPORT'.
add_field 'IS_ALLOWED'  'Is Allowed'          'BOOLEAN' abap_true  ''.
add_field 'VERSION_NO'  'Version'             'NUMC'    abap_true  ''.

*======================================================================*
* MM – Safety Stock
*======================================================================*
SELECT SINGLE conf_id FROM zconfcatalog
  WHERE target_cds = 'ZI_MM_SAFE_STOCK'
  INTO @lv_conf_id.

add_field 'ENV_ID'    'Environment'     'CHAR10'  abap_true  'ENV'.
add_field 'PLANT_ID'  'Plant'           'CHAR10'  abap_true  'PLANT'.
add_field 'MAT_GROUP' 'Material Group'  'CHAR10'  abap_false 'MAT_GROUP'.
add_field 'MIN_QTY'   'Minimum Qty'     'INT8'    abap_false ''.
add_field 'VERSION_NO' 'Version'        'INT4'    abap_true  ''.

*======================================================================*
* FI – Expense Limit
*======================================================================*
SELECT SINGLE conf_id FROM zconfcatalog
  WHERE target_cds = 'ZI_FI_LIMIT_CONF'
  INTO @lv_conf_id.

add_field 'ENV_ID'        'Environment'         'CHAR10'  abap_true  'ENV'.
add_field 'EXPENSE_TYPE'  'Expense Type'        'CHAR30'  abap_true  'EXPENSE_TYPE'.
add_field 'GL_ACCOUNT'    'GL Account'          'CHAR10'  abap_true  'GL_ACCOUNT'.
add_field 'AUTO_APPR_LIM' 'Auto Approval Limit' 'DEC'     abap_true  ''.
add_field 'CURRENCY'      'Currency'            'CUKY'    abap_false 'CURRENCY'.
add_field 'VERSION_NO'    'Version'             'INT4'    abap_true  ''.

*======================================================================*
* SD – Price Config
*======================================================================*
SELECT SINGLE conf_id FROM zconfcatalog
  WHERE target_cds = 'ZI_SD_PRICE_CONF'
  INTO @lv_conf_id.

add_field 'ENV_ID'        'Environment'     'CHAR10'  abap_true  'ENV'.
add_field 'BRANCH_ID'     'Branch'          'CHAR10'  abap_false ''.
add_field 'CUST_GROUP'    'Customer Group'  'CHAR10'  abap_false 'CUST_GROUP'.
add_field 'MATERIAL_GRP'  'Material Group'  'CHAR10'  abap_false 'MAT_GROUP'.
add_field 'MAX_DISCOUNT'  'Max Discount'    'CURR'    abap_false ''.
add_field 'MIN_ORDER_VAL' 'Min Order Value' 'INT4'    abap_false ''.
add_field 'APPROVER_GRP'  'Approver Group'  'CHAR20'  abap_false ''.
add_field 'CURRENCY'      'Currency'        'CUKY'    abap_false 'CURRENCY'.
add_field 'VALID_FROM'    'Valid From'      'DATS'    abap_false ''.
add_field 'VALID_TO'      'Valid To'        'DATS'    abap_false ''.
add_field 'VERSION_NO'    'Version'         'INT4'    abap_true  ''.

*======================================================================*
* Insert
*======================================================================*
IF lt_field IS INITIAL.
  WRITE: / 'No field definitions to insert – check ZCONFCATALOG entries.'.
  RETURN.
ENDIF.

MODIFY zconffielddef FROM TABLE @lt_field.
COMMIT WORK.

WRITE: / |Seeded { sy-dbcnt } row(s) into ZCONFFIELDDEF.|.
