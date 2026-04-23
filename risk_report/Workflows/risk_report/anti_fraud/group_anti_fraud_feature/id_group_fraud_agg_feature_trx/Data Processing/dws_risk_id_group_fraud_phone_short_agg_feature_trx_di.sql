--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-08-20
-- Theme Domain：       Anti-fraud 日志数据策略feature - dws 层
-- Description:         https://jira.shopee.io/browse/SPFDT-54753
-- Data Granularity:    
-- Change Log:
--********************************************************************--

DROP TABLE IF EXISTS risk_report.dws_risk_${reg}_group_fraud_reg_phone_short_agg_feature_trx_di;
CREATE TABLE risk_report.dws_risk_${reg}_group_fraud_reg_phone_short_agg_feature_trx_di (
    flow_no STRING COMMENT '流水号',

    -- 请求用户数特征（req系列）
    reg_phone_reg_req_1hr BIGINT COMMENT '近1小时内的不同用户注册请求数',
    reg_phone_reg_req_3hr BIGINT COMMENT '近3小时内的不同用户注册请求数',
    reg_phone_reg_req_12hr BIGINT COMMENT '近12小时内的不同用户注册请求数',
    reg_phone_reg_req_24hr BIGINT COMMENT '近24小时内的不同用户注册请求数',
    reg_phone_reg_req_2d BIGINT COMMENT '近2天内的不同用户注册请求数',
    reg_phone_reg_req_7d BIGINT COMMENT '近7天内的不同用户注册请求数',
    reg_phone_reg_req_15d BIGINT COMMENT '近15天内的不同用户注册请求数',

    -- 激活用户数特征（act系列）
    reg_phone_reg_trx_1hr BIGINT COMMENT '近1小时内的不同用户注册激活数',
    reg_phone_reg_trx_3hr BIGINT COMMENT '近3小时内的不同用户注册激活数',
    reg_phone_reg_trx_12hr BIGINT COMMENT '近12小时内的不同用户注册激活数',
    reg_phone_reg_trx_24hr BIGINT COMMENT '近24小时内的不同用户注册激活数',
    reg_phone_reg_trx_2d BIGINT COMMENT '近2天内的不同用户注册激活数',
    reg_phone_reg_trx_7d BIGINT COMMENT '近7天内的不同用户注册激活数',
    reg_phone_reg_trx_15d BIGINT COMMENT '近15天内的不同用户注册激活数',

    -- 批量注册请求用户数特征（req_batch系列）
    reg_phone_reg_req_batch_1hr BIGINT COMMENT '近1小时内的不同批量注册用户请求数',
    reg_phone_reg_req_batch_3hr BIGINT COMMENT '近3小时内的不同批量注册用户请求数',
    reg_phone_reg_req_batch_12hr BIGINT COMMENT '近12小时内的不同批量注册用户请求数',
    reg_phone_reg_req_batch_24hr BIGINT COMMENT '近24小时内的不同批量注册用户请求数',
    reg_phone_reg_req_batch_2d BIGINT COMMENT '近2天内的不同批量注册用户请求数',
    reg_phone_reg_req_batch_7d BIGINT COMMENT '近7天内的不同批量注册用户请求数',
    reg_phone_reg_req_batch_15d BIGINT COMMENT '近15天内的不同批量注册用户请求数',

    -- 批量注册激活用户数特征（trx_batch系列）
    reg_phone_reg_trx_batch_1hr BIGINT COMMENT '近1小时内的不同批量注册用户激活数',
    reg_phone_reg_trx_batch_3hr BIGINT COMMENT '近3小时内的不同批量注册用户激活数',
    reg_phone_reg_trx_batch_12hr BIGINT COMMENT '近12小时内的不同批量注册用户激活数',
    reg_phone_reg_trx_batch_24hr BIGINT COMMENT '近24小时内的不同批量注册用户激活数',
    reg_phone_reg_trx_batch_2d BIGINT COMMENT '近2天内的不同批量注册用户激活数',
    reg_phone_reg_trx_batch_7d BIGINT COMMENT '近7天内的不同批量注册用户激活数',
    reg_phone_reg_trx_batch_15d BIGINT COMMENT '近15天内的不同批量注册用户激活数'
)
COMMENT 'risk mart summary table'
PARTITIONED BY (
   grass_date STRING
)
STORED AS parquet
tblproperties
(
    "orc.compress" = "zstd"
)
location '${HDFS_PATH}/dwd/dws_risk_reg_group_fraud_reg_phone_short_agg_feature_trx_di/grass_region=${grass_region}';


