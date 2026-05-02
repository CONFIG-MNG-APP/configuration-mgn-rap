    CLASS lhc_Req DEFINITION INHERITING FROM cl_abap_behavior_handler.
      PRIVATE SECTION.

        CONSTANTS:
          gc_st_draft       TYPE zde_requ_status VALUE 'DRAFT',
          gc_st_submitted   TYPE zde_requ_status VALUE 'SUBMITTED',
          gc_st_approved    TYPE zde_requ_status VALUE 'APPROVED',
          gc_st_rejected    TYPE zde_requ_status VALUE 'REJECTED',
          gc_st_active      TYPE zde_requ_status VALUE 'ACTIVE',
          gc_st_rolled_back TYPE zde_requ_status VALUE 'ROLLED_BACK'.

        CONSTANTS:
          gc_role_manager TYPE zde_role_level VALUE 'MANAGER',
          gc_role_itadmin TYPE zde_role_level VALUE 'IT ADMIN',
          gc_role_keyuser TYPE zde_role_level VALUE 'KEY USER'.

        METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
          IMPORTING keys REQUEST requested_authorizations FOR Req RESULT result.

        METHODS get_instance_features FOR INSTANCE FEATURES
          IMPORTING keys REQUEST requested_features FOR Req RESULT result.

        METHODS approve FOR MODIFY IMPORTING keys FOR ACTION Req~approve RESULT result.
        METHODS reject FOR MODIFY IMPORTING keys FOR ACTION Req~reject RESULT result.
        METHODS submit FOR MODIFY IMPORTING keys FOR ACTION Req~submit RESULT result.
        METHODS promote FOR MODIFY IMPORTING keys FOR ACTION Req~promote RESULT result.
        METHODS rollback FOR MODIFY IMPORTING keys FOR ACTION Req~rollback RESULT result.
        METHODS createRequest FOR MODIFY IMPORTING keys FOR ACTION Req~createRequest RESULT result.
        METHODS updateReason FOR MODIFY IMPORTING keys FOR ACTION Req~updateReason RESULT result.

        METHODS set_default_and_admin_fields FOR DETERMINE ON MODIFY IMPORTING keys FOR Req~set_default_and_admin_fields.
        METHODS validate_before_save FOR VALIDATE ON SAVE IMPORTING keys FOR Req~validate_before_save.

    ENDCLASS.

    CLASS lhc_Req IMPLEMENTATION.

      METHOD get_instance_authorizations.
        " 1. Check each role separately — ZUSERROLE has a compound key (USER_ID + MODULE_ID),
        "    so SELECT SINGLE without MODULE_ID returns an arbitrary row (bug).
        "    Use a separate EXISTS check per role level instead.
        DATA: lv_has_manager TYPE abap_bool,
              lv_has_itadmin TYPE abap_bool,
              lv_has_keyuser TYPE abap_bool.

        SELECT SINGLE @abap_true FROM zuserrole
          WHERE user_id   = @sy-uname
            AND role_level = @gc_role_manager
            AND is_active  = @abap_true
          INTO @lv_has_manager.

        SELECT SINGLE @abap_true FROM zuserrole
          WHERE user_id   = @sy-uname
            AND role_level = @gc_role_itadmin
            AND is_active  = @abap_true
          INTO @lv_has_itadmin.

        SELECT SINGLE @abap_true FROM zuserrole
          WHERE user_id   = @sy-uname
            AND role_level = @gc_role_keyuser
            AND is_active  = @abap_true
          INTO @lv_has_keyuser.

        " 2. Read the current request records
        READ ENTITIES OF zir_conf_req_h IN LOCAL MODE
          ENTITY Req FIELDS ( Status ) WITH CORRESPONDING #( keys )
          RESULT DATA(lt_reqs).

        " 3. Map permissions by role

        " Any user with at least one role can submit
        DATA(lv_auth_submit) = COND #(
          WHEN lv_has_manager = abap_true OR lv_has_itadmin = abap_true OR lv_has_keyuser = abap_true
          THEN if_abap_behv=>auth-allowed
          ELSE if_abap_behv=>auth-unauthorized ).

        " Only MANAGER can approve or reject
        DATA(lv_auth_manager) = COND #(
          WHEN lv_has_manager = abap_true
          THEN if_abap_behv=>auth-allowed
          ELSE if_abap_behv=>auth-unauthorized ).

        " Only IT ADMIN can promote or rollback
        DATA(lv_auth_itadmin) = COND #(
          WHEN lv_has_itadmin = abap_true
          THEN if_abap_behv=>auth-allowed
          ELSE if_abap_behv=>auth-unauthorized ).

        " Only KEY USER and MANAGER can edit or delete (IT ADMIN does not create or delete requests)
        DATA(lv_auth_edit_del) = COND #(
          WHEN lv_has_keyuser = abap_true OR lv_has_manager = abap_true
          THEN if_abap_behv=>auth-allowed
          ELSE if_abap_behv=>auth-unauthorized ).

        " 4. Apply permissions to each request
        LOOP AT lt_reqs INTO DATA(ls_req).
          APPEND VALUE #( %tky                 = ls_req-%tky
                          %update              = lv_auth_edit_del
                          %delete              = lv_auth_edit_del
                          %action-Edit         = lv_auth_edit_del
                          %action-submit       = lv_auth_submit
                          %action-approve      = lv_auth_manager
                          %action-reject       = lv_auth_manager
                          %action-updatereason = lv_auth_submit
                          %action-promote      = lv_auth_itadmin
                          %action-rollback     = lv_auth_itadmin
                        ) TO result.
        ENDLOOP.
      ENDMETHOD.


      METHOD get_instance_features.
        " 1. Read the current status of each request
        READ ENTITIES OF zir_conf_req_h IN LOCAL MODE
          ENTITY Req FIELDS ( Status ) WITH CORRESPONDING #( keys )
          RESULT DATA(lt_reqs).

        " 2. Enable or disable action buttons based on status

        LOOP AT lt_reqs INTO DATA(ls_req).


          DATA(lv_approve)  = if_abap_behv=>fc-o-disabled.
          DATA(lv_reject)   = if_abap_behv=>fc-o-disabled.
          DATA(lv_submit)   = if_abap_behv=>fc-o-disabled.
          DATA(lv_promote)  = if_abap_behv=>fc-o-disabled.
          DATA(lv_rollback) = if_abap_behv=>fc-o-disabled.
          DATA(lv_update)   = if_abap_behv=>fc-o-disabled.
          DATA(lv_delete)   = if_abap_behv=>fc-o-disabled.


          CASE condense( ls_req-Status ).

            WHEN gc_st_draft OR gc_st_rolled_back.
              lv_submit  = if_abap_behv=>fc-o-enabled.
              lv_update  = if_abap_behv=>fc-o-enabled.
              lv_delete  = if_abap_behv=>fc-o-enabled.

            WHEN gc_st_submitted.
              lv_approve = if_abap_behv=>fc-o-enabled.
              lv_reject  = if_abap_behv=>fc-o-enabled.

            WHEN gc_st_approved.
              lv_promote  = if_abap_behv=>fc-o-enabled.
              lv_rollback = if_abap_behv=>fc-o-enabled.

            WHEN gc_st_active.
              lv_promote  = if_abap_behv=>fc-o-enabled.
              lv_rollback = if_abap_behv=>fc-o-enabled.

            WHEN gc_st_rejected.

          ENDCASE.


          APPEND VALUE #( %tky             = ls_req-%tky
                          %update          = lv_update
                          %delete          = lv_delete
                          %action-Edit     = lv_update
                          %action-approve  = lv_approve
                          %action-reject   = lv_reject
                          %action-submit   = lv_submit
                          %action-promote  = lv_promote
                          %action-rollback = lv_rollback
                        ) TO result.

        ENDLOOP.
      ENDMETHOD.


      METHOD approve.
        DATA: lv_now TYPE timestampl.
        GET TIME STAMP FIELD lv_now.

        " Write-back always targets DEV environment
        CONSTANTS: lc_env_dev TYPE string VALUE 'DEV'.

        " Collect all audit log entries; insert in one batch at the end
        DATA lt_audit_log TYPE zcl_gsp26_rule_writer=>tt_audit_logs.

        " Variables for push notification
        DATA: lt_notifications TYPE /iwngw/if_notif_provider=>ty_t_notification,
              ls_notification  TYPE /iwngw/if_notif_provider=>ty_s_notification,
              lt_recipients    TYPE /iwngw/if_notif_provider=>ty_t_notification_recipient,
              ls_recipient     TYPE /iwngw/if_notif_provider=>ty_s_notification_recipient.

        " 1. Read request header and its items
        READ ENTITIES OF zir_conf_req_h IN LOCAL MODE
          ENTITY Req ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(reqs)
          ENTITY Req BY \_Items ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(items).

        LOOP AT reqs ASSIGNING FIELD-SYMBOL(<r>).
          DATA(lv_has_error) = abap_false.

          " 2. Check status transition
          IF zcl_gsp26_rule_status=>is_transition_valid_by_status(
                 iv_current_status = CONV string( <r>-Status )
                 iv_next_status    = zcl_gsp26_rule_status=>cv_approved ) = abap_false.
            lv_has_error = abap_true.
            APPEND VALUE #( %tky = <r>-%tky ) TO failed-req.
            APPEND VALUE #( %tky = <r>-%tky %msg = new_message_with_text(
                             severity = if_abap_behv_message=>severity-error
                             text = 'Request is not in pending approval status.' ) ) TO reported-req.
          ENDIF.

          " 3. Filter items for this request and check at least one exists
          DATA(lt_curr_items) = items.
          DELETE lt_curr_items WHERE ReqId <> <r>-ReqId.

          IF lt_curr_items IS INITIAL AND lv_has_error = abap_false.
            lv_has_error = abap_true.
            APPEND VALUE #( %tky = <r>-%tky ) TO failed-req.
            APPEND VALUE #( %tky = <r>-%tky %msg = new_message_with_text(
                             severity = if_abap_behv_message=>severity-error
                             text = 'Request has no items and cannot be approved.' ) ) TO reported-req.
          ENDIF.

          IF lv_has_error = abap_true. CONTINUE. ENDIF.

          " 4. Run catalog-level validation for each item
          LOOP AT lt_curr_items INTO DATA(ls_item).
            DATA(lt_val_errors) = zcl_gsp26_rule_validator=>validate_request_item(
                                    iv_conf_id       = ls_item-ConfId
                                    iv_action        = ls_item-Action
                                    iv_target_env_id = CONV #( lc_env_dev ) ). " target env is always DEV at approve time
            IF lt_val_errors IS NOT INITIAL.
              lv_has_error = abap_true.
              APPEND VALUE #( %tky = <r>-%tky ) TO failed-req.
              LOOP AT lt_val_errors INTO DATA(ls_err).
                APPEND VALUE #( %tky = <r>-%tky %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text = |Item { ls_item-ConfId }: { ls_err-message }| ) ) TO reported-req.
              ENDLOOP.
            ENDIF.
          ENDLOOP.

          IF lv_has_error = abap_true. CONTINUE. ENDIF.

          " Phase 2: PRE-WRITE VALIDATIONS
          DATA(lt_pre_errors) = zcl_gsp26_rule_validator=>validate_approve_pre_write(
                                  iv_req_id = <r>-ReqId
                                  iv_env_id = CONV #( lc_env_dev ) ).
          LOOP AT lt_pre_errors INTO DATA(ls_pre_err).
            lv_has_error = abap_true.
            APPEND VALUE #( %tky = <r>-%tky %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = ls_pre_err-message ) ) TO reported-req.
          ENDLOOP.

          IF lv_has_error = abap_true.
            APPEND VALUE #( %tky = <r>-%tky ) TO failed-req.
            CONTINUE.
          ENDIF.

          " 6. Mark the request as APPROVED
          MODIFY ENTITIES OF zir_conf_req_h IN LOCAL MODE
            ENTITY Req UPDATE FIELDS ( Status ApprovedBy ApprovedAt )
            WITH VALUE #( ( %tky = <r>-%tky Status = gc_st_approved ApprovedBy = sy-uname ApprovedAt = lv_now ) ).

          " Phase 3: WRITE-BACK — delegate each module to zcl_gsp26_rule_writer
          APPEND LINES OF zcl_gsp26_rule_writer=>write_back_mmss(
            iv_req_id = <r>-ReqId iv_env_id = CONV #( lc_env_dev )
            iv_now = lv_now iv_changed_by = sy-uname ) TO lt_audit_log.
          APPEND LINES OF zcl_gsp26_rule_writer=>write_back_mmroute(
            iv_req_id = <r>-ReqId iv_env_id = CONV #( lc_env_dev )
            iv_now = lv_now iv_changed_by = sy-uname ) TO lt_audit_log.
          APPEND LINES OF zcl_gsp26_rule_writer=>write_back_fi(
            iv_req_id = <r>-ReqId iv_env_id = CONV #( lc_env_dev )
            iv_now = lv_now iv_changed_by = sy-uname ) TO lt_audit_log.
          APPEND LINES OF zcl_gsp26_rule_writer=>write_back_sd(
            iv_req_id = <r>-ReqId iv_env_id = CONV #( lc_env_dev )
            iv_now = lv_now iv_changed_by = sy-uname ) TO lt_audit_log.

          " Send push notification to the request creator
          CLEAR: lt_notifications, lt_recipients, ls_notification, ls_recipient.

          " 1. Recipient is the user who created the request
          ls_recipient-id = <r>-CreatedBy.
          APPEND ls_recipient TO lt_recipients.

          " 2. Build notification payload
          TRY.
              ls_notification-id = cl_system_uuid=>create_uuid_x16_static( ).
            CATCH cx_uuid_error.
          ENDTRY.

          ls_notification-type_key     = 'REQ_APPROVED'. " must match the type ID registered in the notification provider class
          ls_notification-type_version = '1'.
          ls_notification-priority     = /iwngw/if_notif_provider=>gcs_priorities-low.
          ls_notification-recipients   = lt_recipients.

          " 3. Pass {ReqTitle} variable — parameters must be wrapped in a language block
          ls_notification-parameters = VALUE #(
            ( language = sy-langu
              parameters = VALUE #(
                ( name = 'ReqTitle' value = CONV #( <r>-ReqTitle ) type = 'Edm.String' )
              )
            )
          ).

          " 4. Deep-link so clicking the notification opens the request
          " SemanticObject and Action must match manifest.json of the request manager app
          ls_notification-navigation_parameters = VALUE #(
            ( name = 'SemanticObject' value = 'ConfigReq' )
            ( name = 'Action'         value = 'manage' )
            ( name = 'ReqId'          value = CONV #( <r>-ReqId ) )
          ).

          APPEND ls_notification TO lt_notifications.

          " 5. Send the notification
          TRY.
              /iwngw/cl_notification_api=>create_notifications(
                EXPORTING
                  iv_provider_id  = 'ZGSP26SAP06_REQ_NOTIF'
                  it_notification = lt_notifications
              ).
            CATCH /iwngw/cx_notification_api INTO DATA(lx_notif_error).
          ENDTRY.

        ENDLOOP.

        " 7. Flush all collected audit logs in one INSERT
        zcl_gsp26_rule_writer=>flush_audit_logs( lt_audit_log ).

        " 8. Re-read to populate %param in the result
        READ ENTITIES OF zir_conf_req_h IN LOCAL MODE
          ENTITY Req ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_final).

        result = VALUE #( FOR ls_final IN lt_final ( %tky = ls_final-%tky %param = ls_final ) ).
      ENDMETHOD.




      METHOD reject.
        DATA lv_now TYPE timestampl.
        GET TIME STAMP FIELD lv_now.

        " 1. Read request headers
        READ ENTITIES OF zir_conf_req_h IN LOCAL MODE
          ENTITY Req ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(reqs).

        LOOP AT reqs ASSIGNING FIELD-SYMBOL(<r>).
          DATA(lv_has_error) = abap_false.

          " 2. Get rejection reason from the action popup parameter
          DATA(ls_key_entry) = VALUE #( keys[ %tky = <r>-%tky ] OPTIONAL ).
          DATA(lv_reason)    = ls_key_entry-%param-reason.

          " 3. Trim status value
          DATA(lv_current_status) = condense( <r>-Status ).

          " 4. Rejection reason must not be empty
          IF lv_reason IS INITIAL.
            lv_has_error = abap_true.
            APPEND VALUE #( %tky = <r>-%tky ) TO failed-req.
            APPEND VALUE #( %tky = <r>-%tky
                            %msg = new_message_with_text(
                                     severity = if_abap_behv_message=>severity-error
                                     text     = 'Rejection reason is required.' )
                          ) TO reported-req.
          ENDIF.

          " 5. Request must be in SUBMITTED status
          IF zcl_gsp26_rule_status=>is_transition_valid_by_status(
                 iv_current_status = CONV string( lv_current_status )
                 iv_next_status    = zcl_gsp26_rule_status=>cv_rejected ) = abap_false AND lv_has_error = abap_false.
            lv_has_error = abap_true.
            APPEND VALUE #( %tky = <r>-%tky ) TO failed-req.
            APPEND VALUE #( %tky = <r>-%tky
                            %msg = new_message_with_text(
                                     severity = if_abap_behv_message=>severity-error
                                     text     = |Request is not in SUBMITTED status (Current: '{ lv_current_status }')| )
                          ) TO reported-req.
            CONTINUE.
          ENDIF.

          IF lv_has_error = abap_true. CONTINUE. ENDIF.

          " 6. Write audit log entry
          TRY.
              zcl_gsp26_rule_writer=>log_audit_entry(
                iv_req_id   = <r>-ReqId
                iv_conf_id  = <r>-ConfId
                iv_mod_id   = <r>-ModuleId
                iv_act_type = 'REJECT'
                iv_tab_name = 'ZCONFREQH'
                iv_env_id   = <r>-EnvId
                is_new_data = VALUE #( BASE <r> Status = gc_st_rejected RejectReason = lv_reason )
              ).
            CATCH cx_root INTO DATA(lx_audit_rej).
              APPEND VALUE #( %tky = <r>-%tky %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-warning
                text = |Audit log failed: { lx_audit_rej->get_text( ) }| ) ) TO reported-req.
          ENDTRY.

          " 7. Update request status to REJECTED
          MODIFY ENTITIES OF zir_conf_req_h IN LOCAL MODE
            ENTITY Req UPDATE FIELDS ( Status RejectReason RejectedBy RejectedAt )
            WITH VALUE #( ( %tky         = <r>-%tky
                            Status       = gc_st_rejected
                            RejectReason = lv_reason
                            RejectedBy   = sy-uname
                            RejectedAt   = lv_now ) ).

          " Send rejection push notification to the request creator
          DATA: lt_notif_rej TYPE /iwngw/if_notif_provider=>ty_t_notification,
                ls_notif_rej TYPE /iwngw/if_notif_provider=>ty_s_notification,
                lt_recip_rej TYPE /iwngw/if_notif_provider=>ty_t_notification_recipient,
                ls_recip_rej TYPE /iwngw/if_notif_provider=>ty_s_notification_recipient.

          ls_recip_rej-id = <r>-CreatedBy.
          APPEND ls_recip_rej TO lt_recip_rej.

          TRY.
              ls_notif_rej-id = cl_system_uuid=>create_uuid_x16_static( ).
            CATCH cx_uuid_error.
          ENDTRY.

          ls_notif_rej-type_key     = 'REQ_REJECTED'.
          ls_notif_rej-type_version = '1'.
          ls_notif_rej-priority     = /iwngw/if_notif_provider=>gcs_priorities-high.
          ls_notif_rej-recipients   = lt_recip_rej.
          ls_notif_rej-parameters   = VALUE #(
            ( language   = sy-langu
              parameters = VALUE #(
                ( name = 'ReqTitle' value = CONV #( <r>-ReqTitle ) type = 'Edm.String' )
              )
            )
          ).
          ls_notif_rej-navigation_parameters = VALUE #(
            ( name = 'SemanticObject' value = 'ConfigReq' )
            ( name = 'Action'         value = 'manage' )
            ( name = 'ReqId'          value = CONV #( <r>-ReqId ) )
          ).
          APPEND ls_notif_rej TO lt_notif_rej.

          TRY.
              /iwngw/cl_notification_api=>create_notifications(
                EXPORTING
                  iv_provider_id  = 'ZGSP26SAP06_REQ_NOTIF'
                  it_notification = lt_notif_rej
              ).
            CATCH /iwngw/cx_notification_api.
          ENDTRY.

        ENDLOOP.

        " 8. Re-read to populate %param in the result
        READ ENTITIES OF zir_conf_req_h IN LOCAL MODE
          ENTITY Req ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(lt_final_reqs).

        result = VALUE #( FOR res IN lt_final_reqs ( %tky   = res-%tky
                                                     %param = res ) ).
      ENDMETHOD.

      METHOD submit. " Read headers and items in one call to avoid N+1 queries
        READ ENTITIES OF zir_conf_req_h IN LOCAL MODE
          ENTITY Req FIELDS ( ReqId Status ) WITH CORRESPONDING #( keys ) RESULT DATA(reqs)
          ENTITY Req BY \_Items FIELDS ( ReqId ) WITH CORRESPONDING #( keys ) RESULT DATA(all_items).

        LOOP AT reqs ASSIGNING FIELD-SYMBOL(<r>).
          IF zcl_gsp26_rule_status=>is_transition_valid_by_status(
               iv_current_status = CONV string( <r>-Status )
               iv_next_status    = zcl_gsp26_rule_status=>cv_submitted ) = abap_false.
            APPEND VALUE #( %tky = <r>-%tky ) TO failed-req.
            APPEND VALUE #( %tky = <r>-%tky %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text = 'Invalid status transition for Submit' ) ) TO reported-req.
            CONTINUE.
          ENDIF.

          READ TABLE all_items WITH KEY ReqId = <r>-ReqId TRANSPORTING NO FIELDS.
          IF sy-subrc <> 0.
            APPEND VALUE #(
              %tky = <r>-%tky %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
              text = 'Request must contain at least one item before submit' ) )
            TO reported-Req.
            APPEND VALUE #( %tky = <r>-%tky ) TO failed-req.
            CONTINUE.
          ENDIF.

          MODIFY ENTITIES OF zir_conf_req_h IN LOCAL MODE ENTITY Req
            UPDATE FIELDS ( Status )
            WITH VALUE #( ( %tky = <r>-%tky Status = gc_st_submitted ) ).
        ENDLOOP.
        result = VALUE #( FOR r IN reqs ( %tky = r-%tky ) ).
      ENDMETHOD.

      METHOD set_default_and_admin_fields.
        DATA lv_now TYPE timestampl.
        GET TIME STAMP FIELD lv_now.
        READ ENTITIES OF zir_conf_req_h IN LOCAL MODE ENTITY Req ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_req).

        MODIFY ENTITIES OF zir_conf_req_h IN LOCAL MODE
          ENTITY Req UPDATE FIELDS ( Status EnvId CreatedBy CreatedAt ChangedBy ChangedAt )
          WITH VALUE #( FOR ls_req IN lt_req (
              %tky      = ls_req-%tky
              Status    = COND #( WHEN ls_req-Status IS INITIAL THEN gc_st_draft ELSE ls_req-Status )
              EnvId     = COND #( WHEN ls_req-EnvId  IS INITIAL THEN 'DEV'       ELSE ls_req-EnvId )
              CreatedBy = COND #( WHEN ls_req-CreatedBy IS INITIAL THEN sy-uname ELSE ls_req-CreatedBy )
              CreatedAt = COND #( WHEN ls_req-CreatedAt IS INITIAL THEN lv_now   ELSE ls_req-CreatedAt )
              ChangedBy = sy-uname
              ChangedAt = lv_now ) ).
      ENDMETHOD.

      METHOD validate_before_save.
        READ ENTITIES OF zir_conf_req_h IN LOCAL MODE
          ENTITY Req ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(reqs).

        LOOP AT reqs ASSIGNING FIELD-SYMBOL(<r>).
          IF <r>-Status = gc_st_approved OR <r>-Status = gc_st_rejected.
            APPEND VALUE #(
              %tky = <r>-%tky
              %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text     = 'Completed request cannot be changed'
              )
            ) TO reported-req.
            APPEND VALUE #( %tky = <r>-%tky ) TO failed-req.
          ENDIF.
        ENDLOOP.

      ENDMETHOD.

      METHOD promote.
        DATA lv_now TYPE timestampl.
        GET TIME STAMP FIELD lv_now.

        DATA lv_prd_ver_ss TYPE i.
        DATA lv_prd_ver_rt TYPE i.
        DATA lv_prd_ver_fi TYPE i.
        DATA lv_prd_ver_sd TYPE i.
        DATA lt_promo_log  TYPE zcl_gsp26_rule_writer=>tt_audit_logs.

        READ ENTITIES OF zir_conf_req_h IN LOCAL MODE
          ENTITY Req ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(reqs).

        LOOP AT reqs ASSIGNING FIELD-SYMBOL(<r>).

          " Both APPROVED and ACTIVE are valid starting states for promote
          IF <r>-Status <> gc_st_approved AND <r>-Status <> gc_st_active.
            APPEND VALUE #( %tky = <r>-%tky
              %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text     = 'Status must be APPROVED or ACTIVE' )
            ) TO reported-req.
            APPEND VALUE #( %tky = <r>-%tky ) TO failed-req.
            CONTINUE.
          ENDIF.

          " Determine the next environment in the chain
          DATA(lv_next_env) = CONV zde_env_id( SWITCH #( condense( <r>-EnvId )
            WHEN 'DEV' THEN 'QAS'
            WHEN 'QAS' THEN 'PRD'
            ELSE '' ) ).

          IF lv_next_env IS INITIAL.
            APPEND VALUE #( %tky = <r>-%tky
              %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text     = 'Request is already at PRD environment, cannot promote further.' )
            ) TO reported-req.
            APPEND VALUE #( %tky = <r>-%tky ) TO failed-req.
            CONTINUE.
          ENDIF.

          " ── Get a single global version for each module when promoting to PRD ──
          IF lv_next_env = 'PRD'.
            lv_prd_ver_ss = zcl_gsp26_rule_version=>get_global_version( iv_table_name = 'ZMMSAFESTOCK'   iv_env_id = 'PRD' ).
            lv_prd_ver_rt = zcl_gsp26_rule_version=>get_global_version( iv_table_name = 'ZMMROUTECONF'   iv_env_id = 'PRD' ).
            lv_prd_ver_fi = zcl_gsp26_rule_version=>get_global_version( iv_table_name = 'ZFILIMITCONF'   iv_env_id = 'PRD' ).
            lv_prd_ver_sd = zcl_gsp26_rule_version=>get_global_version( iv_table_name = 'ZSD_PRICE_CONF' iv_env_id = 'PRD' ).
          ENDIF.

          " ── Promote all modules to target env ──
          APPEND LINES OF zcl_gsp26_rule_snapshot=>promote_mmss(
            iv_req_id = <r>-ReqId iv_conf_id = <r>-ConfId
            iv_src_env_id = <r>-EnvId iv_tgt_env_id = lv_next_env
            iv_prd_ver = lv_prd_ver_ss iv_now = lv_now iv_changed_by = sy-uname ) TO lt_promo_log.
          APPEND LINES OF zcl_gsp26_rule_snapshot=>promote_mmroute(
            iv_req_id = <r>-ReqId iv_conf_id = <r>-ConfId
            iv_src_env_id = <r>-EnvId iv_tgt_env_id = lv_next_env
            iv_prd_ver = lv_prd_ver_rt iv_now = lv_now iv_changed_by = sy-uname ) TO lt_promo_log.
          APPEND LINES OF zcl_gsp26_rule_snapshot=>promote_fi(
            iv_req_id = <r>-ReqId iv_conf_id = <r>-ConfId
            iv_src_env_id = <r>-EnvId iv_tgt_env_id = lv_next_env
            iv_prd_ver = lv_prd_ver_fi iv_now = lv_now iv_changed_by = sy-uname ) TO lt_promo_log.
          APPEND LINES OF zcl_gsp26_rule_snapshot=>promote_sd(
            iv_req_id = <r>-ReqId iv_conf_id = <r>-ConfId
            iv_src_env_id = <r>-EnvId iv_tgt_env_id = lv_next_env
            iv_prd_ver = lv_prd_ver_sd iv_now = lv_now iv_changed_by = sy-uname ) TO lt_promo_log.

          " ── Update request header: move env_id to next env ──
          " EnvId is a RAP key field — cannot change via MODIFY ENTITIES UPDATE.
          " Use direct SQL to shift the row's env_id (DEV→QAS or QAS→PRD).
          " Status = ACTIVE only when reaching PRD (config is fully live).
          " Status stays APPROVED while still promoting through intermediate envs.
          DATA lv_new_status TYPE zde_requ_status.
          lv_new_status = COND #( WHEN lv_next_env = 'PRD'
                                  THEN gc_st_active
                                  ELSE gc_st_approved ).
          UPDATE zconfreqh
            SET env_id     = @lv_next_env,
                status     = @lv_new_status,
                changed_by = @sy-uname,
                changed_at = @lv_now
            WHERE req_id = @<r>-ReqId
              AND env_id  = @<r>-EnvId.

        ENDLOOP.

        zcl_gsp26_rule_writer=>flush_audit_logs( lt_promo_log ).

        result = VALUE #( FOR r IN reqs ( %tky = r-%tky ) ).
      ENDMETHOD.


      METHOD rollback.
        DATA lv_now TYPE timestampl.
        GET TIME STAMP FIELD lv_now.

        READ ENTITIES OF zir_conf_req_h IN LOCAL MODE
          ENTITY Req ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(reqs).

        LOOP AT reqs ASSIGNING FIELD-SYMBOL(<r>).
          IF <r>-Status <> gc_st_approved AND <r>-Status <> gc_st_active.

            APPEND VALUE #(
              %tky = <r>-%tky
              %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text     = 'Rollback is only allowed when status is Approved or Active.' )
            ) TO reported-req.
            APPEND VALUE #( %tky = <r>-%tky ) TO failed-req.
            CONTINUE.
          ENDIF.

          TRY.
              DATA(lt_restore) = zcl_gsp26_rule_snapshot=>restore_from_snapshot(
                iv_req_id     = <r>-ReqId
                iv_changed_by = sy-uname ).

              LOOP AT lt_restore INTO DATA(ls_res).
                APPEND VALUE #(
                  %tky = <r>-%tky
                  %msg = new_message_with_text(
                    severity = COND #( WHEN ls_res-success = abap_true
                                       THEN if_abap_behv_message=>severity-success
                                       ELSE if_abap_behv_message=>severity-warning )
                    text = ls_res-message )
                ) TO reported-req.
              ENDLOOP.
            CATCH cx_root INTO DATA(lx).
              APPEND VALUE #(
                %tky = <r>-%tky
                %msg = new_message_with_text(
                  severity = if_abap_behv_message=>severity-error
                  text     = |Rollback failed: { lx->get_text( ) }| )
              ) TO reported-req.
              APPEND VALUE #( %tky = <r>-%tky ) TO failed-req.
              CONTINUE.
          ENDTRY.

          TRY.
              zcl_gsp26_rule_writer=>log_audit_entry(
                iv_conf_id  = <r>-ConfId
                iv_req_id   = <r>-ReqId
                iv_mod_id   = <r>-ModuleId
                iv_act_type = 'ROLLBACK'
                iv_tab_name = 'ZCONFREQH'
                iv_env_id   = <r>-EnvId
                is_new_data = VALUE #( BASE <r> Status = gc_st_rolled_back ) ).
            CATCH cx_root INTO DATA(lx_audit_rb).
              APPEND VALUE #( %tky = <r>-%tky %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-warning
                text = |Audit log failed: { lx_audit_rb->get_text( ) }| ) ) TO reported-req.
          ENDTRY.

          " Use direct SQL like promote() — avoids RAP buffer/DB key conflict when env_id changes.
          " restore_from_snapshot() reverts ALL environments at once, so env_id resets to DEV.
          UPDATE zconfreqh
            SET env_id     = 'DEV',
                status     = @gc_st_rolled_back,
                changed_by = @sy-uname,
                changed_at = @lv_now
            WHERE req_id = @<r>-ReqId
              AND env_id  = @<r>-EnvId.

        ENDLOOP.

        result = VALUE #( FOR r IN reqs ( %tky = r-%tky ) ).
      ENDMETHOD.

      METHOD createRequest.
        DATA lv_now              TYPE timestampl.
        DATA lv_conf_id_x16      TYPE sysuuid_x16.
        DATA lv_uuid_c36         TYPE sysuuid_c36.
        DATA lv_env              TYPE zde_env_id.
        DATA lv_req_id_x16       TYPE sysuuid_x16.
        DATA lv_req_item_id_x16  TYPE sysuuid_x16.
        DATA lv_req_id_c36       TYPE sysuuid_c36.
        DATA lv_target_app       TYPE char30.
        DATA lv_conf_id_c36      TYPE string.

        IF keys IS INITIAL. RETURN. ENDIF.

        LOOP AT keys INTO DATA(ls_key).

          CLEAR: lv_now, lv_conf_id_x16, lv_uuid_c36, lv_env,
                 lv_req_id_x16, lv_req_item_id_x16, lv_req_id_c36,
                 lv_target_app, lv_conf_id_c36.

          GET TIME STAMP FIELD lv_now.

          " ── Validate ConfId ──
          IF ls_key-%param-ConfId IS INITIAL.
            APPEND VALUE #(
              %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text     = 'ConfId is empty' )
            ) TO reported-req.
            CONTINUE.
          ENDIF.

          " ── Normalize UUID C36 ──
          lv_conf_id_c36 = to_upper( ls_key-%param-ConfId ).
          IF strlen( lv_conf_id_c36 ) = 32.
            lv_conf_id_c36 = lv_conf_id_c36(8)
              && '-' && lv_conf_id_c36+8(4)
              && '-' && lv_conf_id_c36+12(4)
              && '-' && lv_conf_id_c36+16(4)
              && '-' && lv_conf_id_c36+20(12).
          ENDIF.

          " ── Convert UUID C36 → X16 ──
          lv_uuid_c36 = lv_conf_id_c36.
          TRY.
              cl_system_uuid=>convert_uuid_c36_static(
                EXPORTING uuid     = lv_uuid_c36
                IMPORTING uuid_x16 = lv_conf_id_x16 ).
            CATCH cx_uuid_error INTO DATA(lx_uuid).
              APPEND VALUE #(
                %msg = new_message_with_text(
                  severity = if_abap_behv_message=>severity-error
                  text     = |UUID error: { lx_uuid->get_text( ) }| )
              ) TO reported-req.
              CONTINUE.
          ENDTRY.

          " ── Validate catalog is active ──
          SELECT SINGLE is_active, conf_name FROM zconfcatalog
            WHERE conf_id = @lv_conf_id_x16
            INTO @DATA(ls_cat).
          IF sy-subrc <> 0.
            APPEND VALUE #(
              %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text     = 'Configuration does not exist in catalog' )
            ) TO reported-req.
            CONTINUE.
          ENDIF.
          IF ls_cat-is_active <> abap_true.
            APPEND VALUE #(
              %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text     = |Configuration '{ ls_cat-conf_name }' is inactive and cannot be used to create a request| )
            ) TO reported-req.
            CONTINUE.
          ENDIF.

          " Default to DEV if no target env provided
          lv_env = COND #(
            WHEN ls_key-%param-TargetEnvId IS INITIAL
            THEN 'DEV'
            ELSE ls_key-%param-TargetEnvId ).

          " Create request header and one item in a single MODIFY call
          MODIFY ENTITIES OF zir_conf_req_h
            IN LOCAL MODE
            ENTITY Req
              CREATE SET FIELDS
                WITH VALUE #( (
                  %cid        = 'NEW_REQ'
                  ConfId      = lv_conf_id_x16
                  EnvId       = lv_env
                  ModuleId    = ls_key-%param-ModuleId
                  ReqTitle    = |Maintain { ls_key-%param-ConfName }|
                  Description = |Created from config|
                  Reason      = ls_key-%param-Reason
                ) )
            ENTITY Req
              CREATE BY \_Items SET FIELDS
                WITH VALUE #( (
                  %cid_ref = 'NEW_REQ'
                  %target  = VALUE #( (
                    %cid        = 'NEW_ITEM'
                    ConfId      = lv_conf_id_x16
                    Action      = ls_key-%param-ActionType
                    TargetEnvId = lv_env
                    Notes       = ls_key-%param-Notes
                    VersionNo   = 0
                  ) )
                ) )
            MAPPED   DATA(ls_mapped)
            FAILED   DATA(ls_failed)
            REPORTED DATA(ls_reported).

          IF ls_failed-req IS NOT INITIAL.
            APPEND LINES OF ls_failed-req   TO failed-req.
            APPEND LINES OF ls_reported-req TO reported-req.
            CONTINUE.
          ENDIF.

          " Get the new req_id and req_item_id from the mapped result
          lv_req_id_x16      = ls_mapped-req[ 1 ]-%key-ReqId.
          lv_req_item_id_x16 = ls_mapped-item[ 1 ]-%key-ReqItemId.

          " Convert req_id to C36 and resolve the target app name for navigation
          cl_system_uuid=>convert_uuid_x16_static(
            EXPORTING uuid     = lv_req_id_x16
            IMPORTING uuid_c36 = lv_req_id_c36 ).

          lv_target_app = SWITCH #( ls_key-%param-TargetCds
            WHEN 'ZI_MM_ROUTE_CONF' THEN 'MM_ROUTE_REQ'
            WHEN 'ZI_MM_SAFE_STOCK' THEN 'MM_SAFE_REQ'
            WHEN 'ZI_SD_PRICE_CONF' THEN 'SD_PRICE_REQ'
            WHEN 'ZI_FI_LIMIT_CONF' THEN 'FI_LIMIT_REQ'
            ELSE                         'CONF_REQ' ).

          APPEND VALUE #(
            %param-ReqId     = lv_req_id_c36
            %param-ConfId    = ls_key-%param-ConfId
            %param-ModuleId  = ls_key-%param-ModuleId
            %param-TargetCds = ls_key-%param-TargetCds
            %param-TargetApp = lv_target_app
          ) TO result.

        ENDLOOP.

      ENDMETHOD.


      METHOD updateReason.
        DATA lv_now TYPE timestampl.
        GET TIME STAMP FIELD lv_now.

        LOOP AT keys INTO DATA(ls_key).
          MODIFY ENTITIES OF zir_conf_req_h IN LOCAL MODE
            ENTITY Req UPDATE FIELDS ( Reason ReqTitle ChangedBy ChangedAt )
            WITH VALUE #( (
              %tky      = ls_key-%tky
              Reason    = ls_key-%param-reason
              ReqTitle  = ls_key-%param-req_title
              ChangedBy = sy-uname
              ChangedAt = lv_now
            ) ).
        ENDLOOP.

        READ ENTITIES OF zir_conf_req_h IN LOCAL MODE
          ENTITY Req ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(reqs).

        result = VALUE #( FOR r IN reqs ( %tky = r-%tky ) ).
      ENDMETHOD.

    ENDCLASS.

    CLASS lhc_Item DEFINITION INHERITING FROM cl_abap_behavior_handler.
      PRIVATE SECTION.
        METHODS get_instance_features FOR INSTANCE FEATURES
          IMPORTING keys REQUEST requested_features FOR Item RESULT result.
        METHODS validate_item FOR VALIDATE ON SAVE IMPORTING keys FOR Item~validate_item.
    ENDCLASS.

    CLASS lhc_Item IMPLEMENTATION.
      METHOD get_instance_features.
        " Read parent header status via _Header association
        READ ENTITIES OF zir_conf_req_h IN LOCAL MODE
          ENTITY Item BY \_Header
            FIELDS ( Status )
            WITH CORRESPONDING #( keys )
          RESULT DATA(lt_headers).

        LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
          " Find the matching parent header
          READ TABLE lt_headers ASSIGNING FIELD-SYMBOL(<hdr>)
            WITH KEY %tky-%key = <key>-%key BINARY SEARCH.
          IF sy-subrc <> 0.
            READ TABLE lt_headers INDEX 1 ASSIGNING <hdr>.
          ENDIF.

          DATA(lv_status) = COND zde_requ_status( WHEN <hdr> IS ASSIGNED THEN condense( <hdr>-Status ) ELSE '' ).

          " Items can only be edited or deleted when the parent request is DRAFT or ROLLED_BACK
          DATA(lv_upd_del) = COND #(
            WHEN lv_status = 'DRAFT' OR lv_status = 'ROLLED_BACK'
              THEN if_abap_behv=>fc-o-enabled
              ELSE if_abap_behv=>fc-o-disabled ).

          APPEND VALUE #(
            %tky    = <key>-%tky
            %update = lv_upd_del
            %delete = lv_upd_del
          ) TO result.
        ENDLOOP.
      ENDMETHOD.

      METHOD validate_item.
        READ ENTITIES OF zir_conf_req_h IN LOCAL MODE
          ENTITY Item ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(lt_items).

        LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<i>).

          IF <i>-ConfId IS INITIAL.
            APPEND VALUE #(
              %tky = <i>-%tky
              %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text     = 'ConfId is mandatory' )
            ) TO reported-item.
            APPEND VALUE #( %tky = <i>-%tky ) TO failed-item.
          ENDIF.

          IF <i>-Action IS INITIAL.
            APPEND VALUE #(
              %tky = <i>-%tky
              %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text     = 'Action is mandatory' )
            ) TO reported-item.
            APPEND VALUE #( %tky = <i>-%tky ) TO failed-item.
          ENDIF.

          IF <i>-TargetEnvId IS INITIAL.
            APPEND VALUE #(
              %tky = <i>-%tky
              %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text     = 'TargetEnvId is mandatory' )
            ) TO reported-item.
            APPEND VALUE #( %tky = <i>-%tky ) TO failed-item.
          ENDIF.

        ENDLOOP.
      ENDMETHOD.

    ENDCLASS.
