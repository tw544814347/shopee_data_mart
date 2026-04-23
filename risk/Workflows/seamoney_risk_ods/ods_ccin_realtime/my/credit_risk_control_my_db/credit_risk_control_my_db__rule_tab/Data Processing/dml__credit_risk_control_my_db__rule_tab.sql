

refresh table risk.ccin_multi_realtime_binlog_for_my;

from (
    select 
 rule_id                                                                                              as rule_id
,rule_name                                                                                            as rule_name
,op                                                                                                   as op
,feature_id                                                                                           as feature_id
,value                                                                                                as value
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,status                                                                                               as status
,label                                                                                                as label
,desc                                                                                                 as desc
 
,_event
 from(
    select 
 rule_id                                                                                              as rule_id
,rule_name                                                                                            as rule_name
,op                                                                                                   as op
,feature_id                                                                                           as feature_id
,value                                                                                                as value
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,status                                                                                               as status
,label                                                                                                as label
,desc                                                                                                 as desc
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 rule_id                                                                                              as rule_id
,rule_name                                                                                            as rule_name
,op                                                                                                   as op
,feature_id                                                                                           as feature_id
,value                                                                                                as value
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,status                                                                                               as status
,label                                                                                                as label
,desc                                                                                                 as desc
 
 ,concat_ws('_',nvl(rule_name,''),nvl(label,''))                                                       as on_keys_conds
,_event
        from risk.ods__credit_risk_control_my_db__rule_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.rule_id') as bigint)                                                    as rule_id
,cast(get_json_object(data,'$.rule_name') as string)                                                  as rule_name
,cast(get_json_object(data,'$.op') as string)                                                         as op
,cast(get_json_object(data,'$.feature_id') as bigint)                                                 as feature_id
,cast(get_json_object(data,'$.value') as string)                                                      as value
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.status') as bigint)                                                     as status
,cast(get_json_object(data,'$.label') as string)                                                      as label
,cast(get_json_object(data,'$.desc') as string)                                                       as desc
 
 ,concat_ws('_',nvl(get_json_object(data,'$.rule_name'),''),nvl(get_json_object(data,'$.label'),''))   as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_my 
        where base_database = 'credit_risk_control_my_db' and base_table= 'rule_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 0 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_control_my_db__rule_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 rule_id                                                                                              as rule_id
,rule_name                                                                                            as rule_name
,op                                                                                                   as op
,feature_id                                                                                           as feature_id
,value                                                                                                as value
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,status                                                                                               as status
,label                                                                                                as label
,desc                                                                                                 as desc
 
 ,_event
 ;