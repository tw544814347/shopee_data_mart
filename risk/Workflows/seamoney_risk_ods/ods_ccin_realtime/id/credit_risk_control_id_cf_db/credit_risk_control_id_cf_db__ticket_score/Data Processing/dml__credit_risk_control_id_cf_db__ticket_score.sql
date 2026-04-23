

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,ticket_id                                                                                            as ticket_id
,product_code                                                                                         as product_code
,result                                                                                               as result
,ticket_completed_time                                                                                as ticket_completed_time
,platform_user_id                                                                                     as platform_user_id
,credit_user_id                                                                                       as credit_user_id
,maker_checker_attr                                                                                   as maker_checker_attr
,category                                                                                             as category
,status                                                                                               as status
,maker                                                                                                as maker
,id_card_type                                                                                         as id_card_type
,maker_notes                                                                                          as maker_notes
,checker                                                                                              as checker
,checker_notes                                                                                        as checker_notes
,scorer                                                                                               as scorer
,scorer_notes                                                                                         as scorer_notes
,start_time                                                                                           as start_time
,end_time                                                                                             as end_time
,score_info                                                                                           as score_info
,score_config                                                                                         as score_config
,screen_type                                                                                          as screen_type
,risk_result_type                                                                                     as risk_result_type
,reject_reason                                                                                        as reject_reason
,source                                                                                               as source
,create_date                                                                                          as create_date
,creator                                                                                              as creator
,ticket_category                                                                                      as ticket_category
,qa_ticket_id                                                                                         as qa_ticket_id
,priority                                                                                             as priority
,expiry_time                                                                                          as expiry_time
,sub_topic                                                                                            as sub_topic
,spp_info                                                                                             as spp_info
,topic                                                                                                as topic
,modified_by_notes                                                                                    as modified_by_notes
,modified_by                                                                                          as modified_by
,order_field                                                                                          as order_field
,archive_batch_no                                                                                     as archive_batch_no
,original_platform_type                                                                               as original_platform_type
,shopeepay_user_id                                                                                    as shopeepay_user_id
 
