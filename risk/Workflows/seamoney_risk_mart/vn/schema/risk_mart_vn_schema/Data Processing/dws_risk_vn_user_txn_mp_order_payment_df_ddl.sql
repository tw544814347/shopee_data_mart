drop table if exists ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_payment_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_payment_df (
    platform_user_id                                  string     comment 'platform user id',
    completed_order_cnt_30d                           bigint     comment 'Completed order count in 30 days',
    completed_order_cnt_90d                           bigint     comment 'Completed order count in 90 days',
    completed_order_cnt_180d                          bigint     comment 'Completed order count in 180 days',
    completed_order_cnt_360d                          bigint     comment 'Completed order count in 160 days',
    cod_order_cnt_30d                                 bigint     comment 'Completed cod order count in 30 days',
    cod_order_cnt_90d                                 bigint     comment 'Completed cod order count in 90 days',
    cod_order_cnt_180d                                bigint     comment 'Completed cod order count in 180 days',
    is_cod_customer                                   bigint     comment 'Is cod customer: 1 true, 0 false',
    completed_order_cnt_by_debit_or_credit_card_30d   bigint     comment 'Completed order count by debit or credit card in 30 days',
    completed_order_cnt_by_debit_or_credit_card_90d   bigint     comment 'Completed order count by debit or credit card in 90 days',
    completed_order_cnt_by_debit_or_credit_card_180d  bigint     comment 'Completed order count by debit or credit card in 180 days',
    completed_order_cnt_by_shopeepay_payment_30d      bigint     comment 'Completed order count by shopeepay payment in 30 days',
    completed_order_cnt_by_shopeepay_payment_90d      bigint     comment 'Completed order count by shopeepay payment in 90 days',
    completed_order_cnt_by_shopeepay_payment_180d     bigint     comment 'Completed order count by shopeepay payment in 180 days',
    completed_order_cnt_by_other_payment_30d          bigint     comment 'Completed order count by other payment in 30 days',
    completed_order_cnt_by_other_payment_90d          bigint     comment 'Completed order count by other payment in 90 days',
    completed_order_cnt_by_other_payment_180d         bigint     comment 'Completed order count by other payment in 180 days',
    payment_channel_used_cnt_30d                      bigint     comment 'Count of payment channel used in 30 days',
    payment_channel_used_cnt_90d                      bigint     comment 'Count of payment channel used in 90 days',
    payment_channel_used_cnt_180d                     bigint     comment 'Count of payment channel used in 180 days',
    uw_repayment_channel_flag                         bigint     comment 'uw_repayment_channel_flag',
    uw_payment_channel                                string     comment 'uw_payment_channel'
)
partitioned by (
    grass_date                                        string     comment "Partition, YYYY-MM-DD"
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_aio_user_txn_mp_order_payment_df/grass_region=${region_uppercase}';

msck repair table ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_payment_df;