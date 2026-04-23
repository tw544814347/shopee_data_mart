--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-10-20
-- Theme Domain：       Anti-fraud user overdue feature
-- Description:         https://jira.shopee.io/browse/SPFDT-56370
-- Data Granularity:    
-- Change Log:
--********************************************************************--
CREATE TABLE IF NOT EXISTS ${SCHEMA}.dws_risk_mid_${reg}_${risk_tab_biz_type}_szdf_device_user_info_df (
    sz_dfp_device_id                    STRING  COMMENT 'sz dfp device id',
    platform_user_id                    STRING  COMMENT 'platform user id',
    
    has_dpd30                           BIGINT  COMMENT 'flag for days past due >=30',
    has_dpd30_12m                       BIGINT  COMMENT 'flag for days past due >=30 in last 12 months',
    has_dpd30_6m                        BIGINT  COMMENT 'flag for days past due >=30 in last 6 months',
    has_dpd30_3m                        BIGINT  COMMENT 'flag for days past due >=30 in last 3 months',
    has_dpd30_1m                        BIGINT  COMMENT 'flag for days past due >=30 in last 1 month',
    
    has_dpd30_limit90                   BIGINT  COMMENT 'flag for days past due >=30 with limit >=90',
    has_dpd30_limit90_12m               BIGINT  COMMENT 'flag for days past due >=30 with limit >=90 in last 12 months',
    has_dpd30_limit90_6m                BIGINT  COMMENT 'flag for days past due >=30 with limit >=90 in last 6 months',
    has_dpd30_limit90_3m                BIGINT  COMMENT 'flag for days past due >=30 with limit >=90 in last 3 months',
    has_dpd30_limit90_1m                BIGINT  COMMENT 'flag for days past due >=30 with limit >=90 in last 1 month',
    
    has_dpd90                           BIGINT  COMMENT 'flag for days past due >=90',
    has_dpd90_12m                       BIGINT  COMMENT 'flag for days past due >=90 in last 12 months',
    has_dpd90_6m                        BIGINT  COMMENT 'flag for days past due >=90 in last 6 months',
    has_dpd90_3m                        BIGINT  COMMENT 'flag for days past due >=90 in last 3 months',
    has_dpd90_1m                        BIGINT  COMMENT 'flag for days past due >=90 in last 1 month',
    
    has_dpd90_limit90                   BIGINT  COMMENT 'flag for days past due >=90 with limit >=90',
    has_dpd90_limit90_12m               BIGINT  COMMENT 'flag for days past due >=90 with limit >=90 in last 12 months',
    has_dpd90_limit90_6m                BIGINT  COMMENT 'flag for days past due >=90 with limit >=90 in last 6 months',
    has_dpd90_limit90_3m                BIGINT  COMMENT 'flag for days past due >=90 with limit >=90 in last 3 months',
    has_dpd90_limit90_1m                BIGINT  COMMENT 'flag for days past due >=90 with limit >=90 in last 1 month',
    
    has_fpd30                           BIGINT  COMMENT 'flag for first payment delay >=30',
    has_fpd30_12m                       BIGINT  COMMENT 'flag for first payment delay >=30 in last 12 months',
    has_fpd30_6m                        BIGINT  COMMENT 'flag for first payment delay >=30 in last 6 months',
    has_fpd30_3m                        BIGINT  COMMENT 'flag for first payment delay >=30 in last 3 months',
    has_fpd30_1m                        BIGINT  COMMENT 'flag for first payment delay >=30 in last 1 month',
    
    has_fpd30_limit90                   BIGINT  COMMENT 'flag for first payment delay >=30 with limit >=90',
    has_fpd30_limit90_12m               BIGINT  COMMENT 'flag for first payment delay >=30 with limit >=90 in last 12 months',
    has_fpd30_limit90_6m                BIGINT  COMMENT 'flag for first payment delay >=30 with limit >=90 in last 6 months',
    has_fpd30_limit90_3m                BIGINT  COMMENT 'flag for first payment delay >=30 with limit >=90 in last 3 months',
    has_fpd30_limit90_1m                BIGINT  COMMENT 'flag for first payment delay >=30 with limit >=90 in last 1 month',
    
    has_cpd1                            BIGINT  COMMENT 'flag for current overdue >=1 day',
    has_cpd1_12m                        BIGINT  COMMENT 'flag for current overdue >=1 day in last 12 months',
    has_cpd1_6m                         BIGINT  COMMENT 'flag for current overdue >=1 day in last 6 months',
    has_cpd1_3m                         BIGINT  COMMENT 'flag for current overdue >=1 day in last 3 months',
    has_cpd1_1m                         BIGINT  COMMENT 'flag for current overdue >=1 day in last 1 month',
    
    has_cpd1_limit90                    BIGINT  COMMENT 'flag for current overdue >=1 day with limit >=90',
    has_cpd1_limit90_12m                BIGINT  COMMENT 'flag for current overdue >=1 day with limit >=90 in last 12 months',
    has_cpd1_limit90_6m                 BIGINT  COMMENT 'flag for current overdue >=1 day with limit >=90 in last 6 months',
    has_cpd1_limit90_3m                 BIGINT  COMMENT 'flag for current overdue >=1 day with limit >=90 in last 3 months',
    has_cpd1_limit90_1m                 BIGINT  COMMENT 'flag for current overdue >=1 day with limit >=90 in last 1 month',
    
    has_cpd7                            BIGINT  COMMENT 'flag for current overdue >=7 days',
    has_cpd7_12m                        BIGINT  COMMENT 'flag for current overdue >=7 days in last 12 months',
    has_cpd7_6m                         BIGINT  COMMENT 'flag for current overdue >=7 days in last 6 months',
    has_cpd7_3m                         BIGINT  COMMENT 'flag for current overdue >=7 days in last 3 months',
    has_cpd7_1m                         BIGINT  COMMENT 'flag for current overdue >=7 days in last 1 month',
    
    has_cpd7_limit90                    BIGINT  COMMENT 'flag for current overdue >=7 days with limit >=90',
    has_cpd7_limit90_12m                BIGINT  COMMENT 'flag for current overdue >=7 days with limit >=90 in last 12 months',
    has_cpd7_limit90_6m                 BIGINT  COMMENT 'flag for current overdue >=7 days with limit >=90 in last 6 months',
    has_cpd7_limit90_3m                 BIGINT  COMMENT 'flag for current overdue >=7 days with limit >=90 in last 3 months',
    has_cpd7_limit90_1m                 BIGINT  COMMENT 'flag for current overdue >=7 days with limit >=90 in last 1 month',
    
    has_cpd30                           BIGINT  COMMENT 'flag for current overdue >=30 days',
    has_cpd30_12m                       BIGINT  COMMENT 'flag for current overdue >=30 days in last 12 months',
    has_cpd30_6m                        BIGINT  COMMENT 'flag for current overdue >=30 days in last 6 months',
    has_cpd30_3m                        BIGINT  COMMENT 'flag for current overdue >=30 days in last 3 months',
    has_cpd30_1m                        BIGINT  COMMENT 'flag for current overdue >=30 days in last 1 month',
    
    has_cpd30_limit90                   BIGINT  COMMENT 'flag for current overdue >=30 days with limit >=90',
    has_cpd30_limit90_12m               BIGINT  COMMENT 'flag for current overdue >=30 days with limit >=90 in last 12 months',
    has_cpd30_limit90_6m                BIGINT  COMMENT 'flag for current overdue >=30 days with limit >=90 in last 6 months',
    has_cpd30_limit90_3m                BIGINT  COMMENT 'flag for current overdue >=30 days with limit >=90 in last 3 months',
    has_cpd30_limit90_1m                BIGINT  COMMENT 'flag for current overdue >=30 days with limit >=90 in last 1 month',
    
    has_dpd30_l2y                       BIGINT  COMMENT 'flag for max overdue >=30 days in last 2 years',
    has_dpd30_l2y_12m                   BIGINT  COMMENT 'flag for max overdue >=30 days in last 2 years within last 12 months',
    has_dpd30_l2y_6m                    BIGINT  COMMENT 'flag for max overdue >=30 days in last 2 years within last 6 months',
    has_dpd30_l2y_3m                    BIGINT  COMMENT 'flag for max overdue >=30 days in last 2 years within last 3 months',
    has_dpd30_l2y_1m                    BIGINT  COMMENT 'flag for max overdue >=30 days in last 2 years within last 1 month',
    
    has_dpd30_l2y_limit90               BIGINT  COMMENT 'flag for max overdue >=30 days in last 2 years with limit >=90',
    has_dpd30_l2y_limit90_12m           BIGINT  COMMENT 'flag for max overdue >=30 days in last 2 years with limit >=90 in last 12 months',
    has_dpd30_l2y_limit90_6m            BIGINT  COMMENT 'flag for max overdue >=30 days in last 2 years with limit >=90 in last 6 months',
    has_dpd30_l2y_limit90_3m            BIGINT  COMMENT 'flag for max overdue >=30 days in last 2 years with limit >=90 in last 3 months',
    has_dpd30_l2y_limit90_1m            BIGINT  COMMENT 'flag for max overdue >=30 days in last 2 years with limit >=90 in last 1 month'
)
COMMENT 'risk mart summary table'
PARTITIONED BY (grass_date string)
stored as orc tblproperties ("orc.compress" = "zstd")
location '${HDFS_PATH}/dws/dws_risk_mid_${reg}_${risk_tab_biz_type}_szdf_device_user_info_df'
;


