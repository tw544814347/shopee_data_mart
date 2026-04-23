-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2026-02-05
-- Theme Domain:        User Score MP Feature
-- Data Granularity:    shopee_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-02-05 - chengguo.liu - 初始化
-- =============================================================================


--drop table if exists ${SCHEMA}.dws_risk_${region}_user_score_mp_feature_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_score_mp_feature_df (
    shopee_user_id                  string comment 'shopee user id'
    ,user_bcard_credit_score_v20    double comment 'user bcard credit score v2.0'
)
partitioned by (grass_date string comment 'grass_date, partition key')
stored as orc tblproperties ("orc.compress" = "zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_user_score_mp_feature_df/grass_region=${grass_region}';
--msck repair table ${SCHEMA}.dws_risk_${region}_user_score_mp_feature_df;


insert overwrite table ${SCHEMA}.dws_risk_${region}_user_score_mp_feature_df partition (grass_date = '${grass_date}')
select
    t1.shopee_user_id
    ,t2.user_bcard_credit_score_v20
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
        ,cast(get_json_object(score, '$.score') as double) as user_bcard_credit_score_v20
    from risk.dws_risk_user_score_df
    where
        grass_region = '${grass_region}'
        and grass_date = '${grass_date}'
        and biz_type = 'user_bcard_credit_score'
        and model_version = 'v2.0'
) t2
on t1.shopee_user_id = t2.shopee_user_id
;
