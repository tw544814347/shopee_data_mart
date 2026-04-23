

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,task_id                                                                                              as task_id
,task_data                                                                                            as task_data
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
,_event
 from(
    select 
 id                                                                                                   as id
,task_id                                                                                              as task_id
,task_data                                                                                            as task_data
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,task_id                                                                                              as task_id
,task_data                                                                                            as task_data
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__scoring_open_platform_id_db__auto_backtesting_task_data_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.task_id') as string)                                                    as task_id
,cast(get_json_object(data,'$.task_data') as string)                                                  as task_data
,cast(get_json_object(data,'$.create_time') as decimal(20,0))                                         as create_time
,cast(get_json_object(data,'$.update_time') as decimal(20,0))                                         as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'scoring_open_platform_id_db' and base_table= 'auto_backtesting_task_data_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time')/1000 - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__scoring_open_platform_id_db__auto_backtesting_task_data_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,task_id                                                                                              as task_id
,task_data                                                                                            as task_data
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,_event
 ;