DROP TABLE IF EXISTS risk_report.dws_risk_${reg}_group_fraud_device_login_agg_feature_trx_di;

CREATE TABLE risk_report.dws_risk_${reg}_group_fraud_device_login_agg_feature_trx_di (
    flow_no STRING COMMENT '流水号',
    platform_user_id STRING COMMENT '平台用户ID',
    app_id STRING COMMENT '应用ID',
    scene_id BIGINT COMMENT '场景ID',
    req_time BIGINT COMMENT '请求时间（秒级时间戳）',

    -- 设备登录用户数特征（login系列）
    szdf_reg_login_1hr BIGINT COMMENT '近1小时内的设备登录数',
    szdf_reg_login_3hr BIGINT COMMENT '近3小时内的设备登录数',
    szdf_reg_login_12hr BIGINT COMMENT '近12小时内的设备登录数',
    szdf_reg_login_24hr BIGINT COMMENT '近24小时内的设备登录数',
    szdf_reg_login_2d BIGINT COMMENT '近2天内的设备登录数',
    szdf_reg_login_7d BIGINT COMMENT '近7天内的设备登录数',
    szdf_reg_login_15d BIGINT COMMENT '近15天内的设备登录数',
    szdf_reg_login_30d BIGINT COMMENT '近30天内的设备登录数',
    szdf_reg_login_60d BIGINT COMMENT '近60天内的设备登录数',
    szdf_reg_login_90d BIGINT COMMENT '近90天内的设备登录数',
    szdf_reg_login_180d BIGINT COMMENT '近180天内的设备登录数',

    -- 批量设备登录用户数特征（batch系列）
    szdf_reg_login_batch_1hr BIGINT COMMENT '近1小时内的批量设备登录数',
    szdf_reg_login_batch_3hr BIGINT COMMENT '近3小时内的批量设备登录数',
    szdf_reg_login_batch_12hr BIGINT COMMENT '近12小时内的批量设备登录数',
    szdf_reg_login_batch_24hr BIGINT COMMENT '近24小时内的批量设备登录数',
    szdf_reg_login_batch_2d BIGINT COMMENT '近2天内的批量设备登录数',
    szdf_reg_login_batch_7d BIGINT COMMENT '近7天内的批量设备登录数',
    szdf_reg_login_batch_15d BIGINT COMMENT '近15天内的批量设备登录数',
    szdf_reg_login_batch_30d BIGINT COMMENT '近30天内的批量设备登录数',
    szdf_reg_login_batch_60d BIGINT COMMENT '近60天内的批量设备登录数',
    szdf_reg_login_batch_90d BIGINT COMMENT '近90天内的批量设备登录数',
    szdf_reg_login_batch_180d BIGINT COMMENT '近180天内的批量设备登录数'
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
location '${HDFS_PATH}/dwd/dws_risk_reg_group_fraud_device_login_agg_feature_trx_di/grass_region=${grass_region}';



with szdf_reg_login_agg as (
SELECT 
    base.flow_no,
    base.platform_user_id,
    base.app_id, 
    base.scene_id,
    base.grass_date,
    base.req_time,
    
    -- 设备登录用户数特征 - 基于精确秒级时间窗口
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.login_timestamp <= 3600  -- 1小时 = 3600秒
            AND base.req_time - h.login_timestamp >= 0
            AND h.user_id != base.platform_user_id
        THEN h.user_id END) AS szdf_reg_login_1hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.login_timestamp <= 10800  -- 3小时 = 10800秒
            AND base.req_time - h.login_timestamp >= 0
            AND h.user_id != base.platform_user_id
        THEN h.user_id END) AS szdf_reg_login_3hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.login_timestamp <= 43200  -- 12小时 = 43200秒
            AND base.req_time - h.login_timestamp >= 0
            AND h.user_id != base.platform_user_id
        THEN h.user_id END) AS szdf_reg_login_12hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.login_timestamp <= 86400  -- 1天 = 86400秒
            AND base.req_time - h.login_timestamp >= 0
            AND h.user_id != base.platform_user_id
        THEN h.user_id END) AS szdf_reg_login_24hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.login_timestamp <= 172800  -- 2天 = 172800秒
            AND base.req_time - h.login_timestamp >= 0
            AND h.user_id != base.platform_user_id
        THEN h.user_id END) AS szdf_reg_login_2d,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.login_timestamp <= 604800  -- 7天 = 604800秒
            AND base.req_time - h.login_timestamp >= 0
            AND h.user_id != base.platform_user_id
        THEN h.user_id END) AS szdf_reg_login_7d,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.login_timestamp <= 1296000  -- 15天 = 1296000秒
            AND base.req_time - h.login_timestamp >= 0
            AND h.user_id != base.platform_user_id
        THEN h.user_id END) AS szdf_reg_login_15d,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.login_timestamp <= 2592000  -- 30天 = 2592000秒
            AND base.req_time - h.login_timestamp >= 0
            AND h.user_id != base.platform_user_id
        THEN h.user_id END) AS szdf_reg_login_30d,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.login_timestamp <= 5184000  -- 60天 = 5184000秒
            AND base.req_time - h.login_timestamp >= 0
            AND h.user_id != base.platform_user_id
        THEN h.user_id END) AS szdf_reg_login_60d,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.login_timestamp <= 7776000  -- 90天 = 7776000秒
            AND base.req_time - h.login_timestamp >= 0
            AND h.user_id != base.platform_user_id
        THEN h.user_id END) AS szdf_reg_login_90d,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.login_timestamp <= 15552000  -- 180天 = 15552000秒
            AND base.req_time - h.login_timestamp >= 0
            AND h.user_id != base.platform_user_id
        THEN h.user_id END) AS szdf_reg_login_180d,

    -- 批量设备登录用户数特征（batch系列）
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.login_timestamp <= 3600  -- 1小时 = 3600秒
            AND base.req_time - h.login_timestamp >= 0
            AND h.user_id != base.platform_user_id
            AND h.is_batch_registration = 1
        THEN h.user_id END) AS szdf_reg_login_batch_1hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.login_timestamp <= 10800  -- 3小时 = 10800秒
            AND base.req_time - h.login_timestamp >= 0
            AND h.user_id != base.platform_user_id
            AND h.is_batch_registration = 1
        THEN h.user_id END) AS szdf_reg_login_batch_3hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.login_timestamp <= 43200  -- 12小时 = 43200秒
            AND base.req_time - h.login_timestamp >= 0
            AND h.user_id != base.platform_user_id
            AND h.is_batch_registration = 1
        THEN h.user_id END) AS szdf_reg_login_batch_12hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.login_timestamp <= 86400  -- 1天 = 86400秒
            AND base.req_time - h.login_timestamp >= 0
            AND h.user_id != base.platform_user_id
            AND h.is_batch_registration = 1
        THEN h.user_id END) AS szdf_reg_login_batch_24hr,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.login_timestamp <= 172800  -- 2天 = 172800秒
            AND base.req_time - h.login_timestamp >= 0
            AND h.user_id != base.platform_user_id
            AND h.is_batch_registration = 1
        THEN h.user_id END) AS szdf_reg_login_batch_2d,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.login_timestamp <= 604800  -- 7天 = 604800秒
            AND base.req_time - h.login_timestamp >= 0
            AND h.user_id != base.platform_user_id
            AND h.is_batch_registration = 1
        THEN h.user_id END) AS szdf_reg_login_batch_7d,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.login_timestamp <= 1296000  -- 15天 = 1296000秒
            AND base.req_time - h.login_timestamp >= 0
            AND h.user_id != base.platform_user_id
            AND h.is_batch_registration = 1
        THEN h.user_id END) AS szdf_reg_login_batch_15d,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.login_timestamp <= 2592000  -- 30天 = 2592000秒
            AND base.req_time - h.login_timestamp >= 0
            AND h.user_id != base.platform_user_id
            AND h.is_batch_registration = 1
        THEN h.user_id END) AS szdf_reg_login_batch_30d,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.login_timestamp <= 5184000  -- 60天 = 5184000秒
            AND base.req_time - h.login_timestamp >= 0
            AND h.user_id != base.platform_user_id
            AND h.is_batch_registration = 1
        THEN h.user_id END) AS szdf_reg_login_batch_60d,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.login_timestamp <= 7776000  -- 90天 = 7776000秒
            AND base.req_time - h.login_timestamp >= 0
            AND h.user_id != base.platform_user_id
            AND h.is_batch_registration = 1
        THEN h.user_id END) AS szdf_reg_login_batch_90d,
        
    COUNT(DISTINCT CASE 
        WHEN base.req_time - h.login_timestamp <= 15552000  -- 180天 = 15552000秒
            AND base.req_time - h.login_timestamp >= 0
            AND h.user_id != base.platform_user_id
            AND h.is_batch_registration = 1
        THEN h.user_id END) AS szdf_reg_login_batch_180d
        
