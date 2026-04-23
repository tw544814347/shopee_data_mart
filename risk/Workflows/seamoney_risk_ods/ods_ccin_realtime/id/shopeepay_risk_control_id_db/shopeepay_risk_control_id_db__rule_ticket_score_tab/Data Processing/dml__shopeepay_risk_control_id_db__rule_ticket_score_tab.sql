

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,ticket_id                                                                                            as ticket_id
,product_code                                                                                         as product_code
,result                                                                                               as result
,request_time                                                                                         as request_time
,platform_user_id                                                                                     as platform_user_id
,credit_user_id                                                                                       as credit_user_id
,ticket_category                                                                                      as ticket_category
,status                                                                                               as status
,scorer                                                                                               as scorer
,scorer_notes                                                                                         as scorer_notes
,start_time                                                                                           as start_time
,end_time                                                                                             as end_time
,score_info                                                                                           as score_info
,decision                                                                                             as decision
,remarks                                                                                              as remarks
,score                                                                                                as score
,score_config                                                                                         as score_config
,screen_type                                                                                          as screen_type
,reject_code                                                                                          as reject_code
,qa_ticket_id                                                                                         as qa_ticket_id
,ticket_info                                                                                          as ticket_info
,ticket_info_encrypt                                                                                  as ticket_info_encrypt
,category                                                                                             as category
,priority                                                                                             as priority
,expiry_time                                                                                          as expiry_time
,create_date                                                                                          as create_date
,creator                                                                                              as creator
,topic                                                                                                as topic
,sub_topic                                                                                            as sub_topic
,modified_by                                                                                          as modified_by
,modified_by_notes                                                                                    as modified_by_notes
,ticket_subtype                                                                                       as ticket_subtype
,case_id                                                                                              as case_id
,application_id                                                                                       as application_id
,shopeepay_user_id                                                                                    as shopeepay_user_id
,ic_type                                                                                              as ic_type
,kyc_tag_list                                                                                         as kyc_tag_list
,application_source                                                                                   as application_source
,archive_batch_no                                                                                     as archive_batch_no
,original_platform_type                                                                               as original_platform_type
 
