

refresh table risk.ccin_multi_realtime_binlog_for_my;

from (
    select 
 id                                                                                                   as id
,region                                                                                               as region
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,tree_id                                                                                              as tree_id
,tree_version                                                                                         as tree_version
,tree_type                                                                                            as tree_type
,tree_status                                                                                          as tree_status
,start_time                                                                                           as start_time
,end_time                                                                                             as end_time
,init_flow_time                                                                                       as init_flow_time
,init_flow_ratio                                                                                      as init_flow_ratio
,run_with_new_flow                                                                                    as run_with_new_flow
,mail_flag                                                                                            as mail_flag
,description                                                                                          as description
,operator                                                                                             as operator
,create_time                                                                                          as create_time
,create_user                                                                                          as create_user
,update_time                                                                                          as update_time
 
,_event
 from(
    select 
 id                                                                                                   as id
,region                                                                                               as region
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,tree_id                                                                                              as tree_id
,tree_version                                                                                         as tree_version
,tree_type                                                                                            as tree_type
,tree_status                                                                                          as tree_status
,start_time                                                                                           as start_time
,end_time                                                                                             as end_time
,init_flow_time                                                                                       as init_flow_time
,init_flow_ratio                                                                                      as init_flow_ratio
,run_with_new_flow                                                                                    as run_with_new_flow
,mail_flag                                                                                            as mail_flag
,description                                                                                          as description
,operator                                                                                             as operator
,create_time                                                                                          as create_time
,create_user                                                                                          as create_user
,update_time                                                                                          as update_time
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,region                                                                                               as region
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,tree_id                                                                                              as tree_id
,tree_version                                                                                         as tree_version
,tree_type                                                                                            as tree_type
,tree_status                                                                                          as tree_status
,start_time                                                                                           as start_time
,end_time                                                                                             as end_time
,init_flow_time                                                                                       as init_flow_time
,init_flow_ratio                                                                                      as init_flow_ratio
,run_with_new_flow                                                                                    as run_with_new_flow
,mail_flag                                                                                            as mail_flag
,description                                                                                          as description
,operator                                                                                             as operator
,create_time                                                                                          as create_time
,create_user                                                                                          as create_user
,update_time                                                                                          as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_my_db__policy_tree_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id
,cast(get_json_object(data,'$.region') as string)                                                     as region
,cast(get_json_object(data,'$.app_id') as string)                                                     as app_id
,cast(get_json_object(data,'$.scene_id') as bigint)                                                   as scene_id
,cast(get_json_object(data,'$.tree_id') as bigint)                                                    as tree_id
,cast(get_json_object(data,'$.tree_version') as bigint)                                               as tree_version
,cast(get_json_object(data,'$.tree_type') as bigint)                                                  as tree_type
,cast(get_json_object(data,'$.tree_status') as bigint)                                                as tree_status
,cast(get_json_object(data,'$.start_time') as bigint)                                                 as start_time
,cast(get_json_object(data,'$.end_time') as bigint)                                                   as end_time
,cast(get_json_object(data,'$.init_flow_time') as bigint)                                             as init_flow_time
,cast(get_json_object(data,'$.init_flow_ratio') as bigint)                                            as init_flow_ratio
,cast(get_json_object(data,'$.run_with_new_flow') as bigint)                                          as run_with_new_flow
,cast(get_json_object(data,'$.mail_flag') as bigint)                                                  as mail_flag
,cast(get_json_object(data,'$.description') as string)                                                as description
,cast(get_json_object(data,'$.operator') as string)                                                   as operator
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.create_user') as string)                                                as create_user
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_my 
        where base_database = 'credit_risk_control_my_db' and base_table= 'policy_tree_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 0 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_control_my_db__policy_tree_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,region                                                                                               as region
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,tree_id                                                                                              as tree_id
,tree_version                                                                                         as tree_version
,tree_type                                                                                            as tree_type
,tree_status                                                                                          as tree_status
,start_time                                                                                           as start_time
,end_time                                                                                             as end_time
,init_flow_time                                                                                       as init_flow_time
,init_flow_ratio                                                                                      as init_flow_ratio
,run_with_new_flow                                                                                    as run_with_new_flow
,mail_flag                                                                                            as mail_flag
,description                                                                                          as description
,operator                                                                                             as operator
,create_time                                                                                          as create_time
,create_user                                                                                          as create_user
,update_time                                                                                          as update_time
 
 ,_event
 ;