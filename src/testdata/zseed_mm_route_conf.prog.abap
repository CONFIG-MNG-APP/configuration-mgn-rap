*&---------------------------------------------------------------------*
*& Report zseed_mm_route_conf
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zseed_mm_route_conf.

DELETE FROM zsd_price_req.

COMMIT WORK.

WRITE: / 'All request test data cleared'.
