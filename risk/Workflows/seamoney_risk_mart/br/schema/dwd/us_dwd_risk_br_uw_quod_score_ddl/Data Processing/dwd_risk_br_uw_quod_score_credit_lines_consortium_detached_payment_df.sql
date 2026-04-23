drop  table if exists risk.dwd_risk_br_uw_quod_score_credit_lines_consortium_detached_payment_df;
create external table if not exists risk.dwd_risk_br_uw_quod_score_credit_lines_consortium_detached_payment_df
(
 source_pk                          string            comment 'md5 concaT(trade_id, flow_no,flow_type)'
,platform_user_id                   string            comment 'platform_user_id'
,loan_id                            string            comment 'loan_id'
,payment_id                         string            comment 'Dev generate unique ID for each payment, each ID corresponds to one element in PreviousInstallment.Payments.Payment/DetachedPayment array'
,detached_payment_type              string            comment 'Type of Payment, null if the payment belongs to installment'
,paid_date                          string            comment 'Periodicity of future installment'
,paid_amount                        decimal(32,4)     comment 'Total balance amount of future installment'
,create_time                        string            comment 'create_timecreate_times'
)
partitioned by (grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://D2/projects/risk/hdfs/prod/dwd/dwd_risk_br_uw_quod_score_credit_lines_consortium_detached_payment_df'
;

