

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,mission_id                                                                                           as mission_id
,template_id                                                                                          as template_id
,mission_name                                                                                         as mission_name
,mission_code                                                                                         as mission_code
,mission_type                                                                                         as mission_type
,mission_status                                                                                       as mission_status
,uniqueness                                                                                           as uniqueness
,will_get_score                                                                                       as will_get_score
,visible_condition                                                                                    as visible_condition
,complete_condition                                                                                   as complete_condition
,ops                                                                                                  as ops
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,display_rule_id                                                                                      as display_rule_id
 
,_event
 from(
    select 
 id                                                                                                   as id
,mission_id                                                                                           as mission_id
,template_id                                                                                          as template_id
,mission_name                                                                                         as mission_name
,mission_code                                                                                         as mission_code
,mission_type                                                                                         as mission_type
,mission_status                                                                                       as mission_status
,uniqueness                                                                                           as uniqueness
,will_get_score                                                                                       as will_get_score
,visible_condition                                                                                    as visible_condition
,complete_condition                                                                                   as complete_condition
,ops                                                                                                  as ops
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,display_rule_id                                                                                      as display_rule_id
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,mission_id                                                                                           as mission_id
,template_id                                                                                          as template_id
,mission_name                                                                                         as mission_name
,mission_code                                                                                         as mission_code
,mission_type                                                                                         as mission_type
,mission_status                                                                                       as mission_status
,uniqueness                                                                                           as uniqueness
,will_get_score                                                                                       as will_get_score
,visible_condition                                                                                    as visible_condition
,complete_condition                                                                                   as complete_condition
,ops                                                                                                  as ops
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,display_rule_id                                                                                      as display_rule_id
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_score_id_db__mission_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id
,cast(get_json_object(data,'$.mission_id') as decimal(20,0))                                          as mission_id
,cast(get_json_object(data,'$.template_id') as decimal(20,0))                                         as template_id
,cast(get_json_object(data,'$.mission_name') as string)                                               as mission_name
,cast(get_json_object(data,'$.mission_code') as string)                                               as mission_code
,cast(get_json_object(data,'$.mission_type') as bigint)                                               as mission_type
,cast(get_json_object(data,'$.mission_status') as bigint)                                             as mission_status
,cast(get_json_object(data,'$.uniqueness') as bigint)                                                 as uniqueness
,cast(get_json_object(data,'$.will_get_score') as bigint)                                             as will_get_score
,cast(get_json_object(data,'$.visible_condition') as string)                                          as visible_condition
,cast(get_json_object(data,'$.complete_condition') as string)                                         as complete_condition
,cast(get_json_object(data,'$.ops') as string)                                                        as ops
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.display_rule_id') as bigint)                                            as display_rule_id
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_score_id_db' and base_table= 'mission_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time')/1000 - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_score_id_db__mission_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,mission_id                                                                                           as mission_id
,template_id                                                                                          as template_id
,mission_name                                                                                         as mission_name
,mission_code                                                                                         as mission_code
,mission_type                                                                                         as mission_type
,mission_status                                                                                       as mission_status
,uniqueness                                                                                           as uniqueness
,will_get_score                                                                                       as will_get_score
,visible_condition                                                                                    as visible_condition
,complete_condition                                                                                   as complete_condition
,ops                                                                                                  as ops
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,display_rule_id                                                                                      as display_rule_id
 
 ,_event
 ;