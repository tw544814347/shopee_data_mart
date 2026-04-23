

refresh table risk.ccin_multi_realtime_binlog_for_id;

from (
    select 
 hid                                                                                                  as hid
,id                                                                                                   as id
,platform_type                                                                                        as platform_type
,platform_user_id                                                                                     as platform_user_id
,base_limit                                                                                           as base_limit
,advanced_limit                                                                                       as advanced_limit
,spl                                                                                                  as spl
,instalment_two_month                                                                                 as instalment_two_month
,instalment_three_month                                                                               as instalment_three_month
,instalment_six_month                                                                                 as instalment_six_month
,event_id                                                                                             as event_id
,event_detail                                                                                         as event_detail
,status                                                                                               as status
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,operator                                                                                             as operator
,currency_units                                                                                       as currency_units
,temporary_limit                                                                                      as temporary_limit
,temp_limit_start_time                                                                                as temp_limit_start_time
,temp_limit_end_time                                                                                  as temp_limit_end_time
,admin_fee_rate                                                                                       as admin_fee_rate
,nominal_interest_rate                                                                                as nominal_interest_rate
,buyer_tx_fee_rate                                                                                    as buyer_tx_fee_rate
,late_charge_rate                                                                                     as late_charge_rate
,penalty_interest_rate                                                                                as penalty_interest_rate
,sync_status                                                                                          as sync_status
,user_type                                                                                            as user_type
,source                                                                                               as source
,sync_tag_status                                                                                      as sync_tag_status
,sync_temp_limit_result                                                                               as sync_temp_limit_result
,credit_type                                                                                          as credit_type
,installment_limit                                                                                    as installment_limit
,bnpl_limit                                                                                           as bnpl_limit
,activation_source                                                                                    as activation_source
,notes                                                                                                as notes
 
,_event
 from(
    select 
 hid                                                                                                  as hid
,id                                                                                                   as id
,platform_type                                                                                        as platform_type
,platform_user_id                                                                                     as platform_user_id
,base_limit                                                                                           as base_limit
,advanced_limit                                                                                       as advanced_limit
,spl                                                                                                  as spl
,instalment_two_month                                                                                 as instalment_two_month
,instalment_three_month                                                                               as instalment_three_month
,instalment_six_month                                                                                 as instalment_six_month
,event_id                                                                                             as event_id
,event_detail                                                                                         as event_detail
,status                                                                                               as status
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,operator                                                                                             as operator
,currency_units                                                                                       as currency_units
,temporary_limit                                                                                      as temporary_limit
,temp_limit_start_time                                                                                as temp_limit_start_time
,temp_limit_end_time                                                                                  as temp_limit_end_time
,admin_fee_rate                                                                                       as admin_fee_rate
,nominal_interest_rate                                                                                as nominal_interest_rate
,buyer_tx_fee_rate                                                                                    as buyer_tx_fee_rate
,late_charge_rate                                                                                     as late_charge_rate
,penalty_interest_rate                                                                                as penalty_interest_rate
,sync_status                                                                                          as sync_status
,user_type                                                                                            as user_type
,source                                                                                               as source
,sync_tag_status                                                                                      as sync_tag_status
,sync_temp_limit_result                                                                               as sync_temp_limit_result
,credit_type                                                                                          as credit_type
,installment_limit                                                                                    as installment_limit
,bnpl_limit                                                                                           as bnpl_limit
,activation_source                                                                                    as activation_source
,notes                                                                                                as notes
 
 ,_event
,row_number() over(partition by on_keys_conds order by  get_json_object(_event,'$.ts_ns') desc) as rn
    from (
        select 
 hid                                                                                                  as hid
,id                                                                                                   as id
,platform_type                                                                                        as platform_type
,platform_user_id                                                                                     as platform_user_id
,base_limit                                                                                           as base_limit
,advanced_limit                                                                                       as advanced_limit
,spl                                                                                                  as spl
,instalment_two_month                                                                                 as instalment_two_month
,instalment_three_month                                                                               as instalment_three_month
,instalment_six_month                                                                                 as instalment_six_month
,event_id                                                                                             as event_id
,event_detail                                                                                         as event_detail
,status                                                                                               as status
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,operator                                                                                             as operator
,currency_units                                                                                       as currency_units
,temporary_limit                                                                                      as temporary_limit
,temp_limit_start_time                                                                                as temp_limit_start_time
,temp_limit_end_time                                                                                  as temp_limit_end_time
,admin_fee_rate                                                                                       as admin_fee_rate
,nominal_interest_rate                                                                                as nominal_interest_rate
,buyer_tx_fee_rate                                                                                    as buyer_tx_fee_rate
,late_charge_rate                                                                                     as late_charge_rate
,penalty_interest_rate                                                                                as penalty_interest_rate
,sync_status                                                                                          as sync_status
,user_type                                                                                            as user_type
,source                                                                                               as source
,sync_tag_status                                                                                      as sync_tag_status
,sync_temp_limit_result                                                                               as sync_temp_limit_result
,credit_type                                                                                          as credit_type
,installment_limit                                                                                    as installment_limit
,bnpl_limit                                                                                           as bnpl_limit
,activation_source                                                                                    as activation_source
,notes                                                                                                as notes
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'),hid)           as on_keys_conds
,_event
        from risk.ods__cf_risk_underwriting_id_db__credit_sp_history_tab__df__private fs
        where grass_date = date_add('${ods_date_t1}', -1) 


        union all
        select 
 cast(get_json_object(data,'$.hid') as bigint)                                                        as hid
,cast(get_json_object(data,'$.id') as bigint)                                                         as id
,cast(get_json_object(data,'$.platform_type') as bigint)                                              as platform_type
,cast(get_json_object(data,'$.platform_user_id') as string)                                           as platform_user_id
,cast(get_json_object(data,'$.base_limit') as bigint)                                                 as base_limit
,cast(get_json_object(data,'$.advanced_limit') as bigint)                                             as advanced_limit
,cast(get_json_object(data,'$.spl') as bigint)                                                        as spl
,cast(get_json_object(data,'$.instalment_two_month') as bigint)                                       as instalment_two_month
,cast(get_json_object(data,'$.instalment_three_month') as bigint)                                     as instalment_three_month
,cast(get_json_object(data,'$.instalment_six_month') as bigint)                                       as instalment_six_month
,cast(get_json_object(data,'$.event_id') as string)                                                   as event_id
,cast(get_json_object(data,'$.event_detail') as string)                                               as event_detail
,cast(get_json_object(data,'$.status') as bigint)                                                     as status
,cast(get_json_object(data,'$.version') as bigint)                                                    as version
,cast(get_json_object(data,'$.create_time') as bigint)                                                as create_time
,cast(get_json_object(data,'$.update_time') as bigint)                                                as update_time
,cast(get_json_object(data,'$.operator') as string)                                                   as operator
,cast(get_json_object(data,'$.currency_units') as bigint)                                             as currency_units
,cast(get_json_object(data,'$.temporary_limit') as bigint)                                            as temporary_limit
,cast(get_json_object(data,'$.temp_limit_start_time') as bigint)                                      as temp_limit_start_time
,cast(get_json_object(data,'$.temp_limit_end_time') as bigint)                                        as temp_limit_end_time
,cast(get_json_object(data,'$.admin_fee_rate') as bigint)                                             as admin_fee_rate
,cast(get_json_object(data,'$.nominal_interest_rate') as bigint)                                      as nominal_interest_rate
,cast(get_json_object(data,'$.buyer_tx_fee_rate') as bigint)                                          as buyer_tx_fee_rate
,cast(get_json_object(data,'$.late_charge_rate') as bigint)                                           as late_charge_rate
,cast(get_json_object(data,'$.penalty_interest_rate') as bigint)                                      as penalty_interest_rate
,cast(get_json_object(data,'$.sync_status') as bigint)                                                as sync_status
,cast(get_json_object(data,'$.user_type') as bigint)                                                  as user_type
,cast(get_json_object(data,'$.source') as string)                                                     as source
,cast(get_json_object(data,'$.sync_tag_status') as decimal(20,0))                                     as sync_tag_status
,cast(get_json_object(data,'$.sync_temp_limit_result') as string)                                     as sync_temp_limit_result
,cast(get_json_object(data,'$.credit_type') as bigint)                                                as credit_type
,cast(get_json_object(data,'$.installment_limit') as bigint)                                          as installment_limit
,cast(get_json_object(data,'$.bnpl_limit') as bigint)                                                 as bnpl_limit
,cast(get_json_object(data,'$.activation_source') as bigint)                                          as activation_source
,cast(get_json_object(data,'$.notes') as string)                                                      as notes
 
 ,concat_ws('_', get_json_object(_event,'$.database'),get_json_object(_event,'$.table'), get_json_object(data,'$.hid')) as on_keys_conds
,_event
        from risk.ccin_multi_realtime_binlog_for_id 
        where base_database = 'cf_risk_underwriting_id_db' and base_table= 'credit_sp_history_tab'
        and (dt 
              between date_add('${ods_date_t1}', -2) and date_add('${ods_date_t1}', 10)
            ) 
        and from_unixtime(get_json_object(data,'$.update_time') - 3600 + 0 +0,'yyyy-MM-dd') <='${ods_date_t1}'
        
    ) a
   ) where  rn = 1 and nvl(get_json_object(_event,'$.type'),'') != 'delete'
)
insert overwrite table risk.ods__cf_risk_underwriting_id_db__credit_sp_history_tab__df__private partition(grass_date ='${ods_date_t1}')
select 
 hid                                                                                                  as hid