create or replace temp view szdf_base_data as (
    select  distinct 
            user_id
            ,sz_dfp_device_id
            ,grass_date
    from    risk.dwd_risk_szdf_login_di
    where   grass_region = upper('${reg}')
      and   tz_type = 'local'
      and   grass_date >= '${ds_t_720}' and grass_date <= '${ds}'
      and   sz_dfp_device_id <> '' and   sz_dfp_device_id is not null
);

create or replace temp view overdue_tag as (
    SELECT
        overdue_tag.platform_user_id,
        overdue_tag.credit_user_id,
        overdue_tag.flag_dpd30,
        overdue_tag.flag_dpd30_limit90,
        overdue_tag.flag_dpd90,
        overdue_tag.flag_dpd90_limit90,
        overdue_tag.flag_fpd30,
        overdue_tag.flag_fpd30_limit90,
        overdue_tag.flag_cpd1,
        overdue_tag.flag_cpd1_limit90,
        overdue_tag.flag_cpd7,
        overdue_tag.flag_cpd7_limit90,
        overdue_tag.flag_cpd30,
        overdue_tag.flag_cpd30_limit90,
        overdue.flag_dpd30_l2y,
        overdue.flag_dpd30_l2y_limit90
    FROM (
        SELECT
            platform_user_id,
            credit_user_id,
            flag_dpd30,
            flag_dpd30_limit90,
            flag_dpd90,
            flag_dpd90_limit90,
            flag_fpd30,
            flag_fpd30_limit90,
            flag_cpd1,
            flag_cpd1_limit90,
            flag_cpd7,
            flag_cpd7_limit90,
            flag_cpd30,
            flag_cpd30_limit90
        FROM ${SCHEMA}.dws_risk_${reg}_${biz_type_string}_user_overdue_tag_df
        WHERE grass_date = '${ds}'
    ) overdue_tag
    LEFT JOIN (
        SELECT
            platform_user_id,
            credit_user_id,
            flag_dpd30_l2y,
            flag_dpd30_l2y_limit90
        FROM ${SCHEMA}.dws_risk_${reg}_${biz_type_string}_user_overdue_info_df
        WHERE grass_date = '${ds}'
    ) overdue
    ON overdue_tag.platform_user_id = overdue.platform_user_id
    AND overdue_tag.credit_user_id = overdue.credit_user_id
);


