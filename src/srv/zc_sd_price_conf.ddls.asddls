@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'SD Price Configuration Projection'
@Metadata.allowExtensions: true

@UI.headerInfo: {
  typeName: 'Price Rule',
  typeNamePlural: 'Price Rules',
  title: { type: #STANDARD, value: 'CustGroup' },
  description: { type: #STANDARD, value: 'MaterialGrp' }
}

define root view entity ZC_SD_PRICE_CONF
  as projection on ZI_SD_PRICE_CONF
{
      @UI.facet: [
        { id: 'GeneralInfo',
          purpose: #STANDARD,
          type: #IDENTIFICATION_REFERENCE,
          label: 'Price Configuration',
          position: 10 }
      ]

      @UI: { lineItem:       [{ position: 10, importance: #HIGH }],
             identification: [{ position: 10 }] }
  key ItemId,

      @UI: { identification: [{ position: 20 }] }
      ReqId,

      @UI: { lineItem:       [{ position: 20 }],
             identification: [{ position: 30 }] }
      BranchId,

      @UI: { lineItem:       [{ position: 30 }],
             identification: [{ position: 40 }],
             selectionField: [{ position: 10 }] }
             @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_ENV_DEF', element: 'EnvId' } }]
      EnvId,

      @UI: { lineItem:       [{ position: 40, importance: #HIGH }],
             identification: [{ position: 50 }],
             selectionField: [{ position: 20 }] }
      CustGroup,

      @UI: { lineItem:       [{ position: 50, importance: #HIGH }],
             identification: [{ position: 60 }] }
      MaterialGrp,

      @UI: { lineItem:       [{ position: 60, importance: #HIGH }],
             identification: [{ position: 70 }] }
      MaxDiscount,

      @UI: { identification: [{ position: 80 }] }
      MinOrderVal,

      @UI: { identification: [{ position: 90 }] }
      ApproverGrp,

      @UI: { lineItem:       [{ position: 70 }],
             identification: [{ position: 100 }] }
      Currency,

      @UI: { identification: [{ position: 110 }] }
      ValidFrom,

      @UI: { identification: [{ position: 120 }] }
      ValidTo,

      @UI: { identification: [{ position: 130 }] }
      VersionNo,

      CreatedBy,
      CreatedAt,
      ChangedBy,
      ChangedAt
}