FROM risk_report.dwd_risk_${reg}_group_fraud_feature_trx_base_di base
LEFT JOIN (
    SELECT 
        CAST(le.user_id AS STRING) AS user_id,
        le.sz_dfp_device_id AS szdf,
        le.login_timestamp,
        le.grass_date,
        CASE WHEN tag.reason IS NOT NULL THEN 1 ELSE 0 END AS is_batch_registration
    FROM risk.dwd_risk_szdf_login_di le
    LEFT JOIN (
        SELECT DISTINCT
            CAST(user_id AS STRING) AS user_id,
            create_datetime,
            create_timestamp,
            reason
        FROM risk_report.dim_risk_${reg}_batch_registration_login_fraud_tag_df
        WHERE grass_date = '${ds}'
    ) tag ON le.user_id = tag.user_id
    WHERE le.grass_region = UPPER('${reg}')
        AND le.sz_dfp_device_id != '' 
        AND le.sz_dfp_device_id IS NOT NULL
        AND le.is_device = 'Y' 
        AND le.is_login = 'Y'
        AND le.grass_date >= '${ds}' - INTERVAL '180' DAY AND le.grass_date <= '${ds}'
) h ON base.szdf = h.szdf
    AND base.platform_user_id != h.user_id
    AND base.req_time >= h.login_timestamp
    
