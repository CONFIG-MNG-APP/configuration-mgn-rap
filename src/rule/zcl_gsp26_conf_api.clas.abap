CLASS zcl_gsp26_conf_api DEFINITION
  PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    " ── Return Types ─────────────────────────────────────────────────
    TYPES:
      BEGIN OF ty_fi_limit,
        item_id       TYPE sysuuid_x16,
        env_id        TYPE zde_env_id,
        expense_type  TYPE char30,
        gl_account    TYPE char10,
        auto_appr_lim TYPE p LENGTH 8 DECIMALS 2,
        currency      TYPE waers,
      END OF ty_fi_limit,
      tt_fi_limit TYPE STANDARD TABLE OF ty_fi_limit WITH EMPTY KEY,

      BEGIN OF ty_mm_route,
        item_id      TYPE sysuuid_x16,
        env_id       TYPE zde_env_id,
        plant_id     TYPE char10,
        send_wh      TYPE char10,
        receive_wh   TYPE char10,
        inspector_id TYPE syuname,
        trans_mode   TYPE char20,
        is_allowed   TYPE abap_boolean,
      END OF ty_mm_route,
      tt_mm_route TYPE STANDARD TABLE OF ty_mm_route WITH EMPTY KEY,

      BEGIN OF ty_safe_stock,
        item_id   TYPE sysuuid_x16,
        env_id    TYPE zde_env_id,
        plant_id  TYPE char10,
        mat_group TYPE char10,
        min_qty   TYPE int8,
      END OF ty_safe_stock,
      tt_safe_stock TYPE STANDARD TABLE OF ty_safe_stock WITH EMPTY KEY,

      BEGIN OF ty_sd_price,
        item_id      TYPE sysuuid_x16,
        env_id       TYPE zde_env_id,
        branch_id    TYPE char10,
        cust_group   TYPE char10,
        material_grp TYPE char10,
        max_discount TYPE p LENGTH 8 DECIMALS 2,
        min_order_val TYPE int4,
        approver_grp TYPE char20,
        currency     TYPE waers,
        valid_from   TYPE dats,
        valid_to     TYPE dats,
      END OF ty_sd_price,
      tt_sd_price TYPE STANDARD TABLE OF ty_sd_price WITH EMPTY KEY.

    " ── Public Methods ───────────────────────────────────────────────

    " Lấy tất cả FI Limit config của 1 môi trường
    CLASS-METHODS get_fi_limits
      IMPORTING iv_env_id       TYPE zde_env_id
      RETURNING VALUE(rt_result) TYPE tt_fi_limit.

    " Lấy 1 dòng FI Limit theo expense_type + gl_account
    CLASS-METHODS get_fi_limit_single
      IMPORTING iv_env_id        TYPE zde_env_id
                iv_expense_type  TYPE char30
                iv_gl_account    TYPE char10
      RETURNING VALUE(rs_result) TYPE ty_fi_limit.

    " Lấy tất cả MM Route config của 1 môi trường
    CLASS-METHODS get_mm_routes
      IMPORTING iv_env_id       TYPE zde_env_id
      RETURNING VALUE(rt_result) TYPE tt_mm_route.

    " Kiểm tra 1 tuyến có được phép không
    CLASS-METHODS is_route_allowed
      IMPORTING iv_env_id        TYPE zde_env_id
                iv_send_wh       TYPE char10
                iv_receive_wh    TYPE char10
      RETURNING VALUE(rv_result) TYPE abap_boolean.

    " Lấy tất cả Safe Stock config của 1 môi trường
    CLASS-METHODS get_safe_stocks
      IMPORTING iv_env_id       TYPE zde_env_id
      RETURNING VALUE(rt_result) TYPE tt_safe_stock.

    " Lấy min qty cho 1 plant + material group
    CLASS-METHODS get_min_qty
      IMPORTING iv_env_id        TYPE zde_env_id
                iv_plant_id      TYPE char10
                iv_mat_group     TYPE char10
      RETURNING VALUE(rv_result) TYPE int8.

    " Lấy tất cả SD Price config của 1 môi trường
    CLASS-METHODS get_sd_prices
      IMPORTING iv_env_id       TYPE zde_env_id
      RETURNING VALUE(rt_result) TYPE tt_sd_price.

    " Lấy price rule cho 1 branch + customer group + material group
    CLASS-METHODS get_sd_price_single
      IMPORTING iv_env_id        TYPE zde_env_id
                iv_branch_id     TYPE char10
                iv_cust_group    TYPE char10
                iv_material_grp  TYPE char10
      RETURNING VALUE(rs_result) TYPE ty_sd_price.

    " Xóa toàn bộ cache (gọi khi có config thay đổi)
    CLASS-METHODS clear_cache.

  PRIVATE SECTION.

    " ── Cache storage (static = tồn tại suốt session) ────────────────
    CLASS-DATA:
      gv_fi_cache_env   TYPE zde_env_id,
      gt_fi_cache       TYPE tt_fi_limit,

      gv_mm_cache_env   TYPE zde_env_id,
      gt_mm_cache       TYPE tt_mm_route,

      gv_ss_cache_env   TYPE zde_env_id,
      gt_ss_cache       TYPE tt_safe_stock,

      gv_sd_cache_env   TYPE zde_env_id,
      gt_sd_cache       TYPE tt_sd_price.

    " ── Private loader methods ────────────────────────────────────────
    CLASS-METHODS load_fi_cache
      IMPORTING iv_env_id TYPE zde_env_id.

    CLASS-METHODS load_mm_cache
      IMPORTING iv_env_id TYPE zde_env_id.

    CLASS-METHODS load_ss_cache
      IMPORTING iv_env_id TYPE zde_env_id.

    CLASS-METHODS load_sd_cache
      IMPORTING iv_env_id TYPE zde_env_id.

