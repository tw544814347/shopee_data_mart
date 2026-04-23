--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-10-20
-- Theme Domain：       Anti-fraud user overdue feature
-- Description:         https://jira.shopee.io/browse/SPFDT-56370
-- Data Granularity:    
-- Change Log: 
--              ${filter_condition}： spl 需要过滤对应的 biz_type, biz_type_code as biz_type 就可以/bcl: 1 as biz_type/tl: 11 as biz_type
--              MY TL 计算逻辑用的 one_time 前缀计算
--********************************************************************--
CREATE TABLE IF NOT EXISTS ${SCHEMA}.dws_risk_${reg}_${risk_tab_biz_type}_user_overdue_tag_df (
    platform_user_id                      STRING         COMMENT 'platform_user_id',
    credit_user_id                        STRING         COMMENT 'credit_user_id',

    flag_dpd1                             BIGINT         COMMENT 'flag_dpd1',
    flag_dpd7                             BIGINT         COMMENT 'flag_dpd7',
    flag_dpd30                            BIGINT         COMMENT 'flag_dpd30',
    flag_dpd90                            BIGINT         COMMENT 'flag_dpd90',
    flag_cpd1                             BIGINT         COMMENT 'flag_cpd1',
    flag_cpd7                             BIGINT         COMMENT 'flag_cpd7',
    flag_cpd30                            BIGINT         COMMENT 'flag_cpd30',
    flag_cpd90                            BIGINT         COMMENT 'flag_cpd90', 
    flag_fpd1                             BIGINT         COMMENT 'flag_fpd1',
    flag_fpd7                             BIGINT         COMMENT 'flag_fpd7',
    flag_fpd30                            BIGINT         COMMENT 'flag_fpd30',
    flag_fpd90                            BIGINT         COMMENT 'flag_fpd90',
    flag_limit90                          BIGINT         COMMENT 'flag_limit90',
    
    flag_dpd1_limit90                     BIGINT         COMMENT 'flag_dpd1 * flag_limit90',
    flag_dpd7_limit90                     BIGINT         COMMENT 'flag_dpd7 * flag_limit90',
    flag_dpd30_limit90                    BIGINT         COMMENT 'flag_dpd30 * flag_limit90',
    flag_dpd90_limit90                    BIGINT         COMMENT 'flag_dpd90 * flag_limit90',
    flag_cpd1_limit90                     BIGINT         COMMENT 'flag_cpd1 * flag_limit90',
    flag_cpd7_limit90                     BIGINT         COMMENT 'flag_cpd7 * flag_limit90',
    flag_cpd30_limit90                    BIGINT         COMMENT 'flag_cpd30 * flag_limit90',
    flag_cpd90_limit90                    BIGINT         COMMENT 'flag_cpd90 * flag_limit90',
    flag_fpd1_limit90                     BIGINT         COMMENT 'flag_fpd1 * flag_limit90',
    flag_fpd7_limit90                     BIGINT         COMMENT 'flag_fpd7 * flag_limit90',
    flag_fpd30_limit90                    BIGINT         COMMENT 'flag_fpd30 * flag_limit90',
    flag_fpd90_limit90                    BIGINT         COMMENT 'flag_fpd90 * flag_limit90'
) 
COMMENT 'risk mart summary table'
PARTITIONED BY (grass_date string)
stored as orc tblproperties ("orc.compress" = "zstd")
location '${HDFS_PATH}/dws/dws_risk_${reg}_aio_user_overdue_tag_df/product_id = ${biz_type_code}'
;

