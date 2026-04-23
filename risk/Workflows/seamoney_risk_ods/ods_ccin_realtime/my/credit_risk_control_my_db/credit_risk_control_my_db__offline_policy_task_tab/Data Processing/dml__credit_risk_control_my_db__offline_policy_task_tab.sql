



refresh table risk.ccin_multi_realtime_binlog_for_my;

from (
    select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,policy_tree_id                                                                                       as policy_tree_id
,policy_tree_version                                                                                  as policy_tree_version
,user_group_id                                                                                        as user_group_id
,user_group_name                                                                                      as user_group_name
,run_time                                                                                             as run_time
,status                                                                                               as status
,description                                                                                          as description
,operator                                                                                             as operator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time

,_event
 from(
    select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,policy_tree_id                                                                                       as policy_tree_id
,policy_tree_version                                                                                  as policy_tree_version
,user_group_id                                                                                        as user_group_id
,user_group_name                                                                                      as user_group_name
,run_time                                                                                             as run_time
,status                                                                                               as status
,description                                                                                          as description
,operator                                                                                             as operator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time

 ,_event
,row_number() over(partition by on_keys_conds order by update_time desc,get_json_object(_event,'$.ts') desc, get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,policy_tree_id                                                                                       as policy_tree_id
,policy_tree_version                                                                                  as policy_tree_version
,user_group_id                                                                                        as user_group_id
,user_group_name                                                                                      as user_group_name
,run_time                                                                                             as run_time
,status                                                                                               as status
,description                                                                                          as description
,operator                                                                                             as operator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)                    as on_keys_conds

,_event
        from risk.ods__credit_risk_control_my_db__offline_policy_task_tab__df__private fs
        where grass_date = date_add('${grass_date}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id 
,cast(get_json_object(data,'$.app_id') as string)                                                     as app_id 
,cast(get_json_object(data,'$.scene_id') as bigint)                                                   as scene_id 
,cast(get_json_object(data,'$.policy_tree_id') as bigint)                                             as policy_tree_id 
,cast(get_json_object(data,'$.policy_tree_version') as bigint)                                        as policy_tree_version 
,cast(get_json_object(data,'$.user_group_id') as bigint)                                              as user_group_id 
,cast(get_json_object(data,'$.user_group_name') as string)                                            as user_group_name 
,cast(get_json_object(data,'$.run_time') as string)                                                   as run_time 
,cast(get_json_object(data,'$.status') as bigint)                                                     as status 
,cast(get_json_object(data,'$.description') as string)                                                as description 
,cast(get_json_object(data,'$.operator') as string)                                                   as operator 
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time 
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time 

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),get_json_object(data,'$.id')) as on_keys_conds

,_event
        from risk.ccin_multi_realtime_binlog_for_my 
        where base_database = 'credit_risk_control_my_db' and base_table = 'offline_policy_task_tab'
        --base_database like 'credit_risk_control_my_db%' and base_table like 'offline_policy_task_tab%'
        and (dt 
              between date_add('${grass_date}', -2) 
              and if('${binlog_src_end_date}' >= '${grass_date}', '${binlog_src_end_date}' ,date_add('${grass_date}', 10))
            ) 
         and from_unixtime(get_json_object(data,'$.update_time') - 0,'yyyy-MM-dd') <= '${grass_date}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)

    
insert overwrite table risk.ods__credit_risk_control_my_db__offline_policy_task_tab__df__private partition(grass_date = '${grass_date}')
select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,policy_tree_id                                                                                       as policy_tree_id
,policy_tree_version                                                                                  as policy_tree_version
,user_group_id                                                                                        as user_group_id
,user_group_name                                                                                      as user_group_name
,run_time                                                                                             as run_time
,status                                                                                               as status
,description                                                                                          as description
,operator                                                                                             as operator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time

 ,_event


;
---------------------------msck repair table for all dest dbs---------------------------------------

msck repair table risk.ods__credit_risk_control_my_db__offline_policy_task_tab__df__private;

refresh table risk.ods__credit_risk_control_my_db__offline_policy_task_tab__df__private;

    