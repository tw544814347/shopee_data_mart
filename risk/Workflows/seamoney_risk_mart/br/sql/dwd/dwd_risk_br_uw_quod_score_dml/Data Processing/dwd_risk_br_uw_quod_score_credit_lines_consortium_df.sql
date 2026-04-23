ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
create temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';

create or replace temporary view all_loan_id_tbl as
select 
source_pk 
from risk.dwd_risk_br_uw_quod_score_credit_lines_consortium_df t1 
where grass_date =date_sub('${grass_date}',-1)
group by source_pk 
;

insert overwrite table risk.dwd_risk_br_uw_quod_score_credit_lines_consortium_df partition(grass_date ='${grass_date}')
select 
       t2.source_pk                     as source_pk                                                 
       ,t2.platform_user_id             as platform_user_id  
       ,concat(t2.source_pk,'_',t2.rn)  as loan_id                                  
       ,t2.loan_institution_cnt         as loan_institution_cnt        
       ,t2.revolving_institution_cnt    as revolving_institution_cnt   
       ,t2.cc_institution_cnt           as cc_institution_cnt          
       ,t2.consortium_institution_cnt   as consortium_institution_cnt  
       ,t2.total_institution_cnt        as total_institution_cnt       
       ,t2.relationship_nature          as relationship_nature         
       ,t2.contract_type                as contract_type               
       ,t2.reference_date               as reference_date              
       ,t2.contract_date                as contract_date   
       ,t2.contract_exp_date            as contract_exp_date            
       ,t2.current_loan_amt             as current_loan_amt            
       ,t2.current_dpd_0_amt            as current_dpd_0_amt           
       ,t2.current_dpd_15_amt           as current_dpd_15_amt          
       ,t2.current_dpd_30_amt           as current_dpd_30_amt          
       ,t2.current_dpd_60_amt           as current_dpd_60_amt          
       ,t2.current_dpd_90_amt           as current_dpd_90_amt          
       ,t2.current_due_0_amt            as current_due_0_amt           
       ,t2.current_due_15_amt           as current_due_15_amt          
       ,t2.current_due_30_amt           as current_due_30_amt          
       ,t2.current_due_60_amt           as current_due_60_amt          
       ,t2.current_due_90_amt           as current_due_90_amt          
       ,t2.consotium_group_no           as consotium_group_no   
       ,t2.quota_sequence               as quota_sequence
       ,t2.quota_status                 as quota_status
       ,t2.contract_amt                 as contract_amt
       ,t2.total_instal_cnt             as total_instal_cnt
       ,t2.total_due_amt                as total_due_amt
       ,t2.won_date                     as won_date              
       ,t2.create_time                  as create_time   
       ,t2.previous_installment         as previous_installment  
       ,t2.detached_payment             as detached_payment
       ,t2.future_installment           as future_installment      
