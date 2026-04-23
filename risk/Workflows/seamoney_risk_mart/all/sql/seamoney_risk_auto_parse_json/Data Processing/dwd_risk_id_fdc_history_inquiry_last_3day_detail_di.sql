--drop table if exists risk.dwd_risk_id_fdc_history_inquiry_last_3day_detail_di;
create table if not exists risk.dwd_risk_id_fdc_history_inquiry_last_3day_detail_di (
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
    inquiry_time_last_3_days string,
    inquiry_data_last_3_days bigint,
    inquiry_platform_last_3_days string
)
PARTITIONED BY (grass_date STRING COMMENT 'grass_date, partition key')
STORED AS ORC
TBLPROPERTIES ("orc.compress" = "zstd")
LOCATION '${HDFS_PATH}/risk_mart/dwd_risk_id_fdc_history_inquiry_last_3day_detail_di/grass_region=ID';
--msck repair table risk.dwd_risk_id_fdc_history_inquiry_last_3day_detail_di;

ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
create or replace temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';
create or replace temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

INSERT OVERWRITE TABLE risk.dwd_risk_id_fdc_history_inquiry_last_3day_detail_di PARTITION (grass_date)
select
    concat_ws('_', ktp_req, create_timestamp) as fdc_report_id,
    create_timestamp as create_timestamp,
    flow_no as flow_no,
    cast(ktp_req as bigint) as ktp_req,
    cast(userid as bigint) as userid,
    cast(credit_userid as bigint) as credit_userid,
    trace_id as trace_id,
    data_source_name as data_source_name,
    inquiry_date as inquiry_date,
    status as status,
    coalesce(get_json_object(last3DaysInquiry, '$.tgl_inquiry'), get_json_object(last3DaysInquiry, '$.tglInquiry'), get_json_object(last3DaysInquiry, '$.TglInquiry')) as inquiry_time_last_3_days,
    cast(coalesce(get_json_object(last3DaysInquiry, '$.jml_data'), get_json_object(last3DaysInquiry, '$.jmlData'), get_json_object(last3DaysInquiry, '$.JmlData')) as bigint) as inquiry_data_last_3_days,
    coalesce(get_json_object(last3DaysInquiry, '$.hit_by'), get_json_object(last3DaysInquiry, '$.hitBy'), get_json_object(last3DaysInquiry, '$.HitBy')) as inquiry_platform_last_3_days,
    grass_date
from
(
    select
        unix_timestamp(to_utc_timestamp(create_time, 'GMT+7')) as create_timestamp,
        coalesce(get_json_object(header_data, '$.flow_no'), get_json_object(header_data, '$.flowNo'), get_json_object(header_data, '$.FlowNo')) as flow_no,
        coalesce(get_json_object(req_data, '$.identity_number'), get_json_object(req_data, '$.identityNumber'), get_json_object(req_data, '$.IdentityNumber'), get_json_object(req_data, '$.ktp'), get_json_object(req_data, '$.Ktp'), get_json_object(req_data, '$.KTP')) as ktp_req,
        coalesce(get_json_object(header_data, '$.platform_user_id'), get_json_object(header_data, '$.platformUserId'), get_json_object(header_data, '$.PlatformUserId')) as userid,
        coalesce(get_json_object(header_data, '$.credit_user_id'), get_json_object(header_data, '$.creditUserId'), get_json_object(header_data, '$.CreditUserId')) as credit_userid,
        trace_id as trace_id,
        data_source_name as data_source_name,
        coalesce(get_json_object(resp_raw_data, '$.data.inquiry_date'), get_json_object(resp_raw_data, '$.data.inquiryDate'), get_json_object(resp_raw_data, '$.data.InquiryDate'), get_json_object(resp_raw_data, '$.inquiry_date'), get_json_object(resp_raw_data, '$.inquiryDate'), get_json_object(resp_raw_data, '$.InquiryDate')) as inquiry_date,
        coalesce(get_json_object(resp_raw_data, '$.data.status'), get_json_object(resp_raw_data, '$.data.Status'), get_json_object(resp_raw_data, '$.status'), get_json_object(resp_raw_data, '$.Status')) as status,
        get_json_object(resp_raw_data, '$.historyInquiry.last3DaysInquiry') as last3DaysInquiry_list,
        date_format(format_time(create_time, 'ID'), 'yyyy-MM-dd') as grass_date
    from risk.ods__credit_risk_datafetch_id_db__identity_data_history_tab__df
    where grass_date = '${grass_date}'
    and data_source_name in ('FDCData','FDCDataV5','FDCDataV5.2','FDCRealTimeDataV5.2')
    and date_format(format_time(create_time, 'ID'), 'yyyy-MM-dd') >= date_sub('${grass_date}',30)
    and date_format(format_time(create_time, 'ID'), 'yyyy-MM-dd') <= '${grass_date}'
) t
lateral view outer explode(json_to_array(last3DaysInquiry_list)) tbl as last3DaysInquiry;