INSERT OVERWRITE TABLE ${SCHEMA}.dws_risk_mid_${reg}_${risk_tab_biz_type}_szdf_device_user_info_df partition(grass_date = '${ds}')
select 
    sz_dfp_device_id,
    platform_user_id,
    max(has_dpd30) as has_dpd30,
    max(has_dpd30_12m) as has_dpd30_12m,
    max(has_dpd30_6m) as has_dpd30_6m,
    max(has_dpd30_3m) as has_dpd30_3m,
    max(has_dpd30_1m) as has_dpd30_1m,
    max(has_dpd30_limit90) as has_dpd30_limit90,
    max(has_dpd30_limit90_12m) as has_dpd30_limit90_12m,
    max(has_dpd30_limit90_6m) as has_dpd30_limit90_6m,
    max(has_dpd30_limit90_3m) as has_dpd30_limit90_3m,
    max(has_dpd30_limit90_1m) as has_dpd30_limit90_1m,
    max(has_dpd90) as has_dpd90,
    max(has_dpd90_12m) as has_dpd90_12m,
    max(has_dpd90_6m) as has_dpd90_6m,
    max(has_dpd90_3m) as has_dpd90_3m,
    max(has_dpd90_1m) as has_dpd90_1m,
    max(has_dpd90_limit90) as has_dpd90_limit90,
    max(has_dpd90_limit90_12m) as has_dpd90_limit90_12m,
    max(has_dpd90_limit90_6m) as has_dpd90_limit90_6m,
    max(has_dpd90_limit90_3m) as has_dpd90_limit90_3m,
    max(has_dpd90_limit90_1m) as has_dpd90_limit90_1m,
    max(has_fpd30) as has_fpd30,
    max(has_fpd30_12m) as has_fpd30_12m,
    max(has_fpd30_6m) as has_fpd30_6m,
    max(has_fpd30_3m) as has_fpd30_3m,
    max(has_fpd30_1m) as has_fpd30_1m,
    max(has_fpd30_limit90) as has_fpd30_limit90,
    max(has_fpd30_limit90_12m) as has_fpd30_limit90_12m,
    max(has_fpd30_limit90_6m) as has_fpd30_limit90_6m,
    max(has_fpd30_limit90_3m) as has_fpd30_limit90_3m,
    max(has_fpd30_limit90_1m) as has_fpd30_limit90_1m,
    max(has_cpd1) as has_cpd1,
    max(has_cpd1_12m) as has_cpd1_12m,
    max(has_cpd1_6m) as has_cpd1_6m,
    max(has_cpd1_3m) as has_cpd1_3m,
    max(has_cpd1_1m) as has_cpd1_1m,
    max(has_cpd1_limit90) as has_cpd1_limit90,
    max(has_cpd1_limit90_12m) as has_cpd1_limit90_12m,
    max(has_cpd1_limit90_6m) as has_cpd1_limit90_6m,
    max(has_cpd1_limit90_3m) as has_cpd1_limit90_3m,
    max(has_cpd1_limit90_1m) as has_cpd1_limit90_1m,
    max(has_cpd7) as has_cpd7,
    max(has_cpd7_12m) as has_cpd7_12m,
    max(has_cpd7_6m) as has_cpd7_6m,
    max(has_cpd7_3m) as has_cpd7_3m,
    max(has_cpd7_1m) as has_cpd7_1m,
    max(has_cpd7_limit90) as has_cpd7_limit90,
    max(has_cpd7_limit90_12m) as has_cpd7_limit90_12m,
    max(has_cpd7_limit90_6m) as has_cpd7_limit90_6m,
    max(has_cpd7_limit90_3m) as has_cpd7_limit90_3m,
    max(has_cpd7_limit90_1m) as has_cpd7_limit90_1m,
    max(has_cpd30) as has_cpd30,
    max(has_cpd30_12m) as has_cpd30_12m,
    max(has_cpd30_6m) as has_cpd30_6m,
    max(has_cpd30_3m) as has_cpd30_3m,
    max(has_cpd30_1m) as has_cpd30_1m,
    max(has_cpd30_limit90) as has_cpd30_limit90,
    max(has_cpd30_limit90_12m) as has_cpd30_limit90_12m,
    max(has_cpd30_limit90_6m) as has_cpd30_limit90_6m,
    max(has_cpd30_limit90_3m) as has_cpd30_limit90_3m,
    max(has_cpd30_limit90_1m) as has_cpd30_limit90_1m,
    max(has_dpd30_l2y) as has_dpd30_l2y,
    max(has_dpd30_l2y_12m) as has_dpd30_l2y_12m,
    max(has_dpd30_l2y_6m) as has_dpd30_l2y_6m,
    max(has_dpd30_l2y_3m) as has_dpd30_l2y_3m,
    max(has_dpd30_l2y_1m) as has_dpd30_l2y_1m,
    max(has_dpd30_l2y_limit90) as has_dpd30_l2y_limit90,
    max(has_dpd30_l2y_limit90_12m) as has_dpd30_l2y_limit90_12m,
    max(has_dpd30_l2y_limit90_6m) as has_dpd30_l2y_limit90_6m,
    max(has_dpd30_l2y_limit90_3m) as has_dpd30_l2y_limit90_3m,
    max(has_dpd30_l2y_limit90_1m) as has_dpd30_l2y_limit90_1m
