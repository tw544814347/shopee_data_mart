/*
Author:         chengguo.liu@shopee.com
Created Time:   2023-07-07
Description:
1.计算credit_user_id维度，spl/bcl下一次还款的相关指标
2.在账单日后的，还款计划不会生成账单，所以通过分期还款计划instalment_repayment聚合成bill
update: 2023-12-14 zongyi.lu@shopee.com 新增字段 avg_weighted_remaining_tenure 用户名下SPL,BCL,HPL所有产品未结清loan的平均remaining tenure
*/
create or replace temporary view tmp_spl_id_avg_weighted_remaining_tenure as
select 
credit_user_id
,sum(principal_os_spl)     as principal_os_spl
,sum(remaining_tenure_spl) as remaining_tenure_spl
,sum(principal_os_chp)     as principal_os_chp
,sum(remaining_tenure_chp) as remaining_tenure_chp
from (
select 
credit_user_id
,loan_id 
,sum(case when biz_type =3 then principal_os else 0 end )                            as principal_os_spl
,min(case when biz_type =3 then total_term_num else 0 end) - min(case when biz_type =3 then cur_term_num else 0 end) + 1 as remaining_tenure_spl
,sum(case when biz_type =7 then principal_os else 0 end )                            as principal_os_chp
,min(case when biz_type =7 then total_term_num else 0 end) - min(case when biz_type =7 then cur_term_num else 0 end) + 1 as remaining_tenure_chp
from credit_mart.dws_spl_id_instalment_repayment_df
where grass_date ='${grass_date}'
and clear_time is null 
and biz_type in(3,7)
group by credit_user_id
,loan_id 
) a 
group by credit_user_id
;

create or replace temporary view tmp_bcl_id_avg_weighted_remaining_tenure as
select 
credit_user_id 
,sum(principal_os_bcl)     as principal_os_bcl
,sum(remaining_tenure_bcl) as remaining_tenure_bcl
from(
select 
credit_user_id
,loan_id 
,sum(principal_os)                           as principal_os_bcl
,min(total_term_num) - min(cur_term_num) + 1 as remaining_tenure_bcl
from credit_mart.dws_bcl_id_instalment_repayment_df
where grass_date ='${grass_date}'
and clear_time is null 
group by credit_user_id
,loan_id 
) a 
group by credit_user_id
;


insert overwrite table ${SCHEMA}.dws_risk_id_user_repayment_df partition (grass_date)
select  t1.credit_user_id
        ,t2.days_to_next_spl_repay
        ,t2.next_spl_bill_principal_os
        ,t3.days_to_next_bcl_repay
        ,t3.next_bcl_bill_principal_os
        ,(remaining_tenure_spl+remaining_tenure_chp+remaining_tenure_bcl) / (principal_os_spl+principal_os_chp+principal_os_bcl) as avg_weighted_remaining_tenure
        ,'${ds}' as grass_date
from    (
    select  credit_user_id
    from    (
        select  credit_user_id
        from    credit_mart.dws_spl_id_instalment_repayment_df
        where   grass_date = '${ds}'
        union all
        select  credit_user_id
        from    credit_mart.dws_bcl_id_instalment_repayment_df
        where   grass_date = '${ds}'
    )
    group by credit_user_id
) t1
left outer join (
    select  credit_user_id
            ,days_to_next_spl_repay
            ,next_spl_bill_principal_os
    from    (
        select  credit_user_id
                ,month_due_time as next_spl_due_time
                ,datediff(date(month_due_time), '${ds}') as days_to_next_spl_repay
                ,principal_os as next_spl_bill_principal_os
                ,total_amount_os as next_spl_bill_total_amount_os
                ,row_number() over(partition by credit_user_id order by month_due_time asc)as next_bill_rn
        from    (
            select  credit_user_id
                    ,month_due_time
                    ,sum(principal_os) as principal_os
                    ,sum(total_amount_os) as total_amount_os
            from    credit_mart.dws_spl_id_instalment_repayment_df
            where   grass_date = '${ds}'
              and   month_due_time > '${ds}'
            group by credit_user_id, month_due_time
            having  sum(principal_os) > 0
        )
    )
    where   next_bill_rn = 1
) t2
on      t1.credit_user_id = t2.credit_user_id
left outer join (
    select  credit_user_id
            ,days_to_next_bcl_repay
            ,next_bcl_bill_principal_os
    from    (
        select  credit_user_id
                ,month_due_time as next_bcl_due_time
                ,datediff(date(month_due_time), '${ds}') as days_to_next_bcl_repay
                ,principal_os as next_bcl_bill_principal_os
                ,total_amount_os as next_bcl_bill_total_amount_os
                ,row_number() over(partition by credit_user_id order by month_due_time asc)as next_bill_rn
        from    (
            select  credit_user_id
                    ,month_due_time
                    ,sum(principal_os) as principal_os
                    ,sum(total_amount_os) as total_amount_os
            from    credit_mart.dws_bcl_id_instalment_repayment_df
            where   grass_date = '${ds}'
              and   month_due_time > '${ds}'
            group by credit_user_id, month_due_time
            having  sum(principal_os) > 0
        )
    )
    where   next_bill_rn = 1
) t3
on      t1.credit_user_id = t3.credit_user_id
left join tmp_spl_id_avg_weighted_remaining_tenure t4 on t1.credit_user_id = t4.credit_user_id
left join tmp_bcl_id_avg_weighted_remaining_tenure t5 on t1.credit_user_id = t5.credit_user_id
;




