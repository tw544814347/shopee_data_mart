



refresh table risk.ccin_multi_realtime_binlog_for_br;

from (
    select 
 id                                                                                                   as id
,wfid                                                                                                 as wfid
,platform_user_id                                                                                     as platform_user_id
,step                                                                                                 as step
,status                                                                                               as status
,input                                                                                                as input
,output                                                                                               as output
,next                                                                                                 as next
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time

,_event
 from(
    select 
 id                                                                                                   as id
,wfid                                                                                                 as wfid
,platform_user_id                                                                                     as platform_user_id
,step                                                                                                 as step
,status                                                                                               as status
,input                                                                                                as input
,output                                                                                               as output
,next                                                                                                 as next
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time

 ,_event
,row_number() over(partition by on_keys_conds order by update_time desc,get_json_object(_event,'$.ts') desc, get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,wfid                                                                                                 as wfid
,platform_user_id                                                                                     as platform_user_id
,step                                                                                                 as step
,status                                                                                               as status
,input                                                                                                as input
,output                                                                                               as output
,next                                                                                                 as next
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)                    as on_keys_conds

,_event
        from risk.ods__shopeepay_risk_control_br_db__workflow_steps_tab__df__private fs
        where grass_date = date_add('${grass_date}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id 
,cast(get_json_object(data,'$.wfid') as bigint)                                                       as wfid 
,cast(get_json_object(data,'$.platform_user_id') as string)                                           as platform_user_id 
,cast(get_json_object(data,'$.step') as string)                                                       as step 
,cast(get_json_object(data,'$.status') as bigint)                                                     as status 
,cast(get_json_object(data,'$.input') as string)                                                      as input 
,cast(get_json_object(data,'$.output') as string)                                                     as output 
,cast(get_json_object(data,'$.next') as string)                                                       as next 
,cast(get_json_object(data,'$.version') as bigint)                                                    as version 
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time 
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time 

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),get_json_object(data,'$.id')) as on_keys_conds

,_event
        from risk.ccin_multi_realtime_binlog_for_br 
        where base_database = 'shopeepay_risk_control_br_db' and base_table = 'workflow_steps_tab'
        --base_database like 'shopeepay_risk_control_br_db%' and base_table like 'workflow_steps_tab%'
        and (dt 
              between date_add('${grass_date}', -2) 
              and if('${binlog_src_end_date}' >= '${grass_date}', '${binlog_src_end_date}' ,date_add('${grass_date}', 10))
            ) 
         and from_unixtime(get_json_object(data,'$.update_time') - 39600,'yyyy-MM-dd') <= '${grass_date}'
        
    ) a
   ) where  rn = 1 and 1=1
)

    
insert overwrite table risk.ods__shopeepay_risk_control_br_db__workflow_steps_tab__df__private partition(grass_date = '${grass_date}')
select 
 id                                                                                                   as id
,wfid                                                                                                 as wfid
,platform_user_id                                                                                     as platform_user_id
,step                                                                                                 as step
,status                                                                                               as status
,input                                                                                                as input
,output                                                                                               as output
,next                                                                                                 as next
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time

 ,_event


;
---------------------------msck repair table for all dest dbs---------------------------------------

msck repair table risk.ods__shopeepay_risk_control_br_db__workflow_steps_tab__df__private;

refresh table risk.ods__shopeepay_risk_control_br_db__workflow_steps_tab__df__private;

    