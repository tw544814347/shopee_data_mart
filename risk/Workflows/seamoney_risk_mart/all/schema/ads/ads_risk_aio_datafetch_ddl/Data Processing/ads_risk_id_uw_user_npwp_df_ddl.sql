drop  table if exists risk.ads_risk_${region}_uw_user_npwp_df;
create external table if not exists risk.ads_risk_${region}_uw_user_npwp_df
(
tax_status                  string comment 'tax_status'
,platform_user_id           string comment 'platform_user_id'
,credit_user_id             string comment 'credit_user_id'
,id_card_no                 string comment 'id_card_no'
,tax_taxpayer_status        string comment 'tax_taxpayer_status'
,if_profile_match           string comment 'if_profile_match'
,tax_taxpayer_id            string comment 'tax_taxpayer_id'
,tax_result                 string comment 'tax_result'
,tax_result_code            string comment 'tax_result_code'
,latest_inquiry_date        string comment 'latest_inquiry_date'
,data_source_name           string comment 'data_source'
,ktp_req                    string comment 'req_data.KTP'
)
partitioned by (
    grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
LOCATION '${HDFS_PATH}/risk_mart/ads/ads_risk_aio_uw_user_npwp_df/grass_region=${upper_region}';

msck repair table risk.ads_risk_${region}_uw_user_npwp_df;