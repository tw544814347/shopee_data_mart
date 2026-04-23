drop table if exists ${SCHEMA}.dws_risk_user_city_name_nd;
create external table if not exists ${SCHEMA}.dws_risk_user_city_name_nd
(
    user_id	                                           bigint  comment 'shopee user id'
    ,frequency_city_name_list_6m_new                       string  comment 'frequency city name list'
    
)
comment 'the address user configured'
partitioned by
(
    grass_region   string          comment         'partition key'
    ,grass_date     string            comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_city_name_nd';
msck repair table ${SCHEMA}.dws_risk_user_city_name_nd;