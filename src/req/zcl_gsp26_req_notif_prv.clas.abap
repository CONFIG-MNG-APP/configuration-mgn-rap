CLASS zcl_gsp26_req_notif_prv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /iwngw/if_notif_provider.

    " Notification type keys — referenced by the caller (zbp_ir_conf_req_h)
    " so they stay in sync without duplicating string literals.
    CONSTANTS:
      gc_type_approved  TYPE string VALUE 'REQ_APPROVED',
      gc_type_rejected  TYPE string VALUE 'REQ_REJECTED',
      gc_type_submitted TYPE string VALUE 'REQ_SUBMITTED'.

    " Notification type version — single source of truth
    CONSTANTS:
      gc_type_version TYPE string VALUE '1'.

    " Parameter name for the request title placeholder used in templates
    CONSTANTS:
      gc_param_req_title TYPE string VALUE 'ReqTitle'.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_gsp26_req_notif_prv IMPLEMENTATION.

  METHOD /iwngw/if_notif_provider~get_notification_parameters.
    " Register the {ReqTitle} parameter for all three notification types.
    " The parameter type comes from the standard interface constant — no magic strings.
    CASE iv_type_key.
      WHEN gc_type_approved OR gc_type_rejected OR gc_type_submitted.
        APPEND VALUE #(
          name         = gc_param_req_title
          type         = /iwngw/if_notif_provider=>gcs_parameter_types-type_string
          is_sensitive = abap_false
        ) TO et_parameter.
    ENDCASE.
  ENDMETHOD.


  METHOD /iwngw/if_notif_provider~get_notification_type.
    " Assign type metadata directly into the single export structure.
    " is_actionable is intentionally omitted for compatibility with the
    " current SAP Gateway version deployed on this system.
    CASE iv_type_key.
      WHEN gc_type_approved OR gc_type_rejected OR gc_type_submitted.
        es_notification_type-type_key = iv_type_key.
        es_notification_type-version  = gc_type_version.
    ENDCASE.
  ENDMETHOD.


  METHOD /iwngw/if_notif_provider~get_notification_type_text.
    " Notification display templates shown in the Fiori Launchpad bell icon.
    " {ReqTitle} is substituted at runtime by the notification framework.
    " Both public and sensitive templates are identical — no confidential data
    " is included in the notification text itself.
    CASE iv_type_key.
      WHEN gc_type_approved.
        es_type_text-template_public    = 'Approved: Configuration request "{ReqTitle}" has been approved.'.
        es_type_text-template_sensitive = 'Approved: Configuration request "{ReqTitle}" has been approved.'.

      WHEN gc_type_rejected.
        es_type_text-template_public    = 'Rejected: Configuration request "{ReqTitle}" was not approved.'.
        es_type_text-template_sensitive = 'Rejected: Configuration request "{ReqTitle}" was not approved.'.

      WHEN gc_type_submitted.
        es_type_text-template_public    = 'Pending Approval: A new configuration request "{ReqTitle}" requires your review.'.
        es_type_text-template_sensitive = 'Pending Approval: A new configuration request "{ReqTitle}" requires your review.'.
    ENDCASE.
  ENDMETHOD.


  METHOD /iwngw/if_notif_provider~handle_action.
    " No custom action handling required for this notification type.
  ENDMETHOD.


  METHOD /iwngw/if_notif_provider~handle_bulk_action.
    " No bulk action handling required for this notification type.
  ENDMETHOD.

ENDCLASS.

