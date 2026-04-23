

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,event_code                                                                                           as event_code
,feature_name                                                                                         as feature_name
,status                                                                                               as status
,review_status                                                                                        as review_status
,operator                                                                                             as operator
,path                                                                                                 as path
,op_version                                                                                           as op_version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,grey_path                                                                                            as grey_path
,grey_status                                                                                          as grey_status
,source_scenes                                                                                        as source_scenes
,fillinfo                                                                                             as fillinfo
,source_type                                                                                          as source_type
 
,_event
 from(
    select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,event_code                                                                                           as event_code
,feature_name                                                                                         as feature_name
,status                                                                                               as status
,review_status                                                                                        as review_status
,operator                                                                                             as operator
,path                                                                                                 as path
,op_version                                                                                           as op_version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,grey_path                                                                                            as grey_path
,grey_status                                                                                          as grey_status
,source_scenes                                                                                        as source_scenes
,fillinfo                                                                                             as fillinfo
,source_type                                                                                          as source_type
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,event_code                                                                                           as event_code
,feature_name                                                                                         as feature_name
,status                                                                                               as status
,review_status                                                                                        as review_status
,operator                                                                                             as operator
,path                                                                                                 as path
,op_version                                                                                           as op_version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,grey_path                                                                                            as grey_path
,grey_status                                                                                          as grey_status
,source_scenes                                                                                        as source_scenes
,fillinfo                                                                                             as fillinfo
,source_type                                                                                          as source_type
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_id_db__risk_event_feature_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.app_id') as string)                                                     as app_id
,cast(get_json_object(data,'$.scene_id') as string)                                                   as scene_id
,cast(get_json_object(data,'$.event_code') as string)                                                 as event_code
,cast(get_json_object(data,'$.feature_name') as string)                                               as feature_name
,cast(get_json_object(data,'$.status') as bigint)                                                     as status
,cast(get_json_object(data,'$.review_status') as bigint)                                              as review_status
,cast(get_json_object(data,'$.operator') as string)                                                   as operator
,cast(get_json_object(data,'$.path') as string)                                                       as path
,cast(get_json_object(data,'$.op_version') as bigint)                                                 as op_version
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.grey_path') as string)                                                  as grey_path
,cast(get_json_object(data,'$.grey_status') as bigint)                                                as grey_status
,cast(get_json_object(data,'$.source_scenes') as string)                                              as source_scenes
,cast(get_json_object(data,'$.fillinfo') as string)                                                   as fillinfo
,cast(get_json_object(data,'$.source_type') as bigint)                                                as source_type
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_control_id_db' and base_table= 'risk_event_feature_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete' 
)
insert overwrite table risk.ods__credit_risk_control_id_db__risk_event_feature_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,event_code                                                                                           as event_code
,feature_name                                                                                         as feature_name
,status                                                                                               as status
,review_status                                                                                        as review_status
,operator                                                                                             as operator
,path                                                                                                 as path
,op_version                                                                                           as op_version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,grey_path                                                                                            as grey_path
,grey_status                                                                                          as grey_status
,source_scenes                                                                                        as source_scenes
,fillinfo                                                                                             as fillinfo
,source_type                                                                                          as source_type
 
 ,_event
 ;