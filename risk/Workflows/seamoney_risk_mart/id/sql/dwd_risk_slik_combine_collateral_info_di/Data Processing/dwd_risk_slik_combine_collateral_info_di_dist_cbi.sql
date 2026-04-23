WITH slik_map AS (
    SELECT
        trace_id,
        get_json_object(header_data, '$.CreditUserId') as credit_user_id,
        get_json_object(header_data, '$.PlatformUserId') as platform_user_id,
        get_json_object(header_data, '$.FlowNo') as flow_no,
        get_json_object(req_data, '$.IdNumber') as ktp_no,
        get_json_object(resp_raw_data, '$.status') as status,
        get_json_object(resp_raw_data, '$.error') as is_error,
        substr(create_time,1,10) as create_time,
        explode(
        from_json(get_json_object(resp_raw_data, '$.SlikReports'), 'map<string,string>')
        ) AS (reference_number, value_str)
    FROM risk.ods__credit_risk_datafetch_id_db__identity_data_tab__df
    WHERE grass_date = '${ds}' AND data_source_name = 'CBI' AND datediff(date(grass_date), date(substr(create_time, 1, 10))) <= 90
    ), 
non_empty_report AS (
    SELECT
        trace_id,
        credit_user_id,
        platform_user_id,
        flow_no,
        ktp_no,
        reference_number as report_no,
        status,
        is_error,
        create_time,
        get_json_object(value_str, '$.result.BureauReport.ReportInfo.RINF_ReportDateTime') as report_update_time,
        value_str
    FROM slik_map
    WHERE value_str IS NOT NULL AND length(trim(value_str)) > 2  -- 简单判断非空json字符串
        AND get_json_object(value_str, '$.error') <> true 
    ),
active_loan_data_tmp AS (
        SELECT
            trace_id,
            credit_user_id,
            platform_user_id,
            flow_no,
            ktp_no,
            report_no,
            status,
            is_error,
            create_time,
            report_update_time,
            from_json(
            get_json_object(value_str, '$.result.BureauReport.CreditFacilityDetail.CREDIT_ActiveFacility_AsDebtor.CREDIT_ActiveFacility_AsDebtorList'),
            'array<string>'
            ) AS loan
        FROM non_empty_report
    ),
closed_loan_data_tmp AS (
        SELECT
            trace_id,
            credit_user_id,
            platform_user_id,
            flow_no,
            ktp_no,
            report_no,
            status,
            is_error,
            create_time,
            report_update_time,
            from_json(
            get_json_object(value_str, '$.result.BureauReport.CreditFacilityDetail.CREDIT_ClosedFacility_AsDebtor.CREDIT_ClosedFacility_AsDebtorList'),
            'array<string>'
            ) AS loan
        FROM non_empty_report
    ),
active_loan_data AS (
    SELECT 
        trace_id,
        credit_user_id,
        platform_user_id,
        flow_no,
        ktp_no,
        report_no,
        status,
        is_error,
        create_time,
        report_update_time,
        explode(loan) AS loan
    FROM active_loan_data_tmp
    WHERE loan IS NOT NULL
    ),
closed_loan_data AS (
    SELECT 
        trace_id,
        credit_user_id,
        platform_user_id,
        flow_no,
        ktp_no,
        report_no,
        status,
        is_error,
        create_time,
        report_update_time,
        explode(loan) AS loan
    FROM closed_loan_data_tmp
    WHERE loan IS NOT NULL
    ),
all_loan_data AS (
    SELECT * FROM active_loan_data
    UNION ALL
    SELECT * FROM closed_loan_data
),

