-- added by wei.tao 20251011  新增过滤逻辑 hash_shopee_df <> 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=' 

create or replace temporary view shopee_df_first_appear_merge as
select
    coalesce(t1.shopee_df,t2.shopee_df,t3.shopee_df) as shopee_df
    ,coalesce(t1.spdf_fst_login_timestamp,t2.spdf_fst_login_timestamp) as spdf_fst_login_timestamp
    ,coalesce(t1.spdf_fst_req_credit_timestamp,t3.spdf_fst_req_credit_timestamp) as spdf_fst_req_credit_timestamp
    ,'${grass_region}' as grass_region
from
(
    select
        shopee_df
        ,spdf_fst_login_timestamp
        ,spdf_fst_req_credit_timestamp
        ,grass_region
    from ${SCHEMA}.ads_risk_profile_device_df
    where tz_type = 'local'
        and grass_region = '${grass_region}'
        and grass_date = date_sub(date('${bizdate}'), 1)
        and coalesce(trim(shopee_df), '') <> ''
) t1
full outer join
(
    select
        shopee_df
        ,min(login_timestamp) as spdf_fst_login_timestamp
        ,grass_region
    from ${SCHEMA}.dwd_risk_login_di
    where tz_type = 'local'
        and grass_region = '${grass_region}'
        and grass_date = date('${bizdate}')
        and is_device = 'Y'
        and coalesce(trim(shopee_df), '') <> ''
    group by shopee_df,grass_region
) t2
on t1.grass_region = t2.grass_region
    and t1.shopee_df = t2.shopee_df
full outer join
(
    select
        device_fingerprint as shopee_df
        ,min(req_time) as spdf_fst_req_credit_timestamp
        ,'${grass_region}' as grass_region
    from ${SCHEMA}.dwd_risk_id_strategy_final_result_merge_di
    where grass_date = '${bizdate}'
        and risk_scene_id in (10013,10034,10024,10026)
        and coalesce(trim(device_fingerprint), '') <> ''
    group by device_fingerprint
) t3
on t1.grass_region = t3.grass_region
    and t1.shopee_df = t3.shopee_df
;

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
  and grass_region = '${grass_region}'
  and coalesce(trim(shopee_df), '') <> ''
  and hash_shopee_df <> 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA='
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
    ,a2.spdf_fst_login_timestamp
    ,a2.spdf_fst_req_credit_timestamp
    ,a1.sz_dfp_device_id
    ,a1.grass_region
    ,cast('${bizdate}' as date) as grass_date
from ads_risk_profile_device_df_pre a1
left join shopee_df_first_appear_merge a2
on a1.grass_region = a2.grass_region
    and a1.shopee_df = a2.shopee_df
;

create or replace view ${SCHEMA}.ads_risk_${region}_profile_device_df as
select
    *
from ${SCHEMA}.ads_risk_profile_device_df
where
    grass_region = upper('${region}')
    and grass_date = '${grass_date}'
;