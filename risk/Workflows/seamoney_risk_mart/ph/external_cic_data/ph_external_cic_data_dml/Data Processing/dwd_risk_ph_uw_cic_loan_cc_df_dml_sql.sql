WITH cic_raw_base AS (
    SELECT
        grass_date,
        trace_id,
        GET_JSON_OBJECT(header_data, '$.CreditUserId') AS credit_user_id,
        GET_JSON_OBJECT(header_data, '$.PlatformUserId') AS platform_user_id,
        GET_JSON_OBJECT(header_data, '$.FlowNo') AS flow_no,
        DATE_FORMAT(DATE(GET_JSON_OBJECT(resp_raw_data, '$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.RequestTime')), 'yyyy-MM-dd') AS request_date,
        GET_JSON_OBJECT(resp_raw_data, '$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.RequestTime') AS request_date_time,
        -- 直接解析为JSON数组
        FROM_JSON(
            GET_JSON_OBJECT(resp_raw_data, '$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.CBOutput.ProductResponse.CBNAEProductOutput.CreditReport.ContractsHistory.CreditCards.GrantedContract'),
            'ARRAY<STRUCT<GrantedContract:STRING, GrantedCard:STRING, Profile:STRING>>'
        ) AS cic_cc_granted_contract,
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

-- 步骤1: 展开数组元素
expanded_contracts AS (
    SELECT
        grass_date,
        trace_id,
        credit_user_id,
        platform_user_id,
        flow_no,
        request_date,
        request_date_time,
        EXPLODE(cic_cc_granted_contract) AS contract
    FROM cic_raw_base
    WHERE cic_cc_granted_contract IS NOT NULL
        AND rn = 1
),

-- 步骤2: 解析GrantedContract结构
parsed_contract AS (
    SELECT
        *,
        FROM_JSON(contract.GrantedContract, '
            STRUCT<
                CBContractCode:STRING,
                ContractEndDate:STRING,
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
                RoleDesc:STRING,
                ContractStatus:STRING,
                ContractStatusDesc:STRING
            >
        ') AS granted_contract
    FROM expanded_contracts
),

-- 步骤3: 解析GrantedCard结构并安全转换数值
parsed_card AS (
    SELECT
        *,
        FROM_JSON(contract.GrantedCard, '
            STRUCT<
                CreditLimit:STRING,
                InstallmentType:STRING,
                InstallmentTypeDesc:STRING,
                LastPaymentAmount:STRING,
                LastPaymentDate:STRING,
                MonthlyPaymentAmount:STRING,
                NextPayment:STRING,
                OutstandingBalance:STRING,
                OutstandingBalanceUnbilled:STRING,
                OverdueDays:STRING,
                OverdueDaysDesc:STRING,
                OverduePaymentsAmount:STRING,
                OverduePaymentsNumber:STRING,
                PaymentMethod:STRING,
                PaymentMethodDesc:STRING,
                PaymentPeriodicity:STRING,
                PaymentPeriodicityDesc:STRING,
                ReorganizedCreditCode:STRING,
                ReorganizedCreditCodeDesc:STRING,
                TransactionType:STRING,
                TransactionTypeDesc:STRING
            >
        ') AS granted_card
    FROM parsed_contract
)


INSERT OVERWRITE TABLE risk.dwd_risk_ph_uw_cic_loan_cc_df
SELECT
    trace_id,
    credit_user_id,
    platform_user_id,
    flow_no,
    request_date,
    request_date_time,
    granted_contract.CBContractCode AS contract_code,
    granted_contract.ContractEndDate AS contract_end_date,
    granted_contract.ContractPhase AS contract_phase,
    granted_contract.ContractPhaseDesc AS contract_phase_desc,
    granted_contract.ContractStartDate AS contract_start_date,
    granted_contract.ContractType AS contract_type,
    granted_contract.ContractTypeDesc AS contract_type_desc,
    granted_contract.Currency AS currency,
    granted_contract.CurrencyDesc AS currency_desc,
    granted_contract.LastUpdateDate AS last_update_date,
    granted_contract.OriginalCurrency AS original_currency,
    granted_contract.OriginalCurrencyDesc AS original_currency_desc,
    granted_contract.ProviderCodeEncrypted AS provider_code_encrypted,
    granted_contract.ReferenceNo AS reference_no,
    granted_contract.Role AS role,
    granted_contract.RoleDesc AS role_desc,
    granted_contract.ContractStatus AS contract_status,
    granted_contract.ContractStatusDesc AS contract_status_desc,
    -- 数值字段转换（强制转换，若转换失败会报错）
    CAST(granted_card.CreditLimit AS DECIMAL(30,10)) AS credit_limit,
    granted_card.InstallmentType AS installment_type,
    granted_card.InstallmentTypeDesc AS installment_type_desc,
    CAST(granted_card.LastPaymentAmount AS DECIMAL(30,10)) AS last_payment_amount,
    granted_card.LastPaymentDate AS last_payment_date,
    CAST(granted_card.MonthlyPaymentAmount AS DECIMAL(30,10)) AS monthly_payment_amount,
    granted_card.NextPayment AS next_payment,
    CAST(granted_card.OutstandingBalance AS DECIMAL(30,10)) AS outstanding_balance,
    CAST(granted_card.OutstandingBalanceUnbilled AS DECIMAL(30,10)) AS outstanding_balance_unbilled,
    granted_card.OverdueDays AS overdue_days,
    granted_card.OverdueDaysDesc AS overdue_days_desc,
    CAST(granted_card.OverduePaymentsAmount AS DECIMAL(30,10)) AS overdue_payments_amount,
    CAST(granted_card.OverduePaymentsNumber AS DECIMAL(30,10)) AS overdue_payments_number,
    granted_card.PaymentMethod AS payment_method,
    granted_card.PaymentMethodDesc AS payment_method_desc,
    granted_card.PaymentPeriodicity AS payment_periodicity,
    granted_card.PaymentPeriodicityDesc AS payment_periodicity_desc,
    granted_card.ReorganizedCreditCode AS reorganized_credit_code,
    granted_card.ReorganizedCreditCodeDesc AS reorganized_credit_code_desc,
    granted_card.TransactionType AS transaction_type,
    granted_card.TransactionTypeDesc AS transaction_type_desc,
    grass_date
FROM parsed_card;