with no_reactivate as (
SELECT 
    base.flow_no,
    
    -- 请求用户数特征 (req系列) - 基于精确秒级时间窗口
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 3600  -- 1小时 = 3600秒
            AND base.req_time - h.req_time >= 0
        THEN h.platform_user_id END) AS reg_phone_reg_req_1hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 10800  -- 3小时 = 10800秒
            AND base.req_time - h.req_time >= 0
        THEN h.platform_user_id END) AS reg_phone_reg_req_3hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 43200  -- 12小时 = 43200秒
            AND base.req_time - h.req_time >= 0
        THEN h.platform_user_id END) AS reg_phone_reg_req_12hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 86400  -- 1天 = 86400秒
            AND base.req_time - h.req_time >= 0
        THEN h.platform_user_id END) AS reg_phone_reg_req_24hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 172800  -- 2天 = 172800秒
            AND base.req_time - h.req_time >= 0
        THEN h.platform_user_id END) AS reg_phone_reg_req_2d,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 604800  -- 7天 = 604800秒
            AND base.req_time - h.req_time >= 0
        THEN h.platform_user_id END) AS reg_phone_reg_req_7d,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 1296000  -- 15天 = 1296000秒
            AND base.req_time - h.req_time >= 0
        THEN h.platform_user_id END) AS reg_phone_reg_req_15d,
        
    -- 激活用户数特征 (act系列) - 基于精确秒级时间窗口
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 3600  -- 1小时 = 3600秒
            AND base.req_time - h.req_time >= 0
            AND h.end_result = 'pass'
        THEN h.platform_user_id END) AS reg_phone_reg_trx_1hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 10800  -- 3小时 = 10800秒
            AND base.req_time - h.req_time >= 0
            AND h.end_result = 'pass'
        THEN h.platform_user_id END) AS reg_phone_reg_trx_3hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 43200  -- 12小时 = 43200秒
            AND base.req_time - h.req_time >= 0
            AND h.end_result = 'pass'
        THEN h.platform_user_id END) AS reg_phone_reg_trx_12hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 86400  -- 1天 = 86400秒
            AND base.req_time - h.req_time >= 0
            AND h.end_result = 'pass'
        THEN h.platform_user_id END) AS reg_phone_reg_trx_24hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 172800  -- 2天 = 172800秒
            AND base.req_time - h.req_time >= 0
             
            AND h.end_result = 'pass'
        THEN h.platform_user_id END) AS reg_phone_reg_trx_2d,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 604800  -- 7天 = 604800秒
            AND base.req_time - h.req_time >= 0
            AND h.end_result = 'pass'
        THEN h.platform_user_id END) AS reg_phone_reg_trx_7d,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 1296000  -- 15天 = 1296000秒
            AND base.req_time - h.req_time >= 0
            AND h.end_result = 'pass'
        THEN h.platform_user_id END) AS reg_phone_reg_trx_15d,
  
        COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 3600  -- 1小时 = 3600秒
            AND base.req_time - h.req_time >= 0
            AND h.is_batch_registration = 1
        THEN h.platform_user_id END) AS reg_phone_reg_req_batch_1hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 10800  -- 3小时 = 10800秒
            AND base.req_time - h.req_time >= 0
            AND h.is_batch_registration = 1
        THEN h.platform_user_id END) AS reg_phone_reg_req_batch_3hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 43200  -- 12小时 = 43200秒
            AND base.req_time - h.req_time >= 0
            AND h.is_batch_registration = 1
        THEN h.platform_user_id END) AS reg_phone_reg_req_batch_12hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 86400  -- 1天 = 86400秒
            AND base.req_time - h.req_time >= 0
            AND h.is_batch_registration = 1
        THEN h.platform_user_id END) AS reg_phone_reg_req_batch_24hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 172800  -- 2天 = 172800秒
            AND base.req_time - h.req_time >= 0
            AND h.is_batch_registration = 1
        THEN h.platform_user_id END) AS reg_phone_reg_req_batch_2d,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 604800  -- 7天 = 604800秒
            AND base.req_time - h.req_time >= 0
            AND h.is_batch_registration = 1
        THEN h.platform_user_id END) AS reg_phone_reg_req_batch_7d,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 1296000  -- 15天 = 1296000秒
            AND base.req_time - h.req_time >= 0
            AND h.is_batch_registration = 1
        THEN h.platform_user_id END) AS reg_phone_reg_req_batch_15d,
        
    -- 激活用户数特征 (act系列) - 基于精确秒级时间窗口
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 3600  -- 1小时 = 3600秒
            AND base.req_time - h.req_time >= 0
            AND h.end_result = 'pass'
            AND h.is_batch_registration = 1
        THEN h.platform_user_id END) AS reg_phone_reg_trx_batch_1hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 10800  -- 3小时 = 10800秒
            AND base.req_time - h.req_time >= 0
            AND h.end_result = 'pass'
            AND h.is_batch_registration = 1
        THEN h.platform_user_id END) AS reg_phone_reg_trx_batch_3hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 43200  -- 12小时 = 43200秒
            AND base.req_time - h.req_time >= 0
            AND h.end_result = 'pass'
            AND h.is_batch_registration = 1
        THEN h.platform_user_id END) AS reg_phone_reg_trx_batch_12hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 86400  -- 1天 = 86400秒
            AND base.req_time - h.req_time >= 0
            AND h.end_result = 'pass'
            AND h.is_batch_registration = 1
        THEN h.platform_user_id END) AS reg_phone_reg_trx_batch_24hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 172800  -- 2天 = 172800秒
            AND base.req_time - h.req_time >= 0
            AND h.end_result = 'pass'
            AND h.is_batch_registration = 1
        THEN h.platform_user_id END) AS reg_phone_reg_trx_batch_2d,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 604800  -- 7天 = 604800秒
            AND base.req_time - h.req_time >= 0
            AND h.end_result = 'pass'
            AND h.is_batch_registration = 1
        THEN h.platform_user_id END) AS reg_phone_reg_trx_batch_7d,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 1296000  -- 15天 = 1296000秒
            AND base.req_time - h.req_time >= 0
            AND h.end_result = 'pass'
            AND h.is_batch_registration = 1
        THEN h.platform_user_id END) AS reg_phone_reg_trx_batch_15d

