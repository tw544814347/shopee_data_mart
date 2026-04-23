drop table if exists ${SCHEMA}.dws_risk_buyer_txn_ctime_df;
create external table if not exists ${SCHEMA}.dws_risk_buyer_txn_ctime_df
(
    buyer_id                        bigint             comment 'shopee buyer id'
    ,big_shop_flag                  tinyint            comment 'Whether order belongs to big shop'
    ,gmv                            decimal(25,10)     comment 'Gross mechandise value of the order'
    ,order_cnt                      bigint             comment 'Number of virtual order'
    ,virtual_gmv                    decimal(25,10)     comment 'Gross mechandise value of the virtual order'
    ,virtual_order_cnt              bigint             comment 'Number of virtual order'
    ,create_date                    string             comment 'Dim date of the order when its created (local time in string)'
)
comment '
Tag:risk summary table
store last 180days(create_datetime) orders'
partitioned by
(
    tz_type         string          comment         'timezone type'
    ,grass_region   string          comment         'partition key'
    ,grass_date     string          comment         'partition key, yyyy-MM-dd,date of the order when its created'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_buyer_txn_ctime_df';
msck repair table ${SCHEMA}.dws_risk_buyer_txn_ctime_df;
