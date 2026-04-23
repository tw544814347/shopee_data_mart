

refresh table risk.ccin_multi_realtime_binlog_for_my;

from (
    select 
 id                                                                                                   as id
,tree_id                                                                                              as tree_id
,tree_version                                                                                         as tree_version
,node_id                                                                                              as node_id
,action_type                                                                                          as action_type
,invoke_type                                                                                          as invoke_type
,create_user                                                                                          as create_user
,create_time                                                                                          as create_time
,update_user                                                                                          as update_user
,update_time                                                                                          as update_time
 
,_event
 from(
    select 
 id                                                                                                   as id
,tree_id                                                                                              as tree_id
,tree_version                                                                                         as tree_version
,node_id                                                                                              as node_id
,action_type                                                                                          as action_type
,invoke_type                                                                                          as invoke_type
,create_user                                                                                          as create_user
,create_time                                                                                          as create_time
,update_user                                                                                          as update_user
,update_time                                                                                          as update_time
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,tree_id                                                                                              as tree_id
,tree_version                                                                                         as tree_version
,node_id                                                                                              as node_id
,action_type                                                                                          as action_type
,invoke_type                                                                                          as invoke_type
,create_user                                                                                          as create_user
,create_time                                                                                          as create_time
,update_user                                                                                          as update_user
,update_time                                                                                          as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_my_db__action_node_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.tree_id') as bigint)                                                    as tree_id
,cast(get_json_object(data,'$.tree_version') as bigint)                                               as tree_version
,cast(get_json_object(data,'$.node_id') as string)                                                    as node_id
,cast(get_json_object(data,'$.action_type') as string)                                                as action_type
,cast(get_json_object(data,'$.invoke_type') as string)                                                as invoke_type
,cast(get_json_object(data,'$.create_user') as string)                                                as create_user
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_user') as string)                                                as update_user
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_my 
        where base_database = 'credit_risk_control_my_db' and base_table= 'action_node_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 0 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_control_my_db__action_node_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,tree_id                                                                                              as tree_id
,tree_version                                                                                         as tree_version
,node_id                                                                                              as node_id
,action_type                                                                                          as action_type
,invoke_type                                                                                          as invoke_type
,create_user                                                                                          as create_user
,create_time                                                                                          as create_time
,update_user                                                                                          as update_user
,update_time                                                                                          as update_time
 
 ,_event
 ;