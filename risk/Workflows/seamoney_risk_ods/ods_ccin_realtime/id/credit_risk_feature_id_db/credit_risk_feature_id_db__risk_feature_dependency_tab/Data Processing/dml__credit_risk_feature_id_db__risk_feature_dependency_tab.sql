

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,feature_category                                                                                     as feature_category
,feature_name                                                                                         as feature_name
,feature_version                                                                                      as feature_version
,dependency_feature_category                                                                          as dependency_feature_category
,dependency_feature_name                                                                              as dependency_feature_name
,dependency_feature_version                                                                           as dependency_feature_version
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,region                                                                                               as region
 
,_event
 from(
    select 
 id                                                                                                   as id
,feature_category                                                                                     as feature_category
,feature_name                                                                                         as feature_name
,feature_version                                                                                      as feature_version
,dependency_feature_category                                                                          as dependency_feature_category
,dependency_feature_name                                                                              as dependency_feature_name
,dependency_feature_version                                                                           as dependency_feature_version
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,region                                                                                               as region
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,feature_category                                                                                     as feature_category
,feature_name                                                                                         as feature_name
,feature_version                                                                                      as feature_version
,dependency_feature_category                                                                          as dependency_feature_category
,dependency_feature_name                                                                              as dependency_feature_name
,dependency_feature_version                                                                           as dependency_feature_version
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,region                                                                                               as region
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_feature_id_db__risk_feature_dependency_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id
,cast(get_json_object(data,'$.feature_category') as bigint)                                           as feature_category
,cast(get_json_object(data,'$.feature_name') as string)                                               as feature_name
,cast(get_json_object(data,'$.feature_version') as bigint)                                            as feature_version
,cast(get_json_object(data,'$.dependency_feature_category') as bigint)                                as dependency_feature_category
,cast(get_json_object(data,'$.dependency_feature_name') as string)                                    as dependency_feature_name
,cast(get_json_object(data,'$.dependency_feature_version') as bigint)                                 as dependency_feature_version
,cast(get_json_object(data,'$.creator') as string)                                                    as creator
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.region') as string)                                                     as region
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_feature_id_db' and base_table= 'risk_feature_dependency_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(_event,'$.ts') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_feature_id_db__risk_feature_dependency_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,feature_category                                                                                     as feature_category
,feature_name                                                                                         as feature_name
,feature_version                                                                                      as feature_version
,dependency_feature_category                                                                          as dependency_feature_category
,dependency_feature_name                                                                              as dependency_feature_name
,dependency_feature_version                                                                           as dependency_feature_version
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,region                                                                                               as region
 
 ,_event
 ;