drop  table if exists risk.dwd_risk_br_uw_quod_score_base_info_history_address_df;
create external table if not exists risk.dwd_risk_br_uw_quod_score_base_info_history_address_df
(
 source_pk                          string            comment 'md5 concaT(trade_id, flow_no,flow_type)'
,platform_user_id                   string            comment 'platform_user_id'
,address_street                     string            comment 'address_street'
,address_number                     string            comment 'address_number'
,address_complement                 string            comment 'address_complement'
,address_neighborhood               string            comment 'address_neighborhood'
,address_city                       string            comment 'address_city'
,address_state                      string            comment 'address_state'
,address_postal_code                string            comment 'address_postal_code'
,address_update_date                string            comment 'address_update_date'
,create_time                        string          comment 'create_time'
)
partitioned by (grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/dwd/dwd_risk_br_uw_quod_score_base_info_history_address_df'