drop  table if exists risk.dwd_risk_br_uw_quod_score_credit_lines_revolving_df;
create external table if not exists risk.dwd_risk_br_uw_quod_score_credit_lines_revolving_df
(
 source_pk                          string            comment 'md5 concaT(trade_id, flow_no,flow_type)'
,platform_user_id                   string            comment 'platform_user_id'
,loan_id                            string            comment 'loan_id'
,loan_institution_cnt               bigint            comment 'Unique Institution Count in which the CPF consulted has loan contracts'
,revolving_institution_cnt          bigint            comment 'Unique Institution Count in the which the CPF consulted has revolving contracts'
,cc_institution_cnt                 bigint            comment 'Unique Institution Count in which the CPF consulted has credit card contracts'
,consortium_institution_cnt         bigint            comment 'Unique Institution Count in which the CPF consulted has consortium contracts'
,total_institution_cnt              bigint            comment 'Total count of unique institutions has contracts'
,relationship_nature                int               comment 'relationship_nature'
,contract_type                      string            comment 'contract_type'
,reference_date                     string            comment 'Date of last update on quod side'
,contract_date                      string            comment 'Date of contracting'
,contract_exp_date                  string            comment 'Contract expiration date'
,total_used_amt                     decimal(32,4)     comment 'Total used of revolving'
,future_instal_closing_date         string            comment 'Closing date of future installment'
,future_instal_used_amt             decimal(32,4)     comment 'Used amount of future installment'
,create_time                        string            comment 'create_time'
,previous_installment               string            comment 'PreviousInstallments'
)
partitioned by (grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://D2/projects/risk/hdfs/prod/dwd/dwd_risk_br_uw_quod_score_credit_lines_revolving_df'
;
