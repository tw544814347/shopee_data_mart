-- 获取原始信贷数据
WITH loan_records AS (
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
    ) as loan_record
    FROM risk.ods__credit_risk_datafetch_id_db__identity_data_tab__df
    WHERE grass_date = '${ds}' and data_source_name = 'ClikData' AND datediff(date(grass_date), date(substr(create_time, 1, 10))) <= 90
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
  get_json_object(loan_record, '$.commonData.providerCode') as reporter_ljk_id,
  get_json_object(loan_record, '$.commonData.providerCodeDesc') as reporter,
  get_json_object(loan_record, '$.commonData.contractStatusDesc') as condition,
  get_json_object(loan_record, '$.commonData.contractStatusCode') as condition_id,
  get_json_object(loan_record, '$.commonData.pastDueStausDesc') as quality,
  get_json_object(loan_record, '$.commonData.pastDueStausCode') as quality_id,
  get_json_object(loan_record, '$.commonData.contractTypeCodeDesc') as creditor_category,
  get_json_object(loan_record, '$.commonData.contractTypeCode') as creditor_category_id,
  get_json_object(loan_record, '$.grantedCredit.codeAgreementCreditDesc') as credit_contract,
  get_json_object(loan_record, '$.grantedCredit.codeAgreementCredit') as credit_contract_id,
  get_json_object(loan_record, '$.grantedCredit.creditLimit') as loan_amt,
  get_json_object(loan_record, '$.grantedCredit.initialCreditLimit') as initial_loan_amt,
  get_json_object(loan_record, '$.grantedCredit.debitBalance') as os_amt,
  '' as branch,
  '' as branch_id,
  get_json_object(loan_record, '$.grantedCredit.penalty') as penalty,
  get_json_object(loan_record, '$.grantedCredit.frequencyOfRestructuring') as restructure_frequency,
  get_json_object(loan_record, '$.grantedCredit.frequencyOfCredit') as credit_freq,
  get_json_object(loan_record, '$.maximum.maxOverduePaymentsNumber') as overdue_freq,
  get_json_object(loan_record, '$.commonData.contractTypeCodeDesc') as credit_category,
  get_json_object(loan_record, '$.commonData.contractTypeCode') as credit_category_id,
  get_json_object(loan_record, '$.grantedCredit.usageTypeCodeDesc') as usage_type,
  get_json_object(loan_record, '$.grantedCredit.usageTypeCode') as usage_type_id,
  get_json_object(loan_record, '$.grantedCredit.typeOfInterestRateDesc') as interest_type,
  get_json_object(loan_record, '$.grantedCredit.typeOfInterestRate') as interest_type_id,
  get_json_object(loan_record, '$.grantedCredit.daysPastDue') as total_overdue_days,
  get_json_object(loan_record, '$.grantedCredit.debtorCategoryCodeDesc') as debit_category,
  get_json_object(loan_record, '$.grantedCredit.debtorCategoryCode') as debit_category_id,
  get_json_object(loan_record, '$.commonData.financigProgram') as government_credit_program_id,
  get_json_object(loan_record, '$.commonData.financigProgramDesc') as government_credit_program,
  get_json_object(loan_record, '$.commonData.information') as description,
  get_json_object(loan_record, '$.grantedCredit.codeOfRestructuring') as restructure_method_id,
  get_json_object(loan_record, '$.grantedCredit.badCreditCauseDesc') as bad_reason,
  get_json_object(loan_record, '$.grantedCredit.badCreditCauseCode') as bad_reason_id,
  get_json_object(loan_record, '$.grantedCredit.economicSectorCodeDesc') as economy_sector,
  get_json_object(loan_record, '$.grantedCredit.economicSectorCode') as economy_sector_id,
  get_json_object(loan_record, '$.grantedCredit.codeCharacteristicCreditDesc') as credit_nature,
  get_json_object(loan_record, '$.grantedCredit.codeCharacteristicCredit') as credit_nature_id,
  get_json_object(loan_record, '$.grantedCredit.originalAgreementNumber') as initial_contract_no,
  get_json_object(loan_record, '$.grantedCredit.finalAgreementNumber') as final_contract_no,
  get_json_object(loan_record, '$.grantedCredit.interestRate') as interest,
  get_json_object(loan_record, '$.grantedCredit.startDateOfCredit') as credit_start_date,
  get_json_object(loan_record, '$.grantedCredit.originalAgreementDate') as initial_contract_date,
  get_json_object(loan_record, '$.grantedCredit.finalAgreementDate') as final_contract_date,
  '' as report_create_date,
  get_json_object(loan_record, '$.commonData.dueDate') as due_date,
  get_json_object(loan_record, '$.commonData.contractStatusDate') as condition_date,
  get_json_object(loan_record, '$.grantedCredit.badCreditDate') as bad_date,
  get_json_object(loan_record, '$.grantedCredit.finalRestructuringDate') as final_restructure_date,
  get_json_object(loan_record, '$.grantedCredit.interestOverdueAmount') as overdue_interest,
  get_json_object(loan_record, '$.grantedCredit.principalOverdueAmount') as overdue_principal,
  get_json_object(loan_record, '$.collaterals.grantedCollaterals') as collateral_list,
