--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-10-20
-- Theme Domain：       Anti-fraud user overdue feature
-- Description:         https://jira.shopee.io/browse/SPFDT-56370
-- Data Granularity:    
-- Change Log:
--********************************************************************--

CREATE TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_${reg}_all_prod_user_overdue_info_middle_df (
    platform_user_id                      STRING         COMMENT 'platform_user_id',
    credit_user_id                        STRING         COMMENT 'credit_user_id',
    current_max_dpd_eod                   BIGINT         COMMENT 'current_max_dpd', 
    ever_max_dpd_eod                      BIGINT         COMMENT 'historical_max_dpd', 
    max_limit_usage_rate_l2y              DECIMAL(20,10) COMMENT 'max_limit_usage_rate_l2y',
    max_dpd_l2y                           BIGINT         COMMENT 'max_dpd_l2y',
    flag_dpd30_l2y_limit90                BIGINT         COMMENT 'flag_dpd30_l2y_limit90',
    credit_limit                          DECIMAL(20,10) COMMENT 'credit limit: common_perm_credit_limit + common_temp_credit_limit + installment_perm_credit_limit',
    used_limit                            DECIMAL(20,10) COMMENT 'used_limit: common_perm_used_credit_amount + common_temp_used_credit_amount + installment_perm_used_credit_amount', 
    frozen_limit                          DECIMAL(20,10) COMMENT 'common_perm_frozen_credit_amount + common_temp_frozen_credit_amount + installment_perm_frozen_credit_amount',
    limit_utilisation                     DECIMAL(20,10) COMMENT '(used_limit + frozen_limit) / credit_limit',
    overdue_amt                           DECIMAL(20,10) COMMENT 'current overdue amount ',
    reactivate_date                       STRING         COMMENT 'reactivate_date ',
    fpd_month_bill_date                   STRING         COMMENT 'fpd bill date',
    fpd_overdue_amt                       DECIMAL(20,10) COMMENT 'first bill overdue amount',
    fpd_measurable_days                   BIGINT         COMMENT 'number of days passed due day of the user first bill',
    fpd_3term_measurable_days             BIGINT         COMMENT 'days after the third bills due date',
    fpd_max_dpd_eod                       BIGINT         COMMENT 'first bill max overdue days eod',
    fpd_max_dpd                           BIGINT         COMMENT 'first bill max overdue days',
    fpd_3term_max_dpd_eod                 BIGINT         COMMENT 'first three bills historical max overdue days eod',
    fpd_3term_max_dpd                     BIGINT         COMMENT 'first three bills historical max overdue days',
    fpd_overdue_amt_after_react           DECIMAL(20,10) COMMENT 'first bill overdue amount (after react/recredit)',
    fpd_measurable_days_after_react       BIGINT         COMMENT 'number of days passed due day of the user first bill (after react/recredit)',
    fpd_3term_measurable_days_after_react BIGINT         COMMENT 'days after the third bills due date (after react/recredit)',
    fpd_max_dpd_eod_after_react           BIGINT         COMMENT 'first bill max overdue days eod (after react/recredit)',
    fpd_max_dpd_after_react               BIGINT         COMMENT 'first bill max overdue days (after react/recredit)',
    fpd_3term_max_dpd_eod_after_react     BIGINT         COMMENT 'first three bills historical max overdue days eod (after react/recredit)',
    fpd_3term_max_dpd_after_react         BIGINT         COMMENT 'first three bills historical max overdue days (after react/recredit)',
    fpd_limit_usage_rate                  DECIMAL(20,10) COMMENT 'fpd_limit_usage_rate',
    overdue_amt_usd                       DECIMAL(20,10) COMMENT 'current overdue amount USD',
    fpd_overdue_amt_usd                   DECIMAL(20,10) COMMENT 'first bill overdue amount USD'
) 
COMMENT 'risk mart summary table'
PARTITIONED BY (product_id int, grass_date string)
stored as orc tblproperties ("orc.compress" = "zstd")
location '${HDFS_PATH}/ads/ads/ads_aio_risk_user_overdue_info_df/grass_region=${grass_region}'
;



MSCK REPAIR TABLE ${SCHEMA}.ads_risk_${reg}_all_prod_user_overdue_info_middle_df;


create or replace view ads_risk_${reg}_all_prod_user_overdue_info_df
COMMENT 'risk mart summary table'
as 
select 
    platform_user_id as shopee_user_id   
    ,product_id   
    ,grass_date         
    ,credit_user_id                        
    ,current_max_dpd_eod as current_max_dpd_eod              
    ,ever_max_dpd_eod as ever_max_dpd_eod                    
    ,max_limit_usage_rate_l2y              
    ,max_dpd_l2y as max_dpd_eod_l2y                           
    ,flag_dpd30_l2y_limit90 as flag_dpd30_eod_l2y_limit90               
    ,credit_limit                          
    ,used_limit                            
    ,frozen_limit                          
    ,limit_utilisation 
    ,overdue_amt                    
    ,overdue_amt_usd  as overdue_amt_usd        
    ,fpd_overdue_amt                                
    ,fpd_overdue_amt_usd as fpd_overdue_amt_usd                      
    ,fpd_measurable_days                   
    ,fpd_3term_measurable_days             
    ,fpd_max_dpd_eod as fpd_max_dpd_eod                                      
    ,fpd_3term_max_dpd_eod as fpd_3term_max_dpd_eod                                
    ,fpd_3term_measurable_days_after_react                
    ,fpd_3term_max_dpd_eod_after_react as fpd_3term_max_dpd_eod_after_react   
    ,fpd_overdue_amt_after_react
    ,fpd_measurable_days_after_react
    ,fpd_max_dpd_eod_after_react   
from 
${SCHEMA}.ads_risk_${reg}_all_prod_user_overdue_info_middle_df base
;