drop  table if exists risk.dwd_risk_br_uw_serasa_personal_info_df;
create external table if not exists risk.dwd_risk_br_uw_serasa_personal_info_df
(
platform_user_id           string            comment 'platform_user_id'
,document_number           string            comment 'reports[0].registration.documentNumber'  
,name                      string            comment 'reports[0].registration.consumerName'  
,mother_name               string            comment 'reports[0].registration.motherName'  
,birth_date                string            comment 'reports[0].registration.birthDate'  
,status_registration       string            comment 'reports[0].registration.statusRegistration'  
,status_date               string            comment 'reports[0].registration.statusDate'  
,address_line              string            comment 'reports[0].registration.address.addressLine'  
,address_district          string            comment 'reports[0].registration.address.district'  
,address_zipcode           string            comment 'reports[0].registration.address.zipCode'  
,address_country           string            comment 'reports[0].registration.address.country'  
,address_city              string            comment 'reports[0].registration.address.city'  
,address_state             string            comment 'reports[0].registration.address.state'  
,phone_region_code         string            comment 'reports[0].registration.phone.regionCode'  
,phone_area_code           string            comment 'reports[0].registration.phone.areaCode'  
,phone_number              string            comment 'reports[0].registration.phone.phoneNumber'  
,pefin_count               bigint            comment 'reports[0].negativeData.pefin.summary.count'  
,pefin_balance             decimal(32,4)     comment 'reports[0].negativeData.pefin.summary.balance'             
,refin_count               bigint            comment 'reports[0].negativeData.refin.summary.count'      
,refin_balance             decimal(32,4)     comment 'reports[0].negativeData.refin.summary.balance'             
,notary_count              bigint            comment 'reports[0].negativeData.notary.summary.count'      
,notary_balance            decimal(32,4)     comment 'reports[0].negativeData.notary.summary.balance'             
,check_count               bigint            comment 'reports[0].negativeData.check.summary.count'      
,check_balance             decimal(32,4)     comment 'reports[0].negativeData.check.summary.count'             
,inquiry_count             bigint            comment 'reports[0].facts.inquiry.summary.count'      
,stolen_doc_count          bigint            comment 'reports[0].facts.stolenDocuments.summary.count'      
,stolen_doc_balance        decimal(32,4)     comment 'reports[0].facts.stolenDocuments.summary.balance'             
,spc_negative_count        bigint            comment 'optionalFeatures.negativeData.spcNegative.summary.count'      
,spc_negative_balance      decimal(32,4)     comment 'optionalFeatures.negativeData.spcNegative.summary.balance'             
,spc_inquiry_count         bigint            comment 'optionalFeatures.facts.spcInquires.summary.count'      
)
partitioned by (grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://D2/projects/risk/hdfs/prod/risk_mart/dwd/dwd_risk_br_uw_serasa_personal_info_df'
;