

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,template_name                                                                                        as template_name
,placeholder_params                                                                                   as placeholder_params
,datasource                                                                                           as datasource
,datasource_placeholder_params                                                                        as datasource_placeholder_params
,result                                                                                               as result
,remark                                                                                               as remark
,dependency                                                                                           as dependency
,desc_version                                                                                         as desc_version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,template_desc                                                                                        as template_desc
,region                                                                                               as region
 
,_event
 from(
    select 
 id                                                                                                   as id
,template_name                                                                                        as template_name
,placeholder_params                                                                                   as placeholder_params
,datasource                                                                                           as datasource
,datasource_placeholder_params                                                                        as datasource_placeholder_params
,result                                                                                               as result
,remark                                                                                               as remark
,dependency                                                                                           as dependency
,desc_version                                                                                         as desc_version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,template_desc                                                                                        as template_desc
,region                                                                                               as region
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,template_name                                                                                        as template_name
,placeholder_params                                                                                   as placeholder_params
,datasource                                                                                           as datasource
,datasource_placeholder_params                                                                        as datasource_placeholder_params
,result                                                                                               as result
,remark                                                                                               as remark
,dependency                                                                                           as dependency
,desc_version                                                                                         as desc_version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,template_desc                                                                                        as template_desc
,region                                                                                               as region
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_feature_id_db__risk_feature_template_desc_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id
,cast(get_json_object(data,'$.template_name') as string)                                              as template_name
,cast(get_json_object(data,'$.placeholder_params') as string)                                         as placeholder_params
,cast(get_json_object(data,'$.datasource') as string)                                                 as datasource
,cast(get_json_object(data,'$.datasource_placeholder_params') as string)                              as datasource_placeholder_params
,cast(get_json_object(data,'$.result') as string)                                                     as result
,cast(get_json_object(data,'$.remark') as string)                                                     as remark
,cast(get_json_object(data,'$.dependency') as string)                                                 as dependency
,cast(get_json_object(data,'$.desc_version') as string)                                               as desc_version
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.template_desc') as string)                                              as template_desc
,cast(get_json_object(data,'$.region') as string)                                                     as region
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_feature_id_db' and base_table= 'risk_feature_template_desc_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_feature_id_db__risk_feature_template_desc_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,template_name                                                                                        as template_name
,placeholder_params                                                                                   as placeholder_params
,datasource                                                                                           as datasource
,datasource_placeholder_params                                                                        as datasource_placeholder_params
,result                                                                                               as result
,remark                                                                                               as remark
,dependency                                                                                           as dependency
,desc_version                                                                                         as desc_version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,template_desc                                                                                        as template_desc
,region                                                                                               as region
 
 ,_event
 ;