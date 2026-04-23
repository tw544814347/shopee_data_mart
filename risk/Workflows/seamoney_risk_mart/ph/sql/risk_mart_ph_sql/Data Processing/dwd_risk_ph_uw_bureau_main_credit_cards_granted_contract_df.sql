insert overwrite table risk.dwd_risk_ph_uw_bureau_main_credit_cards_granted_contract_df partition(grass_date)
select
    platform_user_id
    ,flow_no
    ,request_time
    ,cast(get_json_object(json_string,'$.GrantedContract.CBContractCode') as string)                    as cb_contract_code
    ,cast(get_json_object(json_string,'$.GrantedContract.ContractPhaseDesc') as string)                 as contract_phase_desc
    ,cast(get_json_object(json_string,'$.GrantedContract.ContractStartDate') as string)                 as contract_start_date
    ,cast(get_json_object(json_string,'$.GrantedContract.ContractStatusDesc') as string)                as contract_status_desc
    ,cast(get_json_object(json_string,'$.GrantedContract.ContractTypeDesc') as string)                  as contract_type_desc
    ,cast(get_json_object(json_string,'$.GrantedContract.LastUpdateDate') as string)                    as last_update_date
    ,cast(get_json_object(json_string,'$.GrantedContract.ProviderCodeEncrypted') as string)             as provider_code_encrypted
    ,cast(get_json_object(json_string,'$.GrantedContract.ReferenceNo') as string)                       as reference_no
    ,cast(get_json_object(json_string,'$.GrantedContract.RoleDesc') as string)                          as role_desc
    ,cast(get_json_object(json_string,'$.GrantedContract.ContractEndDate') as string)                   as contract_end_date
    ,cast(get_json_object(json_string,'$.GrantedCard.CreditLimit') as string)                           as credit_limit
    ,cast(get_json_object(json_string,'$.GrantedCard.InstallmentTypeDesc') as string)                   as installment_type_desc
    ,cast(get_json_object(json_string,'$.GrantedCard.LastPaymentAmount') as string)                     as last_payment_amount
    ,cast(get_json_object(json_string,'$.GrantedCard.LastPaymentDate') as string)                       as last_payment_date
    ,cast(get_json_object(json_string,'$.GrantedCard.MonthlyPaymentAmount') as string)                  as monthly_payment_amount
    ,cast(get_json_object(json_string,'$.GrantedCard.NextPayment') as string)                           as next_payment
    ,cast(get_json_object(json_string,'$.GrantedCard.OutstandingBalance') as string)                    as outstanding_balance
    ,cast(get_json_object(json_string,'$.GrantedCard.OutstandingBalanceUnbilled') as string)            as outstanding_balance_unbilled
    ,cast(get_json_object(json_string,'$.GrantedCard.OverdueDays') as string)                           as overdue_days
    ,cast(get_json_object(json_string,'$.GrantedCard.OverdueDaysDesc') as string)                       as overdue_days_desc
    ,cast(get_json_object(json_string,'$.GrantedCard.OverduePaymentsAmount') as string)                 as overdue_payments_amount
    ,cast(get_json_object(json_string,'$.GrantedCard.OverduePaymentsNumber') as string)                 as overdue_payments_number
    ,cast(get_json_object(json_string,'$.GrantedCard.PaymentMethodDesc') as string)                     as payment_method_desc
    ,cast(get_json_object(json_string,'$.GrantedCard.PaymentPeriodicityDesc') as string)                as payment_periodicity_desc
    ,cast(get_json_object(json_string,'$.GrantedCard.ReorganizedCreditCodeDesc') as string)             as reorganized_credit_code_desc
    ,cast(get_json_object(json_string,'$.GrantedCard.TransactionTypeDesc') as string)                   as transaction_type_desc
    ,grass_date
from(
    select
        platform_user_id
        ,flow_no
        ,request_time
        ,split(regexp_replace(regexp_extract(temp_string_array,'^\\[(.+)\\]$',1),'\\]\\}\\,\\{','\\]\\}\\|\\|\\{'),'\\|\\|') as temp_json_list
        ,grass_date
    from(
        select
            cast(get_json_object(header_data,'$.PlatformUserId') as string )  as platform_user_id
            ,cast(get_json_object(header_data,'$.FlowNo') as string )         as flow_no
            ,create_time                                                      as request_time
            ,get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.CBOutput.ProductResponse.CBNAEProductOutput.CreditReport.ContractsHistory.CreditCards.GrantedContract')  as temp_string_array
            ,grass_date
        from risk.ods__credit_risk_datafetch_ph_db__identity_data_history_tab__df
        where grass_date = '${grass_date}'
        and data_source_name = 'CrifData'
        and data_source_code = 2

    )a
)b lateral view explode(temp_json_list) as json_string;
