*&---------------------------------------------------------------------*
*& Report zcleanrequest_header
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zcleanrequest_header.

* ============================================================
* Cleanup program: Delete all request data including RAP drafts
* Transparent tables:
*   ZCONFREQI, ZMMROUTECONF_REQ, ZFILIMITREQ,
*   ZMMSAFESTOCK_REQ, ZSD_PRICE_REQ, ZCONFREQH
* RAP Draft tables (_D):
*   ZCONFREQI_D, ZCONFREQH_D,
*   ZFI_LIMIT_D, ZMMROUTEROOT_D, ZMMSAFESTOCK_D, ZSD_PRICE_CONF_D
* WARNING: This deletes ALL rows - use only in dev/test system
* ============================================================

DATA: lv_total TYPE i VALUE 0.

* ── Request item tables (delete before header - FK dependency) ────────
DELETE FROM zconfreqi.
lv_total = lv_total + sy-dbcnt.
WRITE: / |ZCONFREQI:          { sy-dbcnt } rows deleted.|.

DELETE FROM zmmrouteconf_req.
lv_total = lv_total + sy-dbcnt.
WRITE: / |ZMMROUTECONF_REQ:   { sy-dbcnt } rows deleted.|.

DELETE FROM zfilimitreq.
lv_total = lv_total + sy-dbcnt.
WRITE: / |ZFILIMITREQ:        { sy-dbcnt } rows deleted.|.

DELETE FROM zmmsafestock_req.
lv_total = lv_total + sy-dbcnt.
WRITE: / |ZMMSAFESTOCK_REQ:   { sy-dbcnt } rows deleted.|.

DELETE FROM zsd_price_req.
lv_total = lv_total + sy-dbcnt.
WRITE: / |ZSD_PRICE_REQ:      { sy-dbcnt } rows deleted.|.

* ── Request header (after items) ─────────────────────────────────────
DELETE FROM zconfreqh.
lv_total = lv_total + sy-dbcnt.
WRITE: / |ZCONFREQH:          { sy-dbcnt } rows deleted.|.

* ── RAP Draft tables ─────────────────────────────────────────────────
DELETE FROM zconfreqi_d.
lv_total = lv_total + sy-dbcnt.
WRITE: / |ZCONFREQI_D:        { sy-dbcnt } rows deleted.|.

DELETE FROM zconfreqh_d.
lv_total = lv_total + sy-dbcnt.
WRITE: / |ZCONFREQH_D:        { sy-dbcnt } rows deleted.|.

DELETE FROM zfi_limit_d.
lv_total = lv_total + sy-dbcnt.
WRITE: / |ZFI_LIMIT_D:        { sy-dbcnt } rows deleted.|.

DELETE FROM zmmrouteroot_d.
lv_total = lv_total + sy-dbcnt.
WRITE: / |ZMMROUTEROOT_D:     { sy-dbcnt } rows deleted.|.

DELETE FROM zmmsafestock_d.
lv_total = lv_total + sy-dbcnt.
WRITE: / |ZMMSAFESTOCK_D:     { sy-dbcnt } rows deleted.|.

DELETE FROM zsd_price_conf_d.
lv_total = lv_total + sy-dbcnt.
WRITE: / |ZSD_PRICE_CONF_D:   { sy-dbcnt } rows deleted.|.

COMMIT WORK.

WRITE: / '--------------------------------------------'.
WRITE: / |Total: { lv_total } rows deleted. All request + draft data cleaned.|.
