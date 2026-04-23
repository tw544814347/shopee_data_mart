



refresh table risk.ccin_multi_realtime_binlog_for_br;

from (
    select 
 id                                                                                                   as id
,unique_key                                                                                           as unique_key
,data_source_name                                                                                     as data_source_name
,req_key                                                                                              as req_key
,req_header                                                                                           as req_header
,req                                                                                                  as req
,extra_info                                                                                           as extra_info
,retry_count                                                                                          as retry_count
,resp_code                                                                                            as resp_code
,trace_id                                                                                             as trace_id
,app_key                                                                                              as app_key
,data_year_month                                                                                      as data_year_month
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time

,_event
 from(
    select 
 id                                                                                                   as id
,unique_key                                                                                           as unique_key
,data_source_name                                                                                     as data_source_name
,req_key                                                                                              as req_key
,req_header                                                                                           as req_header
,req                                                                                                  as req
,extra_info                                                                                           as extra_info
,retry_count                                                                                          as retry_count
,resp_code                                                                                            as resp_code
,trace_id                                                                                             as trace_id
,app_key                                                                                              as app_key
,data_year_month                                                                                      as data_year_month
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time

 ,_event
,row_number() over(partition by on_keys_conds order by update_time desc,get_json_object(_event,'$.ts') desc, get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,unique_key                                                                                           as unique_key
,data_source_name                                                                                     as data_source_name
,req_key                                                                                              as req_key
,req_header                                                                                           as req_header
,req                                                                                                  as req
,extra_info                                                                                           as extra_info
,retry_count                                                                                          as retry_count
,resp_code                                                                                            as resp_code
,trace_id                                                                                             as trace_id
,app_key                                                                                              as app_key
,data_year_month                                                                                      as data_year_month
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)                    as on_keys_conds

,_event
        from risk.ods__credit_risk_datafetch_br_db__identity_fetch_tab__df__private fs
        where grass_date = date_add('${grass_date}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id 
,cast(get_json_object(data,'$.unique_key') as string)                                                 as unique_key 
,cast(get_json_object(data,'$.data_source_name') as string)                                           as data_source_name 
,cast(get_json_object(data,'$.req_key') as string)                                                    as req_key 
,cast(get_json_object(data,'$.req_header') as string)                                                 as req_header 
,cast(get_json_object(data,'$.req') as string)                                                        as req 
,cast(get_json_object(data,'$.extra_info') as string)                                                 as extra_info 
,cast(get_json_object(data,'$.retry_count') as bigint)                                                as retry_count 
,cast(get_json_object(data,'$.resp_code') as bigint)                                                  as resp_code 
,cast(get_json_object(data,'$.trace_id') as string)                                                   as trace_id 
,cast(get_json_object(data,'$.app_key') as string)                                                    as app_key 
,cast(get_json_object(data,'$.data_year_month') as string)                                            as data_year_month 
,cast(get_json_object(data,'$.create_time') as string)                                                as create_time 
,cast(get_json_object(data,'$.update_time') as string)                                                as update_time 

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),get_json_object(data,'$.id')) as on_keys_conds

,_event
        from risk.ccin_multi_realtime_binlog_for_br 
        where base_database = 'credit_risk_datafetch_br_db' and base_table = 'identity_fetch_tab'
        --base_database like 'credit_risk_datafetch_br_db%' and base_table like 'identity_fetch_tab%'
        and (dt 
              between date_add('${grass_date}', -2) 
              and if('${binlog_src_end_date}' >= '${grass_date}', '${binlog_src_end_date}' ,date_add('${grass_date}', 10))
            ) 
         and from_unixtime(unix_timestamp(get_json_object(data,'$.update_time')) + 8 * 3600 - 39600,'yyyy-MM-dd') <= '${grass_date}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)

    
insert overwrite table risk.ods__credit_risk_datafetch_br_db__identity_fetch_tab__df__private partition(grass_date = '${grass_date}')
select 
 id                                                                                                   as id
,unique_key                                                                                           as unique_key
,data_source_name                                                                                     as data_source_name
,req_key                                                                                              as req_key
,req_header                                                                                           as req_header
,req                                                                                                  as req
,extra_info                                                                                           as extra_info
,retry_count                                                                                          as retry_count
,resp_code                                                                                            as resp_code
,trace_id                                                                                             as trace_id
,app_key                                                                                              as app_key
,data_year_month                                                                                      as data_year_month
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time

 ,_event


;
---------------------------msck repair table for all dest dbs---------------------------------------

msck repair table risk.ods__credit_risk_datafetch_br_db__identity_fetch_tab__df__private;

refresh table risk.ods__credit_risk_datafetch_br_db__identity_fetch_tab__df__private;

    