DROP TABLE IF EXISTS risk.dwd_risk_id_uw_cbi_base_info_df;
CREATE EXTERNAL TABLE IF NOT EXISTS risk.dwd_risk_id_uw_cbi_base_info_df
(
trace_id                    string comment 'trace_id'
,credit_user_id             string comment 'header_data.CreditUserId'
,platform_user_id           string comment 'header_data.PlatformUserId'
,flow_no                    string comment 'header_data.FlowNo'
,ktp_no                     string comment 'req_data.IdNumber'
,cbi_status                 string comment 'resp_raw_data.status'
,cbi_is_error               string comment 'resp_raw_data.error'
,cbi_report_no              string comment 'resp_raw_data.SlikReports.{reference_number}'
,report_update_time         string comment 'resp_raw_data.SlikReports.{reference_number}.result.BureauReport.ReportInfo.RINF_ReportDateTime'
,report_error               string comment 'resp_raw_data.SlikReports.{reference_number}.error'
,report_status              string comment 'resp_raw_data.SlikReports.{reference_number}.status'
,slik_report                string comment 'resp_raw_data.SlikReports.{reference_number}.SlikReports'
)
PARTITIONED BY (
    grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_aio_uw_cbi_base_info_df/grass_region=ID';
MSCK REPAIR TABLE risk.dwd_risk_id_uw_cbi_base_info_df;