from (
       select
              source_pk                                                                                                                                                                                        as source_pk                                                 
              ,t1.platform_user_id                                                                                                                                                                             as platform_user_id  
              ,cast(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].CreditLines.PaymentHabit[0].UniqueCNPJLoans')       as bigint)                                                   as loan_institution_cnt      
              ,cast(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].CreditLines.PaymentHabit[0].UniqueCNPJRevolving')   as bigint)                                                   as revolving_institution_cnt 
              ,cast(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].CreditLines.PaymentHabit[0].UniqueCNPJCreditCards') as bigint)                                                   as cc_institution_cnt        
              ,cast(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].CreditLines.PaymentHabit[0].UniqueCNPJConsorcios')  as bigint)                                                   as consortium_institution_cnt
              ,cast(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].CreditLines.PaymentHabit[0].UniqueCNPJTotal')       as bigint)                                                   as total_institution_cnt     
              ,cast(get_json_object(tbl.consorcios,'$.RelationshipNature') as int)                                                                                                                             as relationship_nature       
              ,get_json_object(tbl.consorcios,'$.ContractType')                                                                                                                                                as contract_type             
              ,concat(get_json_object(tbl.consorcios,'$.DateReference.Year'),'-',get_json_object(tbl.consorcios,'$.DateReference.Month'),'-',get_json_object(tbl.consorcios,'$.DateReference.Day'))            as reference_date            
              ,concat(get_json_object(tbl.consorcios,'$.DateHired.Year'),'-',get_json_object(tbl.consorcios,'$.DateHired.Month'),'-',get_json_object(tbl.consorcios,'$.DateHired.Day'))                        as contract_date             
              ,concat(get_json_object(tbl.consorcios,'$.DateContractDue.Year'),'-',get_json_object(tbl.consorcios,'$.DateContractDue.Month'),'-',get_json_object(tbl.consorcios,'$.DateContractDue.Day'))      as contract_exp_date         
              ,cast(get_json_object(tbl.consorcios,'$.Summary.Total') as double )                                                                                                                              as current_loan_amt          
              ,cast(get_json_object(tbl.consorcios,'$.Summary.ExpiredAmount.Period15Days') as double )                                                                                                         as current_dpd_0_amt         
              ,cast(get_json_object(tbl.consorcios,'$.Summary.ExpiredAmount.Period16To30Days') as double )                                                                                                     as current_dpd_15_amt        
              ,cast(get_json_object(tbl.consorcios,'$.Summary.ExpiredAmount.Period31To60Days') as double )                                                                                                     as current_dpd_30_amt        
              ,cast(get_json_object(tbl.consorcios,'$.Summary.ExpiredAmount.Period61To90Days') as double )                                                                                                     as current_dpd_60_amt        
              ,cast(get_json_object(tbl.consorcios,'$.Summary.ExpiredAmount.MoreThan91Days') as double )                                                                                                       as current_dpd_90_amt        
              ,cast(get_json_object(tbl.consorcios,'$.Summary.DueAmount.Period15Days') as double )                                                                                                             as current_due_0_amt         
              ,cast(get_json_object(tbl.consorcios,'$.Summary.DueAmount.Period16To30Days') as double )                                                                                                         as current_due_15_amt        
              ,cast(get_json_object(tbl.consorcios,'$.Summary.DueAmount.Period31To60Days') as double )                                                                                                         as current_due_30_amt        
              ,cast(get_json_object(tbl.consorcios,'$.Summary.DueAmount.Period61To90Days') as double )                                                                                                         as current_due_60_amt        
              ,cast(get_json_object(tbl.consorcios,'$.Summary.DueAmount.MoreThan91Days') as double )                                                                                                           as current_due_90_amt   
              ,get_json_object(tbl.consorcios,'$.NumberGroup')                                                                                                                                                 as consotium_group_no
              ,get_json_object(tbl.consorcios,'$.QuotaSequence')                                                                                                                                               as quota_sequence
              ,get_json_object(tbl.consorcios,'$.QuotaStatus')                                                                                                                                                 as quota_status
              ,cast(get_json_object(tbl.consorcios,'$.AmountContract') as double )                                                                                                                             as contract_amt
              ,cast(get_json_object(tbl.consorcios,'$.AmountContract') as double )                                                                                                                             as total_instal_cnt
              ,cast(get_json_object(tbl.consorcios,'$.AmountContract') as double )                                                                                                                             as total_due_amt
              ,concat(get_json_object(tbl.consorcios,'$.DateWon.Year'),'-',get_json_object(tbl.consorcios,'$.DateWon.Month'),'-',get_json_object(tbl.consorcios,'$.DateWon.Day'))                              as won_date
              ,create_time                                                                                                                                                                                     as create_time
              ,get_json_object(tbl.consorcios,'$.PreviousInstallments')                                                                                                                                        as previous_installment      
              ,get_json_object(tbl.consorcios,'$.DetachedPayments')                                                                                                                                            as detached_payment 
              ,get_json_object(tbl.consorcios,'$.FutureInstallments')                                                                                                                                          as future_installment        
              ,row_number() over(partition by source_pk order by create_time )                                                                                                                                 as rn                  
       from ( 
              select 
                  tt1.source_pk
                  ,tt1.platform_user_id
                  ,tt1.rsp
                  ,from_unixtime(tt1.create_time  - 11*3600,'yyyy-MM-dd HH:mm:ss')    as create_time
              from risk.dwd_risk_br_uw_risk_trade_df tt1 
              left join all_loan_id_tbl tt2 on tt1.source_pk = tt2.source_pk 
              where tt1.grass_date ='${grass_date}' 
              and tt1.flow_type='QuodReport'
              and tt2.source_pk is null 
       ) t1 
       lateral view explode(json_to_array(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].CreditLines.PaymentHabit[0].Consorcios.Consorcio'))) tbl as consorcios
       
) t2 
union all 
select 
       t2.source_pk                     as source_pk                                                 
       ,t2.platform_user_id             as platform_user_id  
       ,t2.loan_id                      as loan_id                                  
       ,t2.loan_institution_cnt         as loan_institution_cnt        
       ,t2.revolving_institution_cnt    as revolving_institution_cnt   
       ,t2.cc_institution_cnt           as cc_institution_cnt          
       ,t2.consortium_institution_cnt   as consortium_institution_cnt  
       ,t2.total_institution_cnt        as total_institution_cnt       
       ,t2.relationship_nature          as relationship_nature         
       ,t2.contract_type                as contract_type               
       ,t2.reference_date               as reference_date              
       ,t2.contract_date                as contract_date 
       ,t2.contract_exp_date            as contract_exp_date              
       ,t2.current_loan_amt             as current_loan_amt            
       ,t2.current_dpd_0_amt            as current_dpd_0_amt           
       ,t2.current_dpd_15_amt           as current_dpd_15_amt          
       ,t2.current_dpd_30_amt           as current_dpd_30_amt          
       ,t2.current_dpd_60_amt           as current_dpd_60_amt          
       ,t2.current_dpd_90_amt           as current_dpd_90_amt          
       ,t2.current_due_0_amt            as current_due_0_amt           
       ,t2.current_due_15_amt           as current_due_15_amt          
       ,t2.current_due_30_amt           as current_due_30_amt          
       ,t2.current_due_60_amt           as current_due_60_amt          
       ,t2.current_due_90_amt           as current_due_90_amt          
       ,t2.consotium_group_no           as consotium_group_no   
       ,t2.quota_sequence               as quota_sequence
       ,t2.quota_status                 as quota_status
       ,t2.contract_amt                 as contract_amt
       ,t2.total_instal_cnt             as total_instal_cnt
       ,t2.total_due_amt                as total_due_amt
       ,t2.won_date                     as won_date              
       ,t2.create_time                  as create_time   
       ,t2.previous_installment         as previous_installment  
       ,t2.detached_payment             as detached_payment
       ,t2.future_installment           as future_installment       
from risk.dwd_risk_br_uw_quod_score_credit_lines_consortium_df  t2 
where grass_date =date_sub('${grass_date}',-1) 

;