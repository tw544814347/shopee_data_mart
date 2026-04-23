--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-08-20
-- Theme Domain：       Anti-fraud 日志数据策略feature - dws 层
-- Description:         https://jira.shopee.io/browse/SPFDT-54753
-- Data Granularity:    
-- Change Log:
--********************************************************************--

DROP TABLE IF EXISTS risk_report.dws_risk_${reg}_group_fraud_reg_phone_long_agg_feature_di;
CREATE TABLE risk_report.dws_risk_${reg}_group_fraud_reg_phone_long_agg_feature_di (
    flow_no STRING COMMENT '流水号',

    -- 请求用户数特征（req系列）
    reg_phone_reg_req_30d BIGINT COMMENT '近30天内的不同用户注册请求数',
    reg_phone_reg_req_60d BIGINT COMMENT '近60天内的不同用户注册请求数',
    reg_phone_reg_req_90d BIGINT COMMENT '近90天内的不同用户注册请求数',
    reg_phone_reg_req_180d BIGINT COMMENT '近180天内的不同用户注册请求数',

    -- 激活用户数特征（act系列）
    reg_phone_reg_act_30d BIGINT COMMENT '近30天内的不同用户注册激活数',
    reg_phone_reg_act_60d BIGINT COMMENT '近60天内的不同用户注册激活数',
    reg_phone_reg_act_90d BIGINT COMMENT '近90天内的不同用户注册激活数',
    reg_phone_reg_act_180d BIGINT COMMENT '近180天内的不同用户注册激活数',

    -- 批量注册请求用户数特征（req_batch系列）
    reg_phone_reg_req_batch_30d BIGINT COMMENT '近30天内的不同批量注册用户请求数',
    reg_phone_reg_req_batch_60d BIGINT COMMENT '近60天内的不同批量注册用户请求数',
    reg_phone_reg_req_batch_90d BIGINT COMMENT '近90天内的不同批量注册用户请求数',
    reg_phone_reg_req_batch_180d BIGINT COMMENT '近180天内的不同批量注册用户请求数',

    -- 批量注册激活用户数特征（act_batch系列）
    reg_phone_reg_act_batch_30d BIGINT COMMENT '近30天内的不同批量注册用户激活数',
    reg_phone_reg_act_batch_60d BIGINT COMMENT '近60天内的不同批量注册用户激活数',
    reg_phone_reg_act_batch_90d BIGINT COMMENT '近90天内的不同批量注册用户激活数',
    reg_phone_reg_act_batch_180d BIGINT COMMENT '近180天内的不同批量注册用户激活数'
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
location '${HDFS_PATH}/dwd/dws_risk_reg_group_fraud_reg_phone_long_agg_feature_di/grass_region=${grass_region}';


CREATE OR REPLACE TEMP VIEW 
reg_phone_hist_all_middle_day_agg_part as (
    SELECT DISTINCT 
        app_id, scene_id, reg_phone, platform_user_id,
        end_result, is_batch_registration, is_reactivate,
        grass_date  -- 保留日期用于后续筛选
    FROM risk_report.dwd_risk_${reg}_group_fraud_phone_di
    WHERE grass_date BETWEEN date('${ds}') - interval '179' day AND date('${ds}') - interval '1' day
);

CACHE TABLE reg_phone_hist_all_middle_day_agg_part;   -- 把查询结果缓存到内存/磁盘
CREATE OR REPLACE TEMP VIEW 
reg_phone_hist_all_edge_day_agg_part as (
    SELECT DISTINCT 
        app_id, scene_id, reg_phone, platform_user_id,
        req_time, end_result, is_batch_registration, is_reactivate
    FROM risk_report.dwd_risk_${reg}_group_fraud_phone_di
    WHERE grass_date in (date('${ds}'),date('${ds}') - interval '180' day,date('${ds}') - interval '90' day,date('${ds}') - interval '60' day,date('${ds}') - interval '30' day)
);
CREATE OR REPLACE TEMP VIEW 
has_reactivate as (
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
    ) AS reg_phone_reg_req_30d,
    
    -- 60天请求用户数
    COUNT(DISTINCT 
        CASE 
            WHEN platform_user_id != hist_all_platform_user_id
                AND hist_all_grass_date >= date('${ds}') - interval '59' day
            THEN hist_all_platform_user_id
            WHEN platform_user_id != today_platform_user_id
                AND req_time - today_req_time <= 5184000  -- 60天 = 5184000秒
            THEN today_platform_user_id
        END
    ) AS reg_phone_reg_req_60d,
    
    -- 90天请求用户数
    COUNT(DISTINCT 
        CASE 
            WHEN platform_user_id != hist_all_platform_user_id
                AND hist_all_grass_date >= date('${ds}') - interval '89' day
            THEN hist_all_platform_user_id
            WHEN platform_user_id != today_platform_user_id
                AND req_time - today_req_time <= 7776000  -- 90天 = 7776000秒
            THEN today_platform_user_id
        END
    ) AS reg_phone_reg_req_90d,
    
    -- 180天请求用户数
    COUNT(DISTINCT 
        CASE 
            WHEN platform_user_id != hist_all_platform_user_id
                AND hist_all_grass_date >= date('${ds}') - interval '179' day
            THEN hist_all_platform_user_id
            WHEN platform_user_id != today_platform_user_id
                AND req_time - today_req_time <= 15552000  -- 180天 = 15552000秒
            THEN today_platform_user_id
        END
    ) AS reg_phone_reg_req_180d,
    
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
    ) AS reg_phone_reg_act_30d,
    
    -- 60天激活用户数
    COUNT(DISTINCT 
        CASE 
            WHEN platform_user_id != hist_all_platform_user_id
                AND hist_all_grass_date >= date('${ds}') - interval '59' day
                AND hist_end_result = 'pass'
            THEN hist_all_platform_user_id
            WHEN platform_user_id != today_platform_user_id
                AND req_time - today_req_time <= 5184000  -- 60天 = 5184000秒
                AND hist_end_result = 'pass'
            THEN today_platform_user_id
        END
    ) AS reg_phone_reg_act_60d,
    
    -- 90天激活用户数
    COUNT(DISTINCT 
        CASE 
            WHEN platform_user_id != hist_all_platform_user_id
                AND hist_all_grass_date >= date('${ds}') - interval '89' day
                AND hist_end_result = 'pass'
            THEN hist_all_platform_user_id
            WHEN platform_user_id != today_platform_user_id
                AND req_time - today_req_time <= 7776000  -- 90天 = 7776000秒
                AND hist_end_result = 'pass'
            THEN today_platform_user_id
        END
    ) AS reg_phone_reg_act_90d,
    
    -- 180天激活用户数
    COUNT(DISTINCT 
        CASE 
            WHEN platform_user_id != hist_all_platform_user_id
                AND hist_all_grass_date >= date('${ds}') - interval '179' day
                AND hist_end_result = 'pass'
            THEN hist_all_platform_user_id
            WHEN platform_user_id != today_platform_user_id
                AND req_time - today_req_time <= 15552000  -- 180天 = 15552000秒
                AND hist_end_result = 'pass'
            THEN today_platform_user_id
        END
    ) AS reg_phone_reg_act_180d,
    
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
    ) AS reg_phone_reg_req_batch_30d,
    
    -- 60天批量注册请求用户数
    COUNT(DISTINCT 
        CASE 
            WHEN platform_user_id != hist_all_platform_user_id
                AND hist_all_grass_date >= date('${ds}') - interval '59' day
                AND hist_is_batch_registration = 1
            THEN hist_all_platform_user_id
            WHEN platform_user_id != today_platform_user_id
                AND req_time - today_req_time <= 5184000  -- 60天 = 5184000秒
                AND hist_is_batch_registration = 1
            THEN today_platform_user_id
        END
    ) AS reg_phone_reg_req_batch_60d,
    
    -- 90天批量注册请求用户数
    COUNT(DISTINCT 
        CASE 
            WHEN platform_user_id != hist_all_platform_user_id
                AND hist_all_grass_date >= date('${ds}') - interval '89' day
                AND hist_is_batch_registration = 1
            THEN hist_all_platform_user_id
            WHEN platform_user_id != today_platform_user_id
                AND req_time - today_req_time <= 7776000  -- 90天 = 7776000秒
                AND hist_is_batch_registration = 1
            THEN today_platform_user_id
        END
    ) AS reg_phone_reg_req_batch_90d,
    
    -- 180天批量注册请求用户数
    COUNT(DISTINCT 
        CASE 
            WHEN platform_user_id != hist_all_platform_user_id
                AND hist_all_grass_date >= date('${ds}') - interval '179' day
                AND hist_is_batch_registration = 1
            THEN hist_all_platform_user_id
            WHEN platform_user_id != today_platform_user_id
                AND req_time - today_req_time <= 15552000  -- 180天 = 15552000秒
                AND hist_is_batch_registration = 1
            THEN today_platform_user_id
        END
    ) AS reg_phone_reg_req_batch_180d,
    
    -- ==================== 批量注册激活用户数特征 (act_batch系列) ====================
    
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
    ) AS reg_phone_reg_act_batch_30d,
    
    -- 60天批量注册激活用户数
    COUNT(DISTINCT 
        CASE 
            WHEN platform_user_id != hist_all_platform_user_id
                AND hist_all_grass_date >= date('${ds}') - interval '59' day
                AND hist_end_result = 'pass'
                AND hist_is_batch_registration = 1
            THEN hist_all_platform_user_id
            WHEN platform_user_id != today_platform_user_id
                AND req_time - today_req_time <= 5184000  -- 60天 = 5184000秒
                AND hist_end_result = 'pass'
                AND hist_is_batch_registration = 1
            THEN today_platform_user_id
        END
    ) AS reg_phone_reg_act_batch_60d,
    
    -- 90天批量注册激活用户数
    COUNT(DISTINCT 
        CASE 
            WHEN platform_user_id != hist_all_platform_user_id
                AND hist_all_grass_date >= date('${ds}') - interval '89' day
                AND hist_end_result = 'pass'
                AND hist_is_batch_registration = 1
            THEN hist_all_platform_user_id
            WHEN platform_user_id != today_platform_user_id
                AND req_time - today_req_time <= 7776000  -- 90天 = 7776000秒
                AND hist_end_result = 'pass'
                AND hist_is_batch_registration = 1
            THEN today_platform_user_id
        END
    ) AS reg_phone_reg_act_batch_90d,
    
    -- 180天批量注册激活用户数
    COUNT(DISTINCT 
        CASE 
            WHEN platform_user_id != hist_all_platform_user_id
                AND hist_all_grass_date >= date('${ds}') - interval '179' day
                AND hist_end_result = 'pass'
                AND hist_is_batch_registration = 1
            THEN hist_all_platform_user_id
            WHEN platform_user_id != today_platform_user_id
                AND req_time - today_req_time <= 15552000  -- 180天 = 15552000秒
                AND hist_end_result = 'pass'
                AND hist_is_batch_registration = 1
            THEN today_platform_user_id
        END
    ) AS reg_phone_reg_act_batch_180d
        
