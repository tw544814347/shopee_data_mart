-- 从CLIK数据中提取个人基本信息
WITH base_info AS (
  SELECT
    -- 主键信息
    trace_id as trace_id,
    get_json_object(header_data, '$.CreditUserId') AS credit_user_id,
    get_json_object(header_data, '$.PlatformUserId') AS platform_user_id,
    get_json_object(header_data, '$.FlowNo') AS flow_no,
    get_json_object(req_data, '$.IdentityNumber') AS ktp_no,
    get_json_object(resp_raw_data, '$.responseData.messageId.cbsmessageId') AS report_no,
    get_json_object(resp_raw_data, '$.cgResponseInfo.info.status') AS status,
    get_json_object(resp_raw_data, '$.cgResponseInfo.info.error') AS is_error,
    get_json_object(resp_raw_data, '$.responseData.enquiredData.subjectRefDate') AS report_update_time, 
    substr(create_time,1,10) as create_time,
    
    -- 基本信息
    get_json_object(resp_raw_data, '$.responseData.creditReport.matchedSubject[0].individual.individualName.fullName') AS name,
    get_json_object(resp_raw_data, '$.responseData.creditReport.matchedSubject[0].individual.birthData.date') AS birth_date,
    get_json_object(resp_raw_data, '$.responseData.creditReport.matchedSubject[0].individual.birthData.place') AS birth_place,
    
    -- 身份信息
    get_json_object(resp_raw_data, '$.responseData.creditReport.matchedSubject[0].individual.identificationCode[0].identificationCode.identityType') AS identity_id,
    get_json_object(resp_raw_data, '$.responseData.creditReport.matchedSubject[0].individual.identificationCode[0].identificationCode.identityNumber') AS identity_number,
    get_json_object(resp_raw_data, '$.responseData.creditReport.matchedSubject[0].individual.id.npwp') AS npwp,
    
    -- 性别信息
    get_json_object(resp_raw_data, '$.responseData.creditReport.matchedSubject[0].individual.gender') AS gender_id,
    get_json_object(resp_raw_data, '$.responseData.creditReport.matchedSubject[0].individual.genderDesc') AS gender,
    
    -- 教育信息
    get_json_object(resp_raw_data, '$.responseData.creditReport.matchedSubject[0].individual.educationalStatusCode') AS degree_id,
    get_json_object(resp_raw_data, '$.responseData.creditReport.matchedSubject[0].individual.educationalStatusCodeDesc') AS degree,
    
    -- 工作信息
    get_json_object(resp_raw_data, '$.responseData.creditReport.matchedSubject[0].individual.employmentDataHistory[0].employmentData.occupationCode') AS job_id,
    get_json_object(resp_raw_data, '$.responseData.creditReport.matchedSubject[0].individual.employmentDataHistory[0].employmentDataDesc.occupationDesc') AS job,
    get_json_object(resp_raw_data, '$.responseData.creditReport.matchedSubject[0].individual.employmentDataHistory[0].employmentData.workplace') AS work_place,
    get_json_object(resp_raw_data, '$.responseData.creditReport.matchedSubject[0].individual.employmentDataHistory[0].employmentData.employerSector') AS business_field_id,
    get_json_object(resp_raw_data, '$.responseData.creditReport.matchedSubject[0].individual.employmentDataHistory[0].employmentDataDesc.employerSectorDesc') AS business_field,
    
    -- 地址信息
    get_json_object(resp_raw_data, '$.responseData.creditReport.matchedSubject[0].individual.addressHistory[0].address.address') AS address,
    get_json_object(resp_raw_data, '$.responseData.creditReport.matchedSubject[0].individual.addressHistory[0].address.country') AS country_id,
    get_json_object(resp_raw_data, '$.responseData.creditReport.matchedSubject[0].individual.addressHistory[0].addressDesc.countryDesc') AS country,
    get_json_object(resp_raw_data, '$.responseData.creditReport.matchedSubject[0].individual.addressHistory[0].address.city') AS city_id,
    get_json_object(resp_raw_data, '$.responseData.creditReport.matchedSubject[0].individual.addressHistory[0].addressDesc.cityDesc') AS city,
    get_json_object(resp_raw_data, '$.responseData.creditReport.matchedSubject[0].individual.addressHistory[0].address.district') AS district,
    get_json_object(resp_raw_data, '$.responseData.creditReport.matchedSubject[0].individual.addressHistory[0].address.subDistrict') AS village,
    get_json_object(resp_raw_data, '$.responseData.creditReport.matchedSubject[0].individual.addressHistory[0].address.postalCode') AS zipcode,
    
    -- 报告相关信息 
    get_json_object(resp_raw_data, '$.responseData.creditReport.matchedSubject[0].individual.lastUpdateDate') AS report_update_date,
    NULL AS reporter_ljk_id,  -- 标记为 NA 的字段设为 NULL
    NULL AS reporter,         -- 标记为 NA 的字段设为 NULL
    NULL AS report_create_date  -- 标记为 NA 的字段设为 NULL

  FROM risk.ods__credit_risk_datafetch_id_db__identity_data_tab__df
  WHERE grass_date = '${ds}' AND data_source_name = 'ClikData' AND datediff(date(grass_date), date(substr(create_time, 1, 10))) <= 90
  -- limit 100
),

