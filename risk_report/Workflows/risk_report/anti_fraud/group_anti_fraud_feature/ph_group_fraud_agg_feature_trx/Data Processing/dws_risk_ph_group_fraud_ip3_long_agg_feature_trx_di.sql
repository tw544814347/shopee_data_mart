--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-08-20
-- Theme Domain：       Anti-fraud 日志数据策略feature - dws 层
-- Description:         https://jira.shopee.io/browse/SPFDT-54753
-- Data Granularity:    
-- Change Log:
--********************************************************************--

DROP TABLE IF EXISTS risk_report.dws_risk_${reg}_group_fraud_ip3_long_agg_feature_trx_di;
CREATE TABLE risk_report.dws_risk_${reg}_group_fraud_ip3_long_agg_feature_trx_di (
    flow_no STRING COMMENT '流水号',

    -- 请求用户数特征（req系列）
    ip3_reg_req_30d BIGINT COMMENT '近30天内的不同用户注册请求数',
    ip3_reg_req_60d BIGINT COMMENT '近60天内的不同用户注册请求数',
    ip3_reg_req_90d BIGINT COMMENT '近90天内的不同用户注册请求数',
    ip3_reg_req_180d BIGINT COMMENT '近180天内的不同用户注册请求数',

    -- 激活用户数特征（act系列）
    ip3_reg_trx_30d BIGINT COMMENT '近30天内的不同用户注册激活数',
    ip3_reg_trx_60d BIGINT COMMENT '近60天内的不同用户注册激活数',
    ip3_reg_trx_90d BIGINT COMMENT '近90天内的不同用户注册激活数',
    ip3_reg_trx_180d BIGINT COMMENT '近180天内的不同用户注册激活数',

    -- 批量注册请求用户数特征（req_batch系列）
    ip3_reg_req_batch_30d BIGINT COMMENT '近30天内的不同批量注册用户请求数',
    ip3_reg_req_batch_60d BIGINT COMMENT '近60天内的不同批量注册用户请求数',
    ip3_reg_req_batch_90d BIGINT COMMENT '近90天内的不同批量注册用户请求数',
    ip3_reg_req_batch_180d BIGINT COMMENT '近180天内的不同批量注册用户请求数',

    -- 批量注册激活用户数特征（trx_batch系列）
    ip3_reg_trx_batch_30d BIGINT COMMENT '近30天内的不同批量注册用户激活数',
    ip3_reg_trx_batch_60d BIGINT COMMENT '近60天内的不同批量注册用户激活数',
    ip3_reg_trx_batch_90d BIGINT COMMENT '近90天内的不同批量注册用户激活数',
    ip3_reg_trx_batch_180d BIGINT COMMENT '近180天内的不同批量注册用户激活数'
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
location '${HDFS_PATH}/dwd/dws_risk_reg_group_fraud_ip3_long_agg_feature_trx_di/grass_region=${grass_region}';




CREATE OR REPLACE TEMP VIEW 
has_or_no_reactivate as (
SELECT 
    base.flow_no,

    -- ==================== 请求用户数特征 (req系列) ====================
    
    -- 30天请求用户数
    COUNT(DISTINCT 
        CASE 
            WHEN platform_user_id != hist_all_platform_user_id
                AND hist_all_grass_date >= date('${ds}') - interval '29' day
            THEN hist_all_platform_user_id
            WHEN platform_user_id != today_platform_user_id
                AND req_time - today_req_time <= 2592000  -- 30天 = 2592000秒
            THEN today_platform_user_id
        END
    ) AS ip3_reg_req_30d,
    
    -- 60天请求用户数
    null AS ip3_reg_req_60d,
    
    -- 90天请求用户数
    null AS ip3_reg_req_90d,
    
    -- 180天请求用户数
    null AS ip3_reg_req_180d,
    
    -- ==================== 激活用户数特征 (act系列) ====================
    
    -- 30天激活用户数
    COUNT(DISTINCT 
        CASE 
            WHEN platform_user_id != hist_all_platform_user_id
                AND hist_all_grass_date >= date('${ds}') - interval '29' day
                AND hist_end_result = 'pass'
            THEN hist_all_platform_user_id
            WHEN platform_user_id != today_platform_user_id
                AND req_time - today_req_time <= 2592000  -- 30天 = 2592000秒
                AND hist_end_result = 'pass'
            THEN today_platform_user_id
        END
    ) AS ip3_reg_trx_30d,
    
    -- 60天激活用户数
    null AS ip3_reg_trx_60d,
    
    -- 90天激活用户数
    null AS ip3_reg_trx_90d,
    
    -- 180天激活用户数
    null AS ip3_reg_trx_180d,
    
    -- ==================== 批量注册请求用户数特征 (batch req系列) ====================
    
    -- 30天批量注册请求用户数
    COUNT(DISTINCT 
        CASE 
            WHEN platform_user_id != hist_all_platform_user_id
                AND hist_all_grass_date >= date('${ds}') - interval '29' day
                AND hist_is_batch_registration = 1
            THEN hist_all_platform_user_id
            WHEN platform_user_id != today_platform_user_id
                AND req_time - today_req_time <= 2592000  -- 30天 = 2592000秒
                AND hist_is_batch_registration = 1
            THEN today_platform_user_id
        END
    ) AS ip3_reg_req_batch_30d,
    
    -- 60天批量注册请求用户数
    null AS ip3_reg_req_batch_60d,
    
    -- 90天批量注册请求用户数
    null AS ip3_reg_req_batch_90d,
    
    -- 180天批量注册请求用户数
    null AS ip3_reg_req_batch_180d,
    
    -- ==================== 批量注册激活用户数特征 (trx_batch系列) ====================
    
    -- 30天批量注册激活用户数
    COUNT(DISTINCT 
        CASE 
            WHEN platform_user_id != hist_all_platform_user_id
                AND hist_all_grass_date >= date('${ds}') - interval '29' day
                AND hist_end_result = 'pass'
                AND hist_is_batch_registration = 1
            THEN hist_all_platform_user_id
            WHEN platform_user_id != today_platform_user_id
                AND req_time - today_req_time <= 2592000  -- 30天 = 2592000秒
                AND hist_end_result = 'pass'
                AND hist_is_batch_registration = 1
            THEN today_platform_user_id
        END
    ) AS ip3_reg_trx_batch_30d,
    
    -- 60天批量注册激活用户数
    null AS ip3_reg_trx_batch_60d,
    
    -- 90天批量注册激活用户数
    null AS ip3_reg_trx_batch_90d,
    
    -- 180天批量注册激活用户数
    null AS ip3_reg_trx_batch_180d
        
FROM 
risk_report.dwd_risk_${reg}_ip3_long_di as base
where grass_date = '${ds}'
GROUP BY     
    base.flow_no
);

insert overwrite table risk_report.dws_risk_${reg}_group_fraud_ip3_long_agg_feature_trx_di partition (grass_date = '${ds}')
SELECT *
FROM has_or_no_reactivate
WHERE ip3_reg_req_30d > 0 OR ip3_reg_trx_30d > 0 OR ip3_reg_req_batch_30d > 0 OR ip3_reg_trx_batch_30d > 0
;

msck repair table risk_report.dws_risk_${reg}_group_fraud_ip3_long_agg_feature_trx_di;
refresh table risk_report.dws_risk_${reg}_group_fraud_ip3_long_agg_feature_trx_di;
