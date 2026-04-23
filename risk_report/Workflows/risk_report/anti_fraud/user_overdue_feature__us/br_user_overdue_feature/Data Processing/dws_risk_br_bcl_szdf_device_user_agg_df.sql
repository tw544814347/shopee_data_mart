--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-10-20
-- Theme Domain：       Anti-fraud user overdue feature
-- Description:         https://jira.shopee.io/browse/SPFDT-56370
-- Data Granularity:    
-- Change Log:
--********************************************************************--
CREATE TABLE IF NOT EXISTS ${SCHEMA}.dws_risk_${reg}_${risk_tab_biz_type}_szdf_device_user_agg_df (
    sz_dfp_device_id                       STRING         COMMENT 'sz_dfp_device_id',

    cnt_user_dpd30_l24m                    BIGINT         COMMENT 'cnt users with historical max overdue >=30 days in last 24 months',
    cnt_user_dpd30_l12m                    BIGINT         COMMENT 'cnt users with historical max overdue >=30 days in last 12 months',
    cnt_user_dpd30_l6m                     BIGINT         COMMENT 'cnt users with historical max overdue >=30 days in last 6 months',
    cnt_user_dpd30_l3m                     BIGINT         COMMENT 'cnt users with historical max overdue >=30 days in last 3 months',
    cnt_user_dpd30_l1m                     BIGINT         COMMENT 'cnt users with historical max overdue >=30 days in last 1 month',
    cnt_user_dpd30_limit90_l24m            BIGINT         COMMENT 'cnt users with historical max overdue >=30 days and limit >=90 in last 24 months',
    cnt_user_dpd30_limit90_l12m            BIGINT         COMMENT 'cnt users with historical max overdue >=30 days and limit >=90 in last 12 months',
    cnt_user_dpd30_limit90_l6m             BIGINT         COMMENT 'cnt users with historical max overdue >=30 days and limit >=90 in last 6 months',
    cnt_user_dpd30_limit90_l3m             BIGINT         COMMENT 'cnt users with historical max overdue >=30 days and limit >=90 in last 3 months',
    cnt_user_dpd30_limit90_l1m             BIGINT         COMMENT 'cnt users with historical max overdue >=30 days and limit >=90 in last 1 month',
    cnt_user_dpd90_l24m                    BIGINT         COMMENT 'cnt users with historical max overdue >=90 days in last 24 months',
    cnt_user_dpd90_l12m                    BIGINT         COMMENT 'cnt users with historical max overdue >=90 days in last 12 months',
    cnt_user_dpd90_l6m                     BIGINT         COMMENT 'cnt users with historical max overdue >=90 days in last 6 months',
    cnt_user_dpd90_l3m                     BIGINT         COMMENT 'cnt users with historical max overdue >=90 days in last 3 months',
    cnt_user_dpd90_l1m                     BIGINT         COMMENT 'cnt users with historical max overdue >=90 days in last 1 month',
    cnt_user_dpd90_limit90_l24m            BIGINT         COMMENT 'cnt users with historical max overdue >=90 days and limit >=90 in last 24 months',
    cnt_user_dpd90_limit90_l12m            BIGINT         COMMENT 'cnt users with historical max overdue >=90 days and limit >=90 in last 12 months',
    cnt_user_dpd90_limit90_l6m             BIGINT         COMMENT 'cnt users with historical max overdue >=90 days and limit >=90 in last 6 months',
    cnt_user_dpd90_limit90_l3m             BIGINT         COMMENT 'cnt users with historical max overdue >=90 days and limit >=90 in last 3 months',
    cnt_user_dpd90_limit90_l1m             BIGINT         COMMENT 'cnt users with historical max overdue >=90 days and limit >=90 in last 1 month',
    cnt_user_fpd30_l24m                    BIGINT         COMMENT 'cnt users with first period overdue >=30 days in last 24 months',
    cnt_user_fpd30_l12m                    BIGINT         COMMENT 'cnt users with first period overdue >=30 days in last 12 months',
    cnt_user_fpd30_l6m                     BIGINT         COMMENT 'cnt users with first period overdue >=30 days in last 6 months',
    cnt_user_fpd30_l3m                     BIGINT         COMMENT 'cnt users with first period overdue >=30 days in last 3 months',
    cnt_user_fpd30_l1m                     BIGINT         COMMENT 'cnt users with first period overdue >=30 days in last 1 month',
    cnt_user_fpd30_limit90_l24m            BIGINT         COMMENT 'cnt users with first period overdue >=30 days and limit >=90 in last 24 months',
    cnt_user_fpd30_limit90_l12m            BIGINT         COMMENT 'cnt users with first period overdue >=30 days and limit >=90 in last 12 months',
    cnt_user_fpd30_limit90_l6m             BIGINT         COMMENT 'cnt users with first period overdue >=30 days and limit >=90 in last 6 months',
    cnt_user_fpd30_limit90_l3m             BIGINT         COMMENT 'cnt users with first period overdue >=30 days and limit >=90 in last 3 months',
    cnt_user_fpd30_limit90_l1m             BIGINT         COMMENT 'cnt users with first period overdue >=30 days and limit >=90 in last 1 month',
    cnt_user_cpd1_l24m                     BIGINT         COMMENT 'cnt users with current overdue >=1 day in last 24 months',
    cnt_user_cpd1_l12m                     BIGINT         COMMENT 'cnt users with current overdue >=1 day in last 12 months',
    cnt_user_cpd1_l6m                      BIGINT         COMMENT 'cnt users with current overdue >=1 day in last 6 months',
    cnt_user_cpd1_l3m                      BIGINT         COMMENT 'cnt users with current overdue >=1 day in last 3 months',
    cnt_user_cpd1_l1m                      BIGINT         COMMENT 'cnt users with current overdue >=1 day in last 1 month',
    cnt_user_cpd1_limit90_l24m             BIGINT         COMMENT 'cnt users with current overdue >=1 day and limit >=90 in last 24 months',
    cnt_user_cpd1_limit90_l12m             BIGINT         COMMENT 'cnt users with current overdue >=1 day and limit >=90 in last 12 months',
    cnt_user_cpd1_limit90_l6m              BIGINT         COMMENT 'cnt users with current overdue >=1 day and limit >=90 in last 6 months',
    cnt_user_cpd1_limit90_l3m              BIGINT         COMMENT 'cnt users with current overdue >=1 day and limit >=90 in last 3 months',
    cnt_user_cpd1_limit90_l1m              BIGINT         COMMENT 'cnt users with current overdue >=1 day and limit >=90 in last 1 month',
    cnt_user_cpd7_l24m                     BIGINT         COMMENT 'cnt users with current overdue >=7 days in last 24 months',
    cnt_user_cpd7_l12m                     BIGINT         COMMENT 'cnt users with current overdue >=7 days in last 12 months',
    cnt_user_cpd7_l6m                      BIGINT         COMMENT 'cnt users with current overdue >=7 days in last 6 months',
    cnt_user_cpd7_l3m                      BIGINT         COMMENT 'cnt users with current overdue >=7 days in last 3 months',
    cnt_user_cpd7_l1m                      BIGINT         COMMENT 'cnt users with current overdue >=7 days in last 1 month',
    cnt_user_cpd7_limit90_l24m             BIGINT         COMMENT 'cnt users with current overdue >=7 days and limit >=90 in last 24 months',
    cnt_user_cpd7_limit90_l12m             BIGINT         COMMENT 'cnt users with current overdue >=7 days and limit >=90 in last 12 months',
    cnt_user_cpd7_limit90_l6m              BIGINT         COMMENT 'cnt users with current overdue >=7 days and limit >=90 in last 6 months',
    cnt_user_cpd7_limit90_l3m              BIGINT         COMMENT 'cnt users with current overdue >=7 days and limit >=90 in last 3 months',
    cnt_user_cpd7_limit90_l1m              BIGINT         COMMENT 'cnt users with current overdue >=7 days and limit >=90 in last 1 month',
    cnt_user_cpd30_l24m                    BIGINT         COMMENT 'cnt users with current overdue >=30 days in last 24 months',
    cnt_user_cpd30_l12m                    BIGINT         COMMENT 'cnt users with current overdue >=30 days in last 12 months',
    cnt_user_cpd30_l6m                     BIGINT         COMMENT 'cnt users with current overdue >=30 days in last 6 months',
    cnt_user_cpd30_l3m                     BIGINT         COMMENT 'cnt users with current overdue >=30 days in last 3 months',
    cnt_user_cpd30_l1m                     BIGINT         COMMENT 'cnt users with current overdue >=30 days in last 1 month',
    cnt_user_cpd30_limit90_l24m            BIGINT         COMMENT 'cnt users with current overdue >=30 days and limit >=90 in last 24 months',
    cnt_user_cpd30_limit90_l12m            BIGINT         COMMENT 'cnt users with current overdue >=30 days and limit >=90 in last 12 months',
    cnt_user_cpd30_limit90_l6m             BIGINT         COMMENT 'cnt users with current overdue >=30 days and limit >=90 in last 6 months',
    cnt_user_cpd30_limit90_l3m             BIGINT         COMMENT 'cnt users with current overdue >=30 days and limit >=90 in last 3 months',
    cnt_user_cpd30_limit90_l1m             BIGINT         COMMENT 'cnt users with current overdue >=30 days and limit >=90 in last 1 month',
    cnt_user_dpd30_l2y_l24m                BIGINT         COMMENT 'cnt users with max overdue >=30 days in last 2 years within last 24 months',
    cnt_user_dpd30_l2y_l12m                BIGINT         COMMENT 'cnt users with max overdue >=30 days in last 2 years within last 12 months',
    cnt_user_dpd30_l2y_l6m                 BIGINT         COMMENT 'cnt users with max overdue >=30 days in last 2 years within last 6 months',
    cnt_user_dpd30_l2y_l3m                 BIGINT         COMMENT 'cnt users with max overdue >=30 days in last 2 years within last 3 months',
    cnt_user_dpd30_l2y_l1m                 BIGINT         COMMENT 'cnt users with max overdue >=30 days in last 2 years within last 1 month',
    cnt_user_dpd30_l2y_limit90_l24m        BIGINT         COMMENT 'cnt users with max overdue >=30 days in last 2 years and limit >=90 within last 24 months',
    cnt_user_dpd30_l2y_limit90_l12m        BIGINT         COMMENT 'cnt users with max overdue >=30 days in last 2 years and limit >=90 within last 12 months',
    cnt_user_dpd30_l2y_limit90_l6m         BIGINT         COMMENT 'cnt users with max overdue >=30 days in last 2 years and limit >=90 within last 6 months',
    cnt_user_dpd30_l2y_limit90_l3m         BIGINT         COMMENT 'cnt users with max overdue >=30 days in last 2 years and limit >=90 within last 3 months',
    cnt_user_dpd30_l2y_limit90_l1m         BIGINT         COMMENT 'cnt users with max overdue >=30 days in last 2 years and limit >=90 within last 1 month'
) 
COMMENT 'risk mart summary table'
PARTITIONED BY (grass_date string)
stored as orc tblproperties ("orc.compress" = "zstd")
location '${HDFS_PATH}/dws/dws_risk_${reg}_aio_szdf_device_user_agg_df/product_id = ${biz_type_code}'
;


