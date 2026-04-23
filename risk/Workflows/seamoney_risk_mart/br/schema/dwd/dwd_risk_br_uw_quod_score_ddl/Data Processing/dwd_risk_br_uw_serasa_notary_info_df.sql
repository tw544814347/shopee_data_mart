drop  table if exists risk.dwd_risk_br_uw_serasa_notary_info_df;
create external table if not exists risk.dwd_risk_br_uw_serasa_notary_info_df
(
platform_user_id      string            comment 'platform_user_id'
,loan_id              string            comment 'Dev generate unique ID for each loan, each ID corresponds to one element in pefin array  MD5 CONCAT(occurrence_date, contractor_id)'
,occurrence_date      string            comment 'reports[0].negativeData.notary.notaryResponse[0].occurrenceDate'
,amount               decimal(32,4)     comment 'reports[0].negativeData.notary.notaryResponse[0].amount'
,office_number        string            comment 'reports[0].negativeData.notary.notaryResponse[0].officeNumber'
,office_name          string            comment 'reports[0].negativeData.notary.notaryResponse[0].officeName'
,city                 string            comment 'reports[0].negativeData.notary.notaryResponse[0].city'     
,federal_unit         string            comment 'reports[0].negativeData.notary.notaryResponse[0].federalUnit'     
)
partitioned by (grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/risk_mart/dwd/dwd_risk_br_uw_serasa_notary_info_df'
;