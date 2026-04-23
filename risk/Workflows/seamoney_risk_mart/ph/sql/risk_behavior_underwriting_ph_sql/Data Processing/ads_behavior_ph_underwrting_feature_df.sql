--********************************************************************--
-- Author:              lisheng@shopee.com
-- Created Time:        2025-09-18
-- Theme Domain：       risk-feature
-- Description:         user_behavior underwirting feature
-- Data Granularity:    credit_user_id
-- 变更历史：
--  v1
--  v2 lihseng@shopee.com, 新增is_limit_decrease_user_180d相关字段, jira: https://jira.shopee.io/browse/SPFDT-55607
--  2025-11-25 wei.tao@shopee.com, 更改 is_limit_decrease_user_180d 底表数据源 dwd_uc_ph_user_uc_tag_info_tab_df
--********************************************************************--

-- DROP TABLE IF EXISTS ${SCHEMA}.ads_behavior_ph_underwrting_feature_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_behavior_ph_underwrting_feature_df
(
    credit_user_id                          STRING
    , shopee_account_status                 STRING COMMENT 'shopee_account_status'
    , average_limit_utilization_3d_spl      DECIMAL(30,10) COMMENT 'spl 3days avg limit_utilization'
    , average_limit_utilization_7d_spl      DECIMAL(30,10) COMMENT 'spl 7days avg limit_utilization'
    , average_limit_utilization_15d_spl     DECIMAL(30,10) COMMENT 'spl 15days avg limit_utilization'
    , average_limit_utilization_30d_spl     DECIMAL(30,10) COMMENT 'spl 30days avg limit_utilization'
    , average_limit_utilization_3d_bcl      DECIMAL(30,10) COMMENT 'bcl 3days avg limit_utilization'
    , average_limit_utilization_7d_bcl      DECIMAL(30,10) COMMENT 'bcl 7days avg limit_utilization'
    , average_limit_utilization_15d_bcl     DECIMAL(30,10) COMMENT 'bcl 15days avg limit_utilization'
    , average_limit_utilization_30d_bcl     DECIMAL(30,10) COMMENT 'bcl 30days avg limit_utilization'
    , max_limit_utilization_30d_spl         DECIMAL(30,10) COMMENT 'spl 30days max limit_utilization'
    , max_limit_utilization_60d_spl         DECIMAL(30,10) COMMENT 'spl 60days max limit_utilization'
    , max_limit_utilization_90d_spl         DECIMAL(30,10) COMMENT 'spl 90days max limit_utilization'
    , max_limit_utilization_180d_spl        DECIMAL(30,10) COMMENT 'spl 180days max limit_utilization'
    , max_limit_utilization_360d_spl        DECIMAL(30,10) COMMENT 'spl 360days max limit_utilization'
    , max_limit_utilization_30d_bcl         DECIMAL(30,10) COMMENT 'bcl 30days max limit_utilization'
    , max_limit_utilization_60d_bcl         DECIMAL(30,10) COMMENT 'bcl 60days max limit_utilization'
    , max_limit_utilization_90d_bcl         DECIMAL(30,10) COMMENT 'bcl 90days max limit_utilization'
    , max_limit_utilization_180d_bcl        DECIMAL(30,10) COMMENT 'bcl 180days max limit_utilization'
    , max_limit_utilization_360d_bcl        DECIMAL(30,10) COMMENT 'bcl 360days max limit_utilization'
    -- v2新增字段：用户限额降低标识
    , is_limit_decrease_user_180d           INT COMMENT 'limit decrease tag for user in 180 days (0=无标签, 1=限额降低, 2=其他标签类型)'
)
PARTITIONED BY
(
    grass_date                              STRING COMMENT 'YYYY-MM-dd'
)
STORED AS ORC TBLPROPERTIES ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_behavior_underwrting_feature_df/grass_region=PH';
-- MSCK REPAIR TABLE dev_risk.ads_behavior_ph_underwrting_feature_df;

