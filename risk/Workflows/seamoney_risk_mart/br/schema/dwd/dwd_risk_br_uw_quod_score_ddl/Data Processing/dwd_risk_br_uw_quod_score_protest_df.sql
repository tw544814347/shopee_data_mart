drop  table if exists risk.dwd_risk_br_uw_quod_score_protest_df;
create external table if not exists risk.dwd_risk_br_uw_quod_score_protest_df
(
source_pk                          string            comment 'key_id'
,create_time                       string            comment 'create_time'
,platform_user_id                  string            comment 'platform_user_id'
,date_query                        string            comment 'Query Date YYYY-MM-DD'
,return                            string            comment 'successful return indicator'
,error                             string            comment 'Error indicator'
,error_description                 string            comment 'Description and the number of Notary Office found in the Protests'
,situation                         string            comment 'Protest Status'
,total_protest_value               decimal(32,4)     comment 'Sum of all protest values '
,conteudo                          string            comment 'conteudo'
)
partitioned by (grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/dwd/dwd_risk_br_uw_quod_score_protest_df'