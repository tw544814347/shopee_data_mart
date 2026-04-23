

refresh table risk.ccin_multi_realtime_binlog_for_ph;

from (
    select 
 id                                                                                                   as id
,archive_rule_no                                                                                      as archive_rule_no
,archive_batch_no                                                                                     as archive_batch_no
,archive_sub_batch_no                                                                                 as archive_sub_batch_no
,table_batch_index                                                                                    as table_batch_index
,db_host                                                                                              as db_host
,db_port                                                                                              as db_port
,real_db_name                                                                                         as real_db_name
,real_table_name                                                                                      as real_table_name
,pre_delete_id_list                                                                                   as pre_delete_id_list
,pre_delete_count                                                                                     as pre_delete_count
,actual_delete_count                                                                                  as actual_delete_count
,pre_delete_time                                                                                      as pre_delete_time
,actual_delete_time                                                                                   as actual_delete_time
,archive_status                                                                                       as archive_status
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,is_primary                                                                                           as is_primary
,primary_sub_batch_no                                                                                 as primary_sub_batch_no
,is_archive                                                                                           as is_archive
 
,_event
 from(
    select 
 id                                                                                                   as id
,archive_rule_no                                                                                      as archive_rule_no
,archive_batch_no                                                                                     as archive_batch_no
,archive_sub_batch_no                                                                                 as archive_sub_batch_no
,table_batch_index                                                                                    as table_batch_index
,db_host                                                                                              as db_host
,db_port                                                                                              as db_port
,real_db_name                                                                                         as real_db_name
,real_table_name                                                                                      as real_table_name
,pre_delete_id_list                                                                                   as pre_delete_id_list
,pre_delete_count                                                                                     as pre_delete_count
,actual_delete_count                                                                                  as actual_delete_count
,pre_delete_time                                                                                      as pre_delete_time
,actual_delete_time                                                                                   as actual_delete_time
,archive_status                                                                                       as archive_status
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,is_primary                                                                                           as is_primary
,primary_sub_batch_no                                                                                 as primary_sub_batch_no
,is_archive                                                                                           as is_archive
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,archive_rule_no                                                                                      as archive_rule_no
,archive_batch_no                                                                                     as archive_batch_no
,archive_sub_batch_no                                                                                 as archive_sub_batch_no
,table_batch_index                                                                                    as table_batch_index
,db_host                                                                                              as db_host
,db_port                                                                                              as db_port
,real_db_name                                                                                         as real_db_name
,real_table_name                                                                                      as real_table_name
,pre_delete_id_list                                                                                   as pre_delete_id_list
,pre_delete_count                                                                                     as pre_delete_count
,actual_delete_count                                                                                  as actual_delete_count
,pre_delete_time                                                                                      as pre_delete_time
,actual_delete_time                                                                                   as actual_delete_time
,archive_status                                                                                       as archive_status
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,is_primary                                                                                           as is_primary
,primary_sub_batch_no                                                                                 as primary_sub_batch_no
,is_archive                                                                                           as is_archive
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_archiveplatform_ph_db__archive_sub_batch_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id
,cast(get_json_object(data,'$.archive_rule_no') as decimal(20,0))                                     as archive_rule_no
,cast(get_json_object(data,'$.archive_batch_no') as string)                                           as archive_batch_no
,cast(get_json_object(data,'$.archive_sub_batch_no') as decimal(20,0))                                as archive_sub_batch_no
,cast(get_json_object(data,'$.table_batch_index') as decimal(20,0))                                   as table_batch_index
,cast(get_json_object(data,'$.db_host') as string)                                                    as db_host
,cast(get_json_object(data,'$.db_port') as bigint)                                                    as db_port
,cast(get_json_object(data,'$.real_db_name') as string)                                               as real_db_name
,cast(get_json_object(data,'$.real_table_name') as string)                                            as real_table_name
,cast(get_json_object(data,'$.pre_delete_id_list') as string)                                         as pre_delete_id_list
,cast(get_json_object(data,'$.pre_delete_count') as decimal(20,0))                                    as pre_delete_count
,cast(get_json_object(data,'$.actual_delete_count') as decimal(20,0))                                 as actual_delete_count
,cast(get_json_object(data,'$.pre_delete_time') as string)                                            as pre_delete_time
,cast(get_json_object(data,'$.actual_delete_time') as string)                                         as actual_delete_time
,cast(get_json_object(data,'$.archive_status') as tinyint)                                            as archive_status
,cast(get_json_object(data,'$.version') as bigint)                                                    as version
,cast(get_json_object(data,'$.create_time') as string)                                                as create_time
,cast(get_json_object(data,'$.update_time') as string)                                                as update_time
,cast(get_json_object(data,'$.is_primary') as bigint)                                                 as is_primary
,cast(get_json_object(data,'$.primary_sub_batch_no') as decimal(20,0))                                as primary_sub_batch_no
,cast(get_json_object(data,'$.is_archive') as bigint)                                                 as is_archive
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_ph 
        where base_database = 'credit_risk_archiveplatform_ph_db' and base_table= 'archive_sub_batch_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(unix_timestamp(get_json_object(data,'$.update_time')) + 28800 - 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and (nvl(get_json_object(_event,'$.type'),'') != 'delete' 
or (nvl(get_json_object(_event,'$.type'),'') = 'delete' and archive_batch_no is not null and archive_batch_no !='') 
) 
)
insert overwrite table risk.ods__credit_risk_archiveplatform_ph_db__archive_sub_batch_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,archive_rule_no                                                                                      as archive_rule_no
,archive_batch_no                                                                                     as archive_batch_no
,archive_sub_batch_no                                                                                 as archive_sub_batch_no
,table_batch_index                                                                                    as table_batch_index
,db_host                                                                                              as db_host
,db_port                                                                                              as db_port
,real_db_name                                                                                         as real_db_name
,real_table_name                                                                                      as real_table_name
,pre_delete_id_list                                                                                   as pre_delete_id_list
,pre_delete_count                                                                                     as pre_delete_count
,actual_delete_count                                                                                  as actual_delete_count
,pre_delete_time                                                                                      as pre_delete_time
,actual_delete_time                                                                                   as actual_delete_time
,archive_status                                                                                       as archive_status
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,is_primary                                                                                           as is_primary
,primary_sub_batch_no                                                                                 as primary_sub_batch_no
,is_archive                                                                                           as is_archive
 
 ,_event
 ;