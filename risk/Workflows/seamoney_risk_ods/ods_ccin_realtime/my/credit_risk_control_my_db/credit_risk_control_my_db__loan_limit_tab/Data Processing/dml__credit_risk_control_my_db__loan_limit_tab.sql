

refresh table risk.ccin_multi_realtime_binlog_for_my;

from (
    select 
 id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,app_id                                                                                               as app_id
,sub_app_id                                                                                           as sub_app_id
,total_limit                                                                                          as total_limit
,ceiling_limit                                                                                        as ceiling_limit
,version                                                                                              as version
,currency_units                                                                                       as currency_units
,temporary_limit                                                                                      as temporary_limit
,temp_limit_start_time                                                                                as temp_limit_start_time
,temp_limit_end_time                                                                                  as temp_limit_end_time
,admin_fee_rate                                                                                       as admin_fee_rate
,late_charge_rate                                                                                     as late_charge_rate
,penalty_interest_rate                                                                                as penalty_interest_rate
,sync_credit_status                                                                                   as sync_credit_status
,sync_whitelist_status                                                                                as sync_whitelist_status
,sync_tag_status                                                                                      as sync_tag_status
,event_id                                                                                             as event_id
,event_detail                                                                                         as event_detail
,source                                                                                               as source
,operator                                                                                             as operator
,status                                                                                               as status
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,customer_level_credit_limit                                                                          as customer_level_credit_limit
,spl_eligible                                                                                         as spl_eligible
,cod_eligible                                                                                         as cod_eligible
,percentage_sales                                                                                     as percentage_sales
,prepayment_penalty_rate                                                                              as prepayment_penalty_rate
,scene                                                                                                as scene
,nominal_interest_rate                                                                                as nominal_interest_rate
,sync_temp_limit_result                                                                               as sync_temp_limit_result
,service_fee_rate                                                                                     as service_fee_rate
,shop_id                                                                                              as shop_id
,seller_group                                                                                         as seller_group
,is_prefer_seller                                                                                     as is_prefer_seller
,is_fss_seller                                                                                        as is_fss_seller
,is_official_seller                                                                                   as is_official_seller
,notes                                                                                                as notes
 
,_event
 from(
    select 
 id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,app_id                                                                                               as app_id
,sub_app_id                                                                                           as sub_app_id
,total_limit                                                                                          as total_limit
,ceiling_limit                                                                                        as ceiling_limit
,version                                                                                              as version
,currency_units                                                                                       as currency_units
,temporary_limit                                                                                      as temporary_limit
,temp_limit_start_time                                                                                as temp_limit_start_time
,temp_limit_end_time                                                                                  as temp_limit_end_time
,admin_fee_rate                                                                                       as admin_fee_rate
,late_charge_rate                                                                                     as late_charge_rate
,penalty_interest_rate                                                                                as penalty_interest_rate
,sync_credit_status                                                                                   as sync_credit_status
,sync_whitelist_status                                                                                as sync_whitelist_status
,sync_tag_status                                                                                      as sync_tag_status
,event_id                                                                                             as event_id
,event_detail                                                                                         as event_detail
,source                                                                                               as source
,operator                                                                                             as operator
,status                                                                                               as status
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,customer_level_credit_limit                                                                          as customer_level_credit_limit
,spl_eligible                                                                                         as spl_eligible
,cod_eligible                                                                                         as cod_eligible
,percentage_sales                                                                                     as percentage_sales
,prepayment_penalty_rate                                                                              as prepayment_penalty_rate
,scene                                                                                                as scene
,nominal_interest_rate                                                                                as nominal_interest_rate
,sync_temp_limit_result                                                                               as sync_temp_limit_result
,service_fee_rate                                                                                     as service_fee_rate
,shop_id                                                                                              as shop_id
,seller_group                                                                                         as seller_group
,is_prefer_seller                                                                                     as is_prefer_seller
,is_fss_seller                                                                                        as is_fss_seller
,is_official_seller                                                                                   as is_official_seller
,notes                                                                                                as notes
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,app_id                                                                                               as app_id
,sub_app_id                                                                                           as sub_app_id
,total_limit                                                                                          as total_limit
,ceiling_limit                                                                                        as ceiling_limit
,version                                                                                              as version
,currency_units                                                                                       as currency_units
,temporary_limit                                                                                      as temporary_limit
,temp_limit_start_time                                                                                as temp_limit_start_time
,temp_limit_end_time                                                                                  as temp_limit_end_time
,admin_fee_rate                                                                                       as admin_fee_rate
,late_charge_rate                                                                                     as late_charge_rate
,penalty_interest_rate                                                                                as penalty_interest_rate
,sync_credit_status                                                                                   as sync_credit_status
,sync_whitelist_status                                                                                as sync_whitelist_status
,sync_tag_status                                                                                      as sync_tag_status
,event_id                                                                                             as event_id
,event_detail                                                                                         as event_detail
,source                                                                                               as source
,operator                                                                                             as operator
,status                                                                                               as status
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,customer_level_credit_limit                                                                          as customer_level_credit_limit
,spl_eligible                                                                                         as spl_eligible
,cod_eligible                                                                                         as cod_eligible
,percentage_sales                                                                                     as percentage_sales
,prepayment_penalty_rate                                                                              as prepayment_penalty_rate
,scene                                                                                                as scene
,nominal_interest_rate                                                                                as nominal_interest_rate
,sync_temp_limit_result                                                                               as sync_temp_limit_result
,service_fee_rate                                                                                     as service_fee_rate
,shop_id                                                                                              as shop_id
,seller_group                                                                                         as seller_group
,is_prefer_seller                                                                                     as is_prefer_seller
,is_fss_seller                                                                                        as is_fss_seller
,is_official_seller                                                                                   as is_official_seller
,notes                                                                                                as notes
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),id)            as on_keys_conds
,_event
        from risk.ods__credit_risk_control_my_db__loan_limit_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.platform_user_id') as string)                                           as platform_user_id
