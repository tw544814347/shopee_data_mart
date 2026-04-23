

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,trade_id                                                                                             as trade_id
,flow_no                                                                                              as flow_no
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,result_code                                                                                          as result_code
,reason                                                                                               as reason
,reject_code                                                                                          as reject_code
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,status                                                                                               as status
,req_params                                                                                           as req_params
,risk_level                                                                                           as risk_level
,limit_info                                                                                           as limit_info
,pending_code                                                                                         as pending_code
,risk_grade                                                                                           as risk_grade
,tree_id                                                                                              as tree_id
,tree_type                                                                                            as tree_type
,tree_version                                                                                         as tree_version
,context_info                                                                                         as context_info
,pending_feature                                                                                      as pending_feature
 
,_event
 from(
    select 
 id                                                                                                   as id
,trade_id                                                                                             as trade_id
,flow_no                                                                                              as flow_no
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,result_code                                                                                          as result_code
,reason                                                                                               as reason
,reject_code                                                                                          as reject_code
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,status                                                                                               as status
,req_params                                                                                           as req_params
,risk_level                                                                                           as risk_level
,limit_info                                                                                           as limit_info
,pending_code                                                                                         as pending_code
,risk_grade                                                                                           as risk_grade
,tree_id                                                                                              as tree_id
,tree_type                                                                                            as tree_type
,tree_version                                                                                         as tree_version
,context_info                                                                                         as context_info
,pending_feature                                                                                      as pending_feature
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,trade_id                                                                                             as trade_id
,flow_no                                                                                              as flow_no
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,result_code                                                                                          as result_code
,reason                                                                                               as reason
,reject_code                                                                                          as reject_code
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,status                                                                                               as status
,req_params                                                                                           as req_params
,risk_level                                                                                           as risk_level
,limit_info                                                                                           as limit_info
,pending_code                                                                                         as pending_code
,risk_grade                                                                                           as risk_grade
,tree_id                                                                                              as tree_id
,tree_type                                                                                            as tree_type
,tree_version                                                                                         as tree_version
,context_info                                                                                         as context_info
,pending_feature                                                                                      as pending_feature
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__ldn_risk_underwriting_id_db__invoke_policy_result_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id
,cast(get_json_object(data,'$.trade_id') as string)                                                   as trade_id
,cast(get_json_object(data,'$.flow_no') as string)                                                    as flow_no
,cast(get_json_object(data,'$.app_id') as string)                                                     as app_id
,cast(get_json_object(data,'$.scene_id') as bigint)                                                   as scene_id
,cast(get_json_object(data,'$.platform_user_id') as string)                                           as platform_user_id
,cast(get_json_object(data,'$.result_code') as bigint)                                                as result_code
,cast(get_json_object(data,'$.reason') as string)                                                     as reason
,cast(get_json_object(data,'$.reject_code') as string)                                                as reject_code
,cast(get_json_object(data,'$.create_time') as decimal(20,0))                                         as create_time
,cast(get_json_object(data,'$.update_time') as decimal(20,0))                                         as update_time
,cast(get_json_object(data,'$.status') as bigint)                                                     as status
,cast(get_json_object(data,'$.req_params') as string)                                                 as req_params
,cast(get_json_object(data,'$.risk_level') as bigint)                                                 as risk_level
,cast(get_json_object(data,'$.limit_info') as string)                                                 as limit_info
,cast(get_json_object(data,'$.pending_code') as string)                                               as pending_code
,cast(get_json_object(data,'$.risk_grade') as bigint)                                                 as risk_grade
,cast(get_json_object(data,'$.tree_id') as bigint)                                                    as tree_id
,cast(get_json_object(data,'$.tree_type') as bigint)                                                  as tree_type
,cast(get_json_object(data,'$.tree_version') as bigint)                                               as tree_version
,cast(get_json_object(data,'$.context_info') as string)                                               as context_info
,cast(get_json_object(data,'$.pending_feature') as string)                                            as pending_feature
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'ldn_risk_underwriting_id_db' and base_table= 'invoke_policy_result_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__ldn_risk_underwriting_id_db__invoke_policy_result_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,trade_id                                                                                             as trade_id
,flow_no                                                                                              as flow_no
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,result_code                                                                                          as result_code
,reason                                                                                               as reason
,reject_code                                                                                          as reject_code
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,status                                                                                               as status
,req_params                                                                                           as req_params
,risk_level                                                                                           as risk_level
,limit_info                                                                                           as limit_info
,pending_code                                                                                         as pending_code
,risk_grade                                                                                           as risk_grade
,tree_id                                                                                              as tree_id
,tree_type                                                                                            as tree_type
,tree_version                                                                                         as tree_version
,context_info                                                                                         as context_info
,pending_feature                                                                                      as pending_feature
 
 ,_event
 ;