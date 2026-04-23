drop  table if exists risk.dwd_risk_br_uw_quod_score_negative_ccfnotes_df;
create external table if not exists risk.dwd_risk_br_uw_quod_score_negative_ccfnotes_df
(
source_pk                          string            comment 'key_id'
,cpf                               string            comment 'cpf'
,create_time                       string            comment 'create_time'
,platform_user_id                  string            comment 'platform_user_id'
,entity_type                       string            comment 'entity_type'
,cpf_cnpj                          string            comment 'cpf_cnpj'
,reporting_bank_code               string            comment 'reporting_bank_code'
,reporting_branch_prefix           string            comment 'reporting_branch_prefix'
,reason_bounce                     string            comment 'reason_bounce '
,bounce_count                      string            comment 'bounce_count'
,date_last_bounce                  string            comment 'date_last_bounce'
)
partitioned by (grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/dwd/dwd_risk_br_uw_quod_score_negative_ccfnotes_df'
;