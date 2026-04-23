ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
create temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';

create or replace temporary view all_loan_id_tbl as
select 
source_pk 
from risk.dwd_risk_br_uw_quod_score_credit_lines_revolving_pre_installment_df t1 
where grass_date =date_sub('${grass_date}',-1)
group by source_pk 
;

insert overwrite table risk.dwd_risk_br_uw_quod_score_credit_lines_revolving_pre_installment_df partition(grass_date ='${grass_date}')
select 
       t2.source_pk                     as source_pk                                                 
       ,t2.platform_user_id             as platform_user_id  
       ,t2.loan_id                      as loan_id   
       ,concat(t2.loan_id,'_',t2.rn)    as installment_id
       ,t2.pre_instal_closing_date      as pre_instal_closing_date
       ,t2.pre_instal_used_amt          as pre_instal_used_amt
       ,t2.create_time                  as create_time                          

from (
       select
              source_pk                                                                                                                                                                                     as source_pk                                                 
              ,t1.platform_user_id                                                                                                                                                                          as platform_user_id
              ,t1.loan_id                                                                                                                                                                                   as loan_id  
              ,concat(get_json_object(tbl.previous_installment,'$.DateClosing.Year'),'-',get_json_object(tbl.previous_installment,'$.DateClosing.Month'),'-',get_json_object(tbl.previous_installment,'$.DateClosing.Day'))   as pre_instal_closing_date
              ,cast(get_json_object(tbl.previous_installment,'$.AmountUsed') as double )                                                                                                                     as pre_instal_used_amt
              ,create_time                                                                                                                                                                                  as create_time
              ,row_number() over(partition by source_pk order by create_time )                                                                                                                              as rn                  
       from (
              select
                  tt1.source_pk
                  ,tt1.platform_user_id
                  ,tt1.loan_id 
                  ,tt1.previous_installment 
                  ,tt1.create_time
              from risk.dwd_risk_br_uw_quod_score_credit_lines_revolving_df tt1 
              left join all_loan_id_tbl tt2 on tt1.source_pk = tt2.source_pk
              where tt1.grass_date ='${grass_date}' 
              and tt2.source_pk is null 
       ) t1  
       lateral view explode(json_to_array(get_json_object(t1.previous_installment,'$.PreviousInstallment'))) tbl as previous_installment 
) t2 
union all 
select 
       source_pk                     as source_pk                                                 
       ,platform_user_id             as platform_user_id  
       ,loan_id                      as loan_id   
       ,installment_id               as installment_id
       ,pre_instal_closing_date      as pre_instal_closing_date
       ,pre_instal_used_amt          as pre_instal_used_amt
       ,create_time                  as create_time  
from risk.dwd_risk_br_uw_quod_score_credit_lines_revolving_pre_installment_df
where grass_date =date_sub('${grass_date}',-1) 

;                  