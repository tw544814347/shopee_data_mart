

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,screen_id                                                                                            as screen_id
,req_no                                                                                               as req_no
,product_code                                                                                         as product_code
,screen_type                                                                                          as screen_type
,screen_source                                                                                        as screen_source
,apply_type                                                                                           as apply_type
,category                                                                                             as category
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,credit_user_id                                                                                       as credit_user_id
,credit_corp_id                                                                                       as credit_corp_id
,user_name                                                                                            as user_name
,id_card_no                                                                                           as id_card_no
,id_card_type                                                                                         as id_card_type
,first_order_time                                                                                     as first_order_time
,screen_status                                                                                        as screen_status
,task_result                                                                                          as task_result
,screen_result                                                                                        as screen_result
,reject_code                                                                                          as reject_code
,maker_result                                                                                         as maker_result
,maker_submit_time                                                                                    as maker_submit_time
,maker                                                                                                as maker
,maker_map_no                                                                                         as maker_map_no
,checker_result                                                                                       as checker_result
,checker_submit_time                                                                                  as checker_submit_time
,checker                                                                                              as checker
,checker_map_no                                                                                       as checker_map_no
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,screen_info                                                                                          as screen_info
,screen_tpl_uuid                                                                                      as screen_tpl_uuid
,is_skip                                                                                              as is_skip
,maker_checker_attr                                                                                   as maker_checker_attr
,skip_reason                                                                                          as skip_reason
,skip_operator                                                                                        as skip_operator
,skip_operator_map_no                                                                                 as skip_operator_map_no
,skip_time                                                                                            as skip_time
,shop_id                                                                                              as shop_id
,maker_start_time                                                                                     as maker_start_time
,checker_start_time                                                                                   as checker_start_time
,assignee                                                                                             as assignee
,notes                                                                                                as notes
,risk_result_type                                                                                     as risk_result_type
,from_source                                                                                          as from_source
,user_name_encrypt                                                                                    as user_name_encrypt
,id_card_no_encrypt                                                                                   as id_card_no_encrypt
,screen_info_encrypt                                                                                  as screen_info_encrypt
,order_field                                                                                          as order_field
,archive_batch_no                                                                                     as archive_batch_no
,priority                                                                                             as priority
,original_platform_type                                                                               as original_platform_type
,shopeepay_user_id                                                                                    as shopeepay_user_id
 
