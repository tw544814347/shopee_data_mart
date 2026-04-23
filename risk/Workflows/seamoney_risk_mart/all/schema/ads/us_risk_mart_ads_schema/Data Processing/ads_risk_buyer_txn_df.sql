drop table if exists ${SCHEMA}.ads_risk_buyer_txn_df;
create external table if not exists ${SCHEMA}.ads_risk_buyer_txn_df
(
    buyer_id bigint comment 'unique id of the buyer'
    ,buyer_confirmed_order_in_14d bigint comment 'confirmed orders in last 14 days'
    ,buyer_confirmed_order_in_30d bigint comment 'confirmed orders in last 30 days'
    ,buyer_confirmed_order_in_60d bigint comment 'confirmed orders in last 60 days'
    ,buyer_confirmed_order_in_90d bigint comment 'confirmed orders in last 90 days'
    ,buyer_confirmed_order_in_180d bigint comment 'confirmed orders in last 180 days'
    ,buyer_confirmed_order_in_360d bigint comment 'confirmed orders in last 360 days'
    ,buyer_nmv_usd_in_14d decimal(30,10) comment 'gmv usd of confirmed orders in last 14 days'
    ,buyer_nmv_usd_in_30d decimal(30,10) comment 'gmv usd of confirmed orders in last 30 days'
    ,buyer_nmv_usd_in_60d decimal(30,10) comment 'gmv usd of confirmed orders in last 60 days'
    ,buyer_nmv_usd_in_90d decimal(30,10) comment 'gmv usd of confirmed orders in last 90 days'
    ,buyer_nmv_usd_in_180d decimal(30,10) comment 'gmv usd of confirmed orders in last 180 days'
    ,buyer_nmv_usd_in_360d decimal(30,10) comment 'gmv usd of confirmed orders in last 360 days'
    ,buyer_spl_exclude_nmv_usd_in_14d decimal(30,10) comment 'gmv usd of confirmed spl excluded orders in last 14 days'
    ,buyer_spl_exclude_nmv_usd_in_30d decimal(30,10) comment 'gmv usd of confirmed spl excluded orders in last 30 days'
    ,buyer_spl_exclude_nmv_usd_in_60d decimal(30,10) comment 'gmv usd of confirmed spl excluded orders in last 60 days'
    ,buyer_spl_exclude_nmv_usd_in_90d decimal(30,10) comment 'gmv usd of confirmed spl excluded orders in last 90 days'
    ,buyer_spl_exclude_nmv_usd_in_180d decimal(30,10) comment 'gmv usd of confirmed spl excluded orders in last 180 days'
    ,buyer_spl_exclude_nmv_usd_in_360d decimal(30,10) comment 'gmv usd of confirmed spl excluded orders in last 360 days'
    ,buyer_abs_usd_in_14d decimal(30,10) comment 'abs usd of confirmed order in last 14 days'
    ,buyer_abs_usd_in_30d decimal(30,10) comment 'abs usd of confirmed order in last 30 days'
    ,buyer_abs_usd_in_60d decimal(30,10) comment 'abs usd of confirmed order in last 60 days'
    ,buyer_abs_usd_in_90d decimal(30,10) comment 'abs usd of confirmed order in last 90 days'
    ,buyer_abs_usd_in_180d decimal(30,10) comment 'abs usd of confirmed order in last 180 days'
    ,buyer_abs_usd_in_lifetime decimal(30,10) comment 'abs usd of confirmed order in lifetime'
)
partitioned by
(
    tz_type        string          comment         'timezone type'
    ,grass_region   string          comment         'partition key'
    ,grass_date     string            comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dws/ads_risk_buyer_txn_df';
msck repair table ${SCHEMA}.ads_risk_buyer_txn_df;