-- create by wei.tao  统一 sg 地区的模板

set spark.sql.hive.convertMetastoreParquet=false;
create or replace temporary view user_device_spdf_tddf as
select
    user.user_id
    ,user_device.shopee_df
    ,user_device.shopee_device_id
    ,coalesce(tongdun.tongdun_device_id, tongdun_history.tongdun_device_id) as tongdun_device_id
    ,user_device.hash_shopee_df
    ,user_device.create_timestamp
    ,user.grass_region
    ,cast('${bizdate}' as date) as grass_date
from (
    select
        user_id
        ,grass_region
    from mp_user.dim_user__reg_s0_live
    where grass_date = date('${bizdate}')
      and grass_region = '${grass_region}'
) user
join (
    select
        userid as user_id
        ,device_fingerprint as shopee_df
        ,base64(device_fingerprint) as shopee_device_id
        ,base64(hashed_fingerprint) as hash_shopee_df
        ,min(ctime) as create_timestamp
    from risk.dim_shopee_device_extension_v2_db__device_ext_tab__reg_df
    where base64(hashed_fingerprint) <> 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=' 
    group by userid, device_fingerprint, hashed_fingerprint
) user_device
  on user.user_id = user_device.user_id
left outer join (
    select
        tongdun_device_id
        ,hash_shopee_df
        ,grass_region
    from ${SCHEMA}.dim_risk_tongdun_device_mapping_tab
    where tz_type='local'
      and grass_region = '${grass_region}'
) tongdun
  on user.grass_region = tongdun.grass_region and user_device.hash_shopee_df = tongdun.hash_shopee_df
left outer join (
    select
        tongdun_device_id
        ,hash_shopee_df
    from ${SCHEMA}.dim_risk_tongdun_device_mapping_history_df
    where tz_type='local'
) tongdun_history
on tongdun.tongdun_device_id is null and user_device.hash_shopee_df = tongdun_history.hash_shopee_df
;

insert overwrite table ${SCHEMA}.dim_risk_user_device_df partition (tz_type='local', grass_region, grass_date)
select
    t1.user_id
    ,t1.shopee_df
    ,t1.shopee_device_id
    ,t1.tongdun_device_id
    ,t1.hash_shopee_df
    ,t1.create_timestamp
    ,coalesce(t2.sz_dfp_device_id, t3.sz_dfp_device_id) as sz_dfp_device_id
    ,t1.grass_region
    ,t1.grass_date
from user_device_spdf_tddf t1
left outer join (
    select
        device_type
        ,device_id
        ,sz_dfp_device_id
        ,grass_region
    from ${SCHEMA}.dim_risk_sz_dfp_device_mapping_df
    where tz_type='local'
      and grass_date = date('${bizdate}')
      and grass_region = '${grass_region}'
      and device_type = 'tddf'
) t2
on t1.grass_region = t2.grass_region
  and t1.tongdun_device_id = t2.device_id
left outer join (
    select
        device_type
        ,device_id
        ,sz_dfp_device_id
        ,grass_region
    from ${SCHEMA}.dim_risk_sz_dfp_device_mapping_df
    where tz_type='local'
      and grass_date = date('${bizdate}')
      and grass_region = '${grass_region}'
      and device_type = 'spdf'
) t3
on t1.grass_region = t3.grass_region
  and t1.hash_shopee_df = t3.device_id
;