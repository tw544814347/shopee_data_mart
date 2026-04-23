

refresh table risk.ccin_multi_realtime_binlog_for_my_encrypt;

from (
    select 
 id                                                                                                   as id
,data_source_name                                                                                     as data_source_name
,url                                                                                                  as url
,request_method                                                                                       as request_method
,request_header                                                                                       as request_header
,request_body                                                                                         as request_body
,response_body                                                                                        as response_body
,response_code                                                                                        as response_code
,time_cost_ms                                                                                         as time_cost_ms
,error_info                                                                                           as error_info
,trace_id                                                                                             as trace_id
,request_key                                                                                          as request_key
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,scene_id                                                                                             as scene_id
,flow_no                                                                                              as flow_no
,risk_req_no                                                                                          as risk_req_no
,app_id                                                                                               as app_id
,entity                                                                                               as entity
,call_scene                                                                                           as call_scene
,response_body_encrypt                                                                                as response_body_encrypt
,request_body_encrypt                                                                                 as request_body_encrypt
,request_header_encrypt                                                                               as request_header_encrypt
,archive_batch_no                                                                                     as archive_batch_no
 ,response_body_encrypt_data                                                                           as response_body_encrypt_data
,response_body_encrypt_md5                                                                            as response_body_encrypt_md5
,response_body_encrypt_mask                                                                           as response_body_encrypt_mask
,request_body_encrypt_data                                                                            as request_body_encrypt_data
,request_body_encrypt_md5                                                                             as request_body_encrypt_md5
,request_body_encrypt_mask                                                                            as request_body_encrypt_mask
,request_header_encrypt_data                                                                          as request_header_encrypt_data
,request_header_encrypt_md5                                                                           as request_header_encrypt_md5
,request_header_encrypt_mask                                                                          as request_header_encrypt_mask
,_event
 from(
    select 
 id                                                                                                   as id
,data_source_name                                                                                     as data_source_name
,url                                                                                                  as url
,request_method                                                                                       as request_method
,request_header                                                                                       as request_header
,request_body                                                                                         as request_body
,response_body                                                                                        as response_body
,response_code                                                                                        as response_code
,time_cost_ms                                                                                         as time_cost_ms
,error_info                                                                                           as error_info
,trace_id                                                                                             as trace_id
,request_key                                                                                          as request_key
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,scene_id                                                                                             as scene_id
,flow_no                                                                                              as flow_no
,risk_req_no                                                                                          as risk_req_no
,app_id                                                                                               as app_id
,entity                                                                                               as entity
,call_scene                                                                                           as call_scene
,response_body_encrypt                                                                                as response_body_encrypt
,request_body_encrypt                                                                                 as request_body_encrypt
,request_header_encrypt                                                                               as request_header_encrypt
,archive_batch_no                                                                                     as archive_batch_no
 ,response_body_encrypt_data                                                                           as response_body_encrypt_data
,response_body_encrypt_md5                                                                            as response_body_encrypt_md5
,response_body_encrypt_mask                                                                           as response_body_encrypt_mask
,request_body_encrypt_data                                                                            as request_body_encrypt_data
,request_body_encrypt_md5                                                                             as request_body_encrypt_md5
,request_body_encrypt_mask                                                                            as request_body_encrypt_mask
,request_header_encrypt_data                                                                          as request_header_encrypt_data
,request_header_encrypt_md5                                                                           as request_header_encrypt_md5
,request_header_encrypt_mask                                                                          as request_header_encrypt_mask
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,data_source_name                                                                                     as data_source_name
,url                                                                                                  as url
,request_method                                                                                       as request_method
,request_header                                                                                       as request_header
,request_body                                                                                         as request_body
,response_body                                                                                        as response_body
,response_code                                                                                        as response_code
,time_cost_ms                                                                                         as time_cost_ms
,error_info                                                                                           as error_info
,trace_id                                                                                             as trace_id
,request_key                                                                                          as request_key
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,scene_id                                                                                             as scene_id
,flow_no                                                                                              as flow_no
,risk_req_no                                                                                          as risk_req_no
,app_id                                                                                               as app_id
,entity                                                                                               as entity
,call_scene                                                                                           as call_scene
,response_body_encrypt                                                                                as response_body_encrypt
,request_body_encrypt                                                                                 as request_body_encrypt
,request_header_encrypt                                                                               as request_header_encrypt
,archive_batch_no                                                                                     as archive_batch_no
 ,response_body_encrypt_data                                                                           as response_body_encrypt_data
,response_body_encrypt_md5                                                                            as response_body_encrypt_md5
,response_body_encrypt_mask                                                                           as response_body_encrypt_mask
,request_body_encrypt_data                                                                            as request_body_encrypt_data
,request_body_encrypt_md5                                                                             as request_body_encrypt_md5
,request_body_encrypt_mask                                                                            as request_body_encrypt_mask
,request_header_encrypt_data                                                                          as request_header_encrypt_data
,request_header_encrypt_md5                                                                           as request_header_encrypt_md5
,request_header_encrypt_mask                                                                          as request_header_encrypt_mask
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_datafetch_my_db__data_source_api_request_log_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.data_source_name') as string)                                           as data_source_name
,cast(get_json_object(data,'$.url') as string)                                                        as url
,cast(get_json_object(data,'$.request_method') as string)                                             as request_method
,cast(get_json_object(data,'$.request_header') as string)                                             as request_header
,cast(get_json_object(data,'$.request_body') as string)                                               as request_body
,cast(get_json_object(data,'$.response_body') as string)                                              as response_body
,cast(get_json_object(data,'$.response_code') as bigint)                                              as response_code
,cast(get_json_object(data,'$.time_cost_ms') as bigint)                                               as time_cost_ms
,cast(get_json_object(data,'$.error_info') as string)                                                 as error_info
,cast(get_json_object(data,'$.trace_id') as string)                                                   as trace_id
,cast(get_json_object(data,'$.request_key') as string)                                                as request_key
,cast(get_json_object(data,'$.create_time') as string)                                                as create_time
,cast(get_json_object(data,'$.update_time') as string)                                                as update_time
,cast(get_json_object(data,'$.scene_id') as bigint)                                                   as scene_id
,cast(get_json_object(data,'$.flow_no') as string)                                                    as flow_no
,cast(get_json_object(data,'$.risk_req_no') as string)                                                as risk_req_no
,cast(get_json_object(data,'$.app_id') as string)                                                     as app_id
,cast(get_json_object(data,'$.entity') as string)                                                     as entity
,cast(get_json_object(data,'$.call_scene') as bigint)                                                 as call_scene
,cast(get_json_object(data,'$.response_body_encrypt') as string)                                      as response_body_encrypt
,cast(get_json_object(data,'$.request_body_encrypt') as string)                                       as request_body_encrypt
,cast(get_json_object(data,'$.request_header_encrypt') as string)                                     as request_header_encrypt
,cast(get_json_object(data,'$.archive_batch_no') as string)                                           as archive_batch_no
 ,cast(get_json_object(data,'$.response_body_encrypt_data') as string)                                 as response_body_encrypt_data
,cast(get_json_object(data,'$.response_body_encrypt_md5') as string)                                  as response_body_encrypt_md5
,cast(get_json_object(data,'$.response_body_encrypt_mask') as string)                                 as response_body_encrypt_mask
,cast(get_json_object(data,'$.request_body_encrypt_data') as string)                                  as request_body_encrypt_data
,cast(get_json_object(data,'$.request_body_encrypt_md5') as string)                                   as request_body_encrypt_md5
,cast(get_json_object(data,'$.request_body_encrypt_mask') as string)                                  as request_body_encrypt_mask
,cast(get_json_object(data,'$.request_header_encrypt_data') as string)                                as request_header_encrypt_data
,cast(get_json_object(data,'$.request_header_encrypt_md5') as string)                                 as request_header_encrypt_md5
,cast(get_json_object(data,'$.request_header_encrypt_mask') as string)                                as request_header_encrypt_mask
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_my_encrypt 
        where base_database = 'credit_risk_datafetch_my_db' and base_table= 'data_source_api_request_log_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(unix_timestamp(get_json_object(data,'$.update_time')) + 28800 - 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and 1=1 
)
insert overwrite table risk.ods__credit_risk_datafetch_my_db__data_source_api_request_log_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,data_source_name                                                                                     as data_source_name
,url                                                                                                  as url
,request_method                                                                                       as request_method
,request_header                                                                                       as request_header
,request_body                                                                                         as request_body
,response_body                                                                                        as response_body
,response_code                                                                                        as response_code
,time_cost_ms                                                                                         as time_cost_ms
,error_info                                                                                           as error_info
,trace_id                                                                                             as trace_id
,request_key                                                                                          as request_key
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,scene_id                                                                                             as scene_id
,flow_no                                                                                              as flow_no
,risk_req_no                                                                                          as risk_req_no
,app_id                                                                                               as app_id
,entity                                                                                               as entity
,call_scene                                                                                           as call_scene
,response_body_encrypt                                                                                as response_body_encrypt
,request_body_encrypt                                                                                 as request_body_encrypt
,request_header_encrypt                                                                               as request_header_encrypt
,archive_batch_no                                                                                     as archive_batch_no
 ,response_body_encrypt_data                                                                           as response_body_encrypt_data
,response_body_encrypt_md5                                                                            as response_body_encrypt_md5
,response_body_encrypt_mask                                                                           as response_body_encrypt_mask
,request_body_encrypt_data                                                                            as request_body_encrypt_data
,request_body_encrypt_md5                                                                             as request_body_encrypt_md5
,request_body_encrypt_mask                                                                            as request_body_encrypt_mask
,request_header_encrypt_data                                                                          as request_header_encrypt_data
,request_header_encrypt_md5                                                                           as request_header_encrypt_md5
,request_header_encrypt_mask                                                                          as request_header_encrypt_mask
 ,_event
 ;