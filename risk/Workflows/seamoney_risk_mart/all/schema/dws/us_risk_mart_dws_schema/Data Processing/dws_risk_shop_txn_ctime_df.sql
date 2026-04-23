drop table if exists ${SCHEMA}.dws_risk_shop_txn_ctime_df;
create external table if not exists ${SCHEMA}.dws_risk_shop_txn_ctime_df
(
    shop_id                   bigint         comment 'unique id of the shop'
    ,create_date              string         comment 'Dim date of the order when its created (local time in string)'
    ,terminal_flag            tinyint        comment 'Whether order reach terminal status'
    ,diff_days                bigint         comment 'Days to date'
    ,diff_months              bigint         comment 'months to date'
    ,gmv                      decimal(30,10) comment 'Gross mechandise value of the order'
    ,order_cnt                bigint         comment 'Number of order'
    ,cc_gmv                   decimal(30,10) comment 'Net mechandise value of the order by credit payment method'
    ,nmv                      decimal(30,10) comment 'Net mechandise value of the order'
    ,confirmed_order_cnt      bigint         comment 'Number of confirmed order'
    ,cc_nmv                   decimal(30,10) comment 'Net mechandise value of the order by credit payment method'
    ,return_gmv               decimal(30,10) comment 'Gross mechandise value of return order'
    ,return_order_cnt         bigint         comment 'Number of return order'
    ,cancelled_order_cnt      bigint         comment 'number of cancelled order'
)
partitioned by
(
    tz_type        string          comment         'timezone type'
    ,grass_region   string          comment         'partition key'
    ,grass_date     string            comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_shop_txn_ctime_df';
msck repair table ${SCHEMA}.dws_risk_shop_txn_ctime_df;