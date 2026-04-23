

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,flow_no                                                                                              as flow_no
,req_params                                                                                           as req_params
,rsp                                                                                                  as rsp
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,pending_start_time                                                                                   as pending_start_time
,pending_finish_time                                                                                  as pending_finish_time
,result_code                                                                                          as result_code
,shopeepay_user_id                                                                                    as shopeepay_user_id
 
,_event
 from(
    select 
 id                                                                                                   as id
,flow_no                                                                                              as flow_no
,req_params                                                                                           as req_params
,rsp                                                                                                  as rsp
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,pending_start_time                                                                                   as pending_start_time
,pending_finish_time                                                                                  as pending_finish_time
,result_code                                                                                          as result_code
,shopeepay_user_id                                                                                    as shopeepay_user_id
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,flow_no                                                                                              as flow_no
,req_params                                                                                           as req_params
,rsp                                                                                                  as rsp
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,pending_start_time                                                                                   as pending_start_time
,pending_finish_time                                                                                  as pending_finish_time
,result_code                                                                                          as result_code
,shopeepay_user_id                                                                                    as shopeepay_user_id
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__ldn_risk_underwriting_id_db__invoke_policy_result_history_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.flow_no') as string)                                                    as flow_no
,cast(get_json_object(data,'$.req_params') as string)                                                 as req_params
,cast(get_json_object(data,'$.rsp') as string)                                                        as rsp
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.app_id') as string)                                                     as app_id
,cast(get_json_object(data,'$.scene_id') as bigint)                                                   as scene_id
,cast(get_json_object(data,'$.platform_user_id') as string)                                           as platform_user_id
,cast(get_json_object(data,'$.platform_type') as bigint)                                              as platform_type
,cast(get_json_object(data,'$.pending_start_time') as bigint)                                         as pending_start_time
,cast(get_json_object(data,'$.pending_finish_time') as bigint)                                        as pending_finish_time
,cast(get_json_object(data,'$.result_code') as bigint)                                                as result_code
,cast(get_json_object(data,'$.shopeepay_user_id') as string)                                          as shopeepay_user_id
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'ldn_risk_underwriting_id_db' and base_table= 'invoke_policy_result_history_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete' 
)
insert overwrite table risk.ods__ldn_risk_underwriting_id_db__invoke_policy_result_history_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,flow_no                                                                                              as flow_no
,req_params                                                                                           as req_params
,rsp                                                                                                  as rsp
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,pending_start_time                                                                                   as pending_start_time
,pending_finish_time                                                                                  as pending_finish_time
,result_code                                                                                          as result_code
,shopeepay_user_id                                                                                    as shopeepay_user_id
 
 ,_event
 ;