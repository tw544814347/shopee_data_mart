

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,event_code                                                                                           as event_code
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,check_result                                                                                         as check_result
,method                                                                                               as method
,operator                                                                                             as operator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
,_event
 from(
    select 
 id                                                                                                   as id
,event_code                                                                                           as event_code
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,check_result                                                                                         as check_result
,method                                                                                               as method
,operator                                                                                             as operator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,event_code                                                                                           as event_code
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,check_result                                                                                         as check_result
,method                                                                                               as method
,operator                                                                                             as operator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_id_db__risk_event_action_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.event_code') as string)                                                 as event_code
,cast(get_json_object(data,'$.app_id') as string)                                                     as app_id
,cast(get_json_object(data,'$.scene_id') as bigint)                                                   as scene_id
,cast(get_json_object(data,'$.check_result') as string)                                               as check_result
,cast(get_json_object(data,'$.method') as string)                                                     as method
,cast(get_json_object(data,'$.operator') as string)                                                   as operator
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_control_id_db' and base_table= 'risk_event_action_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_control_id_db__risk_event_action_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,event_code                                                                                           as event_code
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,check_result                                                                                         as check_result
,method                                                                                               as method
,operator                                                                                             as operator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,_event
 ;