-- 1. 从原始报告中提取各种债务数据
raw_data AS (
  SELECT 
    -- resp_raw_data,
    trace_id as trace_id,
    get_json_object(header_data, '$.CreditUserId') AS credit_user_id,
    get_json_object(header_data, '$.PlatformUserId') AS platform_user_id,
    get_json_object(header_data, '$.FlowNo') AS flow_no,
    get_json_object(req_data, '$.IdentityNumber') AS ktp_no,
    get_json_object(resp_raw_data, '$.responseData.messageId.cbsmessageId') AS report_no,
    get_json_object(resp_raw_data, '$.cgResponseInfo.info.status') AS status,
    get_json_object(resp_raw_data, '$.cgResponseInfo.info.error') AS is_error,
    get_json_object(resp_raw_data, '$.responseData.enquiredData.subjectRefDate') AS report_update_time, 
    substr(create_time,1,10) as create_time,
    get_json_object(resp_raw_data, '$.responseData.creditReport.contractsHistory.credit.grantedCredit') AS loan_list,
    get_json_object(resp_raw_data, '$.responseData.creditReport.contractsHistory.credit.amountsSummary') AS loan_sum,
    get_json_object(resp_raw_data, '$.responseData.creditReport.contractsHistory.bond.amountsSummary') AS bond_sum,
    get_json_object(resp_raw_data, '$.responseData.creditReport.contractsHistory.letterOfCredit.amountsSummary') AS lc_sum,
    get_json_object(resp_raw_data, '$.responseData.creditReport.contractsHistory.guarantee.amountsSummary') AS guarantee_sum,
    get_json_object(resp_raw_data, '$.responseData.creditReport.contractsHistory.otherFacilities.amountsSummary') AS other_sum
  FROM risk.ods__credit_risk_datafetch_id_db__identity_data_tab__df
  WHERE grass_date = '${ds}' and data_source_name = 'ClikData' AND datediff(date(grass_date), date(substr(create_time, 1, 10))) <= 90
),

-- 2. 拆分贷款列表为单独的行
loans AS (
  SELECT 
    trace_id, credit_user_id, platform_user_id, flow_no, ktp_no, 
    report_no, status, is_error, report_update_time,
    loan_sum, bond_sum, lc_sum, guarantee_sum, other_sum,
    create_time,
    explode(from_json(loan_list, 'ARRAY<STRING>')) AS loan
  FROM raw_data
),

