drop  table if exists risk.dwd_risk_br_uw_quod_score_base_info_inquiry_df;
create external table if not exists risk.dwd_risk_br_uw_quod_score_base_info_inquiry_df
(
 source_pk                          string            comment 'md5 concaT(trade_id, flow_no,flow_type)'
,platform_user_id                   string            comment 'platform_user_id'
,inquiry_date                       string            comment 'inquiry_date'
,inquiry_cnt                        int               comment 'inquiry_cnt'
,segment                            string            comment 'segment'
,create_time                        string          comment 'create_time'
)
partitioned by (grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/dwd/dwd_risk_br_uw_quod_score_base_info_inquiry_df'