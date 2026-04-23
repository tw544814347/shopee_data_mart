

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,trade_id                                                                                             as trade_id
,flow_no                                                                                              as flow_no
,flow_type                                                                                            as flow_type
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,req_ip                                                                                               as req_ip
,server_ip                                                                                            as server_ip
,code                                                                                                 as code
,msg                                                                                                  as msg
,req                                                                                                  as req
,rsp                                                                                                  as rsp
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,version                                                                                              as version
,score                                                                                                as score
,name                                                                                                 as name
,speed                                                                                                as speed
,local_ip                                                                                             as local_ip
,relevance_id                                                                                         as relevance_id
,request_params                                                                                       as request_params
,process_step                                                                                         as process_step
,exec_time                                                                                            as exec_time
,node_id                                                                                              as node_id
 
,_event
 from(
    select 
 id                                                                                                   as id
,trade_id                                                                                             as trade_id
,flow_no                                                                                              as flow_no
,flow_type                                                                                            as flow_type
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,req_ip                                                                                               as req_ip
,server_ip                                                                                            as server_ip
,code                                                                                                 as code
,msg                                                                                                  as msg
,req                                                                                                  as req
,rsp                                                                                                  as rsp
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,version                                                                                              as version
,score                                                                                                as score
,name                                                                                                 as name
,speed                                                                                                as speed
,local_ip                                                                                             as local_ip
,relevance_id                                                                                         as relevance_id
,request_params                                                                                       as request_params
,process_step                                                                                         as process_step
,exec_time                                                                                            as exec_time
,node_id                                                                                              as node_id
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,trade_id                                                                                             as trade_id
,flow_no                                                                                              as flow_no
,flow_type                                                                                            as flow_type
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,req_ip                                                                                               as req_ip
,server_ip                                                                                            as server_ip
,code                                                                                                 as code
,msg                                                                                                  as msg
,req                                                                                                  as req
,rsp                                                                                                  as rsp
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,version                                                                                              as version
,score                                                                                                as score
,name                                                                                                 as name
,speed                                                                                                as speed
,local_ip                                                                                             as local_ip
,relevance_id                                                                                         as relevance_id
,request_params                                                                                       as request_params
,process_step                                                                                         as process_step
,exec_time                                                                                            as exec_time
,node_id                                                                                              as node_id
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_id_db__credit_risk_trade_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as integer)                                                        as id
,cast(get_json_object(data,'$.trade_id') as string)                                                   as trade_id
,cast(get_json_object(data,'$.flow_no') as string)                                                    as flow_no
,cast(get_json_object(data,'$.flow_type') as string)                                                  as flow_type
,cast(get_json_object(data,'$.app_id') as string)                                                     as app_id
,cast(get_json_object(data,'$.scene_id') as bigint)                                                   as scene_id
,cast(get_json_object(data,'$.platform_user_id') as string)                                           as platform_user_id
,cast(get_json_object(data,'$.req_ip') as string)                                                     as req_ip
,cast(get_json_object(data,'$.server_ip') as string)                                                  as server_ip
,cast(get_json_object(data,'$.code') as bigint)                                                       as code
,cast(get_json_object(data,'$.msg') as string)                                                        as msg
,cast(get_json_object(data,'$.req') as string)                                                        as req
,cast(get_json_object(data,'$.rsp') as string)                                                        as rsp
,cast(get_json_object(data,'$.create_time') as integer)                                               as create_time
,cast(get_json_object(data,'$.update_time') as integer)                                               as update_time
,cast(get_json_object(data,'$.version') as string)                                                    as version
,cast(get_json_object(data,'$.score') as decimal(30,10))                                              as score
,cast(get_json_object(data,'$.name') as string)                                                       as name
,cast(get_json_object(data,'$.speed') as bigint)                                                      as speed
,cast(get_json_object(data,'$.local_ip') as string)                                                   as local_ip
,cast(get_json_object(data,'$.relevance_id') as string)                                               as relevance_id
,cast(get_json_object(data,'$.request_params') as string)                                             as request_params
,cast(get_json_object(data,'$.process_step') as bigint)                                               as process_step
,cast(get_json_object(data,'$.exec_time') as string)                                                  as exec_time
,cast(get_json_object(data,'$.node_id') as string)                                                    as node_id
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_control_id_db' and base_table= 'credit_risk_trade_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_control_id_db__credit_risk_trade_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,trade_id                                                                                             as trade_id
,flow_no                                                                                              as flow_no
,flow_type                                                                                            as flow_type
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,req_ip                                                                                               as req_ip
,server_ip                                                                                            as server_ip
,code                                                                                                 as code
,msg                                                                                                  as msg
,req                                                                                                  as req
,rsp                                                                                                  as rsp
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,version                                                                                              as version
,score                                                                                                as score
,name                                                                                                 as name
,speed                                                                                                as speed
,local_ip                                                                                             as local_ip
,relevance_id                                                                                         as relevance_id
,request_params                                                                                       as request_params
,process_step                                                                                         as process_step
,exec_time                                                                                            as exec_time
,node_id                                                                                              as node_id
 
 ,_event
 ;