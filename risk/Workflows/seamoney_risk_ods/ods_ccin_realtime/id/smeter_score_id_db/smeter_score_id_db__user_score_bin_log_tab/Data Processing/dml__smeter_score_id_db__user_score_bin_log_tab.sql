

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,bin_log_id                                                                                           as bin_log_id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,bin_time                                                                                             as bin_time
,current_score                                                                                        as current_score
,change_score                                                                                         as change_score
,result_score                                                                                         as result_score
,cause_type                                                                                           as cause_type
,cause                                                                                                as cause
,event_id                                                                                             as event_id
,event_detail                                                                                         as event_detail
,reserved1                                                                                            as reserved1
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,has_seen                                                                                             as has_seen
 
,_event
 from(
    select 
 id                                                                                                   as id
,bin_log_id                                                                                           as bin_log_id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,bin_time                                                                                             as bin_time
,current_score                                                                                        as current_score
,change_score                                                                                         as change_score
,result_score                                                                                         as result_score
,cause_type                                                                                           as cause_type
,cause                                                                                                as cause
,event_id                                                                                             as event_id
,event_detail                                                                                         as event_detail
,reserved1                                                                                            as reserved1
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,has_seen                                                                                             as has_seen
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,bin_log_id                                                                                           as bin_log_id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,bin_time                                                                                             as bin_time
,current_score                                                                                        as current_score
,change_score                                                                                         as change_score
,result_score                                                                                         as result_score
,cause_type                                                                                           as cause_type
,cause                                                                                                as cause
,event_id                                                                                             as event_id
,event_detail                                                                                         as event_detail
,reserved1                                                                                            as reserved1
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,has_seen                                                                                             as has_seen
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__smeter_score_id_db__user_score_bin_log_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id
,cast(get_json_object(data,'$.bin_log_id') as string)                                                 as bin_log_id
,cast(get_json_object(data,'$.platform_user_id') as string)                                           as platform_user_id
,cast(get_json_object(data,'$.platform_type') as bigint)                                              as platform_type
,cast(get_json_object(data,'$.bin_time') as bigint)                                                   as bin_time
,cast(get_json_object(data,'$.current_score') as bigint)                                              as current_score
,cast(get_json_object(data,'$.change_score') as bigint)                                               as change_score
,cast(get_json_object(data,'$.result_score') as bigint)                                               as result_score
,cast(get_json_object(data,'$.cause_type') as bigint)                                                 as cause_type
,cast(get_json_object(data,'$.cause') as bigint)                                                      as cause
,cast(get_json_object(data,'$.event_id') as string)                                                   as event_id
,cast(get_json_object(data,'$.event_detail') as string)                                               as event_detail
,cast(get_json_object(data,'$.reserved1') as string)                                                  as reserved1
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.has_seen') as bigint)                                                   as has_seen
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'smeter_score_id_db' and base_table= 'user_score_bin_log_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time')/1000 - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete' 
)
insert overwrite table risk.ods__smeter_score_id_db__user_score_bin_log_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,bin_log_id                                                                                           as bin_log_id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,bin_time                                                                                             as bin_time
,current_score                                                                                        as current_score
,change_score                                                                                         as change_score
,result_score                                                                                         as result_score
,cause_type                                                                                           as cause_type
,cause                                                                                                as cause
,event_id                                                                                             as event_id
,event_detail                                                                                         as event_detail
,reserved1                                                                                            as reserved1
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,has_seen                                                                                             as has_seen
 
 ,_event
 ;