CLASS zcl_gsp26_mail_sender DEFINITION
  PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      gc_ev_submitted   TYPE string VALUE 'SUBMITTED',
      gc_ev_approved    TYPE string VALUE 'APPROVED',
      gc_ev_rejected    TYPE string VALUE 'REJECTED',
      gc_ev_promoted    TYPE string VALUE 'PROMOTED',
      gc_ev_rolled_back TYPE string VALUE 'ROLLED_BACK'.

    CLASS-METHODS send_notification
      IMPORTING
        iv_event        TYPE string
        iv_req_id       TYPE sysuuid_x16
        iv_req_title    TYPE string
        iv_module_id    TYPE string
        iv_env_id       TYPE string
        iv_creator      TYPE syuname
        iv_triggered_by TYPE syuname
        iv_reason       TYPE string OPTIONAL.

  PRIVATE SECTION.
    CLASS-METHODS get_emails_by_role
      IMPORTING
        iv_module_id TYPE string
        iv_role      TYPE string
      RETURNING VALUE(rt_emails) TYPE string_table.

    CLASS-METHODS get_email_by_user
      IMPORTING
        iv_user_id TYPE syuname
      RETURNING VALUE(rv_email) TYPE ad_smtpadr.

    CLASS-METHODS build_html
      IMPORTING
        iv_event        TYPE string
        iv_req_id_c36   TYPE sysuuid_c36
        iv_req_title    TYPE string
        iv_module_id    TYPE string
        iv_env_id       TYPE string
        iv_triggered_by TYPE syuname
        iv_reason       TYPE string OPTIONAL
      RETURNING VALUE(rv_html) TYPE string.

    CLASS-METHODS do_send
      IMPORTING
        it_recipients TYPE string_table
        iv_subject    TYPE string
        iv_html       TYPE string.

ENDCLASS.


