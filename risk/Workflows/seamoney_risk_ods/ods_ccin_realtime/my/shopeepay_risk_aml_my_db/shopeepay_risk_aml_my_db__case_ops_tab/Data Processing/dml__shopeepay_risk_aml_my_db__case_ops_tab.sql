

refresh table risk.ccin_multi_realtime_binlog_for_my;

from (
    select 
 id                                                                                                   as id
,case_uuid                                                                                            as case_uuid
,operator                                                                                             as operator
,content                                                                                              as content
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,notes                                                                                                as notes
,operation_type                                                                                       as operation_type
,start_time                                                                                           as start_time
,role                                                                                                 as role
,archive_batch_no                                                                                     as archive_batch_no
 
,_event
 from(
    select 
 id                                                                                                   as id
,case_uuid                                                                                            as case_uuid
,operator                                                                                             as operator
,content                                                                                              as content
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,notes                                                                                                as notes
,operation_type                                                                                       as operation_type
,start_time                                                                                           as start_time
,role                                                                                                 as role
,archive_batch_no                                                                                     as archive_batch_no
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,case_uuid                                                                                            as case_uuid
,operator                                                                                             as operator
,content                                                                                              as content
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,notes                                                                                                as notes
,operation_type                                                                                       as operation_type
,start_time                                                                                           as start_time
,role                                                                                                 as role
,archive_batch_no                                                                                     as archive_batch_no
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__shopeepay_risk_aml_my_db__case_ops_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.case_uuid') as string)                                                  as case_uuid
,cast(get_json_object(data,'$.operator') as string)                                                   as operator
,cast(get_json_object(data,'$.content') as string)                                                    as content
,cast(get_json_object(data,'$.version') as bigint)                                                    as version
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.notes') as string)                                                      as notes
,cast(get_json_object(data,'$.operation_type') as bigint)                                             as operation_type
,cast(get_json_object(data,'$.start_time') as bigint)                                                 as start_time
,cast(get_json_object(data,'$.role') as string)                                                       as role
,cast(get_json_object(data,'$.archive_batch_no') as string)                                           as archive_batch_no
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_my 
        where base_database = 'shopeepay_risk_aml_my_db' and base_table= 'case_ops_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 0 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and (nvl(get_json_object(_event,'$.type'),'') != 'delete' 
or (nvl(get_json_object(_event,'$.type'),'') = 'delete' and archive_batch_no is not null and archive_batch_no !='') 
) 
)
insert overwrite table risk.ods__shopeepay_risk_aml_my_db__case_ops_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,case_uuid                                                                                            as case_uuid
,operator                                                                                             as operator
,content                                                                                              as content
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,notes                                                                                                as notes
,operation_type                                                                                       as operation_type
,start_time                                                                                           as start_time
,role                                                                                                 as role
,archive_batch_no                                                                                     as archive_batch_no
 
 ,_event
 ;