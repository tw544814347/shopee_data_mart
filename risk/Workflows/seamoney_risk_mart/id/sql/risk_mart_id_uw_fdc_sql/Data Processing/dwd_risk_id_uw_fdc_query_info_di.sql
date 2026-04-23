-- 2024-09-26 chenyingying FDCData的KTP标识关键词为IdentityNumber，不是KTP, 已确认
--DROP TABLE IF EXISTS ${SCHEMA}.dwd_risk_id_uw_fdc_query_info_di;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dwd_risk_id_uw_fdc_query_info_di
(
    trace_id          STRING 
    ,userid           STRING
    ,credit_userid     STRING
    ,ktp_inquiry_time  STRING
    ,ktp_number       STRING
    ,inquiry_by       STRING
    ,inquiry_name     STRING
    ,member_id        STRING
    ,member_name      STRING
    ,inquiry_date     STRING
    ,status           STRING
    ,flow_no          STRING
    ,ktp_req          STRING
    ,fdc_report_id    STRING
)
PARTITIONED BY (
    grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/risk_mart/dwd/dwd_risk_id_uw_fdc_query_info_di/grass_region=ID';
--MSCK REPAIR TABLE ${SCHEMA}.dwd_risk_id_uw_fdc_query_info_di;

create or replace temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

INSERT OVERWRITE TABLE ${SCHEMA}.dwd_risk_id_uw_fdc_query_info_di PARTITION (grass_date)
select trace_id
    ,get_json_object(header_data,'$.PlatformUserId')    as userid
    ,get_json_object(header_data,'$.CreditUserId')    as credit_userid
    ,concat(get_json_object(resp_raw_data,'$.data.NoIdentitas'),format_time(create_time, 'ID')) as ktp_inquiry_time
    ,get_json_object(resp_raw_data,'$.data.NoIdentitas') as ktp_number
    ,get_json_object(resp_raw_data,'$.InquiryBy')   as inquiry_by
    ,get_json_object(resp_raw_data,'$.InquiryName') as inquiry_name
    ,coalesce(get_json_object(resp_raw_data,'$.memberId'),get_json_object(resp_raw_data,'$.MemberId'))    as member_id
    ,coalesce(get_json_object(resp_raw_data,'$.memberName'),get_json_object(resp_raw_data,'$.MemberName'))    as member_name
    ,coalesce(get_json_object(resp_raw_data,'$.inquiryDate'),get_json_object(resp_raw_data,'$.InquiryDate')) as inquiry_date
    ,coalesce(get_json_object(resp_raw_data,'$.status'),get_json_object(resp_raw_data,'$.Status'))      as status
    ,get_json_object(header_data,'$.FlowNo')             as flow_no
    -- KTP 标识符兼容
    ,case when data_source_name = 'FDCData' then get_json_object(req_data, '$.IdentityNumber')
    else    get_json_object(req_data,'$.KTP') end                  as ktp_req
    ,case when data_source_name = 'FDCData' then concat(get_json_object(req_data, '$.IdentityNumber'), '_', unix_timestamp(format_time(create_time, 'ID')))
    else concat(get_json_object(req_data,'$.KTP'), '_', unix_timestamp(format_time(create_time, 'ID'))) end as fdc_report_id
    ,date_format(format_time(create_time, 'ID'), 'yyyy-MM-dd') as grass_date
from risk.ods__credit_risk_datafetch_id_db__identity_data_history_tab__df
where grass_date = '${grass_date}'
and data_source_name in ('FDCDataV5','FDCData', 'FDCDataV5.2')
and date_format(format_time(create_time, 'ID'), 'yyyy-MM-dd') >= date_sub('${grass_date}',30)
and date_format(format_time(create_time, 'ID'), 'yyyy-MM-dd') <= '${grass_date}'
;