FROM 
(
    select distinct flow_no,platform_user_id,req_time, app_id, scene_id,reg_phone,grass_date
    from risk_report.dwd_risk_${reg}_group_fraud_feature_trx_base_di base
    WHERE base.grass_date = '${ds}'
        AND base.app_id in ('kredit', 'spj', 'spjup') -- bcl/spl/scl
) base
LEFT JOIN 
(   
    select distinct app_id, scene_id, reg_phone, platform_user_id,
        req_time, end_result, is_batch_registration, is_reactivate
    from risk_report.dwd_risk_${reg}_group_fraud_phone_agg_trx_di
    where grass_date >= date('${ds}') - interval '15' day  -- 只需15天数据
        AND grass_date <= '${ds}'
        AND app_id in ('kredit', 'spj', 'spjup') -- bcl/spl/scl
        AND is_reactivate = 0
) as h
ON base.reg_phone = h.reg_phone
    AND if(base.app_id = 'kredit', base.app_id = h.app_id, base.app_id = h.app_id AND base.scene_id = h.scene_id) 
    AND base.platform_user_id != h.platform_user_id
GROUP BY base.flow_no
)

,has_reactivate as (
SELECT 
    base.flow_no,
    
    -- 请求用户数特征 (req系列) - 基于精确秒级时间窗口
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 3600  -- 1小时 = 3600秒
            AND base.req_time - h.req_time >= 0
        THEN h.platform_user_id END) AS reg_phone_reg_req_1hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 10800  -- 3小时 = 10800秒
            AND base.req_time - h.req_time >= 0
        THEN h.platform_user_id END) AS reg_phone_reg_req_3hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 43200  -- 12小时 = 43200秒
            AND base.req_time - h.req_time >= 0
        THEN h.platform_user_id END) AS reg_phone_reg_req_12hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 86400  -- 1天 = 86400秒
            AND base.req_time - h.req_time >= 0
        THEN h.platform_user_id END) AS reg_phone_reg_req_24hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 172800  -- 2天 = 172800秒
            AND base.req_time - h.req_time >= 0
        THEN h.platform_user_id END) AS reg_phone_reg_req_2d,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 604800  -- 7天 = 604800秒
            AND base.req_time - h.req_time >= 0
        THEN h.platform_user_id END) AS reg_phone_reg_req_7d,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 1296000  -- 15天 = 1296000秒
            AND base.req_time - h.req_time >= 0
        THEN h.platform_user_id END) AS reg_phone_reg_req_15d,
    
    -- 激活用户数特征 (act系列) - 1hr~15d
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 3600  -- 1小时 = 3600秒
            AND base.req_time - h.req_time >= 0             
            AND h.end_result = 'pass'
        THEN h.platform_user_id END) AS reg_phone_reg_trx_1hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 10800  -- 3小时 = 10800秒
            AND base.req_time - h.req_time >= 0
            AND h.end_result = 'pass'
        THEN h.platform_user_id END) AS reg_phone_reg_trx_3hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 43200  -- 12小时 = 43200秒
            AND base.req_time - h.req_time >= 0
            AND h.end_result = 'pass'
        THEN h.platform_user_id END) AS reg_phone_reg_trx_12hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 86400  -- 1天 = 86400秒
            AND base.req_time - h.req_time >= 0
            AND h.end_result = 'pass'
        THEN h.platform_user_id END) AS reg_phone_reg_trx_24hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 172800  -- 2天 = 172800秒
            AND base.req_time - h.req_time >= 0
            AND h.end_result = 'pass'
        THEN h.platform_user_id END) AS reg_phone_reg_trx_2d,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 604800  -- 7天 = 604800秒
            AND base.req_time - h.req_time >= 0
            AND h.end_result = 'pass'
        THEN h.platform_user_id END) AS reg_phone_reg_trx_7d,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 1296000  -- 15天 = 1296000秒
            AND base.req_time - h.req_time >= 0     
            AND h.end_result = 'pass'
        THEN h.platform_user_id END) AS reg_phone_reg_trx_15d,
    
    -- 批量注册请求用户数特征 (batch req系列) - 1hr~15d
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 3600  -- 1小时 = 3600秒
            AND base.req_time - h.req_time >= 0
            AND h.is_batch_registration = 1
        THEN h.platform_user_id END) AS reg_phone_reg_req_batch_1hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 10800  -- 3小时 = 10800秒
            AND base.req_time - h.req_time >= 0             
            AND h.is_batch_registration = 1
        THEN h.platform_user_id END) AS reg_phone_reg_req_batch_3hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 43200  -- 12小时 = 43200秒
            AND base.req_time - h.req_time >= 0
            AND h.is_batch_registration = 1
        THEN h.platform_user_id END) AS reg_phone_reg_req_batch_12hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 86400  -- 1天 = 86400秒
            AND base.req_time - h.req_time >= 0
            AND h.is_batch_registration = 1
        THEN h.platform_user_id END) AS reg_phone_reg_req_batch_24hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 172800  -- 2天 = 172800秒
            AND base.req_time - h.req_time >= 0
            AND h.is_batch_registration = 1
        THEN h.platform_user_id END) AS reg_phone_reg_req_batch_2d,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 604800  -- 7天 = 604800秒
            AND base.req_time - h.req_time >= 0
            AND h.is_batch_registration = 1
        THEN h.platform_user_id END) AS reg_phone_reg_req_batch_7d,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 1296000  -- 15天 = 1296000秒
            AND base.req_time - h.req_time >= 0
            AND h.is_batch_registration = 1
        THEN h.platform_user_id END) AS reg_phone_reg_req_batch_15d,
    
    -- 批量注册激活用户数特征 (trx_batch系列) - 1hr~15d
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 3600  -- 1小时 = 3600秒
            AND base.req_time - h.req_time >= 0
            AND h.end_result = 'pass'
            AND h.is_batch_registration = 1
        THEN h.platform_user_id END) AS reg_phone_reg_trx_batch_1hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 10800  -- 3小时 = 10800秒
            AND base.req_time - h.req_time >= 0
            AND h.end_result = 'pass'
            AND h.is_batch_registration = 1
        THEN h.platform_user_id END) AS reg_phone_reg_trx_batch_3hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 43200  -- 12小时 = 43200秒
            AND base.req_time - h.req_time >= 0
            AND h.end_result = 'pass'
            AND h.is_batch_registration = 1
        THEN h.platform_user_id END) AS reg_phone_reg_trx_batch_12hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 86400  -- 1天 = 86400秒
            AND base.req_time - h.req_time >= 0
            AND h.end_result = 'pass'
            AND h.is_batch_registration = 1
        THEN h.platform_user_id END) AS reg_phone_reg_trx_batch_24hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 172800  -- 2天 = 172800秒
            AND base.req_time - h.req_time >= 0
            AND h.end_result = 'pass'
            AND h.is_batch_registration = 1
        THEN h.platform_user_id END) AS reg_phone_reg_trx_batch_2d,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 604800  -- 7天 = 604800秒
            AND base.req_time - h.req_time >= 0
            AND h.end_result = 'pass'
            AND h.is_batch_registration = 1
        THEN h.platform_user_id END) AS reg_phone_reg_trx_batch_7d,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.req_time <= 1296000  -- 15天 = 1296000秒
            AND base.req_time - h.req_time >= 0
            AND h.end_result = 'pass'
            AND h.is_batch_registration = 1
        THEN h.platform_user_id END) AS reg_phone_reg_trx_batch_15d
        
