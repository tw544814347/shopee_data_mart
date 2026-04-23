drop table if exists ${SCHEMA}.dws_risk_id_fes_seller_linkage_txn_df;
create external table if not exists ${SCHEMA}.dws_risk_id_fes_seller_linkage_txn_df
(
    seller_user_id string
    ,linkage_type string
    ,estimated_escrow_order_cnt bigint
    ,estimated_escrow_amount decimal(30, 10)
    ,estimated_escrow_order_cnt_ratio double
    ,estimated_escrow_amount_ratio double
) 
partitioned by
(
    grass_date string comment 'YYYY-MM-dd'
)
stored as orc
tblproperties
(
    "orc.compress" = "zstd"
)
location '${HDFS_PATH}/risk_mart/dws/dws_risk_fes_seller_linkage_txn_df/grass_region=ID';
msck repair table ${SCHEMA}.dws_risk_id_fes_seller_linkage_txn_df;

