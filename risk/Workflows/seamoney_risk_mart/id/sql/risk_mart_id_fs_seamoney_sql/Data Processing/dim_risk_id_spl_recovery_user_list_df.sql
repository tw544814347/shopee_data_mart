--********************************************************************--
-- Author:              zhicheng.chen
-- Created Time:        2025-09-11
-- Theme Domain：       user_info
-- Description:         smcdrisk_policy.id_spl_realtime_recovery_user_list源表没有日切，因此透传加日切做dim表，便于后续定位问题
-- Data Granularity:    
-- 变更历史：
--********************************************************************--
create external table if not exists ${SCHEMA}.dim_risk_id_spl_recovery_user_list_df (
    platform_user_id 			string comment 'platform_user_id'
    ,is_spl_recovered 	int comment 'is spl recovered'
)
partitioned by (
    grass_date 			string comment 'yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd") 
location  '${HDFS_PATH}/risk_mart/dim/dim_risk_spl_recovery_user_list_df/grass_region=ID'
comment 'snapshot of smcdrisk_policy.id_spl_realtime_recovery_user_list on every day';

insert overwrite table ${SCHEMA}.dim_risk_id_spl_recovery_user_list_df partition(grass_date)
select 
platform_user_id
,is_spl_recovered
,'${grass_date}'  as grass_date
from smcdrisk_policy.id_spl_realtime_recovery_user_list 
;