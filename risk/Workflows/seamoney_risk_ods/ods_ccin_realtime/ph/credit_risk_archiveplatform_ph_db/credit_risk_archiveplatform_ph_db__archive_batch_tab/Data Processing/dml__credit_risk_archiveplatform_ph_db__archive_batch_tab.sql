

refresh table risk.ccin_multi_realtime_binlog_for_ph;

from (
    select 
 id                                                                                                   as id
,archive_batch_no                                                                                     as archive_batch_no
,archive_status                                                                                       as archive_status
,archive_rule_no                                                                                      as archive_rule_no
,archive_rule_version                                                                                 as archive_rule_version
,pre_delete_total_count                                                                               as pre_delete_total_count
,actual_delete_total_count                                                                            as actual_delete_total_count
,pre_delete_time                                                                                      as pre_delete_time
,confirm_delete_time                                                                                  as confirm_delete_time
,actual_delete_time                                                                                   as actual_delete_time
,biz_date                                                                                             as biz_date
,remark                                                                                               as remark
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,logic_db_name                                                                                        as logic_db_name
,logic_table_name_list                                                                                as logic_table_name_list
,upload_succ_time                                                                                     as upload_succ_time
,is_cross_db                                                                                          as is_cross_db
,is_field_archive                                                                                     as is_field_archive
,logic_db_and_tab_info_cross_db                                                                       as logic_db_and_tab_info_cross_db
 
,_event
 from(
    select 
 id                                                                                                   as id
,archive_batch_no                                                                                     as archive_batch_no
,archive_status                                                                                       as archive_status
,archive_rule_no                                                                                      as archive_rule_no
,archive_rule_version                                                                                 as archive_rule_version
,pre_delete_total_count                                                                               as pre_delete_total_count
,actual_delete_total_count                                                                            as actual_delete_total_count
,pre_delete_time                                                                                      as pre_delete_time
,confirm_delete_time                                                                                  as confirm_delete_time
,actual_delete_time                                                                                   as actual_delete_time
,biz_date                                                                                             as biz_date
,remark                                                                                               as remark
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,logic_db_name                                                                                        as logic_db_name
,logic_table_name_list                                                                                as logic_table_name_list
,upload_succ_time                                                                                     as upload_succ_time
,is_cross_db                                                                                          as is_cross_db
,is_field_archive                                                                                     as is_field_archive
,logic_db_and_tab_info_cross_db                                                                       as logic_db_and_tab_info_cross_db
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,archive_batch_no                                                                                     as archive_batch_no
,archive_status                                                                                       as archive_status
,archive_rule_no                                                                                      as archive_rule_no
,archive_rule_version                                                                                 as archive_rule_version
,pre_delete_total_count                                                                               as pre_delete_total_count
,actual_delete_total_count                                                                            as actual_delete_total_count
,pre_delete_time                                                                                      as pre_delete_time
,confirm_delete_time                                                                                  as confirm_delete_time
,actual_delete_time                                                                                   as actual_delete_time
,biz_date                                                                                             as biz_date
,remark                                                                                               as remark
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,logic_db_name                                                                                        as logic_db_name
,logic_table_name_list                                                                                as logic_table_name_list
,upload_succ_time                                                                                     as upload_succ_time
,is_cross_db                                                                                          as is_cross_db
,is_field_archive                                                                                     as is_field_archive
,logic_db_and_tab_info_cross_db                                                                       as logic_db_and_tab_info_cross_db
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_archiveplatform_ph_db__archive_batch_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id
,cast(get_json_object(data,'$.archive_batch_no') as string)                                           as archive_batch_no
,cast(get_json_object(data,'$.archive_status') as tinyint)                                            as archive_status
,cast(get_json_object(data,'$.archive_rule_no') as decimal(20,0))                                     as archive_rule_no
,cast(get_json_object(data,'$.archive_rule_version') as bigint)                                       as archive_rule_version
,cast(get_json_object(data,'$.pre_delete_total_count') as decimal(20,0))                              as pre_delete_total_count
,cast(get_json_object(data,'$.actual_delete_total_count') as decimal(20,0))                           as actual_delete_total_count
,cast(get_json_object(data,'$.pre_delete_time') as string)                                            as pre_delete_time
,cast(get_json_object(data,'$.confirm_delete_time') as string)                                        as confirm_delete_time
,cast(get_json_object(data,'$.actual_delete_time') as string)                                         as actual_delete_time
,cast(get_json_object(data,'$.biz_date') as string)                                                   as biz_date
,cast(get_json_object(data,'$.remark') as string)                                                     as remark
,cast(get_json_object(data,'$.version') as bigint)                                                    as version
,cast(get_json_object(data,'$.create_time') as string)                                                as create_time
,cast(get_json_object(data,'$.update_time') as string)                                                as update_time
,cast(get_json_object(data,'$.logic_db_name') as string)                                              as logic_db_name
,cast(get_json_object(data,'$.logic_table_name_list') as string)                                      as logic_table_name_list
,cast(get_json_object(data,'$.upload_succ_time') as string)                                           as upload_succ_time
,cast(get_json_object(data,'$.is_cross_db') as bigint)                                                as is_cross_db
,cast(get_json_object(data,'$.is_field_archive') as bigint)                                           as is_field_archive
,cast(get_json_object(data,'$.logic_db_and_tab_info_cross_db') as string)                             as logic_db_and_tab_info_cross_db
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_ph 
        where base_database = 'credit_risk_archiveplatform_ph_db' and base_table= 'archive_batch_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(unix_timestamp(get_json_object(data,'$.update_time')) + 28800 - 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and (nvl(get_json_object(_event,'$.type'),'') != 'delete' 
or (nvl(get_json_object(_event,'$.type'),'') = 'delete' and archive_batch_no is not null and archive_batch_no !='') 
) 
)
insert overwrite table risk.ods__credit_risk_archiveplatform_ph_db__archive_batch_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,archive_batch_no                                                                                     as archive_batch_no
,archive_status                                                                                       as archive_status
,archive_rule_no                                                                                      as archive_rule_no
,archive_rule_version                                                                                 as archive_rule_version
,pre_delete_total_count                                                                               as pre_delete_total_count
,actual_delete_total_count                                                                            as actual_delete_total_count
,pre_delete_time                                                                                      as pre_delete_time
,confirm_delete_time                                                                                  as confirm_delete_time
,actual_delete_time                                                                                   as actual_delete_time
,biz_date                                                                                             as biz_date
,remark                                                                                               as remark
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,logic_db_name                                                                                        as logic_db_name
,logic_table_name_list                                                                                as logic_table_name_list
,upload_succ_time                                                                                     as upload_succ_time
,is_cross_db                                                                                          as is_cross_db
,is_field_archive                                                                                     as is_field_archive
,logic_db_and_tab_info_cross_db                                                                       as logic_db_and_tab_info_cross_db
 
 ,_event
 ;