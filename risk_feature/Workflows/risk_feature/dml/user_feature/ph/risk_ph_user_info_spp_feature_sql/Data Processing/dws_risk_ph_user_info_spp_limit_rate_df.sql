-- =============================================================================
-- Author:              chenyingying@shopee.com
-- Created Time:        2026-01-26
-- Theme Domain:        User Info Limit Credit Feature
-- Data Granularity:    platform_user_id
-- Description: PH暂时还是platform user id，2C业务，等待DFS切换为shopeepay user id       
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-01-26 - chenyingying - 初始化
-- =============================================================================

--drop table if exists ${SCHEMA}.dws_risk_${region}_user_info_spp_limit_rate_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_info_spp_limit_rate_df(
    platform_user_id   string  comment 'shopeepay user id'
    ,expected_bcl_limit     decimal(30,10)  comment 'expected bcl limit'
    ,expected_bcl_interest_rate decimal(30,10)  comment 'expected bcl interest rate'
)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_user_info_spp_limit_rate_df/grass_region=${grass_region}';
--msck repair table ${SCHEMA}.dws_risk_${region}_user_info_spp_limit_rate_df;

insert overwrite table ${SCHEMA}.dws_risk_${region}_user_info_spp_limit_rate_df partition(grass_date='${ds}')
select t1.platform_user_id
        ,t2.expected_bcl_interest_rate
        ,t3.expected_bcl_limit
from (
    select user_id as platform_user_id
    from    mp_user.dim_user__${region}_s0_live
    where   grass_date = '${ds}'
) t1
left join (
    select  platform_user_id
            ,nominal_interest_rate / decimal_base as expected_bcl_interest_rate
    from credit_uc.dwd_uc_bcl_${region}_pre_activation_fee_rate_info_df
    where grass_date = '${ds}'
    and credit_type = 1
    and status = 1 
    and platform_type = 1
) t2
on t1.platform_user_id = t2.platform_user_id
left join (
    select  platform_user_id
            ,total_quota_amount as expected_bcl_limit
    from credit_uc.dwd_uc_bcl_${region}_pre_activation_limit_info_df
    where grass_date = '${ds}'
    and credit_type = 1
    and status = 1
    and sub_quota_type = 1
) t3
on t1.platform_user_id = t3.platform_user_id
