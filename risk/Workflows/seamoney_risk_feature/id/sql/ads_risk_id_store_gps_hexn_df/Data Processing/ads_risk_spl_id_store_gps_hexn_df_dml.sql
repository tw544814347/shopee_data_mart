--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-04-21
-- Theme Domain：       feature
-- Description:         https://jira.shopee.io/browse/SPFDT-51195
-- Data Granularity:    store_id + gps + hexn
-- 变更历史：
--          20250606 by wei.tao https://jira.shopee.io/browse/SPFDT-52558 新增 status 字段
--********************************************************************--

create or replace temporary function geo_to_h3 as 'com.shopee.udf.Geo2H3UDF' 
using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-tool-udf-1.0-SNAPSHOT-jar-with-dependencies.jar'
;

-- DROP TABLE IF EXISTS ${SCHEMA}.ads_risk_spl_id_store_gps_hexn_df;
-- CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_spl_id_store_gps_hexn_df
-- (
--     hex_gps string comment 'hexn', 
--     row_key string comment 'hexn_gpshexn',
--     store_gps_list string comment 'array set of {store_id & GPS_lat_lng_list}'
--     -- size
-- )
-- PARTITIONED BY
-- (
-- 	grass_date string comment 'YYYY-MM-dd'
-- )
-- stored as orc tblproperties ("orc.compress"="zstd")
-- LOCATION '${HDFS_PATH}/risk_feature/ads/ads_risk_spl_id_store_gps_hexn_df';
-- MSCK REPAIR TABLE ${SCHEMA}.ads_risk_spl_id_store_gps_hexn_df;


with hexn_view as (
select 
    case when char_length(gps_latitude) > 0 and char_length(gps_longitude) > 0 then geo_to_h3(gps_latitude, gps_longitude, 5) 
        else null
        end 
        as hex5,
    case when char_length(gps_latitude) > 0 and char_length(gps_longitude) > 0 then geo_to_h3(gps_latitude, gps_longitude, 6) 
        else null
        end 
        as hex6,
    case when char_length(gps_latitude) > 0 and char_length(gps_longitude) > 0 then geo_to_h3(gps_latitude, gps_longitude, 7) 
        else null
        end 
        as hex7,
    case when char_length(gps_latitude) > 0 and char_length(gps_longitude) > 0 then geo_to_h3(gps_latitude, gps_longitude, 8)
        else null
        end 
        as hex8,
    case when char_length(gps_latitude) > 0 and char_length(gps_longitude) > 0 then geo_to_h3(gps_latitude, gps_longitude, 9)
        else null
        end 
        as hex9,
    case when char_length(gps_latitude) > 0 and char_length(gps_longitude) > 0 then geo_to_h3(gps_latitude, gps_longitude, 10)
        else null
        end 
        as hex10,
    store_id,
    gps_latitude,
    gps_longitude,
    status
from smcdrisk_antifraud.f_id_cicilan_store_whitelist_detail  
-- where gps_latitude is not null and gps_longitude is not null 
)

insert overwrite table risk.ads_risk_spl_id_store_gps_hexn_df partition (grass_date = '${grass_date}')


select hex_gps,
       row_key,
       to_json(store_gps_list) as store_gps_list
from 
(
select 
    hex10 as hex_gps,
    concat(hex10, '_', 'gpshex10') as row_key,
    collect_list(
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
    concat(hex9, '_', 'gpshex9') as row_key,
    collect_list(
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
    concat(hex8, '_', 'gpshex8') as row_key,
    collect_list(
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
    concat(hex7, '_', 'gpshex7') as row_key,
    collect_list(
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
    concat(hex6, '_', 'gpshex6') as row_key,
    collect_list(
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
    concat(hex5, '_', 'gpshex5') as row_key,
    collect_list(
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