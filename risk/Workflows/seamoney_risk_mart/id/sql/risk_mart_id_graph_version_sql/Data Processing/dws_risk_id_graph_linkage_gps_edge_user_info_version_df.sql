create or replace temporary function geo_to_h3 as 'com.shopee.udf.Geo2H3UDF' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-tool-udf-1.0-SNAPSHOT-jar-with-dependencies.jar';

create or replace temporary view strategy_raw_data as
SELECT 
    platform_user_id,
    gps_latitude,
    gps_longitude,
    client_ip,
    get_json_object(extension,'$.CommonHeader.extension_process_data.sz_dfp.bssid') as bssid,
    create_time,
    grass_date
FROM risk.dwd_risk_${region}_strategy_final_result_merge_di
WHERE grass_date >= cast(date_sub('${current_grass_date}', 7) as string)
    and grass_date < '${current_grass_date}'
    and date(from_unixtime(create_time)) < '${current_grass_date}'
    AND risk_scene_id IN (10012, 10013, 10014, 10003)
    and platform_user_id <> 0
;

create or replace temporary view registration_raw_data as
SELECT 
    user_id as platform_user_id,
    latitude,
    longitude,
    client_ip,
    dfpinfosz__bssid as bssid,
    ipinfo__proxy_type,
    grass_date
FROM antifraud_dw.dwd_evt_user_registration_di
WHERE grass_region = '${grass_region}' 
    AND grass_date >= date_sub('${current_grass_date}', 7)
    and grass_date < date'${current_grass_date}'
    and user_id <> 0
;

create or replace temporary view login_raw_data as
SELECT 
    user_id as platform_user_id,
    latitude,
    longitude,
    client_ip,
    dfpinfosz__bssid as bssid,
    ipinfo__proxy_type,
    grass_date
FROM antifraud_dw.dwd_evt_shopee_login_di
WHERE grass_region = '${grass_region}' 
    AND grass_date >= date_sub('${current_grass_date}', 1)
    and grass_date < date'${current_grass_date}'
    and user_id <> 0
;

-- ========================================
-- GPS 软连接数据处理（多精度复用版本）
-- ========================================
-- Step 1: Activation场景GPS数据处理（一次性生成3个精度）
create or replace temporary view activation_gps_multi_precision as
SELECT 
    platform_user_id,
    geo_to_h3(gps_latitude, gps_longitude, 10) as gps_hex_10,
    geo_to_h3(gps_latitude, gps_longitude, 11) as gps_hex_11,
    geo_to_h3(gps_latitude, gps_longitude, 12) as gps_hex_12,
    min(date(from_unixtime(create_time))) as create_date,
    max(date(from_unixtime(create_time))) as last_date
FROM strategy_raw_data
WHERE gps_latitude <> ''
    and gps_latitude <> '0'
    AND gps_longitude <> ''
    and gps_longitude <> '0'
GROUP BY 
    platform_user_id, 
    geo_to_h3(gps_latitude, gps_longitude, 10),
    geo_to_h3(gps_latitude, gps_longitude, 11),
    geo_to_h3(gps_latitude, gps_longitude, 12)
;

-- 展开为长表格式（unpivot）
create or replace temporary view activation_gps_raw as
SELECT platform_user_id, gps_hex_10 as gps_hex, create_date, last_date, 10 as h3_precision, 'act' as scene FROM activation_gps_multi_precision WHERE gps_hex_10 IS NOT NULL
UNION ALL
SELECT platform_user_id, gps_hex_11 as gps_hex, create_date, last_date, 11 as h3_precision, 'act' as scene FROM activation_gps_multi_precision WHERE gps_hex_11 IS NOT NULL
UNION ALL
SELECT platform_user_id, gps_hex_12 as gps_hex, create_date, last_date, 12 as h3_precision, 'act' as scene FROM activation_gps_multi_precision WHERE gps_hex_12 IS NOT NULL
;

-- 统一过滤逻辑：所有精度使用相同阈值100
create or replace temporary view activation_gps_limited as
SELECT gps_hex, h3_precision
FROM activation_gps_raw
GROUP BY gps_hex, h3_precision
HAVING count(DISTINCT platform_user_id) <= 100
;

create or replace temporary view activation_gps as
SELECT 
    a.platform_user_id,
    a.gps_hex,
    a.create_date,
    a.last_date,
    a.h3_precision,
    a.scene
FROM activation_gps_raw a
INNER JOIN activation_gps_limited l 
    ON a.gps_hex = l.gps_hex 
    AND a.h3_precision = l.h3_precision
;

-- Step 2: Registration场景GPS数据处理（多精度版本）
create or replace temporary view registration_gps_multi_precision as
SELECT 
    platform_user_id,
    geo_to_h3(cast(latitude as double), cast(longitude as double), 10) as gps_hex_10,
    geo_to_h3(cast(latitude as double), cast(longitude as double), 11) as gps_hex_11,
    geo_to_h3(cast(latitude as double), cast(longitude as double), 12) as gps_hex_12,
    min(grass_date) as create_date,
    max(grass_date) as last_date
FROM registration_raw_data
WHERE latitude <> ''
    and latitude <> '0'
    AND longitude <> ''
    and longitude <> '0'
GROUP BY 
    platform_user_id,
    geo_to_h3(cast(latitude as double), cast(longitude as double), 10),
    geo_to_h3(cast(latitude as double), cast(longitude as double), 11),
    geo_to_h3(cast(latitude as double), cast(longitude as double), 12)
;

