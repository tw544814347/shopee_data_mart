

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,task_id                                                                                              as task_id
,company_name                                                                                         as company_name
,company_type                                                                                         as company_type
,service_name_list                                                                                    as service_name_list
,remark                                                                                               as remark
,operator                                                                                             as operator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,finish_time                                                                                          as finish_time
,task_status                                                                                          as task_status
,hash_method                                                                                          as hash_method
,hash_key                                                                                             as hash_key
,result_file                                                                                          as result_file
,retry_count                                                                                          as retry_count
,failed_reason                                                                                        as failed_reason
 
,_event
 from(
    select 
 id                                                                                                   as id
,task_id                                                                                              as task_id
,company_name                                                                                         as company_name
,company_type                                                                                         as company_type
,service_name_list                                                                                    as service_name_list
,remark                                                                                               as remark
,operator                                                                                             as operator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,finish_time                                                                                          as finish_time
,task_status                                                                                          as task_status
,hash_method                                                                                          as hash_method
,hash_key                                                                                             as hash_key
,result_file                                                                                          as result_file
,retry_count                                                                                          as retry_count
,failed_reason                                                                                        as failed_reason
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,task_id                                                                                              as task_id
,company_name                                                                                         as company_name
,company_type                                                                                         as company_type
,service_name_list                                                                                    as service_name_list
,remark                                                                                               as remark
,operator                                                                                             as operator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,finish_time                                                                                          as finish_time
,task_status                                                                                          as task_status
,hash_method                                                                                          as hash_method
,hash_key                                                                                             as hash_key
,result_file                                                                                          as result_file
,retry_count                                                                                          as retry_count
,failed_reason                                                                                        as failed_reason
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_open_platform_id_db__auto_backtesting_task_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.task_id') as string)                                                    as task_id
,cast(get_json_object(data,'$.company_name') as string)                                               as company_name
,cast(get_json_object(data,'$.company_type') as bigint)                                               as company_type
,cast(get_json_object(data,'$.service_name_list') as string)                                          as service_name_list
,cast(get_json_object(data,'$.remark') as string)                                                     as remark
,cast(get_json_object(data,'$.operator') as string)                                                   as operator
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.finish_time') as bigint)                                                as finish_time
,cast(get_json_object(data,'$.task_status') as bigint)                                                as task_status
,cast(get_json_object(data,'$.hash_method') as string)                                                as hash_method
,cast(get_json_object(data,'$.hash_key') as string)                                                   as hash_key
,cast(get_json_object(data,'$.result_file') as string)                                                as result_file
,cast(get_json_object(data,'$.retry_count') as bigint)                                                as retry_count
,cast(get_json_object(data,'$.failed_reason') as string)                                              as failed_reason
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_open_platform_id_db' and base_table= 'auto_backtesting_task_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time')/1000 - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_open_platform_id_db__auto_backtesting_task_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,task_id                                                                                              as task_id
,company_name                                                                                         as company_name
,company_type                                                                                         as company_type
,service_name_list                                                                                    as service_name_list
,remark                                                                                               as remark
,operator                                                                                             as operator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,finish_time                                                                                          as finish_time
,task_status                                                                                          as task_status
,hash_method                                                                                          as hash_method
,hash_key                                                                                             as hash_key
,result_file                                                                                          as result_file
,retry_count                                                                                          as retry_count
,failed_reason                                                                                        as failed_reason
 
 ,_event
 ;