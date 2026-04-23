--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-10-20
-- Theme Domain：       Anti-fraud user overdue feature
-- Description:         https://jira.shopee.io/browse/SPFDT-56370
-- Data Granularity:    
-- Change Log:
--      update by wei.tao  MX 地区 + tl 产品 都暂时使用这个表，后续会根据需求调整 2026-02-02
--********************************************************************--
CREATE TABLE IF NOT EXISTS ${SCHEMA}.dws_risk_${reg}_${risk_tab_biz_type}_user_overdue_info_df (
    platform_user_id             STRING             COMMENT 'platform_user_id',
    credit_user_id               STRING             COMMENT 'credit_user_id',
    max_dpd_l2y                  BIGINT             COMMENT 'user max DPD days in last 24 month',
    max_limit_usage_rate_l2y     DECIMAL(20,10)     COMMENT 'the max limit usage rate in last 24 month',
    flag_dpd30_l2y_limit90       BIGINT             COMMENT '1: the user max DPD days in last 24 month > 30 && the limit usage rate >=90% on that overdue due day;0: others',
    flag_dpd30_l2y               BIGINT             COMMENT 'flag_dpd30_l2y'
) 
COMMENT 'risk mart summary table'
PARTITIONED BY (grass_date string)
stored as orc tblproperties ("orc.compress" = "zstd")
location '${HDFS_PATH}/dws/dws_risk_${reg}_aio_user_overdue_info_df/product_id = ${biz_type_code}'
;

with ${biz_type_string}_l2y as 
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
    where  grass_date between cast(date_sub(to_date('${ds}'), 720) as string) and '${ds}'
    and biz_type in (${biz_type_code}) and platform_type = 1
    and (
        case when '${risk_tab_biz_type}' = 'spl' then product_id = 3
        when '${risk_tab_biz_type}' = 'chp' then product_id = 3
        when '${risk_tab_biz_type}' = 'bcl' then product_id = 1
        when '${risk_tab_biz_type}' = 'tl' then product_id = 11
        else false end) 
),
hpd_l2y as 
(
    select  platform_user_id
            ,credit_user_id
            ,current_max_dpd_eod as current_max_dpd
            ,grass_date
    from    risk_feature.ads_risk_${biz_type_string}_${reg}_user_behavior_df
    where   current_max_dpd_eod >= 1 and biz_type in (${biz_type_code})
      and   grass_date between cast(date_sub(to_date('${ds}'), 720) as string) and '${ds}'
)

insert overwrite table ${SCHEMA}.dws_risk_${reg}_${risk_tab_biz_type}_user_overdue_info_df partition(grass_date = '${ds}')
select  ${biz_type_string}.platform_user_id
        ,${biz_type_string}.credit_user_id
        ,max(current_max_dpd) as max_dpd_l2y
        ,max(total_limit_utilisation) as max_limit_usage_rate_l2y
        ,max(case when current_max_dpd>=30 and (total_limit_utilisation >= 0.9 or total_available_credit_limit < 0) then 1 else 0 end) as flag_dpd30_l2y_limit90
        ,max(case when current_max_dpd>=30 then 1 else 0 end) as flag_dpd30_l2y
from    ${biz_type_string}_l2y ${biz_type_string}
left join hpd_l2y hpd on hpd.credit_user_id = ${biz_type_string}.credit_user_id
and   hpd.grass_date = ${biz_type_string}.grass_date 
and   hpd.platform_user_id = ${biz_type_string}.platform_user_id
group by ${biz_type_string}.platform_user_id
        ,${biz_type_string}.credit_user_id
;