,cast(get_json_object(data,'$.platform_type') as bigint)                                              as platform_type
,cast(get_json_object(data,'$.app_id') as string)                                                     as app_id
,cast(get_json_object(data,'$.sub_app_id') as string)                                                 as sub_app_id
,cast(get_json_object(data,'$.total_limit') as bigint)                                                as total_limit
,cast(get_json_object(data,'$.ceiling_limit') as bigint)                                              as ceiling_limit
,cast(get_json_object(data,'$.version') as bigint)                                                    as version
,cast(get_json_object(data,'$.currency_units') as bigint)                                             as currency_units
,cast(get_json_object(data,'$.temporary_limit') as bigint)                                            as temporary_limit
,cast(get_json_object(data,'$.temp_limit_start_time') as bigint)                                      as temp_limit_start_time
,cast(get_json_object(data,'$.temp_limit_end_time') as bigint)                                        as temp_limit_end_time
,cast(get_json_object(data,'$.admin_fee_rate') as bigint)                                             as admin_fee_rate
,cast(get_json_object(data,'$.late_charge_rate') as bigint)                                           as late_charge_rate
,cast(get_json_object(data,'$.penalty_interest_rate') as bigint)                                      as penalty_interest_rate
,cast(get_json_object(data,'$.sync_credit_status') as bigint)                                         as sync_credit_status
,cast(get_json_object(data,'$.sync_whitelist_status') as bigint)                                      as sync_whitelist_status
,cast(get_json_object(data,'$.sync_tag_status') as decimal(20,0))                                     as sync_tag_status
,cast(get_json_object(data,'$.event_id') as string)                                                   as event_id
,cast(get_json_object(data,'$.event_detail') as string)                                               as event_detail
,cast(get_json_object(data,'$.source') as string)                                                     as source
,cast(get_json_object(data,'$.operator') as string)                                                   as operator
,cast(get_json_object(data,'$.status') as bigint)                                                     as status
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.customer_level_credit_limit') as bigint)                                as customer_level_credit_limit
,cast(get_json_object(data,'$.spl_eligible') as bigint)                                               as spl_eligible
,cast(get_json_object(data,'$.cod_eligible') as bigint)                                               as cod_eligible
,cast(get_json_object(data,'$.percentage_sales') as bigint)                                           as percentage_sales
,cast(get_json_object(data,'$.prepayment_penalty_rate') as bigint)                                    as prepayment_penalty_rate
,cast(get_json_object(data,'$.scene') as string)                                                      as scene
,cast(get_json_object(data,'$.nominal_interest_rate') as bigint)                                      as nominal_interest_rate
,cast(get_json_object(data,'$.sync_temp_limit_result') as string)                                     as sync_temp_limit_result
,cast(get_json_object(data,'$.service_fee_rate') as bigint)                                           as service_fee_rate
,cast(get_json_object(data,'$.shop_id') as string)                                                    as shop_id
,cast(get_json_object(data,'$.seller_group') as bigint)                                               as seller_group
,cast(get_json_object(data,'$.is_prefer_seller') as bigint)                                           as is_prefer_seller
,cast(get_json_object(data,'$.is_fss_seller') as bigint)                                              as is_fss_seller
,cast(get_json_object(data,'$.is_official_seller') as bigint)                                         as is_official_seller
,cast(get_json_object(data,'$.notes') as string)                                                      as notes
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.id')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_my 
        where base_database = 'credit_risk_control_my_db' and base_table= 'loan_limit_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 0 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__credit_risk_control_my_db__loan_limit_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 id                                                                                                   as id
,platform_user_id                                                                                     as platform_user_id
,platform_type                                                                                        as platform_type
,app_id                                                                                               as app_id
,sub_app_id                                                                                           as sub_app_id
,total_limit                                                                                          as total_limit
,ceiling_limit                                                                                        as ceiling_limit
,version                                                                                              as version
,currency_units                                                                                       as currency_units
,temporary_limit                                                                                      as temporary_limit
,temp_limit_start_time                                                                                as temp_limit_start_time
,temp_limit_end_time                                                                                  as temp_limit_end_time
,admin_fee_rate                                                                                       as admin_fee_rate
,late_charge_rate                                                                                     as late_charge_rate
,penalty_interest_rate                                                                                as penalty_interest_rate
,sync_credit_status                                                                                   as sync_credit_status
,sync_whitelist_status                                                                                as sync_whitelist_status
,sync_tag_status                                                                                      as sync_tag_status
,event_id                                                                                             as event_id
,event_detail                                                                                         as event_detail
,source                                                                                               as source
,operator                                                                                             as operator
,status                                                                                               as status
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,customer_level_credit_limit                                                                          as customer_level_credit_limit
,spl_eligible                                                                                         as spl_eligible
,cod_eligible                                                                                         as cod_eligible
,percentage_sales                                                                                     as percentage_sales
,prepayment_penalty_rate                                                                              as prepayment_penalty_rate
,scene                                                                                                as scene
,nominal_interest_rate                                                                                as nominal_interest_rate
,sync_temp_limit_result                                                                               as sync_temp_limit_result
,service_fee_rate                                                                                     as service_fee_rate
,shop_id                                                                                              as shop_id
,seller_group                                                                                         as seller_group
,is_prefer_seller                                                                                     as is_prefer_seller
,is_fss_seller                                                                                        as is_fss_seller
,is_official_seller                                                                                   as is_official_seller
,notes                                                                                                as notes
 
 ,_event
 ;