create or replace temporary view registration_gps_raw as
SELECT platform_user_id, gps_hex_10 as gps_hex, create_date, last_date, 10 as h3_precision, 'reg' as scene FROM registration_gps_multi_precision WHERE gps_hex_10 IS NOT NULL
UNION ALL
SELECT platform_user_id, gps_hex_11 as gps_hex, create_date, last_date, 11 as h3_precision, 'reg' as scene FROM registration_gps_multi_precision WHERE gps_hex_11 IS NOT NULL
UNION ALL
SELECT platform_user_id, gps_hex_12 as gps_hex, create_date, last_date, 12 as h3_precision, 'reg' as scene FROM registration_gps_multi_precision WHERE gps_hex_12 IS NOT NULL
;

create or replace temporary view registration_gps_limited as
SELECT gps_hex, h3_precision
FROM registration_gps_raw
GROUP BY gps_hex, h3_precision
HAVING count(DISTINCT platform_user_id) <= 100
;

create or replace temporary view registration_gps as
SELECT 
    a.platform_user_id,
    a.gps_hex,
    a.create_date,
    a.last_date,
    a.h3_precision,
    a.scene
FROM registration_gps_raw a
INNER JOIN registration_gps_limited l 
    ON a.gps_hex = l.gps_hex 
    AND a.h3_precision = l.h3_precision
;

-- Step 3: Login场景GPS数据处理（多精度版本，阈值更严格）
create or replace temporary view login_gps_multi_precision as
SELECT 
    platform_user_id,
    geo_to_h3(cast(latitude as double), cast(longitude as double), 10) as gps_hex_10,
    geo_to_h3(cast(latitude as double), cast(longitude as double), 11) as gps_hex_11,
    geo_to_h3(cast(latitude as double), cast(longitude as double), 12) as gps_hex_12,
    min(grass_date) as create_date,
    max(grass_date) as last_date
FROM login_raw_data
WHERE latitude <> ''
    and latitude <> '0'
    and longitude <> ''
    and longitude <> '0'
GROUP BY 
    platform_user_id,
    geo_to_h3(cast(latitude as double), cast(longitude as double), 10),
    geo_to_h3(cast(latitude as double), cast(longitude as double), 11),
    geo_to_h3(cast(latitude as double), cast(longitude as double), 12)
;

create or replace temporary view login_gps_raw as
SELECT platform_user_id, gps_hex_10 as gps_hex, create_date, last_date, 10 as h3_precision, 'login' as scene FROM login_gps_multi_precision WHERE gps_hex_10 IS NOT NULL
UNION ALL
SELECT platform_user_id, gps_hex_11 as gps_hex, create_date, last_date, 11 as h3_precision, 'login' as scene FROM login_gps_multi_precision WHERE gps_hex_11 IS NOT NULL
UNION ALL
SELECT platform_user_id, gps_hex_12 as gps_hex, create_date, last_date, 12 as h3_precision, 'login' as scene FROM login_gps_multi_precision WHERE gps_hex_12 IS NOT NULL
;

create or replace temporary view login_gps_limited as
SELECT gps_hex, h3_precision
FROM login_gps_raw
GROUP BY gps_hex, h3_precision
HAVING count(DISTINCT platform_user_id) <= 50
;

create or replace temporary view login_gps as
SELECT 
    a.platform_user_id,
    a.gps_hex,
    a.create_date,
    a.last_date,
    a.h3_precision,
    a.scene
FROM login_gps_raw a
INNER JOIN login_gps_limited l 
    ON a.gps_hex = l.gps_hex 
    AND a.h3_precision = l.h3_precision
;

-- Step 4: 合并所有已过滤的GPS场景数据（带精度信息）
create or replace temporary view all_gps_filtered as
SELECT platform_user_id, gps_hex, create_date, last_date, h3_precision, scene FROM activation_gps
UNION ALL
SELECT platform_user_id, gps_hex, create_date, last_date, h3_precision, scene FROM registration_gps  
UNION ALL
SELECT platform_user_id, gps_hex, create_date, last_date, h3_precision, scene FROM login_gps
;

-- Step 5: GPS用户关联结果生成（支持多精度）
create or replace temporary view gps_linkage_result as
SELECT 
    concat('userid/', a.platform_user_id) as userid1,
    concat('userid/', b.platform_user_id) as userid2,
    concat('gps_hex', a.h3_precision, '/', a.gps_hex) as linkage_details,
    concat('gps_hex', a.h3_precision, '_', a.scene) as linkage1_type,
    concat('gps_hex', b.h3_precision, '_', b.scene) as linkage2_type,
    a.create_date as linkage1_create_date,
    a.last_date as linkage1_last_date,
    b.create_date as linkage2_create_date,
    b.last_date as linkage2_last_date,
    concat('gps_hex', a.h3_precision) as linkage_type
FROM all_gps_filtered a
INNER JOIN all_gps_filtered b 
    ON a.gps_hex = b.gps_hex
    AND a.h3_precision = b.h3_precision  -- 关键：只关联相同精度的数据
WHERE a.platform_user_id <> b.platform_user_id
;


-- Step 6: 写入结果表（支持多精度：gps_hex10, gps_hex11, gps_hex12）
insert overwrite table ${SCHEMA}.dws_risk_id_graph_linkage_edge_user_info_version_df 
partition(version_name='v2', grass_date='${grass_date}', linkage_type)
select
    userid1 as shopee_user_id,
    userid2 as linkage_shopee_user_id,
    linkage_details,
    linkage1_type,
    linkage2_type,
    linkage1_create_date,
    linkage1_last_date,
    linkage2_create_date,
    linkage2_last_date,
    linkage_type  -- 动态分区字段：gps_hex10/gps_hex11/gps_hex12
from gps_linkage_result
;

