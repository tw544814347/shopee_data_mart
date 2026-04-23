drop table if exists ${SCHEMA}.dws_risk_buyer_device_complete_di;
create external table if not exists ${SCHEMA}.dws_risk_buyer_device_complete_di
(
    buyer_id bigint comment 'shopee buyer id'
    ,shopee_device_id string comment 'shopee device id'
    ,complete_physical_product_ord_cnt_1d bigint comment 'complete physical product order count in last day'
    ,fas_timestamp_of_complete_physical_product_ord_1d bigint comment 'first time of complete physical product order'
    ,sz_dfp_device_id string comment 'sz device fingerprint id'
)
comment 'complete event aggregate by buyer, device'
partitioned by
(
    tz_type        string          comment         'timezone type'
    ,grass_region   string          comment         'partition key'
    ,grass_date     string            comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_buyer_device_complete_di';
msck repair table ${SCHEMA}.dws_risk_buyer_device_complete_di;