@EndUserText.label: 'Lý do từ chối'
define abstract entity ZABSTR_REJECT_REASON
{
  @EndUserText.label: 'Lý do (Reason)'
  reason : abap.string( 256 ); 
  @EndUserText.label: 'Request Title'
  req_title : abap.string( 256 );
}
