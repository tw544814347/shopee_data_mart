ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
create temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';

create or replace temporary view all_loan_id_tbl as
select 
source_pk 
from risk.dwd_risk_br_uw_quod_score_credit_lines_creditcard_df t1 
where grass_date =date_sub('${grass_date}',-1)
group by source_pk 
;

insert overwrite table risk.dwd_risk_br_uw_quod_score_credit_lines_creditcard_df partition(grass_date ='${grass_date}')
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
       ,t2.last_4_digits_card_no        as last_4_digits_card_no       
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
       ,t2.total_balance                as total_balance               
       ,t2.future_instal_due_date       as future_instal_due_date      
       ,t2.future_instal_balance        as future_instal_balance       
       ,t2.future_instal_min_payment    as future_instal_min_payment   
       ,t2.create_time                  as create_time   
       ,t2.previous_installment         as previous_installment              
from (
       select
              source_pk                                                                                                                                                                                        as source_pk                                                 
              ,t1.platform_user_id                                                                                                                                                                             as platform_user_id  
              ,cast(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].CreditLines.PaymentHabit[0].UniqueCNPJLoans')       as bigint)                                                   as loan_institution_cnt      
              ,cast(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].CreditLines.PaymentHabit[0].UniqueCNPJRevolving')   as bigint)                                                   as revolving_institution_cnt 
              ,cast(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].CreditLines.PaymentHabit[0].UniqueCNPJCreditCards') as bigint)                                                   as cc_institution_cnt        
              ,cast(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].CreditLines.PaymentHabit[0].UniqueCNPJConsorcios')  as bigint)                                                   as consortium_institution_cnt
              ,cast(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].CreditLines.PaymentHabit[0].UniqueCNPJTotal')       as bigint)                                                   as total_institution_cnt     
              ,cast(get_json_object(tbl.credit_card,'$.RelationshipNature') as int)                                                                                                                            as relationship_nature       
              ,get_json_object(tbl.credit_card,'$.ContractType')                                                                                                                                               as contract_type             
              ,concat(get_json_object(tbl.credit_card,'$.DateReference.Year'),'-',get_json_object(tbl.credit_card,'$.DateReference.Month'),'-',get_json_object(tbl.credit_card,'$.DateReference.Day'))         as reference_date            
              ,concat(get_json_object(tbl.credit_card,'$.DateHired.Year'),'-',get_json_object(tbl.credit_card,'$.DateHired.Month'),'-',get_json_object(tbl.credit_card,'$.DateHired.Day'))                     as contract_date             
              ,get_json_object(tbl.credit_card,'$.CardNumber')                                                                                                                                                 as last_4_digits_card_no         
              ,cast(get_json_object(tbl.credit_card,'$.Summary.Total') as double )                                                                                                                             as current_loan_amt          
              ,cast(get_json_object(tbl.credit_card,'$.Summary.ExpiredAmount.Period15Days') as double )                                                                                                        as current_dpd_0_amt         
              ,cast(get_json_object(tbl.credit_card,'$.Summary.ExpiredAmount.Period16To30Days') as double )                                                                                                    as current_dpd_15_amt        
              ,cast(get_json_object(tbl.credit_card,'$.Summary.ExpiredAmount.Period31To60Days') as double )                                                                                                    as current_dpd_30_amt        
              ,cast(get_json_object(tbl.credit_card,'$.Summary.ExpiredAmount.Period61To90Days') as double )                                                                                                    as current_dpd_60_amt        
              ,cast(get_json_object(tbl.credit_card,'$.Summary.ExpiredAmount.MoreThan91Days') as double )                                                                                                      as current_dpd_90_amt        
              ,cast(get_json_object(tbl.credit_card,'$.Summary.DueAmount.Period15Days') as double )                                                                                                            as current_due_0_amt         
              ,cast(get_json_object(tbl.credit_card,'$.Summary.DueAmount.Period16To30Days') as double )                                                                                                        as current_due_15_amt        
              ,cast(get_json_object(tbl.credit_card,'$.Summary.DueAmount.Period31To60Days') as double )                                                                                                        as current_due_30_amt        
              ,cast(get_json_object(tbl.credit_card,'$.Summary.DueAmount.Period61To90Days') as double )                                                                                                        as current_due_60_amt        
              ,cast(get_json_object(tbl.credit_card,'$.Summary.DueAmount.MoreThan91Days') as double )                                                                                                          as current_due_90_amt        
              ,cast(get_json_object(tbl.credit_card,'$.AmountTotalBalance') as double )                                                                                                                        as total_balance 
              ,concat(get_json_object(tbl.credit_card,'$.FutureInstallment.DateDue.Year'),'-',get_json_object(tbl.credit_card,'$.FutureInstallment.DateDue.Month'),'-',get_json_object(tbl.credit_card,'$.FutureInstallment.DateDue.Day')) as future_instal_due_date
              ,cast(get_json_object(tbl.credit_card,'$.FutureInstallment.AmountTotalBalance') as double )                                                                                                      as future_instal_balance
              ,cast(get_json_object(tbl.credit_card,'$.utureInstallment.AmountMinPayment') as double )                                                                                                         as future_instal_min_payment
              ,create_time                                                                                                                                                                                     as create_time
              ,get_json_object(tbl.credit_card,'$.PreviousInstallments')                                                                                                                                       as previous_installment             
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
       lateral view explode(json_to_array(get_json_object(t1.rsp,'$.QuodReportResponseEx.Response.Records.Record[0].CreditLines.PaymentHabit[0].CreditCards.CreditCard'))) tbl as credit_card
       
) t2 
union all 
select 
       source_pk                     as source_pk                                                 
       ,platform_user_id             as platform_user_id  
       ,loan_id                      as loan_id                                  
       ,loan_institution_cnt         as loan_institution_cnt        
       ,revolving_institution_cnt    as revolving_institution_cnt   
       ,cc_institution_cnt           as cc_institution_cnt          
       ,consortium_institution_cnt   as consortium_institution_cnt  
       ,total_institution_cnt        as total_institution_cnt       
       ,relationship_nature          as relationship_nature         
       ,contract_type                as contract_type               
       ,reference_date               as reference_date              
       ,contract_date                as contract_date               
       ,last_4_digits_card_no        as last_4_digits_card_no       
       ,current_loan_amt             as current_loan_amt            
       ,current_dpd_0_amt            as current_dpd_0_amt           
       ,current_dpd_15_amt           as current_dpd_15_amt          
       ,current_dpd_30_amt           as current_dpd_30_amt          
       ,current_dpd_60_amt           as current_dpd_60_amt          
       ,current_dpd_90_amt           as current_dpd_90_amt          
       ,current_due_0_amt            as current_due_0_amt           
       ,current_due_15_amt           as current_due_15_amt          
       ,current_due_30_amt           as current_due_30_amt          
       ,current_due_60_amt           as current_due_60_amt          
       ,current_due_90_amt           as current_due_90_amt          
       ,total_balance                as total_balance               
       ,future_instal_due_date       as future_instal_due_date      
       ,future_instal_balance        as future_instal_balance       
       ,future_instal_min_payment    as future_instal_min_payment   
       ,create_time                  as create_time   
       ,previous_installment         as previous_installment
from risk.dwd_risk_br_uw_quod_score_credit_lines_creditcard_df 
where grass_date =date_sub('${grass_date}',-1) 

;