,_event
 from(
    select 
 id                                                                                                   as id
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,ticket_id                                                                                            as ticket_id
,product_code                                                                                         as product_code
,result                                                                                               as result
,ticket_completed_time                                                                                as ticket_completed_time
,platform_user_id                                                                                     as platform_user_id
,credit_user_id                                                                                       as credit_user_id
,maker_checker_attr                                                                                   as maker_checker_attr
,category                                                                                             as category
,status                                                                                               as status
,maker                                                                                                as maker
,id_card_type                                                                                         as id_card_type
,maker_notes                                                                                          as maker_notes
,checker                                                                                              as checker
,checker_notes                                                                                        as checker_notes
,scorer                                                                                               as scorer
,scorer_notes                                                                                         as scorer_notes
,start_time                                                                                           as start_time
,end_time                                                                                             as end_time
,score_info                                                                                           as score_info
,score_config                                                                                         as score_config
,screen_type                                                                                          as screen_type
,risk_result_type                                                                                     as risk_result_type
,reject_reason                                                                                        as reject_reason
,source                                                                                               as source
,create_date                                                                                          as create_date
,creator                                                                                              as creator
,ticket_category                                                                                      as ticket_category
,qa_ticket_id                                                                                         as qa_ticket_id
,priority                                                                                             as priority
,expiry_time                                                                                          as expiry_time
,sub_topic                                                                                            as sub_topic
,spp_info                                                                                             as spp_info
,topic                                                                                                as topic
,modified_by_notes                                                                                    as modified_by_notes
,modified_by                                                                                          as modified_by
,order_field                                                                                          as order_field
,archive_batch_no                                                                                     as archive_batch_no
,original_platform_type                                                                               as original_platform_type
,shopeepay_user_id                                                                                    as shopeepay_user_id
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,ticket_id                                                                                            as ticket_id
,product_code                                                                                         as product_code
,result                                                                                               as result
,ticket_completed_time                                                                                as ticket_completed_time
,platform_user_id                                                                                     as platform_user_id
,credit_user_id                                                                                       as credit_user_id
,maker_checker_attr                                                                                   as maker_checker_attr
,category                                                                                             as category
,status                                                                                               as status
,maker                                                                                                as maker
,id_card_type                                                                                         as id_card_type
,maker_notes                                                                                          as maker_notes
,checker                                                                                              as checker
,checker_notes                                                                                        as checker_notes
,scorer                                                                                               as scorer
,scorer_notes                                                                                         as scorer_notes
,start_time                                                                                           as start_time
,end_time                                                                                             as end_time
,score_info                                                                                           as score_info
,score_config                                                                                         as score_config
,screen_type                                                                                          as screen_type
,risk_result_type                                                                                     as risk_result_type
,reject_reason                                                                                        as reject_reason
,source                                                                                               as source
,create_date                                                                                          as create_date
,creator                                                                                              as creator
,ticket_category                                                                                      as ticket_category
,qa_ticket_id                                                                                         as qa_ticket_id
,priority                                                                                             as priority
,expiry_time                                                                                          as expiry_time
,sub_topic                                                                                            as sub_topic
,spp_info                                                                                             as spp_info
,topic                                                                                                as topic
,modified_by_notes                                                                                    as modified_by_notes
,modified_by                                                                                          as modified_by
,order_field                                                                                          as order_field
,archive_batch_no                                                                                     as archive_batch_no
,original_platform_type                                                                               as original_platform_type
,shopeepay_user_id                                                                                    as shopeepay_user_id
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_id_cf_db__ticket_score__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.ticket_id') as string)                                                  as ticket_id
,cast(get_json_object(data,'$.product_code') as string)                                               as product_code
,cast(get_json_object(data,'$.result') as bigint)                                                     as result
,cast(get_json_object(data,'$.ticket_completed_time') as bigint)                                      as ticket_completed_time
,cast(get_json_object(data,'$.platform_user_id') as string)                                           as platform_user_id
,cast(get_json_object(data,'$.credit_user_id') as bigint)                                             as credit_user_id
,cast(get_json_object(data,'$.maker_checker_attr') as bigint)                                         as maker_checker_attr
,cast(get_json_object(data,'$.category') as bigint)                                                   as category
,cast(get_json_object(data,'$.status') as bigint)                                                     as status
,cast(get_json_object(data,'$.maker') as string)                                                      as maker
,cast(get_json_object(data,'$.id_card_type') as bigint)                                               as id_card_type
,cast(get_json_object(data,'$.maker_notes') as string)                                                as maker_notes
,cast(get_json_object(data,'$.checker') as string)                                                    as checker
,cast(get_json_object(data,'$.checker_notes') as string)                                              as checker_notes
,cast(get_json_object(data,'$.scorer') as string)                                                     as scorer
,cast(get_json_object(data,'$.scorer_notes') as string)                                               as scorer_notes
,cast(get_json_object(data,'$.start_time') as bigint)                                                 as start_time
,cast(get_json_object(data,'$.end_time') as bigint)                                                   as end_time
,cast(get_json_object(data,'$.score_info') as string)                                                 as score_info
,cast(get_json_object(data,'$.score_config') as string)                                               as score_config
,cast(get_json_object(data,'$.screen_type') as string)                                                as screen_type
,cast(get_json_object(data,'$.risk_result_type') as bigint)                                           as risk_result_type
,cast(get_json_object(data,'$.reject_reason') as string)                                              as reject_reason
,cast(get_json_object(data,'$.source') as bigint)                                                     as source
,cast(get_json_object(data,'$.create_date') as bigint)                                                as create_date
,cast(get_json_object(data,'$.creator') as string)                                                    as creator
,cast(get_json_object(data,'$.ticket_category') as bigint)                                            as ticket_category
,cast(get_json_object(data,'$.qa_ticket_id') as string)                                               as qa_ticket_id
,cast(get_json_object(data,'$.priority') as bigint)                                                   as priority
,cast(get_json_object(data,'$.expiry_time') as bigint)                                                as expiry_time
,cast(get_json_object(data,'$.sub_topic') as string)                                                  as sub_topic
,cast(get_json_object(data,'$.spp_info') as string)                                                   as spp_info
,cast(get_json_object(data,'$.topic') as string)                                                      as topic
,cast(get_json_object(data,'$.modified_by_notes') as string)                                          as modified_by_notes
,cast(get_json_object(data,'$.modified_by') as string)                                                as modified_by
,cast(get_json_object(data,'$.order_field') as string)                                                as order_field
,cast(get_json_object(data,'$.archive_batch_no') as string)                                           as archive_batch_no
,cast(get_json_object(data,'$.original_platform_type') as bigint)                                     as original_platform_type
,cast(get_json_object(data,'$.shopeepay_user_id') as string)                                          as shopeepay_user_id
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'credit_risk_control_id_cf_db' and base_table= 'ticket_score'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and (nvl(get_json_object(_event,'$.type'),'') != 'delete' 
or (nvl(get_json_object(_event,'$.type'),'') = 'delete' and archive_batch_no is not null and archive_batch_no !='') 
) 
)
insert overwrite table risk.ods__credit_risk_control_id_cf_db__ticket_score__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,ticket_id                                                                                            as ticket_id
,product_code                                                                                         as product_code
,result                                                                                               as result
,ticket_completed_time                                                                                as ticket_completed_time
,platform_user_id                                                                                     as platform_user_id
,credit_user_id                                                                                       as credit_user_id
,maker_checker_attr                                                                                   as maker_checker_attr
,category                                                                                             as category
,status                                                                                               as status
,maker                                                                                                as maker
,id_card_type                                                                                         as id_card_type
,maker_notes                                                                                          as maker_notes
,checker                                                                                              as checker
,checker_notes                                                                                        as checker_notes
,scorer                                                                                               as scorer
,scorer_notes                                                                                         as scorer_notes
,start_time                                                                                           as start_time
,end_time                                                                                             as end_time
,score_info                                                                                           as score_info
,score_config                                                                                         as score_config
,screen_type                                                                                          as screen_type
,risk_result_type                                                                                     as risk_result_type
,reject_reason                                                                                        as reject_reason
,source                                                                                               as source
,create_date                                                                                          as create_date
,creator                                                                                              as creator
,ticket_category                                                                                      as ticket_category
,qa_ticket_id                                                                                         as qa_ticket_id
,priority                                                                                             as priority
,expiry_time                                                                                          as expiry_time
,sub_topic                                                                                            as sub_topic
,spp_info                                                                                             as spp_info
,topic                                                                                                as topic
,modified_by_notes                                                                                    as modified_by_notes
,modified_by                                                                                          as modified_by
,order_field                                                                                          as order_field
,archive_batch_no                                                                                     as archive_batch_no
,original_platform_type                                                                               as original_platform_type
,shopeepay_user_id                                                                                    as shopeepay_user_id
 
 ,_event
 ;