,id                                                                                                   as id
,platform_type                                                                                        as platform_type
,platform_user_id                                                                                     as platform_user_id
,base_limit                                                                                           as base_limit
,advanced_limit                                                                                       as advanced_limit
,spl                                                                                                  as spl
,instalment_two_month                                                                                 as instalment_two_month
,instalment_three_month                                                                               as instalment_three_month
,instalment_six_month                                                                                 as instalment_six_month
,event_id                                                                                             as event_id
,event_detail                                                                                         as event_detail
,status                                                                                               as status
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,operator                                                                                             as operator
,currency_units                                                                                       as currency_units
,temporary_limit                                                                                      as temporary_limit
,temp_limit_start_time                                                                                as temp_limit_start_time
,temp_limit_end_time                                                                                  as temp_limit_end_time
,admin_fee_rate                                                                                       as admin_fee_rate
,nominal_interest_rate                                                                                as nominal_interest_rate
,buyer_tx_fee_rate                                                                                    as buyer_tx_fee_rate
,late_charge_rate                                                                                     as late_charge_rate
,penalty_interest_rate                                                                                as penalty_interest_rate
,sync_status                                                                                          as sync_status
,user_type                                                                                            as user_type
,source                                                                                               as source
,sync_tag_status                                                                                      as sync_tag_status
,sync_temp_limit_result                                                                               as sync_temp_limit_result
,credit_type                                                                                          as credit_type
,installment_limit                                                                                    as installment_limit
,bnpl_limit                                                                                           as bnpl_limit
,activation_source                                                                                    as activation_source
,notes                                                                                                as notes
 
 ,_event
 ;