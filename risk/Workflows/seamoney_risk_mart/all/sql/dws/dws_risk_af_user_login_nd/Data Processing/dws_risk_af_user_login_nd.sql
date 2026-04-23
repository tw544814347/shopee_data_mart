insert overwrite table ${SCHEMA}.dws_risk_af_user_login_nd partition (grass_region, grass_date)
select
    t1.user_id as platform_user_id
    ,t2.login_szdf_3d
    ,t2.login_szdf_7d
    ,t2.login_szdf_14d
    ,t2.login_szdf_30d
    ,t2.login_szdf_60d
    ,t2.login_bad_szdf_3d
    ,t2.login_bad_szdf_7d
    ,t2.login_bad_szdf_14d
    ,t2.login_bad_szdf_30d
    ,t2.login_bad_szdf_60d
    ,t2.login_spdf_3d
    ,t2.login_spdf_7d
    ,t2.login_spdf_14d
    ,t2.login_spdf_30d
    ,t2.login_spdf_60d
    ,t2.login_country_3d
    ,t2.login_country_7d
    ,t2.login_country_14d
    ,t2.login_country_30d
    ,t2.login_country_60d
    ,t2.login_city_3d
    ,t2.login_city_7d
    ,t2.login_city_14d
    ,t2.login_city_30d
    ,t2.login_city_60d
    ,t3.login_szdf_3d
    ,t3.login_szdf_7d
    ,t3.login_szdf_14d
    ,t3.login_ip_3d
    ,t3.login_ip_7d
    ,t3.login_ip_14d
    ,t3.login_ipc_3d
    ,t3.login_ipc_7d
    ,t3.login_ipc_14d
    ,t3.login_bssid_3d
    ,t3.login_bssid_7d
    ,t3.login_bssid_14d
    ,t1.grass_region
    ,t1.grass_date
from
    (
        select
            user_id
            ,grass_region
            ,grass_date
        from mp_user.dim_user__reg_s0_live
        where
            tz_type = 'local'
            and grass_date = '${grass_date}'
    ) t1
    left join ${SCHEMA}.dws_risk_af_user_device_login_nd t2 on t1.grass_region = t2.grass_region
    and t1.grass_date = t2.grass_date
    and t1.user_id = t2.user_id
    left join ${SCHEMA}.dws_risk_af_user_device_ip_manual_login_nd t3 on t1.grass_region = t3.grass_region
    and t1.grass_date = t3.grass_date
    and t1.user_id = t3.user_id
;