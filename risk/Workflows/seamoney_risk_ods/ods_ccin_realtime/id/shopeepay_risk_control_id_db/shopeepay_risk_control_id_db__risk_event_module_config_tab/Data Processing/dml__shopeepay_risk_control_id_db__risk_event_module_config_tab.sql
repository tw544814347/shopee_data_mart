

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,event_code                                                                                           as event_code
,config                                                                                               as config
,module_type                                                                                          as module_type
,grey_config                                                                                          as grey_config
,grey_percentage                                                                                      as grey_percentage
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,operator                                                                                             as operator
 
,_event
 from(
    select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,event_code                                                                                           as event_code
,config                                                                                               as config
,module_type                                                                                          as module_type
,grey_config                                                                                          as grey_config
,grey_percentage                                                                                      as grey_percentage
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,operator                                                                                             as operator
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,event_code                                                                                           as event_code
,config                                                                                               as config
,module_type                                                                                          as module_type
,grey_config                                                                                          as grey_config
,grey_percentage                                                                                      as grey_percentage
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,operator                                                                                             as operator
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__shopeepay_risk_control_id_db__risk_event_module_config_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.app_id') as string)                                                     as app_id
,cast(get_json_object(data,'$.scene_id') as string)                                                   as scene_id
,cast(get_json_object(data,'$.event_code') as string)                                                 as event_code
,cast(get_json_object(data,'$.config') as string)                                                     as config
,cast(get_json_object(data,'$.module_type') as string)                                                as module_type
,cast(get_json_object(data,'$.grey_config') as string)                                                as grey_config
,cast(get_json_object(data,'$.grey_percentage') as bigint)                                            as grey_percentage
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.operator') as string)                                                   as operator
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'shopeepay_risk_control_id_db' and base_table= 'risk_event_module_config_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__shopeepay_risk_control_id_db__risk_event_module_config_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,event_code                                                                                           as event_code
,config                                                                                               as config
,module_type                                                                                          as module_type
,grey_config                                                                                          as grey_config
,grey_percentage                                                                                      as grey_percentage
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,operator                                                                                             as operator
 
 ,_event
 ;