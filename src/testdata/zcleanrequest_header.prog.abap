*&---------------------------------------------------------------------*
*& Report zcleanrequest_header
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zcleanrequest_header.

* ============================================================
* Cleanup program: Delete all request data
* Tables: ZCONFREQH, ZCONFREQI, ZMMROUTECONF_REQ,
*         ZFILIMITREQ, ZMMSAFESTOCK_REQ, ZSD_PRICE_REQ
* WARNING: This deletes ALL rows - use only in dev/test system
* ============================================================

DATA: lv_total TYPE i VALUE 0.

DELETE FROM zconfreqi.
lv_total = lv_total + sy-dbcnt.
WRITE: / |ZCONFREQI:         { sy-dbcnt } rows deleted.|.

DELETE FROM zmmrouteconf_req.
lv_total = lv_total + sy-dbcnt.
WRITE: / |ZMMROUTECONF_REQ:  { sy-dbcnt } rows deleted.|.

DELETE FROM zfilimitreq.
lv_total = lv_total + sy-dbcnt.
WRITE: / |ZFILIMITREQ:       { sy-dbcnt } rows deleted.|.

DELETE FROM zmmsafestock_req.
lv_total = lv_total + sy-dbcnt.
WRITE: / |ZMMSAFESTOCK_REQ:  { sy-dbcnt } rows deleted.|.

DELETE FROM zsd_price_req.
lv_total = lv_total + sy-dbcnt.
WRITE: / |ZSD_PRICE_REQ:     { sy-dbcnt } rows deleted.|.

* Delete header last (items must be deleted first - FK dependency)
DELETE FROM zconfreqh.
lv_total = lv_total + sy-dbcnt.
WRITE: / |ZCONFREQH:         { sy-dbcnt } rows deleted.|.

COMMIT WORK.

WRITE: / '--------------------------------------------'.
WRITE: / |Total: { lv_total } rows deleted. All request data cleaned.|.
