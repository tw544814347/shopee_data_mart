

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,mission_start_score                                                                                  as mission_start_score
,get_score                                                                                            as get_score
,mission_id                                                                                           as mission_id
,mission_code                                                                                         as mission_code
,mission_type                                                                                         as mission_type
,complete_condition                                                                                   as complete_condition
,mission_total_count                                                                                  as mission_total_count
,completed_count                                                                                      as completed_count
,complete_status                                                                                      as complete_status
,start_time                                                                                           as start_time
,complete_time                                                                                        as complete_time
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
,_event
 from(
    select 
 id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,mission_start_score                                                                                  as mission_start_score
,get_score                                                                                            as get_score
,mission_id                                                                                           as mission_id
,mission_code                                                                                         as mission_code
,mission_type                                                                                         as mission_type
,complete_condition                                                                                   as complete_condition
,mission_total_count                                                                                  as mission_total_count
,completed_count                                                                                      as completed_count
,complete_status                                                                                      as complete_status
,start_time                                                                                           as start_time
,complete_time                                                                                        as complete_time
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,mission_start_score                                                                                  as mission_start_score
,get_score                                                                                            as get_score
,mission_id                                                                                           as mission_id
,mission_code                                                                                         as mission_code
,mission_type                                                                                         as mission_type
,complete_condition                                                                                   as complete_condition
,mission_total_count                                                                                  as mission_total_count
,completed_count                                                                                      as completed_count
,complete_status                                                                                      as complete_status
,start_time                                                                                           as start_time
,complete_time                                                                                        as complete_time
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_score_id_db__user_mission_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id
,cast(get_json_object(data,'$.platform_user_id') as string)                                           as platform_user_id
,cast(get_json_object(data,'$.platform_type') as bigint)                                              as platform_type
,cast(get_json_object(data,'$.mission_start_score') as bigint)                                        as mission_start_score
,cast(get_json_object(data,'$.get_score') as bigint)                                                  as get_score
,cast(get_json_object(data,'$.mission_id') as decimal(20,0))                                          as mission_id
,cast(get_json_object(data,'$.mission_code') as string)                                               as mission_code
,cast(get_json_object(data,'$.mission_type') as bigint)                                               as mission_type
,cast(get_json_object(data,'$.complete_condition') as string)                                         as complete_condition
,cast(get_json_object(data,'$.mission_total_count') as bigint)                                        as mission_total_count
,cast(get_json_object(data,'$.completed_count') as bigint)                                            as completed_count
,cast(get_json_object(data,'$.complete_status') as bigint)                                            as complete_status
,cast(get_json_object(data,'$.start_time') as bigint)                                                 as start_time
,cast(get_json_object(data,'$.complete_time') as bigint)                                              as complete_time
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_score_id_db' and base_table= 'user_mission_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time')/1000 - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_score_id_db__user_mission_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,mission_start_score                                                                                  as mission_start_score
,get_score                                                                                            as get_score
,mission_id                                                                                           as mission_id
,mission_code                                                                                         as mission_code
,mission_type                                                                                         as mission_type
,complete_condition                                                                                   as complete_condition
,mission_total_count                                                                                  as mission_total_count
,completed_count                                                                                      as completed_count
,complete_status                                                                                      as complete_status
,start_time                                                                                           as start_time
,complete_time                                                                                        as complete_time
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,_event
 ;