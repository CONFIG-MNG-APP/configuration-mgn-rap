*&---------------------------------------------------------------------*
*& Report zseed_sd_matl_grp
*&---------------------------------------------------------------------*
REPORT zseed_sd_matl_grp.

WRITE: / '=== Seeding Bicycle Material Groups for ZSD_MATL_GRP ==='.

" 1. Xóa toàn bộ dữ liệu cũ
DELETE FROM zsd_matl_grp.
WRITE: / |Deleted old data: { sy-dbcnt } row(s).|.

" 2. Chèn dữ liệu mới chuyên ngành xe đạp
INSERT zsd_matl_grp FROM TABLE @( VALUE #(
  ( client = sy-mandt  matl_grp = 'MTB'    description = 'Mountain Bikes'           )
  ( client = sy-mandt  matl_grp = 'ROAD'   description = 'Road & Racing Bikes'      )
  ( client = sy-mandt  matl_grp = 'CITY'   description = 'City & Commuter Bikes'    )
  ( client = sy-mandt  matl_grp = 'KIDS'   description = 'Kids Bicycles'            )
  ( client = sy-mandt  matl_grp = 'EBIK'   description = 'Electric Bikes (E-Bikes)' )
  ( client = sy-mandt  matl_grp = 'PART'   description = 'Spare Parts (Tires, etc.)')
  ( client = sy-mandt  matl_grp = 'GEAR'   description = 'Cycling Gear & Helmets'   )
) ).

COMMIT WORK.
WRITE: / |Seeded new data: { sy-dbcnt } row(s) into ZSD_MATL_GRP.|.
