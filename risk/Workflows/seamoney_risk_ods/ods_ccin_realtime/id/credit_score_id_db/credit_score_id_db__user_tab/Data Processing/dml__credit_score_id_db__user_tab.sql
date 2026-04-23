

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,credit_user_id                                                                                       as credit_user_id
,status                                                                                               as status
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,active_time                                                                                          as active_time
,merge_batch                                                                                          as merge_batch
 
,_event
 from(
    select 
 id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,credit_user_id                                                                                       as credit_user_id
,status                                                                                               as status
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,active_time                                                                                          as active_time
,merge_batch                                                                                          as merge_batch
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,credit_user_id                                                                                       as credit_user_id
,status                                                                                               as status
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,active_time                                                                                          as active_time
,merge_batch                                                                                          as merge_batch
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_score_id_db__user_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.platform_user_id') as string)                                           as platform_user_id
,cast(get_json_object(data,'$.platform_type') as bigint)                                              as platform_type
,cast(get_json_object(data,'$.credit_user_id') as string)                                             as credit_user_id
,cast(get_json_object(data,'$.status') as bigint)                                                     as status
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.active_time') as bigint)                                                as active_time
,cast(get_json_object(data,'$.merge_batch') as string)                                                as merge_batch
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_score_id_db' and base_table= 'user_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time')/1000 - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_score_id_db__user_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,credit_user_id                                                                                       as credit_user_id
,status                                                                                               as status
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,active_time                                                                                          as active_time
,merge_batch                                                                                          as merge_batch
 
 ,_event
 ;