-- 3. 从每笔贷款中提取债务余额和信用额度
loan_amounts AS (
  SELECT 
    trace_id, credit_user_id, platform_user_id, flow_no, ktp_no, 
    report_no, status, is_error, report_update_time,
    loan_sum, bond_sum, lc_sum, guarantee_sum, other_sum, create_time,
    CASE 
      WHEN get_json_object(loan, '$.grantedCredit.debitBalance') IN ('NaN', 'null', '') OR get_json_object(loan, '$.grantedCredit.debitBalance') IS NULL THEN NULL 
      ELSE CAST(get_json_object(loan, '$.grantedCredit.debitBalance') AS FLOAT) 
    END AS os,
    CASE 
      WHEN get_json_object(loan, '$.grantedCredit.creditLimit') IN ('NaN', 'null', '') OR get_json_object(loan, '$.grantedCredit.creditLimit') IS NULL THEN NULL 
      ELSE CAST(get_json_object(loan, '$.grantedCredit.creditLimit') AS FLOAT) 
    END AS credit_limit,
    loan
  FROM loans 
),

-- 4. 计算所有贷款的总余额和总信用额度
loan_totals AS (
  SELECT 
    trace_id, credit_user_id, platform_user_id, flow_no, ktp_no, 
    report_no, status, is_error, report_update_time,
    loan_sum, bond_sum, lc_sum, guarantee_sum, other_sum, create_time,
    COALESCE(SUM(os), 0) AS total_os_amt,
    COALESCE(SUM(credit_limit), 0) AS total_credit_limit
  FROM loan_amounts
  GROUP BY trace_id, credit_user_id, platform_user_id, flow_no, ktp_no, 
    report_no, status, is_error, report_update_time,
    loan_sum, bond_sum, lc_sum, guarantee_sum, other_sum, create_time
),

-- 5. 从每笔贷款中提取信用档案记录
credit_profiles AS (
  SELECT 
    trace_id, credit_user_id, platform_user_id, flow_no, ktp_no, 
    report_no, status, is_error, report_update_time, create_time,
    loan,
    explode(from_json(get_json_object(loan, '$.creditProfile'), 'ARRAY<STRING>')) AS profile
  FROM loans
),

-- 6. 从信用档案中提取质量代码和日期
quality_records AS (
  SELECT 
    trace_id, credit_user_id, platform_user_id, flow_no, ktp_no, 
    report_no, status, is_error, report_update_time, create_time,
    profile,
    CASE 
      WHEN get_json_object(profile, '$.qualityCode') IS NULL 
        OR get_json_object(profile, '$.qualityCode') IN ('NaN', 'null', '')
      THEN NULL 
      ELSE CAST(get_json_object(profile, '$.qualityCode') AS FLOAT) 
    END AS quality,
    CASE
      WHEN CAST(get_json_object(profile, '$.referenceMonth') AS INT) BETWEEN 1 AND 12
      THEN concat(
        get_json_object(profile, '$.referenceYear'), '-',
        LPAD(get_json_object(profile, '$.referenceMonth'), 2, '0'), '-15'
      )
      ELSE NULL
    END AS quality_date
  FROM credit_profiles
),

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- select *
-- from quality_records
-- limit 100;
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
quality_records_sub as (
select trace_id, credit_user_id, platform_user_id, flow_no, ktp_no, 
    report_no, status, is_error, report_update_time, create_time,
    profile,quality,quality_date, row_number() over(partition by trace_id order by quality desc, quality_date asc) as rk
from quality_records
), 

-- 7. 找出每个 profile 的最差信用质量记录
worst_quality_record AS (
  SELECT 
    trace_id, credit_user_id, platform_user_id, flow_no, ktp_no, 
    report_no, status, is_error, report_update_time, create_time,
    profile,
    if(quality is null or quality = 'null' or quality = 'Null', -1, quality)    AS worst_quality,
    if(quality_date is null or quality_date = 'null' or quality_date = 'Null', '', quality_date)    AS worst_quality_date_raw
  FROM quality_records_sub
  where rk = 1
),

-- 8. 格式化最差信用质量日期
formatted_worst_quality AS (
  SELECT
    trace_id, credit_user_id, platform_user_id, flow_no, ktp_no, 
    report_no, status, is_error, report_update_time, create_time,
    profile,
    worst_quality,
    CASE 
      WHEN worst_quality_date_raw = '' OR worst_quality_date_raw IS NULL THEN '' 
      ELSE date_format(to_date(worst_quality_date_raw, 'yyyy-MM-dd'), 'yyyyMM')
    END AS worst_quality_date
  FROM worst_quality_record
),

