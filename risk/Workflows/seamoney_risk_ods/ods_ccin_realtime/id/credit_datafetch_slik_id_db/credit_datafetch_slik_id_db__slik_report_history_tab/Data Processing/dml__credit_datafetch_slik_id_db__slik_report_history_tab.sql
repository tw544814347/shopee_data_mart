

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 report_id                                                                                            as report_id
,ktp                                                                                                  as ktp
,user_reference_code                                                                                  as user_reference_code
,file_exist                                                                                           as file_exist
,file                                                                                                 as file
,result                                                                                               as result
,file_path                                                                                            as file_path
,decode_file_path                                                                                     as decode_file_path
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,flow_no                                                                                              as flow_no
,app_key                                                                                              as app_key
,crawl_account                                                                                        as crawl_account
,approve_account                                                                                      as approve_account
,crawl_time                                                                                           as crawl_time
,approve_time                                                                                         as approve_time
,file_reference_code                                                                                  as file_reference_code
 
,_event
 from(
    select 
 report_id                                                                                            as report_id
,ktp                                                                                                  as ktp
,user_reference_code                                                                                  as user_reference_code
,file_exist                                                                                           as file_exist
,file                                                                                                 as file
,result                                                                                               as result
,file_path                                                                                            as file_path
,decode_file_path                                                                                     as decode_file_path
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,flow_no                                                                                              as flow_no
,app_key                                                                                              as app_key
,crawl_account                                                                                        as crawl_account
,approve_account                                                                                      as approve_account
,crawl_time                                                                                           as crawl_time
,approve_time                                                                                         as approve_time
,file_reference_code                                                                                  as file_reference_code
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 report_id                                                                                            as report_id
,ktp                                                                                                  as ktp
,user_reference_code                                                                                  as user_reference_code
,file_exist                                                                                           as file_exist
,file                                                                                                 as file
,result                                                                                               as result
,file_path                                                                                            as file_path
,decode_file_path                                                                                     as decode_file_path
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,flow_no                                                                                              as flow_no
,app_key                                                                                              as app_key
,crawl_account                                                                                        as crawl_account
,approve_account                                                                                      as approve_account
,crawl_time                                                                                           as crawl_time
,approve_time                                                                                         as approve_time
,file_reference_code                                                                                  as file_reference_code
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),report_id)     as on_keys_conds
,_event
        from risk.ods__credit_datafetch_slik_id_db__slik_report_history_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.report_id') as bigint)                                                  as report_id
,cast(get_json_object(data,'$.ktp') as string)                                                        as ktp
,cast(get_json_object(data,'$.user_reference_code') as string)                                        as user_reference_code
,cast(get_json_object(data,'$.file_exist') as integer)                                                as file_exist
,cast(get_json_object(data,'$.file') as string)                                                       as file
,cast(get_json_object(data,'$.result') as string)                                                     as result
,cast(get_json_object(data,'$.file_path') as string)                                                  as file_path
,cast(get_json_object(data,'$.decode_file_path') as string)                                           as decode_file_path
,cast(get_json_object(data,'$.create_time') as string)                                                as create_time
,cast(get_json_object(data,'$.update_time') as string)                                                as update_time
,cast(get_json_object(data,'$.flow_no') as string)                                                    as flow_no
,cast(get_json_object(data,'$.app_key') as string)                                                    as app_key
,cast(get_json_object(data,'$.crawl_account') as string)                                              as crawl_account
,cast(get_json_object(data,'$.approve_account') as string)                                            as approve_account
,cast(get_json_object(data,'$.crawl_time') as string)                                                 as crawl_time
,cast(get_json_object(data,'$.approve_time') as string)                                               as approve_time
,cast(get_json_object(data,'$.file_reference_code') as string)                                        as file_reference_code
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.report_id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_datafetch_slik_id_db' and base_table= 'slik_report_history_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(unix_timestamp(get_json_object(data,'$.update_time')) + 28800 - 3600 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete' 
)
insert overwrite table risk.ods__credit_datafetch_slik_id_db__slik_report_history_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 report_id                                                                                            as report_id
,ktp                                                                                                  as ktp
,user_reference_code                                                                                  as user_reference_code
,file_exist                                                                                           as file_exist
,file                                                                                                 as file
,result                                                                                               as result
,file_path                                                                                            as file_path
,decode_file_path                                                                                     as decode_file_path
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,flow_no                                                                                              as flow_no
,app_key                                                                                              as app_key
,crawl_account                                                                                        as crawl_account
,approve_account                                                                                      as approve_account
,crawl_time                                                                                           as crawl_time
,approve_time                                                                                         as approve_time
,file_reference_code                                                                                  as file_reference_code
 
 ,_event
 ;