

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,data_source_name                                                                                     as data_source_name
,entity                                                                                               as entity
,total_calls                                                                                          as total_calls
,success_calls                                                                                        as success_calls
,failed_calls                                                                                         as failed_calls
,success_rate                                                                                         as success_rate
,failed_rate                                                                                          as failed_rate
,year_month                                                                                           as year_month
,update_time                                                                                          as update_time
,create_time                                                                                          as create_time
,daily_data                                                                                           as daily_data
 
,_event
 from(
    select 
 id                                                                                                   as id
,data_source_name                                                                                     as data_source_name
,entity                                                                                               as entity
,total_calls                                                                                          as total_calls
,success_calls                                                                                        as success_calls
,failed_calls                                                                                         as failed_calls
,success_rate                                                                                         as success_rate
,failed_rate                                                                                          as failed_rate
,year_month                                                                                           as year_month
,update_time                                                                                          as update_time
,create_time                                                                                          as create_time
,daily_data                                                                                           as daily_data
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,data_source_name                                                                                     as data_source_name
,entity                                                                                               as entity
,total_calls                                                                                          as total_calls
,success_calls                                                                                        as success_calls
,failed_calls                                                                                         as failed_calls
,success_rate                                                                                         as success_rate
,failed_rate                                                                                          as failed_rate
,year_month                                                                                           as year_month
,update_time                                                                                          as update_time
,create_time                                                                                          as create_time
,daily_data                                                                                           as daily_data
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_datafetch_id_db__data_source_monthly_statistics_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id
,cast(get_json_object(data,'$.data_source_name') as string)                                           as data_source_name
,cast(get_json_object(data,'$.entity') as string)                                                     as entity
,cast(get_json_object(data,'$.total_calls') as decimal(20,0))                                         as total_calls
,cast(get_json_object(data,'$.success_calls') as decimal(20,0))                                       as success_calls
,cast(get_json_object(data,'$.failed_calls') as decimal(20,0))                                        as failed_calls
,cast(get_json_object(data,'$.success_rate') as double)                                               as success_rate
,cast(get_json_object(data,'$.failed_rate') as double)                                                as failed_rate
,cast(get_json_object(data,'$.year_month') as bigint)                                                 as year_month
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.daily_data') as string)                                                 as daily_data
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_datafetch_id_db' and base_table= 'data_source_monthly_statistics_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_datafetch_id_db__data_source_monthly_statistics_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,data_source_name                                                                                     as data_source_name
,entity                                                                                               as entity
,total_calls                                                                                          as total_calls
,success_calls                                                                                        as success_calls
,failed_calls                                                                                         as failed_calls
,success_rate                                                                                         as success_rate
,failed_rate                                                                                          as failed_rate
,year_month                                                                                           as year_month
,update_time                                                                                          as update_time
,create_time                                                                                          as create_time
,daily_data                                                                                           as daily_data
 
 ,_event
 ;