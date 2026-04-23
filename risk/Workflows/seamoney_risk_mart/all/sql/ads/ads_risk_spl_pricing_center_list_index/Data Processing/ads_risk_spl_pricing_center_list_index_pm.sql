--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-07-23
-- Theme Domain：       pricing center index
-- Description:         https://jira.shopee.io/browse/SPFDT-42323   BE会根据这个index去判断是否要更新名单的数据
--                      -- 但是存在一个问题,如果名单到下午才更新的话就会影响上午批次的名单,因此将index文件在14:00再更新一次或者依赖调度较晚的名单表marker
-- Data Granularity:    
-- 变更历史：
--      update by 2024-07-23 zongyi.lu@shopee.com 1.新增spl plus 名单 https://jira.shopee.io/browse/SPFDT-42323
--********************************************************************--

insert overwrite table risk.ads_risk_spl_pricing_center_list_index partition(grass_date='${grass_date}')
select 
t1.table_name
,max(case when t1.flag in (1,-1) then 1 else 0 end)  as is_update
from (
    select 
        tt1.table_name as table_name 
        ,tt1.data      as data
        ,sum(tt1.flag) as flag 
    from (
        select 
            shop_id                                                 as data 
            ,'ads_risk_th_spl_pricing_center_shop_availablelist_df' as table_name 
            ,1                                                      as flag 
        from risk.ads_risk_th_spl_pricing_center_shop_availablelist_df
        where grass_date='${grass_date}'
        group by shop_id
        union all 
        select 
            shop_id                                                 as data 
            ,'ads_risk_th_spl_pricing_center_shop_availablelist_df' as table_name 
            ,-1                                                     as flag 
        from risk.ads_risk_th_spl_pricing_center_shop_availablelist_df
        where grass_date=date_sub('${grass_date}',1)
        group by shop_id
        union all 
        select 
            shop_id                                                 as data 
            ,'ads_risk_th_spl_pricing_center_shop_blacklist_df'     as table_name 
            ,1                                                      as flag 
        from risk.ads_risk_th_spl_pricing_center_shop_blacklist_df
        where grass_date='${grass_date}'
        group by shop_id
        union all 
        select 
            shop_id                                                 as data 
            ,'ads_risk_th_spl_pricing_center_shop_blacklist_df'     as table_name 
            ,-1                                                     as flag 
        from risk.ads_risk_th_spl_pricing_center_shop_blacklist_df
        where grass_date=date_sub('${grass_date}',1)
        group by shop_id

        union all 
        select 
            shop_id                                                 as data 
            ,'ads_risk_ph_spl_pricing_center_shop_availablelist_df' as table_name 
            ,1                                                      as flag 
        from risk.ads_risk_ph_spl_pricing_center_shop_availablelist_df
        where grass_date='${grass_date}'
        group by shop_id
        union all 
        select 
            shop_id                                                 as data 
            ,'ads_risk_ph_spl_pricing_center_shop_availablelist_df' as table_name 
            ,-1                                                     as flag 
        from risk.ads_risk_ph_spl_pricing_center_shop_availablelist_df
        where grass_date=date_sub('${grass_date}',1)
        group by shop_id
        union all 
        select 
            shop_id                                                 as data 
            ,'ads_risk_ph_spl_pricing_center_shop_blacklist_df'     as table_name 
            ,1                                                      as flag 
        from risk.ads_risk_ph_spl_pricing_center_shop_blacklist_df
        where grass_date='${grass_date}'
        group by shop_id
        union all 
        select 
            shop_id                                                 as data 
            ,'ads_risk_ph_spl_pricing_center_shop_blacklist_df'     as table_name 
            ,-1                                                     as flag 
        from risk.ads_risk_ph_spl_pricing_center_shop_blacklist_df
        where grass_date=date_sub('${grass_date}',1)
        group by shop_id

        union all 
        select 
            shop_id                                                 as data 
            ,'ads_risk_my_spl_pricing_center_shop_availablelist_df' as table_name 
            ,1                                                      as flag 
        from risk.ads_risk_my_spl_pricing_center_shop_availablelist_df
        where grass_date='${grass_date}'
        group by shop_id
        union all 
        select 
            shop_id                                                 as data 
            ,'ads_risk_my_spl_pricing_center_shop_availablelist_df' as table_name 
            ,-1                                                     as flag 
        from risk.ads_risk_my_spl_pricing_center_shop_availablelist_df
        where grass_date=date_sub('${grass_date}',1)
        group by shop_id
        union all 
        select 
            shop_id                                                 as data 
            ,'ads_risk_my_spl_pricing_center_shop_blacklist_df'     as table_name 
            ,1                                                      as flag 
        from risk.ads_risk_my_spl_pricing_center_shop_blacklist_df
        where grass_date='${grass_date}'
        group by shop_id
        union all 
        select 
            shop_id                                                 as data 
            ,'ads_risk_my_spl_pricing_center_shop_blacklist_df'     as table_name 
            ,-1                                                     as flag 
        from risk.ads_risk_my_spl_pricing_center_shop_blacklist_df
        where grass_date=date_sub('${grass_date}',1)
        group by shop_id


        union all 
        select 
            item_id                                                 as data 
            ,'ads_risk_id_spl_pricing_center_item_blacklist_df'     as table_name 
            ,1                                                      as flag 
        from risk.ads_risk_id_spl_pricing_center_item_blacklist_df
        where grass_date='${grass_date}'
        group by item_id
        union all 
        select 
            item_id                                                 as data 
            ,'ads_risk_id_spl_pricing_center_item_blacklist_df'     as table_name 
            ,-1                                                     as flag 
        from risk.ads_risk_id_spl_pricing_center_item_blacklist_df
        where grass_date=date_sub('${grass_date}',1)
        group by item_id
        union all 
        select 
            shop_id                                                 as data 
            ,'ads_risk_id_spl_pricing_center_shop_availablelist_df'     as table_name 
            ,1                                                      as flag 
        from risk.ads_risk_id_spl_pricing_center_shop_availablelist_df
        where grass_date='${grass_date}'
        group by shop_id
        union all 
        select 
            shop_id                                                 as data 
            ,'ads_risk_id_spl_pricing_center_shop_availablelist_df'     as table_name 
            ,-1                                                     as flag 
        from risk.ads_risk_id_spl_pricing_center_shop_availablelist_df
        where grass_date=date_sub('${grass_date}',1)
        group by shop_id
        union all 
        select 
            shop_id                                                 as data 
            ,'ads_risk_sg_spl_pricing_center_shop_availablelist_df'     as table_name 
            ,1                                                      as flag 
        from risk.ads_risk_sg_spl_pricing_center_shop_availablelist_df
        where grass_date='${grass_date}'
        group by shop_id
        union all 
        select 
            shop_id                                                 as data 
            ,'ads_risk_sg_spl_pricing_center_shop_availablelist_df'     as table_name 
            ,-1                                                     as flag 
        from risk.ads_risk_sg_spl_pricing_center_shop_availablelist_df
        where grass_date=date_sub('${grass_date}',1)
        group by shop_id
        
        -- update by zongyi.lu 新增spl plus名单 
        union all 
        select 
            data                                                 as data 
            ,'ads_risk_id_spl_plus_pricing_center_shop_whitelist_df'     as table_name 
            ,1                                                      as flag 
        from risk.ads_risk_id_spl_plus_pricing_center_shop_whitelist_df
        where grass_date='${grass_date}'
        group by data
        union all 
        select 
            data                                                 as data 
            ,'ads_risk_id_spl_plus_pricing_center_shop_whitelist_df'     as table_name 
            ,-1                                                     as flag 
        from risk.ads_risk_id_spl_plus_pricing_center_shop_whitelist_df
        where grass_date=date_sub('${grass_date}',1)
        group by data
        union all 
        select 
            data                                                 as data 
            ,'ads_risk_id_spl_plus_pricing_center_user_blacklist_df'     as table_name 
            ,1                                                      as flag 
        from risk.ads_risk_id_spl_plus_pricing_center_user_blacklist_df
        where grass_date='${grass_date}'
        group by data
        union all 
        select 
            data                                                 as data 
            ,'ads_risk_id_spl_plus_pricing_center_user_blacklist_df'     as table_name 
            ,-1                                                     as flag 
        from risk.ads_risk_id_spl_plus_pricing_center_user_blacklist_df
        where grass_date=date_sub('${grass_date}',1)
        group by data
        union all 
        select 
            data                                                 as data 
            ,'ads_risk_id_spl_plus_pricing_center_item_blacklist_df'     as table_name 
            ,1                                                      as flag 
        from risk.ads_risk_id_spl_plus_pricing_center_item_blacklist_df
        where grass_date='${grass_date}'
        group by data
        union all 
        select 
            data                                                 as data 
            ,'ads_risk_id_spl_plus_pricing_center_item_blacklist_df'     as table_name 
            ,-1                                                     as flag 
        from risk.ads_risk_id_spl_plus_pricing_center_item_blacklist_df
        where grass_date=date_sub('${grass_date}',1)
        group by data
        
    
    ) tt1 
    group by 
        tt1.table_name 
        ,tt1.data
) t1 
group by 
t1.table_name
;