FROM 
(
    select distinct flow_no,platform_user_id,req_time, app_id, scene_id,reg_phone,grass_date
    from risk_report.dwd_risk_${reg}_group_fraud_feature_trx_base_di base
    WHERE base.grass_date = '${ds}'
        AND base.app_id not in ('kredit', 'spj', 'spjup') -- bcl/spl/scl
) base
LEFT JOIN 
(   
    select distinct app_id, scene_id, reg_phone, platform_user_id,
        req_time, end_result, is_batch_registration, is_reactivate
    from risk_report.dwd_risk_${reg}_group_fraud_phone_agg_trx_di
    where grass_date >= date('${ds}') - interval '15' day  -- 只需15天数据
        AND grass_date <= '${ds}'
        AND app_id not in ('kredit', 'spj', 'spjup') -- bcl/spl/scl
) as h
ON base.reg_phone = h.reg_phone
    AND base.app_id = h.app_id
    AND base.scene_id = h.scene_id  
    AND base.platform_user_id != h.platform_user_id
GROUP BY base.flow_no
)

insert overwrite table risk_report.dws_risk_${reg}_group_fraud_reg_phone_short_agg_feature_trx_di partition (grass_date = '${ds}')
SELECT *
FROM has_reactivate
WHERE reg_phone_reg_req_15d > 0 OR reg_phone_reg_trx_15d > 0 OR reg_phone_reg_req_batch_15d > 0 OR reg_phone_reg_trx_batch_15d > 0
union all
SELECT *
FROM no_reactivate
WHERE reg_phone_reg_req_15d > 0 OR reg_phone_reg_trx_15d > 0 OR reg_phone_reg_req_batch_15d > 0 OR reg_phone_reg_trx_batch_15d > 0
;


msck repair table risk_report.dws_risk_${reg}_group_fraud_reg_phone_short_agg_feature_trx_di;
refresh table risk_report.dws_risk_${reg}_group_fraud_reg_phone_short_agg_feature_trx_di;



create or replace view risk_report.dws_risk_${reg}_group_fraud_phone_short_agg_feature_trx_di
COMMENT 'risk mart summary table'
as select * 
from 
risk_report.dws_risk_${reg}_group_fraud_reg_phone_short_agg_feature_trx_di;