drop table if exists ${SCHEMA}.dws_risk_buyer_phone_complete_df;
create external table if not exists ${SCHEMA}.dws_risk_buyer_phone_complete_df
(
    buyer_id bigint comment 'shopee buyer id'
    ,phone string comment 'primary key phone'
    ,shipping_phone string comment 'attribute: shipping phone'
    ,complete_physical_ord_cnt_6m bigint comment 'complete physical product order count in 6 months'
)
comment 'user login accumulated table'
partitioned by
(
    tz_type        string          comment         'timezone type'
    ,grass_region   string          comment         'partition key'
    ,grass_date     string            comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_buyer_phone_complete_df';
msck repair table ${SCHEMA}.dws_risk_buyer_phone_complete_df;