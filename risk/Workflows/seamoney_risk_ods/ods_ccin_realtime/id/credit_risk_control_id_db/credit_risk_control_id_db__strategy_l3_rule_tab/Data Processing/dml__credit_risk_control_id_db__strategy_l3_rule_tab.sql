

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,ori_id                                                                                               as ori_id
,l3_rule_name                                                                                         as l3_rule_name
,l3_rule_script                                                                                       as l3_rule_script
,l2_ruls                                                                                              as l2_ruls
,expression                                                                                           as expression
,extention                                                                                            as extention
,version                                                                                              as version
,description                                                                                          as description
,status                                                                                               as status
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,category                                                                                             as category
,version_status                                                                                       as version_status
,error_default                                                                                        as error_default
 
,_event
 from(
    select 
 id                                                                                                   as id
,ori_id                                                                                               as ori_id
,l3_rule_name                                                                                         as l3_rule_name
,l3_rule_script                                                                                       as l3_rule_script
,l2_ruls                                                                                              as l2_ruls
,expression                                                                                           as expression
,extention                                                                                            as extention
,version                                                                                              as version
,description                                                                                          as description
,status                                                                                               as status
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,category                                                                                             as category
,version_status                                                                                       as version_status
,error_default                                                                                        as error_default
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,ori_id                                                                                               as ori_id
,l3_rule_name                                                                                         as l3_rule_name
,l3_rule_script                                                                                       as l3_rule_script
,l2_ruls                                                                                              as l2_ruls
,expression                                                                                           as expression
,extention                                                                                            as extention
,version                                                                                              as version
,description                                                                                          as description
,status                                                                                               as status
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,category                                                                                             as category
,version_status                                                                                       as version_status
,error_default                                                                                        as error_default
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_id_db__strategy_l3_rule_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.ori_id') as bigint)                                                     as ori_id
,cast(get_json_object(data,'$.l3_rule_name') as string)                                               as l3_rule_name
,cast(get_json_object(data,'$.l3_rule_script') as string)                                             as l3_rule_script
,cast(get_json_object(data,'$.l2_ruls') as string)                                                    as l2_ruls
,cast(get_json_object(data,'$.expression') as string)                                                 as expression
,cast(get_json_object(data,'$.extention') as string)                                                  as extention
,cast(get_json_object(data,'$.version') as integer)                                                   as version
,cast(get_json_object(data,'$.description') as string)                                                as description
,cast(get_json_object(data,'$.status') as byte)                                                       as status
,cast(get_json_object(data,'$.creator') as string)                                                    as creator
,cast(get_json_object(data,'$.create_time') as integer)                                               as create_time
,cast(get_json_object(data,'$.update_time') as integer)                                               as update_time
,cast(get_json_object(data,'$.category') as byte)                                                     as category
,cast(get_json_object(data,'$.version_status') as byte)                                               as version_status
,cast(get_json_object(data,'$.error_default') as string)                                              as error_default
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_control_id_db' and base_table= 'strategy_l3_rule_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_control_id_db__strategy_l3_rule_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,ori_id                                                                                               as ori_id
,l3_rule_name                                                                                         as l3_rule_name
,l3_rule_script                                                                                       as l3_rule_script
,l2_ruls                                                                                              as l2_ruls
,expression                                                                                           as expression
,extention                                                                                            as extention
,version                                                                                              as version
,description                                                                                          as description
,status                                                                                               as status
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,category                                                                                             as category
,version_status                                                                                       as version_status
,error_default                                                                                        as error_default
 
 ,_event
 ;