--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-10-20
-- Theme Domain：       Anti-fraud user overdue feature
-- Description:         https://jira.shopee.io/browse/SPFDT-56370
-- Data Granularity:    
-- Change Log:
--********************************************************************--

CREATE TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_${reg}_all_prod_device_user_agg_middle_df (
    sz_dfp_device_id                       STRING         COMMENT 'sz_dfp_device_id',
    cnt_user_l3m                           BIGINT         COMMENT 'cnt distinct users in last 3 months',
    cnt_user_l1m                           BIGINT         COMMENT 'cnt distinct users in last 1 month',
    cnt_user_l10d                          BIGINT         COMMENT 'cnt distinct users in last 10 days',
    cnt_user_login_3d                      BIGINT         COMMENT 'cnt users with login days <=3 in last 3 months',
    cnt_user_login_2d                      BIGINT         COMMENT 'cnt users with login days <=2 in last 3 months',
    cnt_user_login_1d                      BIGINT         COMMENT 'cnt users with login days <=1 in last 3 months',
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
    cnt_user_dpd30_l2y_limit90_l1m         BIGINT         COMMENT 'cnt users with max overdue >=30 days in last 2 years and limit >=90 within last 1 month',
    cnt_user_cpd1_credit_l24m              BIGINT         COMMENT 'cnt credit users with current overdue >=1 day in last 24 months',
    cnt_user_cpd1_credit_l12m              BIGINT         COMMENT 'cnt credit users with current overdue >=1 day in last 12 months',
    cnt_user_cpd1_credit_l6m               BIGINT         COMMENT 'cnt credit users with current overdue >=1 day in last 6 months',
    cnt_user_cpd1_credit_l3m               BIGINT         COMMENT 'cnt credit users with current overdue >=1 day in last 3 months',
    cnt_user_cpd1_credit_l1m               BIGINT         COMMENT 'cnt credit users with current overdue >=1 day in last 1 month',
    cnt_user_cpd7_credit_l24m              BIGINT         COMMENT 'cnt credit users with current overdue >=7 days in last 24 months',
    cnt_user_cpd7_credit_l12m              BIGINT         COMMENT 'cnt credit users with current overdue >=7 days in last 12 months',
    cnt_user_cpd7_credit_l6m               BIGINT         COMMENT 'cnt credit users with current overdue >=7 days in last 6 months',
    cnt_user_cpd7_credit_l3m               BIGINT         COMMENT 'cnt credit users with current overdue >=7 days in last 3 months',
    cnt_user_cpd7_credit_l1m               BIGINT         COMMENT 'cnt credit users with current overdue >=7 days in last 1 month',
    cnt_user_cpd30_credit_l24m             BIGINT         COMMENT 'cnt credit users with current overdue >=30 days in last 24 months',
    cnt_user_cpd30_credit_l12m             BIGINT         COMMENT 'cnt credit users with current overdue >=30 days in last 12 months',
    cnt_user_cpd30_credit_l6m              BIGINT         COMMENT 'cnt credit users with current overdue >=30 days in last 6 months',
    cnt_user_cpd30_credit_l3m              BIGINT         COMMENT 'cnt credit users with current overdue >=30 days in last 3 months',
    cnt_user_cpd30_credit_l1m              BIGINT         COMMENT 'cnt credit users with current overdue >=30 days in last 1 month',
    cnt_user_dpd30_l2y_limit90_credit_l24m BIGINT         COMMENT 'cnt credit users with max overdue >=30 days in last 2 years and limit >=90 within last 24 months',
    cnt_user_dpd30_l2y_limit90_credit_l12m BIGINT         COMMENT 'cnt credit users with max overdue >=30 days in last 2 years and limit >=90 within last 12 months',
    cnt_user_dpd30_l2y_limit90_credit_l6m  BIGINT         COMMENT 'cnt credit users with max overdue >=30 days in last 2 years and limit >=90 within last 6 months',
    cnt_user_dpd30_l2y_limit90_credit_l3m  BIGINT         COMMENT 'cnt credit users with max overdue >=30 days in last 2 years and limit >=90 within last 3 months',
    cnt_user_dpd30_l2y_limit90_credit_l1m  BIGINT         COMMENT 'cnt credit users with max overdue >=30 days in last 2 years and limit >=90 within last 1 month',
    is_gps_palembang                       BIGINT         COMMENT 'is city contain palembang in last 30d',
    is_ip_palembang                        BIGINT         COMMENT 'is ip contain palembang in last 30d'
) 
COMMENT 'risk mart summary table'
PARTITIONED BY (product_id int, grass_date string)
stored as orc tblproperties ("orc.compress" = "zstd")
location '${HDFS_PATH}/ads/ads_aio_risk_device_user_agg_df/grass_region=${grass_region}'
;


