drop table if exists ${SCHEMA}.dws_risk_${region}_user_metrics_biz_manage_df;

create table if not exists ${SCHEMA}.dws_risk_${region}_user_metrics_biz_manage_df
(
    platform_user_id string comment 'platform_user_id'
    ,hit_rule_bad_user_in_cluster_v2 bigint comment 'hit_rule_bad_user_in_cluster_v2'
)
partitioned by
(
    grass_date string comment 'grass_date, partition key'
)
stored as parquet
tblproperties
(
    "orc.compress" = "zstd"
)
location '${HDFS_PATH}/risk_mart/dwd/dws_risk_user_metrics_biz_manage_df/grass_region=${grass_region}';

msck repair table ${SCHEMA}.dws_risk_${region}_user_metrics_biz_manage_df;

