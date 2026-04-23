drop  table if exists risk.dwd_risk_${region}_uw_user_bpjs_df;
create external table if not exists risk.dwd_risk_${region}_uw_user_bpjs_df
(
platform_user_id         string comment 'platform_user_id'
,credit_user_id          string comment 'credit_user_id'
,income_status           string comment 'income_status'
,name_check              string comment 'name_check'
,nik_check               string comment 'nik_check'
,gender                  string comment 'gender'
,company_address         string comment 'company_address'
,phone_no                string comment 'phone_no'
,company_name            string comment 'company_name'
,income_mask             string comment 'income_mask'
,income_unmask           bigint comment 'income_unmask'
,income_range            string comment 'income_range'
,latest_salary_month     string comment 'latest_salary_month'
,registration_date       string comment 'registration_date'
,account_status          string comment 'account_status'
,latest_inquiry_date     string comment 'latest_inquiry_date'
,data_source_name        string comment 'data_source'
,ktp_req                 string comment 'req_data.KTP'
)
partitioned by (
    grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_aio_uw_user_bpjs_df/grass_region=${upper_region}';

msck repair table risk.dwd_risk_${region}_uw_user_bpjs_df;