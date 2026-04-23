

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,uuid                                                                                                 as uuid
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,description                                                                                          as description
,version                                                                                              as version
,version_status                                                                                       as version_status
,strategy_package                                                                                     as strategy_package
,layout_data                                                                                          as layout_data
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,status                                                                                               as status
,sub_category                                                                                         as sub_category
 
,_event
 from(
    select 
 id                                                                                                   as id
,uuid                                                                                                 as uuid
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,description                                                                                          as description
,version                                                                                              as version
,version_status                                                                                       as version_status
,strategy_package                                                                                     as strategy_package
,layout_data                                                                                          as layout_data
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,status                                                                                               as status
,sub_category                                                                                         as sub_category
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,uuid                                                                                                 as uuid
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,description                                                                                          as description
,version                                                                                              as version
,version_status                                                                                       as version_status
,strategy_package                                                                                     as strategy_package
,layout_data                                                                                          as layout_data
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,status                                                                                               as status
,sub_category                                                                                         as sub_category
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__shopeepay_risk_control_id_db__fe_scene_strategy_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.uuid') as string)                                                       as uuid
,cast(get_json_object(data,'$.app_id') as string)                                                     as app_id
,cast(get_json_object(data,'$.scene_id') as bigint)                                                   as scene_id
,cast(get_json_object(data,'$.description') as string)                                                as description
,cast(get_json_object(data,'$.version') as bigint)                                                    as version
,cast(get_json_object(data,'$.version_status') as bigint)                                             as version_status
,cast(get_json_object(data,'$.strategy_package') as string)                                           as strategy_package
,cast(get_json_object(data,'$.layout_data') as string)                                                as layout_data
,cast(get_json_object(data,'$.creator') as string)                                                    as creator
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.status') as bigint)                                                     as status
,cast(get_json_object(data,'$.sub_category') as bigint)                                               as sub_category
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'shopeepay_risk_control_id_db' and base_table= 'fe_scene_strategy_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__shopeepay_risk_control_id_db__fe_scene_strategy_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,uuid                                                                                                 as uuid
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,description                                                                                          as description
,version                                                                                              as version
,version_status                                                                                       as version_status
,strategy_package                                                                                     as strategy_package
,layout_data                                                                                          as layout_data
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,status                                                                                               as status
,sub_category                                                                                         as sub_category
 
 ,_event
 ;