

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,task_id                                                                                              as task_id
,task_category                                                                                        as task_category
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,status                                                                                               as status
,result                                                                                               as result
,result_info                                                                                          as result_info
,task_info                                                                                            as task_info
,task_output                                                                                          as task_output
,sign                                                                                                 as sign
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
,_event
 from(
    select 
 id                                                                                                   as id
,task_id                                                                                              as task_id
,task_category                                                                                        as task_category
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,status                                                                                               as status
,result                                                                                               as result
,result_info                                                                                          as result_info
,task_info                                                                                            as task_info
,task_output                                                                                          as task_output
,sign                                                                                                 as sign
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,task_id                                                                                              as task_id
,task_category                                                                                        as task_category
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,status                                                                                               as status
,result                                                                                               as result
,result_info                                                                                          as result_info
,task_info                                                                                            as task_info
,task_output                                                                                          as task_output
,sign                                                                                                 as sign
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_id_db__user_involve_task_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.task_id') as string)                                                    as task_id
,cast(get_json_object(data,'$.task_category') as byte)                                                as task_category
,cast(get_json_object(data,'$.app_id') as string)                                                     as app_id
,cast(get_json_object(data,'$.scene_id') as bigint)                                                   as scene_id
,cast(get_json_object(data,'$.platform_user_id') as string)                                           as platform_user_id
,cast(get_json_object(data,'$.status') as byte)                                                       as status
,cast(get_json_object(data,'$.result') as byte)                                                       as result
,cast(get_json_object(data,'$.result_info') as string)                                                as result_info
,cast(get_json_object(data,'$.task_info') as string)                                                  as task_info
,cast(get_json_object(data,'$.task_output') as string)                                                as task_output
,cast(get_json_object(data,'$.sign') as string)                                                       as sign
,cast(get_json_object(data,'$.version') as bigint)                                                    as version
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_control_id_db' and base_table= 'user_involve_task_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_control_id_db__user_involve_task_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,task_id                                                                                              as task_id
,task_category                                                                                        as task_category
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,status                                                                                               as status
,result                                                                                               as result
,result_info                                                                                          as result_info
,task_info                                                                                            as task_info
,task_output                                                                                          as task_output
,sign                                                                                                 as sign
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,_event
 ;