FROM 
(
select base.*, hist_all.platform_user_id as hist_all_platform_user_id, null as today_platform_user_id,
        hist_all.grass_date as hist_all_grass_date, null as today_req_time, hist_all.end_result as hist_end_result, hist_all.is_batch_registration as hist_is_batch_registration--, hist_all.is_reactivate
from 
(
    select distinct flow_no,platform_user_id,req_time, app_id, scene_id,reg_phone,grass_date
    from risk_report.dwd_risk_${reg}_group_fraud_feature_act_base_di base
    where base.grass_date = '${ds}'
        AND base.app_id not in ('kredit', 'spj', 'spjup') -- bcl/spl/scl
) base
LEFT JOIN reg_phone_hist_all_middle_day_agg_part hist_all
    ON md5(base.reg_phone) = md5(hist_all.reg_phone)
    AND base.app_id = hist_all.app_id
    AND base.scene_id = hist_all.scene_id
UNION ALL 
select base.*, null as hist_all_platform_user_id, today.platform_user_id as today_platform_user_id,
        null as hist_all_grass_date, today.req_time as today_req_time, today.end_result as hist_end_result, today.is_batch_registration as hist_is_batch_registration--, today.is_reactivate
from
(
    select distinct flow_no,platform_user_id,req_time, app_id, scene_id,reg_phone,grass_date
    from risk_report.dwd_risk_${reg}_group_fraud_feature_act_base_di base
    where base.grass_date = '${ds}'
        AND base.app_id not in ('kredit', 'spj', 'spjup') -- bcl/spl/scl
) base
LEFT JOIN reg_phone_hist_all_edge_day_agg_part today
    ON md5(base.reg_phone) = md5(today.reg_phone)
    AND base.app_id = today.app_id
    AND base.scene_id = today.scene_id   
) as base
GROUP BY     
    base.flow_no
);
CREATE OR REPLACE TEMP VIEW 
no_reactivate as ( 
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
    ) AS reg_phone_reg_req_30d,
    
    -- 60天请求用户数
    COUNT(DISTINCT 
        CASE 
            WHEN platform_user_id != hist_all_platform_user_id
                AND hist_all_grass_date >= date('${ds}') - interval '59' day
            THEN hist_all_platform_user_id
            WHEN platform_user_id != today_platform_user_id
                AND req_time - today_req_time <= 5184000  -- 60天 = 5184000秒
            THEN today_platform_user_id
        END
    ) AS reg_phone_reg_req_60d,
    
    -- 90天请求用户数
    COUNT(DISTINCT 
        CASE 
            WHEN platform_user_id != hist_all_platform_user_id
                AND hist_all_grass_date >= date('${ds}') - interval '89' day
            THEN hist_all_platform_user_id
            WHEN platform_user_id != today_platform_user_id
                AND req_time - today_req_time <= 7776000  -- 90天 = 7776000秒
            THEN today_platform_user_id
        END
    ) AS reg_phone_reg_req_90d,
    
    -- 180天请求用户数
    COUNT(DISTINCT 
        CASE 
            WHEN platform_user_id != hist_all_platform_user_id
                AND hist_all_grass_date >= date('${ds}') - interval '179' day
            THEN hist_all_platform_user_id
            WHEN platform_user_id != today_platform_user_id
                AND req_time - today_req_time <= 15552000  -- 180天 = 15552000秒
            THEN today_platform_user_id
        END
    ) AS reg_phone_reg_req_180d,
    
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
    ) AS reg_phone_reg_act_30d,
    
    -- 60天激活用户数
    COUNT(DISTINCT 
        CASE 
            WHEN platform_user_id != hist_all_platform_user_id
                AND hist_all_grass_date >= date('${ds}') - interval '59' day
                AND hist_end_result = 'pass'
            THEN hist_all_platform_user_id
            WHEN platform_user_id != today_platform_user_id
                AND req_time - today_req_time <= 5184000  -- 60天 = 5184000秒
                AND hist_end_result = 'pass'
            THEN today_platform_user_id
        END
    ) AS reg_phone_reg_act_60d,
    
    -- 90天激活用户数
    COUNT(DISTINCT 
        CASE 
            WHEN platform_user_id != hist_all_platform_user_id
                AND hist_all_grass_date >= date('${ds}') - interval '89' day
                AND hist_end_result = 'pass'
            THEN hist_all_platform_user_id
            WHEN platform_user_id != today_platform_user_id
                AND req_time - today_req_time <= 7776000  -- 90天 = 7776000秒
                AND hist_end_result = 'pass'
            THEN today_platform_user_id
        END
    ) AS reg_phone_reg_act_90d,
    
    -- 180天激活用户数
    COUNT(DISTINCT 
        CASE 
            WHEN platform_user_id != hist_all_platform_user_id
                AND hist_all_grass_date >= date('${ds}') - interval '179' day
                AND hist_end_result = 'pass'
            THEN hist_all_platform_user_id
            WHEN platform_user_id != today_platform_user_id
                AND req_time - today_req_time <= 15552000  -- 180天 = 15552000秒
                AND hist_end_result = 'pass'
            THEN today_platform_user_id
        END
    ) AS reg_phone_reg_act_180d,
    
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
    ) AS reg_phone_reg_req_batch_30d,
    
    -- 60天批量注册请求用户数
    COUNT(DISTINCT 
        CASE 
            WHEN platform_user_id != hist_all_platform_user_id
                AND hist_all_grass_date >= date('${ds}') - interval '59' day
                AND hist_is_batch_registration = 1
            THEN hist_all_platform_user_id
            WHEN platform_user_id != today_platform_user_id
                AND req_time - today_req_time <= 5184000  -- 60天 = 5184000秒
                AND hist_is_batch_registration = 1
            THEN today_platform_user_id
        END
    ) AS reg_phone_reg_req_batch_60d,
    
    -- 90天批量注册请求用户数
    COUNT(DISTINCT 
        CASE 
            WHEN platform_user_id != hist_all_platform_user_id
                AND hist_all_grass_date >= date('${ds}') - interval '89' day
                AND hist_is_batch_registration = 1
            THEN hist_all_platform_user_id
            WHEN platform_user_id != today_platform_user_id
                AND req_time - today_req_time <= 7776000  -- 90天 = 7776000秒
                AND hist_is_batch_registration = 1
            THEN today_platform_user_id
        END
    ) AS reg_phone_reg_req_batch_90d,
    
    -- 180天批量注册请求用户数
    COUNT(DISTINCT 
        CASE 
            WHEN platform_user_id != hist_all_platform_user_id
                AND hist_all_grass_date >= date('${ds}') - interval '179' day
                AND hist_is_batch_registration = 1
            THEN hist_all_platform_user_id
            WHEN platform_user_id != today_platform_user_id
                AND req_time - today_req_time <= 15552000  -- 180天 = 15552000秒
                AND hist_is_batch_registration = 1
            THEN today_platform_user_id
        END
    ) AS reg_phone_reg_req_batch_180d,
    
    -- ==================== 批量注册激活用户数特征 (act_batch系列) ====================
    
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
    ) AS reg_phone_reg_act_batch_30d,
    
    -- 60天批量注册激活用户数
    COUNT(DISTINCT 
        CASE 
            WHEN platform_user_id != hist_all_platform_user_id
                AND hist_all_grass_date >= date('${ds}') - interval '59' day
                AND hist_end_result = 'pass'
                AND hist_is_batch_registration = 1
            THEN hist_all_platform_user_id
            WHEN platform_user_id != today_platform_user_id
                AND req_time - today_req_time <= 5184000  -- 60天 = 5184000秒
                AND hist_end_result = 'pass'
                AND hist_is_batch_registration = 1
            THEN today_platform_user_id
        END
    ) AS reg_phone_reg_act_batch_60d,
    
    -- 90天批量注册激活用户数
    COUNT(DISTINCT 
        CASE 
            WHEN platform_user_id != hist_all_platform_user_id
                AND hist_all_grass_date >= date('${ds}') - interval '89' day
                AND hist_end_result = 'pass'
                AND hist_is_batch_registration = 1
            THEN hist_all_platform_user_id
            WHEN platform_user_id != today_platform_user_id
                AND req_time - today_req_time <= 7776000  -- 90天 = 7776000秒
                AND hist_end_result = 'pass'
                AND hist_is_batch_registration = 1
            THEN today_platform_user_id
        END
    ) AS reg_phone_reg_act_batch_90d,
    
    -- 180天批量注册激活用户数
    COUNT(DISTINCT 
            CASE 
                WHEN platform_user_id != hist_all_platform_user_id
                    AND hist_all_grass_date >= date('${ds}') - interval '179' day
                    AND hist_end_result = 'pass'
                    AND hist_is_batch_registration = 1
                THEN hist_all_platform_user_id
                WHEN platform_user_id != today_platform_user_id
                    AND req_time - today_req_time <= 15552000  -- 180天 = 15552000秒
                    AND hist_end_result = 'pass'
                    AND hist_is_batch_registration = 1
                THEN today_platform_user_id
            END
    ) AS reg_phone_reg_act_batch_180d
