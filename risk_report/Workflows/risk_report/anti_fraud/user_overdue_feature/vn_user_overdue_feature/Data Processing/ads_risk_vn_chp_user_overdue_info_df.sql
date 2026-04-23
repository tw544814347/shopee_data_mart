--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-10-20
-- Theme Domain：       Anti-fraud user overdue feature
-- Description:         https://jira.shopee.io/browse/SPFDT-56370
-- Data Granularity:    
-- Change Log:
--********************************************************************--
CREATE TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_${reg}_${risk_tab_biz_type}_user_overdue_info_tmp_df (
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
PARTITIONED BY (grass_date string)
stored as orc tblproperties ("orc.compress" = "zstd")
location '${HDFS_PATH}/ads/ads/ads_aio_risk_user_overdue_info_df/grass_region=${grass_region}/product_id=${biz_type_code}'
;

with ${biz_type_string} as 
(
    select  platform_user_id
            ,credit_user_id
            --     ,round(common_perm_credit_limit+ common_temp_credit_limit+ installment_perm_credit_limit) as total_credit_limit
        --     ,round(common_perm_used_credit_amount + common_temp_used_credit_amount+installment_perm_used_credit_amount) as total_used_limit
        --     ,round(common_perm_frozen_credit_amount + common_temp_frozen_credit_amount + installment_perm_frozen_credit_amount) as total_frozen_limit
        ,round(common_perm_credit_limit+ common_temp_credit_limit+ installment_perm_credit_limit + one_time_credit_limit) as total_credit_limit
        ,round(common_perm_used_credit_amount + common_temp_used_credit_amount+installment_perm_used_credit_amount + one_time_used_credit_amount) as total_used_limit
        ,round(common_perm_frozen_credit_amount + common_temp_frozen_credit_amount + installment_perm_frozen_credit_amount + one_time_frozen_credit_amount) as total_frozen_limit
        --     ,round(common_perm_credit_limit+ common_temp_credit_limit+ installment_perm_credit_limit)-round(common_perm_used_credit_amount + common_temp_used_credit_amount+installment_perm_used_credit_amount) as total_available_credit_limit
        --     ,((common_perm_used_credit_amount + common_temp_used_credit_amount+installment_perm_used_credit_amount)+(common_perm_frozen_credit_amount + common_temp_frozen_credit_amount + installment_perm_frozen_credit_amount))
        --       / nullif(common_perm_credit_limit + common_temp_credit_limit + installment_perm_credit_limit, 0)
        --      as total_limit_utilisation
        ,round(common_perm_credit_limit+ common_temp_credit_limit+ installment_perm_credit_limit + one_time_credit_limit)-round(common_perm_used_credit_amount + common_temp_used_credit_amount+installment_perm_used_credit_amount + one_time_used_credit_amount) as total_available_credit_limit
        -- 计算 one time
        ,((common_perm_used_credit_amount + common_temp_used_credit_amount+installment_perm_used_credit_amount + one_time_used_credit_amount)+(common_perm_frozen_credit_amount + common_temp_frozen_credit_amount + installment_perm_frozen_credit_amount + one_time_frozen_credit_amount))
        / nullif(common_perm_credit_limit + common_temp_credit_limit + installment_perm_credit_limit + one_time_credit_limit, 0)
        as total_limit_utilisation
        -- 计算 one time 
            ,grass_date
    from  credit_mart.dws_${biz_type_string}_aio_${reg}_account_df
    where  grass_date = '${ds}' and platform_type = 1
    and    biz_type in (${biz_type_code}) 
    and (
            case when '${risk_tab_biz_type}' = 'spl' then product_id = 3
              when '${risk_tab_biz_type}' = 'chp' then product_id = 3
              when '${risk_tab_biz_type}' = 'bcl' then product_id = 1
              when '${risk_tab_biz_type}' = 'tl' then product_id = 11
              else false end)   
)

insert overwrite table ${SCHEMA}.ads_risk_${reg}_${risk_tab_biz_type}_user_overdue_info_tmp_df partition(grass_date = '${ds}')
select  
    ${biz_type_string}_ds.platform_user_id,
    ${biz_type_string}_ds.credit_user_id,
    coalesce(xpd.current_max_dpd_eod, 0) as current_max_dpd_eod,
    coalesce(xpd.ever_max_dpd_eod, 0) as ever_max_dpd_eod,
    coalesce(l2y.max_limit_usage_rate_l2y, -9999) as max_limit_usage_rate_l2y,
    coalesce(l2y.max_dpd_l2y, 0) as max_dpd_l2y,
    coalesce(l2y.flag_dpd30_l2y_limit90, 0) as flag_dpd30_l2y_limit90,
    coalesce(${biz_type_string}_ds.total_credit_limit, 0) as credit_limit,
    coalesce(${biz_type_string}_ds.total_used_limit, 0) as used_limit,
    coalesce(${biz_type_string}_ds.total_frozen_limit, 0) as frozen_limit,
    coalesce(${biz_type_string}_ds.total_limit_utilisation, 0) as limit_utilisation,
    coalesce(user_overdue_amt.overdue_amt, 0) as overdue_amt,
    coalesce(three_term.reactivate_date, '9999-12-31'),
    coalesce(three_term.fpd_month_bill_date, '9999-12-31'),
    coalesce(three_term.fpd_overdue_amt, 0) as fpd_overdue_amt,
    coalesce(three_term.fpd_measurable_days, -9999) as fpd_measurable_days,
    coalesce(three_term.fpd_3term_measurable_days, -9999) as fpd_3term_measurable_days,
    coalesce(three_term.fpd_max_dpd_eod, 0) as fpd_max_dpd_eod,
    coalesce(three_term.fpd_max_dpd, 0) as fpd_max_dpd,
    coalesce(three_term.fpd_3term_max_dpd_eod, 0) as fpd_3term_max_dpd_eod,
    coalesce(three_term.fpd_3term_max_dpd, 0) as fpd_3term_max_dpd,
    coalesce(three_term.fpd_overdue_amt_after_react, 0) as fpd_overdue_amt_after_react,
    coalesce(three_term.fpd_measurable_days_after_react, -9999) as fpd_measurable_days_after_react,
    coalesce(three_term.fpd_3term_measurable_days_after_react, -9999) as fpd_3term_measurable_days_after_react,
    coalesce(three_term.fpd_max_dpd_eod_after_react, 0) as fpd_max_dpd_eod_after_react,
    coalesce(three_term.fpd_max_dpd_after_react, 0) as fpd_max_dpd_after_react,
    coalesce(three_term.fpd_3term_max_dpd_eod_after_react, 0) as fpd_3term_max_dpd_eod_after_react,
    coalesce(three_term.fpd_3term_max_dpd_after_react, 0) as fpd_3term_max_dpd_after_react,
    null as fpd_limit_usage_rate,
    coalesce(overdue_amt / exchange_rate, 0) as overdue_amt_usd,                             
    coalesce(fpd_overdue_amt / exchange_rate, 0) as fpd_overdue_amt_usd              
from (
        select  
            platform_user_id
            ,credit_user_id
            ,total_credit_limit
            ,total_used_limit
            ,total_frozen_limit
            ,total_limit_utilisation
            ,grass_date
        from ${biz_type_string} 
) ${biz_type_string}_ds
left join (
        select credit_user_id, platform_user_id, ever_max_dpd_eod, current_max_dpd_eod
        from risk_feature.ads_risk_${biz_type_string}_${reg}_user_behavior_df
        where grass_date = '${ds}' and biz_type in (${biz_type_code})
) xpd
on xpd.credit_user_id = ${biz_type_string}_ds.credit_user_id
  and xpd.platform_user_id = ${biz_type_string}_ds.platform_user_id
left join (
        select  
            credit_user_id
            ,platform_user_id
            ,max_limit_usage_rate_l2y
            ,max_dpd_l2y
            ,flag_dpd30_l2y_limit90
        from ${SCHEMA}.dws_risk_${reg}_${risk_tab_biz_type}_user_overdue_info_df where grass_date = '${ds}' 
) l2y 
on l2y.credit_user_id = ${biz_type_string}_ds.credit_user_id
  and l2y.platform_user_id = ${biz_type_string}_ds.platform_user_id
left join (
        select 
            credit_user_id, platform_user_id,
            sum(principal_repayable) as overdue_amt
        from credit_mart.dws_${biz_type_string}_aio_${reg}_instalment_repayment_df
        where grass_date = '${ds}' 
            and biz_type in (${biz_type_code})
            and dpd_eod>0 and platform_type = 1
            and product_id = ${biz_type_code}
            and (
            case when '${risk_tab_biz_type}' = 'spl' then product_id = 3
              when '${risk_tab_biz_type}' = 'chp' then product_id = 3
              when '${risk_tab_biz_type}' = 'bcl' then product_id = 1
              when '${risk_tab_biz_type}' = 'tl' then product_id = 11
              else false end)   
        group by credit_user_id, platform_user_id
) user_overdue_amt 
on user_overdue_amt.credit_user_id = ${biz_type_string}_ds.credit_user_id
  and user_overdue_amt.platform_user_id = ${biz_type_string}_ds.platform_user_id
left join (
        select 
                credit_user_id
                ,platform_user_id                                        
                ,reactivate_date                       
                ,fpd_month_bill_date                   
                ,fpd_overdue_amt                       
                ,fpd_measurable_days                   
                ,fpd_3term_measurable_days             
                ,fpd_max_dpd_eod                       
                ,fpd_max_dpd                           
                ,fpd_3term_max_dpd_eod                 
                ,fpd_3term_max_dpd                     
                ,fpd_overdue_amt_after_react           
                ,fpd_measurable_days_after_react       
                ,fpd_3term_measurable_days_after_react 
                ,fpd_max_dpd_eod_after_react           
                ,fpd_max_dpd_after_react               
                ,fpd_3term_max_dpd_eod_after_react     
                ,fpd_3term_max_dpd_after_react         
        from ${SCHEMA}.dws_risk_${reg}_${risk_tab_biz_type}_fpd_user_overdue_info_df
        where grass_date = '${ds}'
) three_term
on three_term.credit_user_id = ${biz_type_string}_ds.credit_user_id
  and  three_term.platform_user_id = ${biz_type_string}_ds.platform_user_id
left join (
  select exchange_rate, grass_date
  from mp_order.dim_exchange_rate__reg_s0_live 
  where grass_region = upper('${reg}')
) as exchange_rate
on date(${biz_type_string}_ds.grass_date) = exchange_rate.grass_date
;

create or replace view ads_risk_${reg}_${risk_tab_biz_type}_user_overdue_info_df
COMMENT 'risk mart summary table'
as 
select 
    platform_user_id as shopee_user_id    
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
${SCHEMA}.ads_risk_${reg}_${risk_tab_biz_type}_user_overdue_info_tmp_df base
;