

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 hid                                                                                                  as hid
,id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,term                                                                                                 as term
,interest_rate                                                                                        as interest_rate
,status                                                                                               as status
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,operator                                                                                             as operator
,notes                                                                                                as notes
 
,_event
 from(
    select 
 hid                                                                                                  as hid
,id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,term                                                                                                 as term
,interest_rate                                                                                        as interest_rate
,status                                                                                               as status
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,operator                                                                                             as operator
,notes                                                                                                as notes
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 hid                                                                                                  as hid
,id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,term                                                                                                 as term
,interest_rate                                                                                        as interest_rate
,status                                                                                               as status
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,operator                                                                                             as operator
,notes                                                                                                as notes
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),hid)           as on_keys_conds
,_event
        from risk.ods__ldn_risk_underwriting_id_db__cashloan_instalment_history_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.hid') as bigint)                                                        as hid
,cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.platform_user_id') as string)                                           as platform_user_id
,cast(get_json_object(data,'$.platform_type') as bigint)                                              as platform_type
,cast(get_json_object(data,'$.term') as bigint)                                                       as term
,cast(get_json_object(data,'$.interest_rate') as bigint)                                              as interest_rate
,cast(get_json_object(data,'$.status') as bigint)                                                     as status
,cast(get_json_object(data,'$.version') as bigint)                                                    as version
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.operator') as string)                                                   as operator
,cast(get_json_object(data,'$.notes') as string)                                                      as notes
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.hid')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'ldn_risk_underwriting_id_db' and base_table= 'cashloan_instalment_history_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__ldn_risk_underwriting_id_db__cashloan_instalment_history_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 hid                                                                                                  as hid
,id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,term                                                                                                 as term
,interest_rate                                                                                        as interest_rate
,status                                                                                               as status
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,operator                                                                                             as operator
,notes                                                                                                as notes
 
 ,_event
 ;