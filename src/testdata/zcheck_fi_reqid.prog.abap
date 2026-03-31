REPORT zcheck_fi_reqid.

  WRITE: / '=== ALL ZCONFREQH ==='.
  SELECT req_id, status, module_id, req_title FROM zconfreqh
    INTO TABLE @DATA(lt_all).
  LOOP AT lt_all INTO DATA(ls_a).
    WRITE: / ls_a-req_id, ls_a-module_id, ls_a-status, ls_a-req_title.
  ENDLOOP.
  WRITE: / |Total: { lines( lt_all ) }|.

  WRITE: / ''.
  WRITE: / '=== ZFILIMITREQ DISTINCT REQ_ID ==='.
  SELECT DISTINCT req_id FROM zfilimitreq INTO TABLE @DATA(lt_r).
  LOOP AT lt_r INTO DATA(ls_r).
    READ TABLE lt_all WITH KEY req_id = ls_r-req_id INTO DATA(ls_match).
    IF sy-subrc = 0.
      WRITE: / 'MATCH:', ls_r-req_id, ls_match-status, ls_match-module_id.
    ELSE.
      WRITE: / 'NO MATCH:', ls_r-req_id.
    ENDIF.
  ENDLOOP.
