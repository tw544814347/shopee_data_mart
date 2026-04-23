drop table if exists ${SCHEMA}.dws_risk_th_user_txn_mp_checkout_df;
create external table if not exists ${SCHEMA}.dws_risk_th_user_txn_mp_checkout_df (
    platform_user_id                        string     comment 'platform user id'
    ,cnt_buyer_pccheckout_frequency          int        comment  'cnt_buyer_pccheckout_frequency'
    ,is_pc_order_0_1m                        int        comment ''
    ,is_pc_order_1_2m                        int        comment ''
    ,is_pc_order_2_3m                        int        comment ''
    ,is_pc_order_3_4m                        int        comment ''
    ,is_pc_order_4_5m                        int        comment ''
    ,is_pc_order_5_6m                        int        comment ''
)
partitioned by (
    grass_date                              string     comment "Partition, YYYY-MM-DD"
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_aio_user_txn_mp_checkout_df/grass_region=TH';

msck repair table ${SCHEMA}.dws_risk_th_user_txn_mp_checkout_df;