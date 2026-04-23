drop  table if exists risk.dwd_risk_br_uw_quod_score_protest_content_registry_df;
create external table if not exists risk.dwd_risk_br_uw_quod_score_protest_content_registry_df
(
source_pk                          string            comment 'key_id'
,create_time                       string            comment 'create_time'
,platform_user_id                  string            comment 'platform_user_id'
,city_code                         bigint            comment 'city_code'
,notary_code                       bigint            comment 'notary_code'
,notary_name                       string            comment 'notary_name'
,notary_phone                      string            comment 'notary_phone'
,notary_address                    string            comment 'notary_address'
,notary_city                       string            comment 'notary_city'
,no_of_protests                    int               comment 'Number of protests in the registry'
,value_of_protests                 decimal(32,4)     comment 'Monetary value of protests in the registry'
)
partitioned by (grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/dwd/dwd_risk_br_uw_quod_score_protest_content_registry_df'