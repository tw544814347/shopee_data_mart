--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-11-14
-- Theme Domain：       item_blacklist 
-- Description:         由于处理ID之外，之前传的shop_blacklist名单都应该是item_id,因此此处先做view 做兼容(1: 名字从shop_blacklist改为item_blacklist；2. 字段shop_id改为item_id)
--                      涉及 BR MY PH TH VN
-- 变更历史：
--********************************************************************--
drop view if exists risk.ads_risk_${region}_spl_pricing_center_item_blacklist_df;

create view if not exists risk.ads_risk_${region}_spl_pricing_center_item_blacklist_df as 
select 
shop_id as item_id 
,status 
,grass_date
from risk.ads_risk_${region}_spl_pricing_center_shop_blacklist_df
;