*&---------------------------------------------------------------------*
*& Report zseed_plant_unit
*&---------------------------------------------------------------------*
REPORT zseed_plant_unit.

" 1. Xóa toàn bộ dữ liệu cũ của bảng
DELETE FROM zplantunit.
COMMIT WORK.

" 2. Chuẩn bị dữ liệu mới mang logic chuỗi cung ứng toàn cầu
DATA lt_plant_unit TYPE TABLE OF zplantunit.

lt_plant_unit = VALUE #(
  ( plant_id = 'HQ01' plant_type = 'CORP'    parent_org = '1000' description = 'Global Headquarters & R&D' )
  ( plant_id = 'US01' plant_type = 'FACTORY' parent_org = '1000' description = 'Dallas Frame Manufacturing Plant' )
  ( plant_id = 'US02' plant_type = 'DC'      parent_org = '1000' description = 'North America Distribution Hub' )
  ( plant_id = 'TW01' plant_type = 'FACTORY' parent_org = '2000' description = 'Taichung Parts Manufacturing' )
  ( plant_id = 'VN01' plant_type = 'FACTORY' parent_org = '2000' description = 'Binh Duong Assembly Plant' )
  ( plant_id = 'VN02' plant_type = 'DC'      parent_org = '2000' description = 'APAC Distribution Center' )
).

" 3. Thực thi Insert vào Database
INSERT zplantunit FROM TABLE @lt_plant_unit.

IF sy-subrc = 0.
  COMMIT WORK.
  cl_demo_output=>display( 'Đã Reset & Insert thành công Data nhà máy (ZPLANTUNIT)!' ).
ELSE.
  ROLLBACK WORK.
  cl_demo_output=>display( 'Lỗi: Không thể cập nhật dữ liệu nhà máy.' ).
ENDIF.
