drop  table if exists risk.dwd_risk_br_uw_serasa_spc_inquiries_df;
create external table if not exists risk.dwd_risk_br_uw_serasa_spc_inquiries_df
(
platform_user_id            string         comment 'platform_user_id'
,document_number      string            comment 'registration.documentNumber'
,occurrence_date            string         comment 'optionalFeatures.facts.spcInquires.spcInquiriesResponse[0].occurrenceDate'
,segment_description        string         comment 'optionalFeatures.facts.spcInquires.spcInquiriesResponse[0].segmentDescription'
)
partitioned by (grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://D2/projects/risk/hdfs/prod/risk_mart/dwd/dwd_risk_br_uw_serasa_spc_inquiries_df'
;