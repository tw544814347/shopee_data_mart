
WITH cic_raw_base AS (
    SELECT
        grass_date,
        trace_id,
        GET_JSON_OBJECT(header_data, '$.CreditUserId') AS credit_user_id,
        GET_JSON_OBJECT(header_data, '$.PlatformUserId') AS platform_user_id,
        GET_JSON_OBJECT(header_data, '$.FlowNo') AS flow_no,
        DATE_FORMAT(DATE(GET_JSON_OBJECT(resp_raw_data, '$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.RequestTime')), 'yyyy-MM-dd') AS request_date,
        GET_JSON_OBJECT(resp_raw_data, '$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.RequestTime') AS request_date_time,
        GET_JSON_OBJECT(resp_raw_data, '$.SOAPBody.InvokeResponse.Return.Text.Response.Detail.Content.CBOutput.ProductResponse.CBNAEProductOutput.CreditReport.MatchedSubject') AS cic_report_demogr,
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
)


INSERT OVERWRITE TABLE risk.dwd_risk_ph_uw_cic_demogr_df
SELECT
    trace_id,
    credit_user_id,
    platform_user_id,
    flow_no,
    request_date,
    request_date_time,
    -- 主表字段
    GET_JSON_OBJECT(cic_report_demogr, '$.CBSubjectCode') AS cic_demogr_cb_subject_code,
    GET_JSON_OBJECT(cic_report_demogr, '$.FlagMatched') AS cic_demogr_matched_flag,
    -- IndividualName解析
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.IndividualName.FirstName') AS cic_demogr_first_name,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.IndividualName.FormerLastName') AS cic_demogr_former_last_name,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.IndividualName.LastName') AS cic_demogr_last_name,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.IndividualName.MiddleName') AS cic_demogr_middle_name,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.IndividualName.Nickname') AS cic_demogr_nickname,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.IndividualName.Suffix') AS cic_demogr_suffix,
    -- AdditionalNames解析
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.AdditionalNames.FatherFirstName') AS cic_demogr_father_first_name,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.AdditionalNames.FatherLastName') AS cic_demogr_father_last_name,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.AdditionalNames.FatherMiddleName') AS cic_demogr_father_middle_name,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.AdditionalNames.FatherSuffix') AS cic_demogr_father_suffix,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.AdditionalNames.MotherMaidenFirstName') AS cic_demogr_mother_first_name,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.AdditionalNames.MotherMaidenLastName') AS cic_demogr_mother_last_name,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.AdditionalNames.MotherMaidenMiddleName') AS cic_demogr_mother_middle_name,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.AdditionalNames.SpouseFirstName') AS cic_demogr_spouse_first_name,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.AdditionalNames.SpouseLastName') AS cic_demogr_spouse_last_name,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.AdditionalNames.SpouseMiddleName') AS cic_demogr_spouse_middle_name,
    -- GeneralDataIndividual解析（类型转换）
    CAST(GET_JSON_OBJECT(cic_report_demogr, '$.Individual.GeneralDataIndividual.GeneralDataIndividual.CarsOwnedNo') AS BIGINT) AS cic_demogr_cars_owned_no,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.GeneralDataIndividual.GeneralDataIndividual.CivilStatus') AS cic_demogr_civil_status,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.GeneralDataIndividual.GeneralDataIndividualDesc.CivilStatusDesc') AS cic_demogr_civil_status_desc,
    CAST(GET_JSON_OBJECT(cic_report_demogr, '$.Individual.GeneralDataIndividual.GeneralDataIndividual.DependantsNo') AS BIGINT) AS cic_demogr_dependants_no,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.GeneralDataIndividual.GeneralDataIndividual.Gender') AS cic_demogr_gender,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.GeneralDataIndividual.GeneralDataIndividualDesc.GenderDesc') AS cic_demogr_gender_desc,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.GeneralDataIndividual.GeneralDataIndividual.Nationality') AS cic_demogr_nationality,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.GeneralDataIndividual.GeneralDataIndividualDesc.NationalityDesc') AS cic_demogr_nationality_desc,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.GeneralDataIndividual.GeneralDataIndividual.Resident') AS cic_demogr_resident,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.GeneralDataIndividual.GeneralDataIndividualDesc.ResidentDesc') AS cic_demogr_resident_desc,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.GeneralDataIndividual.GeneralDataIndividual.Title') AS cic_demogr_title,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.GeneralDataIndividual.GeneralDataIndividualDesc.TitleDesc') AS cic_demogr_title_desc,
    -- BirthData解析
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.BirthData.BirthData.Country') AS cic_demogr_birth_country,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.BirthData.BirthDataDesc.CountryDesc') AS cic_demogr_birth_country_desc,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.BirthData.BirthData.Place') AS cic_demogr_birth_place,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.BirthData.BirthData.Date') AS cic_demogr_birth_date,
    -- EmploymentData解析（金额类型转换）
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.EmploymentData.Text') AS cic_demogr_employ_text,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.EmploymentData.LastUpdateDate') AS cic_demogr_employ_last_update_date,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.EmploymentData.EmploymentData.AnnualMonthlyIndicator') AS cic_demogr_employ_annual_monthly_indicator,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.EmploymentData.EmploymentDataDesc.AnnualMonthlyIndicatorDesc') AS cic_demogr_employ_annual_monthly_indicator_desc,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.EmploymentData.EmploymentData.Currency') AS cic_demogr_employ_currency,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.EmploymentData.EmploymentDataDesc.CurrencyDesc') AS cic_demogr_employ_currency_desc,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.EmploymentData.EmploymentData.DateHiredFrom') AS cic_demogr_employ_date_hired_from,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.EmploymentData.EmploymentData.DateHiredTo') AS cic_demogr_employ_date_hired_to,
    CAST(GET_JSON_OBJECT(cic_report_demogr, '$.Individual.EmploymentData.EmploymentData.GrossIncome') AS DECIMAL(30,10)) AS cic_demogr_employ_gross_income,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.EmploymentData.EmploymentData.Occupation') AS cic_demogr_employ_occupation,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.EmploymentData.EmploymentDataDesc.OccupationDesc') AS cic_demogr_employ_occupation_desc,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.EmploymentData.EmploymentData.OccupationStatus') AS cic_demogr_employ_occupation_status,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.EmploymentData.EmploymentDataDesc.OccupationStatusDesc') AS cic_demogr_employ_occupation_status_desc,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.EmploymentData.EmploymentData.PhoneNumber') AS cic_demogr_employ_phone_number,
    -- 其他字段
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.AddressHistory') AS cic_demogr_address_history,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.ContactHistory') AS cic_demogr_contact_history,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.IdentificationCodeHistory') AS cic_demogr_id_code_history,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.IDHistory') AS cic_demogr_id_history,
    GET_JSON_OBJECT(cic_report_demogr, '$.Individual.SoleTraderData') AS cic_demogr_sole_trader_data,
    grass_date
FROM cic_raw_base
WHERE rn = 1  -- 去重后只保留第一条记录