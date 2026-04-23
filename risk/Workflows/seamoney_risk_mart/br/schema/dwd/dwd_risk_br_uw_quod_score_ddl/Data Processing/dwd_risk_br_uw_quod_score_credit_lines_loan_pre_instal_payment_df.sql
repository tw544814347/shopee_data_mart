drop  table if exists risk.dwd_risk_br_uw_quod_score_credit_lines_loan_pre_instal_payment_df;
create external table if not exists risk.dwd_risk_br_uw_quod_score_credit_lines_loan_pre_instal_payment_df
(
 source_pk                          string            comment 'md5 concaT(trade_id, flow_no,flow_type)'
,platform_user_id                   string            comment 'platform_user_id'
,loan_id                            string            comment 'loan_id'
,installment_id                     string            comment 'Dev generate unique ID for each installment, each ID corresponds to one element in PreviousInstallment/FutureInstallment array'
,payment_id                         string            comment 'Dev generate unique ID for each payment, each ID corresponds to one element in PreviousInstallment.Payments.Payment/DetachedPayment array'
,paid_date                          string            comment 'paid_date'
,paid_amount                        decimal(32,4)     comment 'paid_amount'
,create_time                        string            comment 'create_timecreate_times'
)
partitioned by (grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/dwd/dwd_risk_br_uw_quod_score_credit_lines_loan_pre_instal_payment_df'
;

drop  table if exists risk.dwd_risk_br_uw_quod_score_credit_lines_loan_pre_instal_payment_df;
