drop  table if exists risk.dwd_risk_br_uw_serasa_inquiries_df;
create external table if not exists risk.dwd_risk_br_uw_serasa_inquiries_df
(
platform_user_id            string     comment 'platform_user_id'
,occurrence_date            string     comment 'reports[0].facts.inquiry.inquiryResponse[0].occurrenceDate'
,segment_description        string     comment 'reports[0].facts.inquiry.inquiryResponse[0].segmentDescription'
,days_quantity              bigint     comment 'reports[0].facts.inquiry.inquiryResponse[0].daysQuantity'

)
partitioned by (grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/risk_mart/dwd/dwd_risk_br_uw_serasa_inquiries_df'
;