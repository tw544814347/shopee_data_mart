DROP TABLE IF EXISTS risk.dwd_risk_id_uw_cbi_fasility_collateral_info_df;
CREATE EXTERNAL TABLE IF NOT EXISTS risk.dwd_risk_id_uw_cbi_fasility_collateral_info_df
(
trace_id                                       string comment 'trace_id'
,credit_user_id                                string comment 'credit_user_id'
,platform_user_id                              string comment 'platform_user_id'
,flow_no                                       string comment 'flow_no'
,ktp_no                                        string comment 'ktp_no'
,cbi_report_no                                 string comment 'cbi_report_no'
,cbi_status                                    string comment 'cbi_status'
,cbi_is_error                                  string comment 'cbi_is_error'
,report_update_time                            string comment 'report_update_time'
,initial_contract_no                           string comment 'initial_contract_no'
,collateral_type                               string comment 'collateral_type'
,binding_type                                  string comment 'binding_type'
,name_of_the_collateral_owner                  string comment 'name_of_the_collateral_owner'
,collateral_value_by_independent_appraiser     string comment 'collateral_value_by_independent_appraiser'
,collateral_value_by_ljk                       string comment 'collateral_value_by_LJK'
,collateral_value_njop                         string comment 'collateral_value_NJOP'
,register_code                                 string comment 'register_code'
,percentage_of_paripasu                        string comment 'percentage_of_paripasu'
)
PARTITIONED BY (
    grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_aio_uw_cbi_fasility_collateral_info_df/grass_region=ID';
MSCK REPAIR TABLE risk.dwd_risk_id_uw_cbi_fasility_collateral_info_df;
