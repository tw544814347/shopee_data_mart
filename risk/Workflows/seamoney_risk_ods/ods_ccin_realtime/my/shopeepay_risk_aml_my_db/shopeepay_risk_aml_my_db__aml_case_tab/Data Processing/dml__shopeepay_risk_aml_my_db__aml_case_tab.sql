

refresh table risk.ccin_multi_realtime_binlog_for_my;

from (
    select 
 id                                                                                                   as id
,case_uuid                                                                                            as case_uuid
,category                                                                                             as category
,customer_name                                                                                        as customer_name
,user_id                                                                                              as user_id
,nums_of_alerts                                                                                       as nums_of_alerts
,kyc_info                                                                                             as kyc_info
,status                                                                                               as status
,is_rework                                                                                            as is_rework
,maker                                                                                                as maker
,maker_notes                                                                                          as maker_notes
,checker                                                                                              as checker
,checker_notes                                                                                        as checker_notes
,compliance                                                                                           as compliance
,compliance_notes                                                                                     as compliance_notes
,case_owner                                                                                           as case_owner
,updater                                                                                              as updater
,document                                                                                             as document
,reviews                                                                                              as reviews
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,notes                                                                                                as notes
,ext_info                                                                                             as ext_info
,result                                                                                               as result
,last_risk_rating                                                                                     as last_risk_rating
,platform_type                                                                                        as platform_type
,rule_hit                                                                                             as rule_hit
,version                                                                                              as version
,kyc_info_encrypt                                                                                     as kyc_info_encrypt
,order_field                                                                                          as order_field
,priority                                                                                             as priority
,archive_batch_no                                                                                     as archive_batch_no
 
,_event
 from(
    select 
 id                                                                                                   as id
,case_uuid                                                                                            as case_uuid
,category                                                                                             as category
,customer_name                                                                                        as customer_name
,user_id                                                                                              as user_id
,nums_of_alerts                                                                                       as nums_of_alerts
,kyc_info                                                                                             as kyc_info
,status                                                                                               as status
,is_rework                                                                                            as is_rework
,maker                                                                                                as maker
,maker_notes                                                                                          as maker_notes
,checker                                                                                              as checker
,checker_notes                                                                                        as checker_notes
,compliance                                                                                           as compliance
,compliance_notes                                                                                     as compliance_notes
,case_owner                                                                                           as case_owner
,updater                                                                                              as updater
,document                                                                                             as document
,reviews                                                                                              as reviews
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,notes                                                                                                as notes
,ext_info                                                                                             as ext_info
,result                                                                                               as result
,last_risk_rating                                                                                     as last_risk_rating
,platform_type                                                                                        as platform_type
,rule_hit                                                                                             as rule_hit
,version                                                                                              as version
,kyc_info_encrypt                                                                                     as kyc_info_encrypt
,order_field                                                                                          as order_field
,priority                                                                                             as priority
,archive_batch_no                                                                                     as archive_batch_no
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,case_uuid                                                                                            as case_uuid
,category                                                                                             as category
,customer_name                                                                                        as customer_name
,user_id                                                                                              as user_id
,nums_of_alerts                                                                                       as nums_of_alerts
,kyc_info                                                                                             as kyc_info
,status                                                                                               as status
,is_rework                                                                                            as is_rework
,maker                                                                                                as maker
,maker_notes                                                                                          as maker_notes
,checker                                                                                              as checker
,checker_notes                                                                                        as checker_notes
,compliance                                                                                           as compliance
,compliance_notes                                                                                     as compliance_notes
,case_owner                                                                                           as case_owner
,updater                                                                                              as updater
,document                                                                                             as document
,reviews                                                                                              as reviews
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,notes                                                                                                as notes
,ext_info                                                                                             as ext_info
,result                                                                                               as result
,last_risk_rating                                                                                     as last_risk_rating
,platform_type                                                                                        as platform_type
,rule_hit                                                                                             as rule_hit
,version                                                                                              as version
,kyc_info_encrypt                                                                                     as kyc_info_encrypt
,order_field                                                                                          as order_field
,priority                                                                                             as priority
,archive_batch_no                                                                                     as archive_batch_no
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__shopeepay_risk_aml_my_db__aml_case_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.case_uuid') as string)                                                  as case_uuid
,cast(get_json_object(data,'$.category') as bigint)                                                   as category
,cast(get_json_object(data,'$.customer_name') as string)                                              as customer_name
,cast(get_json_object(data,'$.user_id') as string)                                                    as user_id
,cast(get_json_object(data,'$.nums_of_alerts') as bigint)                                             as nums_of_alerts
,cast(get_json_object(data,'$.kyc_info') as string)                                                   as kyc_info
,cast(get_json_object(data,'$.status') as bigint)                                                     as status
,cast(get_json_object(data,'$.is_rework') as bigint)                                                  as is_rework
,cast(get_json_object(data,'$.maker') as string)                                                      as maker
,cast(get_json_object(data,'$.maker_notes') as string)                                                as maker_notes
,cast(get_json_object(data,'$.checker') as string)                                                    as checker
,cast(get_json_object(data,'$.checker_notes') as string)                                              as checker_notes
,cast(get_json_object(data,'$.compliance') as string)                                                 as compliance
,cast(get_json_object(data,'$.compliance_notes') as string)                                           as compliance_notes
,cast(get_json_object(data,'$.case_owner') as string)                                                 as case_owner
,cast(get_json_object(data,'$.updater') as string)                                                    as updater
,cast(get_json_object(data,'$.document') as string)                                                   as document
,cast(get_json_object(data,'$.reviews') as string)                                                    as reviews
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.notes') as string)                                                      as notes
,cast(get_json_object(data,'$.ext_info') as string)                                                   as ext_info
,cast(get_json_object(data,'$.result') as bigint)                                                     as result
,cast(get_json_object(data,'$.last_risk_rating') as bigint)                                           as last_risk_rating
,cast(get_json_object(data,'$.platform_type') as bigint)                                              as platform_type
,cast(get_json_object(data,'$.rule_hit') as string)                                                   as rule_hit
,cast(get_json_object(data,'$.version') as bigint)                                                    as version
,cast(get_json_object(data,'$.kyc_info_encrypt') as string)                                           as kyc_info_encrypt
,cast(get_json_object(data,'$.order_field') as string)                                                as order_field
,cast(get_json_object(data,'$.priority') as bigint)                                                   as priority
,cast(get_json_object(data,'$.archive_batch_no') as string)                                           as archive_batch_no
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event as _event
        from risk.ccin_multi_realtime_binlog_for_my 
        where base_database = 'shopeepay_risk_aml_my_db' and base_table= 'aml_case_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 0 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and (nvl(get_json_object(_event,'$.type'),'') != 'delete' 
or (nvl(get_json_object(_event,'$.type'),'') = 'delete' and archive_batch_no is not null and archive_batch_no !='') 
) 
)
insert overwrite table risk.ods__shopeepay_risk_aml_my_db__aml_case_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,case_uuid                                                                                            as case_uuid
,category                                                                                             as category
,customer_name                                                                                        as customer_name
,user_id                                                                                              as user_id
,nums_of_alerts                                                                                       as nums_of_alerts
,kyc_info                                                                                             as kyc_info
,status                                                                                               as status
,is_rework                                                                                            as is_rework
,maker                                                                                                as maker
,maker_notes                                                                                          as maker_notes
,checker                                                                                              as checker
,checker_notes                                                                                        as checker_notes
,compliance                                                                                           as compliance
,compliance_notes                                                                                     as compliance_notes
,case_owner                                                                                           as case_owner
,updater                                                                                              as updater
,document                                                                                             as document
,reviews                                                                                              as reviews
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,notes                                                                                                as notes
,ext_info                                                                                             as ext_info
,result                                                                                               as result
,last_risk_rating                                                                                     as last_risk_rating
,platform_type                                                                                        as platform_type
,rule_hit                                                                                             as rule_hit
,version                                                                                              as version
,kyc_info_encrypt                                                                                     as kyc_info_encrypt
,order_field                                                                                          as order_field
,priority                                                                                             as priority
,archive_batch_no                                                                                     as archive_batch_no
 
 ,_event
 ;