

refresh table risk.ccin_multi_realtime_binlog_for_my;

from (
    select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,region                                                                                               as region
,config_name                                                                                          as config_name
,config_tag                                                                                           as config_tag
,config_tree                                                                                          as config_tree
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
,_event
 from(
    select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,region                                                                                               as region
,config_name                                                                                          as config_name
,config_tag                                                                                           as config_tag
,config_tree                                                                                          as config_tree
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,region                                                                                               as region
,config_name                                                                                          as config_name
,config_tag                                                                                           as config_tag
,config_tree                                                                                          as config_tree
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__invest_risk_control_my_db__risk_workflow_config_tree_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id
,cast(get_json_object(data,'$.app_id') as string)                                                     as app_id
,cast(get_json_object(data,'$.scene_id') as bigint)                                                   as scene_id
,cast(get_json_object(data,'$.region') as string)                                                     as region
,cast(get_json_object(data,'$.config_name') as string)                                                as config_name
,cast(get_json_object(data,'$.config_tag') as string)                                                 as config_tag
,cast(get_json_object(data,'$.config_tree') as string)                                                as config_tree
,cast(get_json_object(data,'$.version') as bigint)                                                    as version
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_my 
        where base_database = 'invest_risk_control_my_db' and base_table= 'risk_workflow_config_tree_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 0 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__invest_risk_control_my_db__risk_workflow_config_tree_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,region                                                                                               as region
,config_name                                                                                          as config_name
,config_tag                                                                                           as config_tag
,config_tree                                                                                          as config_tree
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,_event
 ;