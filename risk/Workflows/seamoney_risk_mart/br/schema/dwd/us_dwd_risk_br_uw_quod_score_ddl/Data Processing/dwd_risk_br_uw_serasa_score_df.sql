drop  table if exists risk.dwd_risk_br_uw_serasa_score_df;
create external table if not exists risk.dwd_risk_br_uw_serasa_score_df
(
platform_user_id  string            comment 'platform_user_id'
,document_number      string            comment 'registration.documentNumber'
,score            bigint            comment '0-300: high risk of default 300-700: med risk>700: low risk reports[0].score.score'
,score_model      string            comment 'HSPN: Serasa Score with Positive HFIN: Serasa Score Fintech reports[0].score.scoreModel'
,range            string            comment 'A: best score range	reports[0].score.rang'
,default_rate     decimal(32,4)     comment 'probability of default, 0-100 reports[0].score.defaultRate'
,code_message     bigint            comment '99: normal 43: Score inhibited by the holder of the document consulted500: server error reports[0].score.codeMessage'
,message          string            comment 'reports[0].score.message'   
)
partitioned by (grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://D2/projects/risk/hdfs/prod/risk_mart/dwd/dwd_risk_br_uw_serasa_score_df'
;

msck repair table risk.dwd_risk_br_uw_serasa_score_df;