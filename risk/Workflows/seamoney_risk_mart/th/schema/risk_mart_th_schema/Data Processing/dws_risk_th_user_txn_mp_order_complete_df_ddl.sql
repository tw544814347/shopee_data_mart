drop table if exists ${SCHEMA}.dws_risk_th_user_txn_mp_order_complete_df;
create external table if not exists ${SCHEMA}.dws_risk_th_user_txn_mp_order_complete_df (
     platform_user_id                                  string     comment 'platform user id'
    ,uw_cod_percent_90d                               double     comment ''
    ,uw_cod_percent_180d                                double     comment ''
    ,uw_cod_percent_360d                                   double     comment ''
    ,uw_abs_usd_360d                               double     comment ''
    ,uw_confirmed_gmv_usd_90d_spl_exclude              double     comment ''
)
partitioned by (
    grass_date                                        string     comment "Partition, YYYY-MM-DD"
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_aio_user_txn_mp_order_complete_df/grass_region=TH';

msck repair table ${SCHEMA}.dws_risk_th_user_txn_mp_order_complete_df;