CREATE OR REPLACE TEMPORARY VIEW tmp_ph_platform_user_account_status AS
SELECT 
    user_id                                 AS platform_user_id
    , status                                AS shopee_account_status
FROM mp_user.dim_user__reg_s0_live
WHERE tz_type = 'local'
    AND grass_region = 'PH'
    AND grass_date = '${ds}'
;

CREATE OR REPLACE TEMPORARY VIEW tmp_spl_ph_behavior_user AS
SELECT
    credit_user_id
    , SUM(CASE WHEN grass_date >= DATE_SUB('${grass_date}', 3) THEN total_limit_util_spl ELSE 0 END) AS total_limit_utilization_3d_spl
    , SUM(CASE WHEN grass_date >= DATE_SUB('${grass_date}', 7) THEN total_limit_util_spl ELSE 0 END) AS total_limit_utilization_7d_spl
    , SUM(CASE WHEN grass_date >= DATE_SUB('${grass_date}', 15) THEN total_limit_util_spl ELSE 0 END) AS total_limit_utilization_15d_spl
    , SUM(CASE WHEN grass_date >= DATE_SUB('${grass_date}', 30) THEN total_limit_util_spl ELSE 0 END) AS total_limit_utilization_30d_spl
    , COUNT(DISTINCT CASE WHEN grass_date >= DATE_SUB('${grass_date}', 3) THEN grass_date ELSE NULL END) AS grass_date_cnt_3d_spl
    , COUNT(DISTINCT CASE WHEN grass_date >= DATE_SUB('${grass_date}', 7) THEN grass_date ELSE NULL END) AS grass_date_cnt_7d_spl
    , COUNT(DISTINCT CASE WHEN grass_date >= DATE_SUB('${grass_date}', 15) THEN grass_date ELSE NULL END) AS grass_date_cnt_15d_spl
    , COUNT(DISTINCT CASE WHEN grass_date >= DATE_SUB('${grass_date}', 30) THEN grass_date ELSE NULL END) AS grass_date_cnt_30d_spl
    , MAX(CASE WHEN grass_date >= DATE_SUB('${grass_date}', 30) THEN total_limit_util_spl ELSE 0 END) AS max_limit_utilization_30d_spl
    , MAX(CASE WHEN grass_date >= DATE_SUB('${grass_date}', 60) THEN total_limit_util_spl ELSE 0 END) AS max_limit_utilization_60d_spl
    , MAX(CASE WHEN grass_date >= DATE_SUB('${grass_date}', 90) THEN total_limit_util_spl ELSE 0 END) AS max_limit_utilization_90d_spl
    , MAX(CASE WHEN grass_date >= DATE_SUB('${grass_date}', 180) THEN total_limit_util_spl ELSE 0 END) AS max_limit_utilization_180d_spl
    , MAX(CASE WHEN grass_date >= DATE_SUB('${grass_date}', 360) THEN total_limit_util_spl ELSE 0 END) AS max_limit_utilization_360d_spl
FROM (
    SELECT 
        credit_user_id                      AS credit_user_id
        , -- total_user_credit_utilisation      
        (
            COALESCE(common_perm_used_credit_amount, 0) +
            COALESCE(common_temp_used_credit_amount, 0) +
            COALESCE(installment_perm_used_credit_amount, 0) +
            -- COALESCE(lite_used_credit_amount, 0) +
            COALESCE(common_perm_frozen_credit_amount, 0) +
            COALESCE(common_temp_frozen_credit_amount, 0) +
            COALESCE(installment_perm_frozen_credit_amount, 0) 
            -- COALESCE(lite_frozen_credit_amount, 0)
        ) / (
            COALESCE(common_perm_credit_limit, 0) +
            COALESCE(common_temp_credit_limit, 0) +
            COALESCE(installment_perm_credit_limit, 0) 
            -- COALESCE(lite_credit_limit, 0)
        )                                   AS total_limit_util_spl
        , grass_date                        AS grass_date
    FROM credit_mart.dws_spl_ph_account_df
    WHERE COALESCE(common_perm_credit_limit, 0) + COALESCE(common_temp_credit_limit, 0) + COALESCE(installment_perm_credit_limit, 0) -- + COALESCE(lite_credit_limit, 0) 
        > 0
        AND biz_type = 3
        AND grass_date >= DATE_SUB('${grass_date}', 180)
) a 
GROUP BY credit_user_id
;

