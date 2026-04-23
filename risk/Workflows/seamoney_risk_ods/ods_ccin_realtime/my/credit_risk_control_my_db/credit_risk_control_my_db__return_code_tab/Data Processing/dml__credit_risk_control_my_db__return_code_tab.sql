

refresh table risk.ccin_multi_realtime_binlog_for_my;

from (
    select 
 id                                                                                                   as id
,code_type                                                                                            as code_type
,code_category                                                                                        as code_category
,code_sub_category                                                                                    as code_sub_category
,code_name                                                                                            as code_name
,description                                                                                          as description
,code_status                                                                                          as code_status
,operator                                                                                             as operator
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
,_event
 from(
    select 
 id                                                                                                   as id
,code_type                                                                                            as code_type
,code_category                                                                                        as code_category
,code_sub_category                                                                                    as code_sub_category
,code_name                                                                                            as code_name
,description                                                                                          as description
,code_status                                                                                          as code_status
,operator                                                                                             as operator
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,code_type                                                                                            as code_type
,code_category                                                                                        as code_category
,code_sub_category                                                                                    as code_sub_category
,code_name                                                                                            as code_name
,description                                                                                          as description
,code_status                                                                                          as code_status
,operator                                                                                             as operator
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_my_db__return_code_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.code_type') as bigint)                                                  as code_type
,cast(get_json_object(data,'$.code_category') as bigint)                                              as code_category
,cast(get_json_object(data,'$.code_sub_category') as string)                                          as code_sub_category
,cast(get_json_object(data,'$.code_name') as string)                                                  as code_name
,cast(get_json_object(data,'$.description') as string)                                                as description
,cast(get_json_object(data,'$.code_status') as bigint)                                                as code_status
,cast(get_json_object(data,'$.operator') as string)                                                   as operator
,cast(get_json_object(data,'$.version') as bigint)                                                    as version
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_my 
        where base_database = 'credit_risk_control_my_db' and base_table= 'return_code_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 0 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_control_my_db__return_code_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,code_type                                                                                            as code_type
,code_category                                                                                        as code_category
,code_sub_category                                                                                    as code_sub_category
,code_name                                                                                            as code_name
,description                                                                                          as description
,code_status                                                                                          as code_status
,operator                                                                                             as operator
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,_event
 ;