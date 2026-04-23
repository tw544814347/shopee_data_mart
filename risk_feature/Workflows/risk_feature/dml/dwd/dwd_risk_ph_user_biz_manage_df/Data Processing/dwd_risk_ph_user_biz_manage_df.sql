-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-10-22
-- Theme Domain:        user biz manage table sync
-- Data Granularity:    shopee_user_id
-- Description:         业务透传表，无加工逻辑，dwd表整合
-- Documents:           
-- =============================================================================
--  Version History:
--  2025-10-22 - chengguo.liu - 初始化
-- =============================================================================


--drop table if exists ${SCHEMA}.dwd_risk_ph_user_biz_manage_df;
create table if not exists ${SCHEMA}.dwd_risk_ph_user_biz_manage_df
(
    shopee_user_id string comment 'platform_user_id'
    ,is_uw_proactively_wl int comment 'category'
)
partitioned by
(
    grass_date string comment 'grass_date, partition key'
)
stored as orc
tblproperties
(
    "orc.compress" = "zstd"
)
location '${HDFS_PATH}/risk_feature/dwd/dwd_risk_ph_user_biz_manage_df';
--msck repair table ${SCHEMA}.dwd_risk_ph_user_biz_manage_df;



insert overwrite table ${SCHEMA}.dwd_risk_ph_user_biz_manage_df partition (grass_date = '${grass_date}')
select
     t1.shopee_user_id
    ,t2.is_uw_proactively_wl       
from(
        select
            user_id as shopee_user_id
        from mp_user.dim_user__reg_s0_live
        where tz_type = 'local'
        and grass_region = 'PH'
        and grass_date = '${grass_date}'
    ) t1
    left join (
        select
            platform_user_id as shopee_user_id
            ,is_uw_proactively_wl
        from smcdrisk_policy.ph_splx_proactive_wl
    ) t2 on t1.shopee_user_id = t2.shopee_user_id
;