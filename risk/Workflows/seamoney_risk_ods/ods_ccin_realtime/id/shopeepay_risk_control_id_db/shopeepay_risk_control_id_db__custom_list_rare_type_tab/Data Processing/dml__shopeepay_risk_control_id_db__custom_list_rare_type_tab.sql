

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,data                                                                                                 as data
,data_type                                                                                            as data_type
,custom_list_id                                                                                       as custom_list_id
,data_source                                                                                          as data_source
,action_detail                                                                                        as action_detail
,action_fail_detail                                                                                   as action_fail_detail
,action_status                                                                                        as action_status
,remark                                                                                               as remark
,status                                                                                               as status
,description                                                                                          as description
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,expire_time                                                                                          as expire_time
 
,_event
 from(
    select 
 id                                                                                                   as id
,data                                                                                                 as data
,data_type                                                                                            as data_type
,custom_list_id                                                                                       as custom_list_id
,data_source                                                                                          as data_source
,action_detail                                                                                        as action_detail
,action_fail_detail                                                                                   as action_fail_detail
,action_status                                                                                        as action_status
,remark                                                                                               as remark
,status                                                                                               as status
,description                                                                                          as description
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,expire_time                                                                                          as expire_time
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,data                                                                                                 as data
,data_type                                                                                            as data_type
,custom_list_id                                                                                       as custom_list_id
,data_source                                                                                          as data_source
,action_detail                                                                                        as action_detail
,action_fail_detail                                                                                   as action_fail_detail
,action_status                                                                                        as action_status
,remark                                                                                               as remark
,status                                                                                               as status
,description                                                                                          as description
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,expire_time                                                                                          as expire_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__shopeepay_risk_control_id_db__custom_list_rare_type_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id
,cast(get_json_object(data,'$.data') as string)                                                       as data
,cast(get_json_object(data,'$.data_type') as bigint)                                                  as data_type
,cast(get_json_object(data,'$.custom_list_id') as decimal(20,0))                                      as custom_list_id
,cast(get_json_object(data,'$.data_source') as string)                                                as data_source
,cast(get_json_object(data,'$.action_detail') as string)                                              as action_detail
,cast(get_json_object(data,'$.action_fail_detail') as string)                                         as action_fail_detail
,cast(get_json_object(data,'$.action_status') as bigint)                                              as action_status
,cast(get_json_object(data,'$.remark') as string)                                                     as remark
,cast(get_json_object(data,'$.status') as bigint)                                                     as status
,cast(get_json_object(data,'$.description') as string)                                                as description
,cast(get_json_object(data,'$.creator') as string)                                                    as creator
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.expire_time') as bigint)                                                as expire_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'shopeepay_risk_control_id_db' and base_table= 'custom_list_rare_type_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__shopeepay_risk_control_id_db__custom_list_rare_type_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,data                                                                                                 as data
,data_type                                                                                            as data_type
,custom_list_id                                                                                       as custom_list_id
,data_source                                                                                          as data_source
,action_detail                                                                                        as action_detail
,action_fail_detail                                                                                   as action_fail_detail
,action_status                                                                                        as action_status
,remark                                                                                               as remark
,status                                                                                               as status
,description                                                                                          as description
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,expire_time                                                                                          as expire_time
 
 ,_event
 ;