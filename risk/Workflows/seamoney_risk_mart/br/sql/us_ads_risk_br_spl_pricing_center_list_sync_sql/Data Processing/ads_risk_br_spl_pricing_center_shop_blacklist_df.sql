--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-01-19
-- Theme Domain：       br_spl_pricing_center shop blacklist
-- Description:         商户黑名单
--                     
-- 变更历史：
-- update by zongyi.lu@shopee.com 2024-05-16 修改成mart表,新增注释
--********************************************************************--

insert overwrite table risk.ads_risk_br_spl_pricing_center_shop_blacklist_df partition(grass_date ='${grass_date}')
select 
data  as  shop_id
,1    as  status
from risk.dwd_risk_br_credit_custom_list_df
where grass_date ='${grass_date}'
and custom_list_name in ('MP_Banned_Category_IDs') 
and status = 1 
and data_type=13
;
-- select 
-- data  as  shop_id
-- ,1    as  status
-- from
-- (
--     select 
--         id
--         ,list_name
--     from risk.ods__credit_risk_control_br_db__custom_list_tab__df
--     where grass_date='${grass_date}' 
--     and list_name in ('MP_Banned_Category_IDs') 
-- ) a
-- join(
--     select 
--     data
--     ,custom_list_id
--     ,data_type
--     from risk.ods__credit_risk_control_br_db__custom_list_rare_type_tab__df
--     where grass_date='${grass_date}' 
--     and status = 1 
--     and data_type=13
-- ) b on a.id=b.custom_list_id
-- group by shop_id
-- ;



