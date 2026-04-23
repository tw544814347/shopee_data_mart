DROP TABLE IF EXISTS ${SCHEMA}.dws_risk_spp_txn_hex_di;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dws_risk_spp_txn_hex_di
(
user_id string
,transaction_id string
,storeid string
,payment_channel_name string
,payment_method_name string
,location string
,location_status string
,latitude double
,longitude double
,gps_hex_1 string
,gps_hex_2 string
,gps_hex_3 string
,gps_hex_4 string
,gps_hex_5 string
,gps_hex_6 string
,gps_hex_7 string
,gps_hex_8 string
,gps_hex_9 string
,gps_hex_10 string
,create_time string
)
partitioned by
(
    grass_region   string          comment         'partition key'
    ,grass_date     string          comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_spp_txn_hex_di';
msck repair table ${SCHEMA}.dws_risk_spp_txn_hex_di;