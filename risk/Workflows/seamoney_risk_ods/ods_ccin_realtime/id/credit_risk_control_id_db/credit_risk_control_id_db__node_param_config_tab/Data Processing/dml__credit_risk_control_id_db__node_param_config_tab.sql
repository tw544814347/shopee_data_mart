

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,tree_id                                                                                              as tree_id
,node_id                                                                                              as node_id
,sis_field                                                                                            as sis_field
,sis_field_type                                                                                       as sis_field_type
,default_value                                                                                        as default_value
,field                                                                                                as field
,data_source                                                                                          as data_source
,tag                                                                                                  as tag
,create_user                                                                                          as create_user
,create_time                                                                                          as create_time
,feature_version                                                                                      as feature_version
,value_type                                                                                           as value_type
,sis_value_type                                                                                       as sis_value_type
,sis_data_array_size                                                                                  as sis_data_array_size
 
,_event
 from(
    select 
 id                                                                                                   as id
,tree_id                                                                                              as tree_id
,node_id                                                                                              as node_id
,sis_field                                                                                            as sis_field
,sis_field_type                                                                                       as sis_field_type
,default_value                                                                                        as default_value
,field                                                                                                as field
,data_source                                                                                          as data_source
,tag                                                                                                  as tag
,create_user                                                                                          as create_user
,create_time                                                                                          as create_time
,feature_version                                                                                      as feature_version
,value_type                                                                                           as value_type
,sis_value_type                                                                                       as sis_value_type
,sis_data_array_size                                                                                  as sis_data_array_size
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,tree_id                                                                                              as tree_id
,node_id                                                                                              as node_id
,sis_field                                                                                            as sis_field
,sis_field_type                                                                                       as sis_field_type
,default_value                                                                                        as default_value
,field                                                                                                as field
,data_source                                                                                          as data_source
,tag                                                                                                  as tag
,create_user                                                                                          as create_user
,create_time                                                                                          as create_time
,feature_version                                                                                      as feature_version
,value_type                                                                                           as value_type
,sis_value_type                                                                                       as sis_value_type
,sis_data_array_size                                                                                  as sis_data_array_size
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_id_db__node_param_config_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id
,cast(get_json_object(data,'$.tree_id') as bigint)                                                    as tree_id
,cast(get_json_object(data,'$.node_id') as string)                                                    as node_id
,cast(get_json_object(data,'$.sis_field') as string)                                                  as sis_field
,cast(get_json_object(data,'$.sis_field_type') as bigint)                                             as sis_field_type
,cast(get_json_object(data,'$.default_value') as string)                                              as default_value
,cast(get_json_object(data,'$.field') as string)                                                      as field
,cast(get_json_object(data,'$.data_source') as string)                                                as data_source
,cast(get_json_object(data,'$.tag') as string)                                                        as tag
,cast(get_json_object(data,'$.create_user') as string)                                                as create_user
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.feature_version') as bigint)                                            as feature_version
,cast(get_json_object(data,'$.value_type') as bigint)                                                 as value_type
,cast(get_json_object(data,'$.sis_value_type') as string)                                             as sis_value_type
,cast(get_json_object(data,'$.sis_data_array_size') as bigint)                                        as sis_data_array_size
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_control_id_db' and base_table= 'node_param_config_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.create_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_control_id_db__node_param_config_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,tree_id                                                                                              as tree_id
,node_id                                                                                              as node_id
,sis_field                                                                                            as sis_field
,sis_field_type                                                                                       as sis_field_type
,default_value                                                                                        as default_value
,field                                                                                                as field
,data_source                                                                                          as data_source
,tag                                                                                                  as tag
,create_user                                                                                          as create_user
,create_time                                                                                          as create_time
,feature_version                                                                                      as feature_version
,value_type                                                                                           as value_type
,sis_value_type                                                                                       as sis_value_type
,sis_data_array_size                                                                                  as sis_data_array_size
 
 ,_event
 ;