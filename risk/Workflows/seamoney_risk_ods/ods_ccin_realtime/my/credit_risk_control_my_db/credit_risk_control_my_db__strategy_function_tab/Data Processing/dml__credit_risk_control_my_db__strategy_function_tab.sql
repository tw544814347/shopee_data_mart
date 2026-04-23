

refresh table risk.ccin_multi_realtime_binlog_for_my;

from (
    select 
 id                                                                                                   as id
,ori_id                                                                                               as ori_id
,function_name                                                                                        as function_name
,params                                                                                               as params
,function_script                                                                                      as function_script
,template                                                                                             as template
,interface                                                                                            as interface
,function_type                                                                                        as function_type
,return_type                                                                                          as return_type
,extention                                                                                            as extention
,version                                                                                              as version
,description                                                                                          as description
,status                                                                                               as status
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,version_status                                                                                       as version_status
,data_src                                                                                             as data_src
,func_real_name                                                                                       as func_real_name
,func_template                                                                                        as func_template
,func_ext_template                                                                                    as func_ext_template
,func_real_params                                                                                     as func_real_params
,fit_scope                                                                                            as fit_scope
,fit_scope_version                                                                                    as fit_scope_version
,rendering_template                                                                                   as rendering_template
 
,_event
 from(
    select 
 id                                                                                                   as id
,ori_id                                                                                               as ori_id
,function_name                                                                                        as function_name
,params                                                                                               as params
,function_script                                                                                      as function_script
,template                                                                                             as template
,interface                                                                                            as interface
,function_type                                                                                        as function_type
,return_type                                                                                          as return_type
,extention                                                                                            as extention
,version                                                                                              as version
,description                                                                                          as description
,status                                                                                               as status
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,version_status                                                                                       as version_status
,data_src                                                                                             as data_src
,func_real_name                                                                                       as func_real_name
,func_template                                                                                        as func_template
,func_ext_template                                                                                    as func_ext_template
,func_real_params                                                                                     as func_real_params
,fit_scope                                                                                            as fit_scope
,fit_scope_version                                                                                    as fit_scope_version
,rendering_template                                                                                   as rendering_template
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,ori_id                                                                                               as ori_id
,function_name                                                                                        as function_name
,params                                                                                               as params
,function_script                                                                                      as function_script
,template                                                                                             as template
,interface                                                                                            as interface
,function_type                                                                                        as function_type
,return_type                                                                                          as return_type
,extention                                                                                            as extention
,version                                                                                              as version
,description                                                                                          as description
,status                                                                                               as status
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,version_status                                                                                       as version_status
,data_src                                                                                             as data_src
,func_real_name                                                                                       as func_real_name
,func_template                                                                                        as func_template
,func_ext_template                                                                                    as func_ext_template
,func_real_params                                                                                     as func_real_params
,fit_scope                                                                                            as fit_scope
,fit_scope_version                                                                                    as fit_scope_version
,rendering_template                                                                                   as rendering_template
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_my_db__strategy_function_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.ori_id') as bigint)                                                     as ori_id
,cast(get_json_object(data,'$.function_name') as string)                                              as function_name
,cast(get_json_object(data,'$.params') as string)                                                     as params
,cast(get_json_object(data,'$.function_script') as string)                                            as function_script
,cast(get_json_object(data,'$.template') as string)                                                   as template
,cast(get_json_object(data,'$.interface') as string)                                                  as interface
,cast(get_json_object(data,'$.function_type') as bigint)                                              as function_type
,cast(get_json_object(data,'$.return_type') as bigint)                                                as return_type
,cast(get_json_object(data,'$.extention') as string)                                                  as extention
,cast(get_json_object(data,'$.version') as bigint)                                                    as version
,cast(get_json_object(data,'$.description') as string)                                                as description
,cast(get_json_object(data,'$.status') as bigint)                                                     as status
,cast(get_json_object(data,'$.creator') as string)                                                    as creator
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.version_status') as bigint)                                             as version_status
,cast(get_json_object(data,'$.data_src') as bigint)                                                   as data_src
,cast(get_json_object(data,'$.func_real_name') as string)                                             as func_real_name
,cast(get_json_object(data,'$.func_template') as string)                                              as func_template
,cast(get_json_object(data,'$.func_ext_template') as string)                                          as func_ext_template
,cast(get_json_object(data,'$.func_real_params') as string)                                           as func_real_params
,cast(get_json_object(data,'$.fit_scope') as string)                                                  as fit_scope
,cast(get_json_object(data,'$.fit_scope_version') as string)                                          as fit_scope_version
,cast(get_json_object(data,'$.rendering_template') as string)                                         as rendering_template
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_my 
        where base_database = 'credit_risk_control_my_db' and base_table= 'strategy_function_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 0 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_control_my_db__strategy_function_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,ori_id                                                                                               as ori_id
,function_name                                                                                        as function_name
,params                                                                                               as params
,function_script                                                                                      as function_script
,template                                                                                             as template
,interface                                                                                            as interface
,function_type                                                                                        as function_type
,return_type                                                                                          as return_type
,extention                                                                                            as extention
,version                                                                                              as version
,description                                                                                          as description
,status                                                                                               as status
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,version_status                                                                                       as version_status
,data_src                                                                                             as data_src
,func_real_name                                                                                       as func_real_name
,func_template                                                                                        as func_template
,func_ext_template                                                                                    as func_ext_template
,func_real_params                                                                                     as func_real_params
,fit_scope                                                                                            as fit_scope
,fit_scope_version                                                                                    as fit_scope_version
,rendering_template                                                                                   as rendering_template
 
 ,_event
 ;