-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-11-18
-- Theme Domain:        User Base Info MP Feature
-- Data Granularity:    shopee_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-01-15 - chengguo.liu - 初始化
-- =============================================================================

-- drop table if exists ${SCHEMA}.dws_risk_${region}_user_info_mp_feature_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_info_mp_feature_df
(
    shopee_user_id string comment 'shopee user id'
    ,shopee_account_status string comment 'shopee account status'
    ,cic_group3_freeze_status int comment 'cic group3 freeze status'
    ,is_svip_active           bigint comment 'whether the user is vip or not'
)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_user_info_mp_feature_df/grass_region=${grass_region}';
-- msck repair table ${SCHEMA}.dws_risk_${region}_user_info_mp_feature_df;


insert overwrite table ${SCHEMA}.dws_risk_${region}_user_info_mp_feature_df partition (grass_date = '${grass_date}')
select
    t1.shopee_user_id
    ,t1.shopee_account_status
    ,t2.cic_group3_freeze_status
    ,t3.is_svip_active
from
(
    select
        user_id as shopee_user_id
        ,status as shopee_account_status
    from mp_user.dim_user__reg_s0_live
    where
        tz_type = 'local'
        and grass_region = '${grass_region}'
        and grass_date = '${grass_date}'
) t1
left join
(
    select
        shopee_user_id
        ,cic_group3_freeze_status
    from ${SCHEMA}.dws_risk_${region}_user_info_mp_user_metrics_biz_manage_df
    where grass_date = '${grass_date}'
) t2
on t1.shopee_user_id = t2.shopee_user_id
left join
(
    select shopee_user_id
            ,is_svip_active
    from ${SCHEMA}.dws_risk_${region}_user_info_mp_basic_info_df
    where   grass_date = '${ds}'
) t3
on t1.shopee_user_id = t3.shopee_user_id
;