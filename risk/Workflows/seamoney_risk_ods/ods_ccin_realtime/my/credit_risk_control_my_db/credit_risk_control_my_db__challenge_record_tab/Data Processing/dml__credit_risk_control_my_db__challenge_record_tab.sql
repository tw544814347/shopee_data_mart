

refresh table risk.ccin_multi_realtime_binlog_for_my;

from (
    select 
 id                                                                                                   as id
,biz                                                                                                  as biz
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,event_code                                                                                           as event_code
,req_no                                                                                               as req_no
,challenge_type                                                                                       as challenge_type
,req_memo                                                                                             as req_memo
,platform_type                                                                                        as platform_type
,platform_user_id                                                                                     as platform_user_id
,jumpback_url                                                                                         as jumpback_url
,callback_url                                                                                         as callback_url
,challenge_data                                                                                       as challenge_data
,timeout_seconds                                                                                      as timeout_seconds
,result                                                                                               as result
,record_status                                                                                        as record_status
,extra_info                                                                                           as extra_info
,failure_info                                                                                         as failure_info
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,shopeepay_user_id                                                                                    as shopeepay_user_id
,extension                                                                                            as extension
,query_no                                                                                             as query_no
,challenge_data_encrypt                                                                               as challenge_data_encrypt
,original_platform_type                                                                               as original_platform_type
,archive_batch_no                                                                                     as archive_batch_no
 
,_event
 from(
    select 
 id                                                                                                   as id
,biz                                                                                                  as biz
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,event_code                                                                                           as event_code
,req_no                                                                                               as req_no
,challenge_type                                                                                       as challenge_type
,req_memo                                                                                             as req_memo
,platform_type                                                                                        as platform_type
,platform_user_id                                                                                     as platform_user_id
,jumpback_url                                                                                         as jumpback_url
,callback_url                                                                                         as callback_url
,challenge_data                                                                                       as challenge_data
,timeout_seconds                                                                                      as timeout_seconds
,result                                                                                               as result
,record_status                                                                                        as record_status
,extra_info                                                                                           as extra_info
,failure_info                                                                                         as failure_info
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,shopeepay_user_id                                                                                    as shopeepay_user_id
,extension                                                                                            as extension
,query_no                                                                                             as query_no
,challenge_data_encrypt                                                                               as challenge_data_encrypt
,original_platform_type                                                                               as original_platform_type
,archive_batch_no                                                                                     as archive_batch_no
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,biz                                                                                                  as biz
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,event_code                                                                                           as event_code
,req_no                                                                                               as req_no
,challenge_type                                                                                       as challenge_type
,req_memo                                                                                             as req_memo
,platform_type                                                                                        as platform_type
,platform_user_id                                                                                     as platform_user_id
,jumpback_url                                                                                         as jumpback_url
,callback_url                                                                                         as callback_url
,challenge_data                                                                                       as challenge_data
,timeout_seconds                                                                                      as timeout_seconds
,result                                                                                               as result
,record_status                                                                                        as record_status
,extra_info                                                                                           as extra_info
,failure_info                                                                                         as failure_info
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,shopeepay_user_id                                                                                    as shopeepay_user_id
,extension                                                                                            as extension
,query_no                                                                                             as query_no
,challenge_data_encrypt                                                                               as challenge_data_encrypt
,original_platform_type                                                                               as original_platform_type
,archive_batch_no                                                                                     as archive_batch_no
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_my_db__challenge_record_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.biz') as string)                                                        as biz
,cast(get_json_object(data,'$.app_id') as string)                                                     as app_id
,cast(get_json_object(data,'$.scene_id') as bigint)                                                   as scene_id
,cast(get_json_object(data,'$.event_code') as string)                                                 as event_code
,cast(get_json_object(data,'$.req_no') as string)                                                     as req_no
,cast(get_json_object(data,'$.challenge_type') as bigint)                                             as challenge_type
,cast(get_json_object(data,'$.req_memo') as string)                                                   as req_memo
,cast(get_json_object(data,'$.platform_type') as bigint)                                              as platform_type
,cast(get_json_object(data,'$.platform_user_id') as string)                                           as platform_user_id
,cast(get_json_object(data,'$.jumpback_url') as string)                                               as jumpback_url
,cast(get_json_object(data,'$.callback_url') as string)                                               as callback_url
,cast(get_json_object(data,'$.challenge_data') as string)                                             as challenge_data
,cast(get_json_object(data,'$.timeout_seconds') as bigint)                                            as timeout_seconds
,cast(get_json_object(data,'$.result') as bigint)                                                     as result
,cast(get_json_object(data,'$.record_status') as bigint)                                              as record_status
,cast(get_json_object(data,'$.extra_info') as string)                                                 as extra_info
,cast(get_json_object(data,'$.failure_info') as string)                                               as failure_info
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.shopeepay_user_id') as string)                                          as shopeepay_user_id
,cast(get_json_object(data,'$.extension') as string)                                                  as extension
,cast(get_json_object(data,'$.query_no') as string)                                                   as query_no
,cast(get_json_object(data,'$.challenge_data_encrypt') as string)                                     as challenge_data_encrypt
,cast(get_json_object(data,'$.original_platform_type') as bigint)                                     as original_platform_type
,cast(get_json_object(data,'$.archive_batch_no') as string)                                           as archive_batch_no
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_my 
        where base_database = 'credit_risk_control_my_db' and base_table= 'challenge_record_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 0 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and (nvl(get_json_object(_event,'$.type'),'') != 'delete' 
or (nvl(get_json_object(_event,'$.type'),'') = 'delete' and archive_batch_no is not null and archive_batch_no !='') 
) 
)
insert overwrite table risk.ods__credit_risk_control_my_db__challenge_record_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,biz                                                                                                  as biz
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,event_code                                                                                           as event_code
,req_no                                                                                               as req_no
,challenge_type                                                                                       as challenge_type
,req_memo                                                                                             as req_memo
,platform_type                                                                                        as platform_type
,platform_user_id                                                                                     as platform_user_id
,jumpback_url                                                                                         as jumpback_url
,callback_url                                                                                         as callback_url
,challenge_data                                                                                       as challenge_data
,timeout_seconds                                                                                      as timeout_seconds
,result                                                                                               as result
,record_status                                                                                        as record_status
,extra_info                                                                                           as extra_info
,failure_info                                                                                         as failure_info
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,shopeepay_user_id                                                                                    as shopeepay_user_id
,extension                                                                                            as extension
,query_no                                                                                             as query_no
,challenge_data_encrypt                                                                               as challenge_data_encrypt
,original_platform_type                                                                               as original_platform_type
,archive_batch_no                                                                                     as archive_batch_no
 
 ,_event
 ;