

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,model_name                                                                                           as model_name
,model_version                                                                                        as model_version
,model_url                                                                                            as model_url
,version                                                                                              as version
,model_description                                                                                    as model_description
,model_status                                                                                         as model_status
,model_history                                                                                        as model_history
,timeout                                                                                              as timeout
,inputs                                                                                               as inputs
,outputs                                                                                              as outputs
,operator                                                                                             as operator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,binning_rules                                                                                        as binning_rules
 
,_event
 from(
    select 
 id                                                                                                   as id
,model_name                                                                                           as model_name
,model_version                                                                                        as model_version
,model_url                                                                                            as model_url
,version                                                                                              as version
,model_description                                                                                    as model_description
,model_status                                                                                         as model_status
,model_history                                                                                        as model_history
,timeout                                                                                              as timeout
,inputs                                                                                               as inputs
,outputs                                                                                              as outputs
,operator                                                                                             as operator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,binning_rules                                                                                        as binning_rules
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,model_name                                                                                           as model_name
,model_version                                                                                        as model_version
,model_url                                                                                            as model_url
,version                                                                                              as version
,model_description                                                                                    as model_description
,model_status                                                                                         as model_status
,model_history                                                                                        as model_history
,timeout                                                                                              as timeout
,inputs                                                                                               as inputs
,outputs                                                                                              as outputs
,operator                                                                                             as operator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,binning_rules                                                                                        as binning_rules
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_id_db__strategy_model_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.model_name') as string)                                                 as model_name
,cast(get_json_object(data,'$.model_version') as string)                                              as model_version
,cast(get_json_object(data,'$.model_url') as string)                                                  as model_url
,cast(get_json_object(data,'$.version') as bigint)                                                    as version
,cast(get_json_object(data,'$.model_description') as string)                                          as model_description
,cast(get_json_object(data,'$.model_status') as bigint)                                               as model_status
,cast(get_json_object(data,'$.model_history') as bigint)                                              as model_history
,cast(get_json_object(data,'$.timeout') as bigint)                                                    as timeout
,cast(get_json_object(data,'$.inputs') as string)                                                     as inputs
,cast(get_json_object(data,'$.outputs') as string)                                                    as outputs
,cast(get_json_object(data,'$.operator') as string)                                                   as operator
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.binning_rules') as string)                                              as binning_rules
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_control_id_db' and base_table= 'strategy_model_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_control_id_db__strategy_model_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,model_name                                                                                           as model_name
,model_version                                                                                        as model_version
,model_url                                                                                            as model_url
,version                                                                                              as version
,model_description                                                                                    as model_description
,model_status                                                                                         as model_status
,model_history                                                                                        as model_history
,timeout                                                                                              as timeout
,inputs                                                                                               as inputs
,outputs                                                                                              as outputs
,operator                                                                                             as operator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,binning_rules                                                                                        as binning_rules
 
 ,_event
 ;