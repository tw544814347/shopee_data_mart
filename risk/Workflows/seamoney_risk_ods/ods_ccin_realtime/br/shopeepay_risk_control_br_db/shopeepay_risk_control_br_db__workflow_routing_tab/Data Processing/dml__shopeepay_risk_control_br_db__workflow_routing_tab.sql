



refresh table risk.ccin_multi_realtime_binlog_for_br;

from (
    select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,region                                                                                               as region
,run_mode                                                                                             as run_mode
,proportion                                                                                           as proportion
,config_type                                                                                          as config_type
,workflow_id                                                                                          as workflow_id
,status                                                                                               as status
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time

,_event
 from(
    select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,region                                                                                               as region
,run_mode                                                                                             as run_mode
,proportion                                                                                           as proportion
,config_type                                                                                          as config_type
,workflow_id                                                                                          as workflow_id
,status                                                                                               as status
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time

 ,_event
,row_number() over(partition by on_keys_conds order by update_time desc,get_json_object(_event,'$.ts') desc, get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,region                                                                                               as region
,run_mode                                                                                             as run_mode
,proportion                                                                                           as proportion
,config_type                                                                                          as config_type
,workflow_id                                                                                          as workflow_id
,status                                                                                               as status
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)                    as on_keys_conds

,_event
        from risk.ods__shopeepay_risk_control_br_db__workflow_routing_tab__df__private fs
        where grass_date = date_add('${grass_date}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id 
,cast(get_json_object(data,'$.app_id') as string)                                                     as app_id 
,cast(get_json_object(data,'$.scene_id') as bigint)                                                   as scene_id 
,cast(get_json_object(data,'$.region') as string)                                                     as region 
,cast(get_json_object(data,'$.run_mode') as string)                                                   as run_mode 
,cast(get_json_object(data,'$.proportion') as bigint)                                                 as proportion 
,cast(get_json_object(data,'$.config_type') as string)                                                as config_type 
,cast(get_json_object(data,'$.workflow_id') as bigint)                                                as workflow_id 
,cast(get_json_object(data,'$.status') as string)                                                     as status 
,cast(get_json_object(data,'$.creator') as string)                                                    as creator 
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time 
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time 

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),get_json_object(data,'$.id')) as on_keys_conds

,_event
        from risk.ccin_multi_realtime_binlog_for_br 
        where base_database = 'shopeepay_risk_control_br_db' and base_table = 'workflow_routing_tab'
        --base_database like 'shopeepay_risk_control_br_db%' and base_table like 'workflow_routing_tab%'
        and (dt 
              between date_add('${grass_date}', -2) 
              and if('${binlog_src_end_date}' >= '${grass_date}', '${binlog_src_end_date}' ,date_add('${grass_date}', 10))
            ) 
         and from_unixtime(get_json_object(data,'$.update_time') - 39600,'yyyy-MM-dd') <= '${grass_date}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)

    
insert overwrite table risk.ods__shopeepay_risk_control_br_db__workflow_routing_tab__df__private partition(grass_date = '${grass_date}')
select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,region                                                                                               as region
,run_mode                                                                                             as run_mode
,proportion                                                                                           as proportion
,config_type                                                                                          as config_type
,workflow_id                                                                                          as workflow_id
,status                                                                                               as status
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time

 ,_event


;
---------------------------msck repair table for all dest dbs---------------------------------------

msck repair table risk.ods__shopeepay_risk_control_br_db__workflow_routing_tab__df__private;

refresh table risk.ods__shopeepay_risk_control_br_db__workflow_routing_tab__df__private;

    