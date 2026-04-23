

refresh table risk.ccin_multi_realtime_binlog_for_my;

from (
    select 
 id                                                                                                   as id
,case_uuid                                                                                            as case_uuid
,req_no                                                                                               as req_no
,category                                                                                             as category
,scene                                                                                                as scene
,customer_name                                                                                        as customer_name
,user_id                                                                                              as user_id
,kyc_info                                                                                             as kyc_info
,name_screening_info                                                                                  as name_screening_info
,risk_rating                                                                                          as risk_rating
,last_risk_rating                                                                                     as last_risk_rating
,status                                                                                               as status
,result                                                                                               as result
,maker                                                                                                as maker
,maker_notes                                                                                          as maker_notes
,checker                                                                                              as checker
,checker_notes                                                                                        as checker_notes
,case_owner                                                                                           as case_owner
,updater                                                                                              as updater
,document                                                                                             as document
,reviews                                                                                              as reviews
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,notes                                                                                                as notes
,ext_info                                                                                             as ext_info
,product_type                                                                                         as product_type
,compliance_notes                                                                                     as compliance_notes
,compliance                                                                                           as compliance
,name_list                                                                                            as name_list
,kyc_info_encrypt                                                                                     as kyc_info_encrypt
,final_conclusions                                                                                    as final_conclusions
,risk_rating_score_info                                                                               as risk_rating_score_info
,hit_reasons                                                                                          as hit_reasons
,edd_result_info_encrypt                                                                              as edd_result_info_encrypt
,edd_status                                                                                           as edd_status
,edd_result_info                                                                                      as edd_result_info
,order_field                                                                                          as order_field
,priority                                                                                             as priority
,version                                                                                              as version
,archive_batch_no                                                                                     as archive_batch_no
,original_platform_type                                                                               as original_platform_type
,shopeepay_user_id                                                                                    as shopeepay_user_id
 
,_event
 from(
    select 
 id                                                                                                   as id
,case_uuid                                                                                            as case_uuid
,req_no                                                                                               as req_no
,category                                                                                             as category
,scene                                                                                                as scene
,customer_name                                                                                        as customer_name
,user_id                                                                                              as user_id
,kyc_info                                                                                             as kyc_info
,name_screening_info                                                                                  as name_screening_info
,risk_rating                                                                                          as risk_rating
,last_risk_rating                                                                                     as last_risk_rating
,status                                                                                               as status
,result                                                                                               as result
,maker                                                                                                as maker
,maker_notes                                                                                          as maker_notes
,checker                                                                                              as checker
,checker_notes                                                                                        as checker_notes
,case_owner                                                                                           as case_owner
,updater                                                                                              as updater
,document                                                                                             as document
,reviews                                                                                              as reviews
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,notes                                                                                                as notes
,ext_info                                                                                             as ext_info
,product_type                                                                                         as product_type
,compliance_notes                                                                                     as compliance_notes
,compliance                                                                                           as compliance
,name_list                                                                                            as name_list
,kyc_info_encrypt                                                                                     as kyc_info_encrypt
,final_conclusions                                                                                    as final_conclusions
,risk_rating_score_info                                                                               as risk_rating_score_info
,hit_reasons                                                                                          as hit_reasons
,edd_result_info_encrypt                                                                              as edd_result_info_encrypt
,edd_status                                                                                           as edd_status
,edd_result_info                                                                                      as edd_result_info
,order_field                                                                                          as order_field
,priority                                                                                             as priority
,version                                                                                              as version
,archive_batch_no                                                                                     as archive_batch_no
,original_platform_type                                                                               as original_platform_type
,shopeepay_user_id                                                                                    as shopeepay_user_id
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,case_uuid                                                                                            as case_uuid
,req_no                                                                                               as req_no
,category                                                                                             as category
,scene                                                                                                as scene
,customer_name                                                                                        as customer_name
,user_id                                                                                              as user_id
,kyc_info                                                                                             as kyc_info
,name_screening_info                                                                                  as name_screening_info
,risk_rating                                                                                          as risk_rating
,last_risk_rating                                                                                     as last_risk_rating
,status                                                                                               as status
,result                                                                                               as result
,maker                                                                                                as maker
,maker_notes                                                                                          as maker_notes
,checker                                                                                              as checker
,checker_notes                                                                                        as checker_notes
,case_owner                                                                                           as case_owner
,updater                                                                                              as updater
,document                                                                                             as document
,reviews                                                                                              as reviews
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,notes                                                                                                as notes
,ext_info                                                                                             as ext_info
,product_type                                                                                         as product_type
,compliance_notes                                                                                     as compliance_notes
,compliance                                                                                           as compliance
,name_list                                                                                            as name_list
,kyc_info_encrypt                                                                                     as kyc_info_encrypt
,final_conclusions                                                                                    as final_conclusions
,risk_rating_score_info                                                                               as risk_rating_score_info
,hit_reasons                                                                                          as hit_reasons
,edd_result_info_encrypt                                                                              as edd_result_info_encrypt
,edd_status                                                                                           as edd_status
,edd_result_info                                                                                      as edd_result_info
,order_field                                                                                          as order_field
,priority                                                                                             as priority
,version                                                                                              as version
,archive_batch_no                                                                                     as archive_batch_no
,original_platform_type                                                                               as original_platform_type
,shopeepay_user_id                                                                                    as shopeepay_user_id
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_aml_my_db__aml_ns_case_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.case_uuid') as string)                                                  as case_uuid
,cast(get_json_object(data,'$.req_no') as string)                                                     as req_no
,cast(get_json_object(data,'$.category') as bigint)                                                   as category
,cast(get_json_object(data,'$.scene') as string)                                                      as scene
,cast(get_json_object(data,'$.customer_name') as string)                                              as customer_name
,cast(get_json_object(data,'$.user_id') as string)                                                    as user_id
,cast(get_json_object(data,'$.kyc_info') as string)                                                   as kyc_info
,cast(get_json_object(data,'$.name_screening_info') as string)                                        as name_screening_info
,cast(get_json_object(data,'$.risk_rating') as bigint)                                                as risk_rating
,cast(get_json_object(data,'$.last_risk_rating') as bigint)                                           as last_risk_rating
,cast(get_json_object(data,'$.status') as bigint)                                                     as status
,cast(get_json_object(data,'$.result') as bigint)                                                     as result
,cast(get_json_object(data,'$.maker') as string)                                                      as maker
,cast(get_json_object(data,'$.maker_notes') as string)                                                as maker_notes
,cast(get_json_object(data,'$.checker') as string)                                                    as checker
,cast(get_json_object(data,'$.checker_notes') as string)                                              as checker_notes
,cast(get_json_object(data,'$.case_owner') as string)                                                 as case_owner
,cast(get_json_object(data,'$.updater') as string)                                                    as updater
,cast(get_json_object(data,'$.document') as string)                                                   as document
,cast(get_json_object(data,'$.reviews') as string)                                                    as reviews
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.notes') as string)                                                      as notes
,cast(get_json_object(data,'$.ext_info') as string)                                                   as ext_info
,cast(get_json_object(data,'$.product_type') as string)                                               as product_type
,cast(get_json_object(data,'$.compliance_notes') as string)                                           as compliance_notes
,cast(get_json_object(data,'$.compliance') as string)                                                 as compliance
,cast(get_json_object(data,'$.name_list') as string)                                                  as name_list
,cast(get_json_object(data,'$.kyc_info_encrypt') as string)                                           as kyc_info_encrypt
,cast(get_json_object(data,'$.final_conclusions') as string)                                          as final_conclusions
,cast(get_json_object(data,'$.risk_rating_score_info') as string)                                     as risk_rating_score_info
,cast(get_json_object(data,'$.hit_reasons') as string)                                                as hit_reasons
,cast(get_json_object(data,'$.edd_result_info_encrypt') as string)                                    as edd_result_info_encrypt
,cast(get_json_object(data,'$.edd_status') as bigint)                                                 as edd_status
,cast(get_json_object(data,'$.edd_result_info') as string)                                            as edd_result_info
,cast(get_json_object(data,'$.order_field') as string)                                                as order_field
,cast(get_json_object(data,'$.priority') as bigint)                                                   as priority
,cast(get_json_object(data,'$.version') as bigint)                                                    as version
,cast(get_json_object(data,'$.archive_batch_no') as string)                                           as archive_batch_no
,cast(get_json_object(data,'$.original_platform_type') as bigint)                                     as original_platform_type
,cast(get_json_object(data,'$.shopeepay_user_id') as string)                                          as shopeepay_user_id
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_my 
        where base_database = 'credit_risk_aml_my_db' and base_table= 'aml_ns_case_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 0 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and (nvl(get_json_object(_event,'$.type'),'') != 'delete' 
or (nvl(get_json_object(_event,'$.type'),'') = 'delete' and archive_batch_no is not null and archive_batch_no !='') 
) 
)
insert overwrite table risk.ods__credit_risk_aml_my_db__aml_ns_case_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,case_uuid                                                                                            as case_uuid
,req_no                                                                                               as req_no
,category                                                                                             as category
,scene                                                                                                as scene
,customer_name                                                                                        as customer_name
,user_id                                                                                              as user_id
,kyc_info                                                                                             as kyc_info
,name_screening_info                                                                                  as name_screening_info
,risk_rating                                                                                          as risk_rating
,last_risk_rating                                                                                     as last_risk_rating
,status                                                                                               as status
,result                                                                                               as result
,maker                                                                                                as maker
,maker_notes                                                                                          as maker_notes
,checker                                                                                              as checker
,checker_notes                                                                                        as checker_notes
,case_owner                                                                                           as case_owner
,updater                                                                                              as updater
,document                                                                                             as document
,reviews                                                                                              as reviews
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,notes                                                                                                as notes
,ext_info                                                                                             as ext_info
,product_type                                                                                         as product_type
,compliance_notes                                                                                     as compliance_notes
,compliance                                                                                           as compliance
,name_list                                                                                            as name_list
,kyc_info_encrypt                                                                                     as kyc_info_encrypt
,final_conclusions                                                                                    as final_conclusions
,risk_rating_score_info                                                                               as risk_rating_score_info
,hit_reasons                                                                                          as hit_reasons
,edd_result_info_encrypt                                                                              as edd_result_info_encrypt
,edd_status                                                                                           as edd_status
,edd_result_info                                                                                      as edd_result_info
,order_field                                                                                          as order_field
,priority                                                                                             as priority
,version                                                                                              as version
,archive_batch_no                                                                                     as archive_batch_no
,original_platform_type                                                                               as original_platform_type
,shopeepay_user_id                                                                                    as shopeepay_user_id
 
 ,_event
 ;