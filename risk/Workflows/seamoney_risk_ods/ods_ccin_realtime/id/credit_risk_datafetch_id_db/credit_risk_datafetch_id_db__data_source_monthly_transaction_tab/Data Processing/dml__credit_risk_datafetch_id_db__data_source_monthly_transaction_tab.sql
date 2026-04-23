

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,data_source_name                                                                                     as data_source_name
,entity                                                                                               as entity
,before_tax                                                                                           as before_tax
,after_tax                                                                                            as after_tax
,remark                                                                                               as remark
,operator                                                                                             as operator
,year_month                                                                                           as year_month
,update_time                                                                                          as update_time
,create_time                                                                                          as create_time
,invoice                                                                                              as invoice
,actual_cost                                                                                          as actual_cost
,estimated_cost                                                                                       as estimated_cost
,meta_data_id                                                                                         as meta_data_id
 
,_event
 from(
    select 
 id                                                                                                   as id
,data_source_name                                                                                     as data_source_name
,entity                                                                                               as entity
,before_tax                                                                                           as before_tax
,after_tax                                                                                            as after_tax
,remark                                                                                               as remark
,operator                                                                                             as operator
,year_month                                                                                           as year_month
,update_time                                                                                          as update_time
,create_time                                                                                          as create_time
,invoice                                                                                              as invoice
,actual_cost                                                                                          as actual_cost
,estimated_cost                                                                                       as estimated_cost
,meta_data_id                                                                                         as meta_data_id
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,data_source_name                                                                                     as data_source_name
,entity                                                                                               as entity
,before_tax                                                                                           as before_tax
,after_tax                                                                                            as after_tax
,remark                                                                                               as remark
,operator                                                                                             as operator
,year_month                                                                                           as year_month
,update_time                                                                                          as update_time
,create_time                                                                                          as create_time
,invoice                                                                                              as invoice
,actual_cost                                                                                          as actual_cost
,estimated_cost                                                                                       as estimated_cost
,meta_data_id                                                                                         as meta_data_id
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_datafetch_id_db__data_source_monthly_transaction_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id
,cast(get_json_object(data,'$.data_source_name') as string)                                           as data_source_name
,cast(get_json_object(data,'$.entity') as string)                                                     as entity
,cast(get_json_object(data,'$.before_tax') as decimal(30,10))                                         as before_tax
,cast(get_json_object(data,'$.after_tax') as decimal(30,10))                                          as after_tax
,cast(get_json_object(data,'$.remark') as string)                                                     as remark
,cast(get_json_object(data,'$.operator') as string)                                                   as operator
,cast(get_json_object(data,'$.year_month') as bigint)                                                 as year_month
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.invoice') as string)                                                    as invoice
,cast(get_json_object(data,'$.actual_cost') as decimal(30,10))                                        as actual_cost
,cast(get_json_object(data,'$.estimated_cost') as decimal(30,10))                                     as estimated_cost
,cast(get_json_object(data,'$.meta_data_id') as bigint)                                               as meta_data_id
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_datafetch_id_db' and base_table= 'data_source_monthly_transaction_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_datafetch_id_db__data_source_monthly_transaction_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,data_source_name                                                                                     as data_source_name
,entity                                                                                               as entity
,before_tax                                                                                           as before_tax
,after_tax                                                                                            as after_tax
,remark                                                                                               as remark
,operator                                                                                             as operator
,year_month                                                                                           as year_month
,update_time                                                                                          as update_time
,create_time                                                                                          as create_time
,invoice                                                                                              as invoice
,actual_cost                                                                                          as actual_cost
,estimated_cost                                                                                       as estimated_cost
,meta_data_id                                                                                         as meta_data_id
 
 ,_event
 ;