create or replace temporary view ads_risk_profile_device_df_pre as
select
    a1.shopee_df
    ,a1.shopee_device_id
    ,unbase64(a1.hash_shopee_df) as hash_shopee_df
    ,hex(unbase64(a1.hash_shopee_df)) as hex_hash_shopee_df
    ,a1.tongdun_device_id
    ,a1.sz_dfp_device_id
    ,concat_ws(',', collect_set(user_id)) as login_user_id_list
    ,a1.grass_region
    ,cast('${bizdate}' as date) as grass_date
from ${SCHEMA}.dim_risk_user_device_df a1
where tz_type='local'
  and grass_date = date('${bizdate}')
  and grass_region = upper('${region}')
  and coalesce(trim(shopee_df), '') <> ''
group by
    a1.shopee_df
    ,a1.shopee_device_id
    ,a1.tongdun_device_id
    ,a1.hash_shopee_df
    ,hex(unbase64(a1.hash_shopee_df))
    ,a1.sz_dfp_device_id
    ,a1.grass_region
;

insert overwrite table ${SCHEMA}.ads_risk_profile_device_df partition (tz_type='local', grass_region, grass_date )
select
    a1.shopee_df
    ,a1.shopee_device_id
    ,a1.hash_shopee_df
    ,a1.hex_hash_shopee_df
    ,a1.tongdun_device_id
    ,a1.login_user_id_list
    ,null as spdf_fst_login_timestamp
    ,null as spdf_fst_req_credit_timestamp
    ,a1.sz_dfp_device_id
    ,a1.grass_region
    ,cast('${bizdate}' as date) as grass_date
from ads_risk_profile_device_df_pre a1
;

create or replace view ${SCHEMA}.ads_risk_${region}_profile_device_df as
select
    *
from ${SCHEMA}.ads_risk_profile_device_df
where
    grass_region = upper('${region}')
    and grass_date = '${grass_date}'
;