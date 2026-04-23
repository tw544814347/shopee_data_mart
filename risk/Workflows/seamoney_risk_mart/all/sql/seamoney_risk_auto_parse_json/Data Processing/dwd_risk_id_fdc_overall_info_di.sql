--drop table if exists risk.dwd_risk_id_fdc_overall_info_di;
create table if not exists risk.dwd_risk_id_fdc_overall_info_di (
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
    inquiry_reason string,
    member_id string,
    member_name string,
    app_id string,
    scene_id string,
    unique_active_loan_platform_cnt bigint,
    total_unique_inquiry_over_360days bigint
)
PARTITIONED BY (grass_date STRING COMMENT 'grass_date, partition key')
STORED AS ORC
TBLPROPERTIES ("orc.compress" = "zstd")
LOCATION '${HDFS_PATH}/risk_mart/dwd_risk_id_fdc_overall_info_di/grass_region=ID';
--msck repair table risk.dwd_risk_id_fdc_overall_info_di;

ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
create or replace temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

INSERT OVERWRITE TABLE risk.dwd_risk_id_fdc_overall_info_di PARTITION (grass_date)
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
    coalesce(get_json_object(resp_raw_data, '$.data.inquiry_reason'), get_json_object(resp_raw_data, '$.data.inquiryReason'), get_json_object(resp_raw_data, '$.data.InquiryReason'), get_json_object(resp_raw_data, '$.inquiry_reason'), get_json_object(resp_raw_data, '$.inquiryReason'), get_json_object(resp_raw_data, '$.InquiryReason')) as inquiry_reason,
    coalesce(get_json_object(resp_raw_data, '$.data.member_id'), get_json_object(resp_raw_data, '$.data.memberId'), get_json_object(resp_raw_data, '$.data.MemberId'), get_json_object(resp_raw_data, '$.member_id'), get_json_object(resp_raw_data, '$.memberId'), get_json_object(resp_raw_data, '$.MemberId')) as member_id,
    coalesce(get_json_object(resp_raw_data, '$.data.member_name'), get_json_object(resp_raw_data, '$.data.memberName'), get_json_object(resp_raw_data, '$.data.MemberName'), get_json_object(resp_raw_data, '$.member_name'), get_json_object(resp_raw_data, '$.memberName'), get_json_object(resp_raw_data, '$.MemberName')) as member_name,
    coalesce(get_json_object(header_data, '$.app_id'), get_json_object(header_data, '$.appId'), get_json_object(header_data, '$.AppId')) as app_id,
    coalesce(get_json_object(header_data, '$.scene_id'), get_json_object(header_data, '$.sceneId'), get_json_object(header_data, '$.SceneId')) as scene_id,
    cast(coalesce(get_json_object(resp_raw_data, '$.platformAktif.jumlah_platform_aktif'), get_json_object(resp_raw_data, '$.platformAktif.jumlahPlatformAktif'), get_json_object(resp_raw_data, '$.platformAktif.JumlahPlatformAktif')) as bigint) as unique_active_loan_platform_cnt,
    cast(coalesce(get_json_object(resp_raw_data, '$.historyInquiry.statistic.>360_hari'), get_json_object(resp_raw_data, '$.historyInquiry.statistic.>360Hari')) as bigint) as total_unique_inquiry_over_360days,
    date_format(format_time(create_time, 'ID'), 'yyyy-MM-dd') as grass_date
from risk.ods__credit_risk_datafetch_id_db__identity_data_history_tab__df
where grass_date = '${grass_date}'
and data_source_name in ('FDCData','FDCDataV5','FDCDataV5.2','FDCRealTimeDataV5.2')
and date_format(format_time(create_time, 'ID'), 'yyyy-MM-dd') >= date_sub('${grass_date}',30)
and date_format(format_time(create_time, 'ID'), 'yyyy-MM-dd') <= '${grass_date}';