create external table if not exists ${SCHEMA}.ads_risk_id_profile_store_df (
    id decimal(20, 0) comment 'store id'
    ,city_id decimal(20, 0) comment 'city id'
    ,city_name string comment 'city name'
    ,gps_latitude decimal(11, 8) comment 'store gps latitude'
    ,gps_longitude decimal(11, 8) comment 'store gps longtitude'
) 
COMMENT 'Tag:risk summary table'
partitioned by (
    grass_date string comment 'YYYY-MM-dd'
) stored as orc tblproperties (
    "orc.compress" = "SNAPPY"
    ,"orc.stripe.size" = "2147483648"
) location '${HDFS_PATH}/risk_feature/ads/ads_risk_profile_store_df/grass_region=ID'
;


insert into risk.ads_risk_id_profile_store_df partition (grass_date = '${ds}')
select  id                              as store_id
        ,city_id                        as city_id
        ,city_name                      as city_name
        ,latitude                       as gps_latitude
        ,longitude                      as gps_longitude
from merchantservice.mss_merchant_info_id_db__store_tab__id_daily_s0_live
;