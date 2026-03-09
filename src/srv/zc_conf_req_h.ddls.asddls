@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Change Request Header Projection'
@Metadata.allowExtensions: true

@UI.headerInfo: {
  typeName: 'Change Request',
  typeNamePlural: 'Change Requests',
  title: { type: #STANDARD, value: 'ReqTitle' },
  description: { type: #STANDARD, value: 'Status' }
}

define root view entity ZC_CONF_REQ_H
  provider contract transactional_query
  as projection on ZIR_CONF_REQ_H
{
      @UI.facet: [
        { id: 'GeneralInfo',
          purpose: #STANDARD,
          type: #IDENTIFICATION_REFERENCE,
          label: 'Request Information',
          position: 10 },
        { id: 'Items',
          purpose: #STANDARD,
          type: #LINEITEM_REFERENCE,
          label: 'Request Items',
          position: 20,
          targetElement: '_Items' },
        { id: 'AuditInfo',
          purpose: #STANDARD,
          type: #FIELDGROUP_REFERENCE,
          label: 'Audit Trail',
          position: 30,
          targetQualifier: 'AuditLog' }
      ]

            @UI: { lineItem:       [{ position: 10, importance: #HIGH }],
             identification: [{ position: 10 },
                              { type: #FOR_ACTION, dataAction: 'submit',  label: 'Submit',  position: 20 },
                              { type: #FOR_ACTION, dataAction: 'approve', label: 'Approve', position: 30 },
                              { type: #FOR_ACTION, dataAction: 'reject',  label: 'Reject',  position: 40 }] }
  key ReqId,


      @UI: { lineItem:       [{ position: 20 }],
             identification: [{ position: 20 }],
             selectionField: [{ position: 10 }] }
      EnvId,

      @UI: { lineItem:       [{ position: 30, importance: #HIGH }],
             identification: [{ position: 30 }],
             selectionField: [{ position: 20 }] }
      ModuleId,

      @UI: { lineItem:       [{ position: 40, importance: #HIGH }],
             identification: [{ position: 40 }] }
      ReqTitle,

      @UI: { identification: [{ position: 50 }] }
      Description,

      @UI: { lineItem:       [{ position: 50, importance: #HIGH,
                                criticality: 'StatusCriticality' }],
             identification: [{ position: 60 }],
             selectionField: [{ position: 30 }] }
      Status,

      @UI.hidden: true
      StatusCriticality,

      @UI: { identification: [{ position: 70 }] }
      Reason,

      /* ----- Audit Log Tab ----- */
      @UI: { fieldGroup: [{ qualifier: 'AuditLog', position: 10, label: 'Created By' }],
             lineItem:   [{ position: 60 }] }
      CreatedBy,

      @UI: { fieldGroup: [{ qualifier: 'AuditLog', position: 20, label: 'Created At' }],
             lineItem:   [{ position: 70 }] }
      CreatedAt,

      @UI: { fieldGroup: [{ qualifier: 'AuditLog', position: 30, label: 'Changed By' }] }
      ChangedBy,

      @UI: { fieldGroup: [{ qualifier: 'AuditLog', position: 40, label: 'Changed At' }] }
      ChangedAt,

      @UI: { fieldGroup: [{ qualifier: 'AuditLog', position: 50, label: 'Approved By' }] }
      ApprovedBy,

      @UI: { fieldGroup: [{ qualifier: 'AuditLog', position: 60, label: 'Approved At' }] }
      ApprovedAt,

      @UI: { fieldGroup: [{ qualifier: 'AuditLog', position: 70, label: 'Rejected By' }] }
      RejectedBy,

      @UI: { fieldGroup: [{ qualifier: 'AuditLog', position: 80, label: 'Rejected At' }] }
      RejectedAt,

      /* Associations */
      _Items : redirected to composition child ZC_CONF_REQ_I,
      _Env
}
