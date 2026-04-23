
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
            GET_JSON_OBJECT(resp_raw_data, '$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.CBOutput.ProductResponse.CBNAEProductOutput.CreditReport.ContractsHistory.NonInstallments.GrantedContract'),
            'ARRAY<STRUCT<GrantedContract:STRING, GrantedNonInstallment:STRING, Profile:STRING, Guarantee:STRING>>'
        ) AS cic_non_instalm_granted_contract,
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
        EXPLODE(cic_non_instalm_granted_contract) AS contract
    FROM cic_raw_base
    WHERE cic_non_instalm_granted_contract IS NOT NULL and rn = 1
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

-- 步骤3: 解析GrantedNonInstallment结构
parsed_noninstallment AS (
    SELECT
        *,
        FROM_JSON(contract.GrantedNonInstallment, '
            STRUCT<
                CreditLimit:STRING,
                LastPaymentDate:STRING,
                OverallCreditLimit:STRING,
                OverduePaymentsAmount:STRING,
                TransactionType:STRING,
                TransactionTypeDesc:STRING,
                Utilization:STRING
            >
        ') AS granted_noninstallment
    FROM parsed_contract
),

-- 步骤4: 解析Guarantee结构
parsed_guarantee AS (
    SELECT
        *,
        FROM_JSON(contract.Guarantee, '
            STRUCT<
                Text:STRING,
                GuaranteedAmount:STRING,
                GuarantorName:STRING,
                ProviderGuaranteeNo:STRING,
                ValidityEndDate:STRING,
                ValidityStartDate:STRING,
                Real:STRUCT<
                    Text:STRING,
                    RealGuaranteeCode:STRING,
                    RealGuaranteesDesc:STRING
                >
            >
        ') AS guarantee
    FROM parsed_noninstallment
)


INSERT OVERWRITE TABLE risk.dwd_risk_ph_uw_cic_loan_non_instalm_df

SELECT
    --grass_date,
    trace_id,
    credit_user_id,
    platform_user_id,
    flow_no,
    request_date,
    request_date_time,
    
    -- GrantedContract字段
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
    
    -- GrantedNonInstallment字段
    CAST(granted_noninstallment.CreditLimit AS DECIMAL(30,10)) AS credit_limit,
    granted_noninstallment.LastPaymentDate AS last_payment_date,
    CAST(granted_noninstallment.OverallCreditLimit AS DECIMAL(30,10)) AS overall_credit_limit,
    CAST(granted_noninstallment.OverduePaymentsAmount AS DECIMAL(30,10)) AS overdue_payments_amount,
    granted_noninstallment.TransactionType AS transaction_type,
    granted_noninstallment.TransactionTypeDesc AS transaction_type_desc,
    CAST(granted_noninstallment.Utilization AS DECIMAL(30,10)) AS utilization,
    
    -- Guarantee字段
    guarantee.Text AS text,
    CAST(guarantee.GuaranteedAmount AS DECIMAL(30,10)) AS guaranteed_amount,
    guarantee.GuarantorName AS guarantor_name,
    guarantee.ProviderGuaranteeNo AS provider_guarantee_no,
    guarantee.ValidityEndDate AS validity_end_date,
    guarantee.ValidityStartDate AS validity_start_date,
    guarantee.Real.Text AS real_text,
    guarantee.Real.RealGuaranteeCode AS real_guarantee_code,
    guarantee.Real.RealGuaranteesDesc AS real_guarantee_code_desc,
    grass_date
FROM parsed_guarantee;