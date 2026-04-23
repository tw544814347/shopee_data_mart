--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-05-30
-- Theme Domain：       反欺诈-custom_list
-- Description:         名单同步到holmes
-- Data Granularity:    data
-- 变更历史：
--      update by zongyi.lu@shopee.com， 增加注释，切换risk.dim_risk_id_credit_dict_df Mart表

create or replace temporary view risk_id_all_list as
select
    t1.data          as data 
    ,t1.description  as table_name
    ,t1.data_type    as data_type 
    ,-1              as status
from risk.dwd_risk_id_credit_custom_list_df t1 
where grass_date ='${grass_date}'
and data_source='DE'  
and status=1
    group by t1.data 
    ,t1.description
    ,t1.data_type
;

insert overwrite table risk.ads_risk_id_blacklist_di partition (grass_region, grass_date, table_name)
select 
    data                             as data 
    ,datatype                        as datatype 
    ,'DE daily update ${grass_date}' as remark         
    ,table_name                      as description     
    ,status                          as status 
    ,grass_region                    as grass_region 
    ,'${grass_date}'                 as grass_date 
    ,table_name                      as table_name 
from (
    select 
        data                     as data
        ,datatype                as datatype
        ,table_name              as table_name 
        ,'ID'                    as grass_region 
        ,sum(status) status 
    from (
        select
            t1.data          as data 
            ,t2.dict_name    as datatype
            ,t1.table_name   as table_name
            ,-1              as status
        from risk_id_all_list t1 
        left join (
            select 
            dict_value
            ,dict_name 
            from risk.dim_risk_id_credit_dict_df 
            where grass_date='${grass_date}'
            and parent_dict_key='dataType' 
            group by dict_value
            ,dict_name 
        ) t2 on t1.data_type = t2.dict_value
        group by t1.data 
        ,t2.dict_name
        ,t1.table_name
        union all 
        select  
            data
            ,datatype 
            ,'risky_itemid_table_id' as table_name 
            ,1 status
        from smcdrisk_antifraud.risky_itemid_table_id
        group by data
                ,datatype
        union all 
        select  
            data
            ,datatype 
            ,'blacklist_ato_id' as table_name 
            ,1 status
        from smcdrisk_antifraud.blacklist_ato_id
        group by data
                ,datatype
        union all 
        select  
            data
            ,datatype 
            ,'blacklist_cashout_id' as table_name 
            ,1 status
        from smcdrisk_antifraud.blacklist_cashout_id
        group by data
                ,datatype
        union all 
        select  
            data
            ,datatype 
            ,'blacklist_overdue_id' as table_name 
            ,1 status
        from smcdrisk_antifraud.blacklist_overdue_id
        group by data
                ,datatype
        union all 
        select  
            data
            ,datatype 
            ,'blacklist_shopee_device_consentration_id' as table_name 
            ,1 status
        from smcdrisk_antifraud.blacklist_shopee_device_consentration_id
        group by data
                ,datatype
        union all 
        select  
            data
            ,datatype 
            ,'blacklist_shopee_fraud_tag_id' as table_name 
            ,1 status
        from smcdrisk_antifraud.blacklist_shopee_fraud_tag_id
        group by data
                ,datatype
        union all 
        select  
            data
            ,datatype 
            ,'greylist_cashout_id' as table_name 
            ,1 status
        from smcdrisk_antifraud.greylist_cashout_id
        group by data
                ,datatype
        union all 
        select  
            data
            ,datatype 
            ,'greylist_overdue_shipping_info_id' as table_name 
            ,1 status
        from smcdrisk_antifraud.greylist_overdue_shipping_info_id
        group by data
                ,datatype
        union all 
        select  
            data
            ,datatype 
            ,'greylist_shopee_device_consentration_id' as table_name 
            ,1 status
        from smcdrisk_antifraud.greylist_shopee_device_consentration_id
        group by data
                ,datatype
        union all 
        select  
            data
            ,datatype 
            ,'mp_shop_auto_blacklist_table_id' as table_name 
            ,1 status
        from smcdrisk_antifraud.mp_shop_auto_blacklist_table_id
        group by data
                ,datatype
        union all 
        select  
            data
            ,datatype 
            ,'auto_tok_bad_shop_list_id' as table_name 
            ,1 status
        from smcdrisk_antifraud.auto_tok_bad_shop_list_id
        group by data
                ,datatype
        union all 
        select  
            data
            ,datatype 
            ,'auto_virtual_orders_bad_shop_list_id' as table_name 
            ,1 status
        from smcdrisk_antifraud.auto_virtual_orders_bad_shop_list_id
        group by data
                ,datatype
        union all 
        select  
        data
        ,datatype 
        ,'high_risk_shop_bl_w_shop_tier_id' as table_name 
        ,1 status
        from smcdrisk_antifraud.high_risk_shop_bl_w_shop_tier_id
        group by data
                ,datatype
        union all 
        select  
        data
        ,datatype 
        ,'cashout_shop_bl_newbuyer_1storder_newdistrict_id' as table_name 
        ,1 status
        from smcdrisk_antifraud.cashout_shop_bl_newbuyer_1storder_newdistrict_id
        group by data
                ,datatype
        union all 
        select  
        data
        ,datatype 
        ,'high_risk_shop_tier2_bl_w_shop_tier_id' as table_name 
        ,1 status
        from smcdrisk_antifraud.high_risk_shop_tier2_bl_w_shop_tier_id
        group by data
                ,datatype
        union all 
        select  
        data
        ,datatype 
        ,'cashout_shop_tier2_bl_newbuyer_1storder_newdistrict_id' as table_name 
        ,1 status
        from smcdrisk_antifraud.cashout_shop_tier2_bl_newbuyer_1storder_newdistrict_id
        group by data
                ,datatype
        union all 
        select  
        data
        ,datatype 
        ,'id_mp_highrisky_shop_v2' as table_name 
        ,1 status
        from smcdrisk_antifraud.id_mp_highrisky_shop_v2
        group by data
                ,datatype
        union all 
        select  
        data
        ,datatype 
        ,'bl_30days_shops_for_30001_bad_req_shopid_id' as table_name 
        ,1 status
        from smcdrisk_antifraud.bl_30days_shops_for_30001_bad_req_shopid_id
        group by data
                ,datatype
        union all 
        select  
        data
        ,datatype 
        ,'mp_cashout_shop_linkage_id' as table_name 
        ,1 status
        from smcdrisk_antifraud.mp_cashout_shop_linkage_id
        group by data
                ,datatype
        -- union all 
        -- select  
        -- data
        -- ,datatype 
        -- ,'id_offus_userconstraint_inactive_storelist_de' as table_name 
        -- ,1 status
        -- from smcdrisk_antifraud.id_offus_userconstraint_inactive_storelist_de
        -- group by data
        --         ,datatype
        union all 
        select  
        data
        ,datatype 
        ,'id_offus_userconstraint_activesus_storelist_de' as table_name 
        ,1 status
        from smcdrisk_antifraud.id_offus_userconstraint_activesus_storelist_de
        group by data
                ,datatype
        union all 
        select  
        data
        ,datatype 
        ,'id_offus_userconstraint_all_storelist_de' as table_name 
        ,1 status
        from smcdrisk_antifraud.id_offus_userconstraint_all_storelist_de
        group by data
                ,datatype
        union all 
        select  
        data
        ,datatype 
        ,'id_offus_blacklist_store_de' as table_name 
        ,1 status
        from smcdrisk_antifraud.id_offus_blacklist_store_de
        group by data
                ,datatype
        union all 
        select  
        data
        ,datatype 
        ,'id_offus_online_store_de' as table_name 
        ,1 status
        from smcdrisk_antifraud.id_offus_online_store_de
        group by data
                ,datatype
    ) a 
    group by data 
    ,datatype 
    ,table_name
) a 
where status<>0
;

