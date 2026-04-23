

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,screen_id                                                                                            as screen_id
,operate_type                                                                                         as operate_type
,content                                                                                              as content
,content_map_no                                                                                       as content_map_no
,operator                                                                                             as operator
,operator_map_no                                                                                      as operator_map_no
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
,_event
 from(
    select 
 id                                                                                                   as id
,screen_id                                                                                            as screen_id
,operate_type                                                                                         as operate_type
,content                                                                                              as content
,content_map_no                                                                                       as content_map_no
,operator                                                                                             as operator
,operator_map_no                                                                                      as operator_map_no
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,screen_id                                                                                            as screen_id
,operate_type                                                                                         as operate_type
,content                                                                                              as content
,content_map_no                                                                                       as content_map_no
,operator                                                                                             as operator
,operator_map_no                                                                                      as operator_map_no
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_id_cf_db__screen_ops_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.screen_id') as string)                                                  as screen_id
,cast(get_json_object(data,'$.operate_type') as bigint)                                               as operate_type
,cast(get_json_object(data,'$.content') as string)                                                    as content
,cast(get_json_object(data,'$.content_map_no') as string)                                             as content_map_no
,cast(get_json_object(data,'$.operator') as string)                                                   as operator
,cast(get_json_object(data,'$.operator_map_no') as string)                                            as operator_map_no
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_control_id_cf_db' and base_table= 'screen_ops_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_control_id_cf_db__screen_ops_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,screen_id                                                                                            as screen_id
,operate_type                                                                                         as operate_type
,content                                                                                              as content
,content_map_no                                                                                       as content_map_no
,operator                                                                                             as operator
,operator_map_no                                                                                      as operator_map_no
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,_event
 ;