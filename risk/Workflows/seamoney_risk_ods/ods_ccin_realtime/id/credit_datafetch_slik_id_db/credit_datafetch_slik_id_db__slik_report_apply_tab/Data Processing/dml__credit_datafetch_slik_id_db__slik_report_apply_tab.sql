

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 apply_id                                                                                             as apply_id
,ktp                                                                                                  as ktp
,shopee_id                                                                                            as shopee_id
,credit_user_id                                                                                       as credit_user_id
,product_code                                                                                         as product_code
,apply_status                                                                                         as apply_status
,is_use_cache                                                                                         as is_use_cache
,apply_time                                                                                           as apply_time
,apply_finish_time                                                                                    as apply_finish_time
 
,_event
 from(
    select 
 apply_id                                                                                             as apply_id
,ktp                                                                                                  as ktp
,shopee_id                                                                                            as shopee_id
,credit_user_id                                                                                       as credit_user_id
,product_code                                                                                         as product_code
,apply_status                                                                                         as apply_status
,is_use_cache                                                                                         as is_use_cache
,apply_time                                                                                           as apply_time
,apply_finish_time                                                                                    as apply_finish_time
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 apply_id                                                                                             as apply_id
,ktp                                                                                                  as ktp
,shopee_id                                                                                            as shopee_id
,credit_user_id                                                                                       as credit_user_id
,product_code                                                                                         as product_code
,apply_status                                                                                         as apply_status
,is_use_cache                                                                                         as is_use_cache
,apply_time                                                                                           as apply_time
,apply_finish_time                                                                                    as apply_finish_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),apply_id)      as on_keys_conds
,_event
        from risk.ods__credit_datafetch_slik_id_db__slik_report_apply_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.apply_id') as bigint)                                                   as apply_id
,cast(get_json_object(data,'$.ktp') as string)                                                        as ktp
,cast(get_json_object(data,'$.shopee_id') as bigint)                                                  as shopee_id
,cast(get_json_object(data,'$.credit_user_id') as bigint)                                             as credit_user_id
,cast(get_json_object(data,'$.product_code') as string)                                               as product_code
,cast(get_json_object(data,'$.apply_status') as bigint)                                               as apply_status
,cast(get_json_object(data,'$.is_use_cache') as bigint)                                               as is_use_cache
,cast(get_json_object(data,'$.apply_time') as string)                                                 as apply_time
,cast(get_json_object(data,'$.apply_finish_time') as string)                                          as apply_finish_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.apply_id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_datafetch_slik_id_db' and base_table= 'slik_report_apply_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(unix_timestamp(get_json_object(data,'$.apply_finish_time')) + 28800 - 3600 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete' 
)
insert overwrite table risk.ods__credit_datafetch_slik_id_db__slik_report_apply_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 apply_id                                                                                             as apply_id
,ktp                                                                                                  as ktp
,shopee_id                                                                                            as shopee_id
,credit_user_id                                                                                       as credit_user_id
,product_code                                                                                         as product_code
,apply_status                                                                                         as apply_status
,is_use_cache                                                                                         as is_use_cache
,apply_time                                                                                           as apply_time
,apply_finish_time                                                                                    as apply_finish_time
 
 ,_event
 ;