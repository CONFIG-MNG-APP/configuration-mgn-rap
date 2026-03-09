REPORT zseed_conffielddef.

DATA: lt_field TYPE STANDARD TABLE OF zconffielddef.

APPEND VALUE zconffielddef(
  client          = sy-mandt
  conf_id         = 'B1994EEB6D141FE184F1BC2FC73F537F'
  field_name      = 'ENV_ID'
  field_label     = 'Environment'
  data_type       = 'CHAR10'
  is_required     = abap_true
  value_help_type = 'ENV'
) TO lt_field.

APPEND VALUE zconffielddef(
  client          = sy-mandt
  conf_id         = 'B1994EEB6D141FE184F1BC2FC73F537F'
  field_name      = 'PLANT_ID'
  field_label     = 'Plant'
  data_type       = 'CHAR10'
  is_required     = abap_true
  value_help_type = 'PLANT'
) TO lt_field.

APPEND VALUE zconffielddef(
  client          = sy-mandt
  conf_id         = 'B1994EEB6D141FE184F1BC2FC73F537F'
  field_name      = 'SEND_WH'
  field_label     = 'Sending Warehouse'
  data_type       = 'CHAR10'
  is_required     = abap_true
  value_help_type = 'WAREHOUSE'
) TO lt_field.

APPEND VALUE zconffielddef(
  client          = sy-mandt
  conf_id         = 'B1994EEB6D141FE184F1BC2FC73F537F'
  field_name      = 'RECEIVE_WH'
  field_label     = 'Receiving Warehouse'
  data_type       = 'CHAR10'
  is_required     = abap_true
  value_help_type = 'WAREHOUSE'
) TO lt_field.

APPEND VALUE zconffielddef(
  client          = sy-mandt
  conf_id         = 'B1994EEB6D141FE184F1BC2FC73F537F'
  field_name      = 'INSPECTOR_ID'
  field_label     = 'Inspector'
  data_type       = 'CHAR20'
  is_required     = abap_false
  value_help_type = ''
) TO lt_field.

APPEND VALUE zconffielddef(
  client          = sy-mandt
  conf_id         = 'B1994EEB6D141FE184F1BC2FC73F537F'
  field_name      = 'TRANS_MODE'
  field_label     = 'Transport Mode'
  data_type       = 'CHAR10'
  is_required     = abap_true
  value_help_type = 'TRANSPORT'
) TO lt_field.

APPEND VALUE zconffielddef(
  client          = sy-mandt
  conf_id         = 'B1994EEB6D141FE184F1BC2FC73F537F'
  field_name      = 'IS_ALLOWED'
  field_label     = 'Is Allowed'
  data_type       = 'BOOLEAN'
  is_required     = abap_true
  value_help_type = ''
) TO lt_field.

APPEND VALUE zconffielddef(
  client          = sy-mandt
  conf_id         = 'B1994EEB6D141FE184F1BC2FC73F537F'
  field_name      = 'VERSION_NO'
  field_label     = 'Version'
  data_type       = 'NUMC'
  is_required     = abap_true
  value_help_type = ''
) TO lt_field.

INSERT zconffielddef FROM TABLE @lt_field.
COMMIT WORK.

WRITE: / |Seeded { sy-dbcnt } row(s) into ZCONFFIELDDEF.|.
