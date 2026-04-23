

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,file_id                                                                                              as file_id
,file_name                                                                                            as file_name
,file_fingerprint                                                                                     as file_fingerprint
,ser_content                                                                                          as ser_content
,create_time                                                                                          as create_time
,create_user                                                                                          as create_user
 
,_event
 from(
    select 
 id                                                                                                   as id
,file_id                                                                                              as file_id
,file_name                                                                                            as file_name
,file_fingerprint                                                                                     as file_fingerprint
,ser_content                                                                                          as ser_content
,create_time                                                                                          as create_time
,create_user                                                                                          as create_user
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,file_id                                                                                              as file_id
,file_name                                                                                            as file_name
,file_fingerprint                                                                                     as file_fingerprint
,ser_content                                                                                          as ser_content
,create_time                                                                                          as create_time
,create_user                                                                                          as create_user
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_id_db__ser_file_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.file_id') as string)                                                    as file_id
,cast(get_json_object(data,'$.file_name') as string)                                                  as file_name
,cast(get_json_object(data,'$.file_fingerprint') as string)                                           as file_fingerprint
,cast(get_json_object(data,'$.ser_content') as string)                                                as ser_content
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.create_user') as string)                                                as create_user
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_control_id_db' and base_table= 'ser_file_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.create_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_control_id_db__ser_file_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,file_id                                                                                              as file_id
,file_name                                                                                            as file_name
,file_fingerprint                                                                                     as file_fingerprint
,ser_content                                                                                          as ser_content
,create_time                                                                                          as create_time
,create_user                                                                                          as create_user
 
 ,_event
 ;