@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'FI Limit Configuration Projection'
@Metadata.allowExtensions: true

@UI.headerInfo: {
  typeName: 'Expense Limit',
  typeNamePlural: 'Expense Limits',
  title: { type: #STANDARD, value: 'ExpenseType' },
  description: { type: #STANDARD, value: 'GlAccount' }
}

define root view entity ZC_FI_LIMIT_CONF
provider contract transactional_query
  as projection on ZI_FI_LIMIT_CONF
{
      @UI.facet: [
        { id: 'GeneralInfo',
          purpose: #STANDARD,
          type: #IDENTIFICATION_REFERENCE,
          label: 'Limit Details',
          position: 10 }
      ]

      @UI: { lineItem:       [{ position: 10, importance: #HIGH }],
             identification: [{ position: 10 }] }
  key ItemId,

      @UI: { identification: [{ position: 20 }] }
      ReqId,

      @UI: { lineItem:       [{ position: 20 }],
             identification: [{ position: 30 }],
             selectionField: [{ position: 10 }] }
      EnvId,

      @UI: { lineItem:       [{ position: 30, importance: #HIGH }],
             identification: [{ position: 40 }],
             selectionField: [{ position: 20 }] }
      ExpenseType,

      @UI: { lineItem:       [{ position: 40, importance: #HIGH }],
             identification: [{ position: 50 }] }
      GlAccount,

      @UI: { lineItem:       [{ position: 50, importance: #HIGH }],
             identification: [{ position: 60 }] }
      AutoApprLim,

      @UI: { lineItem:       [{ position: 60 }],
             identification: [{ position: 70 }] }
      Currency,

      @UI: { identification: [{ position: 80 }] }
      VersionNo,

      CreatedBy,
      CreatedAt,
      ChangedBy,
      ChangedAt
}
