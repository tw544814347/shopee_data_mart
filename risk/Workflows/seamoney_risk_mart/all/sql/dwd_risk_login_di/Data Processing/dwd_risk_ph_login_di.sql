-- 变更: wei.tao SG 地区统一成模板

set spark.sql.hive.convertMetastoreParquet=false;
with login_di_spdf_tddf as (
select
    a1.user_id
    ,a1.platform as login_from
    ,a1.is_device
    ,a2.shopee_df
    ,case
        when a1.is_device = "Y" then a2.shopee_device_id
        end as shopee_device_id
    ,coalesce(b1.tongdun_device_id, b2.tongdun_device_id) as tongdun_device_id
    ,a1.is_login
    ,a1.ip as login_ip
    ,a1.event_timestamp as login_timestamp
    ,a2.shopee_df_temper
    ,a2.is_fingerprint_tempered
    ,a2.is_root
    ,a2.hash_shopee_df
    ,a1.grass_region
    ,cast('${bizdate}' as date) as grass_date
from (
    select
        user_id
        ,platform
        ,device_id
        ,ip
        ,event_timestamp
        ,case
            when (platform in ${login_from} or platform like 'ios-app_%' or platform like 'android-app_%') and coalesce(trim(device_id), '') <> '' then 'Y'
            else 'N'
            end as is_device
        ,'Y' as is_login
        ,grass_region
    from mp_user.dwd_login_ent_di__reg_s0_live
    where grass_date = date('${bizdate}')
        and grass_region = '${grass_region}'
) a1
left outer join (
    select
        userid
        ,deviceid
        ,device_fingerprint as shopee_df
        ,fingerprint_before_temper as shopee_df_temper
        ,is_fingerprint_tempered
        ,is_rooted as is_root
        ,base64(device_fingerprint) as shopee_device_id
        ,base64(hashed_fingerprint) as hash_shopee_df
    from risk.dim_shopee_device_extension_v2_db__device_ext_tab__reg_df
    where length(device_fingerprint) > 0
) a2
on a1.is_device = 'Y' and a1.device_id = a2.deviceid and a1.user_id = a2.userid
left outer join (
    select
        shopee_device_id
        ,tongdun_device_id
        ,grass_region
    from ${SCHEMA}.dim_risk_tongdun_device_mapping_tab
    where tz_type = 'local'
        and grass_region = '${grass_region}'
        and coalesce(shopee_device_id,'') <> ''
) b1
on a1.grass_region = b1.grass_region and a2.shopee_device_id = b1.shopee_device_id
left outer join (
    select
        shopee_device_id
        ,tongdun_device_id
    from ${SCHEMA}.dim_risk_tongdun_device_mapping_history_df
    where tz_type = 'local'
    and coalesce(shopee_device_id,'') <> ''
) b2
on b1.tongdun_device_id is null and a2.shopee_device_id = b2.shopee_device_id
)

insert overwrite table ${SCHEMA}.dwd_risk_login_di partition (tz_type='local', grass_region, grass_date)
select
    t1.user_id
    ,t1.login_from
    ,t1.is_device
    ,t1.shopee_df
    ,t1.shopee_device_id
    ,t1.tongdun_device_id
    ,t1.is_login
    ,t1.login_ip
    ,t1.login_timestamp
    ,t1.shopee_df_temper
    ,t1.is_fingerprint_tempered
    ,t1.is_root
    ,t1.hash_shopee_df
    ,coalesce(t2.sz_dfp_device_id, t2_spp.sz_dfp_device_id, t3.sz_dfp_device_id, t4.sz_dfp_device_id) as sz_dfp_device_id
    ,case when t1.login_from in ('shopee_android_lite_app', 'ios-app_shopeepay-app', 'android-app_shopeepay-app') then '1'
          else '0'
          end
        as is_spp_update
    ,spp.shopeepay_user_id
    ,t1.grass_region
    ,t1.grass_date
from login_di_spdf_tddf t1
left join
(
    select
        user_id
        ,shopee_df_plain
        ,event_regional_datetime
        ,grass_region
        ,first(dfpinfosz__securitydeviceid) as sz_dfp_device_id
        ,count(distinct dfpinfosz__securitydeviceid) as sz_df_cnt
    from antifraud_dw.dwd_evt_shopee_login_di
    where grass_region = '${grass_region}'
    and grass_date = date('${bizdate}')
    and coalesce(trim(shopee_df_plain),'') <> ''
    group by user_id, shopee_df_plain, event_regional_datetime, grass_region
    having count(distinct dfpinfosz__securitydeviceid) = 1
) t2
on t1.grass_region = t2.grass_region
  and t1.user_id = t2.user_id
  and t1.shopee_df = t2.shopee_df_plain
  and from_unixtime(t1.login_timestamp) = t2.event_regional_datetime
left join 
(
    select
        user_id
        ,shopee_df_plain
        ,event_regional_datetime
        ,grass_region
        ,first(dfpinfosz__security_device_id) as sz_dfp_device_id
        ,count(distinct dfpinfosz__security_device_id) as sz_df_cnt
    from antifraud_dw.dwd_evt_shopeepay_login_di
    where grass_region = '${grass_region}'
    and grass_date = date('${bizdate}')
    and coalesce(trim(shopee_df_plain),'') <> ''
    group by user_id, shopee_df_plain, event_regional_datetime, grass_region
    having count(distinct dfpinfosz__security_device_id) = 1
) t2_spp
on t1.grass_region = t2_spp.grass_region
  and t1.user_id = t2_spp.user_id
  and t1.shopee_df = t2_spp.shopee_df_plain
  and from_unixtime(t1.login_timestamp) = t2_spp.event_regional_datetime
left join
(
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
) t3
on t1.grass_region = t3.grass_region
  and t1.tongdun_device_id = t3.device_id
left join
(
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
) t4
on t1.grass_region = t4.grass_region
  and t1.hash_shopee_df = t4.device_id
left join (
    select
    *
    from risk.dim_risk_${region}_sp_to_spp_id_mapping_df
    where grass_date = (select max(grass_date) from risk.dim_risk_${region}_sp_to_spp_id_mapping_df)
) spp 
on (t1.user_id=spp.shopee_user_id)
;