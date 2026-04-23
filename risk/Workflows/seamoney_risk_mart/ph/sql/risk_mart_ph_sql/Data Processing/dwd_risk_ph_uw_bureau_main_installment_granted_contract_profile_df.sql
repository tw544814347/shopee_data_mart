insert overwrite table risk.dwd_risk_ph_uw_bureau_main_installment_granted_contract_profile_df partition(grass_date)
select
platform_user_id
,flow_no
,request_time
,cb_contract_code
,contract_phase_desc
,cast(get_json_object(profile_json_string,'$.OverdueDays') as string) as overdue_days
,cast(get_json_object(profile_json_string,'$.OverdueDaysDesc') as string) as overdue_days_desc
,cast(get_json_object(profile_json_string,'$.OverduePaymentsAmount') as string) as overdue_payments_amount
,cast(get_json_object(profile_json_string,'$.ReferenceMonth') as string) as reference_month
,cast(get_json_object(profile_json_string,'$.ReferenceYear') as string) as reference_year
,grass_date
from(
    select
    platform_user_id
    ,flow_no
    ,request_time
    ,cb_contract_code
    ,contract_phase_desc
    ,split(regexp_replace(regexp_extract(profile_json_array,'^\\[(.+)\\]$',1),'\\}\\,\\{','\\}\\|\\|\\{'),'\\|\\|') as profile_json_list
    ,grass_date
    from(
        select
            platform_user_id
            ,flow_no
            ,request_time
            ,cast(get_json_object(json_string,'$.GrantedContract.CBContractCode') as string) as cb_contract_code
            ,cast(get_json_object(json_string,'$.GrantedContract.ContractPhaseDesc') as string) as contract_phase_desc
            ,cast(get_json_object(json_string,'$.Profile') as string) as profile_json_array
            ,grass_date
        from(
            select
                platform_user_id
                ,flow_no
                ,request_time
                ,split(regexp_replace(regexp_extract(temp_string_array,'^\\[(.+)\\]$',1),'\\}\\,\\{\\"GrantedContract','\\}\\|\\|\\{\\"GrantedContract'),'\\|\\|') as temp_json_list
                ,grass_date
            from(
                select
                     cast(get_json_object(header_data,'$.PlatformUserId') as string )  as platform_user_id
                    ,cast(get_json_object(header_data,'$.FlowNo') as string )          as flow_no
                    ,create_time                                                       as request_time
                    ,get_json_object(resp_raw_data,'$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.CBOutput.ProductResponse.CBNAEProductOutput.CreditReport.ContractsHistory.Installments.GrantedContract')  as temp_string_array
                    ,grass_date
                from risk.ods__credit_risk_datafetch_ph_db__identity_data_history_tab__df
                where grass_date = '${grass_date}'
                and data_source_name = 'CrifData'
                and data_source_code = 2
            )a
        )b lateral view explode(temp_json_list) as json_string
    )c
)d lateral view explode(profile_json_list) as profile_json_string;
