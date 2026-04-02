*&---------------------------------------------------------------------*
*& Report ztransmode
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ztransmode.

" DELETE FROM zconfreqh.

" COMMIT WORK.

" WRITE: / |Seeded { sy-dbcnt } row(s) into ZTRANSMODE.|.

DATA: lv_lines TYPE i.
DATA: lv_total TYPE i.

WRITE: / '=== Clearing Request & Config Data ==='.
WRITE: /.

" --- Request Header & Item ---
DELETE FROM zconfreqh.
lv_lines = sy-dbcnt.
lv_total = lv_total + lv_lines.
WRITE: / |Deleted { lv_lines } row(s) from ZCONFREQH (Request Header)|.

DELETE FROM zconfreqi.
lv_lines = sy-dbcnt.
lv_total = lv_total + lv_lines.
WRITE: / |Deleted { lv_lines } row(s) from ZCONFREQI (Request Item)|.

" --- SD Config Request ---
DELETE FROM zsd_price_conf_d.
lv_lines = sy-dbcnt.
lv_total = lv_total + lv_lines.
WRITE: / |Deleted { lv_lines } row(s) from ZSD_PRICE_CONF_D (SD Price Config Draft)|.

DELETE FROM zsd_price_req.
lv_lines = sy-dbcnt.
lv_total = lv_total + lv_lines.
WRITE: / |Deleted { lv_lines } row(s) from ZSD_PRICE_REQ (SD Price Request)|.

" --- FI Config Request ---
DELETE FROM zfi_limit_d.
lv_lines = sy-dbcnt.
lv_total = lv_total + lv_lines.
WRITE: / |Deleted { lv_lines } row(s) from ZFI_LIMIT_D (FI Limit Config Draft)|.

DELETE FROM zfilimitreq.
lv_lines = sy-dbcnt.
lv_total = lv_total + lv_lines.
WRITE: / |Deleted { lv_lines } row(s) from ZFILIMITREQ (FI Limit Config Request)|.

" --- MM Config Request ---
DELETE FROM zmmrouteconf_req.
lv_lines = sy-dbcnt.
lv_total = lv_total + lv_lines.
WRITE: / |Deleted { lv_lines } row(s) from ZMMROUTECONF_REQ (MM Route Config Request)|.

DELETE FROM zmmsafestock_req.
lv_lines = sy-dbcnt.
lv_total = lv_total + lv_lines.
WRITE: / |Deleted { lv_lines } row(s) from ZMMSAFESTOCK_REQ (MM Safe Stock Request)|.

COMMIT WORK.

WRITE: /.
WRITE: / |=== Total deleted: { lv_total } row(s) ===|.
