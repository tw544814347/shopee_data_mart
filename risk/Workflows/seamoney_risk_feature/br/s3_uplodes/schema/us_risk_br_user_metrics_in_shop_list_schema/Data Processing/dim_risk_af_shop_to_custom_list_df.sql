drop table if exists ${SCHEMA}.dim_risk_af_shop_to_custom_list_df;
create table if not exists ${SCHEMA}.dim_risk_af_shop_to_custom_list_df
(
    shop_id string comment 'unique id of shop'
    ,custom_list_infos string comment 'Merchant list list information collection'
)
partitioned by
(
    grass_region   string          comment         'partition key'
    ,grass_date    string          comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dim/dim_risk_af_shop_to_custom_list_df';
msck repair table ${SCHEMA}.dim_risk_af_shop_to_custom_list_df;