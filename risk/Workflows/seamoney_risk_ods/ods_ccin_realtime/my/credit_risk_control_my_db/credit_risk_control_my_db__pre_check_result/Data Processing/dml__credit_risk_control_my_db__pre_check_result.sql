

refresh table risk.ccin_multi_realtime_binlog_for_my;

from (
    select 
 id                                                                                                   as id
,task_id                                                                                              as task_id
,template_type                                                                                        as template_type
,total_rows                                                                                           as total_rows
,number_of_failures                                                                                   as number_of_failures
,custom_header_data                                                                                   as custom_header_data
,custom_body_data                                                                                     as custom_body_data
,inconsistent_filename                                                                                as inconsistent_filename
,fail_filename                                                                                        as fail_filename
,status                                                                                               as status
,operator                                                                                             as operator
,description                                                                                          as description
,update_time                                                                                          as update_time
,create_time                                                                                          as create_time
,notes                                                                                                as notes
 
,_event
 from(
    select 
 id                                                                                                   as id
,task_id                                                                                              as task_id
,template_type                                                                                        as template_type
,total_rows                                                                                           as total_rows
,number_of_failures                                                                                   as number_of_failures
,custom_header_data                                                                                   as custom_header_data
,custom_body_data                                                                                     as custom_body_data
,inconsistent_filename                                                                                as inconsistent_filename
,fail_filename                                                                                        as fail_filename
,status                                                                                               as status
,operator                                                                                             as operator
,description                                                                                          as description
,update_time                                                                                          as update_time
,create_time                                                                                          as create_time
,notes                                                                                                as notes
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,task_id                                                                                              as task_id
,template_type                                                                                        as template_type
,total_rows                                                                                           as total_rows
,number_of_failures                                                                                   as number_of_failures
,custom_header_data                                                                                   as custom_header_data
,custom_body_data                                                                                     as custom_body_data
,inconsistent_filename                                                                                as inconsistent_filename
,fail_filename                                                                                        as fail_filename
,status                                                                                               as status
,operator                                                                                             as operator
,description                                                                                          as description
,update_time                                                                                          as update_time
,create_time                                                                                          as create_time
,notes                                                                                                as notes
 
 ,concat_ws('_',nvl(task_id,''))                                                                       as on_keys_conds
,_event
        from risk.ods__credit_risk_control_my_db__pre_check_result__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.task_id') as bigint)                                                    as task_id
,cast(get_json_object(data,'$.template_type') as bigint)                                              as template_type
,cast(get_json_object(data,'$.total_rows') as bigint)                                                 as total_rows
,cast(get_json_object(data,'$.number_of_failures') as bigint)                                         as number_of_failures
,cast(get_json_object(data,'$.custom_header_data') as string)                                         as custom_header_data
,cast(get_json_object(data,'$.custom_body_data') as string)                                           as custom_body_data
,cast(get_json_object(data,'$.inconsistent_filename') as string)                                      as inconsistent_filename
,cast(get_json_object(data,'$.fail_filename') as string)                                              as fail_filename
,cast(get_json_object(data,'$.status') as bigint)                                                     as status
,cast(get_json_object(data,'$.operator') as string)                                                   as operator
,cast(get_json_object(data,'$.description') as string)                                                as description
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.notes') as string)                                                      as notes
 
 ,concat_ws('_',nvl(get_json_object(data,'$.task_id'),''))                                             as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_my 
        where base_database = 'credit_risk_control_my_db' and base_table= 'pre_check_result'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 0 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_control_my_db__pre_check_result__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,task_id                                                                                              as task_id
,template_type                                                                                        as template_type
,total_rows                                                                                           as total_rows
,number_of_failures                                                                                   as number_of_failures
,custom_header_data                                                                                   as custom_header_data
,custom_body_data                                                                                     as custom_body_data
,inconsistent_filename                                                                                as inconsistent_filename
,fail_filename                                                                                        as fail_filename
,status                                                                                               as status
,operator                                                                                             as operator
,description                                                                                          as description
,update_time                                                                                          as update_time
,create_time                                                                                          as create_time
,notes                                                                                                as notes
 
 ,_event
 ;