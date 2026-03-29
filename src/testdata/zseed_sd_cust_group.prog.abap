*&---------------------------------------------------------------------*
*& Report zseed_sd_cust_group
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zseed_sd_cust_group.

DELETE FROM zsd_cust_group.

INSERT zsd_cust_group FROM TABLE @( VALUE #(
  ( client = sy-mandt  cust_group = 'VIP'       description = 'VIP Customer'           )
  ( client = sy-mandt  cust_group = 'RETAIL'    description = 'Retail Customer'         )
  ( client = sy-mandt  cust_group = 'WHOLESALE' description = 'Wholesale Customer'      )
  ( client = sy-mandt  cust_group = 'CORP'      description = 'Corporate Customer'      )
  ( client = sy-mandt  cust_group = 'GRP01'     description = 'Customer Group 01'       )
  ( client = sy-mandt  cust_group = 'GRP02'     description = 'Customer Group 02'       )
) ).

COMMIT WORK.

WRITE: / |Seeded { sy-dbcnt } row(s) into ZSD_CUST_GROUP.|.
