drop  table if exists risk.dwd_risk_br_uw_quod_score_enterprises_df;
create external table if not exists risk.dwd_risk_br_uw_quod_score_enterprises_df
(
source_pk                          string            comment 'key_id'
,cpf                               string            comment 'cpf'
,create_time                       string            comment 'create_time'
,platform_user_id                  string            comment 'platform_user_id'
,entity_type                       string            comment 'entity_type'
,cnpj_number                       string            comment 'cnpj_number'
,company_name                      string            comment 'company_name'
,company_status                    string            comment 'company_status'
,percent_participation             decimal(32,2)     comment 'percent_participation'
,participation_value               decimal(32,2)     comment 'participation_value'
,relationship_description          string            comment 'relationship_description'
,date_start_partner                string            comment 'date_start_partner'
,date_start                        string            comment 'date_start'
,date_end                          string            comment 'date_end'
,flag_main_job                     string            comment 'flag_main_job'
,date_reference                    string            comment 'date_reference'
)
partitioned by (grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/dwd/dwd_risk_br_uw_quod_score_enterprises_df'