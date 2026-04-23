



refresh table risk.ccin_multi_realtime_binlog_for_br;

from (
    select 
 id                                                                                                   as id
,category                                                                                             as category
,sub_category                                                                                         as sub_category
,json_key                                                                                             as json_key
,json_path                                                                                            as json_path
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,creator                                                                                              as creator
,operator                                                                                             as operator
,region                                                                                               as region

,_event
 from(
    select 
 id                                                                                                   as id
,category                                                                                             as category
,sub_category                                                                                         as sub_category
,json_key                                                                                             as json_key
,json_path                                                                                            as json_path
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,creator                                                                                              as creator
,operator                                                                                             as operator
,region                                                                                               as region

 ,_event
,row_number() over(partition by on_keys_conds order by update_time desc,get_json_object(_event,'$.ts') desc, get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,category                                                                                             as category
,sub_category                                                                                         as sub_category
,json_key                                                                                             as json_key
,json_path                                                                                            as json_path
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,creator                                                                                              as creator
,operator                                                                                             as operator
,region                                                                                               as region

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)                    as on_keys_conds

,_event
        from risk.ods__credit_risk_feature_br_db__risk_feature_common_args_config_tab__df__private fs
        where grass_date = date_add('${grass_date}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id 
,cast(get_json_object(data,'$.category') as bigint)                                                   as category 
,cast(get_json_object(data,'$.sub_category') as string)                                               as sub_category 
,cast(get_json_object(data,'$.json_key') as string)                                                   as json_key 
,cast(get_json_object(data,'$.json_path') as string)                                                  as json_path 
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time 
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time 
,cast(get_json_object(data,'$.creator') as string)                                                    as creator 
,cast(get_json_object(data,'$.operator') as string)                                                   as operator 
,cast(get_json_object(data,'$.region') as string)                                                     as region 

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),get_json_object(data,'$.id')) as on_keys_conds

,_event
        from risk.ccin_multi_realtime_binlog_for_br 
        where base_database = 'credit_risk_feature_br_db' and base_table = 'risk_feature_common_args_config_tab'
        --base_database like 'credit_risk_feature_br_db%' and base_table like 'risk_feature_common_args_config_tab%'
        and (dt 
              between date_add('${grass_date}', -2) 
              and if('${binlog_src_end_date}' >= '${grass_date}', '${binlog_src_end_date}' ,date_add('${grass_date}', 10))
            ) 
         and from_unixtime(get_json_object(data,'$.update_time') - 39600,'yyyy-MM-dd') <= '${grass_date}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)

    
insert overwrite table risk.ods__credit_risk_feature_br_db__risk_feature_common_args_config_tab__df__private partition(grass_date = '${grass_date}')
select 
 id                                                                                                   as id
,category                                                                                             as category
,sub_category                                                                                         as sub_category
,json_key                                                                                             as json_key
,json_path                                                                                            as json_path
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,creator                                                                                              as creator
,operator                                                                                             as operator
,region                                                                                               as region

 ,_event


;
---------------------------msck repair table for all dest dbs---------------------------------------

msck repair table risk.ods__credit_risk_feature_br_db__risk_feature_common_args_config_tab__df__private;

refresh table risk.ods__credit_risk_feature_br_db__risk_feature_common_args_config_tab__df__private;

    