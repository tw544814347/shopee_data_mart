

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,repay_id                                                                                             as repay_id
,flow_no                                                                                              as flow_no
,product_type                                                                                         as product_type
,user_id                                                                                              as user_id
,loan_id                                                                                              as loan_id
,principal                                                                                            as principal
,interest                                                                                             as interest
,cur_term                                                                                             as cur_term
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
,_event
 from(
    select 
 id                                                                                                   as id
,repay_id                                                                                             as repay_id
,flow_no                                                                                              as flow_no
,product_type                                                                                         as product_type
,user_id                                                                                              as user_id
,loan_id                                                                                              as loan_id
,principal                                                                                            as principal
,interest                                                                                             as interest
,cur_term                                                                                             as cur_term
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,repay_id                                                                                             as repay_id
,flow_no                                                                                              as flow_no
,product_type                                                                                         as product_type
,user_id                                                                                              as user_id
,loan_id                                                                                              as loan_id
,principal                                                                                            as principal
,interest                                                                                             as interest
,cur_term                                                                                             as cur_term
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__dps_transaction_id_db__loan_repay_flow_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id
,cast(get_json_object(data,'$.repay_id') as string)                                                   as repay_id
,cast(get_json_object(data,'$.flow_no') as string)                                                    as flow_no
,cast(get_json_object(data,'$.product_type') as string)                                               as product_type
,cast(get_json_object(data,'$.user_id') as string)                                                    as user_id
,cast(get_json_object(data,'$.loan_id') as string)                                                    as loan_id
,cast(get_json_object(data,'$.principal') as decimal(30,10))                                          as principal
,cast(get_json_object(data,'$.interest') as decimal(30,10))                                           as interest
,cast(get_json_object(data,'$.cur_term') as bigint)                                                   as cur_term
,cast(get_json_object(data,'$.create_time') as string)                                                as create_time
,cast(get_json_object(data,'$.update_time') as string)                                                as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'dps_transaction_id_db' and base_table= 'loan_repay_flow_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(unix_timestamp(get_json_object(data,'$.update_time')) + 28800 - 3600 +0,'yyyy-MM-dd') <='${ods_date_t0}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete' 
)
insert overwrite table risk.ods__dps_transaction_id_db__loan_repay_flow_tab__df__private partition(grass_date ='${ods_date_t0}')
select 
 id                                                                                                   as id
,repay_id                                                                                             as repay_id
,flow_no                                                                                              as flow_no
,product_type                                                                                         as product_type
,user_id                                                                                              as user_id
,loan_id                                                                                              as loan_id
,principal                                                                                            as principal
,interest                                                                                             as interest
,cur_term                                                                                             as cur_term
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,_event
 ;