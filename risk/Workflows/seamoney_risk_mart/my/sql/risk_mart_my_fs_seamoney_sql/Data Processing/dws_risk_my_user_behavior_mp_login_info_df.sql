------------------------------------------------------------------------
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2024-03-12
-- Description:         用户行为主题域，MP User Login主题
-- Data Granularity:    shopee_user_id
-- PRD:                 
------------------------------------------------------------------------


drop table if exists ${SCHEMA}.dws_risk_${region}_user_behavior_mp_login_info_df;
create table if not exists ${SCHEMA}.dws_risk_${region}_user_behavior_mp_login_info_df
(
    shopee_user_id string comment 'shopee_user_id'
    ,platform_user_id string comment 'shopeepay_user_id, 暂时保留兼容历史'
    ,login_days_cnt_30d bigint comment 'login days cnt in the past 30 days'
    ,login_days_cnt_90d bigint comment 'login days cnt in the past 90 days'
    ,login_days_cnt_180d bigint comment 'login days cnt in the past 180 days'
    ,login_days_cnt_360d bigint comment 'login days cnt in the past 360 days'
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
msck repair table ${SCHEMA}.dws_risk_${region}_user_behavior_mp_login_info_df;


----dml
--login_days_cnt_90d, MP user_mart没有该时间窗口，单独加工
create or replace temporary view dws_user_behavior_mp_login_info_df as
select
    user_id as shopee_user_id
    ,count(case when datediff(current_date, grass_date) between 0 and 90 then grass_date end) as login_days_cnt_90d
    ,count(case when datediff(current_date, grass_date) between 0 and 360 then grass_date end) as login_days_cnt_360d
from mp_user.dws_user_login_1d__reg_s0_live
where tz_type = 'local'
and grass_region = '${grass_region}'
and grass_date >= date_sub('${grass_date}', 365)
group by user_id
;

--该指标跟MP mp_user.dws_user_login_nd__reg_s0_live.since_last_login_days表里有，但是跟FS逻辑有差异；
--跟FS原逻辑保持一致
create or replace temporary view dws_user_behavior_mp_login_info_td as
select
    user_id as shopee_user_id
    ,datediff(current_date(),date(from_unixtime(last_login_timestamp_td))) as silent_days_cnt
from mp_user.ads_activeness_user_activity_td__reg_s0_live
where tz_type = 'local'
and grass_region = '${grass_region}'
and grass_date = '${grass_date}'
;

insert overwrite table ${SCHEMA}.dws_risk_${region}_user_behavior_mp_login_info_df partition (grass_date = '${grass_date}')
select
    t1.shopee_user_id
    ,t1.shopee_user_id as platform_user_id
    ,coalesce(t2.login_day_cnt_30d,0) as login_days_cnt_30d
    ,coalesce(t3.login_days_cnt_90d,0) as login_days_cnt_90d
    ,coalesce(t2.login_day_cnt_180d,0) as login_days_cnt_180d
    ,coalesce(t3.login_days_cnt_360d,0) as login_days_cnt_360d
    ,t4.silent_days_cnt
from
    (
        select
            user_id as shopee_user_id
        from mp_user.dim_user__reg_s0_live
        where
            tz_type = 'local'
            and grass_region = '${grass_region}'
            and grass_date = '${grass_date}'
    ) t1
left join
(
        select
            user_id as shopee_user_id
            ,login_day_cnt_30d
            ,login_day_cnt_180d
        from mp_user.dws_user_login_nd__reg_s0_live
        where tz_type = 'local'
        and grass_region = '${grass_region}'
        and grass_date = '${grass_date}'
) t2
on t1.shopee_user_id = t2.shopee_user_id
left join
(
    select shopee_user_id
            ,login_days_cnt_90d
            ,login_days_cnt_360d
    from dws_user_behavior_mp_login_info_df
) t3
on t1.shopee_user_id = t3.shopee_user_id
left join
(
    select shopee_user_id
            ,silent_days_cnt
    from dws_user_behavior_mp_login_info_td
) t4
on t1.shopee_user_id = t4.shopee_user_id
;