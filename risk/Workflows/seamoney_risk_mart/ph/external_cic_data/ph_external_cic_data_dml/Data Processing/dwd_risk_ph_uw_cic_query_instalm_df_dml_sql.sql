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
            GET_JSON_OBJECT(resp_raw_data, '$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.CBOutput.ProductResponse.CBNAEProductOutput.CreditReport.ContractsHistory.Installments.NotGrantedContract'),
            'ARRAY<STRUCT<NotGrantedContract:STRING, NotGrantedInstallment:STRING, LinkedSubject:STRING>>'
        ) AS cic_instalm_not_granted_contract,
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

expanded_contracts AS (
    SELECT
        grass_date,
        trace_id,
        credit_user_id,
        platform_user_id,
        flow_no,
        request_date,
        request_date_time,
        EXPLODE(cic_instalm_not_granted_contract) AS contract
    FROM cic_raw_base
    WHERE cic_instalm_not_granted_contract IS NOT NULL and rn = 1
),

parsed_contract AS (
    SELECT
        *,
        FROM_JSON(contract.NotGrantedContract, '
            STRUCT<
                CBContractCode:STRING,
                ContractPhase:STRING,
                ContractPhaseDesc:STRING,
                ContractRequestDate:STRING,
                ContractType:STRING,
                ContractTypeDesc:STRING,
                LastUpdateDate:STRING,
                ProviderCodeEncrypted:STRING,
                ProviderContractNo:STRING,
                ReferenceNo:STRING,
                Role:STRING,
                RoleDesc:STRING
            >
        ') AS not_granted_contract,
        FROM_JSON(contract.NotGrantedInstallment, '
            STRUCT<
                FinancedAmount:STRING,
                InstallmentsNumber:STRING,
                PaymentPeriodicity:STRING,
                PaymentPeriodicityDesc:STRING
            >
        ') AS not_granted_installment,
        FROM_JSON(contract.LinkedSubject, '
            STRUCT<
                CBSubjectCode:STRING,
                Name:STRING,
                Role:STRING,
                RoleDesc:STRING
            >
        ') AS linked_subject
    FROM expanded_contracts
)
INSERT OVERWRITE TABLE risk.dwd_risk_ph_uw_cic_query_instalm_df
SELECT
    -- grass_date,
    trace_id,
    credit_user_id,
    platform_user_id,
    flow_no,
    request_date,
    request_date_time,
    not_granted_contract.CBContractCode AS contract_code,
    not_granted_contract.ContractPhase AS contract_phase,
    not_granted_contract.ContractPhaseDesc AS contract_phase_desc,
    not_granted_contract.ContractRequestDate AS contract_request_date,
    not_granted_contract.ContractType AS contract_type,
    not_granted_contract.ContractTypeDesc AS contract_type_desc,
    not_granted_contract.LastUpdateDate AS last_update_date,
    not_granted_contract.ProviderCodeEncrypted AS provider_code_encrypted,
    not_granted_contract.ProviderContractNo AS provider_contract_no,
    not_granted_contract.ReferenceNo AS reference_no,
    not_granted_contract.Role AS role,
    not_granted_contract.RoleDesc AS role_desc,
    CAST(not_granted_installment.FinancedAmount AS DECIMAL(30,10)) AS financial_amount,
    CAST(not_granted_installment.InstallmentsNumber AS BIGINT) AS installments_number,
    not_granted_installment.PaymentPeriodicity AS payment_periodicity,
    not_granted_installment.PaymentPeriodicityDesc AS payment_periodicity_desc,
    linked_subject.CBSubjectCode AS linked_subject_code,
    linked_subject.Name AS linked_subject_name,
    linked_subject.Role AS linked_subject_role,
    linked_subject.RoleDesc AS linked_subject_role_desc,
    grass_date
FROM parsed_contract;