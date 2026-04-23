ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
create temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';

create or replace temporary view all_loan_id_tbl as
select 
source_pk 
from risk.dwd_risk_br_uw_quod_score_credit_lines_loan_future_installment_df t1 
where grass_date =date_sub('${grass_date}',-1)
group by source_pk 
;

insert overwrite table risk.dwd_risk_br_uw_quod_score_credit_lines_loan_future_installment_df partition(grass_date ='${grass_date}')
select 
       t2.source_pk                     as source_pk                                                 
       ,t2.platform_user_id             as platform_user_id  
       ,t2.loan_id                      as loan_id   
       ,concat(t2.loan_id,'_',t2.rn)    as installment_id
       ,t2.future_instal_due_date       as future_instal_due_date
       ,t2.future_instal_periodicity    as future_instal_periodicity
       ,t2.future_instal_balance        as future_instal_balance
       ,t2.remain_instal_cnt            as remain_instal_cnt
       ,t2.unpaid_instal_cnt            as unpaid_instal_cnt
       ,t2.create_time                  as create_time                          

from (
       select
              source_pk                                                                                                                                                                                     as source_pk                                                 
              ,t1.platform_user_id                                                                                                                                                                          as platform_user_id
              ,t1.loan_id                                                                                                                                                                                   as loan_id  
              ,concat(get_json_object(tbl.future_installment,'$.DateDue.Year'),'-',get_json_object(tbl.future_installment,'$.DateDue.Month'),'-',get_json_object(tbl.future_installment,'$.DateDue.Day'))   as future_instal_due_date
              ,get_json_object(tbl.future_installment,'$.Periodicity')                                                                                                                                      as future_instal_periodicity
              ,cast(get_json_object(tbl.future_installment,'$.AmountTotalBalance') as double)                                                                                                               as future_instal_balance
              ,cast(get_json_object(tbl.future_installment,'$.CountRemainingInstallments') as bigint)                                                                                                       as remain_instal_cnt
              ,create_time                                                                                                                                                                                  as create_time
              ,cast(get_json_object(tbl.future_installment,'$.CountInstallmentsYetToPay')  as bigint)                                                                                                       as unpaid_instal_cnt
              ,row_number() over(partition by source_pk order by create_time )                                                                                                                              as rn                  
       from (
              select
                  tt1.source_pk
                  ,tt1.platform_user_id
                  ,tt1.loan_id 
                  ,tt1.future_installment 
                  ,tt1.create_time
              from risk.dwd_risk_br_uw_quod_score_credit_lines_loan_df tt1 
              left join all_loan_id_tbl tt2 on tt1.source_pk = tt2.source_pk
              where tt1.grass_date ='${grass_date}' 
              and tt2.source_pk is null 
       ) t1  
       lateral view explode(json_to_array(get_json_object(t1.future_installment,'$.FutureInstallment'))) tbl as future_installment 
) t2 
union all 
select 
       source_pk                           as source_pk                       
       ,platform_user_id                   as platform_user_id  
       ,loan_id                            as loan_id   
       ,installment_id                     as installment_id
       ,future_instal_due_date             as future_instal_due_date
       ,future_instal_periodicity          as future_instal_periodicity
       ,future_instal_balance              as future_instal_balance
       ,remain_instal_cnt                  as remain_instal_cnt
       ,unpaid_instal_cnt                  as unpaid_instal_cnt
       ,create_time                        as create_time                     
from risk.dwd_risk_br_uw_quod_score_credit_lines_loan_future_installment_df
where grass_date =date_sub('${grass_date}',-1) 

;                  