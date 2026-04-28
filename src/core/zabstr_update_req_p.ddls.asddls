@EndUserText.label: 'Update Request (Key User)'
define abstract entity ZABSTR_UPDATE_REQ_P
{
  @EndUserText.label: 'Request Title'
  req_title : abap.string( 256 );

  @EndUserText.label: 'Request Reason'
  reason    : abap.string( 256 );
}