create or replace temp view ${biz_type_string}_login_agg as (
    select 
        sz_dfp_device_id,
        sum(has_dpd30) as cnt_user_dpd30_l24m,
        sum(has_dpd30_12m) as cnt_user_dpd30_l12m,
        sum(has_dpd30_6m) as cnt_user_dpd30_l6m,
        sum(has_dpd30_3m) as cnt_user_dpd30_l3m,
        sum(has_dpd30_1m) as cnt_user_dpd30_l1m,
        
        sum(has_dpd30_limit90) as cnt_user_dpd30_limit90_l24m,
        sum(has_dpd30_limit90_12m) as cnt_user_dpd30_limit90_l12m,
        sum(has_dpd30_limit90_6m) as cnt_user_dpd30_limit90_l6m,
        sum(has_dpd30_limit90_3m) as cnt_user_dpd30_limit90_l3m,
        sum(has_dpd30_limit90_1m) as cnt_user_dpd30_limit90_l1m,
        
        sum(has_dpd90) as cnt_user_dpd90_l24m,
        sum(has_dpd90_12m) as cnt_user_dpd90_l12m,
        sum(has_dpd90_6m) as cnt_user_dpd90_l6m,
        sum(has_dpd90_3m) as cnt_user_dpd90_l3m,
        sum(has_dpd90_1m) as cnt_user_dpd90_l1m,
        
        sum(has_dpd90_limit90) as cnt_user_dpd90_limit90_l24m,
        sum(has_dpd90_limit90_12m) as cnt_user_dpd90_limit90_l12m,
        sum(has_dpd90_limit90_6m) as cnt_user_dpd90_limit90_l6m,
        sum(has_dpd90_limit90_3m) as cnt_user_dpd90_limit90_l3m,
        sum(has_dpd90_limit90_1m) as cnt_user_dpd90_limit90_l1m,
        
        sum(has_fpd30) as cnt_user_fpd30_l24m,
        sum(has_fpd30_12m) as cnt_user_fpd30_l12m,
        sum(has_fpd30_6m) as cnt_user_fpd30_l6m,
        sum(has_fpd30_3m) as cnt_user_fpd30_l3m,
        sum(has_fpd30_1m) as cnt_user_fpd30_l1m,
        
        sum(has_fpd30_limit90) as cnt_user_fpd30_limit90_l24m,
        sum(has_fpd30_limit90_12m) as cnt_user_fpd30_limit90_l12m,
        sum(has_fpd30_limit90_6m) as cnt_user_fpd30_limit90_l6m,
        sum(has_fpd30_limit90_3m) as cnt_user_fpd30_limit90_l3m,
        sum(has_fpd30_limit90_1m) as cnt_user_fpd30_limit90_l1m,
        
        sum(has_cpd1) as cnt_user_cpd1_l24m,
        sum(has_cpd1_12m) as cnt_user_cpd1_l12m,
        sum(has_cpd1_6m) as cnt_user_cpd1_l6m,
        sum(has_cpd1_3m) as cnt_user_cpd1_l3m,
        sum(has_cpd1_1m) as cnt_user_cpd1_l1m,
        
        sum(has_cpd1_limit90) as cnt_user_cpd1_limit90_l24m,
        sum(has_cpd1_limit90_12m) as cnt_user_cpd1_limit90_l12m,
        sum(has_cpd1_limit90_6m) as cnt_user_cpd1_limit90_l6m,
        sum(has_cpd1_limit90_3m) as cnt_user_cpd1_limit90_l3m,
        sum(has_cpd1_limit90_1m) as cnt_user_cpd1_limit90_l1m,
        
        sum(has_cpd7) as cnt_user_cpd7_l24m,
        sum(has_cpd7_12m) as cnt_user_cpd7_l12m,
        sum(has_cpd7_6m) as cnt_user_cpd7_l6m,
        sum(has_cpd7_3m) as cnt_user_cpd7_l3m,
        sum(has_cpd7_1m) as cnt_user_cpd7_l1m,
        
        sum(has_cpd7_limit90) as cnt_user_cpd7_limit90_l24m,
        sum(has_cpd7_limit90_12m) as cnt_user_cpd7_limit90_l12m,
        sum(has_cpd7_limit90_6m) as cnt_user_cpd7_limit90_l6m,
        sum(has_cpd7_limit90_3m) as cnt_user_cpd7_limit90_l3m,
        sum(has_cpd7_limit90_1m) as cnt_user_cpd7_limit90_l1m,
        
        sum(has_cpd30) as cnt_user_cpd30_l24m,
        sum(has_cpd30_12m) as cnt_user_cpd30_l12m,
        sum(has_cpd30_6m) as cnt_user_cpd30_l6m,
        sum(has_cpd30_3m) as cnt_user_cpd30_l3m,
        sum(has_cpd30_1m) as cnt_user_cpd30_l1m,
        
        sum(has_cpd30_limit90) as cnt_user_cpd30_limit90_l24m,
        sum(has_cpd30_limit90_12m) as cnt_user_cpd30_limit90_l12m,
        sum(has_cpd30_limit90_6m) as cnt_user_cpd30_limit90_l6m,
        sum(has_cpd30_limit90_3m) as cnt_user_cpd30_limit90_l3m,
        sum(has_cpd30_limit90_1m) as cnt_user_cpd30_limit90_l1m,
        
        sum(has_dpd30_l2y) as cnt_user_dpd30_l2y_l24m,
        sum(has_dpd30_l2y_12m) as cnt_user_dpd30_l2y_l12m,
        sum(has_dpd30_l2y_6m) as cnt_user_dpd30_l2y_l6m,
        sum(has_dpd30_l2y_3m) as cnt_user_dpd30_l2y_l3m,
        sum(has_dpd30_l2y_1m) as cnt_user_dpd30_l2y_l1m,
        
        sum(has_dpd30_l2y_limit90) as cnt_user_dpd30_l2y_limit90_l24m,
        sum(has_dpd30_l2y_limit90_12m) as cnt_user_dpd30_l2y_limit90_l12m,
        sum(has_dpd30_l2y_limit90_6m) as cnt_user_dpd30_l2y_limit90_l6m,
        sum(has_dpd30_l2y_limit90_3m) as cnt_user_dpd30_l2y_limit90_l3m,
        sum(has_dpd30_l2y_limit90_1m) as cnt_user_dpd30_l2y_limit90_l1m
    from ${SCHEMA}.dws_risk_mid_${reg}_${risk_tab_biz_type}_szdf_device_user_info_df
    where grass_date = '${ds}'
    group by sz_dfp_device_id
);

 
insert overwrite table ${SCHEMA}.dws_risk_${reg}_${risk_tab_biz_type}_szdf_device_user_agg_df partition(grass_date = '${ds}')
select 
  ${biz_type_string}_login_agg.sz_dfp_device_id as sz_dfp_device_id

  ,cnt_user_dpd30_l24m
  ,cnt_user_dpd30_l12m
  ,cnt_user_dpd30_l6m
  ,cnt_user_dpd30_l3m
  ,cnt_user_dpd30_l1m
  ,cnt_user_dpd30_limit90_l24m
  ,cnt_user_dpd30_limit90_l12m
  ,cnt_user_dpd30_limit90_l6m
  ,cnt_user_dpd30_limit90_l3m
  ,cnt_user_dpd30_limit90_l1m
  ,cnt_user_dpd90_l24m
  ,cnt_user_dpd90_l12m
  ,cnt_user_dpd90_l6m
  ,cnt_user_dpd90_l3m
  ,cnt_user_dpd90_l1m
  ,cnt_user_dpd90_limit90_l24m
  ,cnt_user_dpd90_limit90_l12m
  ,cnt_user_dpd90_limit90_l6m
  ,cnt_user_dpd90_limit90_l3m
  ,cnt_user_dpd90_limit90_l1m
  ,cnt_user_fpd30_l24m
  ,cnt_user_fpd30_l12m
  ,cnt_user_fpd30_l6m
  ,cnt_user_fpd30_l3m
  ,cnt_user_fpd30_l1m
  ,cnt_user_fpd30_limit90_l24m
  ,cnt_user_fpd30_limit90_l12m
  ,cnt_user_fpd30_limit90_l6m
  ,cnt_user_fpd30_limit90_l3m
  ,cnt_user_fpd30_limit90_l1m
  ,cnt_user_cpd1_l24m
  ,cnt_user_cpd1_l12m
  ,cnt_user_cpd1_l6m
  ,cnt_user_cpd1_l3m
  ,cnt_user_cpd1_l1m
  ,cnt_user_cpd1_limit90_l24m
  ,cnt_user_cpd1_limit90_l12m
  ,cnt_user_cpd1_limit90_l6m
  ,cnt_user_cpd1_limit90_l3m
  ,cnt_user_cpd1_limit90_l1m
  ,cnt_user_cpd7_l24m
  ,cnt_user_cpd7_l12m
  ,cnt_user_cpd7_l6m
  ,cnt_user_cpd7_l3m
  ,cnt_user_cpd7_l1m
  ,cnt_user_cpd7_limit90_l24m
  ,cnt_user_cpd7_limit90_l12m
  ,cnt_user_cpd7_limit90_l6m
  ,cnt_user_cpd7_limit90_l3m
  ,cnt_user_cpd7_limit90_l1m
  ,cnt_user_cpd30_l24m
  ,cnt_user_cpd30_l12m
  ,cnt_user_cpd30_l6m
  ,cnt_user_cpd30_l3m
  ,cnt_user_cpd30_l1m
  ,cnt_user_cpd30_limit90_l24m
  ,cnt_user_cpd30_limit90_l12m
  ,cnt_user_cpd30_limit90_l6m
  ,cnt_user_cpd30_limit90_l3m
  ,cnt_user_cpd30_limit90_l1m
  ,cnt_user_dpd30_l2y_l24m
  ,cnt_user_dpd30_l2y_l12m
  ,cnt_user_dpd30_l2y_l6m
  ,cnt_user_dpd30_l2y_l3m
  ,cnt_user_dpd30_l2y_l1m
  ,cnt_user_dpd30_l2y_limit90_l24m
  ,cnt_user_dpd30_l2y_limit90_l12m
  ,cnt_user_dpd30_l2y_limit90_l6m
  ,cnt_user_dpd30_l2y_limit90_l3m
  ,cnt_user_dpd30_l2y_limit90_l1m
from ${biz_type_string}_login_agg
DISTRIBUTE BY ${biz_type_string}_login_agg.sz_dfp_device_id
;
