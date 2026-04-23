drop table if exists ${SCHEMA}.dws_risk_buyer_device_complete_df;
create external table if not exists ${SCHEMA}.dws_risk_buyer_device_complete_df
(
    buyer_id bigint comment 'shopee buyer id'
    ,shopee_df string comment 'shopee df'
    ,shopee_device_id string comment 'shopee device id'
    ,tongdun_device_id string comment 'bought from the third part, to be the unique mark'
    ,complete_physical_product_ord_cnt_1y bigint comment 'complete physical product order count in last year'
    ,complete_physical_product_ord_day_cnt_1y bigint comment 'complete physical product order day count in last year'
    ,fas_timestamp_of_complete_physical_product_ord_1y bigint comment 'first time complete physical product order in last year'
    ,sz_dfp_device_id string comment 'sz dfp decide id' 
    ,shopeepay_user_id string comment 'spp uid' 
)
comment 'complete event aggregate by buyer, device'
partitioned by
(
    tz_type        string          comment         'timezone type'
    ,grass_region   string          comment         'partition key'
    ,grass_date     string            comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_buyer_device_complete_df';
msck repair table ${SCHEMA}.dws_risk_buyer_device_complete_df;