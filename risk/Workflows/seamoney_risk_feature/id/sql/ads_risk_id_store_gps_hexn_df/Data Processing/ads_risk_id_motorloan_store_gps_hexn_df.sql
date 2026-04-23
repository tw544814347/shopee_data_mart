--********************************************************************--
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-07-10
-- Theme Domain：       Store Behavior
-- Description:         https://jira.shopee.io/browse/SPFDT-53379
-- Data Granularity:    
--********************************************************************--


create or replace temporary function geo_to_h3 as 'com.shopee.udf.Geo2H3UDF' 
using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-tool-udf-1.0-SNAPSHOT-jar-with-dependencies.jar'
;

--DROP TABLE IF EXISTS ${SCHEMA}.ads_risk_id_motorloan_store_gps_hexn_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_id_motorloan_store_gps_hexn_df
(
    hex_gps string comment 'hexn', 
    row_key string comment 'hexn_gpshexn',
    store_gps_list string comment 'array set of {store_id & GPS_lat_lng_list}'
)
PARTITIONED BY
(
 grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_risk_id_motorloan_store_gps_hexn_df';
--MSCK REPAIR TABLE ${SCHEMA}.ads_risk_id_motorloan_store_gps_hexn_df;


with hexn_view as (
select 
    geo_to_h3(gps_latitude, gps_longitude, 5) as hex5,
    geo_to_h3(gps_latitude, gps_longitude, 6) as hex6,
    geo_to_h3(gps_latitude, gps_longitude, 7) as hex7,
    geo_to_h3(gps_latitude, gps_longitude, 8) as hex8,
    geo_to_h3(gps_latitude, gps_longitude, 9) as hex9,
    geo_to_h3(gps_latitude, gps_longitude, 10) as hex10,
    store_id,
    gps_latitude,
    gps_longitude,
    status
from smcdrisk_antifraud.f_id_2w_offline_store_whitelist
where gps_latitude is not null and gps_longitude is not null 
)

insert overwrite table risk.ads_risk_id_motorloan_store_gps_hexn_df partition (grass_date = '${grass_date}')


select hex_gps,
       row_key,
       to_json(store_gps_list) as store_gps_list
from 
(
select 
    hex10 as hex_gps,
    concat('motorloan', '_', hex10, '_', 'gpshex10') as row_key,
    collect_set(
        named_struct(
        'store_id', store_id,
        'gps_list', array(gps_latitude, gps_longitude),
        'status', status
        )
    ) as store_gps_list
from hexn_view
group by 1,2

union all

select 
    hex9 as hex_gps,
    concat('motorloan', '_', hex9, '_', 'gpshex9') as row_key,
    collect_set(
        named_struct(
        'store_id', store_id,
        'gps_list', array(gps_latitude, gps_longitude),
        'status', status
        )
    ) as store_gps_list
from hexn_view
group by 1,2

union all

select 
    hex8 as hex_gps,
    concat('motorloan', '_', hex8, '_', 'gpshex8') as row_key,
    collect_set(
        named_struct(
        'store_id', store_id,
        'gps_list', array(gps_latitude, gps_longitude),
        'status', status
        )
    ) as store_gps_list
from hexn_view
group by 1,2

union all

select 
    hex7 as hex_gps,
    concat('motorloan', '_', hex7, '_', 'gpshex7') as row_key,
    collect_set(
        named_struct(
        'store_id', store_id,
        'gps_list', array(gps_latitude, gps_longitude),
        'status', status
        )
    ) as store_gps_list
from hexn_view
group by 1,2

union all

select 
    hex6 as hex_gps, 
    concat('motorloan', '_', hex6, '_', 'gpshex6') as row_key,
    collect_set(
        named_struct(
        'store_id', store_id,
        'gps_list', array(gps_latitude, gps_longitude),
        'status', status
        )
    ) as store_gps_list
from hexn_view
group by 1,2

union all

select 
    hex5 as hex_gps, 
    concat('motorloan', '_', hex5, '_', 'gpshex5') as row_key,
    collect_set(
        named_struct(
        'store_id', store_id,
        'gps_list', array(gps_latitude, gps_longitude),
        'status', status
        )
    ) as store_gps_list
from hexn_view
group by 1,2
)
;