,_event
 from(
    select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,ticket_id                                                                                            as ticket_id
,product_code                                                                                         as product_code
,result                                                                                               as result
,request_time                                                                                         as request_time
,platform_user_id                                                                                     as platform_user_id
,credit_user_id                                                                                       as credit_user_id
,ticket_category                                                                                      as ticket_category
,status                                                                                               as status
,scorer                                                                                               as scorer
,scorer_notes                                                                                         as scorer_notes
,start_time                                                                                           as start_time
,end_time                                                                                             as end_time
,score_info                                                                                           as score_info
,decision                                                                                             as decision
,remarks                                                                                              as remarks
,score                                                                                                as score
,score_config                                                                                         as score_config
,screen_type                                                                                          as screen_type
,reject_code                                                                                          as reject_code
,qa_ticket_id                                                                                         as qa_ticket_id
,ticket_info                                                                                          as ticket_info
,ticket_info_encrypt                                                                                  as ticket_info_encrypt
,category                                                                                             as category
,priority                                                                                             as priority
,expiry_time                                                                                          as expiry_time
,create_date                                                                                          as create_date
,creator                                                                                              as creator
,topic                                                                                                as topic
,sub_topic                                                                                            as sub_topic
,modified_by                                                                                          as modified_by
,modified_by_notes                                                                                    as modified_by_notes
,ticket_subtype                                                                                       as ticket_subtype
,case_id                                                                                              as case_id
,application_id                                                                                       as application_id
,shopeepay_user_id                                                                                    as shopeepay_user_id
,ic_type                                                                                              as ic_type
,kyc_tag_list                                                                                         as kyc_tag_list
,application_source                                                                                   as application_source
,archive_batch_no                                                                                     as archive_batch_no
,original_platform_type                                                                               as original_platform_type
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,ticket_id                                                                                            as ticket_id
,product_code                                                                                         as product_code
,result                                                                                               as result
,request_time                                                                                         as request_time
,platform_user_id                                                                                     as platform_user_id
,credit_user_id                                                                                       as credit_user_id
,ticket_category                                                                                      as ticket_category
,status                                                                                               as status
,scorer                                                                                               as scorer
,scorer_notes                                                                                         as scorer_notes
,start_time                                                                                           as start_time
,end_time                                                                                             as end_time
,score_info                                                                                           as score_info
,decision                                                                                             as decision
,remarks                                                                                              as remarks
,score                                                                                                as score
,score_config                                                                                         as score_config
,screen_type                                                                                          as screen_type
,reject_code                                                                                          as reject_code
,qa_ticket_id                                                                                         as qa_ticket_id
,ticket_info                                                                                          as ticket_info
,ticket_info_encrypt                                                                                  as ticket_info_encrypt
,category                                                                                             as category
,priority                                                                                             as priority
,expiry_time                                                                                          as expiry_time
,create_date                                                                                          as create_date
,creator                                                                                              as creator
,topic                                                                                                as topic
,sub_topic                                                                                            as sub_topic
,modified_by                                                                                          as modified_by
,modified_by_notes                                                                                    as modified_by_notes
,ticket_subtype                                                                                       as ticket_subtype
,case_id                                                                                              as case_id
,application_id                                                                                       as application_id
,shopeepay_user_id                                                                                    as shopeepay_user_id
,ic_type                                                                                              as ic_type
,kyc_tag_list                                                                                         as kyc_tag_list
,application_source                                                                                   as application_source
,archive_batch_no                                                                                     as archive_batch_no
,original_platform_type                                                                               as original_platform_type
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__shopeepay_risk_control_id_db__rule_ticket_score_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.app_id') as string)                                                     as app_id
,cast(get_json_object(data,'$.scene_id') as bigint)                                                   as scene_id
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.ticket_id') as string)                                                  as ticket_id
,cast(get_json_object(data,'$.product_code') as string)                                               as product_code
,cast(get_json_object(data,'$.result') as bigint)                                                     as result
,cast(get_json_object(data,'$.request_time') as bigint)                                               as request_time
,cast(get_json_object(data,'$.platform_user_id') as string)                                           as platform_user_id
,cast(get_json_object(data,'$.credit_user_id') as bigint)                                             as credit_user_id
,cast(get_json_object(data,'$.ticket_category') as bigint)                                            as ticket_category
,cast(get_json_object(data,'$.status') as bigint)                                                     as status
,cast(get_json_object(data,'$.scorer') as string)                                                     as scorer
,cast(get_json_object(data,'$.scorer_notes') as string)                                               as scorer_notes
,cast(get_json_object(data,'$.start_time') as bigint)                                                 as start_time
,cast(get_json_object(data,'$.end_time') as bigint)                                                   as end_time
,cast(get_json_object(data,'$.score_info') as string)                                                 as score_info
,cast(get_json_object(data,'$.decision') as bigint)                                                   as decision
,cast(get_json_object(data,'$.remarks') as string)                                                    as remarks
,cast(get_json_object(data,'$.score') as bigint)                                                      as score
,cast(get_json_object(data,'$.score_config') as string)                                               as score_config
,cast(get_json_object(data,'$.screen_type') as string)                                                as screen_type
,cast(get_json_object(data,'$.reject_code') as string)                                                as reject_code
,cast(get_json_object(data,'$.qa_ticket_id') as string)                                               as qa_ticket_id
,cast(get_json_object(data,'$.ticket_info') as string)                                                as ticket_info
,cast(get_json_object(data,'$.ticket_info_encrypt') as string)                                        as ticket_info_encrypt
,cast(get_json_object(data,'$.category') as bigint)                                                   as category
,cast(get_json_object(data,'$.priority') as bigint)                                                   as priority
,cast(get_json_object(data,'$.expiry_time') as bigint)                                                as expiry_time
,cast(get_json_object(data,'$.create_date') as bigint)                                                as create_date
,cast(get_json_object(data,'$.creator') as string)                                                    as creator
,cast(get_json_object(data,'$.topic') as string)                                                      as topic
,cast(get_json_object(data,'$.sub_topic') as string)                                                  as sub_topic
,cast(get_json_object(data,'$.modified_by') as string)                                                as modified_by
,cast(get_json_object(data,'$.modified_by_notes') as string)                                          as modified_by_notes
,cast(get_json_object(data,'$.ticket_subtype') as bigint)                                             as ticket_subtype
,cast(get_json_object(data,'$.case_id') as string)                                                    as case_id
,cast(get_json_object(data,'$.application_id') as string)                                             as application_id
,cast(get_json_object(data,'$.shopeepay_user_id') as string)                                          as shopeepay_user_id
,cast(get_json_object(data,'$.ic_type') as bigint)                                                    as ic_type
,cast(get_json_object(data,'$.kyc_tag_list') as string)                                               as kyc_tag_list
,cast(get_json_object(data,'$.application_source') as bigint)                                         as application_source
,cast(get_json_object(data,'$.archive_batch_no') as string)                                           as archive_batch_no
,cast(get_json_object(data,'$.original_platform_type') as bigint)                                     as original_platform_type
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'shopeepay_risk_control_id_db' and base_table= 'rule_ticket_score_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and (nvl(get_json_object(_event,'$.type'),'') != 'delete' 
or (nvl(get_json_object(_event,'$.type'),'') = 'delete' and archive_batch_no is not null and archive_batch_no !='') 
) 
)
insert overwrite table risk.ods__shopeepay_risk_control_id_db__rule_ticket_score_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,ticket_id                                                                                            as ticket_id
,product_code                                                                                         as product_code
,result                                                                                               as result
,request_time                                                                                         as request_time
,platform_user_id                                                                                     as platform_user_id
,credit_user_id                                                                                       as credit_user_id
,ticket_category                                                                                      as ticket_category
,status                                                                                               as status
,scorer                                                                                               as scorer
,scorer_notes                                                                                         as scorer_notes
,start_time                                                                                           as start_time
,end_time                                                                                             as end_time
,score_info                                                                                           as score_info
,decision                                                                                             as decision
,remarks                                                                                              as remarks
,score                                                                                                as score
,score_config                                                                                         as score_config
,screen_type                                                                                          as screen_type
,reject_code                                                                                          as reject_code
,qa_ticket_id                                                                                         as qa_ticket_id
,ticket_info                                                                                          as ticket_info
,ticket_info_encrypt                                                                                  as ticket_info_encrypt
,category                                                                                             as category
,priority                                                                                             as priority
,expiry_time                                                                                          as expiry_time
,create_date                                                                                          as create_date
,creator                                                                                              as creator
,topic                                                                                                as topic
,sub_topic                                                                                            as sub_topic
,modified_by                                                                                          as modified_by
,modified_by_notes                                                                                    as modified_by_notes
,ticket_subtype                                                                                       as ticket_subtype
,case_id                                                                                              as case_id
,application_id                                                                                       as application_id
,shopeepay_user_id                                                                                    as shopeepay_user_id
,ic_type                                                                                              as ic_type
,kyc_tag_list                                                                                         as kyc_tag_list
,application_source                                                                                   as application_source
,archive_batch_no                                                                                     as archive_batch_no
,original_platform_type                                                                               as original_platform_type
 
 ,_event
 ;