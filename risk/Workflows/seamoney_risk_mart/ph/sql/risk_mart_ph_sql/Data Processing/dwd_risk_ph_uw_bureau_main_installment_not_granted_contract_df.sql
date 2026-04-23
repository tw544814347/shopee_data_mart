
insert overwrite table risk.dwd_risk_ph_uw_bureau_main_installment_not_granted_contract_df partition(grass_date)
select
    platform_user_id
    ,flow_no
    ,request_time
    ,cast(get_json_object(json_string,'$.NotGrantedContract.CBContractCode') as string) as cb_contract_code
    ,cast(get_json_object(json_string,'$.NotGrantedContract.ContractPhaseDesc') as string) as contract_phase_desc
    ,cast(get_json_object(json_string,'$.NotGrantedContract.ContractRequestDate') as string) as contract_request_date
    ,cast(get_json_object(json_string,'$.NotGrantedContract.ContractTypeDesc') as string) as contract_type_desc
    ,cast(get_json_object(json_string,'$.NotGrantedContract.LastUpdateDate') as string) as last_update_date
    ,cast(get_json_object(json_string,'$.NotGrantedContract.ProviderCodeEncrypted') as string) as provider_code_encrypted
    ,cast(get_json_object(json_string,'$.NotGrantedContract.ReferenceNo') as string) as reference_no
    ,cast(get_json_object(json_string,'$.NotGrantedContract.RoleDesc') as string) as role_desc
    ,cast(get_json_object(json_string,'$.NotGrantedInstallment.FinancedAmount') as string) as financed_amount
    ,cast(get_json_object(json_string,'$.NotGrantedInstallment.InstallmentsNumber') as string) as installments_number
    ,cast(get_json_object(json_string,'$.NotGrantedInstallment.PaymentPeriodicityDesc') as string) as payment_periodicity_desc
    ,grass_date
from(
    select
        platform_user_id
        ,flow_no
        ,request_time
        ,split(regexp_replace(regexp_extract(temp_string_array,'^\\[(.+)\\]$',1),'\\}\\,\\{','\\}\\|\\|\\{'),'\\|\\|') as temp_json_list
        ,grass_date
    from(
        select
             cast(get_json_object(header_data,'$.PlatformUserId') as string )  as platform_user_id
            ,cast(get_json_object(header_data,'$.FlowNo') as string )          as flow_no
            ,create_time                                                       as request_time
            ,get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.CBOutput.ProductResponse.CBNAEProductOutput.CreditReport.ContractsHistory.Installments.NotGrantedContract')  as temp_string_array
            ,grass_date
        from risk.ods__credit_risk_datafetch_ph_db__identity_data_history_tab__df
        where grass_date = '${grass_date}'
        and data_source_name = 'CrifData'
        and data_source_code = 2
    )a
)b lateral view explode(temp_json_list) as json_string;

