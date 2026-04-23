--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-03-04
-- Theme Domain：       platform_user_id
-- Description:         id bcl ota 黑名单
-- Data Granularity:    platform_user_id
-- 变更历史：          
-- 2024-05-08通过gsheet来控制名单 https://docs.google.com/spreadsheets/d/1KH1yIdMzIW-9SmYDPs66g8sBYwGD1jI7bfD0h9nzBb8/edit#gid=0
-- 将ddl语句放在dml脚本中便于维护
--********************************************************************--

-- insert overwrite table risk.ads_risk_id_spl_ota_user_blacklist_di partition(grass_date ='${grass_date}')
-- select 
--     t1.user_id  as user_id
--     ,1          as status 
-- from risk.ads_risk_id_spl_ota_user_blacklist_df t1
-- left join (
--     select 
--     user_id 
--     from risk.ads_risk_id_spl_ota_user_blacklist_df t2 
--     where grass_date =date_sub('${grass_date}',1)
--     group by user_id
-- ) t2 on t1.user_id = t2.user_id
-- where grass_date ='${grass_date}' and  t2.user_id is null 

-- union all 
-- select 
--     t1.user_id  as user_id
--     ,0       as status 
-- from risk.ads_risk_id_spl_ota_user_blacklist_df t1
-- left join (
--     select 
--     user_id 
--     from risk.ads_risk_id_spl_ota_user_blacklist_df t2 
--     where grass_date ='${grass_date}'
--     group by user_id
-- ) t2 on t1.user_id = t2.user_id
-- where grass_date =date_sub('${grass_date}',1)
-- and t2.user_id is null 
-- ;

-- 只需要在维护的时候才drop
-- drop table if exists ${SCHEMA}.ads_risk_id_bcl_ota_user_blacklist_di;
create external table if not exists ${SCHEMA}.ads_risk_id_bcl_ota_user_blacklist_di
(
user_id       string               comment  "Shopee platform user id credit系统用户ID"
,status       int                  comment "1-新增; 0-删除"
)
partitioned by
(
    grass_date     string   comment "YYYY-MM-DD"
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/ads/ads_risk_ota_user_blacklist_di/garss_region=ID/biz_name=bcl';

-- 只需要在维护的时候才msck
-- msck repair table ${SCHEMA}.ads_risk_id_bcl_ota_user_blacklist_di;

insert overwrite table ${SCHEMA}.ads_risk_id_bcl_ota_user_blacklist_di partition(grass_date ='${grass_date}')
select 
user_id  as user_id 
,cast(status as int)      as status
from risk.ads_risk_id_bcl_ota_user_blacklist_manual
where status='1'
;

