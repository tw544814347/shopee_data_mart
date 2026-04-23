
ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
create temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';

insert overwrite table risk.dwd_risk_br_uw_quod_score_negative_annotation_df partition(grass_date ='${grass_date}')
select
    t1.source_pk                                                                                                                            as source_pk              
    ,get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.CPF')                                               as cpf                       
    ,from_unixtime(t1.create_time  - 11*3600,'yyyy-MM-dd HH:mm:ss')                                                                         as create_time              
    ,t1.platform_user_id                                                                                                                    as platform_user_id         
    ,get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].Negative.DateLastNote')                                      as date_latest_annotation   
    ,cast(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].Negative.PendenciesControlCred') as double )            as pendencies_control_cred  
    ,get_json_object(tbl.apontamento,'$.CNPJ')                                                                                              as annotation_company_cnpj  
    ,get_json_object(tbl.apontamento,'$.CompanyName')                                                                                       as annotation_company_name  
    ,cast(get_json_object(tbl.apontamento,'$.Amount') as double )                                                                           as annotation_amount        
    ,get_json_object(tbl.apontamento,'$.Nature')                                                                                            as annotation_nature        
    ,get_json_object(tbl.apontamento,'$.ContractNumber')                                                                                    as contract_number          
    ,get_json_object(tbl.apontamento,'$.ParticipantType')                                                                                   as participant_type         
    ,get_json_object(tbl.apontamento,'$.ApontamentoStatus')                                                                                 as apontamento_status       
    ,concat(get_json_object(tbl.apontamento,'$.DateOccurred.Year'),'-',get_json_object(tbl.apontamento,'$.DateOccurred.Month'),'-',get_json_object(tbl.apontamento,'$.DateOccurred.Day'))       as date_occurred            
    ,concat(get_json_object(tbl.apontamento,'$.DateIncluded.Year'),'-',get_json_object(tbl.apontamento,'$.DateIncluded.Month'),'-',get_json_object(tbl.apontamento,'$.DateIncluded.Day'))       as date_included            
    ,concat(get_json_object(tbl.apontamento,'$.DateModified.Year'),'-',get_json_object(tbl.apontamento,'$.DateModified.Month'),'-',get_json_object(tbl.apontamento,'$.DateModified.Day'))       as date_modified            
    ,get_json_object(tbl.apontamento,'$.Address.City')                                                                                      as address_city             
    ,get_json_object(tbl.apontamento,'$.Address.State')                                                                                     as address_state               
from risk.dwd_risk_br_uw_risk_trade_df t1 
lateral view explode(json_to_array(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].Negative.Apontamentos.Apontamento'))) tbl as apontamento 
where t1.grass_date ='${grass_date}' 
and t1.flow_type='QuodReport'
and cast(get_json_object(rsp, '$.QuodReportResponseEx.Response.Records.Record[0].HasNegativeData') as string) = 'true'
and get_json_object(rsp, '$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.CPF') IS NOT NULL
;

