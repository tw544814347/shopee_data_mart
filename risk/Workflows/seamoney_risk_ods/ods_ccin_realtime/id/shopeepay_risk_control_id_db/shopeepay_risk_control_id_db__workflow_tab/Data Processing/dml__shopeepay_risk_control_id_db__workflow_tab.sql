

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,flow_no                                                                                              as flow_no
,seq_id                                                                                               as seq_id
,current_step                                                                                         as current_step
,run_step                                                                                             as run_step
,status                                                                                               as status
,input                                                                                                as input
,output                                                                                               as output
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,req_no                                                                                               as req_no
,req_md5                                                                                              as req_md5
,cluster_id                                                                                           as cluster_id
,async_flag                                                                                           as async_flag
,input_encrypt                                                                                        as input_encrypt
,original_platform_type                                                                               as original_platform_type
,shopeepay_user_id                                                                                    as shopeepay_user_id
 
,_event
 from(
    select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,flow_no                                                                                              as flow_no
,seq_id                                                                                               as seq_id
,current_step                                                                                         as current_step
,run_step                                                                                             as run_step
,status                                                                                               as status
,input                                                                                                as input
,output                                                                                               as output
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,req_no                                                                                               as req_no
,req_md5                                                                                              as req_md5
,cluster_id                                                                                           as cluster_id
,async_flag                                                                                           as async_flag
,input_encrypt                                                                                        as input_encrypt
,original_platform_type                                                                               as original_platform_type
,shopeepay_user_id                                                                                    as shopeepay_user_id
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,flow_no                                                                                              as flow_no
,seq_id                                                                                               as seq_id
,current_step                                                                                         as current_step
,run_step                                                                                             as run_step
,status                                                                                               as status
,input                                                                                                as input
,output                                                                                               as output
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,req_no                                                                                               as req_no
,req_md5                                                                                              as req_md5
,cluster_id                                                                                           as cluster_id
,async_flag                                                                                           as async_flag
,input_encrypt                                                                                        as input_encrypt
,original_platform_type                                                                               as original_platform_type
,shopeepay_user_id                                                                                    as shopeepay_user_id
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__shopeepay_risk_control_id_db__workflow_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.app_id') as string)                                                     as app_id
,cast(get_json_object(data,'$.scene_id') as bigint)                                                   as scene_id
,cast(get_json_object(data,'$.platform_user_id') as string)                                           as platform_user_id
,cast(get_json_object(data,'$.flow_no') as string)                                                    as flow_no
,cast(get_json_object(data,'$.seq_id') as string)                                                     as seq_id
,cast(get_json_object(data,'$.current_step') as string)                                               as current_step
,cast(get_json_object(data,'$.run_step') as string)                                                   as run_step
,cast(get_json_object(data,'$.status') as bigint)                                                     as status
,cast(get_json_object(data,'$.input') as string)                                                      as input
,cast(get_json_object(data,'$.output') as string)                                                     as output
,cast(get_json_object(data,'$.version') as bigint)                                                    as version
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.req_no') as string)                                                     as req_no
,cast(get_json_object(data,'$.req_md5') as string)                                                    as req_md5
,cast(get_json_object(data,'$.cluster_id') as bigint)                                                 as cluster_id
,cast(get_json_object(data,'$.async_flag') as bigint)                                                 as async_flag
,cast(get_json_object(data,'$.input_encrypt') as string)                                              as input_encrypt
,cast(get_json_object(data,'$.original_platform_type') as bigint)                                     as original_platform_type
,cast(get_json_object(data,'$.shopeepay_user_id') as string)                                          as shopeepay_user_id
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'shopeepay_risk_control_id_db' and base_table= 'workflow_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and 1=1 
)
insert overwrite table risk.ods__shopeepay_risk_control_id_db__workflow_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,flow_no                                                                                              as flow_no
,seq_id                                                                                               as seq_id
,current_step                                                                                         as current_step
,run_step                                                                                             as run_step
,status                                                                                               as status
,input                                                                                                as input
,output                                                                                               as output
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,req_no                                                                                               as req_no
,req_md5                                                                                              as req_md5
,cluster_id                                                                                           as cluster_id
,async_flag                                                                                           as async_flag
,input_encrypt                                                                                        as input_encrypt
,original_platform_type                                                                               as original_platform_type
,shopeepay_user_id                                                                                    as shopeepay_user_id
 
 ,_event
 ;