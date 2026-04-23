



refresh table risk.ccin_multi_realtime_binlog_for_br;

from (
    select 
 id                                                                                                   as id
,pb_call                                                                                              as pb_call
,pb_path                                                                                              as pb_path
,pb_type                                                                                              as pb_type
,call_status                                                                                          as call_status
,creator                                                                                              as creator
,updater                                                                                              as updater
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,region                                                                                               as region

,_event
 from(
    select 
 id                                                                                                   as id
,pb_call                                                                                              as pb_call
,pb_path                                                                                              as pb_path
,pb_type                                                                                              as pb_type
,call_status                                                                                          as call_status
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
,pb_call                                                                                              as pb_call
,pb_path                                                                                              as pb_path
,pb_type                                                                                              as pb_type
,call_status                                                                                          as call_status
,creator                                                                                              as creator
,updater                                                                                              as updater
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,region                                                                                               as region

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)                    as on_keys_conds

,_event
        from risk.ods__credit_risk_feature_br_db__risk_feature_outer_proto_method_tab__df__private fs
        where grass_date = date_add('${grass_date}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id 
,cast(get_json_object(data,'$.pb_call') as string)                                                    as pb_call 
,cast(get_json_object(data,'$.pb_path') as string)                                                    as pb_path 
,cast(get_json_object(data,'$.pb_type') as string)                                                    as pb_type 
,cast(get_json_object(data,'$.call_status') as bigint)                                                as call_status 
,cast(get_json_object(data,'$.creator') as string)                                                    as creator 
,cast(get_json_object(data,'$.updater') as string)                                                    as updater 
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time 
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time 
,cast(get_json_object(data,'$.region') as string)                                                     as region 

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),get_json_object(data,'$.id')) as on_keys_conds

,_event
        from risk.ccin_multi_realtime_binlog_for_br 
        where base_database = 'credit_risk_feature_br_db' and base_table = 'risk_feature_outer_proto_method_tab'
        --base_database like 'credit_risk_feature_br_db%' and base_table like 'risk_feature_outer_proto_method_tab%'
        and (dt 
              between date_add('${grass_date}', -2) 
              and if('${binlog_src_end_date}' >= '${grass_date}', '${binlog_src_end_date}' ,date_add('${grass_date}', 10))
            ) 
         and from_unixtime(get_json_object(data,'$.update_time') - 39600,'yyyy-MM-dd') <= '${grass_date}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)

    
insert overwrite table risk.ods__credit_risk_feature_br_db__risk_feature_outer_proto_method_tab__df__private partition(grass_date = '${grass_date}')
select 
 id                                                                                                   as id
,pb_call                                                                                              as pb_call
,pb_path                                                                                              as pb_path
,pb_type                                                                                              as pb_type
,call_status                                                                                          as call_status
,creator                                                                                              as creator
,updater                                                                                              as updater
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,region                                                                                               as region

 ,_event


;
---------------------------msck repair table for all dest dbs---------------------------------------

msck repair table risk.ods__credit_risk_feature_br_db__risk_feature_outer_proto_method_tab__df__private;

refresh table risk.ods__credit_risk_feature_br_db__risk_feature_outer_proto_method_tab__df__private;

    