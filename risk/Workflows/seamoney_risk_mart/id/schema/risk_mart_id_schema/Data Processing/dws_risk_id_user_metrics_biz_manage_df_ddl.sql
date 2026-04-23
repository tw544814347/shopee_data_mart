drop table if exists ${SCHEMA}.dws_risk_id_user_metrics_biz_manage_df;

create table if not exists ${SCHEMA}.dws_risk_id_user_metrics_biz_manage_df
(
    platform_user_id string comment 'platform_user_id'
    ,category        string comment 'category'
    ,scene           string comment 'scene'
    ,level           string comment 'level'
    ,source          string comment 'source'
    ,cate            string comment 'cate'
    ,limit_level     string comment 'limit_level'
    ,last_spl_increment_control_live_days_from_now bigint comment ''
) 
partitioned by
(
    grass_date string comment 'grass_date, partition key'
)
stored as parquet
tblproperties
(
    "orc.compress" = "SNAPPY"
    ,"orc.stripe.size" = "268435456"
)
location '${HDFS_PATH}/risk_mart/dwd/dws_risk_user_metrics_biz_manage_df/grass_region=ID';

msck repair table ${SCHEMA}.dws_risk_id_user_metrics_biz_manage_df;

