drop  table if exists risk.dwd_risk_br_uw_quod_score_credit_lines_loan_df;
create external table if not exists risk.dwd_risk_br_uw_quod_score_credit_lines_loan_df
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
,current_loan_amt                   decimal(32,4)     comment 'Current total loan amount'
,current_dpd_0_amt                  decimal(32,4)     comment 'Current amount overdue and not paid during 0-15 days'
,current_dpd_15_amt                 decimal(32,4)     comment 'Current amount overdue and not paid during 16-30 days'
,current_dpd_30_amt                 decimal(32,4)     comment 'Current amount overdue and not paid during 31-60 days'
,current_dpd_60_amt                 decimal(32,4)     comment 'Current amount overdue and not paid during 61-90 days'
,current_dpd_90_amt                 decimal(32,4)     comment 'Current amount overdue and not paid during 90+ days'
,current_due_0_amt                  decimal(32,4)     comment 'Current amount to be due'
,current_due_15_amt                 decimal(32,4)     comment 'current_due_15_amt'
,current_due_30_amt                 decimal(32,4)     comment 'current_due_30_amt'
,current_due_60_amt                 decimal(32,4)     comment 'current_due_60_amt'
,current_due_90_amt                 decimal(32,4)     comment 'current_due_90_amt'
,contract_amt                       decimal(32,4)     comment 'Total contract value '
,total_instal_cnt                   int               comment 'Total installments established in contract'
,previous_installment               string            comment 'PreviousInstallments'
,create_time                        string            comment 'create_time'
,future_installment                 string            comment 'FutureInstallments'
,detached_payment                   string            comment 'DetachedPayments'
)
partitioned by (grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/dwd/dwd_risk_br_uw_quod_score_credit_lines_loan_df'
;

drop  table if exists risk.dwd_risk_br_uw_quod_score_credit_lines_loan_df;
