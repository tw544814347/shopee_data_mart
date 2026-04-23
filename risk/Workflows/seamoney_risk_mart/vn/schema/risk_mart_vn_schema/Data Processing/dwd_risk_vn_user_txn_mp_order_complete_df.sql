drop table if exists ${SCHEMA}.dwd_risk_${region}_user_txn_mp_order_complete_df;
create external table if not exists ${SCHEMA}.dwd_risk_${region}_user_txn_mp_order_complete_df
(

platform_user_id                   string               comment 'platform_user_id'   
,order_id                          bigint               comment 'order_id'
,checkout_id                       bigint               comment 'checkout_id'
,payment_be_channel                string               comment 'payment_be_channel'  
,order_be_status_id                bigint               comment 'order_be_status_id "4 → completed, 11 → escrow paid, 12 → escrow created, 13 → escrow pending, 14 → escrow verified, 15 → escrow payout"'  
,buyer_shipping_address_district   string               comment 'property@buyer shipping district'  
,shipping_confirm_timestamp        bigint               comment 'property@shipping confirm timestamp. For cash on delivery (COD) order: time when the order is placed. For non-COD order: time when the order is paid' 
,shipping_confirm_time_local       string               comment 'property@shipping confirm timestamp. For cash on delivery (COD) order: time when the order is placed. For non-COD order: time when the order is paid'  
,is_bi_excluded                    bigint               comment 'tag@is_bi excluded'  
)
partitioned by
(
    grass_date     string   comment "YYYY-MM-DD"
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_aio_user_txn_mp_order_complete_df/garss_region=${upper_region}';

msck repair table ${SCHEMA}.dwd_risk_${region}_user_txn_mp_order_complete_df;
