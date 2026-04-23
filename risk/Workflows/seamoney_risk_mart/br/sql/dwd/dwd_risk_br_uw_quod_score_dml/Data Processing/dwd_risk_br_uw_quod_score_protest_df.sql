-- ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
-- create temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';

insert overwrite table risk.dwd_risk_br_uw_quod_score_protest_df partition(grass_date ='${grass_date}')
select 

    t1.source_pk                                                                                                                              as source_pk              
    ,from_unixtime(t1.create_time  - 11*3600,'yyyy-MM-dd HH:mm:ss')                                                                           as create_time              
    ,t1.platform_user_id                                                                                                                      as platform_user_id 
    ,get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].Protests.Protest[0].data_consulta')                            as date_query          
    ,get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].Protests.Protest[0].retorno')                                  as return              
    ,get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].Protests.Protest[0].erro')                                     as error               
    ,get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].Protests.Protest[0].erro_descricao')                           as error_description   
    ,get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].Protests.Protest[0].situacao')                                 as situation           
    ,cast(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].Protests.Protest[0].valor_protestados_total')as double )  as total_protest_value 
    ,get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].Protests.Protest[0].conteudo')                                 as conteudo                   
from risk.dwd_risk_br_uw_risk_trade_df t1 
where t1.grass_date ='${grass_date}' 
and t1.flow_type='QuodReport'
;