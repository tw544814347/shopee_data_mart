drop  table if exists risk.dws_risk_${region}_uw_user_bpjs_tongdun_income_conso_df;
create external table if not exists risk.dws_risk_${region}_uw_user_bpjs_tongdun_income_conso_df
(
platform_user_id         string comment 'platform_user_id'
,credit_user_id          string comment 'credit_user_id'
,income_status           string comment 'income_status'
,company_name            string comment 'company_name'
,company_address         string comment 'compnay_address'
,registration_date       string comment 'registration_date'
,latest_salary_month     string comment 'latest_salary_month'
,salary_range            string comment 'salary_range'
,salary_unmask           string comment 'salary_unmask'
,latest_inquiry_date     string comment 'latest_inquirt_date'
,data_source_name        string comment 'data_source'
,ktp_req                 string comment 'req_data.KTP'
)
partitioned by (
    grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_aio_uw_user_bpjs_tongdun_income_conso_df/grass_region=${upper_region}';

msck repair table risk.dws_risk_${region}_uw_user_bpjs_tongdun_income_conso_df;