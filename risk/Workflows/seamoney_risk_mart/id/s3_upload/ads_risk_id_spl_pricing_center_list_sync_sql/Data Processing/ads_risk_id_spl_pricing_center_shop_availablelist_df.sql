-- ## 2023-04-25 zongyi.lu blacklist 逻辑中新增四个名单数据
--  'cashout_shop_bl_newbuyer_1storder_newdistrict_id'
--  'cashout_shop_tier2_bl_newbuyer_1storder_newdistrict_id'
--  'high_risk_shop_bl_w_shop_tier_id'
--  'high_risk_shop_tier2_bl_w_shop_tier_id'
--  剔除如下名单'Seller_Management_Whiltelist_Exit'
--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-03-19
-- Theme Domain：       shop
-- Description:         id shop-level availablelist used by pricing center
-- Data Granularity:    shop_id
-- 变更历史：          
-- 2024-03-19 zongyi.lu 1.黑名单逻辑更新(https://docs.google.com/document/d/1hBL6DzFgyoMajFqP7-lV8_YxSrHUdT7sVUe5W2jCpl4/edit)
--                      2. 换成mart表  
--********************************************************************--


create or replace temporary view  wl_shop as -- 白名单商户
select 
data as shop_id
from risk.dwd_risk_id_credit_custom_list_df
where grass_date ='${grass_date}'
and custom_list_name in ('Seller_Management_Whiltelist')
and data_type='12'
and status = '1'
;
-- select 
--     data as shop_id 
-- from( 
--         select  
--             id
--             ,list_name
--         from risk.ods__credit_risk_control_id_db__custom_list_tab__df
--         where grass_date ='${grass_date}' 
--         and list_name = 'Seller_Management_Whiltelist'
--         group by 
--              id
--             ,list_name
--     ) a join (
--         select  
--             data
--             ,custom_list_id
--         from risk.ods__credit_risk_control_id_db__custom_list_rare_type_tab__df
--         where grass_date ='${grass_date}' 
--         and data_type = 12
--         and status = 1
--     )b on a.id = b.custom_list_id
-- ;
create or replace temporary view  blacklist as
select cast(shop_id as string) shop_id
from smcdrisk_antifraud.mp_shop_blacklist_all_region_dqq
where grass_region = 'ID'
group by cast(shop_id as string) 
;

-- -- ID MP swap out whitelist
-- select 
--     data as shop_id 
-- from   
-- (
--     select  
--         id
--         ,list_name
--     from risk.ods__credit_risk_control_id_db__custom_list_tab__df
--     where grass_date ='${grass_date}' 
--     and list_name in( 
--      'cashout_shop_bl_newbuyer_1storder_newdistrict_id'
--     ,'cashout_shop_tier2_bl_newbuyer_1storder_newdistrict_id'
--     ,'high_risk_shop_bl_w_shop_tier_id'
--     ,'high_risk_shop_tier2_bl_w_shop_tier_id'
--     )
--     group by 
--         id
--         ,list_name
-- ) a join (
--     select  
--         data
--         ,custom_list_id
--     from risk.ods__credit_risk_control_id_db__custom_list_rare_type_tab__df
--     where grass_date ='${grass_date}' 
--         and data_type = 12
--         and status = 1
-- )b on a.id = b.custom_list_id
-- ;

insert overwrite table  risk.ads_risk_id_spl_pricing_center_shop_availablelist_df partition(grass_date='${grass_date}')
select 
    t1.shop_id as shop_id
    ,1        as status
from wl_shop t1
left join blacklist t2 on t1.shop_id=t2.shop_id
where t2.shop_id is null 
;
