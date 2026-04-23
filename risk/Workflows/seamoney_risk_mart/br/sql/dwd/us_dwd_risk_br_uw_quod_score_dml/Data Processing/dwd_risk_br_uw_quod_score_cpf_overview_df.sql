-- ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
-- create temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';

insert overwrite table risk.dwd_risk_br_uw_quod_score_cpf_overview_df partition(grass_date ='${grass_date}')
select
    t1.source_pk                                                                                                              as source_pk              
    ,from_unixtime(t1.create_time  - 11*3600,'yyyy-MM-dd HH:mm:ss')                                                           as create_time              
    ,t1.platform_user_id                                                                                                      as platform_user_id 
    ,get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Header.Status')                                                  as request_status
    ,get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Header.QueryId')                                                 as query_id              
    ,get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Header.TransactionId')                                           as transaction_id             
    ,cast(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].CPStatus') as int)                        as cp_status           
    ,cast(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].Segment') as int)                         as segment    
    ,get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].HasOnlyMinimumPII')                            as has_only_min_pii      
    ,get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].HasNegativeData')                              as has_negative_data 
    ,get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].HasInquiryData')                               as has_inquiry_data                      
from risk.dwd_risk_br_uw_risk_trade_df t1 
where t1.grass_date ='${grass_date}' 
and t1.flow_type='QuodReport'
;