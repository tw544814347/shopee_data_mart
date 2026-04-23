ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
create temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';

insert overwrite table risk.dwd_risk_br_uw_quod_score_base_info_inquiry_df partition(grass_date ='${grass_date}')
select
    t1.source_pk                                                                as source_pk              
    ,platform_user_id                                                           as platform_user_id    
    ,concat(get_json_object(tbl.inquirydetail,'$.DateInquiry.Year'),'-',get_json_object(tbl.inquirydetail,'$.DateInquiry.Month'),'-',get_json_object(tbl.inquirydetail,'$.DateInquiry.Day')) as inquiry_date 
    ,cast(get_json_object(tbl.inquirydetail,'$.InquiryCount')as int )           as inquiry_cnt 
    ,get_json_object(tbl.inquirydetail,'$.Segment')                             as segment 
    ,from_unixtime(t1.create_time  - 11*3600,'yyyy-MM-dd HH:mm:ss')             as create_time
from risk.dwd_risk_br_uw_risk_trade_df t1 
lateral view explode(json_to_array(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].Inquiries.InquiryDetails.InquiryDetail'))) tbl as inquirydetail 
where t1.grass_date ='${grass_date}' 
and t1.flow_type='QuodReport'
;

