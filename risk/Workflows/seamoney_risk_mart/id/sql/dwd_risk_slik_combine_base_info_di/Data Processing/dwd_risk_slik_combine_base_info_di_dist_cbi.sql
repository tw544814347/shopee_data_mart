WITH slik_map AS (
    SELECT
        resp_raw_data,
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
base_data AS (
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

    get_json_object(value_str, '$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_AddresAndContact.INDID_AddressAsIdentity.INDID_Address') as address,
    get_json_object(value_str, '$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_AddresAndContact.INDID_AddressAsIdentity.INDID_City') as city_id,
    get_json_object(value_str, '$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_AddresAndContact.INDID_AddressAsIdentity.INDID_CityDesc') as city,
    get_json_object(value_str, '$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_AddresAndContact.INDID_AddressAsIdentity.INDID_District') as district,
    get_json_object(value_str, '$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_AddresAndContact.INDID_AddressAsIdentity.INDID_SubDistrict') as village,
    get_json_object(value_str, '$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_AddresAndContact.INDID_AddressAsIdentity.INDID_PostalCode') as zipcode,
    get_json_object(value_str, '$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_AddresAndContact.INDID_AddressAsIdentity.INDID_Country') as country_id,
    get_json_object(value_str, '$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_AddresAndContact.INDID_AddressAsIdentity.INDID_CountryDesc') as country,
    
    -- 就业信息 ({employment})
    get_json_object(value_str, '$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_EmploymentInfo.INDID_EmploymentEconomicSector') as business_field_id,
    get_json_object(value_str, '$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_EmploymentInfo.INDID_EmploymentEconomicSectorDesc') as business_field,
    get_json_object(value_str, '$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_EmploymentInfo.INDID_Employment') as job_id,
    get_json_object(value_str, '$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_EmploymentInfo.INDID_EmploymentDesc') as job,
    get_json_object(value_str, '$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_EmploymentInfo.INDID_EmploymentOfficeName') as work_place,
    
    -- 身份信息 ({identity})
    get_json_object(value_str, '$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_Identity.INDID_IDType') as identity_id,
    get_json_object(value_str, '$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_Identity.INDID_IDNumber') as identity_number,
    get_json_object(value_str, '$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_Identity.INDID_TaxNumber') as npwp,
    
    -- 个人信息 ({personal})
    get_json_object(value_str, '$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_Personal.INDID_Gender') as gender_id,
    get_json_object(value_str, '$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_Personal.INDID_GenderDesc') as gender,
    get_json_object(value_str, '$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_Personal.INDID_EducationLevel') as degree_id,
    get_json_object(value_str, '$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_Personal.INDID_EducationLevelDesc') as degree,
    get_json_object(value_str, '$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_Personal.INDID_FullName') as name,
    get_json_object(value_str, '$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_Personal.INDID_DateOfBirth') as birth_date,
    get_json_object(value_str, '$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_Personal.INDID_PlaceOfBirth') as birth_place,
    
    -- NA字段
    NULL as reporter_ljk_id,
    NULL as reporter,
    NULL as report_create_date,
    NULL as report_update_date
    FROM non_empty_report
),
non_empty_report_sub2 AS (
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
        get_json_object(value_str, '$.result.BureauReport.Summary') as summary,
        value_str
    FROM slik_map
    WHERE value_str IS NOT NULL AND length(trim(value_str)) > 2  -- 简单判断非空json字符串
        AND get_json_object(value_str, '$.error') <> true 
    ),
credit_amt_sub2 AS (
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
        sum(
            coalesce(replace(
            get_json_object(summary, '$.SUMM_ActiveFacility_AsDebtor.SUMM_ActiveFacility_AsDebtorFooter.SUMM_AmountSum'),',',''),0)
        ) as credit_amt,
        sum(
            coalesce(replace(
            get_json_object(summary, '$.SUMM_ClosedFacility_AsDebtor.SUMM_ClosedFacility_AsDebtorFooter.SUMM_OutstandingSum'),',',''),0)
        ) as credit_os_amt
    FROM non_empty_report_sub2
    GROUP BY 
        trace_id,
        credit_user_id,
        platform_user_id,
        flow_no,
        ktp_no,
        report_no,
        status,
        is_error,
        create_time,
        report_update_time
    ),
tab2 AS (
select trace_id,
        credit_user_id,
        platform_user_id,
        flow_no,
        ktp_no,
        report_no,
        status,
        is_error,
        create_time,
        report_update_time,
        credit_amt,
        credit_os_amt
from credit_amt_sub2
),
---------------------------------------------------------------------- tab3
non_empty_report_tab3 AS (
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
    WHERE value_str IS NOT NULL AND length(trim(value_str)) > 2                  
        AND get_json_object(value_str, '$.error') <> true 
    ),
active_loan_data_tmp_tab3 AS (
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
        FROM non_empty_report_tab3
    ),
closed_loan_data_tmp_tab3 AS (
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
        FROM non_empty_report_tab3
    ),
active_loan_data_tab3 AS (
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
        explode(loan) AS loan_record
    FROM active_loan_data_tmp_tab3
    WHERE loan IS NOT NULL
    ),
closed_loan_data_tab3 AS (
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
        explode(loan) AS loan_record
    FROM closed_loan_data_tmp_tab3
    WHERE loan IS NOT NULL
    ),
combined_credit_records_tab3 AS (
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
        loan_record
    FROM active_loan_data_tab3
    UNION 
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
        loan_record
    FROM closed_loan_data_tab3
    ),
institution_counts_tab3 AS (
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
        get_json_object(ccr.loan_record, '$.CREDIT_Creditor') as reporter,
        CASE get_json_object(ccr.loan_record, '$.CREDIT_CreditorCategory') 
            WHEN 'Bank Umum Konvensional' THEN 'Bank Umum'
            WHEN 'Bank Umum Syariah / UUS' THEN 'Bank Umum'
            WHEN 'BPR Konvensional' THEN 'BPR/BPRS'
            WHEN 'BPR Syariah' THEN 'BPR/BPRS'
            WHEN 'Perusahaan Pembiayaan' THEN 'Lembaga Pembiayaan'
            WHEN 'Perusahaan Pembiayaan Syariah' THEN 'Lembaga Pembiayaan'
            WHEN 'Perusahaan Modal Ventura' THEN 'Lembaga Pembiayaan'
            WHEN 'Perusahaan Pembiayaan Insfrastruktur' THEN 'Lembaga Pembiayaan'
            WHEN 'Perusahaan Modal Ventura Syariah' THEN 'Lembaga Pembiayaan'
            WHEN 'Lembaga Jasa Keuangan Lainnya' THEN 'Lembaga Pembiayaan'
            WHEN 'Lembaga Jasa Keuangan Lainnya Syariah' THEN 'Lembaga Pembiayaan'
            WHEN 'Perusahaan Efek yang menjalankan kegiatan usaha sebagai perantara pedagang efek' THEN 'Lembaga Pembiayaan'
            WHEN 'Lembaga Pendanaan Efek' THEN 'Lembaga Pembiayaan'
            WHEN 'Pergadaian' THEN 'Lembaga Pembiayaan'
            WHEN 'Pergadaian Syariah/Unit Usaha Syariah' THEN 'Lembaga Pembiayaan'
            WHEN 'Lembaga Non Lembaga Jasa Keuangan' THEN 'Lainnya'
            ELSE NULL
        END as category
    FROM combined_credit_records_tab3 ccr
    ),
tab4 AS (
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
        reporter,
        SUM(CASE WHEN category = 'Bank Umum' THEN 1 ELSE 0 END) as bank_reporter_cnt,
        SUM(CASE WHEN category = 'BPR/BPRS' THEN 1 ELSE 0 END) as bpr_reporter_cnt,
        SUM(CASE WHEN category = 'Lembaga Pembiayaan' THEN 1 ELSE 0 END) as financial_reporter_cnt,
        SUM(CASE WHEN category = 'Lainnya' THEN 1 ELSE 0 END) as other_reporter_cnt
  FROM institution_counts_tab3
  GROUP BY trace_id,
        credit_user_id,
        platform_user_id,
        flow_no,
        ktp_no,
        report_no,
        status,
        is_error,
        create_time,
        report_update_time,
        reporter

),
payment_history_tab3 AS (
    SELECT 
    cr.trace_id,
    cr.credit_user_id,
    cr.platform_user_id,
    cr.flow_no,
    cr.ktp_no,
    cr.report_no,
    cr.status,
    cr.is_error,
    cr.create_time,
    cr.report_update_time,
    ph_item.CREDIT_PaymentHistoryList_Item.CREDIT_Collectability AS quality,
    ph_item.CREDIT_PaymentHistoryList_Item.CREDIT_YearMonthData AS year_month
    FROM (
    SELECT 
        *,
        -- 使用slice函数取前24个元素
        slice(
        from_json(
            coalesce(
                    -- 先尝试Active路径
                    get_json_object(loan_record, '$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_PaymentHistory.CREDIT_PaymentHistoryList'),
                    -- 如果Active路径没有，再尝试Closed路径
                    get_json_object(loan_record, '$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_PaymentHistory.CREDIT_PaymentHistoryList')
                ),
            'array<struct<CREDIT_PaymentHistoryList_Item:struct<CREDIT_Collectability:string,CREDIT_YearMonthData:string>>>'
        ),
        1, 24  -- 从第1个元素开始，取24个元素（索引从1开始）
        ) AS payment_history_array
    FROM combined_credit_records_tab3
    ) cr
    LATERAL VIEW EXPLODE(cr.payment_history_array) ph AS ph_item
),
-- max_payment_history_tab3 as (
-- SELECT 
--     trace_id,
--     credit_user_id,
--     platform_user_id,
--     flow_no,
--     ktp_no,
--     report_no,
--     status,
--     is_error,
--     create_time,
--     report_update_time,
--     coalesce(max(quality),-1) as worst_quality
-- FROM payment_history_tab3
-- GROUP BY trace_id,
--     credit_user_id,
--     platform_user_id,
--     flow_no,
--     ktp_no,
--     report_no,
--     status,
--     is_error,
--     create_time,
--     report_update_time
-- ),
-- tab3 AS (
-- select cr.trace_id,
--     cr.credit_user_id,
--     cr.platform_user_id,
--     cr.flow_no,
--     cr.ktp_no,
--     cr.report_no,
--     cr.status,
--     cr.is_error,
--     cr.create_time,
--     cr.report_update_time,
--     mph.worst_quality as worst_quality,
--     if(cr.quality = mph.worst_quality, cr.year_month, null) as worst_quality_time
-- from --payment_history_tab3 cr 
--     max_payment_history_tab3 mph
-- left join --max_payment_history_tab3 mph 
--     payment_history_tab3 cr
-- on mph.trace_id = cr.trace_id
-- )

tab3 as (
select 
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
    quality as worst_quality,
    year_month as worst_quality_time,
    row_number() over (partition by trace_id order by quality desc, year_month asc) as rank_num
from payment_history_tab3
)

INSERT OVERWRITE TABLE risk.dwd_risk_slik_combine_base_info_di
PARTITION (data_source='CBI', grass_date)

SELECT 
    base_data.trace_id,
    CAST(base_data.credit_user_id AS BIGINT) AS credit_user_id,
    CAST(base_data.platform_user_id AS BIGINT) AS platform_user_id,
    base_data.flow_no,
    CAST(base_data.ktp_no AS BIGINT) AS ktp_no,
    base_data.report_no,
    base_data.status,
    base_data.is_error,
    base_data.report_update_time,
    base_data.create_time,
    
    base_data.name,
    CAST(base_data.birth_date AS STRING) AS birth_date,
    base_data.birth_place,
    CAST(base_data.identity_id AS BIGINT) AS identity_id,
    CAST(base_data.identity_number AS BIGINT) AS identity_number,
    CAST(base_data.npwp AS BIGINT) AS npwp,
    base_data.gender_id,
    base_data.gender,
    CAST(base_data.degree_id AS STRING) AS degree_id,
    base_data.degree,
    CAST(base_data.job_id AS STRING) AS job_id,
    base_data.job,
    base_data.work_place,
    base_data.business_field_id,
    base_data.business_field,
    base_data.address,
    base_data.country_id,
    base_data.country,
    CAST(base_data.city_id AS BIGINT) AS city_id,
    base_data.city,
    base_data.district,
    base_data.village,
    CAST(base_data.zipcode AS STRING) AS zipcode,
    base_data.report_update_date,
    CAST(base_data.reporter_ljk_id AS STRING) AS reporter_ljk_id,
    base_data.reporter,
    base_data.report_create_date,
    
    tab3.worst_quality,
    tab3.worst_quality_time AS worst_quality_date,
    
    CAST(tab4.bank_reporter_cnt AS BIGINT) AS bank_reporter_cnt,
    CAST(tab4.bpr_reporter_cnt AS BIGINT) AS bpr_reporter_cnt,
    CAST(tab4.financial_reporter_cnt AS BIGINT) AS financial_reporter_cnt,
    CAST(tab4.other_reporter_cnt AS BIGINT) AS other_reporter_cnt,
    
    NULL AS guarantee_os_amt,
    CAST(tab2.credit_os_amt AS DECIMAL(20,10)) AS credit_os_amt,
    NULL AS other_os_amt,
    NULL AS lc_os_amt,
    NULL AS securities_os_amt,
    NULL AS guarantee_amt,
    CAST(tab2.credit_amt AS DECIMAL(20,10)) AS credit_amt,
    NULL AS other_amt,
    NULL AS lc_amt,
    NULL AS securities_amt,
    NULL AS total_amt,
    NULL AS total_os_amt,
    base_data.create_time as grass_date
FROM base_data
LEFT JOIN tab2 ON base_data.trace_id = tab2.trace_id
LEFT JOIN tab3 ON base_data.trace_id = tab3.trace_id and tab3.rank_num = 1
LEFT JOIN tab4 ON base_data.trace_id = tab4.trace_id
;