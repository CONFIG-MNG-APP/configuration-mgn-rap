*&---------------------------------------------------------------------*
*& Report zseed_cust_group
*&---------------------------------------------------------------------*
REPORT zseed_cust_group.

" 1. Xóa toàn bộ dữ liệu cũ của bảng (chỉ tác động trên Client hiện tại)
DELETE FROM zsd_cust_group.
COMMIT WORK.

" 2. Chuẩn bị dữ liệu mới sử dụng cú pháp VALUE #( ) siêu ngắn gọn
DATA lt_cust_group TYPE TABLE OF zsd_cust_group.

lt_cust_group = VALUE #(
  ( cust_group = 'DIST' description = 'Regional Distributor' )
  ( cust_group = 'DLER' description = 'Authorized Bike Dealer' )
  ( cust_group = 'CHAN' description = 'Retail Chain Store' )
  ( cust_group = 'INDV' description = 'Individual Consumer' )
  ( cust_group = 'FLET' description = 'Fleet & Rental System' )
  ( cust_group = 'TEAM' description = 'Pro Racing Team' )
  ( cust_group = 'REPR' description = 'Repair & Service Center' )
).

" 3. Chèn (Insert) dữ liệu mới vào Database
INSERT zsd_cust_group FROM TABLE @lt_cust_group.

IF sy-subrc = 0.
  COMMIT WORK.
  " Hiển thị thông báo thành công ra màn hình
  cl_demo_output=>display( 'Đã Reset & Insert thành công Data chuẩn cho ZSD_CUST_GROUP!' ).
ELSE.
  ROLLBACK WORK.
  cl_demo_output=>display( 'Lỗi: Không thể cập nhật dữ liệu.' ).
ENDIF.
