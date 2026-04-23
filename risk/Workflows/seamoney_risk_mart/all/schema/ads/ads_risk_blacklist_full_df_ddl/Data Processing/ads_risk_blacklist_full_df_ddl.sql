drop table if exists ${SCHEMA}.ads_risk_blacklist_full_df;
create external table if not exists ${SCHEMA}.ads_risk_blacklist_full_df
(
    data            string 
    ,datatype       string 
    ,remark         string 
    ,description    string 
    ,status         string 
    ,grass_region   string 
    ,table_name     string
    ,grass_date     string 
     
)
partitioned by
(   
    grass_region  
    ,table_name
    ,grass_date 
    
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/ads/ads_risk_blacklist_full_df';
msck repair table ${SCHEMA}.ads_risk_blacklist_full_df;