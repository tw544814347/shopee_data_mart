drop  table if exists risk.dwd_risk_br_uw_quod_score_negative_annotation_df;
create external table if not exists risk.dwd_risk_br_uw_quod_score_negative_annotation_df
(
source_pk                          string            comment 'key_id'
,cpf                               string            comment 'cpf'
,create_time                       string            comment 'create_time'
,platform_user_id                  string            comment 'platform_user_id'
,date_latest_annotation            string            comment 'date_latest_annotation '
,pendencies_control_cred           decimal(32,2)     comment 'pendencies_control_cred'
,annotation_company_cnpj           string            comment 'annotation_company_cnpj'
,annotation_company_name           string            comment 'annotation_company_name'
,annotation_amount                 decimal(32,2)     comment 'annotation_amount'
,annotation_nature                 string            comment 'annotation_nature'
,contract_number                   string            comment 'contract_number'
,participant_type                  string            comment 'participant_type'
,apontamento_status                string            comment 'apontamento_status'
,date_occurred                     string            comment 'date_occurred'
,date_included                     string            comment 'date_included'
,date_modified                     string            comment 'date_modified'
,address_city                      string            comment 'address_city'
,address_state                     string            comment 'address_state'
)
partitioned by (grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/dwd/dwd_risk_br_uw_quod_score_negative_annotation_df'