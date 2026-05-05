*&---------------------------------------------------------------------*
*& Report zclean_user_mgmt
*&---------------------------------------------------------------------*
*& Cleanup: Delete all rows from ZUSERROLE and ZUSERMAIL
*& Run BEFORE activating the updated ZUSERROLE table (compound key fix)
*& WARNING: deletes ALL user role and email data — dev/test only
*&---------------------------------------------------------------------*
REPORT zclean_user_mgmt.

DATA: lv_total TYPE i VALUE 0.

" Delete user roles
DELETE FROM zuserrole.
lv_total = lv_total + sy-dbcnt.
WRITE: / |ZUSERROLE: { sy-dbcnt } rows deleted.|.

" Delete user emails
DELETE FROM zusermail.
lv_total = lv_total + sy-dbcnt.
WRITE: / |ZUSERMAIL: { sy-dbcnt } rows deleted.|.

COMMIT WORK.

WRITE: / '----------------------------------------------'.
WRITE: / |Total: { lv_total } rows deleted.|.
WRITE: / 'Tables are now empty. You can activate the'.
WRITE: / 'updated ZUSERROLE table (compound key fix).'.
