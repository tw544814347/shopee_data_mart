--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-05-30
-- Theme Domain：       反欺诈-custom_list
-- Description:         名单同步到holmes
-- Data Granularity:    data
-- 变更历史：
--      update by zongyi.lu@shopee.com， 增加注释，切换risk.dim_risk_my_credit_dict_df Mart表
create or replace temporary view risk_my_all_list as
select
    t1.data          as data 
    ,t1.description  as table_name
    ,t1.data_type    as data_type 
    ,-1              as status
from risk.dwd_risk_my_credit_custom_list_df t1 
where grass_date ='${grass_date}'
and data_source='DE'  
and status=1
    group by t1.data 
    ,t1.description
    ,t1.data_type
union all 
select
    t1.data          as data 
    ,t1.description  as table_name
    ,t1.data_type    as data_type 
    ,-1              as status
from risk.dwd_risk_my_shopeepay_custom_list_df t1 
where grass_date ='${grass_date}'
and data_source='DE'  
and status=1
    group by t1.data 
    ,t1.description
    ,t1.data_type
;
;

insert overwrite table risk.ads_risk_my_blacklist_di partition (grass_region, grass_date, table_name)
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
        ,'MY'                    as grass_region 
        ,sum(status) status 
    from (
        select
            t1.data          as data 
            ,t2.dict_name    as datatype
            ,t1.table_name   as table_name
            ,-1              as status
        from risk_my_all_list t1 
        left join (
            select 
            dict_value
            ,dict_name 
            from risk.dim_risk_my_credit_dict_df 
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
            ,'blacklist_overdue_my' as table_name 
            ,1 status
        from smcdrisk_antifraud.blacklist_overdue_my
        group by data
                ,datatype
        union all 
        select  
            data
            ,datatype 
            ,'risky_itemid_table_my' as table_name 
            ,1 status
        from smcdrisk_antifraud.risky_itemid_table_my
        group by data
                ,datatype
        union all 
        select  
            data
            ,datatype 
            ,'list_automation_test_channel_1' as table_name 
            ,1 status
        from smcdrisk_antifraud.list_automation_test_channel_1
        group by data
                ,datatype
        union all 
        select  
            data
            ,datatype 
            ,'list_automation_test_channel_2' as table_name 
            ,1 status
        from smcdrisk_antifraud.list_automation_test_channel_2
        group by data
                ,datatype
        
    ) a 
    group by data 
    ,datatype 
    ,table_name
) a 
where status<>0
;

