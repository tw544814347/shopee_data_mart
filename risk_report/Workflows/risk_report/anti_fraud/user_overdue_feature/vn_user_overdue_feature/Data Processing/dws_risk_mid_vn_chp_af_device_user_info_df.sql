--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-10-20
-- Theme Domain：       Anti-fraud user overdue feature
-- Description:         https://jira.shopee.io/browse/SPFDT-56370
-- Data Granularity:    
-- Change Log:
--********************************************************************--
CREATE TABLE IF NOT EXISTS ${SCHEMA}.dws_risk_mid_${reg}_${risk_tab_biz_type}_af_device_user_info_df (
    sz_dfp_device_id                    STRING  COMMENT 'sz dfp device id',
    platform_user_id                    STRING  COMMENT 'platform user id',
    
    has_cpd1                            BIGINT  COMMENT 'flag for current overdue >=1 day',
    has_cpd1_12m                        BIGINT  COMMENT 'flag for current overdue >=1 day in last 12 months',
    has_cpd1_6m                         BIGINT  COMMENT 'flag for current overdue >=1 day in last 6 months',
    has_cpd1_3m                         BIGINT  COMMENT 'flag for current overdue >=1 day in last 3 months',
    has_cpd1_1m                         BIGINT  COMMENT 'flag for current overdue >=1 day in last 1 month',
    
    has_cpd7                            BIGINT  COMMENT 'flag for current overdue >=7 days',
    has_cpd7_12m                        BIGINT  COMMENT 'flag for current overdue >=7 days in last 12 months',
    has_cpd7_6m                         BIGINT  COMMENT 'flag for current overdue >=7 days in last 6 months',
    has_cpd7_3m                         BIGINT  COMMENT 'flag for current overdue >=7 days in last 3 months',
    has_cpd7_1m                         BIGINT  COMMENT 'flag for current overdue >=7 days in last 1 month',
    
    has_cpd30                           BIGINT  COMMENT 'flag for current overdue >=30 days',
    has_cpd30_12m                       BIGINT  COMMENT 'flag for current overdue >=30 days in last 12 months',
    has_cpd30_6m                        BIGINT  COMMENT 'flag for current overdue >=30 days in last 6 months',
    has_cpd30_3m                        BIGINT  COMMENT 'flag for current overdue >=30 days in last 3 months',
    has_cpd30_1m                        BIGINT  COMMENT 'flag for current overdue >=30 days in last 1 month',
    
    has_dpd30_l2y_limit90               BIGINT  COMMENT 'flag for max overdue >=30 days in last 2 years and limit >=90',
    has_dpd30_l2y_limit90_12m           BIGINT  COMMENT 'flag for max overdue >=30 days in last 2 years and limit >=90 in last 12 months',
    has_dpd30_l2y_limit90_6m            BIGINT  COMMENT 'flag for max overdue >=30 days in last 2 years and limit >=90 in last 6 months',
    has_dpd30_l2y_limit90_3m            BIGINT  COMMENT 'flag for max overdue >=30 days in last 2 years and limit >=90 in last 3 months',
    has_dpd30_l2y_limit90_1m            BIGINT  COMMENT 'flag for max overdue >=30 days in last 2 years and limit >=90 in last 1 month'
)
COMMENT 'risk mart summary table'
PARTITIONED BY (grass_date string)
stored as orc tblproperties ("orc.compress" = "zstd")
location '${HDFS_PATH}/dws/dws_risk_mid_${reg}_${risk_tab_biz_type}_af_device_user_info_df'
;

create or replace temp view overdue_tag as (
    SELECT
        overdue_tag.platform_user_id,
        overdue_tag.credit_user_id,
        overdue_tag.flag_cpd1,
        overdue_tag.flag_cpd7,
        overdue_tag.flag_cpd30,
        overdue.flag_dpd30_l2y_limit90
    FROM (
        SELECT
            platform_user_id,
            credit_user_id,
            flag_cpd1,
            flag_cpd7,
            flag_cpd30
        FROM ${SCHEMA}.dws_risk_${reg}_${risk_tab_biz_type}_user_overdue_tag_df
        WHERE grass_date = '${ds}'
    ) overdue_tag
    LEFT JOIN (
        SELECT
            platform_user_id,
            credit_user_id,
            flag_dpd30_l2y_limit90
        FROM ${SCHEMA}.dws_risk_${reg}_${risk_tab_biz_type}_user_overdue_info_df
        WHERE grass_date = '${ds}'
    ) overdue
    ON overdue_tag.platform_user_id = overdue.platform_user_id
    AND overdue_tag.credit_user_id = overdue.credit_user_id
);
CREATE OR REPLACE TEMP VIEW device_user_base AS (
    SELECT DISTINCT 
        platform_user_id,
        sz_dfp_device_id,
        grass_date
    FROM (
        SELECT 
            platform_user_id,
            get_json_object(extension, '$.CommonHeader.extension_process_data.sz_dfp.device_id') AS sz_dfp_device_id,
            grass_date
        FROM risk.dwd_risk_${reg}_strategy_final_result_merge_di
        WHERE grass_date >= '${ds_t_720}' AND grass_date <= '${ds}' AND CAST(scene_id AS STRING) LIKE '100%'
            AND (case when ${biz_type_code} = 3 then app_id IN ('kredit')
                    when ${biz_type_code} = 7 then app_id IN ('chp')
                    when ${biz_type_code} = 1 then app_id IN ('spj')
                    when ${biz_type_code} = 11 then app_id IN ('tl')
                    else false end)
    ) tmp
    WHERE sz_dfp_device_id IS NOT NULL 
        AND sz_dfp_device_id != ''
);


