

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,ticket_category                                                                                      as ticket_category
,ticket_subtype                                                                                       as ticket_subtype
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,region                                                                                               as region
,version                                                                                              as version
,ticket_info_tpl                                                                                      as ticket_info_tpl
,ticket_info_render                                                                                   as ticket_info_render
,ticket_other_info_tpl                                                                                as ticket_other_info_tpl
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,name                                                                                                 as name
,adapter_uuid                                                                                         as adapter_uuid
,complete_fields                                                                                      as complete_fields
,description                                                                                          as description
,ticket_other_info_tpl_new                                                                            as ticket_other_info_tpl_new
,ticket_info_tpl_new                                                                                  as ticket_info_tpl_new
 
,_event
 from(
    select 
 id                                                                                                   as id
,ticket_category                                                                                      as ticket_category
,ticket_subtype                                                                                       as ticket_subtype
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,region                                                                                               as region
,version                                                                                              as version
,ticket_info_tpl                                                                                      as ticket_info_tpl
,ticket_info_render                                                                                   as ticket_info_render
,ticket_other_info_tpl                                                                                as ticket_other_info_tpl
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,name                                                                                                 as name
,adapter_uuid                                                                                         as adapter_uuid
,complete_fields                                                                                      as complete_fields
,description                                                                                          as description
,ticket_other_info_tpl_new                                                                            as ticket_other_info_tpl_new
,ticket_info_tpl_new                                                                                  as ticket_info_tpl_new
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,ticket_category                                                                                      as ticket_category
,ticket_subtype                                                                                       as ticket_subtype
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,region                                                                                               as region
,version                                                                                              as version
,ticket_info_tpl                                                                                      as ticket_info_tpl
,ticket_info_render                                                                                   as ticket_info_render
,ticket_other_info_tpl                                                                                as ticket_other_info_tpl
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,name                                                                                                 as name
,adapter_uuid                                                                                         as adapter_uuid
,complete_fields                                                                                      as complete_fields
,description                                                                                          as description
,ticket_other_info_tpl_new                                                                            as ticket_other_info_tpl_new
,ticket_info_tpl_new                                                                                  as ticket_info_tpl_new
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_id_db__ticket_tpl_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.ticket_category') as bigint)                                            as ticket_category
,cast(get_json_object(data,'$.ticket_subtype') as bigint)                                             as ticket_subtype
,cast(get_json_object(data,'$.app_id') as string)                                                     as app_id
,cast(get_json_object(data,'$.scene_id') as bigint)                                                   as scene_id
,cast(get_json_object(data,'$.region') as string)                                                     as region
,cast(get_json_object(data,'$.version') as bigint)                                                    as version
,cast(get_json_object(data,'$.ticket_info_tpl') as string)                                            as ticket_info_tpl
,cast(get_json_object(data,'$.ticket_info_render') as string)                                         as ticket_info_render
,cast(get_json_object(data,'$.ticket_other_info_tpl') as string)                                      as ticket_other_info_tpl
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.name') as string)                                                       as name
,cast(get_json_object(data,'$.adapter_uuid') as string)                                               as adapter_uuid
,cast(get_json_object(data,'$.complete_fields') as string)                                            as complete_fields
,cast(get_json_object(data,'$.description') as string)                                                as description
,cast(get_json_object(data,'$.ticket_other_info_tpl_new') as string)                                  as ticket_other_info_tpl_new
,cast(get_json_object(data,'$.ticket_info_tpl_new') as string)                                        as ticket_info_tpl_new
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_control_id_db' and base_table= 'ticket_tpl_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete' 
)
insert overwrite table risk.ods__credit_risk_control_id_db__ticket_tpl_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,ticket_category                                                                                      as ticket_category
,ticket_subtype                                                                                       as ticket_subtype
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,region                                                                                               as region
,version                                                                                              as version
,ticket_info_tpl                                                                                      as ticket_info_tpl
,ticket_info_render                                                                                   as ticket_info_render
,ticket_other_info_tpl                                                                                as ticket_other_info_tpl
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,name                                                                                                 as name
,adapter_uuid                                                                                         as adapter_uuid
,complete_fields                                                                                      as complete_fields
,description                                                                                          as description
,ticket_other_info_tpl_new                                                                            as ticket_other_info_tpl_new
,ticket_info_tpl_new                                                                                  as ticket_info_tpl_new
 
 ,_event
 ;