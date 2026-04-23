drop table if exists ${SCHEMA}.check_real_loan_amount_history;
create table if not exists ${SCHEMA}.check_real_loan_amount_history
(
    flow_no                           string
    ,req_time                         bigint
    ,loan_amount                      bigint
    ,real_loan_amount                 bigint
    ,combine_payment_amount           bigint
    ,real_combine_payment_amount      bigint
    ,order_amount                     bigint
    ,real_order_amount                bigint
    ,transaction_type                 string
    ,decimal_base                     bigint
    ,loan_amount_diff                 int
    ,combine_payment_amount_diff      int
    ,order_amount_diff                int
)
partitioned by
(
    grass_region         string          comment         'region'
    ,app_id              string          comment         'app_id'
    ,scene_id            string          comment         'scene_id'
    ,dt                  string          comment         'partition key, yyyy-MM-dd'
)
stored as parquet;
msck repair table ${SCHEMA}.check_real_loan_amount_history;