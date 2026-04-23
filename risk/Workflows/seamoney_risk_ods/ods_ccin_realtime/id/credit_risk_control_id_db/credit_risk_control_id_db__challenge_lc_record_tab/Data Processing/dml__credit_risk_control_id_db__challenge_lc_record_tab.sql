

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,flow_no                                                                                              as flow_no
,app_id                                                                                               as app_id
,req_no                                                                                               as req_no
,req_memo                                                                                             as req_memo
,platform_type                                                                                        as platform_type
,platform_user_id                                                                                     as platform_user_id
,app_fe_url                                                                                           as app_fe_url
,app_notify_url                                                                                       as app_notify_url
,lc_data                                                                                              as lc_data
,lc_images                                                                                            as lc_images
,lc_result                                                                                            as lc_result
,anti_spoofing_result                                                                                 as anti_spoofing_result
,anti_spoofing_info                                                                                   as anti_spoofing_info
,result                                                                                               as result
,status                                                                                               as status
,description                                                                                          as description
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,lc_module_result                                                                                     as lc_module_result
,lc_data_encrypt                                                                                      as lc_data_encrypt
,req_memo_encrypt                                                                                     as req_memo_encrypt
,original_platform_type                                                                               as original_platform_type
,shopeepay_user_id                                                                                    as shopeepay_user_id
 
,_event
 from(
    select 
 id                                                                                                   as id
,flow_no                                                                                              as flow_no
,app_id                                                                                               as app_id
,req_no                                                                                               as req_no
,req_memo                                                                                             as req_memo
,platform_type                                                                                        as platform_type
,platform_user_id                                                                                     as platform_user_id
,app_fe_url                                                                                           as app_fe_url
,app_notify_url                                                                                       as app_notify_url
,lc_data                                                                                              as lc_data
,lc_images                                                                                            as lc_images
,lc_result                                                                                            as lc_result
,anti_spoofing_result                                                                                 as anti_spoofing_result
,anti_spoofing_info                                                                                   as anti_spoofing_info
,result                                                                                               as result
,status                                                                                               as status
,description                                                                                          as description
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,lc_module_result                                                                                     as lc_module_result
,lc_data_encrypt                                                                                      as lc_data_encrypt
,req_memo_encrypt                                                                                     as req_memo_encrypt
,original_platform_type                                                                               as original_platform_type
,shopeepay_user_id                                                                                    as shopeepay_user_id
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,flow_no                                                                                              as flow_no
,app_id                                                                                               as app_id
,req_no                                                                                               as req_no
,req_memo                                                                                             as req_memo
,platform_type                                                                                        as platform_type
,platform_user_id                                                                                     as platform_user_id
,app_fe_url                                                                                           as app_fe_url
,app_notify_url                                                                                       as app_notify_url
,lc_data                                                                                              as lc_data
,lc_images                                                                                            as lc_images
,lc_result                                                                                            as lc_result
,anti_spoofing_result                                                                                 as anti_spoofing_result
,anti_spoofing_info                                                                                   as anti_spoofing_info
,result                                                                                               as result
,status                                                                                               as status
,description                                                                                          as description
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,lc_module_result                                                                                     as lc_module_result
,lc_data_encrypt                                                                                      as lc_data_encrypt
,req_memo_encrypt                                                                                     as req_memo_encrypt
,original_platform_type                                                                               as original_platform_type
,shopeepay_user_id                                                                                    as shopeepay_user_id
 
 ,concat_ws('_',nvl(flow_no,''),nvl(app_id,''),nvl(req_no,''))                                         as on_keys_conds
,_event
        from risk.ods__credit_risk_control_id_db__challenge_lc_record_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.flow_no') as string)                                                    as flow_no
,cast(get_json_object(data,'$.app_id') as string)                                                     as app_id
,cast(get_json_object(data,'$.req_no') as string)                                                     as req_no
,cast(get_json_object(data,'$.req_memo') as string)                                                   as req_memo
,cast(get_json_object(data,'$.platform_type') as bigint)                                              as platform_type
,cast(get_json_object(data,'$.platform_user_id') as string)                                           as platform_user_id
,cast(get_json_object(data,'$.app_fe_url') as string)                                                 as app_fe_url
,cast(get_json_object(data,'$.app_notify_url') as string)                                             as app_notify_url
,cast(get_json_object(data,'$.lc_data') as string)                                                    as lc_data
,cast(get_json_object(data,'$.lc_images') as string)                                                  as lc_images
,cast(get_json_object(data,'$.lc_result') as bigint)                                                  as lc_result
,cast(get_json_object(data,'$.anti_spoofing_result') as bigint)                                       as anti_spoofing_result
,cast(get_json_object(data,'$.anti_spoofing_info') as string)                                         as anti_spoofing_info
,cast(get_json_object(data,'$.result') as bigint)                                                     as result
,cast(get_json_object(data,'$.status') as bigint)                                                     as status
,cast(get_json_object(data,'$.description') as string)                                                as description
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.lc_module_result') as string)                                           as lc_module_result
,cast(get_json_object(data,'$.lc_data_encrypt') as string)                                            as lc_data_encrypt
,cast(get_json_object(data,'$.req_memo_encrypt') as string)                                           as req_memo_encrypt
,cast(get_json_object(data,'$.original_platform_type') as bigint)                                     as original_platform_type
,cast(get_json_object(data,'$.shopeepay_user_id') as string)                                          as shopeepay_user_id
 
 ,concat_ws('_',nvl(get_json_object(data,'$.flow_no'),''),nvl(get_json_object(data,'$.app_id'),''),nvl(get_json_object(data,'$.req_no'),'')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_control_id_db' and base_table= 'challenge_lc_record_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete' 
)
insert overwrite table risk.ods__credit_risk_control_id_db__challenge_lc_record_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,flow_no                                                                                              as flow_no
,app_id                                                                                               as app_id
,req_no                                                                                               as req_no
,req_memo                                                                                             as req_memo
,platform_type                                                                                        as platform_type
,platform_user_id                                                                                     as platform_user_id
,app_fe_url                                                                                           as app_fe_url
,app_notify_url                                                                                       as app_notify_url
,lc_data                                                                                              as lc_data
,lc_images                                                                                            as lc_images
,lc_result                                                                                            as lc_result
,anti_spoofing_result                                                                                 as anti_spoofing_result
,anti_spoofing_info                                                                                   as anti_spoofing_info
,result                                                                                               as result
,status                                                                                               as status
,description                                                                                          as description
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,lc_module_result                                                                                     as lc_module_result
,lc_data_encrypt                                                                                      as lc_data_encrypt
,req_memo_encrypt                                                                                     as req_memo_encrypt
,original_platform_type                                                                               as original_platform_type
,shopeepay_user_id                                                                                    as shopeepay_user_id
 
 ,_event
 ;