ENDCLASS.


CLASS zcl_gsp26_conf_api IMPLEMENTATION.




  METHOD load_fi_cache.
    " Chỉ query DB nếu cache trống hoặc env khác
    CHECK iv_env_id <> gv_fi_cache_env OR gt_fi_cache IS INITIAL.

    SELECT item_id, env_id, expense_type, gl_account, auto_appr_lim, currency
      FROM zfilimitconf
      WHERE env_id = @iv_env_id
      INTO CORRESPONDING FIELDS OF TABLE @gt_fi_cache.

    gv_fi_cache_env = iv_env_id.
  ENDMETHOD.

  METHOD get_fi_limits.
    load_fi_cache( iv_env_id ).
    rt_result = gt_fi_cache.
  ENDMETHOD.

  METHOD get_fi_limit_single.
    load_fi_cache( iv_env_id ).

    READ TABLE gt_fi_cache INTO rs_result
      WITH KEY expense_type = iv_expense_type
               gl_account   = iv_gl_account.
  ENDMETHOD.




  METHOD load_mm_cache.
    CHECK iv_env_id <> gv_mm_cache_env OR gt_mm_cache IS INITIAL.

    SELECT item_id, env_id, plant_id, send_wh, receive_wh,
           inspector_id, trans_mode, is_allowed
      FROM zmmrouteconf
      WHERE env_id = @iv_env_id
      INTO CORRESPONDING FIELDS OF TABLE @gt_mm_cache.

    gv_mm_cache_env = iv_env_id.
  ENDMETHOD.

  METHOD get_mm_routes.
    load_mm_cache( iv_env_id ).
    rt_result = gt_mm_cache.
  ENDMETHOD.

  METHOD is_route_allowed.
    load_mm_cache( iv_env_id ).

    DATA ls_route TYPE ty_mm_route.
    READ TABLE gt_mm_cache INTO ls_route
      WITH KEY send_wh    = iv_send_wh
               receive_wh = iv_receive_wh.

    rv_result = COND #( WHEN sy-subrc = 0 THEN ls_route-is_allowed
                        ELSE abap_false ).
  ENDMETHOD.





  METHOD load_ss_cache.
    CHECK iv_env_id <> gv_ss_cache_env OR gt_ss_cache IS INITIAL.

    SELECT item_id, env_id, plant_id, mat_group, min_qty
      FROM zmmsafestock
      WHERE env_id = @iv_env_id
      INTO CORRESPONDING FIELDS OF TABLE @gt_ss_cache.

    gv_ss_cache_env = iv_env_id.
  ENDMETHOD.

  METHOD get_safe_stocks.
    load_ss_cache( iv_env_id ).
    rt_result = gt_ss_cache.
  ENDMETHOD.

  METHOD get_min_qty.
    load_ss_cache( iv_env_id ).

    DATA ls_ss TYPE ty_safe_stock.
    READ TABLE gt_ss_cache INTO ls_ss
      WITH KEY plant_id  = iv_plant_id
               mat_group = iv_mat_group.

    rv_result = COND #( WHEN sy-subrc = 0 THEN ls_ss-min_qty
                        ELSE 0 ).
  ENDMETHOD.





  METHOD load_sd_cache.
    CHECK iv_env_id <> gv_sd_cache_env OR gt_sd_cache IS INITIAL.

    SELECT item_id, env_id, branch_id, cust_group, material_grp,
           max_discount, min_order_val, approver_grp,
           currency, valid_from, valid_to
      FROM zsd_price_conf
      WHERE env_id = @iv_env_id
      INTO CORRESPONDING FIELDS OF TABLE @gt_sd_cache.

    gv_sd_cache_env = iv_env_id.
  ENDMETHOD.

  METHOD get_sd_prices.
    load_sd_cache( iv_env_id ).
    rt_result = gt_sd_cache.
  ENDMETHOD.

  METHOD get_sd_price_single.
    load_sd_cache( iv_env_id ).

    READ TABLE gt_sd_cache INTO rs_result
      WITH KEY branch_id    = iv_branch_id
               cust_group   = iv_cust_group
               material_grp = iv_material_grp.
  ENDMETHOD.





  METHOD clear_cache.
    CLEAR: gv_fi_cache_env, gt_fi_cache,
           gv_mm_cache_env, gt_mm_cache,
           gv_ss_cache_env, gt_ss_cache,
           gv_sd_cache_env, gt_sd_cache.
  ENDMETHOD.

ENDCLASS.
