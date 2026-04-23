


refresh table risk.ccin_multi_realtime_binlog_for_br;


from (
    select 
 id                                                                                                   as id
,feature_name                                                                                         as feature_name
,category                                                                                             as category
,fit_scope                                                                                            as fit_scope
,default_value                                                                                        as default_value
,version_status                                                                                       as version_status
,tags                                                                                                 as tags
,version                                                                                              as version
,description                                                                                          as description
,status                                                                                               as status
,execute_engine                                                                                       as execute_engine
,script                                                                                               as script
,require_params                                                                                       as require_params
,query_fields                                                                                         as query_fields
,data_source                                                                                          as data_source
,template_id                                                                                          as template_id
,return_type                                                                                          as return_type
,template_param                                                                                       as template_param
,feature_extensions                                                                                   as feature_extensions
,data_source_param                                                                                    as data_source_param
,binning_rules                                                                                        as binning_rules
,creator                                                                                              as creator
,updater                                                                                              as updater
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,region                                                                                               as region

,_event
 from(
    select 
 id                                                                                                   as id
,feature_name                                                                                         as feature_name
,category                                                                                             as category
,fit_scope                                                                                            as fit_scope
,default_value                                                                                        as default_value
,version_status                                                                                       as version_status
,tags                                                                                                 as tags
,version                                                                                              as version
,description                                                                                          as description
,status                                                                                               as status
,execute_engine                                                                                       as execute_engine
,script                                                                                               as script
,require_params                                                                                       as require_params
,query_fields                                                                                         as query_fields
,data_source                                                                                          as data_source
,template_id                                                                                          as template_id
,return_type                                                                                          as return_type
,template_param                                                                                       as template_param
,feature_extensions                                                                                   as feature_extensions
,data_source_param                                                                                    as data_source_param
,binning_rules                                                                                        as binning_rules
,creator                                                                                              as creator
,updater                                                                                              as updater
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,region                                                                                               as region

 ,_event
,row_number() over(partition by on_keys_conds order by update_time desc,get_json_object(_event,'$.ts') desc, get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,feature_name                                                                                         as feature_name
,category                                                                                             as category
,fit_scope                                                                                            as fit_scope
,default_value                                                                                        as default_value
,version_status                                                                                       as version_status
,tags                                                                                                 as tags
,version                                                                                              as version
,description                                                                                          as description
,status                                                                                               as status
,execute_engine                                                                                       as execute_engine
,script                                                                                               as script
,require_params                                                                                       as require_params
,query_fields                                                                                         as query_fields
,data_source                                                                                          as data_source
,template_id                                                                                          as template_id
,return_type                                                                                          as return_type
,template_param                                                                                       as template_param
,feature_extensions                                                                                   as feature_extensions
,data_source_param                                                                                    as data_source_param
,binning_rules                                                                                        as binning_rules
,creator                                                                                              as creator
,updater                                                                                              as updater
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,region                                                                                               as region

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)                    as on_keys_conds

,_event
        from risk.ods__credit_risk_feature_br_db__risk_feature_new_tab__df__private fs
        where grass_date = date_add('${grass_date}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id 
,cast(get_json_object(data,'$.feature_name') as string)                                               as feature_name 
,cast(get_json_object(data,'$.category') as bigint)                                                   as category 
,cast(get_json_object(data,'$.fit_scope') as string)                                                  as fit_scope 
,cast(get_json_object(data,'$.default_value') as string)                                              as default_value 
,cast(get_json_object(data,'$.version_status') as bigint)                                             as version_status 
,cast(get_json_object(data,'$.tags') as string)                                                       as tags 
,cast(get_json_object(data,'$.version') as bigint)                                                    as version 
,cast(get_json_object(data,'$.description') as string)                                                as description 
,cast(get_json_object(data,'$.status') as bigint)                                                     as status 
,cast(get_json_object(data,'$.execute_engine') as string)                                             as execute_engine 
,cast(get_json_object(data,'$.script') as string)                                                     as script 
,cast(get_json_object(data,'$.require_params') as string)                                             as require_params 
,cast(get_json_object(data,'$.query_fields') as string)                                               as query_fields 
,cast(get_json_object(data,'$.data_source') as string)                                                as data_source 
,cast(get_json_object(data,'$.template_id') as bigint)                                                as template_id 
,cast(get_json_object(data,'$.return_type') as bigint)                                                as return_type 
,cast(get_json_object(data,'$.template_param') as string)                                             as template_param 
,cast(get_json_object(data,'$.feature_extensions') as string)                                         as feature_extensions 
,cast(get_json_object(data,'$.data_source_param') as string)                                          as data_source_param 
,cast(get_json_object(data,'$.binning_rules') as string)                                              as binning_rules 
,cast(get_json_object(data,'$.creator') as string)                                                    as creator 
,cast(get_json_object(data,'$.updater') as string)                                                    as updater 
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time 
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time 
,cast(get_json_object(data,'$.region') as string)                                                     as region 

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),get_json_object(data,'$.id')) as on_keys_conds

,_event
        from risk.ccin_multi_realtime_binlog_for_br 
        where base_database = 'credit_risk_feature_br_db' and base_table = 'risk_feature_new_tab'
        and (dt 
              between date_add('${grass_date}', -2) 
              and if('${binlog_src_end_date}' >= '${grass_date}', '${binlog_src_end_date}' ,date_add('${grass_date}', 10))
            ) 
         and from_unixtime(get_json_object(data,'$.update_time') - 39600,'yyyy-MM-dd') <= '${smd_grass_date}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)

    
insert overwrite table risk.ods__credit_risk_feature_br_db__risk_feature_new_tab__df__private partition(grass_date = '${smd_grass_date}')
select 
 id                                                                                                   as id
,feature_name                                                                                         as feature_name
,category                                                                                             as category
,fit_scope                                                                                            as fit_scope
,default_value                                                                                        as default_value
,version_status                                                                                       as version_status
,tags                                                                                                 as tags
,version                                                                                              as version
,description                                                                                          as description
,status                                                                                               as status
,execute_engine                                                                                       as execute_engine
,script                                                                                               as script
,require_params                                                                                       as require_params
,query_fields                                                                                         as query_fields
,data_source                                                                                          as data_source
,template_id                                                                                          as template_id
,return_type                                                                                          as return_type
,template_param                                                                                       as template_param
,feature_extensions                                                                                   as feature_extensions
,data_source_param                                                                                    as data_source_param
,binning_rules                                                                                        as binning_rules
,creator                                                                                              as creator
,updater                                                                                              as updater
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,region                                                                                               as region

 ,_event


;
---------------------------msck repair table for all dest dbs---------------------------------------

msck repair table risk.ods__credit_risk_feature_br_db__risk_feature_new_tab__df__private;

refresh table risk.ods__credit_risk_feature_br_db__risk_feature_new_tab__df__private;

    