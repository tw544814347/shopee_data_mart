

refresh table risk.ccin_multi_realtime_binlog_for_my;

from (
    select 
 id                                                                                                   as id
,name                                                                                                 as name
,description                                                                                          as description
,level                                                                                                as level
,metrics                                                                                              as metrics
,expression                                                                                           as expression
,error_default                                                                                        as error_default
,version                                                                                              as version
,version_status                                                                                       as version_status
,status                                                                                               as status
,category                                                                                             as category
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,sub_category                                                                                         as sub_category
 
,_event
 from(
    select 
 id                                                                                                   as id
,name                                                                                                 as name
,description                                                                                          as description
,level                                                                                                as level
,metrics                                                                                              as metrics
,expression                                                                                           as expression
,error_default                                                                                        as error_default
,version                                                                                              as version
,version_status                                                                                       as version_status
,status                                                                                               as status
,category                                                                                             as category
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,sub_category                                                                                         as sub_category
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,name                                                                                                 as name
,description                                                                                          as description
,level                                                                                                as level
,metrics                                                                                              as metrics
,expression                                                                                           as expression
,error_default                                                                                        as error_default
,version                                                                                              as version
,version_status                                                                                       as version_status
,status                                                                                               as status
,category                                                                                             as category
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,sub_category                                                                                         as sub_category
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_my_db__fe_strategy_rule_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.name') as string)                                                       as name
,cast(get_json_object(data,'$.description') as string)                                                as description
,cast(get_json_object(data,'$.level') as bigint)                                                      as level
,cast(get_json_object(data,'$.metrics') as string)                                                    as metrics
,cast(get_json_object(data,'$.expression') as string)                                                 as expression
,cast(get_json_object(data,'$.error_default') as string)                                              as error_default
,cast(get_json_object(data,'$.version') as bigint)                                                    as version
,cast(get_json_object(data,'$.version_status') as bigint)                                             as version_status
,cast(get_json_object(data,'$.status') as bigint)                                                     as status
,cast(get_json_object(data,'$.category') as bigint)                                                   as category
,cast(get_json_object(data,'$.creator') as string)                                                    as creator
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.sub_category') as bigint)                                               as sub_category
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_my 
        where base_database = 'credit_risk_control_my_db' and base_table= 'fe_strategy_rule_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 0 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_control_my_db__fe_strategy_rule_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,name                                                                                                 as name
,description                                                                                          as description
,level                                                                                                as level
,metrics                                                                                              as metrics
,expression                                                                                           as expression
,error_default                                                                                        as error_default
,version                                                                                              as version
,version_status                                                                                       as version_status
,status                                                                                               as status
,category                                                                                             as category
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,sub_category                                                                                         as sub_category
 
 ,_event
 ;