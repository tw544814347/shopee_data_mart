-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2026-03-05
-- Theme Domain:        MP User Metrics Biz Manage Feature
-- Data Granularity:    shopee_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-03-05 - chengguo.liu - 初始化
-- =============================================================================

--drop table if exists ${SCHEMA}.dws_risk_${region}_user_info_mp_user_metrics_biz_manage_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_info_mp_user_metrics_biz_manage_df
(
    shopee_user_id string comment 'shopee user id'
    ,cic_group3_freeze_status int comment 'cic group3 freeze status'
)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_user_info_mp_user_metrics_biz_manage_df/grass_region=${grass_region}';
--msck repair table ${SCHEMA}.dws_risk_${region}_user_info_mp_user_metrics_biz_manage_df;


insert overwrite table ${SCHEMA}.dws_risk_${region}_user_info_mp_user_metrics_biz_manage_df partition (grass_date = '${grass_date}')
select
    t1.shopee_user_id
    ,if(t2.shopee_user_id<>'', 1, 0) as cic_group3_freeze_status
from
(
    select
        user_id as shopee_user_id
    from mp_user.dim_user__reg_s0_live
    where
        tz_type = 'local'
        and grass_region = '${grass_region}'
        and grass_date = '${grass_date}'
) t1
left join
(
    select
        platform_user_id as shopee_user_id
    from smcdrisk_policy.vn_cic_group_3_check_userlist
) t2
on t1.shopee_user_id = t2.shopee_user_id
;