--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-03-19
-- Theme Domain：       shop
-- Description:         sg shop-level availablelist used by pricing center
-- Data Granularity:    shop_id
-- 变更历史：          
-- 2024-03-19 zongyi.lu 1.黑名单逻辑更新(https://docs.google.com/document/d/1hBL6DzFgyoMajFqP7-lV8_YxSrHUdT7sVUe5W2jCpl4/edit)
--                      2. 换成mart表  
--********************************************************************--

-- SG  整体可用SPL商户

create or replace temporary view  wl_shop as --白名单商户
select 
data as shop_id
from risk.dwd_risk_sg_credit_custom_list_df
where grass_date ='${grass_date}'
and custom_list_name in ('BD_tag_list')
and data_type='12'
and status = '1'
;
-- select 
--     data as shop_id 
-- from (
--         select  
--             id
--             ,list_name
--     from risk.ods__credit_risk_control_sg_db__custom_list_tab__df
--     where grass_date = '${grass_date}'
--     -- and list_name = 'seller_management_whitelist'
--     and list_name = 'BD_tag_list'
--     group by 
--         id
--         ,list_name
-- ) a join (
--     select  
--         data
--         ,custom_list_id
--     from risk.ods__credit_risk_control_sg_db__custom_list_rare_type_tab__df
--     where grass_date ='${grass_date}'
--     and data_type = 12
--     and status = 1
-- )b on a.id = b.custom_list_id
-- ;


create or replace temporary view  blacklist as 
select 
shop_id
from(
select 
data as shop_id
from risk.dwd_risk_sg_credit_custom_list_df
where grass_date='${grass_date}'  
and custom_list_name in ('seller_management_blacklist')
and data_type=12 
and status = 1
union
select 
 cast(shop_id as string) as shop_id
from smcdrisk_antifraud.mp_shop_blacklist_all_region_dqq
where grass_region = 'SG'
group by cast(shop_id as string)
) a 
group by shop_id
;
-- select 
--     data as shop_id 
-- from (
--     select  
--        id
--        ,list_name
--     from  risk.ods__credit_risk_control_sg_db__custom_list_tab__df
--     where grass_date ='${grass_date}'
--     and list_name = 'seller_management_blacklist'
-- ) a join (
--     select  
--         data
--         ,custom_list_id
--     from risk.ods__credit_risk_control_sg_db__custom_list_rare_type_tab__df
--     where grass_date ='${grass_date}'
--     and data_type = 12
--     and status = 1
-- )b on a.id = b.custom_list_id
-- ;

insert overwrite table  risk.ads_risk_sg_spl_pricing_center_shop_availablelist_df partition(grass_date='${grass_date}')
select 
    t1.shop_id as shop_id
    ,1        as status 
from wl_shop t1 
left join blacklist t2 on t1.shop_id=t2.shop_id
where t2.shop_id is null 
;