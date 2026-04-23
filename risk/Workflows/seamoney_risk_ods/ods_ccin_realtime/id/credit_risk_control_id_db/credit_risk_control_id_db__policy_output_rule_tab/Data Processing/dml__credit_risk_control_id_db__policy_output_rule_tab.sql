

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,rule_version                                                                                         as rule_version
,version_status                                                                                       as version_status
,rule_config                                                                                          as rule_config
,runtime_script                                                                                       as runtime_script
,create_user                                                                                          as create_user
,create_time                                                                                          as create_time
,update_user                                                                                          as update_user
,update_time                                                                                          as update_time
 
,_event
 from(
    select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,rule_version                                                                                         as rule_version
,version_status                                                                                       as version_status
,rule_config                                                                                          as rule_config
,runtime_script                                                                                       as runtime_script
,create_user                                                                                          as create_user
,create_time                                                                                          as create_time
,update_user                                                                                          as update_user
,update_time                                                                                          as update_time
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,rule_version                                                                                         as rule_version
,version_status                                                                                       as version_status
,rule_config                                                                                          as rule_config
,runtime_script                                                                                       as runtime_script
,create_user                                                                                          as create_user
,create_time                                                                                          as create_time
,update_user                                                                                          as update_user
,update_time                                                                                          as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_id_db__policy_output_rule_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id
,cast(get_json_object(data,'$.app_id') as string)                                                     as app_id
,cast(get_json_object(data,'$.scene_id') as bigint)                                                   as scene_id
,cast(get_json_object(data,'$.rule_version') as bigint)                                               as rule_version
,cast(get_json_object(data,'$.version_status') as bigint)                                             as version_status
,cast(get_json_object(data,'$.rule_config') as string)                                                as rule_config
,cast(get_json_object(data,'$.runtime_script') as string)                                             as runtime_script
,cast(get_json_object(data,'$.create_user') as string)                                                as create_user
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_user') as string)                                                as update_user
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_control_id_db' and base_table= 'policy_output_rule_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete' 
)
insert overwrite table risk.ods__credit_risk_control_id_db__policy_output_rule_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,rule_version                                                                                         as rule_version
,version_status                                                                                       as version_status
,rule_config                                                                                          as rule_config
,runtime_script                                                                                       as runtime_script
,create_user                                                                                          as create_user
,create_time                                                                                          as create_time
,update_user                                                                                          as update_user
,update_time                                                                                          as update_time
 
 ,_event
 ;