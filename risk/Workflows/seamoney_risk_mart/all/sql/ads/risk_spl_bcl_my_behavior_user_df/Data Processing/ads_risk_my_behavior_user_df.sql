--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2026-01-07
-- Theme Domain：       
-- Description:         
-- Data Granularity:    platform_user_id + credit_user_id
-- 变更历史
-- update by wei.tao@shopee.com on 2026-03-09 一个月只有个别几天业务表会有数据 added defualt value ensure dqc can pass
--********************************************************************--


DROP TABLE IF EXISTS ${SCHEMA}.ads_risk_my_behavior_user_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_my_behavior_user_df
(
    
    platform_user_id	string,
    credit_user_id    string
    
)
PARTITIONED BY
(
  grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_mart/ads/risk_spl_bcl_my_behavior_user_df';
MSCK REPAIR TABLE ${SCHEMA}.ads_risk_my_behavior_user_df;


insert overwrite table ${SCHEMA}.ads_risk_my_behavior_user_df
partition (grass_date = '${ds}')

select cast(platform_user_id as bigint) as platform_user_id, cast(credit_uesr_id as bigint) as credit_user_id
from smcdrisk_policy.my_plm_freeze_decrease_table
UNION ALL 
select cast('999999999' as bigint) as platform_user_id, cast('999999999' as bigint) as credit_user_id
-- select platform_user_id, credit_user_id
-- from credit_mart.wide_spl_my_behavior_user_df
-- where grass_date = '${ds}'
-- union 
-- select platform_user_id, credit_user_id
-- from credit_mart.wide_bcl_my_behavior_user_df
-- where grass_date = '${ds}'
