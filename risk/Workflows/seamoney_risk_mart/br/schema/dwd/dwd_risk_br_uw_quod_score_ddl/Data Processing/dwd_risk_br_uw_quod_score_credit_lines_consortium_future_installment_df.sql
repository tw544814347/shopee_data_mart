drop  table if exists risk.dwd_risk_br_uw_quod_score_credit_lines_consortium_future_installment_df;
create external table if not exists risk.dwd_risk_br_uw_quod_score_credit_lines_consortium_future_installment_df
(
 source_pk                          string            comment 'md5 concaT(trade_id, flow_no,flow_type)'
,platform_user_id                   string            comment 'platform_user_id'
,loan_id                            string            comment 'loan_id'
,installment_id                     string            comment 'Dev generate unique ID for each installment, each ID corresponds to one element in PreviousInstallment/FutureInstallment array'
,future_instal_due_date             string            comment 'Due date of future installment'
,future_instal_periodicity          string            comment 'Periodicity of future installment'
,future_instal_balance              decimal(32,4)     comment 'Total balance amount of future installment'
,remain_instal_cnt                  bigint            comment 'Count of contract installments due in the future'
,unpaid_instal_cnt                  bigint            comment 'Count of installments yet unpaid, including those with due in the future'
,create_time                        string            comment 'create_timecreate_times'
)
partitioned by (grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/dwd/dwd_risk_br_uw_quod_score_credit_lines_consortium_future_installment_df'
;
