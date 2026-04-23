-- by wei.tao 统一到 模板，all region 任务发 marker
-- update by wei.tao 新增 sppuid 用于后续 feature 开发 2026-01-29

insert overwrite table ${SCHEMA}.dwd_risk_szdf_login_di partition (tz_type='local', grass_region, grass_date)
select
    t1.user_id
    ,t1.login_from
    ,t1.is_device
    ,t1.is_login
    ,t1.login_ip
    ,t1.login_timestamp
    ,t1.sz_dfp_device_id

    ,t1.is_success 
    ,t1.is_auto_login 
    ,t1.login_channel 
    ,t1.platform_id 
    ,t1.app_type_name 
    ,t1.latitude 
    ,t1.longitude 
    ,t1.country_ip 
    ,t1.region_ip 
    ,t1.city_ip 
    ,t1.country_gps 
    ,t1.region_gps 
    ,t1.city_gps 
    ,t1.phone 
    ,t1.dfpinfosz__platform
    ,t1.is_spp
    ,case when spp_user_id is null then spp.shopeepay_user_id
        else spp_user_id  
        end as shopeepay_user_id
    ,t1.grass_region
    ,cast(t1.grass_date as string) as grass_date
from (
select
    a1.sz_dfp_device_id
    ,a1.user_id
    ,a1.platform as login_from
    ,a1.is_device
    ,a1.is_login
    ,a1.ip as login_ip
    ,a1.event_timestamp as login_timestamp
    ,a1.is_success 
    ,a1.is_auto_login 
    ,a1.login_channel 
    ,a1.platform_id 
    ,a1.app_type_name 
    ,a1.latitude 
    ,a1.longitude 
    ,a1.country_ip 
    ,a1.region_ip 
    ,a1.city_ip 
    ,a1.country_gps 
    ,a1.region_gps 
    ,a1.city_gps 
    ,a1.phone 
    ,a1.dfpinfosz__platform
    ,a1.grass_region
    ,a1.grass_date as grass_date
    ,is_spp
    ,spp_user_id
from (
    select
        user_id
        ,CASE platform_id
            WHEN 0   THEN 'UNKNOWN'
            WHEN 1   THEN 'IOS_WEB'
            WHEN 2   THEN 'IOS_APP'
            WHEN 3   THEN 'ANDROID_WEB'
            WHEN 4   THEN 'ANDROID_APP'
            WHEN 5   THEN 'PC_MALL'
            WHEN 6   THEN 'IOS_LITE'
            WHEN 7   THEN 'ANDROID_LITE'
            WHEN 128 THEN 'OTHERS'
            ELSE null 
            END AS platform
        ,client_ip as ip
        ,CAST(event_timestamp / 1000 AS BIGINT) as event_timestamp
        ,'Y' as is_device -- 限制条件为 移动端 ios / android
        ,'Y' as is_login
        ,grass_region
        ,dfpinfosz__securitydeviceid as sz_dfp_device_id
        ,is_success  
        ,is_auto_login  
        ,login_channel  
        ,platform_id 
        ,CASE app_type_id
            WHEN 0  THEN 'APP_TYPE_NA'
            WHEN 1  THEN 'APP_TYPE_SHOPEE'
            WHEN 2  THEN 'APP_TYPE_SHOPEEPAY_MERCHANT'
            WHEN 3  THEN 'APP_TYPE_SHOPEE_LITE'
            WHEN 4  THEN 'APP_TYPE_SHOPEEFOOD_DRIVER'
            WHEN 5  THEN 'APP_TYPE_SHOPEEPAY_USER'
            WHEN 6  THEN 'APP_TYPE_SHOPEEEXPRESS_DRIVER'
            WHEN 7  THEN 'APP_TYPE_MITRA'
            WHEN 8  THEN 'APP_TYPE_SHOPEEEXPRESS_SELLER'
            WHEN 9  THEN 'APP_TYPE_SHOPEELOGISTICS_PORTAL'
            WHEN 10 THEN 'APP_TYPE_AIRPAY'
            WHEN 11 THEN 'APP_TYPE_SHOPEEFOOD_USER'
            WHEN 12 THEN 'APP_TYPE_BRAND_IP'
            WHEN 13 THEN 'APP_TYPE_SHOPEE_LITE_APP'
            WHEN 14 THEN 'APP_TYPE_OPEN_PLATFORM'
            WHEN 15 THEN 'APP_TYPE_PARTNER_VOUCHER_MANAGEMENT'
            WHEN 16 THEN 'APP_TYPE_SHOPEEFOOD_MERCHANT'
            WHEN 17 THEN 'APP_TYPE_SHOPEEFOOD_FOODY'
            WHEN 18 THEN 'APP_TYPE_SHOPEEFOOD_OCHA'
            WHEN 19 THEN 'APP_TYPE_SPX_AGENCY'
            WHEN 20 THEN 'APP_TYPE_LDN'
            WHEN 21 THEN 'APP_TYPE_MCN'
            WHEN 22 THEN 'APP_TYPE_SPX_DIRECT_DELIVERY'
            WHEN 23 THEN 'APP_TYPE_TWS'
            WHEN 24 THEN 'APP_TYPE_WMS'
            WHEN 25 THEN 'APP_TYPE_WMS_WFM'
            WHEN 26 THEN 'APP_TYPE_WMS_AGENCY'
            WHEN 27 THEN 'APP_TYPE_SPX_FMS'
            WHEN 28 THEN 'APP_TYPE_DEMO'
            WHEN 29 THEN 'APP_TYPE_SHOPEE_SELLER'
            ELSE 'UNKNOWN'
        END AS app_type_name  
        ,latitude  
        ,longitude  
        ,ipinfo__country_ip as country_ip
        ,ipinfo__region_ip as region_ip
        ,ipinfo__city_ip as city_ip
        ,gpsinfo__country_gps as country_gps
        ,gpsinfo__region_gps as region_gps  
        ,gpsinfo__city_gps as city_gps  
        ,phone  
        ,grass_date
        ,dfpinfosz__platform
        ,is_spp
        ,spp_user_id
    from --mp_user.dwd_login_ent_di__reg_s0_live --旧表
        (
            select user_id
                ,platform_id
                ,client_ip
                ,event_timestamp
                ,grass_region
                ,dfpinfosz__securitydeviceid
                ,is_success  
                ,is_auto_login  
                ,login_channel  
                ,app_type_id
                ,latitude  
                ,longitude  
                ,ipinfo__country_ip
                ,ipinfo__region_ip
                ,ipinfo__city_ip
                ,gpsinfo__country_gps
                ,gpsinfo__region_gps
                ,gpsinfo__city_gps
                ,phone  
                ,grass_date
                ,dfpinfosz__platform
                ,0 as is_spp
                ,null as spp_user_id
            from antifraud_dw.dwd_evt_shopee_login_di where grass_date = date('${ds}')
            union all
            select user_id
                ,platform_id
                ,client_ip
                ,event_timestamp
                ,grass_region
                ,dfpinfosz__security_device_id
                ,is_success  
                ,is_auto_login  
                ,login_channel   
                ,app_type_id
                ,latitude  
                ,longitude  
                ,ipinfo__country_ip
                ,ipinfo__region_ip
                ,ipinfo__city_ip
                ,gpsinfo__country_gps
                ,gpsinfo__region_gps
                ,gpsinfo__city_gps
                ,phone  
                ,grass_date
                ,dfpinfosz__platform
                ,1 as is_spp
                ,spp_user_id
            from antifraud_dw.dwd_evt_shopeepay_login_di where grass_date = date('${ds}')
        )
    where grass_date = date('${ds}')
        and grass_region = '${grass_region}'
        and dfpinfosz__platform in (1,2) -- 1:Android,2:IOS
) a1
) t1
left join (
    select
    *
    from risk.dim_risk_${region}_sp_to_spp_id_mapping_df
    where grass_date = (select max(grass_date) from risk.dim_risk_${region}_sp_to_spp_id_mapping_df)
) spp 
on (t1.user_id=spp.shopee_user_id)
;

-- create or replace view risk.dwd_risk_v2_login_di
-- as 
-- select *
-- from risk.dwd_risk_szdf_login_di
-- ;


-- create or replace view risk.dwd_risk_login__internal_use__di
-- as 
-- select *
-- from risk.dwd_risk_szdf_login_di
-- ;
