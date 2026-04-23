drop  table if exists risk.dwd_risk_br_uw_quod_score_negative_lawsuit_df;
create external table if not exists risk.dwd_risk_br_uw_quod_score_negative_lawsuit_df
(
source_pk                          string            comment 'key_id'
,cpf                               string            comment 'cpf'
,create_time                       string            comment 'create_time'
,platform_user_id                  string            comment 'platform_user_id'
,process_number                    string            comment 'process_number'
,protocol_number                   string            comment 'protocol_number'
,comarca                           string            comment 'comarca'
,forum                             string            comment 'forum'
,vara                              string            comment 'vara '
,process_author                    string            comment 'process_author'
,name                              string            comment 'name'
,date_of_distribution              string            comment 'date_of_distribution'
,process_type                      string            comment 'process_type'
,current_status                    string            comment 'current_status'
,lawsuit_amount                    decimal(32,2)     comment 'lawsuit_amount'
,city                              string            comment 'city'
,state                             string            comment 'state'
,justice_type                      string            comment 'justice_type' 
,entity_type                       string            comment 'entity_type' 
,cpf_cnpj                          string            comment 'cpf_cnpj' 
,similarity_index                  string            comment 'similarity_index'
,id_confidence                     string            comment 'id_confidence'
,register_id                       string            comment 'register_id'
,register_type                     string            comment 'register_type'
,origin_source                     string            comment 'origin_source'
,date_processed                    string            comment 'date_processed'
)
partitioned by (grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/dwd/dwd_risk_br_uw_quod_score_negative_lawsuit_df'