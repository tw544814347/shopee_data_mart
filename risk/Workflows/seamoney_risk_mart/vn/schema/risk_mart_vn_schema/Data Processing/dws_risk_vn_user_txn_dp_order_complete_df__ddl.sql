drop table if exists ${SCHEMA}.dws_risk_${grass_region_lower}_user_txn_dp_order_complete_df;
create external table if not exists ${SCHEMA}.dws_risk_${grass_region_lower}_user_txn_dp_order_complete_df
(
    platform_user_id             string   comment 'platform_user_id'
    ,completed_order_30d         int      comment 'uw_dp_order_in_30d_vn'
    ,completed_order_60d         int      comment 'uw_dp_order_in_60d_vn'
    ,completed_order_90d         int      comment 'uw_dp_order_in_90d_vn'
    ,completed_order_120d        int      comment 'uw_dp_order_in_120d_vn'
    ,completed_order_180d        int      comment 'uw_dp_order_in_180d_vn'
    ,completed_order_360d        int      comment 'uw_dp_order_in_360d_vn'
)
partitioned by
(
    grass_date     string   comment "YYYY-MM-DD"
)
stored as orc tblproperties (
    "orc.compress" = "zstd"
    ,"orc.stripe.size" = "268435456"
)
location '${HDFS_PATH}/risk_mart/dws/dws_risk_aio_user_txn_dp_order_complete_df/garss_region=${grass_region}';

msck repair table ${SCHEMA}.dws_risk_${grass_region_lower}_user_txn_dp_order_complete_df;