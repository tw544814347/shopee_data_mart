

refresh table risk.ccin_multi_realtime_binlog_for_id;

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
,request_header_encrypt                                                                               as request_header_encrypt
,request_body_encrypt                                                                                 as request_body_encrypt
,response_body_encrypt                                                                                as response_body_encrypt
,archive_batch_no                                                                                     as archive_batch_no
 
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
,request_header_encrypt                                                                               as request_header_encrypt
,request_body_encrypt                                                                                 as request_body_encrypt
,response_body_encrypt                                                                                as response_body_encrypt
,archive_batch_no                                                                                     as archive_batch_no
 
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
,request_header_encrypt                                                                               as request_header_encrypt
,request_body_encrypt                                                                                 as request_body_encrypt
,response_body_encrypt                                                                                as response_body_encrypt
,archive_batch_no                                                                                     as archive_batch_no
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_datafetch_id_db__archive_live_testing_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id
,cast(get_json_object(data,'$.data_source_name') as string)                                           as data_source_name
,cast(get_json_object(data,'$.url') as string)                                                        as url
,cast(get_json_object(data,'$.request_method') as string)                                             as request_method
,cast(get_json_object(data,'$.request_header') as string)                                             as request_header
,cast(get_json_object(data,'$.request_body') as string)                                               as request_body
,cast(get_json_object(data,'$.response_body') as string)                                              as response_body
,cast(get_json_object(data,'$.response_code') as bigint)                                              as response_code
,cast(get_json_object(data,'$.time_cost_ms') as decimal(20,0))                                        as time_cost_ms
,cast(get_json_object(data,'$.error_info') as string)                                                 as error_info
,cast(get_json_object(data,'$.trace_id') as string)                                                   as trace_id
,cast(get_json_object(data,'$.request_key') as string)                                                as request_key
,cast(get_json_object(data,'$.create_time') as string)                                                as create_time
,cast(get_json_object(data,'$.update_time') as string)                                                as update_time
,cast(get_json_object(data,'$.request_header_encrypt') as string)                                     as request_header_encrypt
,cast(get_json_object(data,'$.request_body_encrypt') as string)                                       as request_body_encrypt
,cast(get_json_object(data,'$.response_body_encrypt') as string)                                      as response_body_encrypt
,cast(get_json_object(data,'$.archive_batch_no') as string)                                           as archive_batch_no
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_datafetch_id_db' and base_table= 'archive_live_testing_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(unix_timestamp(get_json_object(data,'$.update_time')) + 28800 - 3600 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and (nvl(get_json_object(_event,'$.type'),'') != 'delete' 
or (nvl(get_json_object(_event,'$.type'),'') = 'delete' and archive_batch_no is not null and archive_batch_no !='') 
) 
)
insert overwrite table risk.ods__credit_risk_datafetch_id_db__archive_live_testing_tab__df__private partition(grass_date ='${ods_date_t1}')
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
,request_header_encrypt                                                                               as request_header_encrypt
,request_body_encrypt                                                                                 as request_body_encrypt
,response_body_encrypt                                                                                as response_body_encrypt
,archive_batch_no                                                                                     as archive_batch_no
 
 ,_event
 ;