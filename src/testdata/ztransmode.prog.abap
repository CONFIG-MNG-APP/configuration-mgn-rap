*&---------------------------------------------------------------------*
*& Report zseed_transmode
*&---------------------------------------------------------------------*
REPORT zseed_transmode.

WRITE: / '=== Seeding Transport Modes for ZTRANSMODE ==='.

" 1. Xóa toàn bộ dữ liệu cũ
DELETE FROM ztransmode.
WRITE: / |Deleted old data: { sy-dbcnt } row(s).|.

" 2. Chèn dữ liệu mới cho chuỗi cung ứng xe đạp
INSERT ztransmode FROM TABLE @( VALUE #(
  ( client = sy-mandt  trans_mode = 'TRUK' description = 'Standard Truck Delivery'  is_active = abap_true )
  ( client = sy-mandt  trans_mode = 'EVAN' description = 'Express Van Delivery'     is_active = abap_true )
  ( client = sy-mandt  trans_mode = 'PICK' description = 'In-Store Pickup'          is_active = abap_true )
  ( client = sy-mandt  trans_mode = 'SEA'  description = 'Ocean Freight (Bulk)'     is_active = abap_true )
  ( client = sy-mandt  trans_mode = 'RAIL' description = 'Domestic Rail Freight'    is_active = abap_true )
  ( client = sy-mandt  trans_mode = 'AIR'  description = 'Express Air (Urgent Part)'is_active = abap_true )
  ( client = sy-mandt  trans_mode = 'POST' description = 'Postal Service (Defunct)' is_active = abap_false ) " Demo Inactive
) ).

COMMIT WORK.
WRITE: / |Seeded new data: { sy-dbcnt } row(s) into ZTRANSMODE.|.
