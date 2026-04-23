

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,region                                                                                               as region
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,policy_name                                                                                          as policy_name
,policy_version                                                                                       as policy_version
,policy_file                                                                                          as policy_file
,policy_file_fingerprint                                                                              as policy_file_fingerprint
,policy_status                                                                                        as policy_status
,policy_info                                                                                          as policy_info
,policy_schema                                                                                        as policy_schema
,description                                                                                          as description
,create_user                                                                                          as create_user
,create_time                                                                                          as create_time
,update_user                                                                                          as update_user
,update_time                                                                                          as update_time
,file_id                                                                                              as file_id
 
,_event
 from(
    select 
 id                                                                                                   as id
,region                                                                                               as region
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,policy_name                                                                                          as policy_name
,policy_version                                                                                       as policy_version
,policy_file                                                                                          as policy_file
,policy_file_fingerprint                                                                              as policy_file_fingerprint
,policy_status                                                                                        as policy_status
,policy_info                                                                                          as policy_info
,policy_schema                                                                                        as policy_schema
,description                                                                                          as description
,create_user                                                                                          as create_user
,create_time                                                                                          as create_time
,update_user                                                                                          as update_user
,update_time                                                                                          as update_time
,file_id                                                                                              as file_id
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,region                                                                                               as region
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,policy_name                                                                                          as policy_name
,policy_version                                                                                       as policy_version
,policy_file                                                                                          as policy_file
,policy_file_fingerprint                                                                              as policy_file_fingerprint
,policy_status                                                                                        as policy_status
,policy_info                                                                                          as policy_info
,policy_schema                                                                                        as policy_schema
,description                                                                                          as description
,create_user                                                                                          as create_user
,create_time                                                                                          as create_time
,update_user                                                                                          as update_user
,update_time                                                                                          as update_time
,file_id                                                                                              as file_id
 
 ,concat_ws('_',nvl(policy_name,''))                                                                   as on_keys_conds
,_event
        from risk.ods__credit_risk_control_id_db__policy_file_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id
,cast(get_json_object(data,'$.region') as string)                                                     as region
,cast(get_json_object(data,'$.app_id') as string)                                                     as app_id
,cast(get_json_object(data,'$.scene_id') as bigint)                                                   as scene_id
,cast(get_json_object(data,'$.policy_name') as string)                                                as policy_name
,cast(get_json_object(data,'$.policy_version') as bigint)                                             as policy_version
,cast(get_json_object(data,'$.policy_file') as string)                                                as policy_file
,cast(get_json_object(data,'$.policy_file_fingerprint') as string)                                    as policy_file_fingerprint
,cast(get_json_object(data,'$.policy_status') as bigint)                                              as policy_status
,cast(get_json_object(data,'$.policy_info') as string)                                                as policy_info
,cast(get_json_object(data,'$.policy_schema') as string)                                              as policy_schema
,cast(get_json_object(data,'$.description') as string)                                                as description
,cast(get_json_object(data,'$.create_user') as string)                                                as create_user
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_user') as string)                                                as update_user
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.file_id') as string)                                                    as file_id
 
 ,concat_ws('_',nvl(get_json_object(data,'$.policy_name'),''))                                         as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_control_id_db' and base_table= 'policy_file_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_control_id_db__policy_file_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,region                                                                                               as region
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,policy_name                                                                                          as policy_name
,policy_version                                                                                       as policy_version
,policy_file                                                                                          as policy_file
,policy_file_fingerprint                                                                              as policy_file_fingerprint
,policy_status                                                                                        as policy_status
,policy_info                                                                                          as policy_info
,policy_schema                                                                                        as policy_schema
,description                                                                                          as description
,create_user                                                                                          as create_user
,create_time                                                                                          as create_time
,update_user                                                                                          as update_user
,update_time                                                                                          as update_time
,file_id                                                                                              as file_id
 
 ,_event
 ;