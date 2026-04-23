

refresh table risk.ccin_multi_realtime_binlog_for_my;

from (
    select 
 id                                                                                                   as id
,ori_id                                                                                               as ori_id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,group_name                                                                                           as group_name
,group_script                                                                                         as group_script
,l3_rules                                                                                             as l3_rules
,default_result_id                                                                                    as default_result_id
,version                                                                                              as version
,status                                                                                               as status
,description                                                                                          as description
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,category                                                                                             as category
,version_status                                                                                       as version_status
,list_config                                                                                          as list_config
,serial_type                                                                                          as serial_type
,strategy_type                                                                                        as strategy_type
,group_script_v2                                                                                      as group_script_v2
,rets                                                                                                 as rets
 
,_event
 from(
    select 
 id                                                                                                   as id
,ori_id                                                                                               as ori_id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,group_name                                                                                           as group_name
,group_script                                                                                         as group_script
,l3_rules                                                                                             as l3_rules
,default_result_id                                                                                    as default_result_id
,version                                                                                              as version
,status                                                                                               as status
,description                                                                                          as description
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,category                                                                                             as category
,version_status                                                                                       as version_status
,list_config                                                                                          as list_config
,serial_type                                                                                          as serial_type
,strategy_type                                                                                        as strategy_type
,group_script_v2                                                                                      as group_script_v2
,rets                                                                                                 as rets
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,ori_id                                                                                               as ori_id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,group_name                                                                                           as group_name
,group_script                                                                                         as group_script
,l3_rules                                                                                             as l3_rules
,default_result_id                                                                                    as default_result_id
,version                                                                                              as version
,status                                                                                               as status
,description                                                                                          as description
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,category                                                                                             as category
,version_status                                                                                       as version_status
,list_config                                                                                          as list_config
,serial_type                                                                                          as serial_type
,strategy_type                                                                                        as strategy_type
,group_script_v2                                                                                      as group_script_v2
,rets                                                                                                 as rets
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__shopeepay_risk_control_my_db__strategy_l3_rule_group_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id
,cast(get_json_object(data,'$.ori_id') as decimal(20,0))                                              as ori_id
,cast(get_json_object(data,'$.app_id') as string)                                                     as app_id
,cast(get_json_object(data,'$.scene_id') as bigint)                                                   as scene_id
,cast(get_json_object(data,'$.group_name') as string)                                                 as group_name
,cast(get_json_object(data,'$.group_script') as string)                                               as group_script
,cast(get_json_object(data,'$.l3_rules') as string)                                                   as l3_rules
,cast(get_json_object(data,'$.default_result_id') as bigint)                                          as default_result_id
,cast(get_json_object(data,'$.version') as bigint)                                                    as version
,cast(get_json_object(data,'$.status') as bigint)                                                     as status
,cast(get_json_object(data,'$.description') as string)                                                as description
,cast(get_json_object(data,'$.creator') as string)                                                    as creator
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.category') as bigint)                                                   as category
,cast(get_json_object(data,'$.version_status') as bigint)                                             as version_status
,cast(get_json_object(data,'$.list_config') as string)                                                as list_config
,cast(get_json_object(data,'$.serial_type') as bigint)                                                as serial_type
,cast(get_json_object(data,'$.strategy_type') as bigint)                                              as strategy_type
,cast(get_json_object(data,'$.group_script_v2') as string)                                            as group_script_v2
,cast(get_json_object(data,'$.rets') as string)                                                       as rets
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_my 
        where base_database = 'shopeepay_risk_control_my_db' and base_table= 'strategy_l3_rule_group_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 0 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__shopeepay_risk_control_my_db__strategy_l3_rule_group_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,ori_id                                                                                               as ori_id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,group_name                                                                                           as group_name
,group_script                                                                                         as group_script
,l3_rules                                                                                             as l3_rules
,default_result_id                                                                                    as default_result_id
,version                                                                                              as version
,status                                                                                               as status
,description                                                                                          as description
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,category                                                                                             as category
,version_status                                                                                       as version_status
,list_config                                                                                          as list_config
,serial_type                                                                                          as serial_type
,strategy_type                                                                                        as strategy_type
,group_script_v2                                                                                      as group_script_v2
,rets                                                                                                 as rets
 
 ,_event
 ;