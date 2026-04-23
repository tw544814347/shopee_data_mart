drop  table if exists risk.dwd_risk_br_uw_serasa_payment_history_df;
create external table if not exists risk.dwd_risk_br_uw_serasa_payment_history_df
(
platform_user_id            string           comment 'platform_user_id'
,document_number      string            comment 'registration.documentNumber'
,initial_day_range          bigint           comment 'optionalFeatures.paymentshistory.paymentsHistoryResponse[0].initialDayRange'
,final_day_range            bigint           comment 'optionalFeatures.paymentshistory.paymentsHistoryResponse[0].finalDayRange'
,score                      string           comment 'optionalFeatures.paymentshistory.paymentsHistoryResponse[0].score'
,range                      string           comment 'optionalFeatures.paymentshistory.paymentsHistoryResponse[0].range'
,message                    string           comment 'optionalFeatures.paymentshistory.paymentsHistoryResponse[0].error.message'
,code                       bigint           comment 'optionalFeatures.paymentshistory.paymentsHistoryResponse[0].error.code'
)
partitioned by (grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://D2/projects/risk/hdfs/prod/risk_mart/dwd/dwd_risk_br_uw_serasa_payment_history_df'
;