-- 9. 从每笔贷款中提取提供商信息
provider_info AS (
  SELECT 
    trace_id, credit_user_id, platform_user_id, flow_no, ktp_no, 
    report_no, status, is_error, report_update_time, create_time,
    get_json_object(loan, '$.commonData.providerCodeDesc') AS provider,
    get_json_object(loan, '$.commonData.providerTypeCode') AS providerTypeCode
  FROM loans
),

-- 10. 将提供商类型代码映射到类别
provider_categories AS (
  SELECT 
    trace_id, credit_user_id, platform_user_id, flow_no, ktp_no, 
    report_no, status, is_error, report_update_time, create_time,
    provider,
    CASE providerTypeCode
      WHEN '0101' THEN 'Bank Umum'
      WHEN '0102' THEN 'Bank Umum'
      WHEN '0103' THEN 'BPR/BPRS'
      WHEN '0104' THEN 'BPR/BPRS'
      WHEN '0201' THEN 'Lembaga Pembiayaan'
      WHEN '0202' THEN 'Lembaga Pembiayaan'
      WHEN '0203' THEN 'Lembaga Pembiayaan'
      WHEN '0204' THEN 'Lembaga Pembiayaan'
      WHEN '0205' THEN 'Lembaga Pembiayaan'
      WHEN '0206' THEN 'Lembaga Pembiayaan'
      WHEN '0401' THEN 'Lembaga Pembiayaan'
      WHEN '0402' THEN 'Lembaga Pembiayaan'
      WHEN '0501' THEN 'Lembaga Pembiayaan'
      WHEN '0502' THEN 'Lembaga Pembiayaan'
      WHEN '0601' THEN 'Lembaga Pembiayaan'
      WHEN '0602' THEN 'Lembaga Pembiayaan'
      WHEN '0701' THEN 'Lembaga Pembiayaan'
      WHEN '0702' THEN 'Lembaga Pembiayaan'
      WHEN '0801' THEN 'Lembaga Pembiayaan'
      WHEN '0802' THEN 'Lembaga Pembiayaan'
      WHEN '0301' THEN 'Lembaga Pembiayaan'
      WHEN '0302' THEN 'Lembaga Pembiayaan'
      WHEN '0909' THEN 'Lainnya'
      ELSE ''
    END AS category
  FROM provider_info
),

-- 11. 移除重复的提供商记录并统计各类提供商数量
provider_counts AS (
  SELECT 
    trace_id, credit_user_id, platform_user_id, flow_no, ktp_no, 
    report_no, status, is_error, report_update_time, create_time,
    COUNT(DISTINCT CASE WHEN category = 'Bank Umum' THEN provider END) AS bank_reporter_cnt,
    COUNT(DISTINCT CASE WHEN category = 'BPR/BPRS' THEN provider END) AS bpr_reporter_cnt,
    COUNT(DISTINCT CASE WHEN category = 'Lembaga Pembiayaan' THEN provider END) AS financial_reporter_cnt,
    COUNT(DISTINCT CASE WHEN category = 'Lainnya' THEN provider END) AS other_reporter_cnt
  FROM provider_categories
  GROUP BY trace_id, credit_user_id, platform_user_id, flow_no, ktp_no, 
    report_no, status, is_error, report_update_time, create_time
),

