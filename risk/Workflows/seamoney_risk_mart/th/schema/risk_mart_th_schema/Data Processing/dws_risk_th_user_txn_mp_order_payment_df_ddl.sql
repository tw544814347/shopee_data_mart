drop table if exists ${SCHEMA}.dws_risk_th_user_txn_mp_order_payment_df;
create external table if not exists ${SCHEMA}.dws_risk_th_user_txn_mp_order_payment_df (
    platform_user_id                                  string     comment 'platform user id',
    uw_repayment_channel_flag                         bigint     comment 'uw_repayment_channel_flag',
    uw_payment_channel                                string     comment 'uw_payment_channel',
    uw_payment_channel_code                           bigint     comment 'uw_payment_channel_code'
)
partitioned by (
    grass_date                                        string     comment "Partition, YYYY-MM-DD"
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_aio_user_txn_mp_order_payment_df/grass_region=TH';

msck repair table ${SCHEMA}.dws_risk_th_user_txn_mp_order_payment_df;