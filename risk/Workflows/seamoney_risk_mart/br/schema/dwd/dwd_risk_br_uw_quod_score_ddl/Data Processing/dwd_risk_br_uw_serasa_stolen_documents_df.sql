drop  table if exists risk.dwd_risk_br_uw_serasa_stolen_documents_df;
create external table if not exists risk.dwd_risk_br_uw_serasa_stolen_documents_df
(
platform_user_id            string     comment 'platform_user_id'
,occurrence_date            string     comment 'reports[0].facts.stolenDocuments.stolenDocumentsResponse[0].occurrenceDate'
,inclusion_date             string     comment 'reports[0].facts.stolenDocuments.stolenDocumentsResponse[0].inclusionDate'
,document_type              string     comment 'reports[0].facts.stolenDocuments.stolenDocumentsResponse[0].documentType'
,document_number            string     comment 'reports[0].facts.stolenDocuments.stolenDocumentsResponse[0].documentNumber'
,issuing_authority          string     comment 'reports[0].facts.stolenDocuments.stolenDocumentsResponse[0].issuingAuthority'
,detailed_reason            string     comment 'reports[0].facts.stolenDocuments.stolenDocumentsResponse[0].detailedReason'
,occurrence_state           string     comment 'reports[0].facts.stolenDocuments.stolenDocumentsResponse[0].occurrenceState'
,region_code                bigint     comment 'reports[0].facts.stolenDocuments.stolenDocumentsResponse[0].phoneNumber.regionCode'
,area_code                  bigint     comment 'reports[0].facts.stolenDocuments.stolenDocumentsResponse[0].phoneNumber.areaCode'
,phone_number               bigint     comment 'reports[0].facts.stolenDocuments.stolenDocumentsResponse[0].phoneNumber.phoneNumber'

)
partitioned by (grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/risk_mart/dwd/dwd_risk_br_uw_serasa_stolen_documents_df'
;

