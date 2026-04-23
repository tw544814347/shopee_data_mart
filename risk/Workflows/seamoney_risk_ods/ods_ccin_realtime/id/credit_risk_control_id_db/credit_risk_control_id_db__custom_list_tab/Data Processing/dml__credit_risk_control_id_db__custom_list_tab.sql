

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,list_name                                                                                            as list_name
,property                                                                                             as property
,status                                                                                               as status
,data_type                                                                                            as data_type
,list_source                                                                                          as list_source
,actions                                                                                              as actions
,de_table_name                                                                                        as de_table_name
,remark                                                                                               as remark
,description                                                                                          as description
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,category                                                                                             as category
,version                                                                                              as version
,total                                                                                                as total
,data_hash                                                                                            as data_hash
,fit_scene                                                                                            as fit_scene
,scenario_based                                                                                       as scenario_based
,screening_switch                                                                                     as screening_switch
,de_table_config                                                                                      as de_table_config
 
,_event
 from(
    select 
 id                                                                                                   as id
,list_name                                                                                            as list_name
,property                                                                                             as property
,status                                                                                               as status
,data_type                                                                                            as data_type
,list_source                                                                                          as list_source
,actions                                                                                              as actions
,de_table_name                                                                                        as de_table_name
,remark                                                                                               as remark
,description                                                                                          as description
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,category                                                                                             as category
,version                                                                                              as version
,total                                                                                                as total
,data_hash                                                                                            as data_hash
,fit_scene                                                                                            as fit_scene
,scenario_based                                                                                       as scenario_based
,screening_switch                                                                                     as screening_switch
,de_table_config                                                                                      as de_table_config
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,list_name                                                                                            as list_name
,property                                                                                             as property
,status                                                                                               as status
,data_type                                                                                            as data_type
,list_source                                                                                          as list_source
,actions                                                                                              as actions
,de_table_name                                                                                        as de_table_name
,remark                                                                                               as remark
,description                                                                                          as description
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,category                                                                                             as category
,version                                                                                              as version
,total                                                                                                as total
,data_hash                                                                                            as data_hash
,fit_scene                                                                                            as fit_scene
,scenario_based                                                                                       as scenario_based
,screening_switch                                                                                     as screening_switch
,de_table_config                                                                                      as de_table_config
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_id_db__custom_list_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.list_name') as string)                                                  as list_name
,cast(get_json_object(data,'$.property') as byte)                                                     as property
,cast(get_json_object(data,'$.status') as byte)                                                       as status
,cast(get_json_object(data,'$.data_type') as string)                                                  as data_type
,cast(get_json_object(data,'$.list_source') as string)                                                as list_source
,cast(get_json_object(data,'$.actions') as string)                                                    as actions
,cast(get_json_object(data,'$.de_table_name') as string)                                              as de_table_name
,cast(get_json_object(data,'$.remark') as string)                                                     as remark
,cast(get_json_object(data,'$.description') as string)                                                as description
,cast(get_json_object(data,'$.creator') as string)                                                    as creator
,cast(get_json_object(data,'$.create_time') as integer)                                               as create_time
,cast(get_json_object(data,'$.update_time') as integer)                                               as update_time
,cast(get_json_object(data,'$.category') as integer)                                                  as category
,cast(get_json_object(data,'$.version') as integer)                                                   as version
,cast(get_json_object(data,'$.total') as bigint)                                                      as total
,cast(get_json_object(data,'$.data_hash') as string)                                                  as data_hash
,cast(get_json_object(data,'$.fit_scene') as string)                                                  as fit_scene
,cast(get_json_object(data,'$.scenario_based') as bigint)                                             as scenario_based
,cast(get_json_object(data,'$.screening_switch') as bigint)                                           as screening_switch
,cast(get_json_object(data,'$.de_table_config') as string)                                            as de_table_config
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_control_id_db' and base_table= 'custom_list_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_control_id_db__custom_list_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,list_name                                                                                            as list_name
,property                                                                                             as property
,status                                                                                               as status
,data_type                                                                                            as data_type
,list_source                                                                                          as list_source
,actions                                                                                              as actions
,de_table_name                                                                                        as de_table_name
,remark                                                                                               as remark
,description                                                                                          as description
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,category                                                                                             as category
,version                                                                                              as version
,total                                                                                                as total
,data_hash                                                                                            as data_hash
,fit_scene                                                                                            as fit_scene
,scenario_based                                                                                       as scenario_based
,screening_switch                                                                                     as screening_switch
,de_table_config                                                                                      as de_table_config
 
 ,_event
 ;