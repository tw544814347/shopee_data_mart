drop  table if exists risk.dwd_risk_br_uw_quod_income_base_info_pincome_df;
create external table if not exists risk.dwd_risk_br_uw_quod_income_base_info_pincome_df
(
platform_user_id                   string          comment 'platform_user_id'
,transaction_id                     string          comment 'transaction_id'
,cpf                                string          comment 'cpf'
,update_date                        string          comment 'update_date'
,presumed_income                    decimal(32,4)   comment 'presumed_income'
,positive_data                      string          comment 'positive_data'
,min_wage_range                     int             comment 'min_wage_range'
,min_wage_range_description         string          comment 'min_wage_range_description'
,income_range_value                 string          comment 'income_range_value'
,source_pk                          string          comment 'md5 concaT(trade_id, flow_no,flow_type)'
,create_time                        string          comment 'create_time'
)
partitioned by (grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/dwd/dwd_risk_br_uw_quod_income_base_info_pincome_df'