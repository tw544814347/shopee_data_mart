--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-05-30
-- Theme Domain：       反欺诈-custom_list
-- Description:         名单同步到holmes
-- Data Granularity:    data
-- 变更历史：
--      update by zongyi.lu@shopee.com， 增加注释，切换risk.dim_risk_th_credit_dict_df Mart表

create or replace temporary view risk_th_all_list as
select
    t1.data          as data 
    ,t1.description  as table_name
    ,t1.data_type    as data_type 
    ,-1              as status
from risk.dwd_risk_th_credit_custom_list_df t1 
where grass_date ='${grass_date}'
and data_source='DE'  
and status=1
    group by t1.data 
    ,t1.description
    ,t1.data_type
;
;

insert overwrite table risk.ads_risk_th_blacklist_di partition (grass_region, grass_date, table_name)
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
        ,'TH'                    as grass_region 
        ,sum(status) status 
    from (
        select
            t1.data          as data 
            ,t2.dict_name    as datatype
            ,case when lower(t1.table_name)='blacklist_clustering_tddf_th'  then  'th_blacklist_clustering_tddf'
                  when lower(t1.table_name)='blacklist_clustering_spdf_th'  then  'th_blacklist_clustering_spdf'
                  when lower(t1.table_name)='blacklist_shopee_fraud_tag_th' then  'th_blacklist_shopee_fraud_tag'
                  when lower(t1.table_name)='blacklist_overdue_users_th'    then  'th_blacklist_overdue_users'
                  when lower(t1.table_name)='ec_overdue_th'                 then  'th_ec_overdue'
                  when lower(t1.table_name)='blacklist_clustering_tddf_th'  then  'th_blacklist_clustering_tddf'
                  when lower(t1.table_name)='blacklist_cashout_shops_th'    then  'th_blacklist_cashout_shops'
                  else lower(t1.table_name) end    as table_name
            ,-1              as status
        from risk_th_all_list t1 
        left join (
            select 
            dict_value
            ,dict_name 
            from risk.dim_risk_th_credit_dict_df 
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
            ,'th_blacklist_shopee_fraud_tag' as table_name 
            ,1 status
        from smcdrisk_antifraud.th_blacklist_shopee_fraud_tag
        group by data
                ,datatype
        union all 
        select  
            data
            ,datatype 
            ,'th_ec_overdue' as table_name 
            ,1 status
        from smcdrisk_antifraud.th_ec_overdue
        group by data
                ,datatype
        union all 
        select  
            data
            ,datatype 
            ,'th_blacklist_overdue_users' as table_name 
            ,1 status
        from smcdrisk_antifraud.th_blacklist_overdue_users
        group by data
                ,datatype
        union all 
        select  
            data
            ,datatype 
            ,'th_blacklist_clustering_spdf' as table_name 
            ,1 status
        from smcdrisk_antifraud.th_blacklist_clustering_spdf
        group by data
                ,datatype
        union all 
        select  
            data
            ,datatype 
            ,'th_blacklist_clustering_tddf' as table_name 
            ,1 status
        from smcdrisk_antifraud.th_blacklist_clustering_tddf
        group by data
                ,datatype
        union all 
        select  
            data
            ,datatype 
            ,'th_blacklist_cashout_shops' as table_name 
            ,1 status
        from smcdrisk_antifraud.th_blacklist_cashout_shops
        group by data
                ,datatype
        union all 
        select  
            data
            ,dataType
            ,'th_blacklist_overdue_users_shopee' as table_name
            ,1 status
        from smcdrisk_antifraud.th_blacklist_overdue_users_shopee
        group by data
        ,datatype
        union all 
        select  
            data
            ,dataType
            ,'th_blacklist_fake_id_spp_users' as table_name
            ,1 status
        from smcdrisk_antifraud.th_blacklist_fake_id_spp_users
        group by data
        ,datatype
        union all 
        select  
            data
            ,dataType
            ,'th_overdue_users_dpd30' as table_name
            ,1 status
        from smcdrisk_antifraud.th_overdue_users_dpd30
        group by data
        ,datatype
        union all 
        select  
            data
            ,dataType
            ,'th_mp_cashout_shop_auto_blacklist' as table_name
            ,1 status
        from smcdrisk_antifraud.th_mp_cashout_shop_auto_blacklist
        group by data
        ,datatype
    ) a 
    group by data 
    ,datatype 
    ,table_name
) a 
where status<>0
;