collateral_data AS (
    SELECT 
        trace_id,
        credit_user_id,
        platform_user_id,
        flow_no,
        ktp_no,
        report_no,
        status,
        is_error,
        create_time,
        report_update_time,
        get_json_object(loan, '$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_InitialContractNumber') as initial_contract_no,
        explode(
            from_json(
                get_json_object(loan, '$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_CollateralOnFacility.CREDIT_CollateralOnFacilityList'),
                'array<string>'
            )
        ) as collateral
    FROM all_loan_data
    WHERE get_json_object(loan, '$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_CollateralOnFacility.CREDIT_CollateralOnFacilityList') IS NOT NULL
),
final_tab as (
SELECT 
    trace_id,
    credit_user_id,
    platform_user_id,
    flow_no,
    ktp_no,
    report_no,
    status,
    is_error,
    create_time,
    report_update_time,
    initial_contract_no,
    NULL as collateral_address,
    get_json_object(collateral_item, '$.CREDIT_CollateralReg') as register_code,
    get_json_object(collateral_item, '$.CREDIT_CollateralType') as collateral_type,
    NULL as collateral_rating,
    NULL as rating_agency_code,
    NULL as rating_agency,
    NULL as binding_type_code,
    get_json_object(collateral_item, '$.CREDIT_SecurityAssignmentType') as binding_type,
    NULL as binding_date,
    get_json_object(collateral_item, '$.CREDIT_CollateralOwnerName') as name_of_the_collateral_owner,
    NULL as proof_of_owner_ship,
    NULL as district_city_code,
    NULL as district_city,
    replace(get_json_object(collateral_item, '$.CREDIT_ValueAsNOJP'),'.','') as collateral_value_NJOP,
    NULL as reporting_evaluation_date,
    replace(get_json_object(collateral_item, '$.CREDIT_ValueByIndpnAppraiser'),'.','') as collateral_value_by_independent_appraiser,
    replace(get_json_object(collateral_item, '$.CREDIT_ValueBySubmitter'),'.','') as collateral_value_by_LJK,
    NULL as name_of_independent_appraiser,
    NULL as date_of_independent_appraisal_assessment,
    get_json_object(collateral_item, '$.CREDIT_CoverageProportion') as percentage_of_paripasu,
    NULL as insured,
    NULL as description,
    NULL as update_timestamp,
    NULL as reporter_rating_date
FROM (
    SELECT 
        trace_id,
        credit_user_id,
        platform_user_id,
        flow_no,
        ktp_no,
        report_no,
        status,
        is_error,
        create_time,
        report_update_time,
        initial_contract_no,
        get_json_object(collateral, '$.CREDIT_CollateralOnFacilityList_Item') as collateral_item
    FROM collateral_data
)
)

INSERT OVERWRITE TABLE risk.dwd_risk_slik_combine_collateral_info_di
PARTITION (data_source='CBI', grass_date)

SELECT
  trace_id,  -- STRING类型保持原样
  CAST(credit_user_id AS BIGINT) AS credit_user_id,
  CAST(platform_user_id AS BIGINT) AS platform_user_id,
  flow_no,  -- STRING
  CAST(ktp_no AS BIGINT) AS ktp_no,
  report_no,  -- STRING
  status,  -- STRING
  is_error,  -- STRING
  create_time,  -- STRING
  report_update_time,  -- STRING
  initial_contract_no,  -- STRING
  collateral_address,  -- STRING
  register_code,  -- STRING
  collateral_type,  -- STRING
  collateral_rating,  -- STRING
  rating_agency_code,  -- STRING
  rating_agency,  -- STRING
  CAST(binding_type_code AS STRING) AS binding_type_code,
  binding_type,  -- STRING
  binding_date,  -- STRING
  name_of_the_collateral_owner,  -- STRING
  proof_of_owner_ship,  -- STRING
  CAST(district_city_code AS STRING) AS district_city_code,
  district_city,  -- STRING
  CAST(collateral_value_NJOP AS DECIMAL(20,10)) AS collateral_value_NJOP,
  reporting_evaluation_date,  -- STRING
  CAST(collateral_value_by_independent_appraiser AS DECIMAL(20,10)) AS collateral_value_by_independent_appraiser,
  CAST(collateral_value_by_LJK AS DECIMAL(20,10)) AS collateral_value_by_LJK,
  name_of_independent_appraiser,  -- STRING
  date_of_independent_appraisal_assessment,  -- STRING
  CAST(percentage_of_paripasu AS DECIMAL(20,10)) AS percentage_of_paripasu,
  insured,  -- STRING
  description,  -- STRING
  update_timestamp,  -- STRING
  reporter_rating_date,  -- STRING
  create_time as grass_date 
FROM final_tab
;