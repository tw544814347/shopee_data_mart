

refresh table risk.ccin_multi_realtime_binlog_for_my;

from (
    select 
 id                                                                                                   as id
,ori_id                                                                                               as ori_id
,l1_rule_name                                                                                         as l1_rule_name
,l1_rule_script                                                                                       as l1_rule_script
,metrics                                                                                              as metrics
,expression                                                                                           as expression
,extention                                                                                            as extention
,version                                                                                              as version
,description                                                                                          as description
,status                                                                                               as status
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,category                                                                                             as category
,version_status                                                                                       as version_status
,metrics_combination                                                                                  as metrics_combination
,features                                                                                             as features
,feature_combinations                                                                                 as feature_combinations
 
,_event
 from(
    select 
 id                                                                                                   as id
,ori_id                                                                                               as ori_id
,l1_rule_name                                                                                         as l1_rule_name
,l1_rule_script                                                                                       as l1_rule_script
,metrics                                                                                              as metrics
,expression                                                                                           as expression
,extention                                                                                            as extention
,version                                                                                              as version
,description                                                                                          as description
,status                                                                                               as status
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,category                                                                                             as category
,version_status                                                                                       as version_status
,metrics_combination                                                                                  as metrics_combination
,features                                                                                             as features
,feature_combinations                                                                                 as feature_combinations
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,ori_id                                                                                               as ori_id
,l1_rule_name                                                                                         as l1_rule_name
,l1_rule_script                                                                                       as l1_rule_script
,metrics                                                                                              as metrics
,expression                                                                                           as expression
,extention                                                                                            as extention
,version                                                                                              as version
,description                                                                                          as description
,status                                                                                               as status
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,category                                                                                             as category
,version_status                                                                                       as version_status
,metrics_combination                                                                                  as metrics_combination
,features                                                                                             as features
,feature_combinations                                                                                 as feature_combinations
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_my_db__strategy_l1_rule_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.ori_id') as bigint)                                                     as ori_id
,cast(get_json_object(data,'$.l1_rule_name') as string)                                               as l1_rule_name
,cast(get_json_object(data,'$.l1_rule_script') as string)                                             as l1_rule_script
,cast(get_json_object(data,'$.metrics') as string)                                                    as metrics
,cast(get_json_object(data,'$.expression') as string)                                                 as expression
,cast(get_json_object(data,'$.extention') as string)                                                  as extention
,cast(get_json_object(data,'$.version') as bigint)                                                    as version
,cast(get_json_object(data,'$.description') as string)                                                as description
,cast(get_json_object(data,'$.status') as bigint)                                                     as status
,cast(get_json_object(data,'$.creator') as string)                                                    as creator
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.category') as bigint)                                                   as category
,cast(get_json_object(data,'$.version_status') as bigint)                                             as version_status
,cast(get_json_object(data,'$.metrics_combination') as string)                                        as metrics_combination
,cast(get_json_object(data,'$.features') as string)                                                   as features
,cast(get_json_object(data,'$.feature_combinations') as string)                                       as feature_combinations
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_my 
        where base_database = 'credit_risk_control_my_db' and base_table= 'strategy_l1_rule_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 0 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_control_my_db__strategy_l1_rule_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,ori_id                                                                                               as ori_id
,l1_rule_name                                                                                         as l1_rule_name
,l1_rule_script                                                                                       as l1_rule_script
,metrics                                                                                              as metrics
,expression                                                                                           as expression
,extention                                                                                            as extention
,version                                                                                              as version
,description                                                                                          as description
,status                                                                                               as status
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,category                                                                                             as category
,version_status                                                                                       as version_status
,metrics_combination                                                                                  as metrics_combination
,features                                                                                             as features
,feature_combinations                                                                                 as feature_combinations
 
 ,_event
 ;