CLASS lhc_priceconf DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS set_defaults FOR DETERMINE ON MODIFY
      IMPORTING keys FOR PriceConf~set_defaults.

    METHODS setAdminFields FOR DETERMINE ON MODIFY
      IMPORTING keys FOR PriceConf~setAdminFields.

    METHODS validate_mandatory FOR VALIDATE ON SAVE
      IMPORTING keys FOR PriceConf~validate_mandatory.

    METHODS validate_dates FOR VALIDATE ON SAVE
      IMPORTING keys FOR PriceConf~validate_dates.

    METHODS validate_business FOR VALIDATE ON SAVE
      IMPORTING keys FOR PriceConf~validate_business.

    METHODS approve FOR MODIFY
      IMPORTING keys FOR ACTION PriceConf~approve RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features
      FOR PriceConf RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations
      FOR PriceConf RESULT result.

ENDCLASS.


CLASS lhc_priceconf IMPLEMENTATION.

  METHOD set_defaults.

    READ ENTITIES OF zi_sd_price_conf IN LOCAL MODE
      ENTITY PriceConf
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_data).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<r>).

      DATA(lv_version_no) = COND i(
                              WHEN <r>-VersionNo IS INITIAL THEN 1
                              ELSE <r>-VersionNo ).

      DATA(lv_action_type) = COND zde_action_type(
                               WHEN <r>-ActionType IS INITIAL THEN 'C'
                               ELSE <r>-ActionType ).

      " ── Lookup ConfId từ request header nếu chưa có ──────────────────
      " RAP draft activation không copy field readonly:update → ConfId luôn zero
      " Fix: server tự lấy conf_id từ ZCONFREQH theo ReqId
      IF <r>-ConfId IS INITIAL AND <r>-ReqId IS NOT INITIAL.
        SELECT SINGLE conf_id
          FROM zconfreqh
          WHERE req_id = @<r>-ReqId
          INTO @DATA(lv_conf_id).

        IF sy-subrc = 0 AND lv_conf_id IS NOT INITIAL.
          MODIFY ENTITIES OF zi_sd_price_conf IN LOCAL MODE
            ENTITY PriceConf
            UPDATE FIELDS ( ConfId )
            WITH VALUE #( (
              %tky   = <r>-%tky
              ConfId = lv_conf_id
            ) ).
        ENDIF.
      ENDIF.

      " NOTE: ActionType bị xóa khỏi UPDATE FIELDS để tránh vòng lặp vô hạn.
      " Trigger của determination là { field SourceItemId, ActionType } — nếu
      " MODIFY này ghi lại ActionType thì sẽ tự trigger lại chính nó → RAISE_SHORTDUMP.
      " Frontend luôn gửi ActionType đúng ('C'/'U'/'X') nên không cần default ở đây.
      MODIFY ENTITIES OF zi_sd_price_conf IN LOCAL MODE
        ENTITY PriceConf
        UPDATE FIELDS ( VersionNo )
        WITH VALUE #(
          (
            %tky      = <r>-%tky
            VersionNo = lv_version_no
          )
        ).

      " ── For U/X rows: populate OldXxx only if frontend didn't send them ──
      " NOTE: Do NOT overwrite new values — frontend sends the user's intended
      "       changes. Only fill OldXxx as a fallback snapshot from main table.
      IF lv_action_type = 'U' OR lv_action_type = 'X'.

        IF <r>-SourceItemId IS INITIAL.
          CONTINUE.
        ENDIF.

        " Skip if frontend already sent all Old snapshot fields
        IF <r>-OldEnvId IS NOT INITIAL OR <r>-OldBranchId IS NOT INITIAL.
          CONTINUE.
        ENDIF.

        SELECT SINGLE *
          FROM zsd_price_conf
          WHERE item_id = @<r>-SourceItemId
          INTO @DATA(ls_src).

        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        " Populate only OldXxx — never touch the new value fields
        MODIFY ENTITIES OF zi_sd_price_conf IN LOCAL MODE
          ENTITY PriceConf
          UPDATE FIELDS (
            OldBranchId
            OldEnvId
            OldCustGroup
            OldMaterialGrp
            OldMaxDiscount
            OldMinOrderVal
            OldApproverGrp
            OldCurrency
            OldValidFrom
            OldValidTo
            OldVersionNo
          )
          WITH VALUE #(
            (
              %tky           = <r>-%tky
              OldBranchId    = ls_src-branch_id
              OldEnvId       = ls_src-env_id
              OldCustGroup   = ls_src-cust_group
              OldMaterialGrp = ls_src-material_grp
              OldMaxDiscount = ls_src-max_discount
              OldMinOrderVal = ls_src-min_order_val
              OldApproverGrp = ls_src-approver_grp
              OldCurrency    = ls_src-currency
              OldValidFrom   = ls_src-valid_from
              OldValidTo     = ls_src-valid_to
              OldVersionNo   = ls_src-version_no
            )
          ).

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD setAdminFields.
    DATA lv_now TYPE timestampl.
    GET TIME STAMP FIELD lv_now.

    READ ENTITIES OF zi_sd_price_conf IN LOCAL MODE
      ENTITY PriceConf
        FIELDS ( CreatedBy CreatedAt ChangedBy ChangedAt )
        WITH CORRESPONDING #( keys )
      RESULT DATA(entities).

    DATA lt_update TYPE TABLE FOR UPDATE zi_sd_price_conf\\PriceConf.

    LOOP AT entities INTO DATA(entity).
      DATA(lv_new_created_by) = COND syuname(
        WHEN entity-CreatedBy IS INITIAL THEN sy-uname
        ELSE entity-CreatedBy ).
      DATA(lv_new_created_at) = COND timestampl(
        WHEN entity-CreatedAt IS INITIAL THEN lv_now
        ELSE entity-CreatedAt ).

      IF entity-ChangedBy   = sy-uname
      AND entity-CreatedBy  = lv_new_created_by
      AND entity-CreatedAt  = lv_new_created_at.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %tky      = entity-%tky
        CreatedBy = lv_new_created_by
        CreatedAt = lv_new_created_at
        ChangedBy = sy-uname
        ChangedAt = lv_now
      ) TO lt_update.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_sd_price_conf IN LOCAL MODE
        ENTITY PriceConf
          UPDATE FIELDS ( CreatedBy CreatedAt ChangedBy ChangedAt )
          WITH lt_update
        REPORTED DATA(update_reported).
      reported = CORRESPONDING #( DEEP update_reported ).
    ENDIF.
  ENDMETHOD.


  METHOD validate_mandatory.
    READ ENTITIES OF zi_sd_price_conf IN LOCAL MODE
      ENTITY PriceConf
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_entities).

    LOOP AT lt_entities INTO DATA(entity).

      " ── Required fields (CREATE) ─────────────────────────────────────────
      IF entity-ActionType = 'C'.
        IF entity-ReqId IS INITIAL OR
           entity-EnvId IS INITIAL OR
           entity-BranchId IS INITIAL OR
           entity-CustGroup IS INITIAL.

          APPEND VALUE #( %tky = entity-%tky ) TO failed-priceconf.
          APPEND VALUE #(
            %tky = entity-%tky
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-error
                     text     = 'Mandatory fields missing for CREATE (ReqId/EnvId/BranchId/CustGroup).' )
          ) TO reported-priceconf.
        ENDIF.
      ENDIF.

      " ── Required fields (UPDATE) ─────────────────────────────────────────
      IF entity-ActionType = 'U'.
        IF entity-EnvId IS INITIAL OR
           entity-BranchId IS INITIAL OR
           entity-CustGroup IS INITIAL.

          APPEND VALUE #( %tky = entity-%tky ) TO failed-priceconf.
          APPEND VALUE #(
            %tky = entity-%tky
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-error
                     text     = 'Mandatory fields missing for UPDATE (EnvId/BranchId/CustGroup).' )
          ) TO reported-priceconf.
        ENDIF.
      ENDIF.

      " ── SourceItemId checks (UPDATE / DELETE) ────────────────────────────
      IF ( entity-ActionType = 'U' OR entity-ActionType = 'X' )
         AND entity-SourceItemId IS INITIAL.

        APPEND VALUE #( %tky = entity-%tky ) TO failed-priceconf.
        APPEND VALUE #(
          %tky = entity-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'SourceItemId is mandatory for UPDATE/DELETE.' )
        ) TO reported-priceconf.
      ENDIF.

      IF ( entity-ActionType = 'U' OR entity-ActionType = 'X' )
         AND entity-SourceItemId IS NOT INITIAL.

        SELECT SINGLE item_id
          FROM zsd_price_conf
          WHERE item_id = @entity-SourceItemId
          INTO @DATA(lv_item_id).

        IF sy-subrc <> 0.
          APPEND VALUE #( %tky = entity-%tky ) TO failed-priceconf.
          APPEND VALUE #(
            %tky = entity-%tky
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-error
                     text     = 'Source price line not found in active configuration.' )
          ) TO reported-priceconf.
        ENDIF.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.


  METHOD validate_dates.
    READ ENTITIES OF zi_sd_price_conf IN LOCAL MODE
      ENTITY PriceConf
        FIELDS ( ValidFrom ValidTo )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_entities).

    LOOP AT lt_entities INTO DATA(entity).
      IF entity-ValidFrom IS NOT INITIAL AND entity-ValidTo IS NOT INITIAL.
        IF entity-ValidTo < entity-ValidFrom.
          APPEND VALUE #( %tky = entity-%tky ) TO failed-priceconf.
          APPEND VALUE #( %tky = entity-%tky
                          %msg = new_message_with_text(
                            severity = if_abap_behv_message=>severity-error
                            text     = 'Valid To must be after Valid From' )
                          %element-ValidTo = if_abap_behv=>mk-on
          ) TO reported-priceconf.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD validate_business.
    READ ENTITIES OF zi_sd_price_conf IN LOCAL MODE
      ENTITY PriceConf
        FIELDS ( MaxDiscount MinOrderVal )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_entities).

    LOOP AT lt_entities INTO DATA(entity).
      IF entity-MaxDiscount IS NOT INITIAL AND entity-MaxDiscount < 0.
        APPEND VALUE #( %tky = entity-%tky ) TO failed-priceconf.
        APPEND VALUE #(
          %tky = entity-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Max Discount cannot be negative' )
          %element-MaxDiscount = if_abap_behv=>mk-on
        ) TO reported-priceconf.
      ENDIF.

      IF entity-MinOrderVal IS NOT INITIAL AND entity-MinOrderVal < 0.
        APPEND VALUE #( %tky = entity-%tky ) TO failed-priceconf.
        APPEND VALUE #(
          %tky = entity-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Min Order Value cannot be negative' )
          %element-MinOrderVal = if_abap_behv=>mk-on
        ) TO reported-priceconf.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD approve.
    DATA lv_now TYPE timestampl.
    GET TIME STAMP FIELD lv_now.

    " 1. Đọc tất cả request records cần approve
    READ ENTITIES OF zi_sd_price_conf IN LOCAL MODE
      ENTITY PriceConf
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_reqs).

    LOOP AT lt_reqs ASSIGNING FIELD-SYMBOL(<req>).

      " 2. Chặn approve lại record đã approved
      IF <req>-LineStatus = 'APPROVED'.
        APPEND VALUE #( %tky = <req>-%tky ) TO failed-priceconf.
        APPEND VALUE #(
          %tky = <req>-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'This record is already approved.' )
        ) TO reported-priceconf.
        CONTINUE.
      ENDIF.

      " 3. Kiểm tra mandatory fields
      IF <req>-EnvId IS INITIAL OR <req>-BranchId IS INITIAL OR
         <req>-CustGroup IS INITIAL.
        APPEND VALUE #( %tky = <req>-%tky ) TO failed-priceconf.
        APPEND VALUE #(
          %tky = <req>-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Cannot approve: EnvId/BranchId/CustGroup missing.' )
        ) TO reported-priceconf.
        CONTINUE.
      ENDIF.

      " 4. Kiểm tra ngày hợp lệ
      IF <req>-ValidFrom IS NOT INITIAL AND <req>-ValidTo IS NOT INITIAL
         AND <req>-ValidTo < <req>-ValidFrom.
        APPEND VALUE #( %tky = <req>-%tky ) TO failed-priceconf.
        APPEND VALUE #(
          %tky = <req>-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Cannot approve: Valid To < Valid From.' )
        ) TO reported-priceconf.
        CONTINUE.
      ENDIF.

      " 5. Tính version mới
      DATA(lv_new_version) = COND i(
        WHEN <req>-OldVersionNo IS NOT INITIAL THEN <req>-OldVersionNo + 1
        ELSE 1 ).

      " 6. Chuẩn bị data ghi vào bảng chính
      " Dùng SourceItemId làm item_id cho bảng chính (UPDATE/DELETE)
      " Nếu CREATE thì dùng ItemId (auto-generated)
      DATA(ls_conf) = VALUE zsd_price_conf(
        client        = sy-mandt
        item_id       = COND #(
                          WHEN <req>-SourceItemId IS NOT INITIAL
                          THEN <req>-SourceItemId
                          ELSE <req>-ItemId )
        req_id        = <req>-ReqId
        branch_id     = <req>-BranchId
        env_id        = <req>-EnvId
        cust_group    = <req>-CustGroup
        material_grp  = <req>-MaterialGrp
        max_discount  = <req>-MaxDiscount
        min_order_val = <req>-MinOrderVal
        approver_grp  = <req>-ApproverGrp
        currency      = <req>-Currency
        valid_from    = <req>-ValidFrom
        valid_to      = <req>-ValidTo
        version_no    = lv_new_version
        created_by    = COND #(
                          WHEN <req>-ActionType = 'C'
                          THEN sy-uname
                          ELSE <req>-CreatedBy )
        created_at    = COND #(
                          WHEN <req>-ActionType = 'C'
                          THEN lv_now
                          ELSE <req>-CreatedAt )
        changed_by    = sy-uname
        changed_at    = lv_now
      ).

      " 7. Lấy data cũ để audit log
      DATA ls_old_price TYPE zsd_price_conf.
      CLEAR ls_old_price.
      IF <req>-ActionType = 'U' OR <req>-ActionType = 'X'.
        SELECT SINGLE *
          FROM zsd_price_conf
          WHERE item_id = @ls_conf-item_id
          INTO @ls_old_price.
      ENDIF.

      TRY.
          zcl_gsp26_rule_writer=>log_audit_entry(
            iv_conf_id  = ls_conf-item_id
            iv_req_id   = <req>-ReqId
            iv_mod_id   = 'SD'
            iv_act_type = 'APPROVE'
            iv_tab_name = 'ZSD_PRICE_CONF'
            iv_env_id   = <req>-EnvId
            is_old_data = ls_old_price
            is_new_data = ls_conf ).
        CATCH cx_root.
          " Nếu lỗi ghi log thì bỏ qua, vẫn chạy tiếp
      ENDTRY.

      " 8. Xử lý theo ActionType
      TRY.
          CASE <req>-ActionType.

            WHEN 'X'.
              DELETE FROM zsd_price_conf
                WHERE item_id = @ls_conf-item_id.

              IF sy-subrc <> 0.
                APPEND VALUE #(
                  %tky = <req>-%tky
                  %msg = new_message_with_text(
                           severity = if_abap_behv_message=>severity-warning
                           text     = 'Record not found in config table.' )
                ) TO reported-priceconf.
              ENDIF.

            WHEN OTHERS. " C = CREATE, U = UPDATE
              SELECT SINGLE @abap_true
                FROM zsd_price_conf
                WHERE item_id = @ls_conf-item_id
                INTO @DATA(lv_exists).

              IF lv_exists = abap_true.
                UPDATE zsd_price_conf SET
                  req_id        = @ls_conf-req_id,
                  branch_id     = @ls_conf-branch_id,
                  env_id        = @ls_conf-env_id,
                  cust_group    = @ls_conf-cust_group,
                  material_grp  = @ls_conf-material_grp,
                  max_discount  = @ls_conf-max_discount,
                  min_order_val = @ls_conf-min_order_val,
                  approver_grp  = @ls_conf-approver_grp,
                  currency      = @ls_conf-currency,
                  valid_from    = @ls_conf-valid_from,
                  valid_to      = @ls_conf-valid_to,
                  version_no    = @ls_conf-version_no,
                  changed_by    = @ls_conf-changed_by,
                  changed_at    = @ls_conf-changed_at
                  WHERE item_id = @ls_conf-item_id.
              ELSE.
                INSERT zsd_price_conf FROM @ls_conf.
              ENDIF.

          ENDCASE.

        CATCH cx_root INTO DATA(lx_err).
          APPEND VALUE #( %tky = <req>-%tky ) TO failed-priceconf.
          APPEND VALUE #(
            %tky = <req>-%tky
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-error
                     text     = |DB error: { lx_err->get_text( ) }| )
          ) TO reported-priceconf.
          CONTINUE.
      ENDTRY.

      " 9. Cập nhật request: LineStatus = APPROVED
      MODIFY ENTITIES OF zi_sd_price_conf IN LOCAL MODE
        ENTITY PriceConf
        UPDATE FIELDS ( LineStatus VersionNo ChangedBy ChangedAt )
        WITH VALUE #( (
          %tky       = <req>-%tky
          LineStatus = 'APPROVED'
          VersionNo  = lv_new_version
          ChangedBy  = sy-uname
          ChangedAt  = lv_now
        ) ).

      " 10. Trả kết quả thành công
      APPEND VALUE #(
        %tky   = <req>-%tky
        %param = <req>
      ) TO result.

    ENDLOOP.
  ENDMETHOD.


  METHOD get_instance_features.
    READ ENTITIES OF zi_sd_price_conf IN LOCAL MODE
      ENTITY PriceConf
        FIELDS ( LineStatus )
        WITH CORRESPONDING #( keys )
      RESULT DATA(entities).

    result = VALUE #( FOR entity IN entities
      LET lv_approve = COND #(
        WHEN entity-LineStatus = 'APPROVED'
        THEN if_abap_behv=>fc-o-disabled
        ELSE if_abap_behv=>fc-o-enabled )
      IN (
        %tky            = entity-%tky
        %action-approve = lv_approve
      ) ).
  ENDMETHOD.


  METHOD get_instance_authorizations.
    result = VALUE #( FOR key IN keys
      ( %tky    = key-%tky
        %update = if_abap_behv=>auth-allowed
        %delete = if_abap_behv=>auth-allowed
      ) ).
  ENDMETHOD.

ENDCLASS.
