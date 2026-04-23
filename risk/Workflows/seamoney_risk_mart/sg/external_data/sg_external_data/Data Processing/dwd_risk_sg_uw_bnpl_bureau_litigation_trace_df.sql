-- DROP TABLE IF EXISTS risk.dwd_risk_sg_uw_bnpl_bureau_litigation_trace_df;
-- CREATE TABLE IF NOT EXISTS risk.dwd_risk_sg_uw_bnpl_bureau_litigation_trace_df (
--      trace_id STRING COMMENT '唯一追踪ID',
--     credit_user_id STRING COMMENT '信用用户ID',
--     platform_user_id STRING COMMENT '平台用户ID',
--     flow_no STRING COMMENT '流程编号',
--     request_date STRING COMMENT '请求日期(yyyy-MM-dd)',
--     request_date_time STRING COMMENT '请求时间(yyyy-MM-dd HH:mm:ss)',
--     enquiry_order_id STRING COMMENT '查询订单ID',
--     enquiry_status STRING COMMENT '查询状态',
--     enquiry_errors STRING COMMENT '错误信息',
--     enquiry_customer_name STRING COMMENT '客户姓名',
--     enquiry_id_type STRING COMMENT '证件类型',
--     enquiry_id_no STRING COMMENT '证件号码',
--     court STRING COMMENT '法院名称',
--     is_trace STRING COMMENT '是否追踪',
--     by_bus STRING COMMENT '业务类型',
--     cur_year_cnt_nlg BIGINT COMMENT '本年NLG类案件数量',
--     cur_year_cnt_non_nlg BIGINT COMMENT '本年NON_NLG类案件数量',
--     cur_year_cnt_no_cat BIGINT COMMENT '本年无分类案件数量',
--     pre_year_cnt_nlg BIGINT COMMENT '上年NLG类案件数量',
--     pre_year_cnt_non_nlg BIGINT COMMENT '上年NON_NLG类案件数量',
--     pre_year_cnt_no_cat BIGINT COMMENT '上年无分类案件数量'
--     -- grass_date STRING COMMENT '数据分区日期'
-- )

-- PARTITIONED BY (grass_date STRING COMMENT '分区日期')

-- stored as orc tblproperties ("orc.compress"="zstd")
-- LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_sg_uw_bnpl_bureau_litigation_trace_df';
-- MSCK REPAIR TABLE ${SCHEMA}.dwd_risk_sg_uw_bnpl_bureau_litigation_trace_df;

WITH raw_data AS (
    SELECT
        grass_date,
        trace_id,
        GET_JSON_OBJECT(header_data, '$.CreditUserId') AS credit_user_id,
        GET_JSON_OBJECT(header_data, '$.PlatformUserId') AS platform_user_id,
        GET_JSON_OBJECT(header_data, '$.FlowNo') AS flow_no,
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
        ) AS request_date_time,
        from_json(
            resp_raw_data,
            'STRUCT<
                Status: STRUCT<OrderId:STRING, Status:STRING, Errors:STRING>,
                Request: STRUCT<CustomerName:STRING, IdType:STRING, IdNo:STRING>,
                Response: STRUCT<
                    LitigationTraceList: ARRAY<STRUCT<
                        court:STRING,
                        isTrace:STRING,
                        byBus:STRING,
                        category:STRING,
                        reportingDate:STRING
                    >>
                >
            >'
        ) AS parsed_data
    FROM risk.ods__credit_risk_datafetch_sg_db__identity_data_tab__df
    WHERE grass_date = '${ds}'
        AND data_source_name = 'ExperianBNPL'
),

process_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY 
            grass_date, trace_id, credit_user_id, platform_user_id, flow_no, request_date, request_date_time 
            ORDER BY request_date_time DESC
        ) AS row_sequence
    FROM raw_data
),

exploded_data AS (
    SELECT
        trace_id,
        credit_user_id,
        platform_user_id,
        flow_no,
        request_date,
        request_date_time,
        grass_date,
        parsed_data.Status.OrderId AS enquiry_order_id,
        parsed_data.Status.Status AS enquiry_status,
        parsed_data.Status.Errors AS enquiry_errors,
        parsed_data.Request.CustomerName AS enquiry_customer_name,
        parsed_data.Request.IdType AS enquiry_id_type,
        parsed_data.Request.IdNo AS enquiry_id_no,
        explode(parsed_data.Response.LitigationTraceList) AS trace
    FROM process_data
    WHERE row_sequence = 1
),

year_calculations AS (
    SELECT
        trace_id,
        credit_user_id,
        grass_date,
        platform_user_id,
        flow_no,
        request_date,
        request_date_time,
        enquiry_order_id,
        enquiry_status,
        enquiry_errors,
        enquiry_customer_name,
        enquiry_id_type,
        enquiry_id_no,
        trace.court,
        trace.isTrace,
        trace.byBus,
        YEAR(trace.reportingDate) AS report_year,
        CASE 
            WHEN trace.category = 'NLG' THEN 1 ELSE 0 
        END AS nlg_flag,
        CASE 
            WHEN trace.category = 'NON_NLG' THEN 1 ELSE 0 
        END AS non_nlg_flag,
        CASE 
            WHEN trace.category = 'NO_CAT' THEN 1 ELSE 0 
        END AS no_cat_flag
    FROM exploded_data
)

INSERT INTO TABLE risk.dwd_risk_sg_uw_bnpl_bureau_litigation_trace_df 
SELECT
    trace_id,
    credit_user_id,
    platform_user_id,
    flow_no,
    request_date,
    request_date_time,
    enquiry_order_id,
    enquiry_status,
    enquiry_errors,
    enquiry_customer_name,
    enquiry_id_type,
    enquiry_id_no,
    court,
    isTrace AS is_trace,
    byBus AS by_bus,
    SUM(CASE WHEN report_year = YEAR(CURRENT_DATE()) THEN nlg_flag ELSE 0 END) AS cur_year_cnt_nlg,
    SUM(CASE WHEN report_year = YEAR(CURRENT_DATE()) THEN non_nlg_flag ELSE 0 END) AS cur_year_cnt_non_nlg,
    SUM(CASE WHEN report_year = YEAR(CURRENT_DATE()) THEN no_cat_flag ELSE 0 END) AS cur_year_cnt_no_cat,
    SUM(CASE WHEN report_year = YEAR(CURRENT_DATE())-1 THEN nlg_flag ELSE 0 END) AS pre_year_cnt_nlg,
    SUM(CASE WHEN report_year = YEAR(CURRENT_DATE())-1 THEN non_nlg_flag ELSE 0 END) AS pre_year_cnt_non_nlg,
    SUM(CASE WHEN report_year = YEAR(CURRENT_DATE())-1 THEN no_cat_flag ELSE 0 END) AS pre_year_cnt_no_cat,
    grass_date
FROM year_calculations
GROUP BY 
    trace_id,
    credit_user_id,
    platform_user_id,
    flow_no,
    request_date,
    request_date_time,
    enquiry_order_id,
    enquiry_status,
    enquiry_errors,
    enquiry_customer_name,
    enquiry_id_type,
    enquiry_id_no,
    court,
    isTrace,
    byBus,
    grass_date;