-- 12. 从各种债务汇总中提取债务余额和信用额度
debt_summary AS (
  SELECT
    trace_id, credit_user_id, platform_user_id, flow_no, ktp_no, 
    report_no, status, is_error, report_update_time, create_time,
    total_os_amt AS credit_os_amt,
    total_credit_limit AS credit_amt,
    
    -- 债务余额
    MAX(CASE 
      WHEN get_json_object(guarantee_sum, '$.debitBalance') IN ('NaN', 'null', '') OR get_json_object(guarantee_sum, '$.debitBalance') IS NULL 
      THEN 0
      ELSE CAST(get_json_object(guarantee_sum, '$.debitBalance') AS FLOAT)
    END) AS guarantee_os_amt,
    
    MAX(CASE 
      WHEN get_json_object(other_sum, '$.debitBalance') IN ('NaN', 'null', '') OR get_json_object(other_sum, '$.debitBalance') IS NULL 
      THEN 0
      ELSE CAST(get_json_object(other_sum, '$.debitBalance') AS FLOAT)
    END) AS other_os_amt,
    
    MAX(CASE 
      WHEN get_json_object(lc_sum, '$.debitBalance') IN ('NaN', 'null', '') OR get_json_object(lc_sum, '$.debitBalance') IS NULL 
      THEN 0
      ELSE CAST(get_json_object(lc_sum, '$.debitBalance') AS FLOAT)
    END) AS lc_os_amt,
    
    MAX(CASE 
      WHEN get_json_object(bond_sum, '$.debitBalance') IN ('NaN', 'null', '') OR get_json_object(bond_sum, '$.debitBalance') IS NULL 
      THEN 0
      ELSE CAST(get_json_object(bond_sum, '$.debitBalance') AS FLOAT)
    END) AS securities_os_amt,
    
    -- 信用额度
    MAX(CASE 
      WHEN get_json_object(guarantee_sum, '$.creditLimit') IN ('NaN', 'null', '') OR get_json_object(guarantee_sum, '$.creditLimit') IS NULL 
      THEN 0
      ELSE CAST(get_json_object(guarantee_sum, '$.creditLimit') AS FLOAT)
    END) AS guarantee_amt,
    
    null AS other_amt,
    
    MAX(CASE 
      WHEN get_json_object(lc_sum, '$.creditLimit') IN ('NaN', 'null', '') OR get_json_object(lc_sum, '$.creditLimit') IS NULL 
      THEN 0
      ELSE CAST(get_json_object(lc_sum, '$.creditLimit') AS FLOAT)
    END) AS lc_amt,
    
    null AS securities_amt
  FROM loan_totals
  GROUP BY trace_id, credit_user_id, platform_user_id, flow_no, ktp_no, report_no, status, is_error, report_update_time, create_time, total_os_amt, total_credit_limit
),

-- 13. 计算总余额和总额度
final_calculation AS (
  SELECT
    fwq.trace_id, fwq.credit_user_id, fwq.platform_user_id, fwq.flow_no, fwq.ktp_no, 
    fwq.report_no, fwq.status, fwq.is_error, fwq.report_update_time, fwq.create_time,
    fwq.worst_quality,
    fwq.worst_quality_date,
    pc.bank_reporter_cnt,
    pc.bpr_reporter_cnt,
    pc.financial_reporter_cnt,
    pc.other_reporter_cnt,
    ds.guarantee_os_amt,
    ds.credit_os_amt,
    ds.other_os_amt,
    ds.lc_os_amt,
    ds.securities_os_amt,
    ds.guarantee_amt,
    ds.credit_amt,
    ds.other_amt,
    ds.lc_amt,
    ds.securities_amt,
    COALESCE(ds.guarantee_amt, 0) + 
        COALESCE(ds.credit_amt, 0) + 
        COALESCE(CAST(ds.other_amt AS FLOAT), 0) + 
        COALESCE(ds.lc_amt, 0) + 
        COALESCE(CAST(ds.securities_amt AS FLOAT), 0) AS total_amt,
    COALESCE(ds.guarantee_os_amt, 0) +  
        COALESCE(ds.credit_os_amt, 0) +
        COALESCE(ds.other_os_amt, 0) +
        COALESCE(ds.lc_os_amt, 0) +
        COALESCE(ds.securities_os_amt, 0) AS total_os_amt
  FROM formatted_worst_quality fwq
  LEFT JOIN provider_counts pc 
    ON fwq.trace_id = pc.trace_id 
    -- AND fwq.credit_user_id = pc.credit_user_id
    -- AND fwq.platform_user_id = pc.platform_user_id
    -- AND fwq.flow_no = pc.flow_no
    -- AND fwq.ktp_no = pc.ktp_no
    -- AND fwq.report_no = pc.report_no
    -- AND fwq.status = pc.status
    -- AND fwq.is_error = pc.is_error
    -- AND fwq.report_update_time = pc.report_update_time
  LEFT JOIN debt_summary ds
    ON fwq.trace_id = ds.trace_id 
    -- AND fwq.credit_user_id = ds.credit_user_id
    -- AND fwq.platform_user_id = ds.platform_user_id
    -- AND fwq.flow_no = ds.flow_no
    -- AND fwq.ktp_no = ds.ktp_no
    -- AND fwq.report_no = ds.report_no
    -- AND fwq.status = ds.status
    -- AND fwq.is_error = ds.is_error
    -- AND fwq.report_update_time = ds.report_update_time
),

