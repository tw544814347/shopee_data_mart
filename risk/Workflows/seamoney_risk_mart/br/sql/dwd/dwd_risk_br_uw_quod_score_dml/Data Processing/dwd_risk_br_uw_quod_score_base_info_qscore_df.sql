-- ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
-- create temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';

insert overwrite table risk.dwd_risk_br_uw_quod_score_base_info_qscore_df partition(grass_date ='${grass_date}')
select
 source_pk                                                                                                                        as source_pk                        
,get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.CPF')                                         as cpf
,t1.platform_user_id                                                                                                              as platform_user_id
,get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.CPFStatus')                                   as cpf_status
,get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.PersonName.Name.Full')                        as name                          
,get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.MotherName.Full')                             as mother_name                        
,concat(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.DOB.Year'),'-',get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.DOB.Month'),'-',get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.DOB.Day'))          as dob 
,cast(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.Age') as int )                           as age               
,get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.Gender')                                      as gender            
,cast(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.Deceased') as int)                       as is_deceased       
,concat(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.DOD.Year'),'-',get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.DOD.Month'),'-',get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.DOD.Day'))           as dod
,get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.Address.Street')                              as address_street       
,get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.Address.Number')                              as address_number       
,get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.Address.Complement')                          as address_complement   
,get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.Address.Neighborhood')                        as address_neighborhood 
,get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.Address.City')                                as address_city         
,get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.Address.State')                               as address_state        
,get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.Address.PostalCode')                          as address_postal_code  
,concat(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.Address.DateLastSeen.Year'),'-',get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.Address.DateLastSeen.Month'),'-',get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.Address.DateLastSeen.Day'))              as address_update_date
,get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.Email.Email')                                 as email 
,concat(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.Email.DateLastSeen.Year'),'-',get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.Email.DateLastSeen.Month'),'-',get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.Email.DateLastSeen.Day'))                    as email_update_date                
,get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.PhoneNumber.PhoneNumber')                     as phone
,concat(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.PhoneNumber.DateLastSeen.Year'),'-',get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.PhoneNumber.DateLastSeen.Month'),'-',get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.PhoneNumber.DateLastSeen.Day'))  as phone_update_date      
,get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.MobilePhoneNumber.PhoneNumber')               as mobile_phone             
,concat(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.MobilePhoneNumber.DateLastSeen.Year'),'-',get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.MobilePhoneNumber.DateLastSeen.Month'),'-',get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].BestInfo.MobilePhoneNumber.DateLastSeen.Day'))        as mobile_phone_update_date 
,cast(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].QuodScore.Score') as double )                     as quod_score                
,cast(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].QuodScore.Segment') as int)                       as quod_score_segment        
,cast(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].QuodScore.PaymentCommitmentScore') as double )    as quod_pmt_commitment_score 
,cast(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].QuodScore.ProfileScore')  as double )             as quod_profile_score     
,from_unixtime(t1.create_time  - 11*3600,'yyyy-MM-dd HH:mm:ss')                                                                   as create_time   
from risk.dwd_risk_br_uw_risk_trade_df t1 
where t1.grass_date ='${grass_date}' 
and t1.flow_type='QuodReport'
;

