-- 2024-09-18 新增3个指标(trace_id, userid, credit_userid) chenyingying
-- union all不能直接注释，last_3d_inquiry_list为空的时候，展开list后，list之外的其它列也取不到了

--DROP TABLE IF EXISTS ${SCHEMA}.dwd_risk_id_uw_fdc_history_inquiry_last_3day_detail_di;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dwd_risk_id_uw_fdc_history_inquiry_last_3day_detail_di
(
    trace_id        STRING
    ,userid         STRING
    ,credit_userid  STRING
    ,fdc_report_id  STRING
    ,flow_no        STRING
    ,ktp_req        STRING
    ,inquiry_date   STRING
    ,status         STRING
    ,inquiry_time_last_3_days       STRING
    ,inquiry_data_last_3_days       STRING
    ,inquiry_platform_last_3_days   STRING
    ,data_source_name               STRING
)
PARTITIONED BY (
    grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/risk_mart/dwd/dwd_risk_uw_fdc_history_inquiry_last_3day_detail_di/grass_region=ID';
--MSCK REPAIR TABLE ${SCHEMA}.dwd_risk_id_uw_fdc_history_inquiry_last_3day_detail_di;

create or replace temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';
create or replace temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

INSERT OVERWRITE TABLE ${SCHEMA}.dwd_risk_id_uw_fdc_history_inquiry_last_3day_detail_di PARTITION (grass_date)
select
    trace_id
    ,get_json_object(header_data, '$.PlatformUserId')                                    as userid
    ,get_json_object(header_data,'$.CreditUserId')                                       as credit_userid
    -- KTP 兼容
    ,case   when data_source_name = 'FDCData' then concat(get_json_object(req_data,'$.IdentityNumber'), '_', unix_timestamp(create_time))
            else concat(get_json_object(req_data,'$.KTP'), '_', unix_timestamp(create_time)) end as fdc_report_id
    ,get_json_object(header_data,'$.FlowNo')                         as flow_no
    -- KTP 兼容
    ,case   when data_source_name = 'FDCData' then get_json_object(req_data, '$.IdentityNumber')
            else get_json_object(req_data,'$.KTP') end as ktp_req
    ,coalesce(get_json_object(resp_raw_data,'$.inquiryDate'),get_json_object(resp_raw_data,'$.InquiryDate')) as inquiry_date
    ,coalesce(get_json_object(resp_raw_data,'$.status'),get_json_object(resp_raw_data,'$.Status')) as status
    ,null as inquiry_time_last_3_days
    ,null as inquiry_data_last_3_days
    ,null  as inquiry_platform_last_3_days
    ,data_source_name
    ,grass_date
from
(
    select
        trace_id                       as trace_id
        ,format_time(create_time, 'ID') as create_time
        ,date_format(format_time(create_time, 'ID'), 'yyyy-MM-dd') as grass_date
        ,get_json_object(resp_raw_data,'$.historyInquiry.last3DaysInquiry') as last_3d_inquiry_list
        ,header_data
        ,req_data
        ,resp_raw_data
        ,data_source_name
    from risk.ods__credit_risk_datafetch_id_db__identity_data_history_tab__df
    where grass_date = '${grass_date}'
    and data_source_name in('FDCData','FDCDataV5','FDCDataV5.2') 
    and date_format(format_time(create_time, 'ID'), 'yyyy-MM-dd') >= date_sub('${grass_date}',30)
    and date_format(format_time(create_time, 'ID'), 'yyyy-MM-dd') <= '${grass_date}'
    and coalesce(get_json_object(resp_raw_data,'$.historyInquiry.last3DaysInquiry'),'') in ('', '[]')
) t1 
union all
select
    trace_id                                                                             as trace_id
    ,get_json_object(header_data, '$.PlatformUserId')                                    as userid
    ,get_json_object(header_data,'$.CreditUserId')                                       as credit_userid
    -- KTP 兼容
    ,case   when data_source_name = 'FDCData' then concat(get_json_object(req_data,'$.IdentityNumber'), '_', unix_timestamp(create_time))
            else concat(get_json_object(req_data,'$.KTP'), '_', unix_timestamp(create_time)) end as fdc_report_id
    ,get_json_object(header_data,'$.FlowNo')                         as flow_no
    -- KTP 兼容
    ,case   when data_source_name = 'FDCData' then get_json_object(req_data, '$.IdentityNumber')
            else get_json_object(req_data,'$.KTP') end as ktp_req
    ,coalesce(get_json_object(resp_raw_data,'$.inquiryDate'),get_json_object(resp_raw_data,'$.InquiryDate')) as inquiry_date
    ,coalesce(get_json_object(resp_raw_data,'$.status'),get_json_object(resp_raw_data,'$.Status')) as status
    ,get_json_object(last_3d_inquiry,'$.tgl_inquiry') as inquiry_time_last_3_days
    ,get_json_object(last_3d_inquiry,'$.jml_data') as inquiry_data_last_3_days
    ,get_json_object(last_3d_inquiry,'$.hit_by') as inquiry_platform_last_3_days
    ,data_source_name
    ,grass_date
from
(
    select
        trace_id                       as trace_id
        ,format_time(create_time, 'ID') as create_time
        ,date_format(format_time(create_time, 'ID'), 'yyyy-MM-dd') as grass_date
        ,get_json_object(resp_raw_data,'$.historyInquiry.last3DaysInquiry') as last_3d_inquiry_list
        ,header_data
        ,req_data
        ,resp_raw_data
        ,data_source_name
    from risk.ods__credit_risk_datafetch_id_db__identity_data_history_tab__df
    where grass_date = '${grass_date}'
    and data_source_name in('FDCData','FDCDataV5','FDCDataV5.2') 
    and date_format(format_time(create_time, 'ID'), 'yyyy-MM-dd') >= date_sub('${grass_date}',30)
    and date_format(format_time(create_time, 'ID'), 'yyyy-MM-dd') <= '${grass_date}'
    and coalesce(get_json_object(resp_raw_data,'$.historyInquiry.last3DaysInquiry'),'') not in ('', '[]')
) t2
lateral view explode(json_to_array(last_3d_inquiry_list)) tbl as last_3d_inquiry
;