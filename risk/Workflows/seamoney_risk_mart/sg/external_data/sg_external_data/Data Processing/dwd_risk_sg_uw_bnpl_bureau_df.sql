-- DROP TABLE IF EXISTS risk.dwd_risk_sg_uw_bnpl_bureau_df;
-- CREATE TABLE IF NOT EXISTS risk.dwd_risk_sg_uw_bnpl_bureau_df (
--     trace_id STRING,
--     credit_user_id STRING,
--     platform_user_id STRING,
--     flow_no STRING,
--     request_date STRING,
--     request_datetime STRING,
--     enquiry_order_id STRING,
--     raw_enquiry_date STRING,
--     enquiry_status STRING,
--     enquiry_errors STRING,
--     enquiry_customer_name STRING,
--     enquiry_id_type STRING,
--     enquiry_id_no STRING,
--     enquiry_product STRING,
--     customer_names STRING,
--     verified_id_no STRING,
--     verified_id_type STRING,
--     verified_emails STRING,
--     verified_addresses STRING,
--     report_currency STRING,
--     reporting_cycle STRING,
--     loan_members_m0 BIGINT,
--     loan_members_m1 BIGINT,
--     loan_members_m2 BIGINT,
--     loan_members_m3 BIGINT,
--     loan_members_m4 BIGINT,
--     loan_members_m5 BIGINT,
--     loan_members_m6 BIGINT,
--     loan_members_m7 BIGINT,
--     loan_members_m8 BIGINT,
--     loan_members_m9 BIGINT,
--     loan_members_m10 BIGINT,
--     loan_members_m11 BIGINT,
--     loan_amount_m0 DECIMAL(30,10),
--     loan_amount_m1 DECIMAL(30,10),
--     loan_amount_m2 DECIMAL(30,10),
--     loan_amount_m3 DECIMAL(30,10),
--     loan_amount_m4 DECIMAL(30,10),
--     loan_amount_m5 DECIMAL(30,10),
--     loan_amount_m6 DECIMAL(30,10),
--     loan_amount_m7 DECIMAL(30,10),
--     loan_amount_m8 DECIMAL(30,10),
--     loan_amount_m9 DECIMAL(30,10),
--     loan_amount_m10 DECIMAL(30,10),
--     loan_amount_m11 DECIMAL(30,10),
--     delinquency_count_m0 BIGINT,
--     delinquency_count_m1 BIGINT,
--     delinquency_count_m2 BIGINT,
--     delinquency_count_m3 BIGINT,
--     delinquency_count_m4 BIGINT,
--     delinquency_count_m5 BIGINT,
--     delinquency_count_m6 BIGINT,
--     delinquency_count_m7 BIGINT,
--     delinquency_count_m8 BIGINT,
--     delinquency_count_m9 BIGINT,
--     delinquency_count_m10 BIGINT,
--     delinquency_count_m11 BIGINT,
--     delinquency_amount_m0 DECIMAL(30,10),
--     delinquency_amount_m1 DECIMAL(30,10),
--     delinquency_amount_m2 DECIMAL(30,10),
--     delinquency_amount_m3 DECIMAL(30,10),
--     delinquency_amount_m4 DECIMAL(30,10),
--     delinquency_amount_m5 DECIMAL(30,10),
--     delinquency_amount_m6 DECIMAL(30,10),
--     delinquency_amount_m7 DECIMAL(30,10),
--     delinquency_amount_m8 DECIMAL(30,10),
--     delinquency_amount_m9 DECIMAL(30,10),
--     delinquency_amount_m10 DECIMAL(30,10),
--     delinquency_amount_m11 DECIMAL(30,10),
--     litigation_records STRING
--     -- grass_date STRING
-- )

-- PARTITIONED BY (grass_date STRING COMMENT '分区日期')

-- stored as orc tblproperties ("orc.compress"="zstd")
-- LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_sg_uw_bnpl_bureau_df';
-- MSCK REPAIR TABLE ${SCHEMA}.dwd_risk_sg_uw_bnpl_bureau_df;


