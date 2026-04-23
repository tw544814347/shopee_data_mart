drop table if exists ${SCHEMA}.dws_risk_${region}_user_behavior_mp_login_info_df;

create table if not exists ${SCHEMA}.dws_risk_${region}_user_behavior_mp_login_info_df
(
    platform_user_id string comment 'platform_user_id'
    ,login_days_cnt_30d bigint comment 'login days cnt in the past 30 days'
    ,login_days_cnt_90d bigint comment 'login days cnt in the past 90 days'
    ,login_days_cnt_180d bigint comment 'login days cnt in the past 180 days'
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
    ,"orc.stripe.size" = "268435456"
)
location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_behavior_mp_login_info_df/grass_region=${grass_region}';

msck repair table ${SCHEMA}.dws_risk_${region}_user_behavior_mp_login_info_df;

