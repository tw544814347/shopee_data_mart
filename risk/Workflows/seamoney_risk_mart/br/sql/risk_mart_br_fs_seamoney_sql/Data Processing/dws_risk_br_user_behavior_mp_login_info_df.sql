--drop table if exists ${SCHEMA}.dws_risk_${region}_user_behavior_mp_login_info_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_behavior_mp_login_info_df (
    shopee_user_id string comment 'shopee user id'
    ,platform_user_id string comment 'shopee user id'
    ,login_days_in_180d bigint comment 'login days in last 180 days'
) partitioned by (
    grass_date string comment "YYYY-MM-DD"
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location '${HDFS_PATH}/risk_mart/dws/dws_risk_reg_user_behavior_mp_login_info_df/grass_region=${grass_region}'
;
--msck repair table ${SCHEMA}.dws_risk_${region}_user_behavior_mp_login_info_df;


insert overwrite table ${SCHEMA}.dws_risk_${region}_user_behavior_mp_login_info_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id as shopee_user_id
    ,t1.platform_user_id
    ,t2.login_day_cnt_180d as login_days_in_180d
from
(
    select
        platform_user_id
    from ${SCHEMA}.dim_risk_${region}_user_info_df
    where grass_date = '${grass_date}'
) t1
left join
(
    select
        user_id
        ,login_day_cnt_180d
    from mp_user.dws_user_login_nd__reg_s0_live
    where tz_type = 'local'
        and grass_region = '${grass_region}'
        and grass_date = '${grass_date}'
) t2 on t1.platform_user_id = t2.user_id
;

