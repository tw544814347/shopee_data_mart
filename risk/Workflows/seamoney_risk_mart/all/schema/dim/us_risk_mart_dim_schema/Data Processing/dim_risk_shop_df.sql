drop table if exists ${SCHEMA}.dim_risk_shop_df;
create external table if not exists ${SCHEMA}.dim_risk_shop_df
(
    shop_id                      bigint comment "PK unique id of the shop"
    ,user_id                     bigint comment "unique userid of the buyer"
    ,is_cross_border_tag         bigint comment "whether shop is cross border"
    ,is_preferred                bigint comment "prefered shop flag"
    ,is_preferred_plus_shop      bigint comment "if shop_id is preferred+ then this flag is 1, else 0"
    ,is_official_store_tag       bigint comment "official shop flag"
    ,is_b2c                      bigint comment "seller b2c flag"
    ,response_rate               double comment "response rate"
    ,rating_star                 double comment "shop star rating"
    ,holiday_mode_on             string comment "seller holiday flag"
    ,shopee_acct_status          bigint comment "shop status"
    ,main_category               string comment "the key main category of the shop based on the count of live items listed by the shop"
    ,sub_category                string comment "the key sub category of the shop based on the live items listed by the shop"
    ,sku                         bigint comment "the total number of active items (status = 1) listed by the shop"
    ,active_item_with_stock_cnt  bigint comment "the sku of active items (status = 1) listed by the shop"
    ,shop_like_cnt_td            bigint comment "total like count from a shop from users who are active"
    ,is_big_seller               int    comment "is big seller"
    ,is_managed_shop             tinyint comment "whether shop is managed or not"
    ,shop_penalty_point          bigint  comment "penalty points of the shop 商家当前penalty分数"
    ,penalty_tier                bigint  comment "penalty tier of the shop based on the shop's penalty points 商家当前penalty级别"
)
partitioned by
(
    tz_type         string          comment         'timezone type'
    ,grass_region   string          comment         'partition key'
    ,grass_date     string          comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dim/dim_risk_shop_df';
msck repair table ${SCHEMA}.dim_risk_shop_df;