WHERE base.grass_date = '${ds}'
GROUP BY base.flow_no, base.platform_user_id, base.app_id, base.scene_id, base.grass_date, base.req_time
)



INSERT OVERWRITE TABLE risk_report.dws_risk_${reg}_group_fraud_device_login_agg_feature_trx_di PARTITION (grass_date)

SELECT 
    flow_no,
    platform_user_id,
    app_id,
    cast(scene_id as bigint),
    cast(req_time as bigint),
    szdf_reg_login_1hr,
    szdf_reg_login_3hr,
    szdf_reg_login_12hr,
    szdf_reg_login_24hr,
    szdf_reg_login_2d,
    szdf_reg_login_7d,
    szdf_reg_login_15d,
    szdf_reg_login_30d,
    szdf_reg_login_60d,
    szdf_reg_login_90d,
    szdf_reg_login_180d,
    szdf_reg_login_batch_1hr,
    szdf_reg_login_batch_3hr,
    szdf_reg_login_batch_12hr,
    szdf_reg_login_batch_24hr,
    szdf_reg_login_batch_2d,
    szdf_reg_login_batch_7d,
    szdf_reg_login_batch_15d,
    szdf_reg_login_batch_30d,
    szdf_reg_login_batch_60d,
    szdf_reg_login_batch_90d,
    szdf_reg_login_batch_180d,
         grass_date 
FROM szdf_reg_login_agg;


msck repair table risk_report.dws_risk_${reg}_group_fraud_device_login_agg_feature_trx_di;
refresh table risk_report.dws_risk_${reg}_group_fraud_device_login_agg_feature_trx_di;
