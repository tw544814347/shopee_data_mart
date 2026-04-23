drop table if exists ${SCHEMA}.dws_risk_shop_promotion_df;
create external table if not exists ${SCHEMA}.dws_risk_shop_promotion_df
(
    shop_id bigint comment 'unique id of the shop'
    ,discount_last_1m bigint comment 'whether use discount in last 1 month'
    ,discount_last_3m bigint comment 'whether use discount in last 3 month'
    ,voucher_last_1m bigint comment 'whether use voucher in last 1 month'
    ,voucher_last_3m bigint comment 'whether use voucher in last 3 month'
    ,follower_voucher_last_1m bigint comment 'whether use follower voucher in last 1 month'
    ,follower_voucher_last_3m bigint comment 'whether use follower voucher in last 3 month'
    ,top_picks_last_1m bigint comment 'whether use top picks in last 1 month'
    ,top_picks_last_3m bigint comment 'whether use top picks in last 3 month'
    ,bundle_deal_last_1m bigint comment 'whether use buddle deal in last 1 month'
    ,bundle_deal_last_3m bigint comment 'whether use buddle deal in last 3 month'
    ,shipping_fee_last_1m bigint comment 'whether use free shipping in last 1 month'
    ,shipping_fee_last_3m bigint comment 'whether use free shipping in last 3 month'
    ,add_on_deal_last_1m bigint comment 'whether use add on deal in last 1 month'
    ,add_on_deal_last_3m bigint comment 'whether use free shipping in last 3 month'
)
partitioned by
(
    tz_type        string          comment         'timezone type'
    ,grass_region   string          comment         'partition key'
    ,grass_date     string            comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_shop_promotion_df';
msck repair table ${SCHEMA}.dws_risk_shop_promotion_df;