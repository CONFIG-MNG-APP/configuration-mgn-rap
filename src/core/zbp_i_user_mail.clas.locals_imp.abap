CLASS lhc_usermail DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING REQUEST requested_authorizations FOR UserMail
        RESULT    result,
      validateEmail FOR VALIDATE ON SAVE IMPORTING keys FOR UserMail~validateEmail.
ENDCLASS.

CLASS lhc_usermail IMPLEMENTATION.

  METHOD get_global_authorizations.
    result-%create = if_abap_behv=>auth-allowed.
    result-%update = if_abap_behv=>auth-allowed.
    result-%delete = if_abap_behv=>auth-allowed.
  ENDMETHOD.

  METHOD validateEmail.
    READ ENTITIES OF zi_user_mail IN LOCAL MODE
      ENTITY UserMail
        FIELDS ( UserId Email )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_mails).

    LOOP AT lt_mails INTO DATA(ls_mail).
      " Basic email format check: must contain '@' and '.'
      IF ls_mail-Email NS '@' OR ls_mail-Email NS '.'.
        APPEND VALUE #( %tky = ls_mail-%tky ) TO failed-usermail.
        APPEND VALUE #(
          %tky = ls_mail-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Invalid email address: { ls_mail-Email }|
          )
        ) TO reported-usermail.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