final_tab as 
(
select t1.*,
      t2.worst_quality,
      t2.worst_quality_date as worst_quality_time,
      t2.bank_reporter_cnt,
      t2.bpr_reporter_cnt,
      t2.financial_reporter_cnt,
      t2.other_reporter_cnt,
      t2.guarantee_os_amt,
      t2.credit_os_amt,
      t2.other_os_amt,
      t2.lc_os_amt,
      t2.securities_os_amt,
      t2.guarantee_amt,
      t2.credit_amt,
      t2.other_amt,
      t2.lc_amt,
      t2.securities_amt,
      t2.total_amt,
      t2.total_os_amt
from base_info t1
  left join final_calculation t2
  on t1.trace_id = t2.trace_id
)

INSERT OVERWRITE TABLE risk.dwd_risk_slik_combine_base_info_di
PARTITION (data_source='CLIK',grass_date)

SELECT
  trace_id,
  CAST(credit_user_id AS BIGINT) AS credit_user_id,
  CAST(platform_user_id AS BIGINT) AS platform_user_id,
  flow_no,
  CAST(ktp_no AS BIGINT) AS ktp_no,
  report_no,
  status,
  is_error,
  report_update_time,
  create_time,
  name,
  CAST(birth_date AS STRING) AS birth_date,
  birth_place,
  CAST(identity_id AS BIGINT) AS identity_id,
  CAST(identity_number AS BIGINT) AS identity_number,
  CAST(npwp AS BIGINT) AS npwp,
  gender_id,
  gender,
  CAST(degree_id AS STRING) AS degree_id,
  degree,
  CAST(job_id AS STRING) AS job_id,
  job,
  work_place,
  business_field_id,
  business_field,
  address,
  country_id,
  country,
  CAST(city_id AS BIGINT) AS city_id,
  city,
  district,
  village,
  CAST(zipcode AS STRING) AS zipcode,
  report_update_date,
  CAST(reporter_ljk_id AS STRING) AS reporter_ljk_id,
  reporter,
  report_create_date,
  worst_quality,
  worst_quality_time,
  CAST(bank_reporter_cnt AS BIGINT) AS bank_reporter_cnt,
  CAST(bpr_reporter_cnt AS BIGINT) AS bpr_reporter_cnt,
  CAST(financial_reporter_cnt AS BIGINT) AS financial_reporter_cnt,
  CAST(other_reporter_cnt AS BIGINT) AS other_reporter_cnt,
  CAST(guarantee_os_amt AS DECIMAL(20,10)) AS guarantee_os_amt,
  CAST(credit_os_amt AS DECIMAL(20,10)) AS credit_os_amt,
  CAST(other_os_amt AS DECIMAL(20,10)) AS other_os_amt,
  CAST(lc_os_amt AS DECIMAL(20,10)) AS lc_os_amt,
  CAST(securities_os_amt AS DECIMAL(20,10)) AS securities_os_amt,
  CAST(guarantee_amt AS DECIMAL(20,10)) AS guarantee_amt,
  CAST(credit_amt AS DECIMAL(20,10)) AS credit_amt,
  CAST(other_amt AS DECIMAL(20,10)) AS other_amt,
  CAST(lc_amt AS DECIMAL(20,10)) AS lc_amt,
  CAST(securities_amt AS DECIMAL(20,10)) AS securities_amt,
  CAST(total_amt AS DECIMAL(20,10)) AS total_amt,
  CAST(total_os_amt AS DECIMAL(20,10)) AS total_os_amt,
  create_time as grass_date
from final_tab;