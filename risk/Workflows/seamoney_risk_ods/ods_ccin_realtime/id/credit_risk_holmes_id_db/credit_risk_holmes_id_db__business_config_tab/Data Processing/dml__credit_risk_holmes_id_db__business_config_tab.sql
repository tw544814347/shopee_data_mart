



refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,biz                                                                                                  as biz
,is_show                                                                                              as is_show
,version                                                                                              as version
,operator                                                                                             as operator
,config_name                                                                                          as config_name
,config_value                                                                                         as config_value
,config_desc                                                                                          as config_desc
,config_status                                                                                        as config_status
,config_modules                                                                                       as config_modules
,version_status                                                                                       as version_status

,_event
 from(
    select 
 id                                                                                                   as id
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,biz                                                                                                  as biz
,is_show                                                                                              as is_show
,version                                                                                              as version
,operator                                                                                             as operator
,config_name                                                                                          as config_name
,config_value                                                                                         as config_value
,config_desc                                                                                          as config_desc
,config_status                                                                                        as config_status
,config_modules                                                                                       as config_modules
,version_status                                                                                       as version_status

 ,_event
,row_number() over(partition by on_keys_conds order by update_time desc,get_json_object(_event,'$.ts') desc, get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,biz                                                                                                  as biz
,is_show                                                                                              as is_show
,version                                                                                              as version
,operator                                                                                             as operator
,config_name                                                                                          as config_name
,config_value                                                                                         as config_value
,config_desc                                                                                          as config_desc
,config_status                                                                                        as config_status
,config_modules                                                                                       as config_modules
,version_status                                                                                       as version_status

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)                    as on_keys_conds

,_event
        from risk.ods__credit_risk_holmes_id_db__business_config_tab__df__private fs
        where grass_date = date_add('${grass_date}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id 
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time 
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time 
,cast(get_json_object(data,'$.biz') as string)                                                        as biz 
,cast(get_json_object(data,'$.is_show') as bigint)                                                    as is_show 
,cast(get_json_object(data,'$.version') as bigint)                                                    as version 
,cast(get_json_object(data,'$.operator') as string)                                                   as operator 
,cast(get_json_object(data,'$.config_name') as string)                                                as config_name 
,cast(get_json_object(data,'$.config_value') as string)                                               as config_value 
,cast(get_json_object(data,'$.config_desc') as string)                                                as config_desc 
,cast(get_json_object(data,'$.config_status') as bigint)                                              as config_status 
,cast(get_json_object(data,'$.config_modules') as string)                                             as config_modules 
,cast(get_json_object(data,'$.version_status') as bigint)                                             as version_status 

 ,concat(get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),get_json_object(data,'$.id')) as on_keys_conds

,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_holmes_id_db' and base_table = 'business_config_tab'
        --base_database like 'credit_risk_holmes_id_db%' and base_table like 'business_config_tab%'
        and (dt 
              between date_add('${grass_date}', -2) 
              and if('${binlog_src_end_date}' >= '${grass_date}', '${binlog_src_end_date}' ,date_add('${grass_date}', 10))
            ) 
         and from_unixtime(get_json_object(data,'$.update_time') - 3600,'yyyy-MM-dd') <= '${grass_date}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)

    
insert overwrite table risk.ods__credit_risk_holmes_id_db__business_config_tab__df__private partition(grass_date = '${grass_date}')
select 
 id                                                                                                   as id
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,biz                                                                                                  as biz
,is_show                                                                                              as is_show
,version                                                                                              as version
,operator                                                                                             as operator
,config_name                                                                                          as config_name
,config_value                                                                                         as config_value
,config_desc                                                                                          as config_desc
,config_status                                                                                        as config_status
,config_modules                                                                                       as config_modules
,version_status                                                                                       as version_status

 ,_event


;
---------------------------msck repair table for all dest dbs---------------------------------------

msck repair table risk.ods__credit_risk_holmes_id_db__business_config_tab__df__private;

refresh table risk.ods__credit_risk_holmes_id_db__business_config_tab__df__private;

    