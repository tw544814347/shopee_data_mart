drop table if exists ${SCHEMA}.dwd_risk_mx_uw_aai_blacklist_df;

create external table if not exists ${SCHEMA}.dwd_risk_mx_uw_aai_blacklist_df(
    flow_no string comment 'flow_no'
    ,user_id    string comment 'platform_user_id'
    ,request_id string comment ''
    ,request_datetime   string comment 'request_datetime'
    ,is_hit string comment 'is hit'
    ,extra  string  comment 'extra'
    ,pricing_strategy   string comment 'pricing strategy'
    ,code   string comment 'code'
    ,transaction_id string comment 'transaction_id'
    ,message    string comment 'message'
)
partitioned by
(
    grass_date string comment 'grass_date, partition key'
)
stored as orc
tblproperties
(
    "orc.compress" = "zstd","orc.stripe.size"="268435456"
)
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_uw_aai_blacklist_df/grass_region=MX';
msck repair table ${SCHEMA}.dwd_risk_mx_uw_aai_blacklist_df;


