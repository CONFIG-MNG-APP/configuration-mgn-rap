REPORT zseed_usermail.

TYPES: BEGIN OF ty_entry,
         user_id TYPE syuname,
         email   TYPE ad_smtpadr,
       END OF ty_entry.

DATA lt_entries TYPE TABLE OF ty_entry.

lt_entries = VALUE #(
  ( user_id = sy-uname  email = 'quylhse173141@fpt.edu.vn' )
).

DELETE FROM zusermail.

INSERT zusermail FROM TABLE @( VALUE #(
  FOR ls_e IN lt_entries (
    user_id = ls_e-user_id
    email   = ls_e-email
  )
) ).

COMMIT WORK.

IF sy-subrc = 0.
  LOOP AT lt_entries INTO DATA(ls_out).
    WRITE: / |Done. { ls_out-user_id } → { ls_out-email }|.
  ENDLOOP.
ELSE.
  WRITE: / |Error inserting. sy-subrc = { sy-subrc }.|.
ENDIF.