from (
    select 
        base.sz_dfp_device_id,
        overdue_tag.platform_user_id,
        case when flag_dpd30 = 1 then 1 else 0 end as has_dpd30,
        case when flag_dpd30 = 1 and base.grass_date >= '${ds_t_360}' then 1 else 0 end as has_dpd30_12m,
        case when flag_dpd30 = 1 and base.grass_date >= '${ds_t_180}' then 1 else 0 end as has_dpd30_6m,
        case when flag_dpd30 = 1 and base.grass_date >= '${ds_t_90}' then 1 else 0 end as has_dpd30_3m,
        case when flag_dpd30 = 1 and base.grass_date >= '${ds_t_30}' then 1 else 0 end as has_dpd30_1m,
        
        case when flag_dpd30_limit90 = 1 then 1 else 0 end as has_dpd30_limit90,
        case when flag_dpd30_limit90 = 1 and base.grass_date >= '${ds_t_360}' then 1 else 0 end as has_dpd30_limit90_12m,
        case when flag_dpd30_limit90 = 1 and base.grass_date >= '${ds_t_180}' then 1 else 0 end as has_dpd30_limit90_6m,
        case when flag_dpd30_limit90 = 1 and base.grass_date >= '${ds_t_90}' then 1 else 0 end as has_dpd30_limit90_3m,
        case when flag_dpd30_limit90 = 1 and base.grass_date >= '${ds_t_30}' then 1 else 0 end as has_dpd30_limit90_1m,
        
        case when flag_dpd90 = 1 then 1 else 0 end as has_dpd90,
        case when flag_dpd90 = 1 and base.grass_date >= '${ds_t_360}' then 1 else 0 end as has_dpd90_12m,
        case when flag_dpd90 = 1 and base.grass_date >= '${ds_t_180}' then 1 else 0 end as has_dpd90_6m,
        case when flag_dpd90 = 1 and base.grass_date >= '${ds_t_90}' then 1 else 0 end as has_dpd90_3m,
        case when flag_dpd90 = 1 and base.grass_date >= '${ds_t_30}' then 1 else 0 end as has_dpd90_1m,
        
        case when flag_dpd90_limit90 = 1 then 1 else 0 end as has_dpd90_limit90,
        case when flag_dpd90_limit90 = 1 and base.grass_date >= '${ds_t_360}' then 1 else 0 end as has_dpd90_limit90_12m,
        case when flag_dpd90_limit90 = 1 and base.grass_date >= '${ds_t_180}' then 1 else 0 end as has_dpd90_limit90_6m,
        case when flag_dpd90_limit90 = 1 and base.grass_date >= '${ds_t_90}' then 1 else 0 end as has_dpd90_limit90_3m,
        case when flag_dpd90_limit90 = 1 and base.grass_date >= '${ds_t_30}' then 1 else 0 end as has_dpd90_limit90_1m,
        
        case when flag_fpd30 = 1 then 1 else 0 end as has_fpd30,
        case when flag_fpd30 = 1 and base.grass_date >= '${ds_t_360}' then 1 else 0 end as has_fpd30_12m,
        case when flag_fpd30 = 1 and base.grass_date >= '${ds_t_180}' then 1 else 0 end as has_fpd30_6m,
        case when flag_fpd30 = 1 and base.grass_date >= '${ds_t_90}' then 1 else 0 end as has_fpd30_3m,
        case when flag_fpd30 = 1 and base.grass_date >= '${ds_t_30}' then 1 else 0 end as has_fpd30_1m,
        
        case when flag_fpd30_limit90 = 1 then 1 else 0 end as has_fpd30_limit90,
        case when flag_fpd30_limit90 = 1 and base.grass_date >= '${ds_t_360}' then 1 else 0 end as has_fpd30_limit90_12m,
        case when flag_fpd30_limit90 = 1 and base.grass_date >= '${ds_t_180}' then 1 else 0 end as has_fpd30_limit90_6m,
        case when flag_fpd30_limit90 = 1 and base.grass_date >= '${ds_t_90}' then 1 else 0 end as has_fpd30_limit90_3m,
        case when flag_fpd30_limit90 = 1 and base.grass_date >= '${ds_t_30}' then 1 else 0 end as has_fpd30_limit90_1m,
        
        case when flag_cpd1 = 1 then 1 else 0 end as has_cpd1,
        case when flag_cpd1 = 1 and base.grass_date >= '${ds_t_360}' then 1 else 0 end as has_cpd1_12m,
        case when flag_cpd1 = 1 and base.grass_date >= '${ds_t_180}' then 1 else 0 end as has_cpd1_6m,
        case when flag_cpd1 = 1 and base.grass_date >= '${ds_t_90}' then 1 else 0 end as has_cpd1_3m,
        case when flag_cpd1 = 1 and base.grass_date >= '${ds_t_30}' then 1 else 0 end as has_cpd1_1m,
        
        case when flag_cpd1_limit90 = 1 then 1 else 0 end as has_cpd1_limit90,
        case when flag_cpd1_limit90 = 1 and base.grass_date >= '${ds_t_360}' then 1 else 0 end as has_cpd1_limit90_12m,
        case when flag_cpd1_limit90 = 1 and base.grass_date >= '${ds_t_180}' then 1 else 0 end as has_cpd1_limit90_6m,
        case when flag_cpd1_limit90 = 1 and base.grass_date >= '${ds_t_90}' then 1 else 0 end as has_cpd1_limit90_3m,
        case when flag_cpd1_limit90 = 1 and base.grass_date >= '${ds_t_30}' then 1 else 0 end as has_cpd1_limit90_1m,
        
        case when flag_cpd7 = 1 then 1 else 0 end as has_cpd7,
        case when flag_cpd7 = 1 and base.grass_date >= '${ds_t_360}' then 1 else 0 end as has_cpd7_12m,
        case when flag_cpd7 = 1 and base.grass_date >= '${ds_t_180}' then 1 else 0 end as has_cpd7_6m,
        case when flag_cpd7 = 1 and base.grass_date >= '${ds_t_90}' then 1 else 0 end as has_cpd7_3m,
        case when flag_cpd7 = 1 and base.grass_date >= '${ds_t_30}' then 1 else 0 end as has_cpd7_1m,
        
        case when flag_cpd7_limit90 = 1 then 1 else 0 end as has_cpd7_limit90,
        case when flag_cpd7_limit90 = 1 and base.grass_date >= '${ds_t_360}' then 1 else 0 end as has_cpd7_limit90_12m,
        case when flag_cpd7_limit90 = 1 and base.grass_date >= '${ds_t_180}' then 1 else 0 end as has_cpd7_limit90_6m,
        case when flag_cpd7_limit90 = 1 and base.grass_date >= '${ds_t_90}' then 1 else 0 end as has_cpd7_limit90_3m,
        case when flag_cpd7_limit90 = 1 and base.grass_date >= '${ds_t_30}' then 1 else 0 end as has_cpd7_limit90_1m,
        
        case when flag_cpd30 = 1 then 1 else 0 end as has_cpd30,
        case when flag_cpd30 = 1 and base.grass_date >= '${ds_t_360}' then 1 else 0 end as has_cpd30_12m,
        case when flag_cpd30 = 1 and base.grass_date >= '${ds_t_180}' then 1 else 0 end as has_cpd30_6m,
        case when flag_cpd30 = 1 and base.grass_date >= '${ds_t_90}' then 1 else 0 end as has_cpd30_3m,
        case when flag_cpd30 = 1 and base.grass_date >= '${ds_t_30}' then 1 else 0 end as has_cpd30_1m,
        
        case when flag_cpd30_limit90 = 1 then 1 else 0 end as has_cpd30_limit90,
        case when flag_cpd30_limit90 = 1 and base.grass_date >= '${ds_t_360}' then 1 else 0 end as has_cpd30_limit90_12m,
        case when flag_cpd30_limit90 = 1 and base.grass_date >= '${ds_t_180}' then 1 else 0 end as has_cpd30_limit90_6m,
        case when flag_cpd30_limit90 = 1 and base.grass_date >= '${ds_t_90}' then 1 else 0 end as has_cpd30_limit90_3m,
        case when flag_cpd30_limit90 = 1 and base.grass_date >= '${ds_t_30}' then 1 else 0 end as has_cpd30_limit90_1m,
        
        case when flag_dpd30_l2y = 1 then 1 else 0 end as has_dpd30_l2y,
        case when flag_dpd30_l2y = 1 and base.grass_date >= '${ds_t_360}' then 1 else 0 end as has_dpd30_l2y_12m,
        case when flag_dpd30_l2y = 1 and base.grass_date >= '${ds_t_180}' then 1 else 0 end as has_dpd30_l2y_6m,
        case when flag_dpd30_l2y = 1 and base.grass_date >= '${ds_t_90}' then 1 else 0 end as has_dpd30_l2y_3m,
        case when flag_dpd30_l2y = 1 and base.grass_date >= '${ds_t_30}' then 1 else 0 end as has_dpd30_l2y_1m,
        
        case when flag_dpd30_l2y_limit90 = 1 then 1 else 0 end as has_dpd30_l2y_limit90,
        case when flag_dpd30_l2y_limit90 = 1 and base.grass_date >= '${ds_t_360}' then 1 else 0 end as has_dpd30_l2y_limit90_12m,
        case when flag_dpd30_l2y_limit90 = 1 and base.grass_date >= '${ds_t_180}' then 1 else 0 end as has_dpd30_l2y_limit90_6m,
        case when flag_dpd30_l2y_limit90 = 1 and base.grass_date >= '${ds_t_90}' then 1 else 0 end as has_dpd30_l2y_limit90_3m,
        case when flag_dpd30_l2y_limit90 = 1 and base.grass_date >= '${ds_t_30}' then 1 else 0 end as has_dpd30_l2y_limit90_1m
    from overdue_tag
    inner join szdf_base_data base
        on base.user_id = overdue_tag.platform_user_id
)
group by sz_dfp_device_id, platform_user_id
distribute by sz_dfp_device_id
;