drop table if exists ${SCHEMA}.dws_risk_buyer_city_complete_df;
create external table if not exists ${SCHEMA}.dws_risk_buyer_city_complete_df
(
    buyer_id bigint comment 'shopee buyer id'
    ,city_name string comment 'primary key city name'
    ,checkout_city_name string comment 'attribute: checkout city'
    ,complete_physical_product_ord_cnt_6m bigint comment 'complete physical product order count in 6 months'
    ,checkout_shipping_same_city_of_complete_physical_product_ord_cnt_6m bigint comment 'complete physical product order count in 6 months and checkout city is same with checkout city'
    ,complete_physical_product_ord_cnt_without_proxy_6m bigint comment 'complete physical product order count in 6 months without proxy'
    ,checkout_shipping_same_city_of_complete_physical_product_ord_cnt_without_proxy_6m bigint comment 'complete physical product order count in 6 months and checkout city is same with checkout city without proxy'
)
comment 'complete event aggregate by buyer, device'
partitioned by
(
    tz_type        string          comment         'timezone type'
    ,grass_region   string          comment         'partition key'
    ,grass_date     string            comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_buyer_city_complete_df';
msck repair table ${SCHEMA}.dws_risk_buyer_city_complete_df;