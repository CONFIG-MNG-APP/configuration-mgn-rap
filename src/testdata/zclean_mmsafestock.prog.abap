REPORT zclean_mmsafestock.

DATA: lv_total TYPE i VALUE 0.

* Xóa dữ liệu bảng Request
DELETE FROM zmmsafestock_req.
lv_total = lv_total + sy-dbcnt.
WRITE: / |ZMMSAFESTOCK_REQ:   { sy-dbcnt } rows deleted.|.

* Xóa dữ liệu bảng Draft
DELETE FROM zmmsafestock_d.
lv_total = lv_total + sy-dbcnt.
WRITE: / |ZMMSAFESTOCK_D:     { sy-dbcnt } rows deleted.|.

* Xóa dữ liệu bảng Master Data
DELETE FROM zmmsafestock.
lv_total = lv_total + sy-dbcnt.
WRITE: / |ZMMSAFESTOCK:       { sy-dbcnt } rows deleted.|.

* Lưu thay đổi xuống Database
COMMIT WORK.

WRITE: / '--------------------------------------------'.
WRITE: / |Total: { lv_total } rows deleted for Safe Stock tables.|.
