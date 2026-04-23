

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,old_strategy_id                                                                                      as old_strategy_id
,gray_strategy_id                                                                                     as gray_strategy_id
,gray_proportion                                                                                      as gray_proportion
,stat_status                                                                                          as stat_status
,old_req_total                                                                                        as old_req_total
,old_pass_total                                                                                       as old_pass_total
,old_reject_total                                                                                     as old_reject_total
,old_verify_total                                                                                     as old_verify_total
,old_error_total                                                                                      as old_error_total
,gray_req_total                                                                                       as gray_req_total
,gray_pass_total                                                                                      as gray_pass_total
,gray_reject_total                                                                                    as gray_reject_total
,gray_verify_total                                                                                    as gray_verify_total
,gray_error_total                                                                                     as gray_error_total
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
,_event
 from(
    select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,old_strategy_id                                                                                      as old_strategy_id
,gray_strategy_id                                                                                     as gray_strategy_id
,gray_proportion                                                                                      as gray_proportion
,stat_status                                                                                          as stat_status
,old_req_total                                                                                        as old_req_total
,old_pass_total                                                                                       as old_pass_total
,old_reject_total                                                                                     as old_reject_total
,old_verify_total                                                                                     as old_verify_total
,old_error_total                                                                                      as old_error_total
,gray_req_total                                                                                       as gray_req_total
,gray_pass_total                                                                                      as gray_pass_total
,gray_reject_total                                                                                    as gray_reject_total
,gray_verify_total                                                                                    as gray_verify_total
,gray_error_total                                                                                     as gray_error_total
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,old_strategy_id                                                                                      as old_strategy_id
,gray_strategy_id                                                                                     as gray_strategy_id
,gray_proportion                                                                                      as gray_proportion
,stat_status                                                                                          as stat_status
,old_req_total                                                                                        as old_req_total
,old_pass_total                                                                                       as old_pass_total
,old_reject_total                                                                                     as old_reject_total
,old_verify_total                                                                                     as old_verify_total
,old_error_total                                                                                      as old_error_total
,gray_req_total                                                                                       as gray_req_total
,gray_pass_total                                                                                      as gray_pass_total
,gray_reject_total                                                                                    as gray_reject_total
,gray_verify_total                                                                                    as gray_verify_total
,gray_error_total                                                                                     as gray_error_total
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_id_db__gray_strategy_stat_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.app_id') as string)                                                     as app_id
,cast(get_json_object(data,'$.scene_id') as bigint)                                                   as scene_id
,cast(get_json_object(data,'$.old_strategy_id') as bigint)                                            as old_strategy_id
,cast(get_json_object(data,'$.gray_strategy_id') as bigint)                                           as gray_strategy_id
,cast(get_json_object(data,'$.gray_proportion') as bigint)                                            as gray_proportion
,cast(get_json_object(data,'$.stat_status') as bigint)                                                as stat_status
,cast(get_json_object(data,'$.old_req_total') as bigint)                                              as old_req_total
,cast(get_json_object(data,'$.old_pass_total') as bigint)                                             as old_pass_total
,cast(get_json_object(data,'$.old_reject_total') as bigint)                                           as old_reject_total
,cast(get_json_object(data,'$.old_verify_total') as bigint)                                           as old_verify_total
,cast(get_json_object(data,'$.old_error_total') as bigint)                                            as old_error_total
,cast(get_json_object(data,'$.gray_req_total') as bigint)                                             as gray_req_total
,cast(get_json_object(data,'$.gray_pass_total') as bigint)                                            as gray_pass_total
,cast(get_json_object(data,'$.gray_reject_total') as bigint)                                          as gray_reject_total
,cast(get_json_object(data,'$.gray_verify_total') as bigint)                                          as gray_verify_total
,cast(get_json_object(data,'$.gray_error_total') as bigint)                                           as gray_error_total
,cast(get_json_object(data,'$.creator') as string)                                                    as creator
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_control_id_db' and base_table= 'gray_strategy_stat_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_control_id_db__gray_strategy_stat_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,old_strategy_id                                                                                      as old_strategy_id
,gray_strategy_id                                                                                     as gray_strategy_id
,gray_proportion                                                                                      as gray_proportion
,stat_status                                                                                          as stat_status
,old_req_total                                                                                        as old_req_total
,old_pass_total                                                                                       as old_pass_total
,old_reject_total                                                                                     as old_reject_total
,old_verify_total                                                                                     as old_verify_total
,old_error_total                                                                                      as old_error_total
,gray_req_total                                                                                       as gray_req_total
,gray_pass_total                                                                                      as gray_pass_total
,gray_reject_total                                                                                    as gray_reject_total
,gray_verify_total                                                                                    as gray_verify_total
,gray_error_total                                                                                     as gray_error_total
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,_event
 ;