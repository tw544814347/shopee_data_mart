

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 id                                                                                                   as id
,ticket_id                                                                                            as ticket_id
,ticket_category                                                                                      as ticket_category
,ticket_subtype                                                                                       as ticket_subtype
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,shopeepay_user_id                                                                                    as shopeepay_user_id
,case_id                                                                                              as case_id
,application_source                                                                                   as application_source
,assignee                                                                                             as assignee
,status                                                                                               as status
,result                                                                                               as result
,reject_reason                                                                                        as reject_reason
,ticket_info                                                                                          as ticket_info
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,kyc_tag_list                                                                                         as kyc_tag_list
,ic_type                                                                                              as ic_type
,id_card_no                                                                                           as id_card_no
,user_name                                                                                            as user_name
,notes                                                                                                as notes
,application_id                                                                                       as application_id
,kyc_level                                                                                            as kyc_level
,user_name_encrypt                                                                                    as user_name_encrypt
,ticket_info_encrypt                                                                                  as ticket_info_encrypt
,id_card_no_encrypt                                                                                   as id_card_no_encrypt
,skip_operator_notes                                                                                  as skip_operator_notes
,skip_time                                                                                            as skip_time
,skip_reason                                                                                          as skip_reason
,skip_operator                                                                                        as skip_operator
,archive_batch_no                                                                                     as archive_batch_no
,order_field                                                                                          as order_field
,priority                                                                                             as priority
 
