--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-08-20
-- Theme Domain：       Anti-fraud 日志数据策略feature - dws 层
-- Description:         https://jira.shopee.io/browse/SPFDT-54753
-- Data Granularity:    
-- Change Log:
--********************************************************************--

DROP TABLE IF EXISTS risk_report.dws_risk_${reg}_group_fraud_ip3_short_agg_feature_trx_di;
CREATE TABLE risk_report.dws_risk_${reg}_group_fraud_ip3_short_agg_feature_trx_di (
    flow_no STRING COMMENT '流水号',

    -- 请求用户数特征（req系列）
    ip3_reg_req_1hr BIGINT COMMENT '近1小时内的不同用户注册请求数',
    ip3_reg_req_3hr BIGINT COMMENT '近3小时内的不同用户注册请求数',
    ip3_reg_req_12hr BIGINT COMMENT '近12小时内的不同用户注册请求数',
    ip3_reg_req_24hr BIGINT COMMENT '近24小时内的不同用户注册请求数',
    ip3_reg_req_2d BIGINT COMMENT '近2天内的不同用户注册请求数',
    ip3_reg_req_7d BIGINT COMMENT '近7天内的不同用户注册请求数',
    ip3_reg_req_15d BIGINT COMMENT '近15天内的不同用户注册请求数',

    -- 激活用户数特征（act系列）
    ip3_reg_trx_1hr BIGINT COMMENT '近1小时内的不同用户注册激活数',
    ip3_reg_trx_3hr BIGINT COMMENT '近3小时内的不同用户注册激活数',
    ip3_reg_trx_12hr BIGINT COMMENT '近12小时内的不同用户注册激活数',
    ip3_reg_trx_24hr BIGINT COMMENT '近24小时内的不同用户注册激活数',
    ip3_reg_trx_2d BIGINT COMMENT '近2天内的不同用户注册激活数',
    ip3_reg_trx_7d BIGINT COMMENT '近7天内的不同用户注册激活数',
    ip3_reg_trx_15d BIGINT COMMENT '近15天内的不同用户注册激活数',

    -- 批量注册请求用户数特征（req_batch系列）
    ip3_reg_req_batch_1hr BIGINT COMMENT '近1小时内的不同批量注册用户请求数',
    ip3_reg_req_batch_3hr BIGINT COMMENT '近3小时内的不同批量注册用户请求数',
    ip3_reg_req_batch_12hr BIGINT COMMENT '近12小时内的不同批量注册用户请求数',
    ip3_reg_req_batch_24hr BIGINT COMMENT '近24小时内的不同批量注册用户请求数',
    ip3_reg_req_batch_2d BIGINT COMMENT '近2天内的不同批量注册用户请求数',
    ip3_reg_req_batch_7d BIGINT COMMENT '近7天内的不同批量注册用户请求数',
    ip3_reg_req_batch_15d BIGINT COMMENT '近15天内的不同批量注册用户请求数',

    -- 批量注册激活用户数特征（trx_batch系列）
    ip3_reg_trx_batch_1hr BIGINT COMMENT '近1小时内的不同批量注册用户激活数',
    ip3_reg_trx_batch_3hr BIGINT COMMENT '近3小时内的不同批量注册用户激活数',
    ip3_reg_trx_batch_12hr BIGINT COMMENT '近12小时内的不同批量注册用户激活数',
    ip3_reg_trx_batch_24hr BIGINT COMMENT '近24小时内的不同批量注册用户激活数',
    ip3_reg_trx_batch_2d BIGINT COMMENT '近2天内的不同批量注册用户激活数',
    ip3_reg_trx_batch_7d BIGINT COMMENT '近7天内的不同批量注册用户激活数',
    ip3_reg_trx_batch_15d BIGINT COMMENT '近15天内的不同批量注册用户激活数'
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
location '${HDFS_PATH}/dwd/dws_risk_reg_group_fraud_ip3_short_agg_feature_trx_di/grass_region=${grass_region}';


with 
tmp as (
    SELECT 
        flow_no,
        
        -- 请求用户数特征 (req系列) - 基于预计算的时间差
        COUNT(DISTINCT CASE 
            WHEN time_diff_seconds <= 3600 AND time_diff_seconds >= 0  -- 1小时
            THEN hist_platform_user_id END) AS ip3_reg_req_1hr,
            
        COUNT(DISTINCT CASE 
            WHEN time_diff_seconds <= 10800 AND time_diff_seconds >= 0  -- 3小时
            THEN hist_platform_user_id END) AS ip3_reg_req_3hr,
            
        COUNT(DISTINCT CASE 
            WHEN time_diff_seconds <= 43200 AND time_diff_seconds >= 0  -- 12小时
            THEN hist_platform_user_id END) AS ip3_reg_req_12hr,
            
        COUNT(DISTINCT CASE 
            WHEN time_diff_seconds <= 86400 AND time_diff_seconds >= 0  -- 1天
            THEN hist_platform_user_id END) AS ip3_reg_req_24hr,
            
        COUNT(DISTINCT CASE 
            WHEN time_diff_seconds <= 172800 AND time_diff_seconds >= 0  -- 2天
            THEN hist_platform_user_id END) AS ip3_reg_req_2d,
            
        COUNT(DISTINCT CASE 
            WHEN time_diff_seconds <= 604800 AND time_diff_seconds >= 0  -- 7天
            THEN hist_platform_user_id END) AS ip3_reg_req_7d,
            
        COUNT(DISTINCT CASE 
            WHEN time_diff_seconds <= 1296000 AND time_diff_seconds >= 0  -- 15天
            THEN hist_platform_user_id END) AS ip3_reg_req_15d,
            
        -- 激活用户数特征 (trx系列)
        COUNT(DISTINCT CASE 
            WHEN time_diff_seconds <= 3600 AND time_diff_seconds >= 0
                AND hist_end_result = 'pass'
            THEN hist_platform_user_id END) AS ip3_reg_trx_1hr,
            
        COUNT(DISTINCT CASE 
            WHEN time_diff_seconds <= 10800 AND time_diff_seconds >= 0
                AND hist_end_result = 'pass'
            THEN hist_platform_user_id END) AS ip3_reg_trx_3hr,
            
        COUNT(DISTINCT CASE 
            WHEN time_diff_seconds <= 43200 AND time_diff_seconds >= 0
                AND hist_end_result = 'pass'
            THEN hist_platform_user_id END) AS ip3_reg_trx_12hr,
            
        COUNT(DISTINCT CASE 
            WHEN time_diff_seconds <= 86400 AND time_diff_seconds >= 0
                AND hist_end_result = 'pass'
            THEN hist_platform_user_id END) AS ip3_reg_trx_24hr,
            
        COUNT(DISTINCT CASE 
            WHEN time_diff_seconds <= 172800 AND time_diff_seconds >= 0
                AND hist_end_result = 'pass'
            THEN hist_platform_user_id END) AS ip3_reg_trx_2d,
            
        COUNT(DISTINCT CASE 
            WHEN time_diff_seconds <= 604800 AND time_diff_seconds >= 0
                AND hist_end_result = 'pass'
            THEN hist_platform_user_id END) AS ip3_reg_trx_7d,
            
        COUNT(DISTINCT CASE 
            WHEN time_diff_seconds <= 1296000 AND time_diff_seconds >= 0
                AND hist_end_result = 'pass'
            THEN hist_platform_user_id END) AS ip3_reg_trx_15d,
            
        -- 批量注册请求用户数特征 (req_batch系列)
        COUNT(DISTINCT CASE 
            WHEN time_diff_seconds <= 3600 AND time_diff_seconds >= 0
                AND hist_is_batch_registration = 1
            THEN hist_platform_user_id END) AS ip3_reg_req_batch_1hr,
            
        COUNT(DISTINCT CASE 
            WHEN time_diff_seconds <= 10800 AND time_diff_seconds >= 0
                AND hist_is_batch_registration = 1
            THEN hist_platform_user_id END) AS ip3_reg_req_batch_3hr,
            
        COUNT(DISTINCT CASE 
            WHEN time_diff_seconds <= 43200 AND time_diff_seconds >= 0
                AND hist_is_batch_registration = 1
            THEN hist_platform_user_id END) AS ip3_reg_req_batch_12hr,
            
        COUNT(DISTINCT CASE 
            WHEN time_diff_seconds <= 86400 AND time_diff_seconds >= 0
                AND hist_is_batch_registration = 1
            THEN hist_platform_user_id END) AS ip3_reg_req_batch_24hr,
            
        COUNT(DISTINCT CASE 
            WHEN time_diff_seconds <= 172800 AND time_diff_seconds >= 0
                AND hist_is_batch_registration = 1
            THEN hist_platform_user_id END) AS ip3_reg_req_batch_2d,
            
        COUNT(DISTINCT CASE 
            WHEN time_diff_seconds <= 604800 AND time_diff_seconds >= 0
                AND hist_is_batch_registration = 1
            THEN hist_platform_user_id END) AS ip3_reg_req_batch_7d,
            
        COUNT(DISTINCT CASE 
            WHEN time_diff_seconds <= 1296000 AND time_diff_seconds >= 0
                AND hist_is_batch_registration = 1
            THEN hist_platform_user_id END) AS ip3_reg_req_batch_15d,
            
        -- 批量注册激活用户数特征 (trx_batch系列)
        COUNT(DISTINCT CASE 
            WHEN time_diff_seconds <= 3600 AND time_diff_seconds >= 0
                AND hist_end_result = 'pass'
                AND hist_is_batch_registration = 1
            THEN hist_platform_user_id END) AS ip3_reg_trx_batch_1hr,
            
        COUNT(DISTINCT CASE 
            WHEN time_diff_seconds <= 10800 AND time_diff_seconds >= 0
                AND hist_end_result = 'pass'
                AND hist_is_batch_registration = 1
            THEN hist_platform_user_id END) AS ip3_reg_trx_batch_3hr,
            
        COUNT(DISTINCT CASE 
            WHEN time_diff_seconds <= 43200 AND time_diff_seconds >= 0
                AND hist_end_result = 'pass'
                AND hist_is_batch_registration = 1
            THEN hist_platform_user_id END) AS ip3_reg_trx_batch_12hr,
            
        COUNT(DISTINCT CASE 
            WHEN time_diff_seconds <= 86400 AND time_diff_seconds >= 0
                AND hist_end_result = 'pass'
                AND hist_is_batch_registration = 1
            THEN hist_platform_user_id END) AS ip3_reg_trx_batch_24hr,
            
        COUNT(DISTINCT CASE 
            WHEN time_diff_seconds <= 172800 AND time_diff_seconds >= 0
                AND hist_end_result = 'pass'
                AND hist_is_batch_registration = 1
            THEN hist_platform_user_id END) AS ip3_reg_trx_batch_2d,
            
        COUNT(DISTINCT CASE 
            WHEN time_diff_seconds <= 604800 AND time_diff_seconds >= 0
                AND hist_end_result = 'pass'
                AND hist_is_batch_registration = 1
            THEN hist_platform_user_id END) AS ip3_reg_trx_batch_7d,
            
        COUNT(DISTINCT CASE 
            WHEN time_diff_seconds <= 1296000 AND time_diff_seconds >= 0
                AND hist_end_result = 'pass'
                AND hist_is_batch_registration = 1
            THEN hist_platform_user_id END) AS ip3_reg_trx_batch_15d
FROM risk_report.dwd_risk_${reg}_ip3_short_di
where grass_date = '${ds}'
GROUP BY flow_no
)

insert overwrite table risk_report.dws_risk_${reg}_group_fraud_ip3_short_agg_feature_trx_di partition (grass_date = '${ds}')
SELECT *
FROM tmp
WHERE ip3_reg_req_15d > 0 OR ip3_reg_trx_15d > 0 OR ip3_reg_req_batch_15d > 0 OR ip3_reg_trx_batch_15d > 0
;


msck repair table risk_report.dws_risk_${reg}_group_fraud_ip3_short_agg_feature_trx_di;
refresh table risk_report.dws_risk_${reg}_group_fraud_ip3_short_agg_feature_trx_di;
