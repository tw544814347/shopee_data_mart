



refresh table risk.ccin_multi_realtime_binlog_for_my;

from (
    select 
 id                                                                                                   as id
,offline_task_id                                                                                      as offline_task_id
,start_time                                                                                           as start_time
,end_time                                                                                             as end_time
,run_policy_status                                                                                    as run_policy_status
,run_policy_result                                                                                    as run_policy_result
,sync_status                                                                                          as sync_status
,sync_result                                                                                          as sync_result
,descriptionn                                                                                         as descriptionn
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,gen_result_file_status                                                                               as gen_result_file_status
,run_policy_output_file                                                                               as run_policy_output_file
,run_policy_failed_file                                                                               as run_policy_failed_file
,gen_sync_failed_file_status                                                                          as gen_sync_failed_file_status
,sync_failed_file                                                                                     as sync_failed_file

,_event
 from(
    select 
 id                                                                                                   as id
,offline_task_id                                                                                      as offline_task_id
,start_time                                                                                           as start_time
,end_time                                                                                             as end_time
,run_policy_status                                                                                    as run_policy_status
,run_policy_result                                                                                    as run_policy_result
,sync_status                                                                                          as sync_status
,sync_result                                                                                          as sync_result
,descriptionn                                                                                         as descriptionn
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,gen_result_file_status                                                                               as gen_result_file_status
,run_policy_output_file                                                                               as run_policy_output_file
,run_policy_failed_file                                                                               as run_policy_failed_file
,gen_sync_failed_file_status                                                                          as gen_sync_failed_file_status
,sync_failed_file                                                                                     as sync_failed_file

 ,_event
,row_number() over(partition by on_keys_conds order by update_time desc,get_json_object(_event,'$.ts') desc, get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,offline_task_id                                                                                      as offline_task_id
,start_time                                                                                           as start_time
,end_time                                                                                             as end_time
,run_policy_status                                                                                    as run_policy_status
,run_policy_result                                                                                    as run_policy_result
,sync_status                                                                                          as sync_status
,sync_result                                                                                          as sync_result
,descriptionn                                                                                         as descriptionn
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,gen_result_file_status                                                                               as gen_result_file_status
,run_policy_output_file                                                                               as run_policy_output_file
,run_policy_failed_file                                                                               as run_policy_failed_file
,gen_sync_failed_file_status                                                                          as gen_sync_failed_file_status
,sync_failed_file                                                                                     as sync_failed_file

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)                    as on_keys_conds

,_event
        from risk.ods__credit_risk_control_my_db__offline_policy_task_batch_tab__df__private fs
        where grass_date = date_add('${grass_date}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id 
,cast(get_json_object(data,'$.offline_task_id') as bigint)                                            as offline_task_id 
,cast(get_json_object(data,'$.start_time') as bigint)                                                 as start_time 
,cast(get_json_object(data,'$.end_time') as bigint)                                                   as end_time 
,cast(get_json_object(data,'$.run_policy_status') as bigint)                                          as run_policy_status 
,cast(get_json_object(data,'$.run_policy_result') as string)                                          as run_policy_result 
,cast(get_json_object(data,'$.sync_status') as bigint)                                                as sync_status 
,cast(get_json_object(data,'$.sync_result') as string)                                                as sync_result 
,cast(get_json_object(data,'$.descriptionn') as string)                                               as descriptionn 
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time 
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time 
,cast(get_json_object(data,'$.gen_result_file_status') as bigint)                                     as gen_result_file_status 
,cast(get_json_object(data,'$.run_policy_output_file') as string)                                     as run_policy_output_file 
,cast(get_json_object(data,'$.run_policy_failed_file') as string)                                     as run_policy_failed_file 
,cast(get_json_object(data,'$.gen_sync_failed_file_status') as bigint)                                as gen_sync_failed_file_status 
,cast(get_json_object(data,'$.sync_failed_file') as string)                                           as sync_failed_file 

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),get_json_object(data,'$.id')) as on_keys_conds

,_event
        from risk.ccin_multi_realtime_binlog_for_my 
        where base_database = 'credit_risk_control_my_db' and base_table = 'offline_policy_task_batch_tab'
        --base_database like 'credit_risk_control_my_db%' and base_table like 'offline_policy_task_batch_tab%'
        and (dt 
              between date_add('${grass_date}', -2) 
              and if('${binlog_src_end_date}' >= '${grass_date}', '${binlog_src_end_date}' ,date_add('${grass_date}', 10))
            ) 
         and from_unixtime(get_json_object(data,'$.update_time') - 0,'yyyy-MM-dd') <= '${grass_date}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)

    
insert overwrite table risk.ods__credit_risk_control_my_db__offline_policy_task_batch_tab__df__private partition(grass_date = '${grass_date}')
select 
 id                                                                                                   as id
,offline_task_id                                                                                      as offline_task_id
,start_time                                                                                           as start_time
,end_time                                                                                             as end_time
,run_policy_status                                                                                    as run_policy_status
,run_policy_result                                                                                    as run_policy_result
,sync_status                                                                                          as sync_status
,sync_result                                                                                          as sync_result
,descriptionn                                                                                         as descriptionn
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,gen_result_file_status                                                                               as gen_result_file_status
,run_policy_output_file                                                                               as run_policy_output_file
,run_policy_failed_file                                                                               as run_policy_failed_file
,gen_sync_failed_file_status                                                                          as gen_sync_failed_file_status
,sync_failed_file                                                                                     as sync_failed_file

 ,_event


;
---------------------------msck repair table for all dest dbs---------------------------------------

msck repair table risk.ods__credit_risk_control_my_db__offline_policy_task_batch_tab__df__private;

refresh table risk.ods__credit_risk_control_my_db__offline_policy_task_batch_tab__df__private;

    