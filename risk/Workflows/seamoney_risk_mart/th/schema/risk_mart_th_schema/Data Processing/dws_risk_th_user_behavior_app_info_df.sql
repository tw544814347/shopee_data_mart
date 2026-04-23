drop table if exists ${SCHEMA}.dws_risk_${region}_user_behavior_app_info_df;

create table if not exists ${SCHEMA}.dws_risk_${region}_user_behavior_app_info_df
(
    platform_user_id string comment 'platform_user_id'
    ,app_support_flag bigint comment 'app_support_flag'
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
location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_behavior_app_info_df/grass_region=${grass_region}';

msck repair table ${SCHEMA}.dws_risk_${region}_user_behavior_app_info_df;

