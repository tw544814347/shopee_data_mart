

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,app_id                                                                                               as app_id
,app_user_id                                                                                          as app_user_id
,source                                                                                               as source
,description                                                                                          as description
,create_time                                                                                          as create_time
,user_type                                                                                            as user_type
 
,_event
 from(
    select 
 id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,app_id                                                                                               as app_id
,app_user_id                                                                                          as app_user_id
,source                                                                                               as source
,description                                                                                          as description
,create_time                                                                                          as create_time
,user_type                                                                                            as user_type
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,app_id                                                                                               as app_id
,app_user_id                                                                                          as app_user_id
,source                                                                                               as source
,description                                                                                          as description
,create_time                                                                                          as create_time
,user_type                                                                                            as user_type
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__ldn_risk_underwriting_id_db__user_active_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.platform_user_id') as string)                                           as platform_user_id
,cast(get_json_object(data,'$.platform_type') as bigint)                                              as platform_type
,cast(get_json_object(data,'$.app_id') as string)                                                     as app_id
,cast(get_json_object(data,'$.app_user_id') as string)                                                as app_user_id
,cast(get_json_object(data,'$.source') as string)                                                     as source
,cast(get_json_object(data,'$.description') as string)                                                as description
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.user_type') as bigint)                                                  as user_type
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'ldn_risk_underwriting_id_db' and base_table= 'user_active_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.create_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__ldn_risk_underwriting_id_db__user_active_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,app_id                                                                                               as app_id
,app_user_id                                                                                          as app_user_id
,source                                                                                               as source
,description                                                                                          as description
,create_time                                                                                          as create_time
,user_type                                                                                            as user_type
 
 ,_event
 ;