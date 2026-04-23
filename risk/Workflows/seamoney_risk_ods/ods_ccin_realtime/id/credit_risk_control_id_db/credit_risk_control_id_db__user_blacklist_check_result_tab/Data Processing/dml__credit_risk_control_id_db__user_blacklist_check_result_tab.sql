

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,flow_no                                                                                              as flow_no
,id_number                                                                                            as id_number
,response_status                                                                                      as response_status
,response_time                                                                                        as response_time
,transaction_id                                                                                       as transaction_id
,pricing_strategy                                                                                     as pricing_strategy
,recommendation                                                                                       as recommendation
,default_list_result                                                                                  as default_list_result
,extra                                                                                                as extra
,is_deleted                                                                                           as is_deleted
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
,_event
 from(
    select 
 id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,flow_no                                                                                              as flow_no
,id_number                                                                                            as id_number
,response_status                                                                                      as response_status
,response_time                                                                                        as response_time
,transaction_id                                                                                       as transaction_id
,pricing_strategy                                                                                     as pricing_strategy
,recommendation                                                                                       as recommendation
,default_list_result                                                                                  as default_list_result
,extra                                                                                                as extra
,is_deleted                                                                                           as is_deleted
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,flow_no                                                                                              as flow_no
,id_number                                                                                            as id_number
,response_status                                                                                      as response_status
,response_time                                                                                        as response_time
,transaction_id                                                                                       as transaction_id
,pricing_strategy                                                                                     as pricing_strategy
,recommendation                                                                                       as recommendation
,default_list_result                                                                                  as default_list_result
,extra                                                                                                as extra
,is_deleted                                                                                           as is_deleted
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_id_db__user_blacklist_check_result_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id
,cast(get_json_object(data,'$.platform_user_id') as string)                                           as platform_user_id
,cast(get_json_object(data,'$.platform_type') as bigint)                                              as platform_type
,cast(get_json_object(data,'$.flow_no') as string)                                                    as flow_no
,cast(get_json_object(data,'$.id_number') as string)                                                  as id_number
,cast(get_json_object(data,'$.response_status') as string)                                            as response_status
,cast(get_json_object(data,'$.response_time') as bigint)                                              as response_time
,cast(get_json_object(data,'$.transaction_id') as string)                                             as transaction_id
,cast(get_json_object(data,'$.pricing_strategy') as string)                                           as pricing_strategy
,cast(get_json_object(data,'$.recommendation') as string)                                             as recommendation
,cast(get_json_object(data,'$.default_list_result') as string)                                        as default_list_result
,cast(get_json_object(data,'$.extra') as string)                                                      as extra
,cast(get_json_object(data,'$.is_deleted') as bigint)                                                 as is_deleted
,cast(get_json_object(data,'$.version') as bigint)                                                    as version
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_control_id_db' and base_table= 'user_blacklist_check_result_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_control_id_db__user_blacklist_check_result_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,flow_no                                                                                              as flow_no
,id_number                                                                                            as id_number
,response_status                                                                                      as response_status
,response_time                                                                                        as response_time
,transaction_id                                                                                       as transaction_id
,pricing_strategy                                                                                     as pricing_strategy
,recommendation                                                                                       as recommendation
,default_list_result                                                                                  as default_list_result
,extra                                                                                                as extra
,is_deleted                                                                                           as is_deleted
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,_event
 ;