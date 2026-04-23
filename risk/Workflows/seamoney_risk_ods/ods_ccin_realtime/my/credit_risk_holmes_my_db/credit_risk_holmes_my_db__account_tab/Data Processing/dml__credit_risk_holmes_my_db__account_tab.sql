

refresh table risk.ccin_multi_realtime_binlog_for_my;

from (
    select 
 id                                                                                                   as id
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,name                                                                                                 as name
,email                                                                                                as email
,avatar                                                                                               as avatar
,permissions                                                                                          as permissions
 
,_event
 from(
    select 
 id                                                                                                   as id
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,name                                                                                                 as name
,email                                                                                                as email
,avatar                                                                                               as avatar
,permissions                                                                                          as permissions
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,name                                                                                                 as name
,email                                                                                                as email
,avatar                                                                                               as avatar
,permissions                                                                                          as permissions
 
 ,concat_ws('_',nvl(email,''))                                                                         as on_keys_conds
,_event
        from risk.ods__credit_risk_holmes_my_db__account_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as decimal(20,0))                                                  as id
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.name') as string)                                                       as name
,cast(get_json_object(data,'$.email') as string)                                                      as email
,cast(get_json_object(data,'$.avatar') as string)                                                     as avatar
,cast(get_json_object(data,'$.permissions') as string)                                                as permissions
 
 ,concat_ws('_',nvl(get_json_object(data,'$.email'),''))                                               as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_my 
        where base_database = 'credit_risk_holmes_my_db' and base_table= 'account_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 0 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_holmes_my_db__account_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,name                                                                                                 as name
,email                                                                                                as email
,avatar                                                                                               as avatar
,permissions                                                                                          as permissions
 
 ,_event
 ;