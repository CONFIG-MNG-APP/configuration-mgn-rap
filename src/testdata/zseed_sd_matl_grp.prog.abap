*& Report zseed_sd_matl_grp
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zseed_sd_matl_grp.

DELETE FROM zsd_matl_grp.

INSERT zsd_matl_grp FROM TABLE @( VALUE #(
  ( client = sy-mandt  matl_grp = 'ELEC'    description = 'Electronics'            )
  ( client = sy-mandt  matl_grp = 'PHONE'   description = 'Mobile Phones'          )
  ( client = sy-mandt  matl_grp = 'ACCES'   description = 'Accessories'            )
  ( client = sy-mandt  matl_grp = 'APPL'    description = 'Home Appliances'        )
  ( client = sy-mandt  matl_grp = 'COMP'    description = 'Computers & Laptops'    )
  ( client = sy-mandt  matl_grp = 'AUDIO'   description = 'Audio Equipment'        )
) ).

COMMIT WORK.
WRITE: / |Seeded { sy-dbcnt } row(s) into ZSD_MATL_GRP.|.