WITH processed_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY 
            grass_date, trace_id, credit_user_id, platform_user_id, flow_no, request_date, request_datetime 
            ORDER BY request_datetime DESC
        ) AS row_sequence
    FROM (
        SELECT
            -- keys
            grass_date,
            trace_id,
            GET_JSON_OBJECT(header_data, '$.CreditUserId') AS credit_user_id,
            GET_JSON_OBJECT(header_data, '$.PlatformUserId') AS platform_user_id,
            GET_JSON_OBJECT(header_data, '$.FlowNo') AS flow_no,
            
            -- 时间字段（保持原始字符串和时间戳两种格式）
            DATE_FORMAT(
                TO_TIMESTAMP(
                    GET_JSON_OBJECT(resp_raw_data, '$.Status.EnquiryDate'),
                    'dd/MM/yyyy HH:mm:ss'
                ),
                'yyyy-MM-dd'
            ) AS request_date,
            DATE_FORMAT(
                TO_TIMESTAMP(
                    GET_JSON_OBJECT(resp_raw_data, '$.Status.EnquiryDate'),
                    'dd/MM/yyyy HH:mm:ss'
                ),
                'yyyy-MM-dd HH:mm:ss'
            ) AS request_datetime,
            
            -- Status信息（原始JSON字段）
            GET_JSON_OBJECT(resp_raw_data, '$.Status.OrderId') AS enquiry_order_id,
            GET_JSON_OBJECT(resp_raw_data, '$.Status.EnquiryDate') AS raw_enquiry_date,
            GET_JSON_OBJECT(resp_raw_data, '$.Status.Status') AS enquiry_status,
            GET_JSON_OBJECT(resp_raw_data, '$.Status.Errors') AS enquiry_errors,
            
            -- Request信息（用户提交的查询参数）
            GET_JSON_OBJECT(resp_raw_data, '$.Request.CustomerName') AS enquiry_customer_name,
            GET_JSON_OBJECT(resp_raw_data, '$.Request.IdType') AS enquiry_id_type,
            GET_JSON_OBJECT(resp_raw_data, '$.Request.IdNo') AS enquiry_id_no,
            GET_JSON_OBJECT(resp_raw_data, '$.Request.Product') AS enquiry_product,
            
            -- 身份验证信息
            GET_JSON_OBJECT(resp_raw_data, '$.Response.PersonalIdentifyingInfo.CustomerNames') AS customer_names,
            GET_JSON_OBJECT(resp_raw_data, '$.Response.PersonalIdentifyingInfo.IdNo') AS verified_id_no,
            GET_JSON_OBJECT(resp_raw_data, '$.Response.PersonalIdentifyingInfo.IdType') AS verified_id_type,
            GET_JSON_OBJECT(resp_raw_data, '$.Response.PersonalIdentifyingInfo.Emails') AS verified_emails,
            GET_JSON_OBJECT(resp_raw_data, '$.Response.PersonalIdentifyingInfo.Addresses') AS verified_addresses,
            
            -- 基础财务指标
            GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.Currency') AS report_currency,
            GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.ReportingCycle') AS reporting_cycle,
            
            -- 分期贷款指标（m0-m11完整字段）
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.NoOfBnplLoanMembers.m0') AS DOUBLE)  AS loan_members_m0,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.NoOfBnplLoanMembers.m1') AS DOUBLE)  AS loan_members_m1,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.NoOfBnplLoanMembers.m2') AS DOUBLE)  AS loan_members_m2,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.NoOfBnplLoanMembers.m3') AS DOUBLE)  AS loan_members_m3,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.NoOfBnplLoanMembers.m4') AS DOUBLE)  AS loan_members_m4,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.NoOfBnplLoanMembers.m5') AS DOUBLE)  AS loan_members_m5,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.NoOfBnplLoanMembers.m6') AS DOUBLE)  AS loan_members_m6,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.NoOfBnplLoanMembers.m7') AS DOUBLE)  AS loan_members_m7,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.NoOfBnplLoanMembers.m8') AS DOUBLE)  AS loan_members_m8,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.NoOfBnplLoanMembers.m9') AS DOUBLE)  AS loan_members_m9,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.NoOfBnplLoanMembers.m10') AS DOUBLE) AS loan_members_m10,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.NoOfBnplLoanMembers.m11') AS DOUBLE) AS loan_members_m11,
            
            -- 贷款金额指标
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.AggregatedBnplLoanAmount.m0') AS DOUBLE)  AS loan_amount_m0,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.AggregatedBnplLoanAmount.m1') AS DOUBLE)  AS loan_amount_m1,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.AggregatedBnplLoanAmount.m2') AS DOUBLE)  AS loan_amount_m2,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.AggregatedBnplLoanAmount.m3') AS DOUBLE)  AS loan_amount_m3,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.AggregatedBnplLoanAmount.m4') AS DOUBLE)  AS loan_amount_m4,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.AggregatedBnplLoanAmount.m5') AS DOUBLE)  AS loan_amount_m5,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.AggregatedBnplLoanAmount.m6') AS DOUBLE)  AS loan_amount_m6,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.AggregatedBnplLoanAmount.m7') AS DOUBLE)  AS loan_amount_m7,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.AggregatedBnplLoanAmount.m8') AS DOUBLE)  AS loan_amount_m8,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.AggregatedBnplLoanAmount.m9') AS DOUBLE)  AS loan_amount_m9,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.AggregatedBnplLoanAmount.m10') AS DOUBLE) AS loan_amount_m10,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.AggregatedBnplLoanAmount.m11') AS DOUBLE) AS loan_amount_m11,
            
            -- 逾期指标
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.DelinquencyLoans.m0') AS DOUBLE)  AS delinquency_count_m0,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.DelinquencyLoans.m1') AS DOUBLE)  AS delinquency_count_m1,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.DelinquencyLoans.m2') AS DOUBLE)  AS delinquency_count_m2,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.DelinquencyLoans.m3') AS DOUBLE)  AS delinquency_count_m3,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.DelinquencyLoans.m4') AS DOUBLE)  AS delinquency_count_m4,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.DelinquencyLoans.m5') AS DOUBLE)  AS delinquency_count_m5,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.DelinquencyLoans.m6') AS DOUBLE)  AS delinquency_count_m6,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.DelinquencyLoans.m7') AS DOUBLE)  AS delinquency_count_m7,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.DelinquencyLoans.m8') AS DOUBLE)  AS delinquency_count_m8,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.DelinquencyLoans.m9') AS DOUBLE)  AS delinquency_count_m9,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.DelinquencyLoans.m10') AS DOUBLE) AS delinquency_count_m10,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.DelinquencyLoans.m11') AS DOUBLE) AS delinquency_count_m11,
            
            -- 逾期金额
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.DelinquencyAmounts.m0') AS DOUBLE)  AS delinquency_amount_m0,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.DelinquencyAmounts.m1') AS DOUBLE)  AS delinquency_amount_m1,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.DelinquencyAmounts.m2') AS DOUBLE)  AS delinquency_amount_m2,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.DelinquencyAmounts.m3') AS DOUBLE)  AS delinquency_amount_m3,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.DelinquencyAmounts.m4') AS DOUBLE)  AS delinquency_amount_m4,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.DelinquencyAmounts.m5') AS DOUBLE)  AS delinquency_amount_m5,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.DelinquencyAmounts.m6') AS DOUBLE)  AS delinquency_amount_m6,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.DelinquencyAmounts.m7') AS DOUBLE)  AS delinquency_amount_m7,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.DelinquencyAmounts.m8') AS DOUBLE)  AS delinquency_amount_m8,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.DelinquencyAmounts.m9') AS DOUBLE)  AS delinquency_amount_m9,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.DelinquencyAmounts.m10') AS DOUBLE) AS delinquency_amount_m10,
            CAST(GET_JSON_OBJECT(resp_raw_data, '$.Response.BnplLoanPerformanceInfo.DelinquencyAmounts.m11') AS DOUBLE) AS delinquency_amount_m11,
            
            -- 法律诉讼信息
            GET_JSON_OBJECT(resp_raw_data, '$.Response.LitigationTraceList') AS litigation_records
            
        FROM risk.ods__credit_risk_datafetch_sg_db__identity_data_tab__df
        WHERE grass_date = '${grass_date}'
          AND data_source_name = 'ExperianBNPL'
    ) AS base_data
)

