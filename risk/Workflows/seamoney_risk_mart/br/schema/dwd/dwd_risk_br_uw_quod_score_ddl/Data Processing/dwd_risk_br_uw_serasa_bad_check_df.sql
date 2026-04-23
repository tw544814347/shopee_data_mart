drop  table if exists risk.dwd_risk_br_uw_serasa_bad_check_df;
create external table if not exists risk.dwd_risk_br_uw_serasa_bad_check_df
(
platform_user_id      string            comment 'platform_user_id'
,document_number      string            comment 'registration.documentNumber'
,loan_id              string            comment 'Dev generate unique ID for each loan, each ID corresponds to one element in pefin array  MD5 CONCAT(occurrence_date, contractor_id)'
,occurrence_date      string            comment 'reports[0].negativeData.notary.notaryResponse[0].occurrenceDate'
,legal_square          string           comment 'reports[0].negativeData.check.checkResponse[0].legalSquare'
,bank_id               string           comment 'reports[0].negativeData.check.checkResponse[0].bankId'
,bank_name             string           comment 'reports[0].negativeData.check.checkResponse[0].bankName'
,bank_agency_id        string           comment 'reports[0].negativeData.check.checkResponse[0].bankAgencyId'
,check_count           bigint           comment 'reports[0].negativeData.check.checkResponse[0].checkCount'
,city                  string           comment 'reports[0].negativeData.check.checkResponse[0].city'
,federal_unit          string           comment 'reports[0].negativeData.check.checkResponse[0].federalUnit'
,check_number          string           comment 'reports[0].negativeData.check.checkResponse[0].checkNumber'
,alinea                bigint           comment 'reports[0].negativeData.check.checkResponse[0].alinea'
)
partitioned by (grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/risk_mart/dwd/dwd_risk_br_uw_serasa_bad_check_df'
;
