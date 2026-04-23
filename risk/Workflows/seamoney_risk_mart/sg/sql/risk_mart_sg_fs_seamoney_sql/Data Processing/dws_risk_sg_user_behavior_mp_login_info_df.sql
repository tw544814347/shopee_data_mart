------------------------------------------------------------------------
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2024-11-14
-- Description:         用户行为主题域，MP User Login主题
-- Data Granularity:    platform_user_id
-- PRD:                 
------------------------------------------------------------------------
----ddl
--drop table if exists ${SCHEMA}.dws_risk_${region}_user_behavior_mp_login_info_df;
create table if not exists ${SCHEMA}.dws_risk_${region}_user_behavior_mp_login_info_df
(
    platform_user_id string comment 'platform_user_id'
    ,silent_days_cnt bigint comment 'count of days for no-login period'
) 
partitioned by
(
    grass_date string comment 'grass_date, partition key'
)
stored as orc
tblproperties
(
    "orc.compress" = "zstd"
)
location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_behavior_mp_login_info_df/grass_region=${grass_region}';
--msck repair table ${SCHEMA}.dws_risk_${region}_user_behavior_mp_login_info_df;

--该指标跟MP mp_user.dws_user_login_nd__reg_s0_live.since_last_login_days表里有，但是跟FS逻辑有差异；
--跟FS原逻辑保持一致
create or replace temporary view dws_user_behavior_mp_login_info_td as
select
    user_id as platform_user_id
    ,datediff(current_date(),date(from_unixtime(last_login_timestamp_td))) as silent_days_cnt
from mp_user.ads_activeness_user_activity_td__reg_s0_live
where tz_type = 'local'
and grass_region = '${grass_region}'
and grass_date = '${grass_date}'
;

insert overwrite table ${SCHEMA}.dws_risk_${region}_user_behavior_mp_login_info_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id
    ,t2.silent_days_cnt
from
    (
        select
            platform_user_id
        from ${SCHEMA}.dim_risk_${region}_user_info_df
        where grass_date = '${grass_date}'
    ) t1
left join
(
    select platform_user_id
            ,silent_days_cnt
    from dws_user_behavior_mp_login_info_td
) t2
on t1.platform_user_id = t2.platform_user_id
;