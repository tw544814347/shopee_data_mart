drop  table if exists risk.dwd_risk_br_uw_risk_trade_df;
create external table if not exists risk.dwd_risk_br_uw_risk_trade_df
(
source_pk                            string            comment 'hase CONCAT(trade_id, flow_no,flow_type)'     
,cpf                                 string            comment 'QuodReportResponseEx.Response.Records.Record[0].BestInfo.CPF'
,trade_id                            string            comment 'trade_id'
,flow_no                             string            comment 'flow_no'
,flow_type                           string            comment 'flow_type'
,app_id                              string            comment 'app_id'
,scene_id                            string            comment 'scene_id'
,platform_user_id                    string            comment 'platform_user_id'
,rsp                                 string            comment 'rsp'
,create_time                         string            comment 'create_time'
)
partitioned by (grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/dwd/dwd_risk_br_uw_risk_trade_df'