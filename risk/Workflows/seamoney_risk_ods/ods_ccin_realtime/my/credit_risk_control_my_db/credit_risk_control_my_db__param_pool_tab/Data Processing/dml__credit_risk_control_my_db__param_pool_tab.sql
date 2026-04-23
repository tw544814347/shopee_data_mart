

refresh table risk.ccin_multi_realtime_binlog_for_my;

from (
    select 
 id                                                                                                   as id
,region                                                                                               as region
,app_id                                                                                               as app_id
,field                                                                                                as field
,field_type                                                                                           as field_type
,value_type                                                                                           as value_type
,data_source                                                                                          as data_source
,name                                                                                                 as name
,description                                                                                          as description
,create_user                                                                                          as create_user
,create_time                                                                                          as create_time
,array_size                                                                                           as array_size
,scene_id                                                                                             as scene_id
,field_version                                                                                        as field_version
 
,_event
 from(
    select 
 id                                                                                                   as id
,region                                                                                               as region
,app_id                                                                                               as app_id
,field                                                                                                as field
,field_type                                                                                           as field_type
,value_type                                                                                           as value_type
,data_source                                                                                          as data_source
,name                                                                                                 as name
,description                                                                                          as description
,create_user                                                                                          as create_user
,create_time                                                                                          as create_time
,array_size                                                                                           as array_size
,scene_id                                                                                             as scene_id
,field_version                                                                                        as field_version
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,region                                                                                               as region
,app_id                                                                                               as app_id
,field                                                                                                as field
,field_type                                                                                           as field_type
,value_type                                                                                           as value_type
,data_source                                                                                          as data_source
,name                                                                                                 as name
,description                                                                                          as description
,create_user                                                                                          as create_user
,create_time                                                                                          as create_time
,array_size                                                                                           as array_size
,scene_id                                                                                             as scene_id
,field_version                                                                                        as field_version
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_my_db__param_pool_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id
,cast(get_json_object(data,'$.region') as string)                                                     as region
,cast(get_json_object(data,'$.app_id') as string)                                                     as app_id
,cast(get_json_object(data,'$.field') as string)                                                      as field
,cast(get_json_object(data,'$.field_type') as bigint)                                                 as field_type
,cast(get_json_object(data,'$.value_type') as string)                                                 as value_type
,cast(get_json_object(data,'$.data_source') as string)                                                as data_source
,cast(get_json_object(data,'$.name') as string)                                                       as name
,cast(get_json_object(data,'$.description') as string)                                                as description
,cast(get_json_object(data,'$.create_user') as string)                                                as create_user
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.array_size') as bigint)                                                 as array_size
,cast(get_json_object(data,'$.scene_id') as string)                                                   as scene_id
,cast(get_json_object(data,'$.field_version') as bigint)                                              as field_version
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_my 
        where base_database = 'credit_risk_control_my_db' and base_table= 'param_pool_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.create_time') - 0 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_control_my_db__param_pool_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,region                                                                                               as region
,app_id                                                                                               as app_id
,field                                                                                                as field
,field_type                                                                                           as field_type
,value_type                                                                                           as value_type
,data_source                                                                                          as data_source
,name                                                                                                 as name
,description                                                                                          as description
,create_user                                                                                          as create_user
,create_time                                                                                          as create_time
,array_size                                                                                           as array_size
,scene_id                                                                                             as scene_id
,field_version                                                                                        as field_version
 
 ,_event
 ;