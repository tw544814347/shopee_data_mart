

refresh table risk.ccin_multi_realtime_binlog_for_my;

from (
    select 
 id                                                                                                   as id
,related_case_id                                                                                      as related_case_id
,related_task_id                                                                                      as related_task_id
,related_rule_id                                                                                      as related_rule_id
,transaction_list                                                                                     as transaction_list
,status                                                                                               as status
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,related_organized_case_uuid                                                                          as related_organized_case_uuid
,meta_info                                                                                            as meta_info
 
,_event
 from(
    select 
 id                                                                                                   as id
,related_case_id                                                                                      as related_case_id
,related_task_id                                                                                      as related_task_id
,related_rule_id                                                                                      as related_rule_id
,transaction_list                                                                                     as transaction_list
,status                                                                                               as status
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,related_organized_case_uuid                                                                          as related_organized_case_uuid
,meta_info                                                                                            as meta_info
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,related_case_id                                                                                      as related_case_id
,related_task_id                                                                                      as related_task_id
,related_rule_id                                                                                      as related_rule_id
,transaction_list                                                                                     as transaction_list
,status                                                                                               as status
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,related_organized_case_uuid                                                                          as related_organized_case_uuid
,meta_info                                                                                            as meta_info
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__shopeepay_risk_aml_my_db__aml_alert_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.related_case_id') as bigint)                                            as related_case_id
,cast(get_json_object(data,'$.related_task_id') as bigint)                                            as related_task_id
,cast(get_json_object(data,'$.related_rule_id') as bigint)                                            as related_rule_id
,cast(get_json_object(data,'$.transaction_list') as string)                                           as transaction_list
,cast(get_json_object(data,'$.status') as bigint)                                                     as status
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.related_organized_case_uuid') as string)                                as related_organized_case_uuid
,cast(get_json_object(data,'$.meta_info') as string)                                                  as meta_info
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_my 
        where base_database = 'shopeepay_risk_aml_my_db' and base_table= 'aml_alert_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 0 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__shopeepay_risk_aml_my_db__aml_alert_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,related_case_id                                                                                      as related_case_id
,related_task_id                                                                                      as related_task_id
,related_rule_id                                                                                      as related_rule_id
,transaction_list                                                                                     as transaction_list
,status                                                                                               as status
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,related_organized_case_uuid                                                                          as related_organized_case_uuid
,meta_info                                                                                            as meta_info
 
 ,_event
 ;