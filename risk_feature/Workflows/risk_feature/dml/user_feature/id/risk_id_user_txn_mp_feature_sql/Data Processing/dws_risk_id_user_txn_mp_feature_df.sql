-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-11-18
-- Theme Domain:        User Txn MP Feature
-- Data Granularity:    shopee_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-03-11 - chengguo.liu - 初始化
-- =============================================================================

drop table if exists ${SCHEMA}.dws_risk_${region}_user_txn_mp_feature_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_txn_mp_feature_df
(
    shopee_user_id string comment 'shopee user id'
    ,completed_order_avg_duration_1m bigint comment 'average completed order duration in last 1 month (30 days)'
    ,completed_order_avg_duration_3m bigint comment 'average completed order duration in last 3 months (90 days)'
    ,completed_order_avg_duration_6m bigint comment 'average completed order duration in last 6 months (180 days)'
    ,last3_completed_order_avg_duration_3m bigint comment 'average completed order duration in last 3 months (90 days) for the last 3 completed orders'
)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_user_txn_mp_feature_df/grass_region=${grass_region}';
msck repair table ${SCHEMA}.dws_risk_${region}_user_txn_mp_feature_df;


insert overwrite table ${SCHEMA}.dws_risk_${region}_user_txn_mp_feature_df partition (grass_date = '${grass_date}')
select
    t1.shopee_user_id
    ,t2.completed_order_avg_duration_1m
    ,t2.completed_order_avg_duration_3m
    ,t2.completed_order_avg_duration_6m
    ,t2.last3_completed_order_avg_duration_3m
from (
    select  user_id as shopee_user_id
    from mp_user.dim_user__reg_s0_live
    where   tz_type = 'local'
    and grass_region = '${grass_region}'
    and grass_date = '${grass_date}'
) t1
left join
(
    select
        shopee_user_id
        ,completed_order_avg_duration_1m
        ,completed_order_avg_duration_3m
        ,completed_order_avg_duration_6m
        ,last3_completed_order_avg_duration_3m
    from ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_complete_df
    where grass_date = '${grass_date}'
) t2
on t1.shopee_user_id = t2.shopee_user_id
;