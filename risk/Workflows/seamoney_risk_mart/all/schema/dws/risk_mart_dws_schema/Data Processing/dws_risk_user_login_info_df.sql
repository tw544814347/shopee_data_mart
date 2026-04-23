drop table if exists ${SCHEMA}.dws_risk_user_login_info_df;
create external table if not exists ${SCHEMA}.dws_risk_user_login_info_df
(
    user_id bigint comment 'unique id of user'
    ,buyer_login_days_in_14d bigint comment 'number of days with login in last 14 days'
    ,buyer_login_days_in_30d bigint comment 'number of days with login in last 30 days'
    ,buyer_login_days_in_60d bigint comment 'number of days with login in last 60 days'
    ,buyer_login_days_in_180d bigint comment 'number of days with login in last 180 days'
)
partitioned by
(
    tz_type        string          comment         'timezone type'
    ,grass_region   string          comment         'partition key'
    ,grass_date     string            comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_login_info_df';
msck repair table ${SCHEMA}.dws_risk_user_login_info_df;