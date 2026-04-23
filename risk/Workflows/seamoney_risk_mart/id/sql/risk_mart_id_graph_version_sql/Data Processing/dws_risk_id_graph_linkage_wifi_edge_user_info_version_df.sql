--DROP TABLE IF EXISTS ${SCHEMA}.dws_risk_id_graph_linkage_edge_user_info_version_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dws_risk_id_graph_linkage_edge_user_info_version_df
(
    shopee_user_id              string comment 'source vertex',
    linkage_shopee_user_id      string comment 'linkage_shopee_user_id',
    linkage_details             string comment 'linkage_details',
    linkage1_type               string comment 'linkage1_type',
    linkage2_type               string comment 'linkage2_type',
    linkage1_create_date        string comment 'linkage1_create_date',
    linkage1_last_date          string comment 'linkage1_last_date',
    linkage2_create_date        string comment 'linkage2_create_date',
    linkage2_last_date          string comment 'linkage2_last_date'
)
comment 'Risk Graph Data User Linkage Edge'
partitioned by
(
    version_name string comment 'version_name',
    grass_date string comment 'partition key, yyyy-MM-dd',
    linkage_type string comment 'linkage_type, gps/ipaddr/wifi etc.'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_graph_linkage_edge_user_info_version_df/grass_region=${grass_region}';
--MSCK REPAIR TABLE ${SCHEMA}.dws_risk_id_graph_linkage_edge_user_info_version_df;

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
-- WiFi 软连接数据处理
-- ========================================

-- Step 1: Activation场景WiFi BSSID数据处理（独立过滤逻辑）
create or replace temporary view activation_wifi_raw as
SELECT 
    platform_user_id,
    bssid,
    min(date(from_unixtime(create_time))) as create_date,
    max(date(from_unixtime(create_time))) as last_date
FROM strategy_raw_data
WHERE bssid IS NOT NULL 
    AND bssid <> ''
GROUP BY platform_user_id, bssid
;

create or replace temporary view activation_wifi_limited as
SELECT bssid
FROM activation_wifi_raw
GROUP BY bssid
HAVING count(DISTINCT platform_user_id) <= 100
;

create or replace temporary view activation_wifi as
SELECT 
    a.platform_user_id,
    a.bssid,
    a.create_date,
    a.last_date,
    'act' as scene
FROM activation_wifi_raw a
INNER JOIN activation_wifi_limited l ON a.bssid = l.bssid
;

-- Step 2: Registration场景WiFi BSSID数据处理（独立过滤逻辑）
create or replace temporary view registration_wifi_raw as
SELECT 
    platform_user_id,
    bssid,
    min(grass_date) as create_date,
    max(grass_date) as last_date
FROM registration_raw_data
WHERE bssid <> ''
GROUP BY platform_user_id, bssid
;

create or replace temporary view registration_wifi_limited as
SELECT bssid
FROM registration_wifi_raw
GROUP BY bssid
HAVING count(DISTINCT platform_user_id) <= 100
;

create or replace temporary view registration_wifi as
SELECT 
    a.platform_user_id,
    a.bssid,
    a.create_date,
    a.last_date,
    'reg' as scene
FROM registration_wifi_raw a
INNER JOIN registration_wifi_limited l ON a.bssid = l.bssid
;

-- Step 3: Login场景WiFi BSSID数据处理（独立过滤逻辑）
create or replace temporary view login_wifi_raw as
SELECT 
    platform_user_id,
    bssid,
    min(grass_date) as create_date,
    max(grass_date) as last_date
FROM login_raw_data
WHERE bssid IS NOT NULL 
    AND bssid <> ''
GROUP BY platform_user_id, bssid
;

create or replace temporary view login_wifi_limited as
SELECT bssid
FROM login_wifi_raw
GROUP BY bssid
HAVING count(DISTINCT platform_user_id) <= 50
;

create or replace temporary view login_wifi as
SELECT 
    a.platform_user_id,
    a.bssid,
    a.create_date,
    a.last_date,
    'login' as scene
FROM login_wifi_raw a
INNER JOIN login_wifi_limited l ON a.bssid = l.bssid
;

-- Step 4: 合并所有已过滤的WiFi场景数据
create or replace temporary view all_wifi_filtered as
SELECT platform_user_id, bssid, create_date, last_date, scene FROM activation_wifi
UNION ALL
SELECT platform_user_id, bssid, create_date, last_date, scene FROM registration_wifi  
UNION ALL
SELECT platform_user_id, bssid, create_date, last_date, scene FROM login_wifi
;

-- Step 5: WiFi用户关联结果生成
create or replace temporary view wifi_linkage_result as
SELECT 
    concat('userid/', a.platform_user_id) as userid1,
    concat('userid/', b.platform_user_id) as userid2,
    concat('wifi/', a.bssid) as linkage_details,
    concat('wifi_', a.scene) as linkage1_type,
    concat('wifi_', b.scene) as linkage2_type,
    a.create_date as linkage1_create_date,
    a.last_date as linkage1_last_date,
    b.create_date as linkage2_create_date,
    b.last_date as linkage2_last_date,
    'wifi' as linkage_type
FROM all_wifi_filtered a
INNER JOIN all_wifi_filtered b 
    ON a.bssid = b.bssid
where a.platform_user_id <> b.platform_user_id
;

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
    linkage_type
from wifi_linkage_result
;