CREATE OR REPLACE TEMPORARY VIEW tmp_bcl_ph_behavior_user AS
SELECT
    credit_user_id
    , SUM(CASE WHEN grass_date >= DATE_SUB('${grass_date}', 3) THEN total_limit_util_bcl ELSE 0 END) AS total_limit_utilization_3d_bcl
    , SUM(CASE WHEN grass_date >= DATE_SUB('${grass_date}', 7) THEN total_limit_util_bcl ELSE 0 END) AS total_limit_utilization_7d_bcl
    , SUM(CASE WHEN grass_date >= DATE_SUB('${grass_date}', 15) THEN total_limit_util_bcl ELSE 0 END) AS total_limit_utilization_15d_bcl
    , SUM(CASE WHEN grass_date >= DATE_SUB('${grass_date}', 30) THEN total_limit_util_bcl ELSE 0 END) AS total_limit_utilization_30d_bcl
    , COUNT(DISTINCT CASE WHEN grass_date >= DATE_SUB('${grass_date}', 3) THEN grass_date ELSE NULL END) AS grass_date_cnt_3d_bcl
    , COUNT(DISTINCT CASE WHEN grass_date >= DATE_SUB('${grass_date}', 7) THEN grass_date ELSE NULL END) AS grass_date_cnt_7d_bcl
    , COUNT(DISTINCT CASE WHEN grass_date >= DATE_SUB('${grass_date}', 15) THEN grass_date ELSE NULL END) AS grass_date_cnt_15d_bcl
    , COUNT(DISTINCT CASE WHEN grass_date >= DATE_SUB('${grass_date}', 30) THEN grass_date ELSE NULL END) AS grass_date_cnt_30d_bcl
    , MAX(CASE WHEN grass_date >= DATE_SUB('${grass_date}', 30) THEN total_limit_util_bcl ELSE 0 END) AS max_limit_utilization_30d_bcl
    , MAX(CASE WHEN grass_date >= DATE_SUB('${grass_date}', 60) THEN total_limit_util_bcl ELSE 0 END) AS max_limit_utilization_60d_bcl
    , MAX(CASE WHEN grass_date >= DATE_SUB('${grass_date}', 90) THEN total_limit_util_bcl ELSE 0 END) AS max_limit_utilization_90d_bcl
    , MAX(CASE WHEN grass_date >= DATE_SUB('${grass_date}', 180) THEN total_limit_util_bcl ELSE 0 END) AS max_limit_utilization_180d_bcl
    , MAX(CASE WHEN grass_date >= DATE_SUB('${grass_date}', 360) THEN total_limit_util_bcl ELSE 0 END) AS max_limit_utilization_360d_bcl
FROM (
    SELECT 
        credit_user_id                      AS credit_user_id
        , -- total_user_credit_utilisation      
        (
            COALESCE(common_perm_used_credit_amount, 0) +
            COALESCE(common_temp_used_credit_amount, 0) +
            COALESCE(common_perm_frozen_credit_amount, 0) +
            COALESCE(common_temp_frozen_credit_amount, 0)
        ) / (
            COALESCE(common_perm_credit_limit, 0) +
            COALESCE(common_temp_credit_limit, 0)
        )                                   AS total_limit_util_bcl
        , grass_date                        AS grass_date
    FROM credit_mart.dws_bcl_ph_account_df
    WHERE COALESCE(common_perm_credit_limit, 0) + COALESCE(common_temp_credit_limit, 0) > 0
        AND biz_type = 1    
        AND grass_date >= DATE_SUB('${grass_date}', 180)
) a 
GROUP BY credit_user_id
;

