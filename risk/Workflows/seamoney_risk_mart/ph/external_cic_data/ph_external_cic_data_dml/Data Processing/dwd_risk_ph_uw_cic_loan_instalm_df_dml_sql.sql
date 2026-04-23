
WITH cic_raw_base AS (
    SELECT
        grass_date,
        trace_id,
        GET_JSON_OBJECT(header_data, '$.CreditUserId') AS credit_user_id,
        GET_JSON_OBJECT(header_data, '$.PlatformUserId') AS platform_user_id,
        GET_JSON_OBJECT(header_data, '$.FlowNo') AS flow_no,
        DATE_FORMAT(DATE(GET_JSON_OBJECT(resp_raw_data, '$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.RequestTime')), 'yyyy-MM-dd') AS request_date,
        GET_JSON_OBJECT(resp_raw_data, '$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.RequestTime') AS request_date_time,
        FROM_JSON(
            GET_JSON_OBJECT(resp_raw_data, '$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.CBOutput.ProductResponse.CBNAEProductOutput.CreditReport.ContractsHistory.Installments.GrantedContract'),
            'ARRAY<STRUCT<GrantedContract:STRING, GrantedInstallment:STRING, Leasing:STRING, Profile:STRING, Guarantee:STRING>>'
        ) AS cic_instalm_granted_contract,
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

-- 步骤1: 展开主合约数组
expanded_contracts AS (
    SELECT
        grass_date,
        trace_id,
        credit_user_id,
        platform_user_id,
        flow_no,
        request_date,
        request_date_time,
        EXPLODE(cic_instalm_granted_contract) AS contract
    FROM cic_raw_base
    WHERE cic_instalm_granted_contract IS NOT NULL and rn = 1
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
                RoleDesc:STRING
            >
        ') AS granted_contract
    FROM expanded_contracts
),

-- 步骤3: 解析GrantedInstallment结构
parsed_installment AS (
    SELECT
        *,
        FROM_JSON(contract.GrantedInstallment, '
            STRUCT<
                CreditPurpose:STRING,
                CreditPurposeDesc:STRING,
                FinancedAmount:STRING,
                InstallmentsNumber:STRING,
                LastPaymentAmount:STRING,
                MonthlyPaymentAmount:STRING,
                OutstandingBalance:STRING,
                OutstandingPaymentsNumber:STRING,
                OverdueDays:STRING,
                OverdueDaysDesc:STRING,
                OverduePaymentsAmount:STRING,
                OverduePaymentsNumber:STRING,
                PaymentMethod:STRING,
                PaymentMethodDesc:STRING,
                PaymentPeriodicity:STRING,
                PaymentPeriodicityDesc:STRING,
                TransactionType:STRING,
                TransactionTypeDesc:STRING,
                LastPaymentDate:STRING
            >
        ') AS granted_installment
    FROM parsed_contract
),

-- 步骤4: 解析Leasing结构
parsed_leasing AS (
    SELECT
        *,
        FROM_JSON(contract.Leasing, '
            STRUCT<
                GoodBrand:STRING,
                GoodType:STRING,
                GoodTypeDesc:STRING,
                GoodValue:STRING,
                ManufacturingDate:STRING,
                NewUsedCode:STRING,
                NewUsedCodeDesc:STRING,
                RegistrationNumber:STRING
            >
        ') AS leasing
    FROM parsed_installment
)

INSERT OVERWRITE TABLE risk.dwd_risk_ph_uw_cic_loan_instalm_df

SELECT
    --grass_date,
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
    
    granted_installment.CreditPurpose AS credit_purpose,
    granted_installment.CreditPurposeDesc AS credit_purpose_desc,
    CAST(granted_installment.FinancedAmount AS DECIMAL(30,10)) AS financial_amount,
    CAST(granted_installment.InstallmentsNumber AS BIGINT) AS installments_number,
    CAST(granted_installment.LastPaymentAmount AS DECIMAL(30,10)) AS last_payment_amount,
    CAST(granted_installment.MonthlyPaymentAmount AS DECIMAL(30,10)) AS monthly_payment_amount,
    CAST(granted_installment.OutstandingBalance AS DECIMAL(30,10)) AS outstanding_balance,
    CAST(granted_installment.OutstandingPaymentsNumber AS BIGINT) AS outstanding_payments_number,
    granted_installment.OverdueDays AS overdue_days,
    granted_installment.OverdueDaysDesc AS overdue_days_desc,
    CAST(granted_installment.OverduePaymentsAmount AS DECIMAL(30,10)) AS overdue_payments_amount,
    CAST(granted_installment.OverduePaymentsNumber AS BIGINT) AS overdue_payments_number,
    granted_installment.PaymentMethod AS payment_method,
    granted_installment.PaymentMethodDesc AS payment_method_desc,
    granted_installment.PaymentPeriodicity AS payment_periodicity,
    granted_installment.PaymentPeriodicityDesc AS payment_periodicity_desc,
    granted_installment.TransactionType AS transaction_type,
    granted_installment.TransactionTypeDesc AS transaction_type_desc,
    granted_installment.LastPaymentDate AS last_payment_date,
    
    leasing.GoodBrand AS good_brand,
    leasing.GoodType AS good_type,
    leasing.GoodTypeDesc AS good_type_desc,
    CAST(leasing.GoodValue AS DECIMAL(30,10)) AS good_value,
    leasing.ManufacturingDate AS manufacturing_date,
    leasing.NewUsedCode AS new_used_code,
    leasing.NewUsedCodeDesc AS new_used_code_desc,
    leasing.RegistrationNumber AS registration_number,
    grass_date
FROM parsed_leasing;