FROM 
(
select base.*, hist_all.platform_user_id as hist_all_platform_user_id, null as today_platform_user_id,
        hist_all.grass_date as hist_all_grass_date, null as today_req_time, hist_all.end_result as hist_end_result, hist_all.is_batch_registration as hist_is_batch_registration--, hist_all.is_reactivate
from 
(
    select distinct flow_no,platform_user_id,req_time, app_id, scene_id,reg_phone,grass_date
    from risk_report.dwd_risk_${reg}_group_fraud_feature_act_base_di base
    where base.grass_date = '${ds}'
        AND base.app_id in ('kredit', 'spj', 'spjup') -- bcl/spl/scl
) base
LEFT JOIN reg_phone_hist_all_middle_day_agg_part hist_all
    ON md5(base.reg_phone) = md5(hist_all.reg_phone)
    AND if(base.app_id = 'kredit', base.app_id = hist_all.app_id, base.app_id = hist_all.app_id AND base.scene_id = hist_all.scene_id)
WHERE hist_all.is_reactivate = 0
UNION ALL 
select base.*, null as hist_all_platform_user_id, today.platform_user_id as today_platform_user_id,
        null as hist_all_grass_date, today.req_time as today_req_time, today.end_result as hist_end_result, today.is_batch_registration as hist_is_batch_registration--, today.is_reactivate
from
(
    select distinct flow_no,platform_user_id,req_time, app_id, scene_id,reg_phone,grass_date
    from risk_report.dwd_risk_${reg}_group_fraud_feature_act_base_di base
    where base.grass_date = '${ds}'
        AND base.app_id in ('kredit', 'spj', 'spjup') -- bcl/spl/scl
) base
LEFT JOIN reg_phone_hist_all_edge_day_agg_part today
    ON md5(base.reg_phone) = md5(today.reg_phone)
    AND if(base.app_id = 'kredit', base.app_id = today.app_id, base.app_id = today.app_id AND base.scene_id = today.scene_id) 
WHERE today.is_reactivate = 0
) as base 
GROUP BY 
    base.flow_no
);

insert overwrite table risk_report.dws_risk_${reg}_group_fraud_reg_phone_long_agg_feature_di partition (grass_date = '${ds}')
SELECT *
FROM has_reactivate
WHERE reg_phone_reg_req_180d > 0 OR reg_phone_reg_act_180d > 0 OR reg_phone_reg_req_batch_180d > 0 OR reg_phone_reg_act_batch_180d > 0
union all
SELECT *
FROM no_reactivate
WHERE reg_phone_reg_req_180d > 0 OR reg_phone_reg_act_180d > 0 OR reg_phone_reg_req_batch_180d > 0 OR reg_phone_reg_act_batch_180d > 0
;



msck repair table risk_report.dws_risk_${reg}_group_fraud_reg_phone_long_agg_feature_di;
refresh table risk_report.dws_risk_${reg}_group_fraud_reg_phone_long_agg_feature_di;



create or replace view risk_report.dws_risk_${reg}_group_fraud_phone_long_agg_feature_di
COMMENT 'risk mart summary table'
as select * 
from 
risk_report.dws_risk_${reg}_group_fraud_reg_phone_long_agg_feature_di;