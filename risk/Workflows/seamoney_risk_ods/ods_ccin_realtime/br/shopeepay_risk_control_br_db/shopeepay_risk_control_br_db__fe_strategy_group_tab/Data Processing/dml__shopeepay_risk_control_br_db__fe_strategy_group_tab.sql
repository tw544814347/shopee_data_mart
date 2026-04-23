



refresh table risk.ccin_multi_realtime_binlog_for_br;

from (
    select 
 id                                                                                                   as id
,name                                                                                                 as name
,description                                                                                          as description
,metrics                                                                                              as metrics
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,serial_type                                                                                          as serial_type
,default_result_id                                                                                    as default_result_id
,version                                                                                              as version
,version_status                                                                                       as version_status
,status                                                                                               as status
,category                                                                                             as category
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time

,_event
 from(
    select 
 id                                                                                                   as id
,name                                                                                                 as name
,description                                                                                          as description
,metrics                                                                                              as metrics
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,serial_type                                                                                          as serial_type
,default_result_id                                                                                    as default_result_id
,version                                                                                              as version
,version_status                                                                                       as version_status
,status                                                                                               as status
,category                                                                                             as category
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time

 ,_event
,row_number() over(partition by on_keys_conds order by update_time desc,get_json_object(_event,'$.ts') desc, get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,name                                                                                                 as name
,description                                                                                          as description
,metrics                                                                                              as metrics
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,serial_type                                                                                          as serial_type
,default_result_id                                                                                    as default_result_id
,version                                                                                              as version
,version_status                                                                                       as version_status
,status                                                                                               as status
,category                                                                                             as category
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)                    as on_keys_conds

,_event
        from risk.ods__shopeepay_risk_control_br_db__fe_strategy_group_tab__df__private fs
        where grass_date = date_add('${grass_date}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id 
,cast(get_json_object(data,'$.name') as string)                                                       as name 
,cast(get_json_object(data,'$.description') as string)                                                as description 
,cast(get_json_object(data,'$.metrics') as string)                                                    as metrics 
,cast(get_json_object(data,'$.app_id') as string)                                                     as app_id 
,cast(get_json_object(data,'$.scene_id') as bigint)                                                   as scene_id 
,cast(get_json_object(data,'$.serial_type') as bigint)                                                as serial_type 
,cast(get_json_object(data,'$.default_result_id') as bigint)                                          as default_result_id 
,cast(get_json_object(data,'$.version') as bigint)                                                    as version 
,cast(get_json_object(data,'$.version_status') as bigint)                                             as version_status 
,cast(get_json_object(data,'$.status') as bigint)                                                     as status 
,cast(get_json_object(data,'$.category') as bigint)                                                   as category 
,cast(get_json_object(data,'$.creator') as string)                                                    as creator 
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time 
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time 

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),get_json_object(data,'$.id')) as on_keys_conds

,_event
        from risk.ccin_multi_realtime_binlog_for_br 
        where base_database = 'shopeepay_risk_control_br_db' and base_table = 'fe_strategy_group_tab'
        --base_database like 'shopeepay_risk_control_br_db%' and base_table like 'fe_strategy_group_tab%'
        and (dt 
              between date_add('${grass_date}', -2) 
              and if('${binlog_src_end_date}' >= '${grass_date}', '${binlog_src_end_date}' ,date_add('${grass_date}', 10))
            ) 
         and from_unixtime(get_json_object(data,'$.update_time') - 39600,'yyyy-MM-dd') <= '${grass_date}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)

    
insert overwrite table risk.ods__shopeepay_risk_control_br_db__fe_strategy_group_tab__df__private partition(grass_date = '${grass_date}')
select 
 id                                                                                                   as id
,name                                                                                                 as name
,description                                                                                          as description
,metrics                                                                                              as metrics
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,serial_type                                                                                          as serial_type
,default_result_id                                                                                    as default_result_id
,version                                                                                              as version
,version_status                                                                                       as version_status
,status                                                                                               as status
,category                                                                                             as category
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time

 ,_event


;
---------------------------msck repair table for all dest dbs---------------------------------------

msck repair table risk.ods__shopeepay_risk_control_br_db__fe_strategy_group_tab__df__private;

refresh table risk.ods__shopeepay_risk_control_br_db__fe_strategy_group_tab__df__private;

    