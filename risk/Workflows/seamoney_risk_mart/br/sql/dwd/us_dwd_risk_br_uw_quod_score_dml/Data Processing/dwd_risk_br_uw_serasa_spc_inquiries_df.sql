ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
create temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';

insert overwrite table risk.dwd_risk_br_uw_serasa_spc_inquiries_df partition(grass_date ='${grass_date}')
select 
     get_json_object(t1.header_data,'$.PlatformUserId')                                                                      as platform_user_id    
    ,get_json_object(resp_raw_data,'$.reports[0].registration.documentNumber')                                               as document_number
    ,get_json_object(tbl.spc_inquires,'$.occurrenceDate')                                                                    as occurrence_date
    ,get_json_object(tbl.spc_inquires,'$.segmentDescription')                                                                as segment_description             
from risk.ods__credit_risk_datafetch_br_db__identity_data_tab__df  t1
lateral view explode(json_to_array(get_json_object(t1.resp_raw_data,'$.optionalFeatures.facts.spcInquires.spcInquiriesResponse'))) tbl as spc_inquires 
where grass_date ='${grass_date}'
and data_source_name = 'SerasaInfo'
and get_json_object(resp_raw_data,'$.optionalFeatures.facts.spcInquires.summary.count') >0
;
