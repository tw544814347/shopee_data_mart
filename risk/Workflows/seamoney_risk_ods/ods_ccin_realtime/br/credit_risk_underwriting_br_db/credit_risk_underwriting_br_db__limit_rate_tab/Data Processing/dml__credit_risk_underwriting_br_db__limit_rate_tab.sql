



refresh table risk.ccin_multi_realtime_binlog_for_br;

from (
    select 
 id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,app_id                                                                                               as app_id
,sub_biz_type                                                                                         as sub_biz_type
,version                                                                                              as version
,currency_units                                                                                       as currency_units
,operator                                                                                             as operator
,sync_credit_status                                                                                   as sync_credit_status
,event_id                                                                                             as event_id
,event_detail                                                                                         as event_detail
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,activation_source                                                                                    as activation_source
,source                                                                                               as source
,limit_info                                                                                           as limit_info
,installment_info                                                                                     as installment_info
,rate_info                                                                                            as rate_info
,other_info                                                                                           as other_info

,_event
 from(
    select 
 id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,app_id                                                                                               as app_id
,sub_biz_type                                                                                         as sub_biz_type
,version                                                                                              as version
,currency_units                                                                                       as currency_units
,operator                                                                                             as operator
,sync_credit_status                                                                                   as sync_credit_status
,event_id                                                                                             as event_id
,event_detail                                                                                         as event_detail
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,activation_source                                                                                    as activation_source
,source                                                                                               as source
,limit_info                                                                                           as limit_info
,installment_info                                                                                     as installment_info
,rate_info                                                                                            as rate_info
,other_info                                                                                           as other_info

 ,_event
,row_number() over(partition by on_keys_conds order by update_time desc,get_json_object(_event,'$.ts') desc, get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,app_id                                                                                               as app_id
,sub_biz_type                                                                                         as sub_biz_type
,version                                                                                              as version
,currency_units                                                                                       as currency_units
,operator                                                                                             as operator
,sync_credit_status                                                                                   as sync_credit_status
,event_id                                                                                             as event_id
,event_detail                                                                                         as event_detail
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,activation_source                                                                                    as activation_source
,source                                                                                               as source
,limit_info                                                                                           as limit_info
,installment_info                                                                                     as installment_info
,rate_info                                                                                            as rate_info
,other_info                                                                                           as other_info

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)                    as on_keys_conds

,_event
        from risk.ods__credit_risk_underwriting_br_db__limit_rate_tab__df__private fs
        where grass_date = date_add('${grass_date}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id 
,cast(get_json_object(data,'$.platform_user_id') as string)                                           as platform_user_id 
,cast(get_json_object(data,'$.platform_type') as bigint)                                              as platform_type 
,cast(get_json_object(data,'$.app_id') as bigint)                                                     as app_id 
,cast(get_json_object(data,'$.sub_biz_type') as string)                                               as sub_biz_type 
,cast(get_json_object(data,'$.version') as bigint)                                                    as version 
,cast(get_json_object(data,'$.currency_units') as bigint)                                             as currency_units 
,cast(get_json_object(data,'$.operator') as string)                                                   as operator 
,cast(get_json_object(data,'$.sync_credit_status') as bigint)                                         as sync_credit_status 
,cast(get_json_object(data,'$.event_id') as string)                                                   as event_id 
,cast(get_json_object(data,'$.event_detail') as string)                                               as event_detail 
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time 
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time 
,cast(get_json_object(data,'$.activation_source') as bigint)                                          as activation_source 
,cast(get_json_object(data,'$.source') as string)                                                     as source 
,cast(get_json_object(data,'$.limit_info') as string)                                                 as limit_info 
,cast(get_json_object(data,'$.installment_info') as string)                                           as installment_info 
,cast(get_json_object(data,'$.rate_info') as string)                                                  as rate_info 
,cast(get_json_object(data,'$.other_info') as string)                                                 as other_info 

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),get_json_object(data,'$.id')) as on_keys_conds

,_event
        from risk.ccin_multi_realtime_binlog_for_br 
        where base_database = 'credit_risk_underwriting_br_db' and base_table = 'limit_rate_tab'
        --base_database like 'credit_risk_underwriting_br_db%' and base_table like 'limit_rate_tab%'
        and (dt 
              between date_add('${grass_date}', -2) 
              and if('${binlog_src_end_date}' >= '${grass_date}', '${binlog_src_end_date}' ,date_add('${grass_date}', 10))
            ) 
         and from_unixtime(get_json_object(data,'$.update_time') - 39600,'yyyy-MM-dd') <= '${grass_date}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)

    
insert overwrite table risk.ods__credit_risk_underwriting_br_db__limit_rate_tab__df__private partition(grass_date = '${grass_date}')
select 
 id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,app_id                                                                                               as app_id
,sub_biz_type                                                                                         as sub_biz_type
,version                                                                                              as version
,currency_units                                                                                       as currency_units
,operator                                                                                             as operator
,sync_credit_status                                                                                   as sync_credit_status
,event_id                                                                                             as event_id
,event_detail                                                                                         as event_detail
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,activation_source                                                                                    as activation_source
,source                                                                                               as source
,limit_info                                                                                           as limit_info
,installment_info                                                                                     as installment_info
,rate_info                                                                                            as rate_info
,other_info                                                                                           as other_info

 ,_event


;
---------------------------msck repair table for all dest dbs---------------------------------------

msck repair table risk.ods__credit_risk_underwriting_br_db__limit_rate_tab__df__private;

refresh table risk.ods__credit_risk_underwriting_br_db__limit_rate_tab__df__private;

    