

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,flow_no                                                                                              as flow_no
,req_no                                                                                               as req_no
,model_status                                                                                         as model_status
,model_input                                                                                          as model_input
,model_result                                                                                         as model_result
,model_provider                                                                                       as model_provider
,model_name                                                                                           as model_name
,model_version                                                                                        as model_version
,model_code                                                                                           as model_code
,notify_result                                                                                        as notify_result
,notify_time                                                                                          as notify_time
,query_result                                                                                         as query_result
,query_time                                                                                           as query_time
,query_count                                                                                          as query_count
,version                                                                                              as version
,remark                                                                                               as remark
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,processor_name                                                                                       as processor_name
,model_run_status                                                                                     as model_run_status
 
,_event
 from(
    select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,flow_no                                                                                              as flow_no
,req_no                                                                                               as req_no
,model_status                                                                                         as model_status
,model_input                                                                                          as model_input
,model_result                                                                                         as model_result
,model_provider                                                                                       as model_provider
,model_name                                                                                           as model_name
,model_version                                                                                        as model_version
,model_code                                                                                           as model_code
,notify_result                                                                                        as notify_result
,notify_time                                                                                          as notify_time
,query_result                                                                                         as query_result
,query_time                                                                                           as query_time
,query_count                                                                                          as query_count
,version                                                                                              as version
,remark                                                                                               as remark
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,processor_name                                                                                       as processor_name
,model_run_status                                                                                     as model_run_status
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,flow_no                                                                                              as flow_no
,req_no                                                                                               as req_no
,model_status                                                                                         as model_status
,model_input                                                                                          as model_input
,model_result                                                                                         as model_result
,model_provider                                                                                       as model_provider
,model_name                                                                                           as model_name
,model_version                                                                                        as model_version
,model_code                                                                                           as model_code
,notify_result                                                                                        as notify_result
,notify_time                                                                                          as notify_time
,query_result                                                                                         as query_result
,query_time                                                                                           as query_time
,query_count                                                                                          as query_count
,version                                                                                              as version
,remark                                                                                               as remark
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,processor_name                                                                                       as processor_name
,model_run_status                                                                                     as model_run_status
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_id_cf_db__model_req_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.app_id') as string)                                                     as app_id
,cast(get_json_object(data,'$.scene_id') as bigint)                                                   as scene_id
,cast(get_json_object(data,'$.platform_user_id') as string)                                           as platform_user_id
,cast(get_json_object(data,'$.flow_no') as string)                                                    as flow_no
,cast(get_json_object(data,'$.req_no') as string)                                                     as req_no
,cast(get_json_object(data,'$.model_status') as bigint)                                               as model_status
,cast(get_json_object(data,'$.model_input') as string)                                                as model_input
,cast(get_json_object(data,'$.model_result') as string)                                               as model_result
,cast(get_json_object(data,'$.model_provider') as string)                                             as model_provider
,cast(get_json_object(data,'$.model_name') as string)                                                 as model_name
,cast(get_json_object(data,'$.model_version') as string)                                              as model_version
,cast(get_json_object(data,'$.model_code') as bigint)                                                 as model_code
,cast(get_json_object(data,'$.notify_result') as string)                                              as notify_result
,cast(get_json_object(data,'$.notify_time') as bigint)                                                as notify_time
,cast(get_json_object(data,'$.query_result') as string)                                               as query_result
,cast(get_json_object(data,'$.query_time') as bigint)                                                 as query_time
,cast(get_json_object(data,'$.query_count') as bigint)                                                as query_count
,cast(get_json_object(data,'$.version') as bigint)                                                    as version
,cast(get_json_object(data,'$.remark') as string)                                                     as remark
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.processor_name') as string)                                             as processor_name
,cast(get_json_object(data,'$.model_run_status') as bigint)                                           as model_run_status
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_control_id_cf_db' and base_table= 'model_req_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_control_id_cf_db__model_req_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,flow_no                                                                                              as flow_no
,req_no                                                                                               as req_no
,model_status                                                                                         as model_status
,model_input                                                                                          as model_input
,model_result                                                                                         as model_result
,model_provider                                                                                       as model_provider
,model_name                                                                                           as model_name
,model_version                                                                                        as model_version
,model_code                                                                                           as model_code
,notify_result                                                                                        as notify_result
,notify_time                                                                                          as notify_time
,query_result                                                                                         as query_result
,query_time                                                                                           as query_time
,query_count                                                                                          as query_count
,version                                                                                              as version
,remark                                                                                               as remark
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,processor_name                                                                                       as processor_name
,model_run_status                                                                                     as model_run_status
 
 ,_event
 ;