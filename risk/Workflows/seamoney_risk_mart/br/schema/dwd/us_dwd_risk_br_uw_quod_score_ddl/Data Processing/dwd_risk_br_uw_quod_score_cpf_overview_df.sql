drop  table if exists risk.dwd_risk_br_uw_quod_score_cpf_overview_df;
create external table if not exists risk.dwd_risk_br_uw_quod_score_cpf_overview_df
(
source_pk                          string            comment 'key_id'
,create_time                       string            comment 'create_time'
,platform_user_id                  string            comment 'platform_user_id'
,request_status                    string            comment 'request_status'
,query_id                          string            comment 'query_id'
,transaction_id                    string            comment 'transaction_id'
,cp_status                         int               comment 'Positive Registration Status'
,segment                           int               comment 'segment'    
,has_only_min_pii                  string            comment 'Indicates whether the CPF contains minimum data of the record' 
,has_negative_data                 string            comment 'has_negative_data'
,has_inquiry_data                  string            comment 'has_inquiry_data'
)
partitioned by (grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://D2/projects/risk/hdfs/prod/dwd/dwd_risk_br_uw_quod_score_cpf_overview_df'