,_event
 from(
    select 
 id                                                                                                   as id
,ticket_id                                                                                            as ticket_id
,ticket_category                                                                                      as ticket_category
,ticket_subtype                                                                                       as ticket_subtype
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,shopeepay_user_id                                                                                    as shopeepay_user_id
,case_id                                                                                              as case_id
,application_source                                                                                   as application_source
,assignee                                                                                             as assignee
,status                                                                                               as status
,result                                                                                               as result
,reject_reason                                                                                        as reject_reason
,ticket_info                                                                                          as ticket_info
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,kyc_tag_list                                                                                         as kyc_tag_list
,ic_type                                                                                              as ic_type
,id_card_no                                                                                           as id_card_no
,user_name                                                                                            as user_name
,notes                                                                                                as notes
,application_id                                                                                       as application_id
,kyc_level                                                                                            as kyc_level
,user_name_encrypt                                                                                    as user_name_encrypt
,ticket_info_encrypt                                                                                  as ticket_info_encrypt
,id_card_no_encrypt                                                                                   as id_card_no_encrypt
,skip_operator_notes                                                                                  as skip_operator_notes
,skip_time                                                                                            as skip_time
,skip_reason                                                                                          as skip_reason
,skip_operator                                                                                        as skip_operator
,archive_batch_no                                                                                     as archive_batch_no
,order_field                                                                                          as order_field
,priority                                                                                             as priority
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,ticket_id                                                                                            as ticket_id
,ticket_category                                                                                      as ticket_category
,ticket_subtype                                                                                       as ticket_subtype
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,shopeepay_user_id                                                                                    as shopeepay_user_id
,case_id                                                                                              as case_id
,application_source                                                                                   as application_source
,assignee                                                                                             as assignee
,status                                                                                               as status
,result                                                                                               as result
,reject_reason                                                                                        as reject_reason
,ticket_info                                                                                          as ticket_info
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,kyc_tag_list                                                                                         as kyc_tag_list
,ic_type                                                                                              as ic_type
,id_card_no                                                                                           as id_card_no
,user_name                                                                                            as user_name
,notes                                                                                                as notes
,application_id                                                                                       as application_id
,kyc_level                                                                                            as kyc_level
,user_name_encrypt                                                                                    as user_name_encrypt
,ticket_info_encrypt                                                                                  as ticket_info_encrypt
,id_card_no_encrypt                                                                                   as id_card_no_encrypt
,skip_operator_notes                                                                                  as skip_operator_notes
,skip_time                                                                                            as skip_time
,skip_reason                                                                                          as skip_reason
,skip_operator                                                                                        as skip_operator
,archive_batch_no                                                                                     as archive_batch_no
,order_field                                                                                          as order_field
,priority                                                                                             as priority
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__shopeepay_risk_control_id_db__spp_ticket_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.ticket_id') as string)                                                  as ticket_id
,cast(get_json_object(data,'$.ticket_category') as bigint)                                            as ticket_category
,cast(get_json_object(data,'$.ticket_subtype') as bigint)                                             as ticket_subtype
,cast(get_json_object(data,'$.app_id') as string)                                                     as app_id
,cast(get_json_object(data,'$.scene_id') as bigint)                                                   as scene_id
,cast(get_json_object(data,'$.platform_user_id') as string)                                           as platform_user_id
,cast(get_json_object(data,'$.shopeepay_user_id') as string)                                          as shopeepay_user_id
,cast(get_json_object(data,'$.case_id') as string)                                                    as case_id
,cast(get_json_object(data,'$.application_source') as bigint)                                         as application_source
,cast(get_json_object(data,'$.assignee') as string)                                                   as assignee
,cast(get_json_object(data,'$.status') as bigint)                                                     as status
,cast(get_json_object(data,'$.result') as bigint)                                                     as result
,cast(get_json_object(data,'$.reject_reason') as string)                                              as reject_reason
,cast(get_json_object(data,'$.ticket_info') as string)                                                as ticket_info
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.kyc_tag_list') as string)                                               as kyc_tag_list
,cast(get_json_object(data,'$.ic_type') as bigint)                                                    as ic_type
,cast(get_json_object(data,'$.id_card_no') as string)                                                 as id_card_no
,cast(get_json_object(data,'$.user_name') as string)                                                  as user_name
,cast(get_json_object(data,'$.notes') as string)                                                      as notes
,cast(get_json_object(data,'$.application_id') as string)                                             as application_id
,cast(get_json_object(data,'$.kyc_level') as bigint)                                                  as kyc_level
,cast(get_json_object(data,'$.user_name_encrypt') as string)                                          as user_name_encrypt
,cast(get_json_object(data,'$.ticket_info_encrypt') as string)                                        as ticket_info_encrypt
,cast(get_json_object(data,'$.id_card_no_encrypt') as string)                                         as id_card_no_encrypt
,cast(get_json_object(data,'$.skip_operator_notes') as string)                                        as skip_operator_notes
,cast(get_json_object(data,'$.skip_time') as bigint)                                                  as skip_time
,cast(get_json_object(data,'$.skip_reason') as string)                                                as skip_reason
,cast(get_json_object(data,'$.skip_operator') as string)                                              as skip_operator
,cast(get_json_object(data,'$.archive_batch_no') as string)                                           as archive_batch_no
,cast(get_json_object(data,'$.order_field') as string)                                                as order_field
,cast(get_json_object(data,'$.priority') as bigint)                                                   as priority
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'shopeepay_risk_control_id_db' and base_table= 'spp_ticket_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t0}'
        
    ) a
   ) where  rn = 1 and (nvl(get_json_object(_event,'$.type'),'') != 'delete' 
or (nvl(get_json_object(_event,'$.type'),'') = 'delete' and archive_batch_no is not null and archive_batch_no !='') 
) 
)
insert overwrite table risk.ods__shopeepay_risk_control_id_db__spp_ticket_tab__df__private partition(grass_date ='${ods_date_t0}')
select 
 id                                                                                                   as id
,ticket_id                                                                                            as ticket_id
,ticket_category                                                                                      as ticket_category
,ticket_subtype                                                                                       as ticket_subtype
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,shopeepay_user_id                                                                                    as shopeepay_user_id
,case_id                                                                                              as case_id
,application_source                                                                                   as application_source
,assignee                                                                                             as assignee
,status                                                                                               as status
,result                                                                                               as result
,reject_reason                                                                                        as reject_reason
,ticket_info                                                                                          as ticket_info
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,kyc_tag_list                                                                                         as kyc_tag_list
,ic_type                                                                                              as ic_type
,id_card_no                                                                                           as id_card_no
,user_name                                                                                            as user_name
,notes                                                                                                as notes
,application_id                                                                                       as application_id
,kyc_level                                                                                            as kyc_level
,user_name_encrypt                                                                                    as user_name_encrypt
,ticket_info_encrypt                                                                                  as ticket_info_encrypt
,id_card_no_encrypt                                                                                   as id_card_no_encrypt
,skip_operator_notes                                                                                  as skip_operator_notes
,skip_time                                                                                            as skip_time
,skip_reason                                                                                          as skip_reason
,skip_operator                                                                                        as skip_operator
,archive_batch_no                                                                                     as archive_batch_no
,order_field                                                                                          as order_field
,priority                                                                                             as priority
 
 ,_event
 ;