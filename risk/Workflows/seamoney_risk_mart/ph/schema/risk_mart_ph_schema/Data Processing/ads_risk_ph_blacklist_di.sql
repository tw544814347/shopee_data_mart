drop table if exists ${SCHEMA}.ads_risk_ph_blacklist_di;
create external table if not exists ${SCHEMA}.ads_risk_ph_blacklist_di
(
    data            string 
    ,datatype       string 
    ,remark         string 
    ,description    string 
    ,status         string 
    ,grass_region   string 
    ,grass_date     string 
    ,table_name     string 
)
partitioned by
(   grass_region  
    ,grass_date 
    ,table_name
)
comment 'Tag:risk summary table'
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
location '${HDFS_PATH}/risk_mart/ads/ads_risk_ph_blacklist_di';
msck repair table ${SCHEMA}.ads_risk_ph_blacklist_di;