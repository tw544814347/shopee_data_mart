



refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 user_id                                                                                              as user_id
,platform_type                                                                                        as platform_type
,platform_user_id                                                                                     as platform_user_id
,user_type                                                                                            as user_type
,create_time                                                                                          as create_time
,sync_tag                                                                                             as sync_tag

,_event
 from(
    select 
 user_id                                                                                              as user_id
,platform_type                                                                                        as platform_type
,platform_user_id                                                                                     as platform_user_id
,user_type                                                                                            as user_type
,create_time                                                                                          as create_time
,sync_tag                                                                                             as sync_tag

 ,_event
,row_number() over(partition by on_keys_conds order by create_time desc,get_json_object(_event,'$.ts') desc, get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 user_id                                                                                              as user_id
,platform_type                                                                                        as platform_type
,platform_user_id                                                                                     as platform_user_id
,user_type                                                                                            as user_type
,create_time                                                                                          as create_time
,sync_tag                                                                                             as sync_tag

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),user_id)               as on_keys_conds

,_event
        from risk.ods__cf_risk_underwriting_id_db__user_id_index_tab__df__private fs
        where grass_date = date_add('${grass_date}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.user_id') as decimal(20,0))                                             as user_id 
,cast(get_json_object(data,'$.platform_type') as bigint)                                              as platform_type 
,cast(get_json_object(data,'$.platform_user_id') as string)                                           as platform_user_id 
,cast(get_json_object(data,'$.user_type') as bigint)                                                  as user_type 
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time 
,cast(get_json_object(data,'$.sync_tag') as bigint)                                                   as sync_tag 

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),get_json_object(data,'$.user_id')) as on_keys_conds

,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'cf_risk_underwriting_id_db' and base_table = 'user_id_index_tab'
        --base_database like 'cf_risk_underwriting_id_db%' and base_table like 'user_id_index_tab%'
        and (dt 
              between date_add('${grass_date}', -2) 
              and if('${binlog_src_end_date}' >= '${grass_date}', '${binlog_src_end_date}' ,date_add('${grass_date}', 10))
            ) 
         and from_unixtime(get_json_object(data,'$.create_time') - 3600,'yyyy-MM-dd') <= '${grass_date}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)

    
insert overwrite table risk.ods__cf_risk_underwriting_id_db__user_id_index_tab__df__private partition(grass_date = '${grass_date}')
select 
 user_id                                                                                              as user_id
,platform_type                                                                                        as platform_type
,platform_user_id                                                                                     as platform_user_id
,user_type                                                                                            as user_type
,create_time                                                                                          as create_time
,sync_tag                                                                                             as sync_tag

 ,_event


;
---------------------------msck repair table for all dest dbs---------------------------------------

msck repair table risk.ods__cf_risk_underwriting_id_db__user_id_index_tab__df__private;

refresh table risk.ods__cf_risk_underwriting_id_db__user_id_index_tab__df__private;

    