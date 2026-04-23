create or replace view if not exists risk.dim_shopee_device_extension_v2_db__device_ext_tab__reg_df
 as 
(
    select *
    from marketplace.shopee_device_extension_v2_db__device_ext_tab__id_df
    union all 
    select *
    from marketplace.shopee_device_extension_v2_db__device_ext_tab__my_df
    union all 
    select *
    from marketplace.shopee_device_extension_v2_db__device_ext_tab__ph_df
    union all 
    select *
    from marketplace.shopee_device_extension_v2_db__device_ext_tab__vn_df
    union all 
    select *
    from marketplace.shopee_device_extension_v2_db__device_ext_tab__sg_df
    union all 
    select *
    from marketplace.shopee_device_extension_v2_db__device_ext_tab__th_df
    union all 
    select *
    from marketplace.shopee_device_extension_v2_db__device_ext_tab__tw_df
)