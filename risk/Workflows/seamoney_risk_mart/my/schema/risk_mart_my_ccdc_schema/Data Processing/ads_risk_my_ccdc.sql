drop  table if exists risk.ads_risk_my_ccdc_card;
create external table if not exists risk.ads_risk_my_ccdc_card
(
rowkey                          string            comment 'hbase rowkey'     
,value                          string            comment 'hbase value'
)
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ads/ads_risk_my_ccdc_card'
;

drop  table if exists risk.ads_risk_my_ccdc_bindtime;
create external table if not exists risk.ads_risk_my_ccdc_bindtime
(
rowkey                          string            comment 'hbase rowkey'     
,value                          string            comment 'hbase value'
)
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ads/ads_risk_my_ccdc_bindtime'
;

drop  table if exists risk.ads_risk_my_pre_ccdc_binduser_cnt;
create external table if not exists risk.ads_risk_my_pre_ccdc_binduser_cnt
(
rowkey                          string            comment 'hbase rowkey'     
,value                          string            comment 'hbase value'
)
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ads/ads_risk_my_pre_ccdc_binduser_cnt'
;

drop  table if exists risk.ads_risk_my_ccdc_binduser_cnt;
create external table if not exists risk.ads_risk_my_ccdc_binduser_cnt
(
rowkey                          string            comment 'hbase rowkey'     
,value                          string            comment 'hbase value'
)
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ads/ads_risk_my_ccdc_binduser_cnt'
;


