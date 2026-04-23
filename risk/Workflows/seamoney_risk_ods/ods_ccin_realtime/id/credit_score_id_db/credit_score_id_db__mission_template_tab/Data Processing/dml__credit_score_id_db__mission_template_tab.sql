



refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,mission_name                                                                                         as mission_name
,mission_code                                                                                         as mission_code
,mission_type                                                                                         as mission_type
,complete_condition                                                                                   as complete_condition
,ops                                                                                                  as ops
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time

,_event
 from(
    select 
 id                                                                                                   as id
,mission_name                                                                                         as mission_name
,mission_code                                                                                         as mission_code
,mission_type                                                                                         as mission_type
,complete_condition                                                                                   as complete_condition
,ops                                                                                                  as ops
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time

 ,_event
,row_number() over(partition by on_keys_conds order by update_time desc,get_json_object(_event,'$.ts') desc, get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,mission_name                                                                                         as mission_name
,mission_code                                                                                         as mission_code
,mission_type                                                                                         as mission_type
,complete_condition                                                                                   as complete_condition
,ops                                                                                                  as ops
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)                    as on_keys_conds

,_event
        from risk.ods__credit_score_id_db__mission_template_tab__df__private fs
        where grass_date = date_add('${grass_date}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id 
,cast(get_json_object(data,'$.mission_name') as string)                                               as mission_name 
,cast(get_json_object(data,'$.mission_code') as string)                                               as mission_code 
,cast(get_json_object(data,'$.mission_type') as bigint)                                               as mission_type 
,cast(get_json_object(data,'$.complete_condition') as string)                                         as complete_condition 
,cast(get_json_object(data,'$.ops') as string)                                                        as ops 
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time 
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time 

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),get_json_object(data,'$.id')) as on_keys_conds

,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_score_id_db' and base_table = 'mission_template_tab'
        --base_database like 'credit_score_id_db%' and base_table like 'mission_template_tab%'
        and (dt 
              between date_add('${grass_date}', -2) 
              and if('${binlog_src_end_date}' >= '${grass_date}', '${binlog_src_end_date}' ,date_add('${grass_date}', 10))
            ) 
         and from_unixtime(get_json_object(data,'$.update_time')/1000 - 3600,'yyyy-MM-dd') <= '${grass_date}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)

    
insert overwrite table risk.ods__credit_score_id_db__mission_template_tab__df__private partition(grass_date = '${grass_date}')
select 
 id                                                                                                   as id
,mission_name                                                                                         as mission_name
,mission_code                                                                                         as mission_code
,mission_type                                                                                         as mission_type
,complete_condition                                                                                   as complete_condition
,ops                                                                                                  as ops
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time

 ,_event


;
---------------------------msck repair table for all dest dbs---------------------------------------

msck repair table risk.ods__credit_score_id_db__mission_template_tab__df__private;

refresh table risk.ods__credit_score_id_db__mission_template_tab__df__private;

    