ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
create temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';

create or replace temporary view all_loan_id_tbl as
select 
source_pk 
from risk.dwd_risk_br_uw_quod_score_credit_lines_creditcard_pre_installment_payment_df t1 
where grass_date =date_sub('${grass_date}',-1)
group by source_pk 
;

insert overwrite table risk.dwd_risk_br_uw_quod_score_credit_lines_creditcard_pre_installment_payment_df partition(grass_date ='${grass_date}')
select 
       t2.source_pk                         as source_pk                                                 
       ,t2.platform_user_id                 as platform_user_id  
       ,t2.loan_id                          as loan_id   
       ,t2.installment_id                   as installment_id
       ,concat(t2.installment_id,'_',t2.rn) as payment_id 
       ,t2.paid_date                        as paid_date
       ,t2.paid_amount                      as paid_amount
       ,t2.create_time                      as create_time                    
from (
       select
              source_pk                                                                            as source_pk                                                 
              ,t1.platform_user_id                                                                 as platform_user_id
              ,t1.loan_id                                                                          as loan_id  
              ,t1.installment_id                                                                   as installment_id
              ,concat(get_json_object(tbl.payment,'$.DatePaid.Year'),'-',get_json_object(tbl.payment,'$.DatePaid.Month'),'-',get_json_object(tbl.payment,'$.DatePaid.Day'))   as paid_date
              ,cast(get_json_object(tbl.payment,'$.AmountPaid') as double)                         as paid_amount
              ,create_time                                                                         as create_time
              ,row_number() over(partition by source_pk order by create_time )                     as rn                  
       from (
              select 
                   tt1.source_pk
                   ,tt1.platform_user_id
                   ,tt1.loan_id
                   ,tt1.installment_id
                   ,tt1.payment
                   ,tt1.create_time
              from risk.dwd_risk_br_uw_quod_score_credit_lines_creditcard_pre_installment_df tt1 
              left join all_loan_id_tbl tt2 on tt1.source_pk = tt2.source_pk
              where tt1.grass_date ='${grass_date}' 
              and tt2.source_pk is null  
       ) t1 
       lateral view explode(json_to_array(get_json_object(t1.payment,'$.Payment'))) tbl as payment       
) t2 
union all  
select 
       source_pk           as source_pk       
       ,platform_user_id   as platform_user_id
       ,loan_id            as loan_id   
       ,installment_id     as installment_id
       ,payment_id         as payment_id 
       ,paid_date          as paid_date
       ,paid_amount        as paid_amount
       ,create_time        as create_time     
from risk.dwd_risk_br_uw_quod_score_credit_lines_creditcard_pre_installment_payment_df
where grass_date =date_sub('${grass_date}',-1) 
;                  