MSCK REPAIR TABLE ${SCHEMA}.ads_risk_${reg}_all_prod_device_user_agg_middle_df;

create or replace view ads_risk_${reg}_all_prod_device_user_agg_df
COMMENT 'risk mart summary table'
as 
select 
    sz_dfp_device_id   
    ,product_id                       
    ,grass_date
    ,cnt_user_l3m                           
    ,cnt_user_l1m                           
    ,cnt_user_l10d                          
    ,cnt_user_login_3d                           as cnt_user_login_3d_l3m                  
    ,cnt_user_login_2d                           as cnt_user_login_2d_l3m                  
    ,cnt_user_login_1d                           as cnt_user_login_1d_l3m                     
    ,cnt_user_dpd30_l24m                         as cnt_user_dpd30_eod_l24m
    ,cnt_user_dpd30_l12m                         as cnt_user_dpd30_eod_l12m
    ,cnt_user_dpd30_l6m                          as cnt_user_dpd30_eod_l6m
    ,cnt_user_dpd30_l3m                          as cnt_user_dpd30_eod_l3m
    ,cnt_user_dpd30_l1m                          as cnt_user_dpd30_eod_l1m
    ,cnt_user_dpd30_limit90_l24m                 as cnt_user_dpd30_eod_limit90_l24m
    ,cnt_user_dpd30_limit90_l12m                 as cnt_user_dpd30_eod_limit90_l12m
    ,cnt_user_dpd30_limit90_l6m                  as cnt_user_dpd30_eod_limit90_l6m
    ,cnt_user_dpd30_limit90_l3m                  as cnt_user_dpd30_eod_limit90_l3m
    ,cnt_user_dpd30_limit90_l1m                  as cnt_user_dpd30_eod_limit90_l1m
    ,cnt_user_dpd90_l24m                         as cnt_user_dpd90_eod_l24m
    ,cnt_user_dpd90_l12m                         as cnt_user_dpd90_eod_l12m
    ,cnt_user_dpd90_l6m                          as cnt_user_dpd90_eod_l6m
    ,cnt_user_dpd90_l3m                          as cnt_user_dpd90_eod_l3m
    ,cnt_user_dpd90_l1m                          as cnt_user_dpd90_eod_l1m
    ,cnt_user_dpd90_limit90_l24m                 as cnt_user_dpd90_eod_limit90_l24m
    ,cnt_user_dpd90_limit90_l12m                 as cnt_user_dpd90_eod_limit90_l12m
    ,cnt_user_dpd90_limit90_l6m                  as cnt_user_dpd90_eod_limit90_l6m
    ,cnt_user_dpd90_limit90_l3m                  as cnt_user_dpd90_eod_limit90_l3m
    ,cnt_user_dpd90_limit90_l1m                  as cnt_user_dpd90_eod_limit90_l1m
    ,cnt_user_fpd30_l24m                         as cnt_user_fpd30_eod_l24m
    ,cnt_user_fpd30_l12m                         as cnt_user_fpd30_eod_l12m
    ,cnt_user_fpd30_l6m                          as cnt_user_fpd30_eod_l6m
    ,cnt_user_fpd30_l3m                          as cnt_user_fpd30_eod_l3m
    ,cnt_user_fpd30_l1m                          as cnt_user_fpd30_eod_l1m
    ,cnt_user_fpd30_limit90_l24m                 as cnt_user_fpd30_eod_limit90_l24m
    ,cnt_user_fpd30_limit90_l12m                 as cnt_user_fpd30_eod_limit90_l12m
    ,cnt_user_fpd30_limit90_l6m                  as cnt_user_fpd30_eod_limit90_l6m
    ,cnt_user_fpd30_limit90_l3m                  as cnt_user_fpd30_eod_limit90_l3m
    ,cnt_user_fpd30_limit90_l1m                  as cnt_user_fpd30_eod_limit90_l1m
    ,cnt_user_cpd1_l24m                          as cnt_user_cpd1_eod_l24m
    ,cnt_user_cpd1_l12m                          as cnt_user_cpd1_eod_l12m
    ,cnt_user_cpd1_l6m                           as cnt_user_cpd1_eod_l6m
    ,cnt_user_cpd1_l3m                           as cnt_user_cpd1_eod_l3m
    ,cnt_user_cpd1_l1m                           as cnt_user_cpd1_eod_l1m
    ,cnt_user_cpd1_limit90_l24m                  as cnt_user_cpd1_eod_limit90_l24m
    ,cnt_user_cpd1_limit90_l12m                  as cnt_user_cpd1_eod_limit90_l12m
    ,cnt_user_cpd1_limit90_l6m                   as cnt_user_cpd1_eod_limit90_l6m
    ,cnt_user_cpd1_limit90_l3m                   as cnt_user_cpd1_eod_limit90_l3m
    ,cnt_user_cpd1_limit90_l1m                   as cnt_user_cpd1_eod_limit90_l1m
    ,cnt_user_cpd7_l24m                          as cnt_user_cpd7_eod_l24m
    ,cnt_user_cpd7_l12m                          as cnt_user_cpd7_eod_l12m
    ,cnt_user_cpd7_l6m                           as cnt_user_cpd7_eod_l6m
    ,cnt_user_cpd7_l3m                           as cnt_user_cpd7_eod_l3m
    ,cnt_user_cpd7_l1m                           as cnt_user_cpd7_eod_l1m
    ,cnt_user_cpd7_limit90_l24m                  as cnt_user_cpd7_eod_limit90_l24m
    ,cnt_user_cpd7_limit90_l12m                  as cnt_user_cpd7_eod_limit90_l12m
    ,cnt_user_cpd7_limit90_l6m                   as cnt_user_cpd7_eod_limit90_l6m
    ,cnt_user_cpd7_limit90_l3m                   as cnt_user_cpd7_eod_limit90_l3m
    ,cnt_user_cpd7_limit90_l1m                   as cnt_user_cpd7_eod_limit90_l1m
    ,cnt_user_cpd30_l24m                         as cnt_user_cpd30_eod_l24m
    ,cnt_user_cpd30_l12m                         as cnt_user_cpd30_eod_l12m
    ,cnt_user_cpd30_l6m                          as cnt_user_cpd30_eod_l6m
    ,cnt_user_cpd30_l3m                          as cnt_user_cpd30_eod_l3m
    ,cnt_user_cpd30_l1m                          as cnt_user_cpd30_eod_l1m
    ,cnt_user_cpd30_limit90_l24m                 as cnt_user_cpd30_eod_limit90_l24m
    ,cnt_user_cpd30_limit90_l12m                 as cnt_user_cpd30_eod_limit90_l12m
    ,cnt_user_cpd30_limit90_l6m                  as cnt_user_cpd30_eod_limit90_l6m
    ,cnt_user_cpd30_limit90_l3m                  as cnt_user_cpd30_eod_limit90_l3m
    ,cnt_user_cpd30_limit90_l1m                  as cnt_user_cpd30_eod_limit90_l1m
    ,cnt_user_dpd30_l2y_l24m                     as cnt_user_dpd30_eod_l2y_l24m
    ,cnt_user_dpd30_l2y_l12m                     as cnt_user_dpd30_eod_l2y_l12m
    ,cnt_user_dpd30_l2y_l6m                      as cnt_user_dpd30_eod_l2y_l6m
    ,cnt_user_dpd30_l2y_l3m                      as cnt_user_dpd30_eod_l2y_l3m
    ,cnt_user_dpd30_l2y_l1m                      as cnt_user_dpd30_eod_l2y_l1m
    ,cnt_user_dpd30_l2y_limit90_l24m             as cnt_user_dpd30_eod_l2y_limit90_l24m
    ,cnt_user_dpd30_l2y_limit90_l12m             as cnt_user_dpd30_eod_l2y_limit90_l12m
    ,cnt_user_dpd30_l2y_limit90_l6m              as cnt_user_dpd30_eod_l2y_limit90_l6m
    ,cnt_user_dpd30_l2y_limit90_l3m              as cnt_user_dpd30_eod_l2y_limit90_l3m
    ,cnt_user_dpd30_l2y_limit90_l1m              as cnt_user_dpd30_eod_l2y_limit90_l1m
    ,cnt_user_cpd1_credit_l24m                   as cnt_user_cpd1_eod_credit_l24m
    ,cnt_user_cpd1_credit_l12m                   as cnt_user_cpd1_eod_credit_l12m
    ,cnt_user_cpd1_credit_l6m                    as cnt_user_cpd1_eod_credit_l6m
    ,cnt_user_cpd1_credit_l3m                    as cnt_user_cpd1_eod_credit_l3m
    ,cnt_user_cpd1_credit_l1m                    as cnt_user_cpd1_eod_credit_l1m
    ,cnt_user_cpd7_credit_l24m                   as cnt_user_cpd7_eod_credit_l24m
    ,cnt_user_cpd7_credit_l12m                   as cnt_user_cpd7_eod_credit_l12m
    ,cnt_user_cpd7_credit_l6m                    as cnt_user_cpd7_eod_credit_l6m
    ,cnt_user_cpd7_credit_l3m                    as cnt_user_cpd7_eod_credit_l3m
    ,cnt_user_cpd7_credit_l1m                    as cnt_user_cpd7_eod_credit_l1m
    ,cnt_user_cpd30_credit_l24m                  as cnt_user_cpd30_eod_credit_l24m
    ,cnt_user_cpd30_credit_l12m                  as cnt_user_cpd30_eod_credit_l12m
    ,cnt_user_cpd30_credit_l6m                   as cnt_user_cpd30_eod_credit_l6m
    ,cnt_user_cpd30_credit_l3m                   as cnt_user_cpd30_eod_credit_l3m
    ,cnt_user_cpd30_credit_l1m                   as cnt_user_cpd30_eod_credit_l1m
    ,cnt_user_dpd30_l2y_limit90_credit_l24m      as cnt_user_dpd30_eod_l2y_limit90_credit_l24m
    ,cnt_user_dpd30_l2y_limit90_credit_l12m      as cnt_user_dpd30_eod_l2y_limit90_credit_l12m
    ,cnt_user_dpd30_l2y_limit90_credit_l6m       as cnt_user_dpd30_eod_l2y_limit90_credit_l6m
    ,cnt_user_dpd30_l2y_limit90_credit_l3m       as cnt_user_dpd30_eod_l2y_limit90_credit_l3m
    ,cnt_user_dpd30_l2y_limit90_credit_l1m       as cnt_user_dpd30_eod_l2y_limit90_credit_l1m  
    ,is_gps_palembang                            as is_gps_palembang_l1m                       
    ,is_ip_palembang                             as is_ip_palembang_l1m                        
from 
${SCHEMA}.ads_risk_${reg}_all_prod_device_user_agg_middle_df;


