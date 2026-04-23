-- https://jira.shopee.io/browse/SPFDT-50408 --迭代 v1 20250328

WITH base_data AS (
    SELECT 
        grass_date,
        trace_id,
        GET_JSON_OBJECT(header_data, '$.CreditUserId') AS credit_user_id,
        GET_JSON_OBJECT(header_data, '$.PlatformUserId') AS platform_user_id,
        GET_JSON_OBJECT(header_data, '$.FlowNo') AS flow_no,
        DATE_FORMAT(DATE(GET_JSON_OBJECT(resp_raw_data, '$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.RequestTime')), 'yyyy-MM-dd') AS request_date,
        GET_JSON_OBJECT(resp_raw_data, '$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.RequestTime') AS request_date_time,
        GET_JSON_OBJECT(resp_raw_data, '$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.CBOutput.ProductResponse.CBNAEProductOutput.CreditReport.ContractsHistory.NonInstallments.NotGrantedContract') AS cic_non_instalm_not_granted_contract,
        ROW_NUMBER() OVER (
            PARTITION BY 
                grass_date,
                trace_id,
                GET_JSON_OBJECT(header_data, '$.CreditUserId'),
                GET_JSON_OBJECT(header_data, '$.PlatformUserId'),
                GET_JSON_OBJECT(header_data, '$.FlowNo'),
                DATE_FORMAT(DATE(GET_JSON_OBJECT(resp_raw_data, '$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.RequestTime')), 'yyyy-MM-dd'),
                GET_JSON_OBJECT(resp_raw_data, '$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.RequestTime')
            ORDER BY GET_JSON_OBJECT(resp_raw_data, '$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.RequestTime') DESC
        ) AS rn
    FROM risk.ods__credit_risk_datafetch_ph_db__identity_data_history_tab__df
    WHERE grass_date = '${grass_date}'
      AND data_source_name = 'CrifData'
      AND GET_JSON_OBJECT(resp_raw_data, '$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.CBOutput.ProductResponse.ResultCode') = 'S'
),
parsed_base AS (
    SELECT 
        grass_date,
        trace_id,
        credit_user_id,
        platform_user_id,
        flow_no,
        request_date,
        request_date_time,
        -- 精确修复JSON数组格式
        CASE 
            WHEN SUBSTR(cic_non_instalm_not_granted_contract, 1, 1) = '{'
                THEN CONCAT('[', cic_non_instalm_not_granted_contract, ']')
            ELSE cic_non_instalm_not_granted_contract
        END AS fixed_contract_json
    FROM base_data
    WHERE rn = 1
      AND cic_non_instalm_not_granted_contract IS NOT NULL
      AND LENGTH(cic_non_instalm_not_granted_contract) > 0
),
json_parsed AS (
    SELECT 
        *,
        FROM_JSON(
            fixed_contract_json,
            'ARRAY<STRUCT<
                NotGrantedContract:STRUCT<
                    CBContractCode:STRING,
                    ContractPhase:STRING,
                    ContractPhaseDesc:STRING,
                    ContractRequestDate:STRING,
                    ContractType:STRING,
                    ContractTypeDesc:STRING,
                    LastUpdateDate:STRING,
                    ProviderCodeEncrypted:STRING,
                    ReferenceNo:STRING,
                    Role:STRING,
                    RoleDesc:STRING
                >,
                NotGrantedNonInstallment:STRUCT<CreditLimit:STRING>
            >>'
        ) AS contracts_array
    FROM parsed_base
),
exploded_data AS (
    SELECT 
        grass_date AS grass_date,
        trace_id AS trace_id,
        credit_user_id AS credit_user_id,
        platform_user_id AS platform_user_id,
        flow_no AS flow_no,
        request_date AS request_date,
        request_date_time AS request_date_time,
        contract_item.NotGrantedContract.CBContractCode AS contract_code,  -- 小写下划线
        contract_item.NotGrantedContract.ContractPhase AS contract_phase,  -- 小写下划线
        contract_item.NotGrantedContract.ContractPhaseDesc AS contract_phase_desc,
        contract_item.NotGrantedContract.ContractRequestDate AS contract_request_date,
        contract_item.NotGrantedContract.ContractType AS contract_type,
        contract_item.NotGrantedContract.ContractTypeDesc AS contract_type_desc,
        contract_item.NotGrantedContract.LastUpdateDate AS last_update_date,
        contract_item.NotGrantedContract.ProviderCodeEncrypted AS provider_code_encrypted,
        contract_item.NotGrantedContract.ReferenceNo AS reference_no,
        contract_item.NotGrantedContract.Role AS role,
        contract_item.NotGrantedContract.RoleDesc AS role_desc,
        contract_item.NotGrantedNonInstallment.CreditLimit AS credit_limit  -- 直接使用目标字段名
    FROM json_parsed
    LATERAL VIEW explode(contracts_array) exploded AS contract_item
)

INSERT OVERWRITE TABLE risk.dwd_risk_ph_uw_cic_query_non_instalm_df

SELECT 
    trace_id,
    credit_user_id,
    platform_user_id,
    flow_no,
    request_date,
    request_date_time,
    contract_code,        -- 使用新别名
    contract_phase,
    contract_phase_desc,
    contract_request_date,
    contract_type,
    contract_type_desc,
    last_update_date,
    provider_code_encrypted,
    reference_no,
    role,
    role_desc,
    CAST(credit_limit AS DOUBLE) AS credit_limit,  -- 保持字段名一致
    grass_date
FROM exploded_data
WHERE contract_code IS NOT NULL    -- 使用新别名
    AND contract_code != ''
;