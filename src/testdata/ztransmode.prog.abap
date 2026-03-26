*&---------------------------------------------------------------------*
*& Report ztransmode
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ztransmode.

DELETE FROM ztransmode.

INSERT ztransmode FROM TABLE @( VALUE #(
  ( client = sy-mandt trans_mode = 'TRUCK'       description = 'Truck'          is_active = abap_true )
  ( client = sy-mandt trans_mode = 'VAN'         description = 'Van'            is_active = abap_true )
  ( client = sy-mandt trans_mode = 'SHIP'        description = 'Ship'           is_active = abap_true )
  ( client = sy-mandt trans_mode = 'BIKE'        description = 'Bike'           is_active = abap_true )
  ( client = sy-mandt trans_mode = 'XE MÁY'      description = 'Motorbike'      is_active = abap_true )
  ( client = sy-mandt trans_mode = 'XE ĐẠP ĐIỆN' description = 'Electric Bike'  is_active = abap_true )
) ).

COMMIT WORK.

WRITE: / |Seeded { sy-dbcnt } row(s) into ZTRANSMODE.|.
