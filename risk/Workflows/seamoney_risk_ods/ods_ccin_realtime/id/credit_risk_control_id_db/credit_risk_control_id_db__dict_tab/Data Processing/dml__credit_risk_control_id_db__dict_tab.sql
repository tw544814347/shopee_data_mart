

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,dict_key                                                                                             as dict_key
,dict_name                                                                                            as dict_name
,dict_value                                                                                           as dict_value
,parent_dict_key                                                                                      as parent_dict_key
,leaf_node                                                                                            as leaf_node
,description                                                                                          as description
,status                                                                                               as status
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
,_event
 from(
    select 
 id                                                                                                   as id
,dict_key                                                                                             as dict_key
,dict_name                                                                                            as dict_name
,dict_value                                                                                           as dict_value
,parent_dict_key                                                                                      as parent_dict_key
,leaf_node                                                                                            as leaf_node
,description                                                                                          as description
,status                                                                                               as status
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,dict_key                                                                                             as dict_key
,dict_name                                                                                            as dict_name
,dict_value                                                                                           as dict_value
,parent_dict_key                                                                                      as parent_dict_key
,leaf_node                                                                                            as leaf_node
,description                                                                                          as description
,status                                                                                               as status
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,concat_ws('_',nvl(dict_key,''))                                                                      as on_keys_conds
,_event
        from risk.ods__credit_risk_control_id_db__dict_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.dict_key') as string)                                                   as dict_key
,cast(get_json_object(data,'$.dict_name') as string)                                                  as dict_name
,cast(get_json_object(data,'$.dict_value') as string)                                                 as dict_value
,cast(get_json_object(data,'$.parent_dict_key') as string)                                            as parent_dict_key
,cast(get_json_object(data,'$.leaf_node') as byte)                                                    as leaf_node
,cast(get_json_object(data,'$.description') as string)                                                as description
,cast(get_json_object(data,'$.status') as byte)                                                       as status
,cast(get_json_object(data,'$.creator') as string)                                                    as creator
,cast(get_json_object(data,'$.create_time') as integer)                                               as create_time
,cast(get_json_object(data,'$.update_time') as integer)                                               as update_time
 
 ,concat_ws('_',nvl(get_json_object(data,'$.dict_key'),''))                                            as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_control_id_db' and base_table= 'dict_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_control_id_db__dict_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,dict_key                                                                                             as dict_key
,dict_name                                                                                            as dict_name
,dict_value                                                                                           as dict_value
,parent_dict_key                                                                                      as parent_dict_key
,leaf_node                                                                                            as leaf_node
,description                                                                                          as description
,status                                                                                               as status
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,_event
 ;