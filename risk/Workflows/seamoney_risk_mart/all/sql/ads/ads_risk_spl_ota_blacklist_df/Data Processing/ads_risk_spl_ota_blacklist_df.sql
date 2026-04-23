--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-02-04
-- Theme Domain：       spl ota 黑名单
-- Description:         spl ota 黑名单汇总,且用于QDC
-- Data Granularity:    platform_user_id
-- 变更历史：         
--********************************************************************--

drop  table if exists risk.ads_risk_spl_ota_blacklist_df;
create external table if not exists risk.ads_risk_spl_ota_blacklist_df
(
platform_user_id          string          comment 'platform_user_id'
,status                   int             comment '1-available'
)
partitioned by (
table_name string comment ""
,grass_date string comment "partition date yyyy-MM-dd")
comment 'Tag:risk summary table'
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/risk_mart/ads/ads_risk_spl_ota_blacklist_df'
;


insert overwrite table risk.ads_risk_spl_ota_blacklist_df partition (table_name,grass_date)
select 
shopee_userid as platform_user_id
,is_blacklist as status 
,'ads_risk_ph_spl_ota_user_blacklist_df' as table_name 
,grass_date 
from risk.ads_risk_ph_spl_ota_user_blacklist_df 
where grass_date ='${grass_date}'
union all 
select 
user_id as platform_user_id
,status 
,'ads_risk_id_spl_ota_user_blacklist_df' as table_name 
,grass_date 
from risk.ads_risk_id_spl_ota_user_blacklist_df 
where grass_date ='${grass_date}'
;

msck repair table risk.ads_risk_spl_ota_blacklist_df;
