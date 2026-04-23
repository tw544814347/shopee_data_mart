

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,template_name                                                                                        as template_name
,description                                                                                          as description
,params                                                                                               as params
,execute_engine                                                                                       as execute_engine
,template_script                                                                                      as template_script
,tags                                                                                                 as tags
,rendering_template                                                                                   as rendering_template
,version                                                                                              as version
,status                                                                                               as status
,version_status                                                                                       as version_status
,fit_scope                                                                                            as fit_scope
,return_type                                                                                          as return_type
,creator                                                                                              as creator
,updater                                                                                              as updater
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,default_value                                                                                        as default_value
,region                                                                                               as region
 
,_event
 from(
    select 
 id                                                                                                   as id
,template_name                                                                                        as template_name
,description                                                                                          as description
,params                                                                                               as params
,execute_engine                                                                                       as execute_engine
,template_script                                                                                      as template_script
,tags                                                                                                 as tags
,rendering_template                                                                                   as rendering_template
,version                                                                                              as version
,status                                                                                               as status
,version_status                                                                                       as version_status
,fit_scope                                                                                            as fit_scope
,return_type                                                                                          as return_type
,creator                                                                                              as creator
,updater                                                                                              as updater
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,default_value                                                                                        as default_value
,region                                                                                               as region
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,template_name                                                                                        as template_name
,description                                                                                          as description
,params                                                                                               as params
,execute_engine                                                                                       as execute_engine
,template_script                                                                                      as template_script
,tags                                                                                                 as tags
,rendering_template                                                                                   as rendering_template
,version                                                                                              as version
,status                                                                                               as status
,version_status                                                                                       as version_status
,fit_scope                                                                                            as fit_scope
,return_type                                                                                          as return_type
,creator                                                                                              as creator
,updater                                                                                              as updater
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,default_value                                                                                        as default_value
,region                                                                                               as region
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_feature_id_db__risk_feature_template_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id
,cast(get_json_object(data,'$.template_name') as string)                                              as template_name
,cast(get_json_object(data,'$.description') as string)                                                as description
,cast(get_json_object(data,'$.params') as string)                                                     as params
,cast(get_json_object(data,'$.execute_engine') as string)                                             as execute_engine
,cast(get_json_object(data,'$.template_script') as string)                                            as template_script
,cast(get_json_object(data,'$.tags') as string)                                                       as tags
,cast(get_json_object(data,'$.rendering_template') as string)                                         as rendering_template
,cast(get_json_object(data,'$.version') as bigint)                                                    as version
,cast(get_json_object(data,'$.status') as bigint)                                                     as status
,cast(get_json_object(data,'$.version_status') as bigint)                                             as version_status
,cast(get_json_object(data,'$.fit_scope') as string)                                                  as fit_scope
,cast(get_json_object(data,'$.return_type') as bigint)                                                as return_type
,cast(get_json_object(data,'$.creator') as string)                                                    as creator
,cast(get_json_object(data,'$.updater') as string)                                                    as updater
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.default_value') as string)                                              as default_value
,cast(get_json_object(data,'$.region') as string)                                                     as region
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_feature_id_db' and base_table= 'risk_feature_template_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_feature_id_db__risk_feature_template_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,template_name                                                                                        as template_name
,description                                                                                          as description
,params                                                                                               as params
,execute_engine                                                                                       as execute_engine
,template_script                                                                                      as template_script
,tags                                                                                                 as tags
,rendering_template                                                                                   as rendering_template
,version                                                                                              as version
,status                                                                                               as status
,version_status                                                                                       as version_status
,fit_scope                                                                                            as fit_scope
,return_type                                                                                          as return_type
,creator                                                                                              as creator
,updater                                                                                              as updater
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,default_value                                                                                        as default_value
,region                                                                                               as region
 
 ,_event
 ;