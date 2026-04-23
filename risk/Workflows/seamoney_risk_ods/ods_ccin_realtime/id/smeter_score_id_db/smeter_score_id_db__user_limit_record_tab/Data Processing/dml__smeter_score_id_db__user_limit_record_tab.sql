

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,credit_user_id                                                                                       as credit_user_id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,limit_type                                                                                           as limit_type
,permanent_limit                                                                                      as permanent_limit
,change_limit                                                                                         as change_limit
,apply_time                                                                                           as apply_time
,start_time                                                                                           as start_time
,end_time                                                                                             as end_time
,result_code                                                                                          as result_code
,result_msg                                                                                           as result_msg
,expiry_time                                                                                          as expiry_time
,reserved1                                                                                            as reserved1
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
,_event
 from(
    select 
 id                                                                                                   as id
,credit_user_id                                                                                       as credit_user_id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,limit_type                                                                                           as limit_type
,permanent_limit                                                                                      as permanent_limit
,change_limit                                                                                         as change_limit
,apply_time                                                                                           as apply_time
,start_time                                                                                           as start_time
,end_time                                                                                             as end_time
,result_code                                                                                          as result_code
,result_msg                                                                                           as result_msg
,expiry_time                                                                                          as expiry_time
,reserved1                                                                                            as reserved1
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,credit_user_id                                                                                       as credit_user_id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,limit_type                                                                                           as limit_type
,permanent_limit                                                                                      as permanent_limit
,change_limit                                                                                         as change_limit
,apply_time                                                                                           as apply_time
,start_time                                                                                           as start_time
,end_time                                                                                             as end_time
,result_code                                                                                          as result_code
,result_msg                                                                                           as result_msg
,expiry_time                                                                                          as expiry_time
,reserved1                                                                                            as reserved1
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__smeter_score_id_db__user_limit_record_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id
,cast(get_json_object(data,'$.credit_user_id') as string)                                             as credit_user_id
,cast(get_json_object(data,'$.platform_user_id') as string)                                           as platform_user_id
,cast(get_json_object(data,'$.platform_type') as bigint)                                              as platform_type
,cast(get_json_object(data,'$.limit_type') as bigint)                                                 as limit_type
,cast(get_json_object(data,'$.permanent_limit') as bigint)                                            as permanent_limit
,cast(get_json_object(data,'$.change_limit') as bigint)                                               as change_limit
,cast(get_json_object(data,'$.apply_time') as bigint)                                                 as apply_time
,cast(get_json_object(data,'$.start_time') as bigint)                                                 as start_time
,cast(get_json_object(data,'$.end_time') as bigint)                                                   as end_time
,cast(get_json_object(data,'$.result_code') as bigint)                                                as result_code
,cast(get_json_object(data,'$.result_msg') as string)                                                 as result_msg
,cast(get_json_object(data,'$.expiry_time') as bigint)                                                as expiry_time
,cast(get_json_object(data,'$.reserved1') as string)                                                  as reserved1
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'smeter_score_id_db' and base_table= 'user_limit_record_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time')/1000 - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete' 
)
insert overwrite table risk.ods__smeter_score_id_db__user_limit_record_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,credit_user_id                                                                                       as credit_user_id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,limit_type                                                                                           as limit_type
,permanent_limit                                                                                      as permanent_limit
,change_limit                                                                                         as change_limit
,apply_time                                                                                           as apply_time
,start_time                                                                                           as start_time
,end_time                                                                                             as end_time
,result_code                                                                                          as result_code
,result_msg                                                                                           as result_msg
,expiry_time                                                                                          as expiry_time
,reserved1                                                                                            as reserved1
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,_event
 ;