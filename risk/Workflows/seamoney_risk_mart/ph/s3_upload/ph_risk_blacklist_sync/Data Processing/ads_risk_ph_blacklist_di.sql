--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-05-30
-- Theme Domain：       反欺诈-custom_list
-- Description:         名单同步到holmes
-- Data Granularity:    data
-- 变更历史：
--      update by zongyi.lu@shopee.com， 增加注释，切换risk.dim_risk_ph_credit_dict_df Mart表

create or replace temporary view risk_ph_all_list as
select
    t1.data          as data 
    ,t1.description  as table_name
    ,t1.data_type    as data_type 
    ,-1              as status
from risk.dwd_risk_ph_credit_custom_list_df t1 
where grass_date ='${grass_date}'
and data_source='DE'  
and status=1
    group by t1.data 
    ,t1.description
    ,t1.data_type
;

insert overwrite table risk.ads_risk_ph_blacklist_di partition (grass_region, grass_date, table_name)
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
        ,'PH'                    as grass_region 
        ,sum(status) status 
    from (
        select
            t1.data          as data 
            ,t2.dict_name    as datatype
            ,t1.table_name   as table_name
            ,-1              as status
        from risk_ph_all_list t1 
        left join (
            select 
            dict_value
            ,dict_name 
            from risk.dim_risk_ph_credit_dict_df 
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
            ,'blacklist_spdf_ph' as table_name 
            ,1 status
        from smcdrisk_antifraud.blacklist_spdf_ph
        group by data
                ,datatype
        union all 
        select  
            data
            ,datatype 
            ,'blacklist_tddf_ph' as table_name 
            ,1 status
        from smcdrisk_antifraud.blacklist_tddf_ph
        group by data
                ,datatype
        union all 
        select  
            data
            ,datatype 
            ,'ec_overdue_ph' as table_name 
            ,1 status
        from smcdrisk_antifraud.ec_overdue_ph
        group by data
                ,datatype
        union all 
        select  
            data
            ,datatype 
            ,'blacklist_fraud_tag_ph' as table_name 
            ,1 status
        from smcdrisk_antifraud.blacklist_fraud_tag_ph
        group by data
                ,datatype
        union all 
        select  
            data
            ,datatype 
            ,'blacklist_user_graph_ph' as table_name 
            ,1 status
        from smcdrisk_antifraud.blacklist_user_graph_ph
        group by data
                ,datatype
        union all 
        select  
            data
            ,datatype 
            ,'blacklist_overdue_users_ph' as table_name 
            ,1 status
        from smcdrisk_antifraud.blacklist_overdue_users_ph
        group by data
                ,datatype
        union all 
        select  
            data
            ,datatype 
            ,'blacklist_screening_ph' as table_name 
            ,1 status
        from smcdrisk_antifraud.blacklist_screening_ph
        group by data
                ,datatype
        union all 
        select  
            data
            ,datatype 
            ,'mp_auto_seller_whitelist_ph' as table_name 
            ,1 status
        from smcdrisk_antifraud.mp_auto_seller_whitelist_ph
        group by data
                ,datatype
        union all 
        select  
            data
            ,datatype 
            ,'blacklist_ph' as table_name 
            ,1 status
        from smcdrisk_antifraud.blacklist_ph
        group by data
                ,datatype
        union all 
        select  
            data
            ,datatype 
            ,'blacklist_cashout_shops_ph' as table_name 
            ,1 status
        from smcdrisk_antifraud.blacklist_cashout_shops_ph
        group by data
                ,datatype
        union all 
        select  
            data
            ,datatype 
            ,'ph_blacklist_overdue_users_shopee' as table_name 
            ,1 status
        from smcdrisk_antifraud.ph_blacklist_overdue_users_shopee
        group by data
                ,datatype
        union all 
        select  
            data
            ,datatype 
            ,'ph_overdue_users_dpd30' as table_name 
            ,1 status
        from smcdrisk_antifraud.ph_overdue_users_dpd30
        group by data
                ,datatype
        union all 
        select  
        data
        ,datatype 
        ,'ph_blacklist_uw_freeze_users' as table_name 
        ,1 status
        from smcdrisk_antifraud.ph_blacklist_uw_freeze_users
        group by data
                ,datatype
        union all 
        select  
        data
        ,datatype 
        ,'ph_mp_highrisky_device_ba_phone_linked_shop' as table_name 
        ,1 status
        from smcdrisk_antifraud.ph_mp_highrisky_device_ba_phone_linked_shop
        group by data
                ,datatype
        union all 
        select  
        data
        ,datatype 
        ,'ph_blacklist_spp_account_selling' as table_name 
        ,1 status
        from smcdrisk_antifraud.ph_blacklist_spp_account_selling
        group by data
                ,datatype
        union all 
        select  
        data
        ,datatype 
        ,'cashout_pattern_shop_blacklist_ph' as table_name 
        ,1 status
        from smcdrisk_antifraud.cashout_pattern_shop_blacklist_ph
        group by data
                ,datatype
        
    ) a 
    group by data 
    ,datatype 
    ,table_name
) a 
where status<>0
;

