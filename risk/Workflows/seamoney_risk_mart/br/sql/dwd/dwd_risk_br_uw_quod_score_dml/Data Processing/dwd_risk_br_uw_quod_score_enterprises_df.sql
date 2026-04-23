ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
create temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';

insert overwrite table risk.dwd_risk_br_uw_quod_score_enterprises_df partition(grass_date ='${grass_date}')
select
    t1.source_pk                                                                                                           as source_pk              
    ,get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.CPF')                              as cpf                       
    ,from_unixtime(t1.create_time  - 11*3600,'yyyy-MM-dd HH:mm:ss')                                                        as create_time              
    ,t1.platform_user_id                                                                                                   as platform_user_id 
    ,get_json_object(tbl.partnership,'$.EntityType')                                                                       as entity_type
    ,get_json_object(tbl.partnership,'$.CNPJ')                                                                             as cnpj_number              
    ,get_json_object(tbl.partnership,'$.CompanyName')                                                                      as company_name             
    ,get_json_object(tbl.partnership,'$.CNPJStatus')                                                                       as company_status           
    ,cast(get_json_object(tbl.partnership,'$.PercentParticipation') as double )                                            as percent_participation    
    ,cast(get_json_object(tbl.partnership,'$.ParticipationValue') as double )                                              as participation_value      
    ,get_json_object(tbl.partnership,'$.RelationshipDescription')                                                          as relationship_description 
    ,concat(get_json_object(tbl.partnership,'$.DateStartPartner.Year'),'-',get_json_object(tbl.partnership,'$.DateStartPartner.Month'),'-',get_json_object(tbl.partnership,'$.DateStartPartner.Day'))       as date_occurred            
    ,concat(get_json_object(tbl.partnership,'$.DateStart.Year'),'-',get_json_object(tbl.partnership,'$.DateStart.Month'),'-',get_json_object(tbl.partnership,'$.DateStart.Day'))                            as date_start               
    ,concat(get_json_object(tbl.partnership,'$.DateEnd.Year'),'-',get_json_object(tbl.partnership,'$.DateEnd.Month'),'-',get_json_object(tbl.partnership,'$.DateEnd.Day'))                                  as date_end         
    ,get_json_object(tbl.partnership,'$.FlagMainJob')                                                                      as flag_main_job            
    ,concat(get_json_object(tbl.partnership,'$.DateReference.Year'),'-',get_json_object(tbl.partnership,'$.DateReference.Month'),'-',get_json_object(tbl.partnership,'$.DateReference.Day'))               as date_reference           
from risk.dwd_risk_br_uw_risk_trade_df t1 
lateral view explode(json_to_array(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].EnterpriseData.Partnerships.Partnership'))) tbl as partnership 
where t1.grass_date ='${grass_date}' 
and t1.flow_type='QuodReport'
and get_json_object(rsp, '$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.CPF') IS NOT NULL
;

