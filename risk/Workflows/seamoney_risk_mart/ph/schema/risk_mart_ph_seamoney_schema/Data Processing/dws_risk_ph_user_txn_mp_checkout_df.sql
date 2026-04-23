drop table if exists ${SCHEMA}.dws_risk_${region}_user_txn_mp_checkout_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_txn_mp_checkout_df (
    platform_user_id                        string     comment 'platform user id',
    webcheckout_escrow_paid_order_cnt_30d   bigint     comment 'Escrow paid order cnt in 30 days',
    webcheckout_escrow_paid_order_cnt_60d   bigint     comment 'Escrow paid order cnt in 60 days',
    webcheckout_escrow_paid_order_cnt_90d   bigint     comment 'Escrow paid order cnt in 90 days',
    webcheckout_escrow_paid_order_cnt_120d  bigint     comment 'Escrow paid order cnt in 120 days',
    webcheckout_escrow_paid_order_cnt_150d  bigint     comment 'Escrow paid order cnt in 150 days',
    webcheckout_escrow_paid_order_cnt_180d  bigint     comment 'Escrow paid order cnt in 180 days',
    user_webcheckout_frequency_180d         bigint     comment 'cnt_buyer_webcheckout_frequency'
)
partitioned by (
    grass_date                              string     comment "Partition, YYYY-MM-DD"
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_aio_user_txn_mp_checkout_df/grass_region=${region_uppercase}';

msck repair table ${SCHEMA}.dws_risk_${region}_user_txn_mp_checkout_df;