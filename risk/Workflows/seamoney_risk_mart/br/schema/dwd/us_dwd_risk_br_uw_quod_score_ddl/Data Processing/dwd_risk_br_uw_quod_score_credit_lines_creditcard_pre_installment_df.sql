drop  table if exists risk.dwd_risk_br_uw_quod_score_credit_lines_creditcard_pre_installment_df;
create external table if not exists risk.dwd_risk_br_uw_quod_score_credit_lines_creditcard_pre_installment_df
(
 source_pk                          string            comment 'md5 concaT(trade_id, flow_no,flow_type)'
,platform_user_id                   string            comment 'platform_user_id'
,loan_id                            string            comment 'loan_id'
,installment_id                     string            comment 'Dev generate unique ID for each installment, each ID corresponds to one element in PreviousInstallment/FutureInstallment array'
,pre_instal_due_date                string            comment 'Due date of previous installment, null if it is detached payment'
,pre_instal_balance                 decimal(32,4)     comment 'Balance amount of previous installment, null if it is detached payment'
,pre_instal_min_payment             decimal(32,4)     comment 'Minimum payment amount of previous installment'
,pre_instal_payment_status          string            comment 'Payment status of previous installment, null if it is detached payment'
,create_time                        string            comment 'create_timecreate_times'
,payment                            string            comment 'Payment'  
)
partitioned by (grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://D2/projects/risk/hdfs/prod/dwd/dwd_risk_br_uw_quod_score_credit_lines_creditcard_pre_installment_df'
;