INSERT OVERWRITE TABLE ${SCHEMA}.ads_behavior_ph_underwrting_feature_df PARTITION (grass_date='${ds}')
SELECT
    t1.credit_user_id
    , t1.shopee_account_status
    , t2.total_limit_utilization_3d_spl / t2.grass_date_cnt_3d_spl AS average_limit_utilization_3d_spl
    , t2.total_limit_utilization_7d_spl / t2.grass_date_cnt_7d_spl AS average_limit_utilization_7d_spl
    , t2.total_limit_utilization_15d_spl / t2.grass_date_cnt_15d_spl AS average_limit_utilization_15d_spl
    , t2.total_limit_utilization_30d_spl / t2.grass_date_cnt_30d_spl AS average_limit_utilization_30d_spl
    , t3.total_limit_utilization_3d_bcl / t3.grass_date_cnt_3d_bcl AS average_limit_utilization_3d_bcl
    , t3.total_limit_utilization_7d_bcl / t3.grass_date_cnt_7d_bcl AS average_limit_utilization_7d_bcl
    , t3.total_limit_utilization_15d_bcl / t3.grass_date_cnt_15d_bcl AS average_limit_utilization_15d_bcl
    , t3.total_limit_utilization_30d_bcl / t3.grass_date_cnt_30d_bcl AS average_limit_utilization_30d_bcl 
    , t2.max_limit_utilization_30d_spl
    , t2.max_limit_utilization_60d_spl
    , t2.max_limit_utilization_90d_spl
    , t2.max_limit_utilization_180d_spl
    , t2.max_limit_utilization_360d_spl
    , t3.max_limit_utilization_30d_bcl
    , t3.max_limit_utilization_60d_bcl
    , t3.max_limit_utilization_90d_bcl
    , t3.max_limit_utilization_180d_bcl
    , t3.max_limit_utilization_360d_bcl
    -- v2新增：用户180天内限额降低标识字段
    , t4.is_limit_decrease_user_180d
FROM (
    SELECT 
        tt1.credit_user_id
        , MAX(tt1.account_label)            AS account_label
        , MAX(tt2.shopee_account_status)    AS shopee_account_status
    FROM
    (
        SELECT credit_user_id, account_label, platform_user_id FROM credit_uc.dws_spl_ph_uc_user_df WHERE grass_date = '${ds}' 
        UNION 
        SELECT credit_user_id, NULL AS account_label, platform_user_id FROM credit_uc.dws_bcl_ph_uc_user_df WHERE grass_date = '${ds}'
    ) tt1 
    LEFT JOIN tmp_ph_platform_user_account_status tt2 ON tt1.platform_user_id = tt2.platform_user_id 
    GROUP BY tt1.credit_user_id
) t1
LEFT JOIN tmp_spl_ph_behavior_user t2 ON t1.credit_user_id = t2.credit_user_id 
LEFT JOIN tmp_bcl_ph_behavior_user t3 ON t1.credit_user_id = t3.credit_user_id 
-- v2新增：关联用户平台标签信息，获取180天内是否有限额降低标识
LEFT JOIN (
    SELECT 
        credit_user_id
        , CASE 
            WHEN MAX(CASE WHEN tag_type = 9 THEN 1 ELSE 0 END) = 1
                THEN 1
            WHEN MAX(CASE WHEN tag_type IS NOT NULL AND tag_type <> 9 THEN 1 ELSE 0 END) = 1
                THEN 2
            ELSE 0
        END AS is_limit_decrease_user_180d
    FROM credit_uc.dwd_uc_ph_user_uc_tag_info_tab_df
    WHERE grass_date >= DATE_SUB('${ds}', 180)   
        AND grass_date <= '${ds}'
        AND credit_user_id <> '0'                  
        AND credit_user_id IS NOT NULL
    GROUP BY credit_user_id                       
) t4 ON t1.credit_user_id = t4.credit_user_id      
;
