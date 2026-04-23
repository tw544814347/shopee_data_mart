drop table if exists ${SCHEMA}.dwd_risk_order_complete_di;
create external table if not exists ${SCHEMA}.dwd_risk_order_complete_di
(
    buyer_id                        bigint     comment 'shopee buyer id'
    ,checkout_id                    string     comment 'checkout id'
    ,checkout_ip                    string     comment 'checkout ip'
    ,shopee_device_id               string     comment 'shopee device id'
    ,checkout_timestamp             bigint     comment 'checkout time stamp'
    ,order_id                       bigint     comment 'order id'
    ,is_physical_product_order      string     comment 'whether this order contain the physical product Y : contain physical product N : not contain physical product'
    ,shipping_city_name             string     comment 'shipping city name'
    ,complete_timestamp             bigint     comment 'complete time'
    ,create_timestamp               bigint     comment 'Timestamp of the order when its created (epoch time)' 
    ,complete_date                  string     comment 'Date of the order when its completed'
    ,complete_duration              bigint     comment 'Duration of completed order (second)'
    ,shop_id                        bigint     comment 'shop_id'
    ,big_shop_flag                  tinyint    comment 'Whether order belongs to big shop'
    ,checkout_city_name             string     comment 'checkout_city_name'
    ,shopeepay_user_id              string     comment 'spp uid'
)
comment 'table will keep the complete order today'
partitioned by
(
    tz_type        string          comment         'timezone type'
    ,grass_region   string          comment         'partition key'
    ,grass_date     string            comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_order_complete_di';
msck repair table ${SCHEMA}.dwd_risk_order_complete_di;
