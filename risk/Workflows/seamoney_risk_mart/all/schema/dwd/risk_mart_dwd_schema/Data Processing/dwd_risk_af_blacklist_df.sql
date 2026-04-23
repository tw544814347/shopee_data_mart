drop table if exists risk.dwd_risk_af_blacklist_df;
create external table if not exists risk.dwd_risk_af_blacklist_df
(
    data                  string comment 'list data'
    ,data_type            string comment 'data_type'
    ,data_source          string comment 'listname source'
    ,action_detail        string comment 'action_detail'
    ,remark               string comment 'remark'
    ,description          string comment 'description'
    ,status               string comment 'status 1:active -1:delete 0:unactive 2:waiting'
    ,status_type          string comment 'status 1:active -1:delete 0:unactive 2:waiting'
    ,creator              string comment 'creator'
    ,update_time          string comment 'update_time'
    ,expire_time          string comment 'expire_time'
)
comment 'fraud user login info'
partitioned by
(
    grass_region   string         comment         'partition key'
    ,grass_date     string         comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_af_blacklist_df';
msck repair table ${SCHEMA}.dwd_risk_af_blacklist_df;