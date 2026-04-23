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
-- IP 软连接数据处理
-- ========================================

-- Step 1: Activation场景IP地址数据处理（独立过滤逻辑）
create or replace temporary view activation_ip_raw as
SELECT 
    platform_user_id,
    client_ip,
    min(date(from_unixtime(create_time))) as create_date,
    max(date(from_unixtime(create_time))) as last_date
FROM strategy_raw_data
WHERE client_ip <> ''
GROUP BY platform_user_id, client_ip
;

create or replace temporary view activation_ip_limited as
SELECT client_ip
FROM activation_ip_raw
GROUP BY client_ip
HAVING count(DISTINCT platform_user_id) <= 100
;

create or replace temporary view activation_ip as
SELECT 
    a.platform_user_id,
    a.client_ip,
    a.create_date,
    a.last_date,
    'act' as scene
FROM activation_ip_raw a
INNER JOIN activation_ip_limited l ON a.client_ip = l.client_ip
;

-- Step 2: Registration场景IP地址数据处理（独立过滤逻辑）
create or replace temporary view registration_ip_raw as
SELECT 
    platform_user_id,
    client_ip,
    min(grass_date) as create_date,
    max(grass_date) as last_date
FROM registration_raw_data
WHERE client_ip <> ''
and ipinfo__proxy_type not in ('DCH', 'VPN')
GROUP BY platform_user_id, client_ip
;

create or replace temporary view registration_ip_limited as
SELECT client_ip
FROM registration_ip_raw
GROUP BY client_ip
HAVING count(DISTINCT platform_user_id) <= 100
;

create or replace temporary view registration_ip as
SELECT 
    a.platform_user_id,
    a.client_ip,
    a.create_date,
    a.last_date,
    'reg' as scene
FROM registration_ip_raw a
INNER JOIN registration_ip_limited l ON a.client_ip = l.client_ip
;

-- Step 3: Login场景IP地址数据处理（独立过滤逻辑）
create or replace temporary view login_ip_raw as
SELECT 
    platform_user_id,
    client_ip,
    min(grass_date) as create_date,
    max(grass_date) as last_date
FROM login_raw_data
WHERE client_ip <> ''
and ipinfo__proxy_type not in ('DCH', 'VPN')
GROUP BY platform_user_id, client_ip
;

create or replace temporary view login_ip_limited as
SELECT client_ip
FROM login_ip_raw
GROUP BY client_ip
HAVING count(DISTINCT platform_user_id) <= 50
;

create or replace temporary view login_ip as
SELECT 
    a.platform_user_id,
    a.client_ip,
    a.create_date,
    a.last_date,
    'login' as scene
FROM login_ip_raw a
INNER JOIN login_ip_limited l ON a.client_ip = l.client_ip
;

-- Step 4: 合并所有已过滤的IP场景数据
create or replace temporary view all_ip_filtered as
SELECT platform_user_id, client_ip, create_date, last_date, scene FROM activation_ip
UNION ALL
SELECT platform_user_id, client_ip, create_date, last_date, scene FROM registration_ip  
UNION ALL
SELECT platform_user_id, client_ip, create_date, last_date, scene FROM login_ip
;

-- Step 5: IP用户关联结果生成
create or replace temporary view ip_linkage_result as
SELECT 
    concat('userid/', a.platform_user_id) as userid1,
    concat('userid/', b.platform_user_id) as userid2,
    concat('ipadd/', a.client_ip) as linkage_details,
    concat('ipadd_', a.scene) as linkage1_type,
    concat('ipadd_', b.scene) as linkage2_type,
    a.create_date as linkage1_create_date,
    a.last_date as linkage1_last_date,
    b.create_date as linkage2_create_date,
    b.last_date as linkage2_last_date,
    'ipadd' as linkage_type
FROM all_ip_filtered a
INNER JOIN all_ip_filtered b 
    ON a.client_ip = b.client_ip
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
from ip_linkage_result
;

