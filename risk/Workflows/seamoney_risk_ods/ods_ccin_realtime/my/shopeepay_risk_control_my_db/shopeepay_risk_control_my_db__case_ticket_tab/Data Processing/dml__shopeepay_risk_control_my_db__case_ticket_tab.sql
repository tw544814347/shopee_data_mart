

refresh table risk.ccin_multi_realtime_binlog_for_my;

from (
    select 
 id                                                                                                   as id
,ticket_id                                                                                            as ticket_id
,user_ids                                                                                             as user_ids
,customer_issue                                                                                       as customer_issue
,channel                                                                                              as channel
,status                                                                                               as status
,case_type                                                                                            as case_type
,channel_case_id                                                                                      as channel_case_id
,investigate_record                                                                                   as investigate_record
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,creator                                                                                              as creator
,result                                                                                               as result
,assignee                                                                                             as assignee
,category                                                                                             as category
,notes                                                                                                as notes
,record_status                                                                                        as record_status
,treatment                                                                                            as treatment
,order_field                                                                                          as order_field
,priority                                                                                             as priority
,archive_batch_no                                                                                     as archive_batch_no
 
,_event
 from(
    select 
 id                                                                                                   as id
,ticket_id                                                                                            as ticket_id
,user_ids                                                                                             as user_ids
,customer_issue                                                                                       as customer_issue
,channel                                                                                              as channel
,status                                                                                               as status
,case_type                                                                                            as case_type
,channel_case_id                                                                                      as channel_case_id
,investigate_record                                                                                   as investigate_record
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,creator                                                                                              as creator
,result                                                                                               as result
,assignee                                                                                             as assignee
,category                                                                                             as category
,notes                                                                                                as notes
,record_status                                                                                        as record_status
,treatment                                                                                            as treatment
,order_field                                                                                          as order_field
,priority                                                                                             as priority
,archive_batch_no                                                                                     as archive_batch_no
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,ticket_id                                                                                            as ticket_id
,user_ids                                                                                             as user_ids
,customer_issue                                                                                       as customer_issue
,channel                                                                                              as channel
,status                                                                                               as status
,case_type                                                                                            as case_type
,channel_case_id                                                                                      as channel_case_id
,investigate_record                                                                                   as investigate_record
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,creator                                                                                              as creator
,result                                                                                               as result
,assignee                                                                                             as assignee
,category                                                                                             as category
,notes                                                                                                as notes
,record_status                                                                                        as record_status
,treatment                                                                                            as treatment
,order_field                                                                                          as order_field
,priority                                                                                             as priority
,archive_batch_no                                                                                     as archive_batch_no
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__shopeepay_risk_control_my_db__case_ticket_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.ticket_id') as string)                                                  as ticket_id
,cast(get_json_object(data,'$.user_ids') as string)                                                   as user_ids
,cast(get_json_object(data,'$.customer_issue') as string)                                             as customer_issue
,cast(get_json_object(data,'$.channel') as string)                                                    as channel
,cast(get_json_object(data,'$.status') as bigint)                                                     as status
,cast(get_json_object(data,'$.case_type') as bigint)                                                  as case_type
,cast(get_json_object(data,'$.channel_case_id') as string)                                            as channel_case_id
,cast(get_json_object(data,'$.investigate_record') as string)                                         as investigate_record
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.creator') as string)                                                    as creator
,cast(get_json_object(data,'$.result') as bigint)                                                     as result
,cast(get_json_object(data,'$.assignee') as string)                                                   as assignee
,cast(get_json_object(data,'$.category') as bigint)                                                   as category
,cast(get_json_object(data,'$.notes') as string)                                                      as notes
,cast(get_json_object(data,'$.record_status') as bigint)                                              as record_status
,cast(get_json_object(data,'$.treatment') as string)                                                  as treatment
,cast(get_json_object(data,'$.order_field') as string)                                                as order_field
,cast(get_json_object(data,'$.priority') as bigint)                                                   as priority
,cast(get_json_object(data,'$.archive_batch_no') as string)                                           as archive_batch_no
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_my 
        where base_database = 'shopeepay_risk_control_my_db' and base_table= 'case_ticket_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 0 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and (nvl(get_json_object(_event,'$.type'),'') != 'delete' 
or (nvl(get_json_object(_event,'$.type'),'') = 'delete' and archive_batch_no is not null and archive_batch_no !='') 
) 
)
insert overwrite table risk.ods__shopeepay_risk_control_my_db__case_ticket_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,ticket_id                                                                                            as ticket_id
,user_ids                                                                                             as user_ids
,customer_issue                                                                                       as customer_issue
,channel                                                                                              as channel
,status                                                                                               as status
,case_type                                                                                            as case_type
,channel_case_id                                                                                      as channel_case_id
,investigate_record                                                                                   as investigate_record
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,creator                                                                                              as creator
,result                                                                                               as result
,assignee                                                                                             as assignee
,category                                                                                             as category
,notes                                                                                                as notes
,record_status                                                                                        as record_status
,treatment                                                                                            as treatment
,order_field                                                                                          as order_field
,priority                                                                                             as priority
,archive_batch_no                                                                                     as archive_batch_no
 
 ,_event
 ;