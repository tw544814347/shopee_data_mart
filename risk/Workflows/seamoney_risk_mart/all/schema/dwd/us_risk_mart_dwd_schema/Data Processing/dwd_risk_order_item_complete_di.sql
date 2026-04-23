drop table if exists ${SCHEMA}.dwd_risk_order_item_complete_di;
create external table if not exists ${SCHEMA}.dwd_risk_order_item_complete_di
(
    buyer_id	                bigint     comment 'shopee buyer id'
    ,order_id                   bigint     comment 'order id'
    ,checkout_id	            bigint     comment 'checkout id'
    ,item_id                    bigint     comment 'item id'
    ,is_physical_product        string     comment 'is the physical product defined by the level1_category name. Y : physical product N : non-physical product'
    ,checkout_shopee_device_id  string     comment 'checkout shopee device id'
    ,complete_timestamp         bigint     comment 'complete time stamp'
    ,tongdun_device_id          string     comment 'tongdun device id'
    ,sz_dfp_device_id           string     comment 'sz device fingerprint id'
    ,create_timestamp           bigint     comment 'Timestamp of the order when its created (epoch time)' 
    ,complete_date              string     comment 'Date of the order when its completed'
    ,complete_duration          bigint     comment 'Duration of completed order (second)'
    ,shop_id                    bigint     comment 'shop_id'
    ,big_shop_flag              tinyint    comment 'Whether order belongs to big shop'
)
comment 'user login record'
partitioned by
(
    tz_type         string          comment         'timezone type'
    ,grass_region   string          comment         'partition key'
    ,grass_date     string            comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_order_item_complete_di';
msck repair table ${SCHEMA}.dwd_risk_order_item_complete_di;

