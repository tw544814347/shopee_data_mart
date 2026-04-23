drop table if exists ${SCHEMA}.dwd_risk_af_payment_success_join_df;
create table if not exists ${SCHEMA}.dwd_risk_af_payment_success_join_df
(
    value          string          comment         'report data'
)
partitioned by
(
    grass_region         string          comment         'partition key'
    ,app_id              string          comment         'app_id'
    ,scene_id            string          comment         'scene_id'
    ,grass_date          string          comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_af_payment_success_join_df';
msck repair table ${SCHEMA}.dwd_risk_af_payment_success_join_df;