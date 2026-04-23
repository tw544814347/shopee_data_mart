--drop table if exists risk.dwd_risk_id_fdc_history_inquiry_active_loan_info_di;
create table if not exists risk.dwd_risk_id_fdc_history_inquiry_active_loan_info_di (
    fdc_report_id string,
    create_timestamp string,
    flow_no string,
    ktp_req bigint,
    userid bigint,
    credit_userid bigint,
    trace_id string,
    data_source_name string,
    inquiry_date string,
    status string,
    total_unique_inquiry_3days bigint,
    total_unique_inquiry_7days bigint,
    total_unique_inquiry_30days bigint,
    total_unique_inquiry_90days bigint,
    total_unique_inquiry_180days bigint,
    total_unique_inquiry_360days bigint,
    total_unique_inquiry_over_360days bigint,
    unique_active_loan_platform_cnt bigint,
    lst_active_loan_platform string
)
PARTITIONED BY (grass_date STRING COMMENT 'grass_date, partition key')
STORED AS ORC
TBLPROPERTIES ("orc.compress" = "zstd")
LOCATION '${HDFS_PATH}/risk_mart/dwd_risk_id_fdc_history_inquiry_active_loan_info_di/grass_region=ID';
--msck repair table risk.dwd_risk_id_fdc_history_inquiry_active_loan_info_di;

ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
create or replace temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

INSERT OVERWRITE TABLE risk.dwd_risk_id_fdc_history_inquiry_active_loan_info_di PARTITION (grass_date)
select
    concat_ws('_', coalesce(get_json_object(req_data, '$.identity_number'), get_json_object(req_data, '$.identityNumber'), get_json_object(req_data, '$.IdentityNumber'), get_json_object(req_data, '$.ktp'), get_json_object(req_data, '$.Ktp'), get_json_object(req_data, '$.KTP')), unix_timestamp(to_utc_timestamp(create_time, 'GMT+7'))) as fdc_report_id,
    unix_timestamp(to_utc_timestamp(create_time, 'GMT+7')) as create_timestamp,
    coalesce(get_json_object(header_data, '$.flow_no'), get_json_object(header_data, '$.flowNo'), get_json_object(header_data, '$.FlowNo')) as flow_no,
    cast(coalesce(get_json_object(req_data, '$.identity_number'), get_json_object(req_data, '$.identityNumber'), get_json_object(req_data, '$.IdentityNumber'), get_json_object(req_data, '$.ktp'), get_json_object(req_data, '$.Ktp'), get_json_object(req_data, '$.KTP')) as bigint) as ktp_req,
    cast(coalesce(get_json_object(header_data, '$.platform_user_id'), get_json_object(header_data, '$.platformUserId'), get_json_object(header_data, '$.PlatformUserId')) as bigint) as userid,
    cast(coalesce(get_json_object(header_data, '$.credit_user_id'), get_json_object(header_data, '$.creditUserId'), get_json_object(header_data, '$.CreditUserId')) as bigint) as credit_userid,
    trace_id as trace_id,
    data_source_name as data_source_name,
    coalesce(get_json_object(resp_raw_data, '$.data.inquiry_date'), get_json_object(resp_raw_data, '$.data.inquiryDate'), get_json_object(resp_raw_data, '$.data.InquiryDate'), get_json_object(resp_raw_data, '$.inquiry_date'), get_json_object(resp_raw_data, '$.inquiryDate'), get_json_object(resp_raw_data, '$.InquiryDate')) as inquiry_date,
    coalesce(get_json_object(resp_raw_data, '$.data.status'), get_json_object(resp_raw_data, '$.data.Status'), get_json_object(resp_raw_data, '$.status'), get_json_object(resp_raw_data, '$.Status')) as status,
    cast(coalesce(get_json_object(resp_raw_data, '$.historyInquiry.statistic.3_hari'), get_json_object(resp_raw_data, '$.historyInquiry.statistic.3Hari')) as bigint) as total_unique_inquiry_3days,
    cast(coalesce(get_json_object(resp_raw_data, '$.historyInquiry.statistic.7_hari'), get_json_object(resp_raw_data, '$.historyInquiry.statistic.7Hari')) as bigint) as total_unique_inquiry_7days,
    cast(coalesce(get_json_object(resp_raw_data, '$.historyInquiry.statistic.30_hari'), get_json_object(resp_raw_data, '$.historyInquiry.statistic.30Hari')) as bigint) as total_unique_inquiry_30days,
    cast(coalesce(get_json_object(resp_raw_data, '$.historyInquiry.statistic.90_hari'), get_json_object(resp_raw_data, '$.historyInquiry.statistic.90Hari')) as bigint) as total_unique_inquiry_90days,
    cast(coalesce(get_json_object(resp_raw_data, '$.historyInquiry.statistic.180_hari'), get_json_object(resp_raw_data, '$.historyInquiry.statistic.180Hari')) as bigint) as total_unique_inquiry_180days,
    cast(coalesce(get_json_object(resp_raw_data, '$.historyInquiry.statistic.360_hari'), get_json_object(resp_raw_data, '$.historyInquiry.statistic.360Hari')) as bigint) as total_unique_inquiry_360days,
    cast(coalesce(get_json_object(resp_raw_data, '$.historyInquiry.statistic.>360_hari'), get_json_object(resp_raw_data, '$.historyInquiry.statistic.>360Hari')) as bigint) as total_unique_inquiry_over_360days,
    cast(coalesce(get_json_object(resp_raw_data, '$.platformAktif.jumlah_platform_aktif'), get_json_object(resp_raw_data, '$.platformAktif.jumlahPlatformAktif'), get_json_object(resp_raw_data, '$.platformAktif.JumlahPlatformAktif')) as bigint) as unique_active_loan_platform_cnt,
    coalesce(get_json_object(resp_raw_data, '$.platformAktif.platform'), get_json_object(resp_raw_data, '$.platformAktif.Platform')) as lst_active_loan_platform,
    date_format(format_time(create_time, 'ID'), 'yyyy-MM-dd') as grass_date
from risk.ods__credit_risk_datafetch_id_db__identity_data_history_tab__df
where grass_date = '${grass_date}'
and data_source_name in ('FDCData','FDCDataV5','FDCDataV5.2','FDCRealTimeDataV5.2')
and date_format(format_time(create_time, 'ID'), 'yyyy-MM-dd') >= date_sub('${grass_date}',30)
and date_format(format_time(create_time, 'ID'), 'yyyy-MM-dd') <= '${grass_date}';