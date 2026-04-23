

refresh table risk.ccin_multi_realtime_binlog_for_my;

from (
    select 
 feature_id                                                                                           as feature_id
,feature_name                                                                                         as feature_name
,module                                                                                               as module
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,is_disable                                                                                           as is_disable
,return_type                                                                                          as return_type
,args                                                                                                 as args
,apply_scene                                                                                          as apply_scene
 
,_event
 from(
    select 
 feature_id                                                                                           as feature_id
,feature_name                                                                                         as feature_name
,module                                                                                               as module
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,is_disable                                                                                           as is_disable
,return_type                                                                                          as return_type
,args                                                                                                 as args
,apply_scene                                                                                          as apply_scene
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 feature_id                                                                                           as feature_id
,feature_name                                                                                         as feature_name
,module                                                                                               as module
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,is_disable                                                                                           as is_disable
,return_type                                                                                          as return_type
,args                                                                                                 as args
,apply_scene                                                                                          as apply_scene
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),feature_id)    as on_keys_conds
,_event
        from risk.ods__credit_risk_control_my_db__feature_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.feature_id') as bigint)                                                 as feature_id
,cast(get_json_object(data,'$.feature_name') as string)                                               as feature_name
,cast(get_json_object(data,'$.module') as string)                                                     as module
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.is_disable') as bigint)                                                 as is_disable
,cast(get_json_object(data,'$.return_type') as string)                                                as return_type
,cast(get_json_object(data,'$.args') as string)                                                       as args
,cast(get_json_object(data,'$.apply_scene') as string)                                                as apply_scene
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.feature_id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_my 
        where base_database = 'credit_risk_control_my_db' and base_table= 'feature_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 0 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_control_my_db__feature_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 feature_id                                                                                           as feature_id
,feature_name                                                                                         as feature_name
,module                                                                                               as module
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,is_disable                                                                                           as is_disable
,return_type                                                                                          as return_type
,args                                                                                                 as args
,apply_scene                                                                                          as apply_scene
 
 ,_event
 ;