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

--drop table if exists ${SCHEMA}.dws_risk_${region}_user_info_spp_feature_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_info_spp_feature_df(
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
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_user_info_spp_feature_df/grass_region=${grass_region}';
--msck repair table ${SCHEMA}.dws_risk_${region}_user_info_spp_featur_df;

insert overwrite table ${SCHEMA}.dws_risk_${region}_user_info_spp_feature_df partition(grass_date='${ds}')
select  t1.platform_user_id
        ,t2.expected_bcl_limit          as expected_bcl_limit
        ,t2.expected_bcl_interest_rate  as expected_bcl_interest_rate
from (
    select user_id as platform_user_id
    from    mp_user.dim_user__${region}_s0_live
    where   grass_date = '${ds}'
) t1
left join (
    select platform_user_id
            ,expected_bcl_limit
            ,expected_bcl_interest_rate
    from    risk_feature.dws_risk_${region}_user_info_spp_limit_rate_df
    where   grass_date = '${ds}'
) t2
on t1.platform_user_id = t2.platform_user_id