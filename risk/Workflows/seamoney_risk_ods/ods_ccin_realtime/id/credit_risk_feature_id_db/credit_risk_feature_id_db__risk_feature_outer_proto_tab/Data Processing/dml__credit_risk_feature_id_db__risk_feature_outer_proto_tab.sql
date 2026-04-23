

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,pb_file_name                                                                                         as pb_file_name
,pb_type                                                                                              as pb_type
,commit_id                                                                                            as commit_id
,pb_content                                                                                           as pb_content
,running_status                                                                                       as running_status
,creator                                                                                              as creator
,updater                                                                                              as updater
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,store_path                                                                                           as store_path
,region                                                                                               as region
 
,_event
 from(
    select 
 id                                                                                                   as id
,pb_file_name                                                                                         as pb_file_name
,pb_type                                                                                              as pb_type
,commit_id                                                                                            as commit_id
,pb_content                                                                                           as pb_content
,running_status                                                                                       as running_status
,creator                                                                                              as creator
,updater                                                                                              as updater
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,store_path                                                                                           as store_path
,region                                                                                               as region
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,pb_file_name                                                                                         as pb_file_name
,pb_type                                                                                              as pb_type
,commit_id                                                                                            as commit_id
,pb_content                                                                                           as pb_content
,running_status                                                                                       as running_status
,creator                                                                                              as creator
,updater                                                                                              as updater
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,store_path                                                                                           as store_path
,region                                                                                               as region
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_feature_id_db__risk_feature_outer_proto_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id
,cast(get_json_object(data,'$.pb_file_name') as string)                                               as pb_file_name
,cast(get_json_object(data,'$.pb_type') as string)                                                    as pb_type
,cast(get_json_object(data,'$.commit_id') as string)                                                  as commit_id
,cast(get_json_object(data,'$.pb_content') as string)                                                 as pb_content
,cast(get_json_object(data,'$.running_status') as bigint)                                             as running_status
,cast(get_json_object(data,'$.creator') as string)                                                    as creator
,cast(get_json_object(data,'$.updater') as string)                                                    as updater
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.store_path') as string)                                                 as store_path
,cast(get_json_object(data,'$.region') as string)                                                     as region
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_feature_id_db' and base_table= 'risk_feature_outer_proto_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_feature_id_db__risk_feature_outer_proto_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,pb_file_name                                                                                         as pb_file_name
,pb_type                                                                                              as pb_type
,commit_id                                                                                            as commit_id
,pb_content                                                                                           as pb_content
,running_status                                                                                       as running_status
,creator                                                                                              as creator
,updater                                                                                              as updater
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,store_path                                                                                           as store_path
,region                                                                                               as region
 
 ,_event
 ;