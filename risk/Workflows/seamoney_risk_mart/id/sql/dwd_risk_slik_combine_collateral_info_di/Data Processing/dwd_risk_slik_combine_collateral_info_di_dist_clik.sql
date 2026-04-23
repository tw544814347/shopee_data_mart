-- CLIK数据源
WITH active_credit AS (
    SELECT 
    trace_id,
    get_json_object(header_data, '$.CreditUserId') as credit_user_id,
    get_json_object(header_data, '$.PlatformUserId') as platform_user_id,
    get_json_object(header_data, '$.FlowNo') as flow_no,
    get_json_object(req_data, '$.IdentityNumber') as ktp_no,
    get_json_object(resp_raw_data, '$.responseData.messageId.cbsmessageId') as report_no,
    get_json_object(resp_raw_data, '$.cgResponseInfo.info.status') as status,
    get_json_object(resp_raw_data, '$.cgResponseInfo.info.error') as is_error,
    get_json_object(resp_raw_data, '$.responseData.enquiredData.subjectRefDate') as report_update_time,
    substr(create_time,1,10) as create_time,
    explode(
        from_json(
            get_json_object(resp_raw_data, '$.responseData.creditReport.contractsHistory.credit.grantedCredit'),
            'array<string>'
        )
    ) as loan
    FROM risk.ods__credit_risk_datafetch_id_db__identity_data_tab__df
    WHERE grass_date = '${ds}' and data_source_name = 'ClikData' AND datediff(date(grass_date), date(substr(create_time, 1, 10))) <= 90
),
final_tab as 
(
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
    get_json_object(loan, '$.grantedCredit.originalAgreementNumber') as initial_contract_no,
    get_json_object(collateral, '$.collateralAddress.address.address') as collateral_address,
    get_json_object(collateral, '$.grantedCollateral.collateralNumber') as register_code,
    get_json_object(collateral, '$.grantedCollateral.collateralTypeDesc') as collateral_type,
    get_json_object(collateral, '$.grantedCollateral.collateralRating') as collateral_rating,
    get_json_object(collateral, '$.grantedCollateral.ratingInstitutionCode') as rating_agency_code,
    get_json_object(collateral, '$.grantedCollateral.ratingInstitutionDesc') as rating_agency,
    get_json_object(collateral, '$.grantedCollateral.bindTypeCode') as binding_type_code,
    get_json_object(collateral, '$.grantedCollateral.bindTypeDesc') as binding_type,
    get_json_object(collateral, '$.grantedCollateral.bindDate') as binding_date,
    get_json_object(collateral, '$.grantedCollateral.collateralOwnerName') as name_of_the_collateral_owner,
    get_json_object(collateral, '$.grantedCollateral.proofOfOwnership') as proof_of_owner_ship,
    get_json_object(collateral, '$.collateralAddress.address.city') as district_city_code,
    get_json_object(collateral, '$.collateralAddress.addressDesc.cityDesc') as district_city,
    get_json_object(collateral, '$.grantedCollateral.collateralValueNJOP') as collateral_value_NJOP,
    get_json_object(collateral, '$.grantedCollateral.collateralAssessmentDateReporter') as reporting_evaluation_date,
    get_json_object(collateral, '$.grantedCollateral.collateralValueIndependentAssessors') as collateral_value_by_independent_appraiser,
    get_json_object(collateral, '$.grantedCollateral.collateralValueReporter') as collateral_value_by_LJK,
    get_json_object(collateral, '$.grantedCollateral.independentAssessorsName') as name_of_independent_appraiser,
    NULL as date_of_independent_appraisal_assessment,
    get_json_object(collateral, '$.grantedCollateral.commonCollateralPercentage') as percentage_of_paripasu,
    get_json_object(collateral, '$.grantedCollateral.insured') as insured,
    get_json_object(collateral, '$.attributeData.information') as description,
    NULL as update_timestamp,
    get_json_object(collateral, '$.grantedCollateral.collateralAssessmentDateReporter') as reporter_rating_date
FROM active_credit
LATERAL VIEW explode(
    from_json(
        get_json_object(loan, '$.collaterals.grantedCollaterals'),
        'array<string>'
    )
) t AS collateral
WHERE get_json_object(loan, '$.collaterals.grantedCollaterals') IS NOT NULL
)

INSERT OVERWRITE TABLE risk.dwd_risk_slik_combine_collateral_info_di
PARTITION (data_source='CLIK', grass_date)

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