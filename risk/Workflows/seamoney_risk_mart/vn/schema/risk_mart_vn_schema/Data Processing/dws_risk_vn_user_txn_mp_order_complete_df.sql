drop table if exists ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_complete_df;

create table if not exists ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_complete_df
(
    platform_user_id string comment 'platform_user_id'
    ,buyer_shipping_address_district_cnt_360d bigint comment 'credit not new device list'
    ,most_order_shipping_address_district_360d string comment 'not_new_device_list_szdf_6m'
) 
partitioned by
(
    grass_date string comment 'grass_date, partition key'
)
stored as orc
tblproperties
(
    "orc.compress" = "zstd"
    ,"orc.stripe.size" = "268435456"
)
location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_txn_mp_order_complete_df/grass_region=${grass_region}';

msck repair table ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_complete_df;