INSERT INTO TABLE risk.dwd_risk_sg_uw_bnpl_bureau_df


SELECT 
    -- grass_date,
    trace_id,
    credit_user_id,
    platform_user_id,
    flow_no,
    request_date,
    request_datetime,
    enquiry_order_id,
    raw_enquiry_date,
    enquiry_status,
    enquiry_errors,
    enquiry_customer_name,
    enquiry_id_type,
    enquiry_id_no,
    enquiry_product,
    customer_names,
    verified_id_no,
    verified_id_type,
    verified_emails,
    verified_addresses,
    report_currency,
    reporting_cycle,
    loan_members_m0,
    loan_members_m1,
    loan_members_m2,
    loan_members_m3,
    loan_members_m4,
    loan_members_m5,
    loan_members_m6,
    loan_members_m7,
    loan_members_m8,
    loan_members_m9,
    loan_members_m10,
    loan_members_m11,
    loan_amount_m0,
    loan_amount_m1,
    loan_amount_m2,
    loan_amount_m3,
    loan_amount_m4,
    loan_amount_m5,
    loan_amount_m6,
    loan_amount_m7,
    loan_amount_m8,
    loan_amount_m9,
    loan_amount_m10,
    loan_amount_m11,
    delinquency_count_m0,
    delinquency_count_m1,
    delinquency_count_m2,
    delinquency_count_m3,
    delinquency_count_m4,
    delinquency_count_m5,
    delinquency_count_m6,
    delinquency_count_m7,
    delinquency_count_m8,
    delinquency_count_m9,
    delinquency_count_m10,
    delinquency_count_m11,
    delinquency_amount_m0,
    delinquency_amount_m1,
    delinquency_amount_m2,
    delinquency_amount_m3,
    delinquency_amount_m4,
    delinquency_amount_m5,
    delinquency_amount_m6,
    delinquency_amount_m7,
    delinquency_amount_m8,
    delinquency_amount_m9,
    delinquency_amount_m10,
    delinquency_amount_m11,
    litigation_records,
    grass_date
FROM processed_data
WHERE row_sequence = 1
;