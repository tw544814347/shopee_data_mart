

refresh table risk.ccin_multi_realtime_binlog_for_my;

from (
    select 
 id                                                                                                   as id
,tree_id                                                                                              as tree_id
,tree_name                                                                                            as tree_name
,node_id                                                                                              as node_id
,parent_node_id                                                                                       as parent_node_id
,depth                                                                                                as depth
,description                                                                                          as description
,create_user                                                                                          as create_user
,create_time                                                                                          as create_time
,render_id                                                                                            as render_id
,node_type                                                                                            as node_type
,node_name                                                                                            as node_name
,use_new_router                                                                                       as use_new_router
 
,_event
 from(
    select 
 id                                                                                                   as id
,tree_id                                                                                              as tree_id
,tree_name                                                                                            as tree_name
,node_id                                                                                              as node_id
,parent_node_id                                                                                       as parent_node_id
,depth                                                                                                as depth
,description                                                                                          as description
,create_user                                                                                          as create_user
,create_time                                                                                          as create_time
,render_id                                                                                            as render_id
,node_type                                                                                            as node_type
,node_name                                                                                            as node_name
,use_new_router                                                                                       as use_new_router
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,tree_id                                                                                              as tree_id
,tree_name                                                                                            as tree_name
,node_id                                                                                              as node_id
,parent_node_id                                                                                       as parent_node_id
,depth                                                                                                as depth
,description                                                                                          as description
,create_user                                                                                          as create_user
,create_time                                                                                          as create_time
,render_id                                                                                            as render_id
,node_type                                                                                            as node_type
,node_name                                                                                            as node_name
,use_new_router                                                                                       as use_new_router
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_my_db__tree_node_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id
,cast(get_json_object(data,'$.tree_id') as bigint)                                                    as tree_id
,cast(get_json_object(data,'$.tree_name') as string)                                                  as tree_name
,cast(get_json_object(data,'$.node_id') as string)                                                    as node_id
,cast(get_json_object(data,'$.parent_node_id') as string)                                             as parent_node_id
,cast(get_json_object(data,'$.depth') as bigint)                                                      as depth
,cast(get_json_object(data,'$.description') as string)                                                as description
,cast(get_json_object(data,'$.create_user') as string)                                                as create_user
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.render_id') as string)                                                  as render_id
,cast(get_json_object(data,'$.node_type') as string)                                                  as node_type
,cast(get_json_object(data,'$.node_name') as string)                                                  as node_name
,cast(get_json_object(data,'$.use_new_router') as bigint)                                             as use_new_router
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_my 
        where base_database = 'credit_risk_control_my_db' and base_table= 'tree_node_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.create_time') - 0 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_control_my_db__tree_node_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,tree_id                                                                                              as tree_id
,tree_name                                                                                            as tree_name
,node_id                                                                                              as node_id
,parent_node_id                                                                                       as parent_node_id
,depth                                                                                                as depth
,description                                                                                          as description
,create_user                                                                                          as create_user
,create_time                                                                                          as create_time
,render_id                                                                                            as render_id
,node_type                                                                                            as node_type
,node_name                                                                                            as node_name
,use_new_router                                                                                       as use_new_router
 
 ,_event
 ;