INSERT OVERWRITE TABLE ${SCHEMA}.dws_risk_mid_${reg}_${risk_tab_biz_type}_af_device_user_info_df partition(grass_date = '${ds}')
select 
    sz_dfp_device_id,
    platform_user_id,
    max(has_cpd1) as has_cpd1,
    max(has_cpd1_12m) as has_cpd1_12m,
    max(has_cpd1_6m) as has_cpd1_6m,
    max(has_cpd1_3m) as has_cpd1_3m,
    max(has_cpd1_1m) as has_cpd1_1m,
    max(has_cpd7) as has_cpd7,
    max(has_cpd7_12m) as has_cpd7_12m,
    max(has_cpd7_6m) as has_cpd7_6m,
    max(has_cpd7_3m) as has_cpd7_3m,
    max(has_cpd7_1m) as has_cpd7_1m,
    max(has_cpd30) as has_cpd30,
    max(has_cpd30_12m) as has_cpd30_12m,
    max(has_cpd30_6m) as has_cpd30_6m,
    max(has_cpd30_3m) as has_cpd30_3m,
    max(has_cpd30_1m) as has_cpd30_1m,
    max(has_dpd30_l2y_limit90) as has_dpd30_l2y_limit90,
    max(has_dpd30_l2y_limit90_12m) as has_dpd30_l2y_limit90_12m,
    max(has_dpd30_l2y_limit90_6m) as has_dpd30_l2y_limit90_6m,
    max(has_dpd30_l2y_limit90_3m) as has_dpd30_l2y_limit90_3m,
    max(has_dpd30_l2y_limit90_1m) as has_dpd30_l2y_limit90_1m
from (
    select 
        base.sz_dfp_device_id,
        overdue_tag.platform_user_id,
        case when flag_cpd1 = 1 then 1 else 0 end as has_cpd1,
        case when flag_cpd1 = 1 and base.grass_date >= '${ds_t_360}' then 1 else 0 end as has_cpd1_12m,
        case when flag_cpd1 = 1 and base.grass_date >= '${ds_t_180}' then 1 else 0 end as has_cpd1_6m,
        case when flag_cpd1 = 1 and base.grass_date >= '${ds_t_90}' then 1 else 0 end as has_cpd1_3m,
        case when flag_cpd1 = 1 and base.grass_date >= '${ds_t_30}' then 1 else 0 end as has_cpd1_1m,
        case when flag_cpd7 = 1 then 1 else 0 end as has_cpd7,
        case when flag_cpd7 = 1 and base.grass_date >= '${ds_t_360}' then 1 else 0 end as has_cpd7_12m,
        case when flag_cpd7 = 1 and base.grass_date >= '${ds_t_180}' then 1 else 0 end as has_cpd7_6m,
        case when flag_cpd7 = 1 and base.grass_date >= '${ds_t_90}' then 1 else 0 end as has_cpd7_3m,
        case when flag_cpd7 = 1 and base.grass_date >= '${ds_t_30}' then 1 else 0 end as has_cpd7_1m,
        case when flag_cpd30 = 1 then 1 else 0 end as has_cpd30,
        case when flag_cpd30 = 1 and base.grass_date >= '${ds_t_360}' then 1 else 0 end as has_cpd30_12m,
        case when flag_cpd30 = 1 and base.grass_date >= '${ds_t_180}' then 1 else 0 end as has_cpd30_6m,
        case when flag_cpd30 = 1 and base.grass_date >= '${ds_t_90}' then 1 else 0 end as has_cpd30_3m,
        case when flag_cpd30 = 1 and base.grass_date >= '${ds_t_30}' then 1 else 0 end as has_cpd30_1m,
        case when flag_dpd30_l2y_limit90 = 1 then 1 else 0 end as has_dpd30_l2y_limit90,
        case when flag_dpd30_l2y_limit90 = 1 and base.grass_date >= '${ds_t_360}' then 1 else 0 end as has_dpd30_l2y_limit90_12m,
        case when flag_dpd30_l2y_limit90 = 1 and base.grass_date >= '${ds_t_180}' then 1 else 0 end as has_dpd30_l2y_limit90_6m,
        case when flag_dpd30_l2y_limit90 = 1 and base.grass_date >= '${ds_t_90}' then 1 else 0 end as has_dpd30_l2y_limit90_3m,
        case when flag_dpd30_l2y_limit90 = 1 and base.grass_date >= '${ds_t_30}' then 1 else 0 end as has_dpd30_l2y_limit90_1m
    from overdue_tag
    inner join device_user_base base on base.platform_user_id = overdue_tag.platform_user_id
)
group by sz_dfp_device_id, platform_user_id
distribute by sz_dfp_device_id
;