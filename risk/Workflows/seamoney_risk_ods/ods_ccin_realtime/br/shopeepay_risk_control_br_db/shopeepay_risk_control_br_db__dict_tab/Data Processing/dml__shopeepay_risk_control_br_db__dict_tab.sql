



refresh table risk.ccin_multi_realtime_binlog_for_br;

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
,row_number() over(partition by on_keys_conds order by update_time desc,get_json_object(_event,'$.ts') desc, get_json_object(_event,'$.ts_ns') desc) as rn
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

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)                    as on_keys_conds

,_event
        from risk.ods__shopeepay_risk_control_br_db__dict_tab__df__private fs
        where grass_date = date_add('${grass_date}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id 
,cast(get_json_object(data,'$.dict_key') as string)                                                   as dict_key 
,cast(get_json_object(data,'$.dict_name') as string)                                                  as dict_name 
,cast(get_json_object(data,'$.dict_value') as string)                                                 as dict_value 
,cast(get_json_object(data,'$.parent_dict_key') as string)                                            as parent_dict_key 
,cast(get_json_object(data,'$.leaf_node') as bigint)                                                  as leaf_node 
,cast(get_json_object(data,'$.description') as string)                                                as description 
,cast(get_json_object(data,'$.status') as bigint)                                                     as status 
,cast(get_json_object(data,'$.creator') as string)                                                    as creator 
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time 
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time 

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),get_json_object(data,'$.id')) as on_keys_conds

,_event
        from risk.ccin_multi_realtime_binlog_for_br 
        where base_database = 'shopeepay_risk_control_br_db' and base_table = 'dict_tab'
        --base_database like 'shopeepay_risk_control_br_db%' and base_table like 'dict_tab%'
        and (dt 
              between date_add('${grass_date}', -2) 
              and if('${binlog_src_end_date}' >= '${grass_date}', '${binlog_src_end_date}' ,date_add('${grass_date}', 10))
            ) 
         and from_unixtime(get_json_object(data,'$.update_time') - 39600,'yyyy-MM-dd') <= '${grass_date}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)

    
insert overwrite table risk.ods__shopeepay_risk_control_br_db__dict_tab__df__private partition(grass_date = '${grass_date}')
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
---------------------------msck repair table for all dest dbs---------------------------------------

msck repair table risk.ods__shopeepay_risk_control_br_db__dict_tab__df__private;

refresh table risk.ods__shopeepay_risk_control_br_db__dict_tab__df__private;

    