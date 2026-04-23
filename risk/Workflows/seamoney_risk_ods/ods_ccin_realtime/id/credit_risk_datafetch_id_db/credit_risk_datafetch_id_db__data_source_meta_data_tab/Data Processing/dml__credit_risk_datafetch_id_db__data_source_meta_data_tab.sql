

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,data_source_name                                                                                     as data_source_name
,entity                                                                                               as entity
,data_type                                                                                            as data_type
,charging_method                                                                                      as charging_method
,unit_price                                                                                           as unit_price
,tax_rate                                                                                             as tax_rate
,contract_expiry_date                                                                                 as contract_expiry_date
,data_status                                                                                          as data_status
,operator                                                                                             as operator
,doc                                                                                                  as doc
,remark                                                                                               as remark
,update_time                                                                                          as update_time
,create_time                                                                                          as create_time
,contract_effective_date                                                                              as contract_effective_date
,tiered_pricing                                                                                       as tiered_pricing
,version                                                                                              as version
,version_status                                                                                       as version_status
,monthly_usage_alert                                                                                  as monthly_usage_alert
 
,_event
 from(
    select 
 id                                                                                                   as id
,data_source_name                                                                                     as data_source_name
,entity                                                                                               as entity
,data_type                                                                                            as data_type
,charging_method                                                                                      as charging_method
,unit_price                                                                                           as unit_price
,tax_rate                                                                                             as tax_rate
,contract_expiry_date                                                                                 as contract_expiry_date
,data_status                                                                                          as data_status
,operator                                                                                             as operator
,doc                                                                                                  as doc
,remark                                                                                               as remark
,update_time                                                                                          as update_time
,create_time                                                                                          as create_time
,contract_effective_date                                                                              as contract_effective_date
,tiered_pricing                                                                                       as tiered_pricing
,version                                                                                              as version
,version_status                                                                                       as version_status
,monthly_usage_alert                                                                                  as monthly_usage_alert
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,data_source_name                                                                                     as data_source_name
,entity                                                                                               as entity
,data_type                                                                                            as data_type
,charging_method                                                                                      as charging_method
,unit_price                                                                                           as unit_price
,tax_rate                                                                                             as tax_rate
,contract_expiry_date                                                                                 as contract_expiry_date
,data_status                                                                                          as data_status
,operator                                                                                             as operator
,doc                                                                                                  as doc
,remark                                                                                               as remark
,update_time                                                                                          as update_time
,create_time                                                                                          as create_time
,contract_effective_date                                                                              as contract_effective_date
,tiered_pricing                                                                                       as tiered_pricing
,version                                                                                              as version
,version_status                                                                                       as version_status
,monthly_usage_alert                                                                                  as monthly_usage_alert
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_datafetch_id_db__data_source_meta_data_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id
,cast(get_json_object(data,'$.data_source_name') as string)                                           as data_source_name
,cast(get_json_object(data,'$.entity') as string)                                                     as entity
,cast(get_json_object(data,'$.data_type') as string)                                                  as data_type
,cast(get_json_object(data,'$.charging_method') as string)                                            as charging_method
,cast(get_json_object(data,'$.unit_price') as decimal(30,10))                                         as unit_price
,cast(get_json_object(data,'$.tax_rate') as decimal(30,10))                                           as tax_rate
,cast(get_json_object(data,'$.contract_expiry_date') as bigint)                                       as contract_expiry_date
,cast(get_json_object(data,'$.data_status') as bigint)                                                as data_status
,cast(get_json_object(data,'$.operator') as string)                                                   as operator
,cast(get_json_object(data,'$.doc') as string)                                                        as doc
,cast(get_json_object(data,'$.remark') as string)                                                     as remark
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.contract_effective_date') as bigint)                                    as contract_effective_date
,cast(get_json_object(data,'$.tiered_pricing') as string)                                             as tiered_pricing
,cast(get_json_object(data,'$.version') as bigint)                                                    as version
,cast(get_json_object(data,'$.version_status') as bigint)                                             as version_status
,cast(get_json_object(data,'$.monthly_usage_alert') as bigint)                                        as monthly_usage_alert
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_datafetch_id_db' and base_table= 'data_source_meta_data_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete' 
)
insert overwrite table risk.ods__credit_risk_datafetch_id_db__data_source_meta_data_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,data_source_name                                                                                     as data_source_name
,entity                                                                                               as entity
,data_type                                                                                            as data_type
,charging_method                                                                                      as charging_method
,unit_price                                                                                           as unit_price
,tax_rate                                                                                             as tax_rate
,contract_expiry_date                                                                                 as contract_expiry_date
,data_status                                                                                          as data_status
,operator                                                                                             as operator
,doc                                                                                                  as doc
,remark                                                                                               as remark
,update_time                                                                                          as update_time
,create_time                                                                                          as create_time
,contract_effective_date                                                                              as contract_effective_date
,tiered_pricing                                                                                       as tiered_pricing
,version                                                                                              as version
,version_status                                                                                       as version_status
,monthly_usage_alert                                                                                  as monthly_usage_alert
 
 ,_event
 ;