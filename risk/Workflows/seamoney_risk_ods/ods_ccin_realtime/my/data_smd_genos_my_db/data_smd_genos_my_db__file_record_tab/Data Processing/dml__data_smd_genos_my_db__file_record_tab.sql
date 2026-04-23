

refresh table risk.ccin_multi_realtime_binlog_for_my;

from (
    select 
 id                                                                                                   as id
,ex_id                                                                                                as ex_id
,request_id                                                                                           as request_id
,app_id                                                                                               as app_id
,file_type                                                                                            as file_type
,path                                                                                                 as path
,upload_path                                                                                          as upload_path
,raw_output                                                                                           as raw_output
,status                                                                                               as status
,msg                                                                                                  as msg
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
,_event
 from(
    select 
 id                                                                                                   as id
,ex_id                                                                                                as ex_id
,request_id                                                                                           as request_id
,app_id                                                                                               as app_id
,file_type                                                                                            as file_type
,path                                                                                                 as path
,upload_path                                                                                          as upload_path
,raw_output                                                                                           as raw_output
,status                                                                                               as status
,msg                                                                                                  as msg
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,ex_id                                                                                                as ex_id
,request_id                                                                                           as request_id
,app_id                                                                                               as app_id
,file_type                                                                                            as file_type
,path                                                                                                 as path
,upload_path                                                                                          as upload_path
,raw_output                                                                                           as raw_output
,status                                                                                               as status
,msg                                                                                                  as msg
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__data_smd_genos_my_db__file_record_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id
,cast(get_json_object(data,'$.ex_id') as string)                                                      as ex_id
,cast(get_json_object(data,'$.request_id') as string)                                                 as request_id
,cast(get_json_object(data,'$.app_id') as string)                                                     as app_id
,cast(get_json_object(data,'$.file_type') as bigint)                                                  as file_type
,cast(get_json_object(data,'$.path') as string)                                                       as path
,cast(get_json_object(data,'$.upload_path') as string)                                                as upload_path
,cast(get_json_object(data,'$.raw_output') as string)                                                 as raw_output
,cast(get_json_object(data,'$.status') as bigint)                                                     as status
,cast(get_json_object(data,'$.msg') as string)                                                        as msg
,cast(get_json_object(data,'$.create_time') as string)                                                as create_time
,cast(get_json_object(data,'$.update_time') as string)                                                as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_my 
        where base_database = 'data_smd_genos_my_db' and base_table= 'file_record_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(unix_timestamp(get_json_object(data,'$.update_time')) + 28800 - 0 -8*3600,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__data_smd_genos_my_db__file_record_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,ex_id                                                                                                as ex_id
,request_id                                                                                           as request_id
,app_id                                                                                               as app_id
,file_type                                                                                            as file_type
,path                                                                                                 as path
,upload_path                                                                                          as upload_path
,raw_output                                                                                           as raw_output
,status                                                                                               as status
,msg                                                                                                  as msg
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,_event
 ;