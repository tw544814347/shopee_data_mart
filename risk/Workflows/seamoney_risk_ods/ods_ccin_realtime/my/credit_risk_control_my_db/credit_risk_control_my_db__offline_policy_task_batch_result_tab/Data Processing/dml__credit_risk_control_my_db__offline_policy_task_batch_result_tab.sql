



refresh table risk.ccin_multi_realtime_binlog_for_my;

from (
    select 
 id                                                                                                   as id
,task_id                                                                                              as task_id
,batch_id                                                                                             as batch_id
,platform_user_id                                                                                     as platform_user_id
,credit_user_id                                                                                       as credit_user_id
,platform_type                                                                                        as platform_type
,run_policy_status                                                                                    as run_policy_status
,run_policy_result                                                                                    as run_policy_result
,policy_input                                                                                         as policy_input
,policy_output                                                                                        as policy_output
,sync_status                                                                                          as sync_status
,sync_result                                                                                          as sync_result
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time

,_event
 from(
    select 
 id                                                                                                   as id
,task_id                                                                                              as task_id
,batch_id                                                                                             as batch_id
,platform_user_id                                                                                     as platform_user_id
,credit_user_id                                                                                       as credit_user_id
,platform_type                                                                                        as platform_type
,run_policy_status                                                                                    as run_policy_status
,run_policy_result                                                                                    as run_policy_result
,policy_input                                                                                         as policy_input
,policy_output                                                                                        as policy_output
,sync_status                                                                                          as sync_status
,sync_result                                                                                          as sync_result
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time

 ,_event
,row_number() over(partition by on_keys_conds order by update_time desc,get_json_object(_event,'$.ts') desc, get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,task_id                                                                                              as task_id
,batch_id                                                                                             as batch_id
,platform_user_id                                                                                     as platform_user_id
,credit_user_id                                                                                       as credit_user_id
,platform_type                                                                                        as platform_type
,run_policy_status                                                                                    as run_policy_status
,run_policy_result                                                                                    as run_policy_result
,policy_input                                                                                         as policy_input
,policy_output                                                                                        as policy_output
,sync_status                                                                                          as sync_status
,sync_result                                                                                          as sync_result
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)                    as on_keys_conds

,_event
        from risk.ods__credit_risk_control_my_db__offline_policy_task_batch_result_tab__df__private fs
        where grass_date = date_add('${grass_date}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id 
,cast(get_json_object(data,'$.task_id') as bigint)                                                    as task_id 
,cast(get_json_object(data,'$.batch_id') as bigint)                                                   as batch_id 
,cast(get_json_object(data,'$.platform_user_id') as string)                                           as platform_user_id 
,cast(get_json_object(data,'$.credit_user_id') as string)                                             as credit_user_id 
,cast(get_json_object(data,'$.platform_type') as bigint)                                              as platform_type 
,cast(get_json_object(data,'$.run_policy_status') as bigint)                                          as run_policy_status 
,cast(get_json_object(data,'$.run_policy_result') as string)                                          as run_policy_result 
,cast(get_json_object(data,'$.policy_input') as string)                                               as policy_input 
,cast(get_json_object(data,'$.policy_output') as string)                                              as policy_output 
,cast(get_json_object(data,'$.sync_status') as bigint)                                                as sync_status 
,cast(get_json_object(data,'$.sync_result') as string)                                                as sync_result 
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time 
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time 

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),get_json_object(data,'$.id')) as on_keys_conds

,_event
        from risk.ccin_multi_realtime_binlog_for_my 
        where base_database = 'credit_risk_control_my_db' and base_table = 'offline_policy_task_batch_result_tab'
        --base_database like 'credit_risk_control_my_db%' and base_table like 'offline_policy_task_batch_result_tab%'
        and (dt 
              between date_add('${grass_date}', -2) 
              and if('${binlog_src_end_date}' >= '${grass_date}', '${binlog_src_end_date}' ,date_add('${grass_date}', 10))
            ) 
         and from_unixtime(get_json_object(data,'$.update_time') - 0,'yyyy-MM-dd') <= '${grass_date}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)

    
insert overwrite table risk.ods__credit_risk_control_my_db__offline_policy_task_batch_result_tab__df__private partition(grass_date = '${grass_date}')
select 
 id                                                                                                   as id
,task_id                                                                                              as task_id
,batch_id                                                                                             as batch_id
,platform_user_id                                                                                     as platform_user_id
,credit_user_id                                                                                       as credit_user_id
,platform_type                                                                                        as platform_type
,run_policy_status                                                                                    as run_policy_status
,run_policy_result                                                                                    as run_policy_result
,policy_input                                                                                         as policy_input
,policy_output                                                                                        as policy_output
,sync_status                                                                                          as sync_status
,sync_result                                                                                          as sync_result
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time

 ,_event


;
---------------------------msck repair table for all dest dbs---------------------------------------

msck repair table risk.ods__credit_risk_control_my_db__offline_policy_task_batch_result_tab__df__private;

refresh table risk.ods__credit_risk_control_my_db__offline_policy_task_batch_result_tab__df__private;

    