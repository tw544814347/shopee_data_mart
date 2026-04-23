

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,ori_id                                                                                               as ori_id
,metric_name                                                                                          as metric_name
,metric_script                                                                                        as metric_script
,extention                                                                                            as extention
,func_id                                                                                              as func_id
,func_param                                                                                           as func_param
,return_type                                                                                          as return_type
,version                                                                                              as version
,status                                                                                               as status
,description                                                                                          as description
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,category                                                                                             as category
,version_status                                                                                       as version_status
,data_src                                                                                             as data_src
,error_default                                                                                        as error_default
,show_content                                                                                         as show_content
,fit_scope                                                                                            as fit_scope
,metric_name_with_version                                                                             as metric_name_with_version
 
,_event
 from(
    select 
 id                                                                                                   as id
,ori_id                                                                                               as ori_id
,metric_name                                                                                          as metric_name
,metric_script                                                                                        as metric_script
,extention                                                                                            as extention
,func_id                                                                                              as func_id
,func_param                                                                                           as func_param
,return_type                                                                                          as return_type
,version                                                                                              as version
,status                                                                                               as status
,description                                                                                          as description
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,category                                                                                             as category
,version_status                                                                                       as version_status
,data_src                                                                                             as data_src
,error_default                                                                                        as error_default
,show_content                                                                                         as show_content
,fit_scope                                                                                            as fit_scope
,metric_name_with_version                                                                             as metric_name_with_version
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,ori_id                                                                                               as ori_id
,metric_name                                                                                          as metric_name
,metric_script                                                                                        as metric_script
,extention                                                                                            as extention
,func_id                                                                                              as func_id
,func_param                                                                                           as func_param
,return_type                                                                                          as return_type
,version                                                                                              as version
,status                                                                                               as status
,description                                                                                          as description
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,category                                                                                             as category
,version_status                                                                                       as version_status
,data_src                                                                                             as data_src
,error_default                                                                                        as error_default
,show_content                                                                                         as show_content
,fit_scope                                                                                            as fit_scope
,metric_name_with_version                                                                             as metric_name_with_version
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_id_db__strategy_metric_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.ori_id') as bigint)                                                     as ori_id
,cast(get_json_object(data,'$.metric_name') as string)                                                as metric_name
,cast(get_json_object(data,'$.metric_script') as string)                                              as metric_script
,cast(get_json_object(data,'$.extention') as string)                                                  as extention
,cast(get_json_object(data,'$.func_id') as bigint)                                                    as func_id
,cast(get_json_object(data,'$.func_param') as string)                                                 as func_param
,cast(get_json_object(data,'$.return_type') as bigint)                                                as return_type
,cast(get_json_object(data,'$.version') as bigint)                                                    as version
,cast(get_json_object(data,'$.status') as bigint)                                                     as status
,cast(get_json_object(data,'$.description') as string)                                                as description
,cast(get_json_object(data,'$.creator') as string)                                                    as creator
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.category') as bigint)                                                   as category
,cast(get_json_object(data,'$.version_status') as bigint)                                             as version_status
,cast(get_json_object(data,'$.data_src') as bigint)                                                   as data_src
,cast(get_json_object(data,'$.error_default') as string)                                              as error_default
,cast(get_json_object(data,'$.show_content') as string)                                               as show_content
,cast(get_json_object(data,'$.fit_scope') as string)                                                  as fit_scope
,cast(get_json_object(data,'$.metric_name_with_version') as string)                                   as metric_name_with_version
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_control_id_db' and base_table= 'strategy_metric_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_control_id_db__strategy_metric_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,ori_id                                                                                               as ori_id
,metric_name                                                                                          as metric_name
,metric_script                                                                                        as metric_script
,extention                                                                                            as extention
,func_id                                                                                              as func_id
,func_param                                                                                           as func_param
,return_type                                                                                          as return_type
,version                                                                                              as version
,status                                                                                               as status
,description                                                                                          as description
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,category                                                                                             as category
,version_status                                                                                       as version_status
,data_src                                                                                             as data_src
,error_default                                                                                        as error_default
,show_content                                                                                         as show_content
,fit_scope                                                                                            as fit_scope
,metric_name_with_version                                                                             as metric_name_with_version
 
 ,_event
 ;