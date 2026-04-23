



refresh table risk.ccin_multi_realtime_binlog_for_my;

from (
    select 
 id                                                                                                   as id
,group_name                                                                                           as group_name
,source                                                                                               as source
,description                                                                                          as description
,version                                                                                              as version
,amount                                                                                               as amount
,tags                                                                                                 as tags
,type                                                                                                 as type
,operator                                                                                             as operator
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time

,_event
 from(
    select 
 id                                                                                                   as id
,group_name                                                                                           as group_name
,source                                                                                               as source
,description                                                                                          as description
,version                                                                                              as version
,amount                                                                                               as amount
,tags                                                                                                 as tags
,type                                                                                                 as type
,operator                                                                                             as operator
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time

 ,_event
,row_number() over(partition by on_keys_conds order by update_time desc,get_json_object(_event,'$.ts') desc, get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,group_name                                                                                           as group_name
,source                                                                                               as source
,description                                                                                          as description
,version                                                                                              as version
,amount                                                                                               as amount
,tags                                                                                                 as tags
,type                                                                                                 as type
,operator                                                                                             as operator
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time

 ,concat(nvl(group_name,''))                                                                           as on_keys_conds

,_event
        from risk.ods__credit_risk_control_my_db__policy_user_group_tab__df__private fs
        where grass_date = date_add('${grass_date}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id 
,cast(get_json_object(data,'$.group_name') as string)                                                 as group_name 
,cast(get_json_object(data,'$.source') as bigint)                                                     as source 
,cast(get_json_object(data,'$.description') as string)                                                as description 
,cast(get_json_object(data,'$.version') as bigint)                                                    as version 
,cast(get_json_object(data,'$.amount') as bigint)                                                     as amount 
,cast(get_json_object(data,'$.tags') as string)                                                       as tags 
,cast(get_json_object(data,'$.type') as bigint)                                                       as type 
,cast(get_json_object(data,'$.operator') as string)                                                   as operator 
,cast(get_json_object(data,'$.creator') as string)                                                    as creator 
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time 
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time 

 ,concat(nvl(get_json_object(data,'$.group_name'),''))                                                 as on_keys_conds

,_event
        from risk.ccin_multi_realtime_binlog_for_my 
        where base_database = 'credit_risk_control_my_db' and base_table = 'policy_user_group_tab'
        --base_database like 'credit_risk_control_my_db%' and base_table like 'policy_user_group_tab%'
        and (dt 
              between date_add('${grass_date}', -2) 
              and if('${binlog_src_end_date}' >= '${grass_date}', '${binlog_src_end_date}' ,date_add('${grass_date}', 10))
            ) 
         and from_unixtime(get_json_object(data,'$.update_time') - 0,'yyyy-MM-dd') <= '${grass_date}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)

    
insert overwrite table risk.ods__credit_risk_control_my_db__policy_user_group_tab__df__private partition(grass_date = '${grass_date}')
select 
 id                                                                                                   as id
,group_name                                                                                           as group_name
,source                                                                                               as source
,description                                                                                          as description
,version                                                                                              as version
,amount                                                                                               as amount
,tags                                                                                                 as tags
,type                                                                                                 as type
,operator                                                                                             as operator
,creator                                                                                              as creator
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time

 ,_event


;
---------------------------msck repair table for all dest dbs---------------------------------------

msck repair table risk.ods__credit_risk_control_my_db__policy_user_group_tab__df__private;

refresh table risk.ods__credit_risk_control_my_db__policy_user_group_tab__df__private;

    