-- 月度数据字段（1-24月）需要从creditProfile列表中获取
  concat(
      get_json_object(get_json_object(loan_record, '$.creditProfile[23]'), '$.referenceYear'), 
      lpad(get_json_object(get_json_object(loan_record, '$.creditProfile[23]'), '$.referenceMonth'), 2, '0')
  ) as year_month_1,
  get_json_object(get_json_object(loan_record, '$.creditProfile[23]'), '$.qualityCode') as year_month_1_quality,
  get_json_object(get_json_object(loan_record, '$.creditProfile[23]'), '$.daysPastDue') as year_month_1_overdue_days,

  concat(
      get_json_object(get_json_object(loan_record, '$.creditProfile[22]'), '$.referenceYear'), 
      lpad(get_json_object(get_json_object(loan_record, '$.creditProfile[22]'), '$.referenceMonth'), 2, '0')
  ) as year_month_2,
  get_json_object(get_json_object(loan_record, '$.creditProfile[22]'), '$.qualityCode') as year_month_2_quality,
  get_json_object(get_json_object(loan_record, '$.creditProfile[22]'), '$.daysPastDue') as year_month_2_overdue_days,

  concat(
      get_json_object(get_json_object(loan_record, '$.creditProfile[21]'), '$.referenceYear'), 
      lpad(get_json_object(get_json_object(loan_record, '$.creditProfile[21]'), '$.referenceMonth'), 2, '0')
  ) as year_month_3,
  get_json_object(get_json_object(loan_record, '$.creditProfile[21]'), '$.qualityCode') as year_month_3_quality,
  get_json_object(get_json_object(loan_record, '$.creditProfile[21]'), '$.daysPastDue') as year_month_3_overdue_days,

  concat(
      get_json_object(get_json_object(loan_record, '$.creditProfile[20]'), '$.referenceYear'), 
      lpad(get_json_object(get_json_object(loan_record, '$.creditProfile[20]'), '$.referenceMonth'), 2, '0')
  ) as year_month_4,
  get_json_object(get_json_object(loan_record, '$.creditProfile[20]'), '$.qualityCode') as year_month_4_quality,
  get_json_object(get_json_object(loan_record, '$.creditProfile[20]'), '$.daysPastDue') as year_month_4_overdue_days,

  concat(
      get_json_object(get_json_object(loan_record, '$.creditProfile[19]'), '$.referenceYear'), 
      lpad(get_json_object(get_json_object(loan_record, '$.creditProfile[19]'), '$.referenceMonth'), 2, '0')
  ) as year_month_5,
  get_json_object(get_json_object(loan_record, '$.creditProfile[19]'), '$.qualityCode') as year_month_5_quality,
  get_json_object(get_json_object(loan_record, '$.creditProfile[19]'), '$.daysPastDue') as year_month_5_overdue_days,

  concat(
      get_json_object(get_json_object(loan_record, '$.creditProfile[18]'), '$.referenceYear'), 
      lpad(get_json_object(get_json_object(loan_record, '$.creditProfile[18]'), '$.referenceMonth'), 2, '0')
  ) as year_month_6,
  get_json_object(get_json_object(loan_record, '$.creditProfile[18]'), '$.qualityCode') as year_month_6_quality,
  get_json_object(get_json_object(loan_record, '$.creditProfile[18]'), '$.daysPastDue') as year_month_6_overdue_days,

  concat(
      get_json_object(get_json_object(loan_record, '$.creditProfile[17]'), '$.referenceYear'), 
      lpad(get_json_object(get_json_object(loan_record, '$.creditProfile[17]'), '$.referenceMonth'), 2, '0')
  ) as year_month_7,
  get_json_object(get_json_object(loan_record, '$.creditProfile[17]'), '$.qualityCode') as year_month_7_quality,
  get_json_object(get_json_object(loan_record, '$.creditProfile[17]'), '$.daysPastDue') as year_month_7_overdue_days,

  concat(
      get_json_object(get_json_object(loan_record, '$.creditProfile[16]'), '$.referenceYear'), 
      lpad(get_json_object(get_json_object(loan_record, '$.creditProfile[16]'), '$.referenceMonth'), 2, '0')
  ) as year_month_8,
  get_json_object(get_json_object(loan_record, '$.creditProfile[16]'), '$.qualityCode') as year_month_8_quality,
  get_json_object(get_json_object(loan_record, '$.creditProfile[16]'), '$.daysPastDue') as year_month_8_overdue_days,

  concat(
      get_json_object(get_json_object(loan_record, '$.creditProfile[15]'), '$.referenceYear'), 
      lpad(get_json_object(get_json_object(loan_record, '$.creditProfile[15]'), '$.referenceMonth'), 2, '0')
  ) as year_month_9,
  get_json_object(get_json_object(loan_record, '$.creditProfile[15]'), '$.qualityCode') as year_month_9_quality,
  get_json_object(get_json_object(loan_record, '$.creditProfile[15]'), '$.daysPastDue') as year_month_9_overdue_days,

  concat(
      get_json_object(get_json_object(loan_record, '$.creditProfile[14]'), '$.referenceYear'), 
      lpad(get_json_object(get_json_object(loan_record, '$.creditProfile[14]'), '$.referenceMonth'), 2, '0')
  ) as year_month_10,
  get_json_object(get_json_object(loan_record, '$.creditProfile[14]'), '$.qualityCode') as year_month_10_quality,
  get_json_object(get_json_object(loan_record, '$.creditProfile[14]'), '$.daysPastDue') as year_month_10_overdue_days,

  concat(
      get_json_object(get_json_object(loan_record, '$.creditProfile[13]'), '$.referenceYear'), 
      lpad(get_json_object(get_json_object(loan_record, '$.creditProfile[13]'), '$.referenceMonth'), 2, '0')
  ) as year_month_11,
  get_json_object(get_json_object(loan_record, '$.creditProfile[13]'), '$.qualityCode') as year_month_11_quality,
  get_json_object(get_json_object(loan_record, '$.creditProfile[13]'), '$.daysPastDue') as year_month_11_overdue_days,

  concat(
      get_json_object(get_json_object(loan_record, '$.creditProfile[12]'), '$.referenceYear'), 
      lpad(get_json_object(get_json_object(loan_record, '$.creditProfile[12]'), '$.referenceMonth'), 2, '0')
  ) as year_month_12,
  get_json_object(get_json_object(loan_record, '$.creditProfile[12]'), '$.qualityCode') as year_month_12_quality,
  get_json_object(get_json_object(loan_record, '$.creditProfile[12]'), '$.daysPastDue') as year_month_12_overdue_days,

  concat(
      get_json_object(get_json_object(loan_record, '$.creditProfile[11]'), '$.referenceYear'), 
      lpad(get_json_object(get_json_object(loan_record, '$.creditProfile[11]'), '$.referenceMonth'), 2, '0')
  ) as year_month_13,
  get_json_object(get_json_object(loan_record, '$.creditProfile[11]'), '$.qualityCode') as year_month_13_quality,
  get_json_object(get_json_object(loan_record, '$.creditProfile[11]'), '$.daysPastDue') as year_month_13_overdue_days, 

  concat(
      get_json_object(get_json_object(loan_record, '$.creditProfile[10]'), '$.referenceYear'), 
      lpad(get_json_object(get_json_object(loan_record, '$.creditProfile[10]'), '$.referenceMonth'), 2, '0')
  ) as year_month_14,
  get_json_object(get_json_object(loan_record, '$.creditProfile[10]'), '$.qualityCode') as year_month_14_quality,
  get_json_object(get_json_object(loan_record, '$.creditProfile[10]'), '$.daysPastDue') as year_month_14_overdue_days,

  concat(
      get_json_object(get_json_object(loan_record, '$.creditProfile[9]'), '$.referenceYear'), 
      lpad(get_json_object(get_json_object(loan_record, '$.creditProfile[9]'), '$.referenceMonth'), 2, '0')
  ) as year_month_15,
  get_json_object(get_json_object(loan_record, '$.creditProfile[9]'), '$.qualityCode') as year_month_15_quality,
  get_json_object(get_json_object(loan_record, '$.creditProfile[9]'), '$.daysPastDue') as year_month_15_overdue_days,

  concat(
      get_json_object(get_json_object(loan_record, '$.creditProfile[8]'), '$.referenceYear'), 
      lpad(get_json_object(get_json_object(loan_record, '$.creditProfile[8]'), '$.referenceMonth'), 2, '0')
  ) as year_month_16,
  get_json_object(get_json_object(loan_record, '$.creditProfile[8]'), '$.qualityCode') as year_month_16_quality,
  get_json_object(get_json_object(loan_record, '$.creditProfile[8]'), '$.daysPastDue') as year_month_16_overdue_days,

  concat(
      get_json_object(get_json_object(loan_record, '$.creditProfile[7]'), '$.referenceYear'), 
      lpad(get_json_object(get_json_object(loan_record, '$.creditProfile[7]'), '$.referenceMonth'), 2, '极0')
  ) as year_month_17,
  get_json_object(get_json_object(loan_record, '$.creditProfile[7]'), '$.qualityCode') as year_month_17_quality,
  get_json_object(get_json_object(loan_record, '$.creditProfile[7]'), '$.daysPastDue') as year_month_17_overdue_days,

  concat(
      get_json_object(get_json_object(loan_record, '$.creditProfile[6]'), '$.referenceYear'), 
      lpad(get_json_object(get_json_object(loan_record, '$.creditProfile[6]'), '$.referenceMonth'), 2, '0')
  ) as year_month_18,
  get_json_object(get_json_object(loan_record, '$.creditProfile[6]'), '$.qualityCode') as year_month_18_quality,
  get_json_object(get_json_object(loan_record, '$.creditProfile[6]'), '$.daysPastDue') as year_month_18_overdue_days,

  concat(
      get_json_object(get_json_object(loan_record, '$.creditProfile[5]'), '$.referenceYear'), 
      lpad(get_json_object(get_json_object(loan_record, '$.creditProfile[5]'), '$.referenceMonth'), 2, '0')
  ) as year_month_19,
  get_json_object(get_json_object(loan_record, '$.creditProfile[5]'), '$.qualityCode') as year_month_19_quality,
  get_json_object(get_json_object(loan_record, '$.creditProfile[5]'), '$.daysPastDue') as year_month_19_overdue_days,

  concat(
      get_json_object(get_json_object(loan_record, '$.creditProfile[4]'), '$.referenceYear'), 
      lpad(get_json_object(get_json_object(loan_record, '$.creditProfile[4]'), '$.referenceMonth'), 2, '0')
  ) as year_month_20,
  get_json_object(get_json_object(loan_record, '$.creditProfile[4]'), '$.qualityCode') as year_month_20_quality,
  get_json_object(get_json_object(loan_record, '$.creditProfile[4]'), '$.daysPastDue') as year_month_20_overdue_days,

  concat(
      get_json_object(get_json_object(loan_record, '$.creditProfile[3]'), '$.referenceYear'), 
      lpad(get_json_object(get_json_object(loan_record, '$.creditProfile[3]'), '$.referenceMonth'), 2, '0')
  ) as year_month_21,
  get_json_object(get_json_object(loan_record, '$.creditProfile[3]'), '$.qualityCode') as year_month_21_quality,
  get_json_object(get_json_object(loan_record, '$.creditProfile[3]'), '$.daysPastDue') as year_month_21_overdue_days,

  concat(
      get_json_object(get_json_object(loan_record, '$.creditProfile[2]'), '$.referenceYear'), 
      lpad(get_json_object(get_json_object(loan_record, '$.creditProfile[2]'), '$.referenceMonth'), 2, '0')
  ) as year_month_22,
  get_json_object(get_json_object(loan_record, '$.creditProfile[2]'), '$.qualityCode') as year_month_22_quality,
  get_json_object(get_json_object(loan_record, '$.creditProfile[2]'), '$.daysPastDue') as year_month_22_overdue_days,

  concat(
      get_json_object(get_json_object(loan_record, '$.creditProfile[1]'), '$.referenceYear'),  -- 修正了索引
      lpad(get_json_object(get_json_object(loan_record, '$.creditProfile[1]'), '$.referenceMonth'), 2, '0')
  ) as year_month_23,
  get_json_object(get_json_object(loan_record, '$.creditProfile[1]'), '$.qualityCode') as year_month_23_quality,
  get_json_object(get_json_object(loan_record, '$.creditProfile[1]'), '$.daysPastDue') as year_month_23_overdue_days,

  concat(
      get_json_object(get_json_object(loan_record, '$.creditProfile[0]'), '$.referenceYear'), 
      lpad(get_json_object(get_json_object(loan_record, '$.creditProfile[0]'), '$.referenceMonth'), 2, '0')
  ) as year_month_24,
  get_json_object(get_json_object(loan_record, '$.creditProfile[0]'), '$.qualityCode') as year_month_24_quality,
  get_json_object(get_json_object(loan_record, '$.creditProfile[0]'), '$.daysPastDue') as year_month_24_overdue_days,