CLASS zcl_gsp26_mail_sender IMPLEMENTATION.

  METHOD send_notification.
    " Convert UUID X16 → C36 for display in email
    DATA lv_req_id_c36 TYPE sysuuid_c36.
    TRY.
        cl_system_uuid=>convert_uuid_x16_static(
          EXPORTING uuid     = iv_req_id
          IMPORTING uuid_c36 = lv_req_id_c36 ).
      CATCH cx_uuid_error.
        lv_req_id_c36 = ''.
    ENDTRY.

    DATA lt_recipients TYPE string_table.
    DATA lv_creator_email TYPE ad_smtpadr.

    CASE iv_event.
      WHEN gc_ev_submitted.
        lt_recipients = get_emails_by_role( iv_module_id = iv_module_id iv_role = 'MANAGER' ).

      WHEN gc_ev_approved OR gc_ev_rejected.
        lv_creator_email = get_email_by_user( iv_creator ).
        IF lv_creator_email IS NOT INITIAL.
          APPEND CONV string( lv_creator_email ) TO lt_recipients.
        ENDIF.

      WHEN gc_ev_promoted OR gc_ev_rolled_back.
        lv_creator_email = get_email_by_user( iv_creator ).
        IF lv_creator_email IS NOT INITIAL.
          APPEND CONV string( lv_creator_email ) TO lt_recipients.
        ENDIF.
        APPEND LINES OF get_emails_by_role( iv_module_id = iv_module_id iv_role = 'MANAGER' ) TO lt_recipients.
    ENDCASE.

    IF lt_recipients IS INITIAL. RETURN. ENDIF.

    DATA(lv_html) = build_html(
      iv_event        = iv_event
      iv_req_id_c36   = lv_req_id_c36
      iv_req_title    = iv_req_title
      iv_module_id    = iv_module_id
      iv_env_id       = iv_env_id
      iv_triggered_by = iv_triggered_by
      iv_reason       = iv_reason ).

    DATA(lv_subject) = SWITCH string( iv_event
      WHEN gc_ev_submitted   THEN |[ABAP19] New request pending approval: { iv_req_title }|
      WHEN gc_ev_approved    THEN |[ABAP19] Request approved: { iv_req_title }|
      WHEN gc_ev_rejected    THEN |[ABAP19] Request rejected: { iv_req_title }|
      WHEN gc_ev_promoted    THEN |[ABAP19] Request promoted: { iv_req_title }|
      WHEN gc_ev_rolled_back THEN |[ABAP19] Request rolled back: { iv_req_title }|
      ELSE                        |[ABAP19] System notification: { iv_req_title }| ).

    do_send( it_recipients = lt_recipients iv_subject = lv_subject iv_html = lv_html ).
  ENDMETHOD.


  METHOD get_emails_by_role.
    " Match exact module OR 'ALL' wildcard (same pattern as org_access = '*')
    SELECT zm~email
      FROM zuserrole AS zr
      INNER JOIN zusermail AS zm ON zm~user_id = zr~user_id
      WHERE ( zr~module_id = @iv_module_id OR zr~module_id = 'ALL' )
        AND zr~role_level = @iv_role
        AND zr~is_active  = @abap_true
      INTO TABLE @DATA(lt_result).
    rt_emails = VALUE #( FOR ls IN lt_result ( CONV string( ls-email ) ) ).
  ENDMETHOD.


  METHOD get_email_by_user.
    SELECT SINGLE email FROM zusermail
      WHERE user_id = @iv_user_id
      INTO @rv_email.
  ENDMETHOD.


  METHOD build_html.
    DATA(lv_color) = SWITCH string( iv_event
      WHEN gc_ev_rejected                    THEN '#bb0000'
      WHEN gc_ev_approved OR gc_ev_promoted  THEN '#107e3e'
      ELSE                                        '#0a6ed1' ).

    DATA(lv_label) = SWITCH string( iv_event
      WHEN gc_ev_submitted   THEN 'PENDING APPROVAL'
      WHEN gc_ev_approved    THEN 'APPROVED'
      WHEN gc_ev_rejected    THEN 'REJECTED'
      WHEN gc_ev_promoted    THEN 'PROMOTED'
      WHEN gc_ev_rolled_back THEN 'ROLLED BACK'
      ELSE                        iv_event ).

    DATA(lv_reason_row) = COND string(
      WHEN iv_reason IS NOT INITIAL
      THEN |<tr><td style="padding:8px;font-weight:bold;width:160px">Rejection Reason</td>|
        && |\n<td style="padding:8px">{ iv_reason }</td></tr>|
      ELSE '' ).

    " Each line kept under 132 chars; split by \n in do_send to avoid mid-tag breaking
    rv_html =
      `<html>` && |\n|
      && `<body style="font-family:Arial,sans-serif;font-size:14px;color:#333">` && |\n|
      && |<div style="border-left:4px solid { lv_color };padding:12px 20px;background:#f5f5f5">| && |\n|
      && |<h2 style="color:{ lv_color };margin:0 0 6px">{ lv_label }</h2>| && |\n|
      && `<p style="margin:0">Your configuration request has a new update.</p>` && |\n|
      && `</div>` && |\n|
      && `<table style="border-collapse:collapse;width:100%">` && |\n|
      && `<tr>` && |\n|
      && `<td style="padding:8px;font-weight:bold;width:160px">Title</td>` && |\n|
      && |<td style="padding:8px">{ iv_req_title }</td>| && |\n|
      && `</tr>` && |\n|
      && `<tr>` && |\n|
      && `<td style="padding:8px;font-weight:bold">Request ID</td>` && |\n|
      && |<td style="padding:8px">{ iv_req_id_c36 }</td>| && |\n|
      && `</tr>` && |\n|
      && `<tr>` && |\n|
      && `<td style="padding:8px;font-weight:bold">Module</td>` && |\n|
      && |<td style="padding:8px">{ iv_module_id }</td>| && |\n|
      && `</tr>` && |\n|
      && `<tr>` && |\n|
      && `<td style="padding:8px;font-weight:bold">Environment</td>` && |\n|
      && |<td style="padding:8px">{ iv_env_id }</td>| && |\n|
      && `</tr>` && |\n|
      && `<tr>` && |\n|
      && `<td style="padding:8px;font-weight:bold">Performed by</td>` && |\n|
      && |<td style="padding:8px">{ iv_triggered_by }</td>| && |\n|
      && `</tr>` && |\n|
      && lv_reason_row
      && `</table>` && |\n|
      && `<p style="margin-top:20px;font-size:12px;color:#888">` && |\n|
      && `This is an automated email from the ABAP19 Configuration Management system.` && |\n|
      && `</p>` && |\n|
      && `</body></html>`.
  ENDMETHOD.


  METHOD do_send.
    TRY.
        DATA(lo_req) = cl_bcs=>create_persistent( ).
        lo_req->set_send_immediately( abap_true ).

        " Split HTML by newlines into BCSY_TEXT — avoids breaking mid-tag
        DATA lt_body    TYPE bcsy_text.
        DATA lt_lines   TYPE string_table.
        SPLIT iv_html AT |\n| INTO TABLE lt_lines.
        LOOP AT lt_lines INTO DATA(lv_line).
          APPEND CONV #( lv_line ) TO lt_body.
        ENDLOOP.

        DATA(lo_doc) = cl_document_bcs=>create_document(
          i_type    = 'HTM'
          i_subject = CONV #( iv_subject )
          i_text    = lt_body ).
        lo_req->set_document( lo_doc ).

        LOOP AT it_recipients INTO DATA(lv_email).
          CHECK lv_email IS NOT INITIAL.
          lo_req->add_recipient(
            i_recipient = cl_cam_address_bcs=>create_internet_address( CONV #( lv_email ) ) ).
        ENDLOOP.

        " send() stores the request in the BCS tables as part of the current LUW.
        " The RAP framework COMMIT WORK will flush it; the SMTP background job then delivers it.
        lo_req->send( i_with_error_screen = abap_false ).

      CATCH cx_root.
        " Fire-and-forget: mail errors must not fail the business action
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
