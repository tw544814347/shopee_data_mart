drop  table if exists risk.dwd_risk_br_uw_serasa_refin_info_df;
create external table if not exists risk.dwd_risk_br_uw_serasa_refin_info_df
(
platform_user_id      string            comment 'platform_user_id'
,document_number      string            comment 'registration.documentNumber'
,loan_id              string            comment 'Dev generate unique ID for each loan, each ID corresponds to one element in pefin array  MD5 CONCAT(occurrence_date, contractor_id)'
,occurrence_date      string            comment 'reports[0].negativeData.refin.refinResponse[0].occurrenceDate'
,legal_nature_id      string            comment 'reports[0].negativeData.refin.refinResponse[0].legalNatureId'
,legal_nature         string            comment 'reports[0].negativeData.refin.refinResponse[0].legalNature'
,contractor_id        string            comment 'reports[0].negativeData.refin.refinResponse[0].contractId'
,creditor_name        string            comment 'reports[0].negativeData.refin.refinResponse[0].creditorName'
,amount               decimal(32,4)     comment 'reports[0].negativeData.refin.refinResponse[0].amount'
,city                 string            comment 'reports[0].negativeData.refin.refinResponse[0].city'
,federal_unit         string            comment 'reports[0].negativeData.refin.refinResponse[0].federalUnit'
,public_agency        string            comment 'reports[0].negativeData.refin.refinResponse[0].publicAgency'
,principal            string            comment 'reports[0].negativeData.refin.refinResponse[0].principal'     
)
partitioned by (grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://D2/projects/risk/hdfs/prod/risk_mart/dwd/dwd_risk_br_uw_serasa_refin_info_df'
;