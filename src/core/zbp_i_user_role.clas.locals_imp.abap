CLASS lhc_userrole DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    CONSTANTS:
      gc_role_key_user TYPE zde_role_level VALUE 'KEY USER',
      gc_role_manager  TYPE zde_role_level VALUE 'MANAGER',
      gc_role_it_admin TYPE zde_role_level VALUE 'IT ADMIN'.

    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING REQUEST requested_authorizations FOR UserRole
        RESULT result,
      setFullname    FOR DETERMINE ON MODIFY  IMPORTING keys FOR UserRole~setFullname,
      validateSoD    FOR VALIDATE  ON SAVE    IMPORTING keys FOR UserRole~validateSoD,
      validateUserId FOR VALIDATE  ON SAVE    IMPORTING keys FOR UserRole~validateUserId.
ENDCLASS.

CLASS lhc_userrole IMPLEMENTATION.

  METHOD get_global_authorizations.
    " Access control is handled at the app layer (IT ADMIN role in zuserrole).
    " Grant all CRUD operations unconditionally at the ABAP BO level.
    result-%create = if_abap_behv=>auth-allowed.
    result-%update = if_abap_behv=>auth-allowed.
    result-%delete = if_abap_behv=>auth-allowed.
  ENDMETHOD.

  METHOD setFullname.
    " Auto-populate Fullname from SAP user address store on create
    READ ENTITIES OF zi_user_role IN LOCAL MODE
      ENTITY UserRole
        FIELDS ( UserId Fullname )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_roles).

    DATA lt_update TYPE TABLE FOR UPDATE zi_user_role\\UserRole.

    LOOP AT lt_roles INTO DATA(ls_role) WHERE Fullname IS INITIAL.
      SELECT SINGLE name_first, name_last
        FROM adrp
        INNER JOIN usr21 ON usr21~persnumber = adrp~persnumber
        INTO @DATA(ls_name)
        WHERE usr21~bname = @ls_role-UserId.

      IF sy-subrc = 0.
        DATA(lv_fullname) = condense( ls_name-name_first && ` ` && ls_name-name_last ).
        IF lv_fullname IS NOT INITIAL.
          APPEND VALUE #(
            %tky     = ls_role-%tky
            Fullname = lv_fullname
          ) TO lt_update.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_user_role IN LOCAL MODE
        ENTITY UserRole
          UPDATE FIELDS ( Fullname )
          WITH lt_update
        REPORTED DATA(lt_reported).
    ENDIF.
  ENDMETHOD.

  METHOD validateSoD.
    " A user cannot hold KEY USER and MANAGER roles for the same module.
    " IT ADMIN can coexist with domain roles (different module context).
    READ ENTITIES OF zi_user_role IN LOCAL MODE
      ENTITY UserRole
        FIELDS ( UserId ModuleId RoleLevel )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_roles).

    LOOP AT lt_roles INTO DATA(ls_new).
      " Only KEY USER and MANAGER conflict with each other in the same module
      CHECK ls_new-RoleLevel = gc_role_key_user OR ls_new-RoleLevel = gc_role_manager.

      DATA(lv_conflict_role) = COND zde_role_level(
        WHEN ls_new-RoleLevel = gc_role_key_user THEN gc_role_manager
        ELSE                                          gc_role_key_user
      ).

      " Check if conflicting role already exists for same user + module
      SELECT SINGLE @abap_true
        FROM zuserrole
        INTO @DATA(lv_found)
        WHERE user_id    = @ls_new-UserId
          AND module_id  = @ls_new-ModuleId
          AND role_level = @lv_conflict_role.

      IF lv_found = abap_true.
        APPEND VALUE #( %tky = ls_new-%tky ) TO failed-userrole.
        APPEND VALUE #(
          %tky = ls_new-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |User { ls_new-UserId } already has role { lv_conflict_role } for module { ls_new-ModuleId }. SoD violation.|
          )
        ) TO reported-userrole.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateUserId.
    " Warn if USER_ID does not exist in the ABAP system user store
    READ ENTITIES OF zi_user_role IN LOCAL MODE
      ENTITY UserRole
        FIELDS ( UserId )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_roles).

    LOOP AT lt_roles INTO DATA(ls_role).
      SELECT SINGLE bname FROM usr02
        INTO @DATA(lv_user)
        WHERE bname = @ls_role-UserId.

      IF sy-subrc <> 0.
        " Warning only — allow assigning roles to future users
        APPEND VALUE #(
          %tky = ls_role-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-warning
            text     = |User { ls_role-UserId } does not exist in the system. Role will be saved.|
          )
        ) TO reported-userrole.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