-- ... 继续到24个月
  NULL as project_local_id,
  NULL as project_local,
  get_json_object(loan_record, '$.grantedCredit.valueInOriginalCurrency') as value_in_original_currency,
  get_json_object(loan_record, '$.commonData.currencyCode') as currency_code,
  get_json_object(loan_record, '$.grantedCredit.projectValue') as project_value,
  get_json_object(loan_record, '$.commonData.providerContractNo') as account_no,
  NULL as guarantor,
  get_json_object(loan_record, '$.grantedCredit.currentMonthRealization') as current_month_disbursement,
  NULL as restructure_method,
  get_json_object(loan_record, '$.commonData.referenceDate') as report_update_date,
  get_json_object(loan_record, '$.commonData.startDate') as start_date
FROM loan_records
)

INSERT OVERWRITE TABLE risk.dwd_risk_slik_combine_loan_info_di
PARTITION (data_source='CLIK', grass_date)

SELECT
  trace_id,
  credit_user_id,
  platform_user_id,
  flow_no,
  CAST(ktp_no AS BIGINT) AS ktp_no,
  report_no,
  status,
  is_error,
  create_time,
  report_update_time,
  CAST(reporter_ljk_id AS STRING) AS reporter_ljk_id,
  reporter,
  condition,
  CAST(condition_id AS STRING) AS condition_id,
  quality,
  CAST(quality_id AS STRING) AS quality_id,
  creditor_category,
  creditor_category_id,
  credit_contract,
  credit_contract_id,
  CAST(loan_amt AS DECIMAL(20,10)) AS loan_amt,
  CAST(initial_loan_amt AS DECIMAL(20,10)) AS initial_loan_amt,
  CAST(os_amt AS DECIMAL(20,10)) AS os_amt,
  branch,
  CAST(branch_id AS STRING) AS branch_id,
  CAST(penalty AS DECIMAL(20,10)) AS penalty,
  CAST(restructure_frequency AS BIGINT) AS restructure_frequency,
  CAST(credit_freq AS BIGINT) AS credit_freq,
  CAST(overdue_freq AS BIGINT) AS overdue_freq,
  credit_category,
  credit_category_id,
  usage_type,
  CAST(usage_type_id AS STRING) AS usage_type_id,
  interest_type,
  CAST(interest_type_id AS STRING) AS interest_type_id,
  CAST(interest AS DECIMAL(20,10)) AS interest,
  CAST(total_overdue_days AS BIGINT) AS total_overdue_days,
  debit_category,
  debit_category_id,
  government_credit_program_id,
  government_credit_program,
  description,
  CAST(restructure_method_id AS STRING) AS restructure_method_id,
  bad_reason,
  CAST(bad_reason_id AS STRING) AS bad_reason_id,
  economy_sector,
  economy_sector_id,
  credit_nature,
  CAST(credit_nature_id AS STRING) AS credit_nature_id,
  initial_contract_no,
  final_contract_no,
  credit_start_date,
  initial_contract_date,
  final_contract_date,
  report_create_date,
  due_date,
  condition_date,
  bad_date,
  final_restructure_date,
  CAST(overdue_interest AS DECIMAL(20,10)) AS overdue_interest,
  CAST(overdue_principal AS DECIMAL(20,10)) AS overdue_principal,
  collateral_list,
  year_month_1,
  year_month_1_quality,
  CAST(year_month_1_overdue_days AS BIGINT) AS year_month_1_overdue_days,
  year_month_2,
  year_month_2_quality,
  CAST(year_month_2_overdue_days AS BIGINT) AS year_month_2_overdue_days,
  year_month_3,
  year_month_3_quality,
  CAST(year_month_3_overdue_days AS BIGINT) AS year_month_3_overdue_days,
  year_month_4,
  year_month_4_quality,
  CAST(year_month_4_overdue_days AS BIGINT) AS year_month_4_overdue_days,
  year_month_5,
  year_month_5_quality,
  CAST(year_month_5_overdue_days AS BIGINT) AS year_month_5_overdue_days,
  year_month_6,
  year_month_6_quality,
  CAST(year_month_6_overdue_days AS BIGINT) AS year_month_6_overdue_days,
  year_month_7,
  year_month_7_quality,
  CAST(year_month_7_overdue_days AS BIGINT) AS year_month_7_overdue_days,
  year_month_8,
  year_month_8_quality,
  CAST(year_month_8_overdue_days AS BIGINT) AS year_month_8_overdue_days,
  year_month_9,
  year_month_9_quality,
  CAST(year_month_9_overdue_days AS BIGINT) AS year_month_9_overdue_days,
  year_month_10,
  year_month_10_quality,
  CAST(year_month_10_overdue_days AS BIGINT) AS year_month_10_overdue_days,
  year_month_11,
  year_month_11_quality,
  CAST(year_month_11_overdue_days AS BIGINT) AS year_month_11_overdue_days,
  year_month_12,
  year_month_12_quality,
  CAST(year_month_12_overdue_days AS BIGINT) AS year_month_12_overdue_days,
  year_month_13,
  year_month_13_quality,
  CAST(year_month_13_overdue_days AS BIGINT) AS year_month_13_overdue_days,
  year_month_14,
  year_month_14_quality,
  CAST(year_month_14_overdue_days AS BIGINT) AS year_month_14_overdue_days,
  year_month_15,
  year_month_15_quality,
  CAST(year_month_15_overdue_days AS BIGINT) AS year_month_15_overdue_days,
  year_month_16,
  year_month_16_quality,
  CAST(year_month_16_overdue_days AS BIGINT) AS year_month_16_overdue_days,
  year_month_17,
  year_month_17_quality,
  CAST(year_month_17_overdue_days AS BIGINT) AS year_month_17_overdue_days,
  year_month_18,
  year_month_18_quality,
  CAST(year_month_18_overdue_days AS BIGINT) AS year_month_18_overdue_days,
  year_month_19,
  year_month_19_quality,
  CAST(year_month_19_overdue_days AS BIGINT) AS year_month_19_overdue_days,
  year_month_20,
  year_month_20_quality,
  CAST(year_month_20_overdue_days AS BIGINT) AS year_month_20_overdue_days,
  year_month_21,
  year_month_21_quality,
  CAST(year_month_21_overdue_days AS BIGINT) AS year_month_21_overdue_days,
  year_month_22,
  year_month_22_quality,
  CAST(year_month_22_overdue_days AS BIGINT) AS year_month_22_overdue_days,
  year_month_23,
  year_month_23_quality,
  CAST(year_month_23_overdue_days AS BIGINT) AS year_month_23_overdue_days,
  year_month_24,
  year_month_24_quality,
  CAST(year_month_24_overdue_days AS BIGINT) AS year_month_24_overdue_days,
  CAST(project_local_id AS STRING) AS project_local_id,
  project_local,
  CAST(value_in_original_currency AS DECIMAL(20,10)) AS value_in_original_currency,
  currency_code,
  CAST(project_value AS DECIMAL(20,10)) AS project_value,
  account_no,
  guarantor,
  CAST(current_month_disbursement AS DECIMAL(20,10)) AS current_month_disbursement,
  restructure_method,
  report_update_date,
  start_date,
  create_time as grass_date
FROM final_tab
;