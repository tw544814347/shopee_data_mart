drop  table if exists risk.ads_risk_id_ccdc_card_apm;
create external table if not exists risk.ads_risk_id_ccdc_card_apm
(
rowkey                          string            comment 'hbase rowkey'     
,value                          string            comment 'hbase value'
)
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ads/ads_risk_id_ccdc_card_apm'
;

drop  table if exists risk.ads_risk_id_ccdc_bindtime_apm;
create external table if not exists risk.ads_risk_id_ccdc_bindtime_apm
(
rowkey                          string            comment 'hbase rowkey'     
,value                          string            comment 'hbase value'
)
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ads/ads_risk_id_ccdc_bindtime_apm'
;

drop  table if exists risk.ads_risk_id_pre_ccdc_binduser_cnt_apm;
create external table if not exists risk.ads_risk_id_pre_ccdc_binduser_cnt_apm
(
rowkey                          string            comment 'hbase rowkey'     
,value                          string            comment 'hbase value'
)
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ads/ads_risk_id_pre_ccdc_binduser_cnt_apm'
;

drop  table if exists risk.ads_risk_id_ccdc_binduser_cnt_apm;
create external table if not exists risk.ads_risk_id_ccdc_binduser_cnt_apm
(
rowkey                          string            comment 'hbase rowkey'     
,value                          string            comment 'hbase value'
)
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ads/ads_risk_id_ccdc_binduser_cnt_apm'
;