with ${biz_type_string} as 
(
    select  platform_user_id
            ,credit_user_id
            ,biz_type
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
), 
hpd as 
(
    select  platform_user_id
            ,credit_user_id
            ,ever_max_dpd_eod as historical_max_dpd
            ,current_max_dpd_eod as current_max_dpd
            ,grass_date
    from    risk_feature.ads_risk_${biz_type_string}_${reg}_user_behavior_df
    where   ever_max_dpd_eod >= 1 and biz_type in (${biz_type_code})
      and   grass_date = '${ds}'
),
dpd90 as 
(
    select  ${biz_type_string}.platform_user_id
            ,${biz_type_string}.credit_user_id
            ,${biz_type_string}.biz_type
            ,case   when historical_max_dpd >= 1 then 1
                    else 0
             end as flag_dpd1
            ,case   when historical_max_dpd >= 7 then 1
                    else 0
             end as flag_dpd7
            ,case   when historical_max_dpd >= 30 then 1
                    else 0
             end as flag_dpd30
            ,case   when historical_max_dpd >= 90 then 1
                    else 0
             end as flag_dpd90
            ,case   when current_max_dpd >= 1 then 1
                    else 0
             end as flag_cpd1 
            ,case   when current_max_dpd >= 7 then 1
                    else 0
             end as flag_cpd7
            ,case   when current_max_dpd >= 30 then 1
                    else 0
             end as flag_cpd30 
            ,case   when current_max_dpd >= 90 then 1
                    else 0
             end as flag_cpd90
            ,case   when total_limit_utilisation >= 0.9 then 1
                    when total_available_credit_limit < 0 then 1
                    else 0
             end as flag_limit90
            ,${biz_type_string}.grass_date
   from ${biz_type_string} 
   left join hpd 
   on hpd.credit_user_id=${biz_type_string}.credit_user_id
     and hpd.platform_user_id=${biz_type_string}.platform_user_id
),
fpd90 as 
(
    select  credit_user_id
            ,platform_user_id
            ,max(max_dpd_eod) as fpd
            ,grass_date
            ,${biz_type_code} as biz_type
    from    credit_mart.dws_${biz_type_string}_aio_${reg}_loan_repayment_df
    where   total_amount_repayable > 0 and ${filter_condition}
      and   is_first_bill_loan = 1 and platform_type = 1
      and grass_date = '${ds}'
      and (
            case when '${risk_tab_biz_type}' = 'spl' then product_id = 3
              when '${risk_tab_biz_type}' = 'chp' then product_id = 3
              when '${risk_tab_biz_type}' = 'bcl' then product_id = 1
              when '${risk_tab_biz_type}' = 'tl' then product_id = 11
              else false end) 
      group by 1,2,4
)


insert overwrite table ${SCHEMA}.dws_risk_${reg}_${risk_tab_biz_type}_user_overdue_tag_df partition(grass_date = '${ds}')
select  dpd90.platform_user_id
        ,dpd90.credit_user_id
        ,dpd90.flag_dpd1
        ,dpd90.flag_dpd7
        ,dpd90.flag_dpd30
        ,dpd90.flag_dpd90
        ,dpd90.flag_cpd1
        ,dpd90.flag_cpd7
        ,dpd90.flag_cpd30
        ,dpd90.flag_cpd90
        ,case   when fpd90.fpd >= 1 then 1
                else 0
         end as flag_fpd90 
        ,case   when fpd90.fpd >= 7 then 1
                else 0
         end as flag_fpd7
        ,case   when fpd90.fpd >= 30 then 1
                else 0
         end as flag_fpd90
        ,case   when fpd90.fpd >= 90 then 1
                else 0
         end as flag_fpd90
        ,dpd90.flag_limit90
        ,dpd90.flag_dpd1  * dpd90.flag_limit90 as flag_dpd1_limit90
        ,dpd90.flag_dpd7  * dpd90.flag_limit90 as flag_dpd7_limit90
        ,dpd90.flag_dpd30 * dpd90.flag_limit90 as flag_dpd30_limit90
        ,dpd90.flag_dpd90 * dpd90.flag_limit90 as flag_dpd90_limit90
        ,dpd90.flag_cpd1  * dpd90.flag_limit90 as flag_cpd1_limit90
        ,dpd90.flag_cpd7  * dpd90.flag_limit90 as flag_cpd7_limit90
        ,dpd90.flag_cpd30 * dpd90.flag_limit90 as flag_cpd30_limit90
        ,dpd90.flag_cpd90 * dpd90.flag_limit90 as flag_cpd90_limit90
        ,case when fpd90.fpd >= 1  then dpd90.flag_limit90 else 0 end as flag_fpd1_limit90
        ,case when fpd90.fpd >= 7  then dpd90.flag_limit90 else 0 end as flag_fpd7_limit90
        ,case when fpd90.fpd >= 30 then dpd90.flag_limit90 else 0 end as flag_fpd30_limit90
        ,case when fpd90.fpd >= 90 then dpd90.flag_limit90 else 0 end as flag_fpd90_limit90
from dpd90
left join fpd90
on dpd90.credit_user_id = fpd90.credit_user_id 
  and dpd90.platform_user_id = fpd90.platform_user_id
  and dpd90.grass_date = fpd90.grass_date
  and dpd90.biz_type = fpd90.biz_type
;
