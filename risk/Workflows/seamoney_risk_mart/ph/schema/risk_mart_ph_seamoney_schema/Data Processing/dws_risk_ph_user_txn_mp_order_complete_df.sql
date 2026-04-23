drop table if exists ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_complete_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_complete_df
(
platform_user_id                   string               comment 'platform_user_id'   
,pctg_of_cod__order_in_30d         double               comment 'Percentage of Cash-On-Delivery orders in last 30 days	'
,pctg_of_cod__order_in_90d         double               comment 'Percentage of Cash-On-Delivery orders in last 90 days	'
,pctg_of_cod__order_in_180d        double               comment 'Percentage of Cash-On-Delivery orders in last 180 days	'
,pctg_of_cod__order_in_360d        double               comment 'Percentage of Cash-On-Delivery orders in last 3360 days	'
,pctg_of_cod__order_in_lifetime    double               comment 'Percentage of Cash-On-Delivery orders in lifetime	'
)
partitioned by
(
    grass_date     string   comment "YYYY-MM-DD"
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dwd/dws_risk_reg_user_txn_mp_order_complete_df/garss_region=${upper_region}';

msck repair table ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_complete_df;
