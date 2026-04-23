drop table if exists ${SCHEMA}.dws_shop_escrowpaid_nmv_nd;
create external table if not exists ${SCHEMA}.dws_shop_escrowpaid_nmv_nd
(
shop_id     bigint
,platform_user_id     String
,escrowpaid_order_cnt_in_7d     int
,escrowpaid_order_cnt_in_15d     int
,escrowpaid_order_cnt_in_30d     int
,escrowpaid_order_cnt_in_60d     int
,escrowpaid_order_cnt_in_90d     int
,escrowpaid_order_cnt_in_180d     int
,escrowpaid_nmv_in_7d      decimal(30,10)
,escrowpaid_nmv_in_15d     decimal(30,10)
,escrowpaid_nmv_in_30d     decimal(30,10)
,escrowpaid_nmv_in_31_60d     decimal(30,10)
,escrowpaid_nmv_in_61_90d     decimal(30,10)
,escrowpaid_nmv_in_91_120d     decimal(30,10)
,escrowpaid_nmv_in_121_150d     decimal(30,10)
,escrowpaid_nmv_in_151_180d     decimal(30,10)
,escrowpaid_nmv_in_181_210d     decimal(30,10)
,escrowpaid_weighted_monthly_nmv     decimal(30,10)
,escrowpaid_weighted_nmv_l1m  decimal(30,10)
,escrowpaid_nmv_usd_in_7d     decimal(30,10)
,escrowpaid_nmv_usd_in_15d     decimal(30,10)
,escrowpaid_nmv_usd_in_30d     decimal(30,10)
,escrowpaid_nmv_usd_in_31_60d     decimal(30,10)
,escrowpaid_nmv_usd_in_60d        decimal(30,10)
,escrowpaid_nmv_usd_in_61_90d     decimal(30,10)
,escrowpaid_nmv_usd_in_90d          decimal(30,10)
,escrowpaid_nmv_usd_in_91_120d     decimal(30,10)
,escrowpaid_nmv_usd_in_121_150d     decimal(30,10)
,escrowpaid_nmv_usd_in_151_180d     decimal(30,10)
,escrowpaid_nmv_usd_in_181_210d     decimal(30,10)
,escrowpaid_weighted_monthly_nmv_usd     decimal(30,10)
,escrowpaid_weighted_nmv_usd_l1m     decimal(30,10)
,avg_escrowpaid_nmv_l3m decimal(30,10)
,avg_escrowpaid_nmv_l6m decimal(30,10)
,daily_escrow_l6m_75pctl decimal(30,10)
)
partitioned by
(
    grass_region   string         
    ,grass_date     string         
)
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dws/dws_shop_escrowpaid_nmv_nd';
msck repair table ${SCHEMA}.dws_shop_escrowpaid_nmv_nd;
