

refresh table risk.ccin_multi_realtime_binlog_for_my;

from (
    select 
 id                                                                                                   as id
,template_id                                                                                          as template_id
,datasource                                                                                           as datasource
,placeholder                                                                                          as placeholder
,placeholder_choice                                                                                   as placeholder_choice
,category                                                                                             as category
,category_key                                                                                         as category_key
,context_mapping_path                                                                                 as context_mapping_path
,creator                                                                                              as creator
,updater                                                                                              as updater
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,region                                                                                               as region
 
,_event
 from(
    select 
 id                                                                                                   as id
,template_id                                                                                          as template_id
,datasource                                                                                           as datasource
,placeholder                                                                                          as placeholder
,placeholder_choice                                                                                   as placeholder_choice
,category                                                                                             as category
,category_key                                                                                         as category_key
,context_mapping_path                                                                                 as context_mapping_path
,creator                                                                                              as creator
,updater                                                                                              as updater
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,region                                                                                               as region
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,template_id                                                                                          as template_id
,datasource                                                                                           as datasource
,placeholder                                                                                          as placeholder
,placeholder_choice                                                                                   as placeholder_choice
,category                                                                                             as category
,category_key                                                                                         as category_key
,context_mapping_path                                                                                 as context_mapping_path
,creator                                                                                              as creator
,updater                                                                                              as updater
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,region                                                                                               as region
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_feature_my_db__risk_feature_template_datasource_choice_mapping_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id
,cast(get_json_object(data,'$.template_id') as decimal(20,0))                                         as template_id
,cast(get_json_object(data,'$.datasource') as string)                                                 as datasource
,cast(get_json_object(data,'$.placeholder') as string)                                                as placeholder
,cast(get_json_object(data,'$.placeholder_choice') as string)                                         as placeholder_choice
,cast(get_json_object(data,'$.category') as bigint)                                                   as category
,cast(get_json_object(data,'$.category_key') as string)                                               as category_key
,cast(get_json_object(data,'$.context_mapping_path') as string)                                       as context_mapping_path
,cast(get_json_object(data,'$.creator') as string)                                                    as creator
,cast(get_json_object(data,'$.updater') as string)                                                    as updater
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.region') as string)                                                     as region
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_my 
        where base_database = 'credit_risk_feature_my_db' and base_table= 'risk_feature_template_datasource_choice_mapping_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 0 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_feature_my_db__risk_feature_template_datasource_choice_mapping_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,template_id                                                                                          as template_id
,datasource                                                                                           as datasource
,placeholder                                                                                          as placeholder
,placeholder_choice                                                                                   as placeholder_choice
,category                                                                                             as category
,category_key                                                                                         as category_key
,context_mapping_path                                                                                 as context_mapping_path
,creator                                                                                              as creator
,updater                                                                                              as updater
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,region                                                                                               as region
 
 ,_event
 ;