

refresh table risk.ccin_multi_realtime_binlog_for_id;

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
,input_encrypt                                                                                        as input_encrypt
,shopeepay_user_id                                                                                    as shopeepay_user_id
 
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
,input_encrypt                                                                                        as input_encrypt
,shopeepay_user_id                                                                                    as shopeepay_user_id
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
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
,input_encrypt                                                                                        as input_encrypt
,shopeepay_user_id                                                                                    as shopeepay_user_id
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_id_cf_db__workflow_steps_shadow_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


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
,cast(get_json_object(data,'$.input_encrypt') as string)                                              as input_encrypt
,cast(get_json_object(data,'$.shopeepay_user_id') as string)                                          as shopeepay_user_id
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_control_id_cf_db' and base_table= 'workflow_steps_shadow_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete' 
)
insert overwrite table risk.ods__credit_risk_control_id_cf_db__workflow_steps_shadow_tab__df__private partition(grass_date ='${ods_date_t1}')
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
,input_encrypt                                                                                        as input_encrypt
,shopeepay_user_id                                                                                    as shopeepay_user_id
 
 ,_event
 ;