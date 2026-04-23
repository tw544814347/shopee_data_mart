

refresh table risk.ccin_multi_realtime_binlog_for_my;

from (
    select 
 id                                                                                                   as id
,field                                                                                                as field
,api                                                                                                  as api
,profile_index                                                                                        as profile_index
,function_name                                                                                        as function_name
,query                                                                                                as query
,extra_attribute                                                                                      as extra_attribute
,create_time                                                                                          as create_time
,create_user                                                                                          as create_user
,update_time                                                                                          as update_time
 
,_event
 from(
    select 
 id                                                                                                   as id
,field                                                                                                as field
,api                                                                                                  as api
,profile_index                                                                                        as profile_index
,function_name                                                                                        as function_name
,query                                                                                                as query
,extra_attribute                                                                                      as extra_attribute
,create_time                                                                                          as create_time
,create_user                                                                                          as create_user
,update_time                                                                                          as update_time
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,field                                                                                                as field
,api                                                                                                  as api
,profile_index                                                                                        as profile_index
,function_name                                                                                        as function_name
,query                                                                                                as query
,extra_attribute                                                                                      as extra_attribute
,create_time                                                                                          as create_time
,create_user                                                                                          as create_user
,update_time                                                                                          as update_time
 
 ,concat_ws('_',nvl(id,''))                                                                            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_my_db__data_feature_param_config_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.field') as string)                                                      as field
,cast(get_json_object(data,'$.api') as string)                                                        as api
,cast(get_json_object(data,'$.profile_index') as string)                                              as profile_index
,cast(get_json_object(data,'$.function_name') as string)                                              as function_name
,cast(get_json_object(data,'$.query') as string)                                                      as query
,cast(get_json_object(data,'$.extra_attribute') as string)                                            as extra_attribute
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.create_user') as string)                                                as create_user
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
 
 ,concat_ws('_',nvl(get_json_object(data,'$.id'),''))                                                  as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_my 
        where base_database = 'credit_risk_control_my_db' and base_table= 'data_feature_param_config_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 0 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete' 
)
insert overwrite table risk.ods__credit_risk_control_my_db__data_feature_param_config_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,field                                                                                                as field
,api                                                                                                  as api
,profile_index                                                                                        as profile_index
,function_name                                                                                        as function_name
,query                                                                                                as query
,extra_attribute                                                                                      as extra_attribute
,create_time                                                                                          as create_time
,create_user                                                                                          as create_user
,update_time                                                                                          as update_time
 
 ,_event
 ;