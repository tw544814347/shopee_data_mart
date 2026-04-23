-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2026-03-10
-- Theme Domain:        User Basic Info MP Feature
-- Data Granularity:    shopee_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-03-10 - chengguo.liu - 初始化
-- =============================================================================

--drop table if exists ${SCHEMA}.dws_risk_${region}_user_info_mp_basic_info_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_info_mp_basic_info_df
(
    shopee_user_id string comment 'shopee user id'
    ,is_svip_active bigint comment 'whether the user is vip or not'
)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_user_info_mp_basic_info_df/grass_region=${grass_region}';
--msck repair table ${SCHEMA}.dws_risk_${region}_user_info_mp_basic_info_df;


insert overwrite table ${SCHEMA}.dws_risk_${region}_user_info_mp_basic_info_df partition (grass_date = '${grass_date}')
select t1.shopee_user_id
        ,t2.is_svip_active
from (
    select
        cast(user_id as string) as shopee_user_id
    from mp_user.dim_user__reg_s0_live
    where
        tz_type = 'local'
        and grass_region = '${grass_region}'
        and grass_date = '${grass_date}'
) t1
left join (
    select  cast(user_id as string) as shopee_user_id
            ,is_svip_active
    from    mp_user.dim_user_ext__reg_s0_live
    where   tz_type = 'local'
    and grass_region = '${grass_region}'
    and grass_date = '${grass_date}'
) t2
on t1.shopee_user_id = t2.shopee_user_id
;