,_event
 from(
    select 
 id                                                                                                   as id
,screen_id                                                                                            as screen_id
,req_no                                                                                               as req_no
,product_code                                                                                         as product_code
,screen_type                                                                                          as screen_type
,screen_source                                                                                        as screen_source
,apply_type                                                                                           as apply_type
,category                                                                                             as category
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,credit_user_id                                                                                       as credit_user_id
,credit_corp_id                                                                                       as credit_corp_id
,user_name                                                                                            as user_name
,id_card_no                                                                                           as id_card_no
,id_card_type                                                                                         as id_card_type
,first_order_time                                                                                     as first_order_time
,screen_status                                                                                        as screen_status
,task_result                                                                                          as task_result
,screen_result                                                                                        as screen_result
,reject_code                                                                                          as reject_code
,maker_result                                                                                         as maker_result
,maker_submit_time                                                                                    as maker_submit_time
,maker                                                                                                as maker
,maker_map_no                                                                                         as maker_map_no
,checker_result                                                                                       as checker_result
,checker_submit_time                                                                                  as checker_submit_time
,checker                                                                                              as checker
,checker_map_no                                                                                       as checker_map_no
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,screen_info                                                                                          as screen_info
,screen_tpl_uuid                                                                                      as screen_tpl_uuid
,is_skip                                                                                              as is_skip
,maker_checker_attr                                                                                   as maker_checker_attr
,skip_reason                                                                                          as skip_reason
,skip_operator                                                                                        as skip_operator
,skip_operator_map_no                                                                                 as skip_operator_map_no
,skip_time                                                                                            as skip_time
,shop_id                                                                                              as shop_id
,maker_start_time                                                                                     as maker_start_time
,checker_start_time                                                                                   as checker_start_time
,assignee                                                                                             as assignee
,notes                                                                                                as notes
,risk_result_type                                                                                     as risk_result_type
,from_source                                                                                          as from_source
,user_name_encrypt                                                                                    as user_name_encrypt
,id_card_no_encrypt                                                                                   as id_card_no_encrypt
,screen_info_encrypt                                                                                  as screen_info_encrypt
,order_field                                                                                          as order_field
,archive_batch_no                                                                                     as archive_batch_no
,priority                                                                                             as priority
,original_platform_type                                                                               as original_platform_type
,shopeepay_user_id                                                                                    as shopeepay_user_id
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,screen_id                                                                                            as screen_id
,req_no                                                                                               as req_no
,product_code                                                                                         as product_code
,screen_type                                                                                          as screen_type
,screen_source                                                                                        as screen_source
,apply_type                                                                                           as apply_type
,category                                                                                             as category
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,credit_user_id                                                                                       as credit_user_id
,credit_corp_id                                                                                       as credit_corp_id
,user_name                                                                                            as user_name
,id_card_no                                                                                           as id_card_no
,id_card_type                                                                                         as id_card_type
,first_order_time                                                                                     as first_order_time
,screen_status                                                                                        as screen_status
,task_result                                                                                          as task_result
,screen_result                                                                                        as screen_result
,reject_code                                                                                          as reject_code
,maker_result                                                                                         as maker_result
,maker_submit_time                                                                                    as maker_submit_time
,maker                                                                                                as maker
,maker_map_no                                                                                         as maker_map_no
,checker_result                                                                                       as checker_result
,checker_submit_time                                                                                  as checker_submit_time
,checker                                                                                              as checker
,checker_map_no                                                                                       as checker_map_no
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,screen_info                                                                                          as screen_info
,screen_tpl_uuid                                                                                      as screen_tpl_uuid
,is_skip                                                                                              as is_skip
,maker_checker_attr                                                                                   as maker_checker_attr
,skip_reason                                                                                          as skip_reason
,skip_operator                                                                                        as skip_operator
,skip_operator_map_no                                                                                 as skip_operator_map_no
,skip_time                                                                                            as skip_time
,shop_id                                                                                              as shop_id
,maker_start_time                                                                                     as maker_start_time
,checker_start_time                                                                                   as checker_start_time
,assignee                                                                                             as assignee
,notes                                                                                                as notes
,risk_result_type                                                                                     as risk_result_type
,from_source                                                                                          as from_source
,user_name_encrypt                                                                                    as user_name_encrypt
,id_card_no_encrypt                                                                                   as id_card_no_encrypt
,screen_info_encrypt                                                                                  as screen_info_encrypt
,order_field                                                                                          as order_field
,archive_batch_no                                                                                     as archive_batch_no
,priority                                                                                             as priority
,original_platform_type                                                                               as original_platform_type
,shopeepay_user_id                                                                                    as shopeepay_user_id
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_id_cf_db__screen_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.screen_id') as string)                                                  as screen_id
,cast(get_json_object(data,'$.req_no') as string)                                                     as req_no
,cast(get_json_object(data,'$.product_code') as string)                                               as product_code
,cast(get_json_object(data,'$.screen_type') as string)                                                as screen_type
,cast(get_json_object(data,'$.screen_source') as string)                                              as screen_source
,cast(get_json_object(data,'$.apply_type') as string)                                                 as apply_type
,cast(get_json_object(data,'$.category') as bigint)                                                   as category
,cast(get_json_object(data,'$.app_id') as string)                                                     as app_id
,cast(get_json_object(data,'$.scene_id') as bigint)                                                   as scene_id
,cast(get_json_object(data,'$.platform_user_id') as string)                                           as platform_user_id
,cast(get_json_object(data,'$.platform_type') as bigint)                                              as platform_type
,cast(get_json_object(data,'$.credit_user_id') as bigint)                                             as credit_user_id
,cast(get_json_object(data,'$.credit_corp_id') as bigint)                                             as credit_corp_id
,cast(get_json_object(data,'$.user_name') as string)                                                  as user_name
,cast(get_json_object(data,'$.id_card_no') as string)                                                 as id_card_no
,cast(get_json_object(data,'$.id_card_type') as bigint)                                               as id_card_type
,cast(get_json_object(data,'$.first_order_time') as bigint)                                           as first_order_time
,cast(get_json_object(data,'$.screen_status') as bigint)                                              as screen_status
,cast(get_json_object(data,'$.task_result') as bigint)                                                as task_result
,cast(get_json_object(data,'$.screen_result') as bigint)                                              as screen_result
,cast(get_json_object(data,'$.reject_code') as string)                                                as reject_code
,cast(get_json_object(data,'$.maker_result') as bigint)                                               as maker_result
,cast(get_json_object(data,'$.maker_submit_time') as bigint)                                          as maker_submit_time
,cast(get_json_object(data,'$.maker') as string)                                                      as maker
,cast(get_json_object(data,'$.maker_map_no') as string)                                               as maker_map_no
,cast(get_json_object(data,'$.checker_result') as bigint)                                             as checker_result
,cast(get_json_object(data,'$.checker_submit_time') as bigint)                                        as checker_submit_time
,cast(get_json_object(data,'$.checker') as string)                                                    as checker
,cast(get_json_object(data,'$.checker_map_no') as string)                                             as checker_map_no
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.screen_info') as string)                                                as screen_info
,cast(get_json_object(data,'$.screen_tpl_uuid') as string)                                            as screen_tpl_uuid
,cast(get_json_object(data,'$.is_skip') as bigint)                                                    as is_skip
,cast(get_json_object(data,'$.maker_checker_attr') as bigint)                                         as maker_checker_attr
,cast(get_json_object(data,'$.skip_reason') as string)                                                as skip_reason
,cast(get_json_object(data,'$.skip_operator') as string)                                              as skip_operator
,cast(get_json_object(data,'$.skip_operator_map_no') as string)                                       as skip_operator_map_no
,cast(get_json_object(data,'$.skip_time') as bigint)                                                  as skip_time
,cast(get_json_object(data,'$.shop_id') as string)                                                    as shop_id
,cast(get_json_object(data,'$.maker_start_time') as bigint)                                           as maker_start_time
,cast(get_json_object(data,'$.checker_start_time') as bigint)                                         as checker_start_time
,cast(get_json_object(data,'$.assignee') as string)                                                   as assignee
,cast(get_json_object(data,'$.notes') as string)                                                      as notes
,cast(get_json_object(data,'$.risk_result_type') as bigint)                                           as risk_result_type
,cast(get_json_object(data,'$.from_source') as string)                                                as from_source
,cast(get_json_object(data,'$.user_name_encrypt') as string)                                          as user_name_encrypt
,cast(get_json_object(data,'$.id_card_no_encrypt') as string)                                         as id_card_no_encrypt
,cast(get_json_object(data,'$.screen_info_encrypt') as string)                                        as screen_info_encrypt
,cast(get_json_object(data,'$.order_field') as string)                                                as order_field
,cast(get_json_object(data,'$.archive_batch_no') as string)                                           as archive_batch_no
,cast(get_json_object(data,'$.priority') as bigint)                                                   as priority
,cast(get_json_object(data,'$.original_platform_type') as bigint)                                     as original_platform_type
,cast(get_json_object(data,'$.shopeepay_user_id') as string)                                          as shopeepay_user_id
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_control_id_cf_db' and base_table= 'screen_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and (nvl(get_json_object(_event,'$.type'),'') != 'delete' 
or (nvl(get_json_object(_event,'$.type'),'') = 'delete' and archive_batch_no is not null and archive_batch_no !='') 
) 
)
insert overwrite table risk.ods__credit_risk_control_id_cf_db__screen_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,screen_id                                                                                            as screen_id
,req_no                                                                                               as req_no
,product_code                                                                                         as product_code
,screen_type                                                                                          as screen_type
,screen_source                                                                                        as screen_source
,apply_type                                                                                           as apply_type
,category                                                                                             as category
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,credit_user_id                                                                                       as credit_user_id
,credit_corp_id                                                                                       as credit_corp_id
,user_name                                                                                            as user_name
,id_card_no                                                                                           as id_card_no
,id_card_type                                                                                         as id_card_type
,first_order_time                                                                                     as first_order_time
,screen_status                                                                                        as screen_status
,task_result                                                                                          as task_result
,screen_result                                                                                        as screen_result
,reject_code                                                                                          as reject_code
,maker_result                                                                                         as maker_result
,maker_submit_time                                                                                    as maker_submit_time
,maker                                                                                                as maker
,maker_map_no                                                                                         as maker_map_no
,checker_result                                                                                       as checker_result
,checker_submit_time                                                                                  as checker_submit_time
,checker                                                                                              as checker
,checker_map_no                                                                                       as checker_map_no
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,screen_info                                                                                          as screen_info
,screen_tpl_uuid                                                                                      as screen_tpl_uuid
,is_skip                                                                                              as is_skip
,maker_checker_attr                                                                                   as maker_checker_attr
,skip_reason                                                                                          as skip_reason
,skip_operator                                                                                        as skip_operator
,skip_operator_map_no                                                                                 as skip_operator_map_no
,skip_time                                                                                            as skip_time
,shop_id                                                                                              as shop_id
,maker_start_time                                                                                     as maker_start_time
,checker_start_time                                                                                   as checker_start_time
,assignee                                                                                             as assignee
,notes                                                                                                as notes
,risk_result_type                                                                                     as risk_result_type
,from_source                                                                                          as from_source
,user_name_encrypt                                                                                    as user_name_encrypt
,id_card_no_encrypt                                                                                   as id_card_no_encrypt
,screen_info_encrypt                                                                                  as screen_info_encrypt
,order_field                                                                                          as order_field
,archive_batch_no                                                                                     as archive_batch_no
,priority                                                                                             as priority
,original_platform_type                                                                               as original_platform_type
,shopeepay_user_id                                                                                    as shopeepay_user_id
 
 ,_event
 ;