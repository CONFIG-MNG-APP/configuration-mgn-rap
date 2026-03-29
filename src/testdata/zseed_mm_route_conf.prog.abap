*&---------------------------------------------------------------------*
*& Report zseed_mm_route_conf
*& Seed baseline data for ZMMROUTECONF across DEV / QAS / PRD envs
*&---------------------------------------------------------------------*
REPORT zseed_mm_route_conf.

" ── 1. Clean up existing data (incl. draft buffer) ─────────────────
DELETE FROM zmmrouteconf_req.
COMMIT WORK.

write: 'delete thành công'.
