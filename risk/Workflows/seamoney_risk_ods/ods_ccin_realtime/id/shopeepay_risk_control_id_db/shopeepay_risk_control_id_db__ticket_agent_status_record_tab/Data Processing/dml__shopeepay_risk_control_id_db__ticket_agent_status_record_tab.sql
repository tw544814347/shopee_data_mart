

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,agent                                                                                                as agent
,notes                                                                                                as notes
,queue                                                                                                as queue
,status                                                                                               as status
,end_time                                                                                             as end_time
,assigned_ticket_id                                                                                   as assigned_ticket_id
,last_assigned_time                                                                                   as last_assigned_time
,assessed_ticket_count                                                                                as assessed_ticket_count
,update_time                                                                                          as update_time
,create_time                                                                                          as create_time
,source                                                                                               as source
,ticket_count                                                                                         as ticket_count
 
,_event
 from(
    select 
 id                                                                                                   as id
,agent                                                                                                as agent
,notes                                                                                                as notes
,queue                                                                                                as queue
,status                                                                                               as status
,end_time                                                                                             as end_time
,assigned_ticket_id                                                                                   as assigned_ticket_id
,last_assigned_time                                                                                   as last_assigned_time
,assessed_ticket_count                                                                                as assessed_ticket_count
,update_time                                                                                          as update_time
,create_time                                                                                          as create_time
,source                                                                                               as source
,ticket_count                                                                                         as ticket_count
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,agent                                                                                                as agent
,notes                                                                                                as notes
,queue                                                                                                as queue
,status                                                                                               as status
,end_time                                                                                             as end_time
,assigned_ticket_id                                                                                   as assigned_ticket_id
,last_assigned_time                                                                                   as last_assigned_time
,assessed_ticket_count                                                                                as assessed_ticket_count
,update_time                                                                                          as update_time
,create_time                                                                                          as create_time
,source                                                                                               as source
,ticket_count                                                                                         as ticket_count
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__shopeepay_risk_control_id_db__ticket_agent_status_record_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.agent') as string)                                                      as agent
,cast(get_json_object(data,'$.notes') as string)                                                      as notes
,cast(get_json_object(data,'$.queue') as bigint)                                                      as queue
,cast(get_json_object(data,'$.status') as bigint)                                                     as status
,cast(get_json_object(data,'$.end_time') as bigint)                                                   as end_time
,cast(get_json_object(data,'$.assigned_ticket_id') as string)                                         as assigned_ticket_id
,cast(get_json_object(data,'$.last_assigned_time') as bigint)                                         as last_assigned_time
,cast(get_json_object(data,'$.assessed_ticket_count') as string)                                      as assessed_ticket_count
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.source') as bigint)                                                     as source
,cast(get_json_object(data,'$.ticket_count') as bigint)                                               as ticket_count
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'shopeepay_risk_control_id_db' and base_table= 'ticket_agent_status_record_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__shopeepay_risk_control_id_db__ticket_agent_status_record_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,agent                                                                                                as agent
,notes                                                                                                as notes
,queue                                                                                                as queue
,status                                                                                               as status
,end_time                                                                                             as end_time
,assigned_ticket_id                                                                                   as assigned_ticket_id
,last_assigned_time                                                                                   as last_assigned_time
,assessed_ticket_count                                                                                as assessed_ticket_count
,update_time                                                                                          as update_time
,create_time                                                                                          as create_time
,source                                                                                               as source
,ticket_count                                                                                         as ticket_count
 
 ,_event
 ;