DROP TABLE IF EXISTS risk.dwd_risk_id_uw_cbi_user_base_info_df;
CREATE EXTERNAL TABLE IF NOT EXISTS risk.dwd_risk_id_uw_cbi_user_base_info_df
(
trace_id                    string comment 'trace_id'
,credit_user_id             string comment 'header_data.CreditUserId'
,platform_user_id           string comment 'header_data.PlatformUserId'
,flow_no                    string comment 'header_data.FlowNo'
,ktp_no                     string comment 'req_data.IdNumber'
,cbi_report_no              string comment 'resp_raw_data.SlikReports.{reference_number}'
,cbi_status                 string comment 'resp_raw_data.status'
,cbi_is_error               string comment 'resp_raw_data.error'
,report_update_time         string comment 'resp_raw_data.SlikReports.{reference_number}.result.BureauReport.ReportInfo.RINF_ReportDateTime'
,address                    string comment 'address'
,business_field_id          string comment 'business_field_id'
,business_field             string comment 'business_field'
,identity_id                string comment 'identity_id'
,gender_id                  string comment 'gender_id'
,gender                     string comment 'gender'
,city_id                    string comment 'city_id'
,city                       string comment 'city'
,district                   string comment 'district'
,village                    string comment 'village'
,degree_id                  string comment 'degree_id'
,degree                     string comment 'degree'
,zipcode                    string comment 'zipcode'
,name                       string comment 'name'
,country_id                 string comment 'country_id'
,country                    string comment 'country'
,identity_number            string comment 'identity_number'
,npwp                       string comment 'npwp'
,job_id                     string comment 'job_id'
,job                        string comment 'job'
)
PARTITIONED BY (
    grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_aio_uw_cbi_user_base_info_df/grass_region=ID';
MSCK REPAIR TABLE risk.dwd_risk_id_uw_cbi_user_base_info_df;
