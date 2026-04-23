

refresh table risk.ccin_multi_realtime_binlog_for_my;

from (
    select 
 id                                                                                                   as id
,rule_id                                                                                              as rule_id
,entity                                                                                               as entity
,frequency                                                                                            as frequency
,threshold                                                                                            as threshold
,look_back_period                                                                                     as look_back_period
,status                                                                                               as status
,version_status                                                                                       as version_status
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,creator                                                                                              as creator
,extra_info                                                                                           as extra_info
,rule_name                                                                                            as rule_name
,type                                                                                                 as type
 
,_event
 from(
    select 
 id                                                                                                   as id
,rule_id                                                                                              as rule_id
,entity                                                                                               as entity
,frequency                                                                                            as frequency
,threshold                                                                                            as threshold
,look_back_period                                                                                     as look_back_period
,status                                                                                               as status
,version_status                                                                                       as version_status
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,creator                                                                                              as creator
,extra_info                                                                                           as extra_info
,rule_name                                                                                            as rule_name
,type                                                                                                 as type
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,rule_id                                                                                              as rule_id
,entity                                                                                               as entity
,frequency                                                                                            as frequency
,threshold                                                                                            as threshold
,look_back_period                                                                                     as look_back_period
,status                                                                                               as status
,version_status                                                                                       as version_status
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,creator                                                                                              as creator
,extra_info                                                                                           as extra_info
,rule_name                                                                                            as rule_name
,type                                                                                                 as type
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__shopeepay_risk_aml_my_db__aml_rule_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.rule_id') as string)                                                    as rule_id
,cast(get_json_object(data,'$.entity') as string)                                                     as entity
,cast(get_json_object(data,'$.frequency') as string)                                                  as frequency
,cast(get_json_object(data,'$.threshold') as string)                                                  as threshold
,cast(get_json_object(data,'$.look_back_period') as bigint)                                           as look_back_period
,cast(get_json_object(data,'$.status') as bigint)                                                     as status
,cast(get_json_object(data,'$.version_status') as bigint)                                             as version_status
,cast(get_json_object(data,'$.version') as bigint)                                                    as version
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.creator') as string)                                                    as creator
,cast(get_json_object(data,'$.extra_info') as string)                                                 as extra_info
,cast(get_json_object(data,'$.rule_name') as string)                                                  as rule_name
,cast(get_json_object(data,'$.type') as bigint)                                                       as type
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_my 
        where base_database = 'shopeepay_risk_aml_my_db' and base_table= 'aml_rule_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 0 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__shopeepay_risk_aml_my_db__aml_rule_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,rule_id                                                                                              as rule_id
,entity                                                                                               as entity
,frequency                                                                                            as frequency
,threshold                                                                                            as threshold
,look_back_period                                                                                     as look_back_period
,status                                                                                               as status
,version_status                                                                                       as version_status
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,creator                                                                                              as creator
,extra_info                                                                                           as extra_info
,rule_name                                                                                            as rule_name
,type                                                                                                 as type
 
 ,_event
 ;