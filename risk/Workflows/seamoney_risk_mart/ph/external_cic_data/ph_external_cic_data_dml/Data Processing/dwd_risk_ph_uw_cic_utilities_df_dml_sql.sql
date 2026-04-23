

WITH raw_data AS (
    SELECT 
        grass_date,
        trace_id,
        GET_JSON_OBJECT(header_data, '$.CreditUserId') AS credit_user_id,
        GET_JSON_OBJECT(header_data, '$.PlatformUserId') AS platform_user_id,
        GET_JSON_OBJECT(header_data, '$.FlowNo') AS flow_no,
        DATE_FORMAT(DATE(GET_JSON_OBJECT(resp_raw_data, '$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.RequestTime')), 'yyyy-MM-dd') AS request_date,
        GET_JSON_OBJECT(resp_raw_data, '$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.RequestTime') AS request_date_time,
        GET_JSON_OBJECT(resp_raw_data, '$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.CBOutput.ProductResponse.CBNAEProductOutput.CreditReport.ContractsHistory.Utilities.GrantedContract') AS cic_utilities_granted_contract,
        ROW_NUMBER() OVER (
            PARTITION BY 
                grass_date,
                trace_id,
                GET_JSON_OBJECT(header_data, '$.CreditUserId'),
                GET_JSON_OBJECT(header_data, '$.PlatformUserId'),
                GET_JSON_OBJECT(header_data, '$.FlowNo'),
                DATE_FORMAT(DATE(GET_JSON_OBJECT(resp_raw_data, '$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.RequestTime')), 'yyyy-MM-dd'),
                GET_JSON_OBJECT(resp_raw_data, '$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.RequestTime')
            ORDER BY GET_JSON_OBJECT(resp_raw_data, '$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.RequestTime') DESC  -- 保留最新记录
        ) AS rn
    FROM risk.ods__credit_risk_datafetch_ph_db__identity_data_history_tab__df
    WHERE grass_date = '${grass_date}'
    AND data_source_name = 'CrifData'
    AND GET_JSON_OBJECT(resp_raw_data, '$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.CBOutput.ProductResponse.ResultCode') = 'S'
),
exploded_array AS (
    SELECT 
        *,
        EXPLODE(
            FROM_JSON(
                cic_utilities_granted_contract,
                'ARRAY<STRUCT<GrantedContract:STRING,GrantedUtility:STRING,Profile:STRING>>'
            )
        ) AS contract_item
    FROM raw_data
    WHERE cic_utilities_granted_contract IS NOT NULL and rn = 1
),
parsed_contract AS (
    SELECT
        grass_date,
        trace_id,
        credit_user_id,
        platform_user_id,
        flow_no,
        request_date,
        request_date_time,
        FROM_JSON(contract_item.GrantedContract, '
            STRUCT<
                CBContractCode:STRING,
                ContractPhase:STRING,
                ContractPhaseDesc:STRING,
                ContractStartDate:STRING,
                ContractType:STRING,
                ContractTypeDesc:STRING,
                Currency:STRING,
                CurrencyDesc:STRING,
                LastUpdateDate:STRING,
                OriginalCurrency:STRING,
                OriginalCurrencyDesc:STRING,
                ProviderCodeEncrypted:STRING,
                ReferenceNo:STRING,
                Role:STRING,
                RoleDesc:STRING
            >
            ') AS contract,
        FROM_JSON(contract_item.GrantedUtility, '
            STRUCT<
                BilledAmount:STRING,
                LastPaymentDate:STRING,
                NextPaymentDate:STRING,
                OutstandingBalance:STRING,
                OverdueDays:STRING,
                OverdueDaysDesc:STRING,
                OverduePaymentsAmount:STRING,
                OverduePaymentsNumber:STRING,
                PaymentMethod:STRING,
                PaymentMethodDesc:STRING,
                PaymentPeriodicity:STRING,
                PaymentPeriodicityDesc:STRING
            >
            ') AS utility,
        contract_item.Profile AS profile
    FROM exploded_array
)

INSERT OVERWRITE TABLE risk.dwd_risk_ph_uw_cic_utilities_df
SELECT
    -- grass_date,
    trace_id,
    credit_user_id,
    platform_user_id,
    flow_no,
    request_date,
    request_date_time,
    contract.CBContractCode AS contract_code,
    contract.ContractPhase,
    contract.ContractPhaseDesc,
    contract.ContractStartDate,
    contract.ContractType,
    contract.ContractTypeDesc,
    contract.Currency,
    contract.CurrencyDesc,
    contract.LastUpdateDate,
    contract.OriginalCurrency,
    contract.OriginalCurrencyDesc,
    contract.ProviderCodeEncrypted,
    contract.ReferenceNo,
    contract.Role,
    contract.RoleDesc,
    profile,
    CAST(utility.BilledAmount AS DOUBLE) AS billed_amount,
    utility.LastPaymentDate,
    utility.NextPaymentDate,
    CAST(utility.OutstandingBalance AS DOUBLE) AS outstanding_balance,
    utility.OverdueDays,
    utility.OverdueDaysDesc,
    CAST(utility.OverduePaymentsAmount AS DOUBLE) AS overdue_payments_amount,
    CAST(utility.OverduePaymentsNumber AS DOUBLE) AS overdue_payments_number,
    utility.PaymentMethod,
    utility.PaymentMethodDesc,
    utility.PaymentPeriodicity,
    utility.PaymentPeriodicityDesc,
    grass_date AS grass_date
FROM parsed_contract
WHERE contract.CBContractCode <> '';