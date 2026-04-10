*&---------------------------------------------------------------------*
*& Report zclean_main_tables
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zclean_main_tables.

" ======================================================================
" Cleanup program: Delete all main config tables + audit log
" Scope: data written by approve() and promote() actions
"   ZMMROUTECONF   - MM Route configurations
"   ZMMSAFESTOCK   - MM Safe Stock configurations
"   ZFILIMITCONF   - FI Limit configurations
"   ZSD_PRICE_CONF - SD Price configurations
"   ZAUDITLOG      - Audit trail
" WARNING: This deletes ALL rows - use only in dev/test system
" ======================================================================

DATA: lv_total TYPE i VALUE 0.

" MM Route config
DELETE FROM zmmrouteconf.
lv_total = lv_total + sy-dbcnt.
WRITE: / |ZMMROUTECONF:    { sy-dbcnt } rows deleted.|.

" MM Safe Stock config
DELETE FROM zmmsafestock.
lv_total = lv_total + sy-dbcnt.
WRITE: / |ZMMSAFESTOCK:    { sy-dbcnt } rows deleted.|.

" FI Limit config
DELETE FROM zfilimitconf.
lv_total = lv_total + sy-dbcnt.
WRITE: / |ZFILIMITCONF:    { sy-dbcnt } rows deleted.|.

" SD Price config
DELETE FROM zsd_price_conf.
lv_total = lv_total + sy-dbcnt.
WRITE: / |ZSD_PRICE_CONF:  { sy-dbcnt } rows deleted.|.

" Audit log
DELETE FROM zauditlog.
lv_total = lv_total + sy-dbcnt.
WRITE: / |ZAUDITLOG:       { sy-dbcnt } rows deleted.|.

COMMIT WORK.

WRITE: / '--------------------------------------------'.
WRITE: / |Total: { lv_total } rows deleted. All main config data cleaned.|.
