--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-02-04
-- Theme Domain：       pricing_center 名单
-- Description:         pc 商户白名单汇总,且用于QDC 因此保留近5天分区即可
-- Data Granularity:    shopid
-- 变更历史：         
--********************************************************************--

drop  table if exists risk.ads_risk_pricing_center_list_df;
create external table if not exists risk.ads_risk_pricing_center_list_df
(
shop_id                   string          comment 'available shopid'
,status                   int             comment '1-available'
)
partitioned by (
table_name string comment ""
,grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ads/ads_risk_pricing_center_list_df'
;


insert overwrite table risk.ads_risk_pricing_center_list_df partition (table_name,grass_date)
select 
shop_id
,status 
,'ads_risk_br_spl_pricing_center_shop_availablelist_df' as table_name 
,grass_date 
from risk.ads_risk_br_spl_pricing_center_shop_availablelist_df 
where grass_date ='${grass_date}'
union all 
select 
shop_id
,status 
,'ads_risk_br_spl_pricing_center_shop_blacklist_df' as table_name 
,grass_date 
from risk.ads_risk_br_spl_pricing_center_shop_blacklist_df 
where grass_date ='${grass_date}'
;

msck repair table risk.ads_risk_pricing_center_list_df;