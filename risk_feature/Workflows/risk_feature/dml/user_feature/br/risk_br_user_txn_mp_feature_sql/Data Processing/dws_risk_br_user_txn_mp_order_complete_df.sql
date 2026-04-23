-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2026-03-11
-- Theme Domain:        User Txn MP Order Complete Feature
-- Data Granularity:    shopee_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-03-11 - chengguo.liu - 初始化
-- =============================================================================

drop table if exists ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_complete_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_complete_df (
    shopee_user_id                                    string     comment 'shopee user id'
    ,platform_user_id                                  string     comment 'platform user id'
)
partitioned by (
    grass_date                                        string     comment 'Partition, YYYY-MM-DD'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_aio_user_txn_mp_order_complete_df/grass_region=${grass_region}';
msck repair table ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_complete_df;


insert overwrite table ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_complete_df partition(grass_date ='${grass_date}')
select
    t1.shopee_user_id
    ,t1.shopee_user_id as platform_user_id
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
;
