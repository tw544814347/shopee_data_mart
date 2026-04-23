

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,voucher_id                                                                                           as voucher_id
,promotion_id                                                                                         as promotion_id
,claim_start_time                                                                                     as claim_start_time
,claim_success_time                                                                                   as claim_success_time
,claim_failed_time                                                                                    as claim_failed_time
,claim_failed_reason                                                                                  as claim_failed_reason
,claim_status                                                                                         as claim_status
,dispatch_status                                                                                      as dispatch_status
,ops                                                                                                  as ops
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
,_event
 from(
    select 
 id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,voucher_id                                                                                           as voucher_id
,promotion_id                                                                                         as promotion_id
,claim_start_time                                                                                     as claim_start_time
,claim_success_time                                                                                   as claim_success_time
,claim_failed_time                                                                                    as claim_failed_time
,claim_failed_reason                                                                                  as claim_failed_reason
,claim_status                                                                                         as claim_status
,dispatch_status                                                                                      as dispatch_status
,ops                                                                                                  as ops
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,voucher_id                                                                                           as voucher_id
,promotion_id                                                                                         as promotion_id
,claim_start_time                                                                                     as claim_start_time
,claim_success_time                                                                                   as claim_success_time
,claim_failed_time                                                                                    as claim_failed_time
,claim_failed_reason                                                                                  as claim_failed_reason
,claim_status                                                                                         as claim_status
,dispatch_status                                                                                      as dispatch_status
,ops                                                                                                  as ops
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__smeter_score_id_db__user_voucher_record_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.platform_user_id') as string)                                           as platform_user_id
,cast(get_json_object(data,'$.platform_type') as bigint)                                              as platform_type
,cast(get_json_object(data,'$.voucher_id') as bigint)                                                 as voucher_id
,cast(get_json_object(data,'$.promotion_id') as string)                                               as promotion_id
,cast(get_json_object(data,'$.claim_start_time') as bigint)                                           as claim_start_time
,cast(get_json_object(data,'$.claim_success_time') as bigint)                                         as claim_success_time
,cast(get_json_object(data,'$.claim_failed_time') as bigint)                                          as claim_failed_time
,cast(get_json_object(data,'$.claim_failed_reason') as string)                                        as claim_failed_reason
,cast(get_json_object(data,'$.claim_status') as bigint)                                               as claim_status
,cast(get_json_object(data,'$.dispatch_status') as bigint)                                            as dispatch_status
,cast(get_json_object(data,'$.ops') as string)                                                        as ops
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'smeter_score_id_db' and base_table= 'user_voucher_record_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time')/1000 - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete' 
)
insert overwrite table risk.ods__smeter_score_id_db__user_voucher_record_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,voucher_id                                                                                           as voucher_id
,promotion_id                                                                                         as promotion_id
,claim_start_time                                                                                     as claim_start_time
,claim_success_time                                                                                   as claim_success_time
,claim_failed_time                                                                                    as claim_failed_time
,claim_failed_reason                                                                                  as claim_failed_reason
,claim_status                                                                                         as claim_status
,dispatch_status                                                                                      as dispatch_status
,ops                                                                                                  as ops
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
 
 ,_event
 ;