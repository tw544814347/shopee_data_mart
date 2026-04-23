ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
create temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';

insert overwrite table risk.dwd_risk_br_uw_quod_score_negative_lawsuit_df partition(grass_date ='${grass_date}')
select
    t1.source_pk                                                                                                           as source_pk              
    ,get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.CPF')                              as cpf                       
    ,from_unixtime(t1.create_time  - 11*3600,'yyyy-MM-dd HH:mm:ss')                                                        as create_time              
    ,t1.platform_user_id                                                                                                   as platform_user_id         
    ,get_json_object(tbl.lawsuitapontamento,'$.ProcessNumber')                                                             as process_number          
    ,get_json_object(tbl.lawsuitapontamento,'$.ProtocolNumber')                                                            as protocol_number         
    ,get_json_object(tbl.lawsuitapontamento,'$.Comarca')                                                                   as comarca                 
    ,get_json_object(tbl.lawsuitapontamento,'$.Forum')                                                                     as forum                   
    ,get_json_object(tbl.lawsuitapontamento,'$.Vara')                                                                      as vara                    
    ,get_json_object(tbl.lawsuitapontamento,'$.ProcessAuthor')                                                             as process_author          
    ,get_json_object(tbl.lawsuitapontamento,'$.Name')                                                                      as name                    
    ,concat(get_json_object(tbl.lawsuitapontamento,'$.DateDistribution.Year'),'-',get_json_object(tbl.lawsuitapontamento,'$.DateDistribution.Month'),'-',get_json_object(tbl.lawsuitapontamento,'$.DateDistribution.Day'))   as date_of_distribution    
    ,get_json_object(tbl.lawsuitapontamento,'$.ProcessType')                                                               as process_type            
    ,get_json_object(tbl.lawsuitapontamento,'$.CurrentStatus')                                                             as current_status          
    ,cast(get_json_object(tbl.lawsuitapontamento,'$.AmountLawsuit') as double )                                            as lawsuit_amount          
    ,get_json_object(tbl.lawsuitapontamento,'$.City')                                                                      as city                    
    ,get_json_object(tbl.lawsuitapontamento,'$.State')                                                                     as state                   
    ,get_json_object(tbl.lawsuitapontamento,'$.JusticeType')                                                               as justice_type            
    ,get_json_object(tbl.lawsuitapontamento,'$.EntityType')                                                                as entity_type             
    ,get_json_object(tbl.lawsuitapontamento,'$.CpfCnpj')                                                                   as cpf_cnpj                
    ,get_json_object(tbl.lawsuitapontamento,'$.SimilarityIndex')                                                           as similarity_index        
    ,get_json_object(tbl.lawsuitapontamento,'$.IdConfidence')                                                              as id_confidence           
    ,get_json_object(tbl.lawsuitapontamento,'$.RegisterId')                                                                as register_id             
    ,get_json_object(tbl.lawsuitapontamento,'$.RegisterType')                                                              as register_type           
    ,get_json_object(tbl.lawsuitapontamento,'$.OriginSource')                                                              as origin_source           
    ,concat(get_json_object(tbl.lawsuitapontamento,'$.DateProcessed.Year'),'-',get_json_object(tbl.lawsuitapontamento,'$.DateProcessed.Month'),'-',get_json_object(tbl.lawsuitapontamento,'$.DateProcessed.Day'))   as date_processed          
from risk.dwd_risk_br_uw_risk_trade_df t1 
lateral view explode(json_to_array(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].Negative.LawSuitApontamentos.LawSuitApontamento'))) tbl as lawsuitapontamento 
where t1.grass_date ='${grass_date}' 
and t1.flow_type='QuodReport'
and cast(get_json_object(rsp, '$.QuodReportResponseEx.Response.Records.Record[0].HasNegativeData') as string) = 'true'
and get_json_object(rsp, '$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.CPF') IS NOT NULL
;

