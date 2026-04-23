DROP TABLE IF EXISTS ${SCHEMA}.ads_2bscore_id_user_address_info_nd;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_2bscore_id_user_address_info_nd
(
    user_id             string
    ,shipping_phone     string
    ,normalized_phone   string
    ,zipcode            string
    ,state              string
    ,city               string
    ,district           string 
    ,address            string
    ,order_cnt          bigint
    ,is_self_addr       int
)
PARTITIONED BY
(
	grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="SNAPPY")
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_2bscore_user_address_info_nd/grass_region=ID';
MSCK REPAIR TABLE ${SCHEMA}.ads_2bscore_id_user_address_info_nd;
