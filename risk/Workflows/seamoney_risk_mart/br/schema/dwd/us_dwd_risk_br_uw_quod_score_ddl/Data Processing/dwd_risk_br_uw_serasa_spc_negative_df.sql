drop  table if exists risk.dwd_risk_br_uw_serasa_spc_negative_df;
create external table if not exists risk.dwd_risk_br_uw_serasa_spc_negative_df
(
platform_user_id            string         comment 'platform_user_id'
,document_number      string            comment 'registration.documentNumber'
,loan_id                    string         comment 'Dev generate unique ID for each loan, each ID corresponds to one element in pefin array  MD5 CONCAT(occurrence_date, creditor_business_id)'
,occurrence_date            string         comment 'optionalFeatures.negativeData.spcNegative.spcNegativeResponse[0].occurrenceDate'
,occurrence_status          string         comment 'optionalFeatures.negativeData.spcNegative.spcNegativeResponse[0].occurrenceStatus'
,legal_nature_id            string         comment 'optionalFeatures.negativeData.spcNegative.spcNegativeResponse[0].legalNatureId'
,legal_nature               string         comment 'optionalFeatures.negativeData.spcNegative.spcNegativeResponse[0].legalNature'
,contract_id                string         comment 'id of occurrence contract optionalFeatures.negativeData.spcNegative.spcNegativeResponse[0].contractId'
,creditor_business_id       string         comment 'ptionalFeatures.negativeData.spcNegative.spcNegativeResponse[0].creditorBusinessId'
,creditor_name              string         comment 'ptionalFeatures.negativeData.spcNegative.spcNegativeResponse[0].creditorName'
,amount                     decimal(32,4)  comment 'ptionalFeatures.negativeData.spcNegative.spcNegativeResponse[0].amount'
,city                       string         comment 'ptionalFeatures.negativeData.spcNegative.spcNegativeResponse[0].city'
,federal_unit               string         comment 'ptionalFeatures.negativeData.spcNegative.spcNegativeResponse[0].federalUnit'
,principal                  string         comment 'indicates if it is a guarantor optionalFeatures.negativeData.spcNegative.spcNegativeResponse[0].principal'

)
partitioned by (grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://D2/projects/risk/hdfs/prod/risk_mart/dwd/dwd_risk_br_uw_serasa_spc_negative_df'
;