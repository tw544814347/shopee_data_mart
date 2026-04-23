ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
create temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';

insert overwrite table risk.dwd_risk_br_uw_quod_score_negative_ccfnotes_df partition(grass_date ='${grass_date}')
select
    t1.source_pk                                                                                                           as source_pk              
    ,get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.CPF')                              as cpf                       
    ,from_unixtime(t1.create_time  - 11*3600,'yyyy-MM-dd HH:mm:ss')                                                        as create_time              
    ,t1.platform_user_id                                                                                                   as platform_user_id 
    ,get_json_object(tbl.ccfapontamento,'$.EntityType')                                                                    as entity_type            
    ,get_json_object(tbl.ccfapontamento,'$.CpfCnpj')                                                                       as cpf_cnpj               
    ,get_json_object(tbl.ccfapontamento,'$.ReportingCodeBank')                                                             as reporting_bank_code    
    ,get_json_object(tbl.ccfapontamento,'$.ReportingBranchPrefixNumber')                                                   as reporting_branch_prefix
    ,get_json_object(tbl.ccfapontamento,'$.ReasonBounce')                                                                  as reason_bounce          
    ,get_json_object(tbl.ccfapontamento,'$.CountBounce')                                                                   as bounce_count           
    ,concat(get_json_object(tbl.ccfapontamento,'$.DateLastBounce.Year'),'-',get_json_object(tbl.ccfapontamento,'$.DateLastBounce.Month'),'-',get_json_object(tbl.ccfapontamento,'$.DateLastBounce.Day'))  as date_last_bounce           
from risk.dwd_risk_br_uw_risk_trade_df t1 
lateral view explode(json_to_array(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].Negative.CcfApontamentos.CcfApontamento'))) tbl as ccfapontamento 
where t1.grass_date ='${grass_date}' 
and t1.flow_type='QuodReport'
and cast(get_json_object(rsp, '$.QuodReportResponseEx.Response.Records.Record[0].HasNegativeData') as string) = 'true'
and get_json_object(rsp, '$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.CPF') IS NOT NULL
;

