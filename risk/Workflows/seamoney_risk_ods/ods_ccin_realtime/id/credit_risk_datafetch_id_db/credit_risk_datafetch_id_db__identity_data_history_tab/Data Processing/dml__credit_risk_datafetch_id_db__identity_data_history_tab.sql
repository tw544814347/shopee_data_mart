

refresh table risk.ccin_multi_realtime_binlog_for_id_encrypt;

from (
    select 
 id                                                                                                   as id
,request_key                                                                                          as request_key
,data_source_name                                                                                     as data_source_name
,data_source_code                                                                                     as data_source_code
,header_data                                                                                          as header_data
,req_data                                                                                             as req_data
,extra_info                                                                                           as extra_info
,resp_raw_data                                                                                        as resp_raw_data
,trace_id                                                                                             as trace_id
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,resp_raw_data_encrypt                                                                                as resp_raw_data_encrypt
,req_data_encrypt                                                                                     as req_data_encrypt
,archive_batch_no                                                                                     as archive_batch_no
 ,resp_raw_data_encrypt_data                                                                           as resp_raw_data_encrypt_data
,''                                                                                                   as resp_raw_data_encrypt_md5
,''                                                                                                   as resp_raw_data_encrypt_mask
,req_data_encrypt_data                                                                                as req_data_encrypt_data
,''                                                                                                   as req_data_encrypt_md5
,''                                                                                                   as req_data_encrypt_mask
,_event
 from(
    select 
 id                                                                                                   as id
,request_key                                                                                          as request_key
,data_source_name                                                                                     as data_source_name
,data_source_code                                                                                     as data_source_code
,header_data                                                                                          as header_data
,req_data                                                                                             as req_data
,extra_info                                                                                           as extra_info
,resp_raw_data                                                                                        as resp_raw_data
,trace_id                                                                                             as trace_id
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,resp_raw_data_encrypt                                                                                as resp_raw_data_encrypt
,req_data_encrypt                                                                                     as req_data_encrypt
,archive_batch_no                                                                                     as archive_batch_no
 ,resp_raw_data_encrypt_data                                                                           as resp_raw_data_encrypt_data
,''                                                                                                   as resp_raw_data_encrypt_md5
,''                                                                                                   as resp_raw_data_encrypt_mask
,req_data_encrypt_data                                                                                as req_data_encrypt_data
,''                                                                                                   as req_data_encrypt_md5
,''                                                                                                   as req_data_encrypt_mask
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,request_key                                                                                          as request_key
,data_source_name                                                                                     as data_source_name
,data_source_code                                                                                     as data_source_code
,header_data                                                                                          as header_data
,req_data                                                                                             as req_data
,extra_info                                                                                           as extra_info
,resp_raw_data                                                                                        as resp_raw_data
,trace_id                                                                                             as trace_id
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,resp_raw_data_encrypt                                                                                as resp_raw_data_encrypt
,req_data_encrypt                                                                                     as req_data_encrypt
,archive_batch_no                                                                                     as archive_batch_no
 ,resp_raw_data_encrypt_data                                                                           as resp_raw_data_encrypt_data
,''                                                                                                   as resp_raw_data_encrypt_md5
,''                                                                                                   as resp_raw_data_encrypt_mask
,req_data_encrypt_data                                                                                as req_data_encrypt_data
,''                                                                                                   as req_data_encrypt_md5
,''                                                                                                   as req_data_encrypt_mask
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_datafetch_id_db__identity_data_history_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id
,cast(get_json_object(data,'$.request_key') as string)                                                as request_key
,cast(get_json_object(data,'$.data_source_name') as string)                                           as data_source_name
,cast(get_json_object(data,'$.data_source_code') as bigint)                                           as data_source_code
,cast(get_json_object(data,'$.header_data') as string)                                                as header_data
,cast(get_json_object(data,'$.req_data') as string)                                                   as req_data
,cast(get_json_object(data,'$.extra_info') as string)                                                 as extra_info
,cast(get_json_object(data,'$.resp_raw_data') as string)                                              as resp_raw_data
,cast(get_json_object(data,'$.trace_id') as string)                                                   as trace_id
,cast(get_json_object(data,'$.create_time') as string)                                                as create_time
,cast(get_json_object(data,'$.update_time') as string)                                                as update_time
,cast(get_json_object(data,'$.resp_raw_data_encrypt') as string)                                      as resp_raw_data_encrypt
,cast(get_json_object(data,'$.req_data_encrypt') as string)                                           as req_data_encrypt
,cast(get_json_object(data,'$.archive_batch_no') as string)                                           as archive_batch_no
 ,cast(get_json_object(data,'$.resp_raw_data_encrypt_data') as string)                                 as resp_raw_data_encrypt_data
,cast(get_json_object(data,'$.resp_raw_data_encrypt_md5') as string)                                  as resp_raw_data_encrypt_md5
,cast(get_json_object(data,'$.resp_raw_data_encrypt_mask') as string)                                 as resp_raw_data_encrypt_mask
,cast(get_json_object(data,'$.req_data_encrypt_data') as string)                                      as req_data_encrypt_data
,cast(get_json_object(data,'$.req_data_encrypt_md5') as string)                                       as req_data_encrypt_md5
,cast(get_json_object(data,'$.req_data_encrypt_mask') as string)                                      as req_data_encrypt_mask
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_id_encrypt 
        where base_database = 'credit_risk_datafetch_id_db' and base_table= 'identity_data_history_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(unix_timestamp(get_json_object(data,'$.update_time')) + 28800 - 3600 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and (nvl(get_json_object(_event,'$.type'),'') != 'delete' 
or (nvl(get_json_object(_event,'$.type'),'') = 'delete' and archive_batch_no is not null and archive_batch_no !='') 
) 
)
insert overwrite table risk.ods__credit_risk_datafetch_id_db__identity_data_history_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,request_key                                                                                          as request_key
,data_source_name                                                                                     as data_source_name
,data_source_code                                                                                     as data_source_code
,header_data                                                                                          as header_data
,req_data                                                                                             as req_data
,extra_info                                                                                           as extra_info
,resp_raw_data                                                                                        as resp_raw_data
,trace_id                                                                                             as trace_id
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,resp_raw_data_encrypt                                                                                as resp_raw_data_encrypt
,req_data_encrypt                                                                                     as req_data_encrypt
,archive_batch_no                                                                                     as archive_batch_no
 ,resp_raw_data_encrypt_data                                                                           as resp_raw_data_encrypt_data
,''                                                                                                   as resp_raw_data_encrypt_md5
,''                                                                                                   as resp_raw_data_encrypt_mask
,req_data_encrypt_data                                                                                as req_data_encrypt_data
,''                                                                                                   as req_data_encrypt_md5
,''                                                                                                   as req_data_encrypt_mask
 ,_event
 ;