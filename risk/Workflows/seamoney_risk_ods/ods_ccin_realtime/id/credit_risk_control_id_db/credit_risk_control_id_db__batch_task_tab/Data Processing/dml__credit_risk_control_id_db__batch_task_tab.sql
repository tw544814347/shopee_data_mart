

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 task_id                                                                                              as task_id
,filename                                                                                             as filename
,status                                                                                               as status
,version                                                                                              as version
,number_of_rows                                                                                       as number_of_rows
,number_of_failures                                                                                   as number_of_failures
,upload_time                                                                                          as upload_time
,finish_time                                                                                          as finish_time
,operator                                                                                             as operator
,fail_filename                                                                                        as fail_filename
,task_name                                                                                            as task_name
,task_type                                                                                            as task_type
,task_policy                                                                                          as task_policy
,task_extension                                                                                       as task_extension
,description                                                                                          as description
,update_time                                                                                          as update_time
,full_report                                                                                          as full_report
,failed_report                                                                                        as failed_report
,check_failed_report                                                                                  as check_failed_report
,api_type                                                                                             as api_type
,call_asli_status                                                                                     as call_asli_status
,upload_status                                                                                        as upload_status
,pfb_version                                                                                          as pfb_version
,screening_time                                                                                       as screening_time
,screening_type                                                                                       as screening_type
,notes                                                                                                as notes
,file_type                                                                                            as file_type
 
,_event
 from(
    select 
 task_id                                                                                              as task_id
,filename                                                                                             as filename
,status                                                                                               as status
,version                                                                                              as version
,number_of_rows                                                                                       as number_of_rows
,number_of_failures                                                                                   as number_of_failures
,upload_time                                                                                          as upload_time
,finish_time                                                                                          as finish_time
,operator                                                                                             as operator
,fail_filename                                                                                        as fail_filename
,task_name                                                                                            as task_name
,task_type                                                                                            as task_type
,task_policy                                                                                          as task_policy
,task_extension                                                                                       as task_extension
,description                                                                                          as description
,update_time                                                                                          as update_time
,full_report                                                                                          as full_report
,failed_report                                                                                        as failed_report
,check_failed_report                                                                                  as check_failed_report
,api_type                                                                                             as api_type
,call_asli_status                                                                                     as call_asli_status
,upload_status                                                                                        as upload_status
,pfb_version                                                                                          as pfb_version
,screening_time                                                                                       as screening_time
,screening_type                                                                                       as screening_type
,notes                                                                                                as notes
,file_type                                                                                            as file_type
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 task_id                                                                                              as task_id
,filename                                                                                             as filename
,status                                                                                               as status
,version                                                                                              as version
,number_of_rows                                                                                       as number_of_rows
,number_of_failures                                                                                   as number_of_failures
,upload_time                                                                                          as upload_time
,finish_time                                                                                          as finish_time
,operator                                                                                             as operator
,fail_filename                                                                                        as fail_filename
,task_name                                                                                            as task_name
,task_type                                                                                            as task_type
,task_policy                                                                                          as task_policy
,task_extension                                                                                       as task_extension
,description                                                                                          as description
,update_time                                                                                          as update_time
,full_report                                                                                          as full_report
,failed_report                                                                                        as failed_report
,check_failed_report                                                                                  as check_failed_report
,api_type                                                                                             as api_type
,call_asli_status                                                                                     as call_asli_status
,upload_status                                                                                        as upload_status
,pfb_version                                                                                          as pfb_version
,screening_time                                                                                       as screening_time
,screening_type                                                                                       as screening_type
,notes                                                                                                as notes
,file_type                                                                                            as file_type
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),task_id)       as on_keys_conds
,_event
        from risk.ods__credit_risk_control_id_db__batch_task_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.task_id') as bigint)                                                    as task_id
,cast(get_json_object(data,'$.filename') as string)                                                   as filename
,cast(get_json_object(data,'$.status') as bigint)                                                     as status
,cast(get_json_object(data,'$.version') as bigint)                                                    as version
,cast(get_json_object(data,'$.number_of_rows') as bigint)                                             as number_of_rows
,cast(get_json_object(data,'$.number_of_failures') as bigint)                                         as number_of_failures
,cast(get_json_object(data,'$.upload_time') as bigint)                                                as upload_time
,cast(get_json_object(data,'$.finish_time') as bigint)                                                as finish_time
,cast(get_json_object(data,'$.operator') as string)                                                   as operator
,cast(get_json_object(data,'$.fail_filename') as string)                                              as fail_filename
,cast(get_json_object(data,'$.task_name') as string)                                                  as task_name
,cast(get_json_object(data,'$.task_type') as bigint)                                                  as task_type
,cast(get_json_object(data,'$.task_policy') as bigint)                                                as task_policy
,cast(get_json_object(data,'$.task_extension') as string)                                             as task_extension
,cast(get_json_object(data,'$.description') as string)                                                as description
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.full_report') as string)                                                as full_report
,cast(get_json_object(data,'$.failed_report') as string)                                              as failed_report
,cast(get_json_object(data,'$.check_failed_report') as string)                                        as check_failed_report
,cast(get_json_object(data,'$.api_type') as bigint)                                                   as api_type
,cast(get_json_object(data,'$.call_asli_status') as bigint)                                           as call_asli_status
,cast(get_json_object(data,'$.upload_status') as bigint)                                              as upload_status
,cast(get_json_object(data,'$.pfb_version') as string)                                                as pfb_version
,cast(get_json_object(data,'$.screening_time') as bigint)                                             as screening_time
,cast(get_json_object(data,'$.screening_type') as bigint)                                             as screening_type
,cast(get_json_object(data,'$.notes') as string)                                                      as notes
,cast(get_json_object(data,'$.file_type') as bigint)                                                  as file_type
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.task_id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_control_id_db' and base_table= 'batch_task_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete' 
)
insert overwrite table risk.ods__credit_risk_control_id_db__batch_task_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 task_id                                                                                              as task_id
,filename                                                                                             as filename
,status                                                                                               as status
,version                                                                                              as version
,number_of_rows                                                                                       as number_of_rows
,number_of_failures                                                                                   as number_of_failures
,upload_time                                                                                          as upload_time
,finish_time                                                                                          as finish_time
,operator                                                                                             as operator
,fail_filename                                                                                        as fail_filename
,task_name                                                                                            as task_name
,task_type                                                                                            as task_type
,task_policy                                                                                          as task_policy
,task_extension                                                                                       as task_extension
,description                                                                                          as description
,update_time                                                                                          as update_time
,full_report                                                                                          as full_report
,failed_report                                                                                        as failed_report
,check_failed_report                                                                                  as check_failed_report
,api_type                                                                                             as api_type
,call_asli_status                                                                                     as call_asli_status
,upload_status                                                                                        as upload_status
,pfb_version                                                                                          as pfb_version
,screening_time                                                                                       as screening_time
,screening_type                                                                                       as screening_type
,notes                                                                                                as notes
,file_type                                                                                            as file_type
 
 ,_event
 ;