

refresh table risk.ccin_multi_realtime_binlog_for_my;

from (
    select 
 scene_id                                                                                             as scene_id
,scene_name                                                                                           as scene_name
,rule_group_ids                                                                                       as rule_group_ids
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,is_disable                                                                                           as is_disable
 
,_event
 from(
    select 
 scene_id                                                                                             as scene_id
,scene_name                                                                                           as scene_name
,rule_group_ids                                                                                       as rule_group_ids
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,is_disable                                                                                           as is_disable
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 scene_id                                                                                             as scene_id
,scene_name                                                                                           as scene_name
,rule_group_ids                                                                                       as rule_group_ids
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,is_disable                                                                                           as is_disable
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),scene_id)      as on_keys_conds
,_event
        from risk.ods__credit_risk_control_my_db__scene_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.scene_id') as bigint)                                                   as scene_id
,cast(get_json_object(data,'$.scene_name') as string)                                                 as scene_name
,cast(get_json_object(data,'$.rule_group_ids') as string)                                             as rule_group_ids
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.is_disable') as bigint)                                                 as is_disable
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.scene_id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_my 
        where base_database = 'credit_risk_control_my_db' and base_table= 'scene_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 0 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_control_my_db__scene_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 scene_id                                                                                             as scene_id
,scene_name                                                                                           as scene_name
,rule_group_ids                                                                                       as rule_group_ids
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,is_disable                                                                                           as is_disable
 
 ,_event
 ;