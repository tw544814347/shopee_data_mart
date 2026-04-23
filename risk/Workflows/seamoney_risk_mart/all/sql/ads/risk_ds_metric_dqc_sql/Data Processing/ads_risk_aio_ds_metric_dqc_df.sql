--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-05-01
-- Theme Domain：       ds metric相关的拉链表监控
-- Description:         ds metric相关的拉链表监控
-- Data Granularity:    bill_id/instalment_id/loan_id
-- 变更历史
-- update by zongyi.lu 2024-08-19 新增拉链表(bill_id/instalment_id/loan_id)&start_date 唯一
--********************************************************************--

-- 以下分别是bill_id instalment_id loan_id 拉链表的aio外表，仅作用于dqc用
drop table if exists ${SCHEMA}.dws_aio_bill_repayment_zi_dqc;
create external table if not exists ${SCHEMA}.dws_aio_bill_repayment_zi_dqc
(
bill_id                 string              comment "Unique id of repay loancore生成唯一id"
,credit_user_id         string              comment "Unique id of credit user 平台用户id"
,platform_user_id       string              comment "Shopee platform user id credit系统用户ID"
,bill_term              string              comment "Bill term in old version 账期"
,month_bill_time        string              comment "time when instalment bill will be issued to user   出账日期"
,month_due_time         string              comment "Time when the bill will turn overdue 逾期日"
,principal_repayable    decimal(30,10)      comment "Pincipal amount repayable 应还本金"
,principal_os           decimal(30,10)      comment "Pincipal amount outstanding 剩余本金"
,principal_refund       decimal(30,10)      comment "Pincipal amount refund 退还本金"       
,principal_deduct       decimal(30,10)      comment "Pincipal amount deduct 减免本金"
,total_amount_repayable decimal(30,10)      comment "Total amount repayable 应还总费用"
,total_amount_refund    decimal(30,10)      comment "Total amount refund 退还总费用"
,total_amount_deduct    decimal(30,10)      comment "Total amount deduct减免总费用"
,total_amount_os        decimal(30,10)      comment "Total amount outstanding 剩余总费用"
,start_date             string              comment "start_date 剩余os开始时间"
) partitioned by (
 garss_region          string 
,product_id           string 
,end_date                       string              comment "start_date 剩余os结束时间"
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_aio_bill_repayment_zi_v2';

msck repair table ${SCHEMA}.dws_aio_bill_repayment_zi_dqc;

drop table if exists ${SCHEMA}.dws_aio_instalment_repayment_zi_dqc;
create external table if not exists ${SCHEMA}.dws_aio_instalment_repayment_zi_dqc
(
instalment_id                   string              comment "Unique ID of instalments 还款计划id"
,loan_id                        string              comment "loan_id 借据"
,credit_user_id                 string              comment "Unique id of credit user 平台用户id"
,platform_user_id               string              comment "Shopee platform user id credit系统用户ID"
,month_due_time                 string              comment "Time when the instalment will turn overdue 逾期日"
,cur_term_num                   string              comment "cur_term_num 当前期次"
,principal_repayable            decimal(30,10)      comment "Pincipal amount repayable 应还本金"
,principal_os                   decimal(30,10)      comment "Pincipal amount outstanding 剩余本金"
,principal_refund               decimal(30,10)      comment "Pincipal amount refund 退还本金"       
,principal_deduct               decimal(30,10)      comment "Pincipal amount deduct 减免本金"
,total_amount_repayable         decimal(30,10)      comment "Total amount repayable 应还总费用"
,total_amount_refund            decimal(30,10)      comment "Total amount refund 退还总费用"
,total_amount_deduct            decimal(30,10)      comment "Total amount deduct减免总费用"
,total_amount_os                decimal(30,10)      comment "Total amount outstanding 剩余总费用"
,loan_disbursed_month           string              comment "the first bill term of the loan.if the loan hasn't been confirmed, the value is null. 首期借据，如果借据还未确认，则该值为null"
,first_instalment_due_time      string              comment "time of the first instalment due 分期付款首期逾期时间"
,bill_due_day                   int                 comment "day(date(first_instalment_due_time))"
,new_repeat_user                string              comment "is_first_bill_loan=1 then new else repeat"
,loan_tenure                    int                 comment "loan_tenure 总期数"
,loan_months_on_book            bigint              comment "Months after bill due date 逾期日相差月份"
,loan_months_after_due          bigint              comment "number of months after bill due date, regardless of clear_status 当前与首期逾期日相差月数"
,loan_principal_repayable       decimal(30,10)      comment "loan Pincipal amount repayable 应还本金"
,loan_principal_os              decimal(30,10)      comment "loan Pincipal amount outstanding 剩余本金"
,start_date                     string              comment "start_date 剩余os开始时间"
) partitioned by(
    garss_region          string 
    ,product_id           string 
    ,end_date                       string              comment "start_date 剩余os结束时间"
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_aio_instalment_repayment_zi_v2';
;

msck repair table ${SCHEMA}.dws_aio_instalment_repayment_zi_dqc;

drop table if exists ${SCHEMA}.dws_aio_loan_repayment_tatal_amount_zi_dqc;
create external table if not exists ${SCHEMA}.dws_aio_loan_repayment_tatal_amount_zi_dqc
(
platform_user_id                 string              comment "Shopee platform user id credit系统用户ID"
,credit_user_id                  string              comment "Unique id of credit user 平台用户id"
,loan_id                         string              comment "loan_id"
,loan_disbursed_month            string              comment "the first bill term of the loan.if the loan hasn't been confirmed, the value is null. 首期借据，如果借据还未确认，则该值为null"
,first_instalment_due_time       string              comment "time of the first instalment due 分期付款首期逾期时间"
,bill_due_day                    int                 comment "day(date(first_instalment_due_time))"
,new_repeat_user                 string              comment "is_first_bill_loan=1 then new else repeat"
,loan_tenure                     int                 comment "loan_tenure 总期数"
,months_on_book                  bigint              comment "Months after bill due date 逾期日相差月份"
,months_after_due                bigint              comment "number of months after bill due date, regardless of clear_status 当前与首期逾期日相差月数"
,clear_status                    bigint              comment "1:uncleared 2:partial cleared 3:cleared"
,dpd_eod                         bigint              comment "dpd_eod"
,principal_repayable             decimal(30,10)      comment "Pincipal amount repayable 应还本金"
,principal_os                    decimal(30,10)      comment "Pincipal amount outstanding 剩余本金"
,total_amount_repayable          decimal(30,10)      comment "repayable amount outstanding 应还总额"          
,total_amount_os                 decimal(30,10)      comment "repayable amount outstanding 剩余总额"
,start_date                      string              comment "start_date 剩余os开始时间"
) 
partitioned by(
    garss_region          string 
    ,product_id           string 
    ,end_date                       string              comment "start_date 剩余os结束时间"
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_aio_loan_repayment_total_amount_zi';
;

msck repair table ${SCHEMA}.dws_aio_loan_repayment_tatal_amount_zi_dqc;

drop table if exists ${SCHEMA}.dws_aio_loan_repayment_zi_dqc;
create external table if not exists ${SCHEMA}.dws_aio_loan_repayment_zi_dqc
(
platform_user_id                 string              comment "Shopee platform user id credit系统用户ID"
,credit_user_id                  string              comment "Unique id of credit user 平台用户id"
,loan_id                         string              comment "loan_id"
,loan_disbursed_month            string              comment "the first bill term of the loan.if the loan hasn't been confirmed, the value is null. 首期借据，如果借据还未确认，则该值为null"
,first_instalment_due_time       string              comment "time of the first instalment due 分期付款首期逾期时间"
,bill_due_day                    int                 comment "day(date(first_instalment_due_time))"
,new_repeat_user                 string              comment "is_first_bill_loan=1 then new else repeat"
,loan_tenure                     int                 comment "loan_tenure 总期数"
,months_on_book                  bigint              comment "Months after bill due date 逾期日相差月份"
,months_after_due                bigint              comment "number of months after bill due date, regardless of clear_status 当前与首期逾期日相差月数"
,clear_status                    bigint              comment "1:uncleared 2:partial cleared 3:cleared"
,dpd_eod                         bigint              comment "dpd_eod"
,principal_repayable             decimal(30,10)      comment "Pincipal amount repayable 应还本金"
,principal_os                    decimal(30,10)      comment "Pincipal amount outstanding 剩余本金"
,start_date                      string              comment "start_date 剩余os开始时间"

) 
partitioned by(
    garss_region          string 
    ,product_id           string 
    ,end_date                       string              comment "start_date 剩余os结束时间"
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_aio_loan_repayment_zi_v2';
;

msck repair table ${SCHEMA}.dws_aio_loan_repayment_zi_dqc;


insert overwrite table risk.ads_risk_aio_ds_metric_dqc_df partition(grass_date='${grass_date}')
select 
dqc_type
,grass_region as grass_region
,product_id
from (
-- 监控start_date>end_date的情况
select 
"error: bill start_date>end_date" as dqc_type
,t1.garss_region as grass_region
,t1.product_id
from risk.dws_aio_bill_repayment_zi_dqc  t1 
where start_date > end_date  
and garss_region not in('BR')
group by t1.garss_region
,t1.product_id
union all 
select 
"error: instalment start_date>end_date" as dqc_type
,t1.garss_region as grass_region
,t1.product_id
from risk.dws_aio_instalment_repayment_zi_dqc  t1 
where start_date > end_date 
and garss_region not in('BR')
group by t1.garss_region
,t1.product_id
union all 
select 
"error: loan start_date>end_date" as dqc_type
,t1.garss_region as grass_region
,t1.product_id
from risk.dws_aio_loan_repayment_zi_dqc  t1 
where start_date > end_date  
group by t1.garss_region
,t1.product_id

-- 监控同一个bill & loan 是否有重复的start_date 
union all 
select 
"error: bill start_date is duplicated" as dqc_type
,t1.garss_region as grass_region
,t1.product_id
from (
    select 
     garss_region
     ,product_id
     ,bill_id  
     ,start_date 
     ,count(1) cnt 
    from risk.dws_aio_bill_repayment_zi_dqc
    where garss_region not in('BR')
    group by garss_region
     ,product_id
     ,bill_id  
     ,start_date
    having count(1)>1
)  t1 
where cnt>1
group by t1.garss_region
,t1.product_id
union all 
select 
"error: instalment start_date is duplicated" as dqc_type
,t1.garss_region as grass_region
,t1.product_id
from (
    select 
     garss_region
     ,product_id
     ,instalment_id  
     ,start_date 
     ,count(1) cnt 
    from risk.dws_aio_instalment_repayment_zi_dqc
    where garss_region not in('BR')
    group by garss_region
     ,product_id
     ,instalment_id  
     ,start_date
    having count(1)>1
)  t1 
where cnt>1 
group by t1.garss_region
,t1.product_id
union all 
-- select 
-- "error: loan start_date is duplicated" as dqc_type
-- ,t1.garss_region as grass_region
-- ,t1.product_id
-- from (
--     select 
--      garss_region
--      ,product_id
--      ,loan_id  
--      ,start_date 
--      ,count(1) cnt 
--     from risk.dws_aio_loan_repayment_tatal_amount_zi_dqc
--     where garss_region not in('BR')
--     group by garss_region
--      ,product_id
--      ,loan_id  
--      ,start_date
--     having count(1)>1
-- )  t1 
-- where cnt>1  
-- group by t1.garss_region
-- ,t1.product_id

-- union all 
select 
"error: loan start_date is duplicated" as dqc_type
,t1.garss_region as grass_region
,t1.product_id
-- from risk.dws_aio_loan_repayment_zi_dqc  t1 
from (
    select 
     garss_region
     ,product_id
     ,loan_id  
     ,start_date 
     ,count(1) cnt 
    from risk.dws_aio_loan_repayment_zi_dqc
    where garss_region not in('BR')
    group by garss_region
     ,product_id
     ,loan_id  
     ,start_date
    having count(1)>1
)  t1 
where cnt>1  
group by t1.garss_region
,t1.product_id
-- 监控os为负数
union all 
select 
"error: bill principal_os<0" as dqc_type
,t1.garss_region as  grass_region
,t1.product_id
from risk.dws_aio_bill_repayment_zi_dqc  t1 
where principal_os<0  
and garss_region not in('BR')
and bill_id not in ('1_1967264289937337400202509')  -- 2025-10-20 手动忽略先，BE侧数据问题
group by t1.garss_region
,t1.product_id
union all 
select 
"error: instalment principal_os<0" as dqc_type
,t1.garss_region as  grass_region
,t1.product_id
from risk.dws_aio_instalment_repayment_zi_dqc  t1 
where principal_os<0
and garss_region not in('BR')
and instalment_id not in ('2046218121580204050-03') -- 2025-10-20 手动忽略先，BE侧数据问题
group by t1.garss_region
,t1.product_id
union all 
select 
"error: loan total_amount_os<0" as dqc_type
,t1.garss_region as  grass_region
,t1.product_id
from risk.dws_aio_loan_repayment_tatal_amount_zi_dqc  t1 
where total_amount_os<0  
and garss_region not in('BR')
and (t1.garss_region not in('ID')and t1.end_date not in('2024-07-18','2023-08-14'))
and loan_id not in ('1698286668093795328', '1698200731955439617', '1698207923198699520','1703275059143193601', '1698709566746994689')
group by t1.garss_region
,t1.product_id
union all 
select 
"error: loan principal_os<0" as dqc_type
,t1.garss_region as  grass_region
,t1.product_id
from risk.dws_aio_loan_repayment_zi_dqc  t1 
where principal_os<0
and garss_region not in('BR')
and (t1.garss_region not in('ID')and t1.end_date not in('2024-07-18','2023-08-14'))
group by t1.garss_region
,t1.product_id

-- 监控os与credit mart 是否一致
union all 
select 
'error: bill risk os <> credit os' as dqc_type
,'ID' as  grass_region
,'3' as product_id
from (
    select  
     a.bill_id
    ,a.principal_os 
    ,b.principal_os as principal_os_b 
    from(
        select 
        bill_id 
        ,sum(principal_os) as principal_os
        from risk.dws_risk_spl_id_bill_repayment_zi_v2
        where end_date='9999-12-31'
        and principal_os>0
        and principal_repayable>0
        group by bill_id
    ) a 
    join (
    select 
    bill_id 
    ,sum(principal_os) as principal_os
    from credit_mart.dws_spl_id_bill_repayment_df
    where grass_date ='${grass_date}'
    and principal_os>0
    and principal_repayable>0
    group by bill_id 
    ) b on a.bill_id = b.bill_id
    where a.principal_os<>b.principal_os
) a 

union all 
select 
'error: bill risk os <> credit os' as dqc_type
,'TH' as  grass_region
,'3' as product_id
from (
    select  
     a.bill_id
    ,a.principal_os 
    ,b.principal_os as principal_os_b 
from(
    select 
    bill_id 
    ,sum(principal_os) as principal_os
    from risk.dws_risk_spl_th_bill_repayment_zi_v2
    where end_date='9999-12-31'
    and principal_os>0
    and principal_repayable>0
    group by bill_id
) a 
join (
select 
bill_id 
,sum(principal_os) as principal_os
from credit_mart.dws_spl_th_bill_repayment_df
where grass_date ='${grass_date}'
and principal_os>0
and principal_repayable>0
group by bill_id 
) b on a.bill_id = b.bill_id
where a.principal_os<>b.principal_os
) a 

union all 
select 
'error: bill risk os <> credit os' as dqc_type
,'TH' as  grass_region
,'2' as product_id
from (
    select  
     a.bill_id
    ,a.principal_os 
    ,b.principal_os as principal_os_b 
from(
    select 
    bill_id 
    ,sum(principal_os) as principal_os
    from risk.dws_risk_scl_th_bill_repayment_zi_v2
    where end_date='9999-12-31'
    and bill_id not in('2_1578856725262466048202310')
    and principal_os>0
    and principal_repayable>0
    group by bill_id
) a 
join (
select 
bill_id 
,sum(principal_os) as principal_os
from credit_mart.dws_scl_th_bill_repayment_df
where grass_date ='${grass_date}'
and principal_os>0
and principal_repayable>0
group by bill_id 
) b on a.bill_id = b.bill_id
where a.principal_os<>b.principal_os
) a 
union all 
select 
'error: bill risk os <> credit os' as dqc_type
,'TH' as  grass_region
,'1' as product_id
from (
    select  
     a.bill_id
    ,a.principal_os 
    ,b.principal_os as principal_os_b 
from(
    select 
    bill_id 
    ,sum(principal_os) as principal_os
    from risk.dws_risk_bcl_th_bill_repayment_zi_v2
    where end_date='9999-12-31'
    and principal_os>0
    and principal_repayable>0
    group by bill_id
) a 
join (
select 
bill_id 
,sum(principal_os) as principal_os
from credit_mart.dws_bcl_th_bill_repayment_df
where grass_date ='${grass_date}'
and principal_os>0
and principal_repayable>0
group by bill_id 
) b on a.bill_id = b.bill_id
where a.principal_os<>b.principal_os
) a 

union all 
select 
'error: bill risk os <> credit os' as dqc_type
,'PH' as  grass_region
,'3' as product_id
from (
    select  
     a.bill_id
    ,a.principal_os 
    ,b.principal_os as principal_os_b 
from(
    select 
    bill_id 
    ,sum(principal_os) as principal_os
    from risk.dws_risk_spl_ph_bill_repayment_zi_v2
    where end_date='9999-12-31'
    and principal_os>0
    and principal_repayable>0
    group by bill_id
) a 
join (
select 
bill_id 
,sum(principal_os) as principal_os
from credit_mart.dws_spl_ph_bill_repayment_df
where grass_date ='${grass_date}'
and principal_os>0
and principal_repayable>0
group by bill_id 
) b on a.bill_id = b.bill_id
where a.principal_os<>b.principal_os
) a 

union all 
select  
'error: bill risk os <> credit os' as dqc_type
,'SG' as  grass_region
,'3' as product_id
from (
    select  
     a.bill_id
    ,a.principal_os 
    ,b.principal_os as principal_os_b 
from(
    select 
    bill_id 
    ,sum(principal_os) as principal_os
    from risk.dws_risk_spl_sg_bill_repayment_zi_v2
    where end_date='9999-12-31'
    and principal_os>0
    and principal_repayable>0
    group by bill_id
) a 
join (
select 
bill_id 
,sum(principal_os) as principal_os
from credit_mart.dws_spl_sg_bill_repayment_df
where grass_date ='${grass_date}'
and principal_os>0
and principal_repayable>0
group by bill_id 
) b on a.bill_id = b.bill_id
where a.principal_os<>b.principal_os
) a 

union all 
select 
'error: bill risk os <> credit os' as dqc_type
,'MY' as  grass_region
,'3' as product_id
from (
    select  
     a.bill_id
    ,a.principal_os 
    ,b.principal_os as principal_os_b 
from(
    select 
    bill_id 
    ,sum(principal_os) as principal_os
    from risk.dws_risk_spl_my_bill_repayment_zi_v2
    where end_date='9999-12-31'
    and principal_os>0
    and principal_repayable>0
    group by bill_id
) a 
join (
select 
bill_id 
,sum(principal_os) as principal_os
from credit_mart.dws_spl_my_bill_repayment_df
where grass_date ='${grass_date}'
and principal_os>0
and principal_repayable>0
group by bill_id 
) b on a.bill_id = b.bill_id
where a.principal_os<>b.principal_os
) a 
-- instalment os对比
union all 
select 
'error: instalment_id risk os <> credit os' as dqc_type
,'MY' as  grass_region
,'1' as product_id
from (
    select  
     a.instalment_id
    ,a.principal_os 
    ,b.principal_os as principal_os_b 
from(
    select 
    t1.instalment_id 
    ,sum(principal_os) as principal_os
    from risk.dws_risk_bcl_my_instalment_repayment_zi_v2 t1 
    left join (
        select 
        instalment_id
        ,count(1)
        from risk.dws_risk_bcl_my_instalment_repayment_zi_v2 
        where end_date='9999-12-31'
        group by instalment_id
        having count(1) > 1
    ) t2 on t1.instalment_id = t2.instalment_id
    where end_date='9999-12-31'
    and principal_os>0
    and principal_repayable>0
    and t2.instalment_id is null
    group by t1.instalment_id
) a 
join (
select 
instalment_id 
,sum(principal_os) as principal_os
from credit_mart.dws_spl_my_instalment_repayment_df
where grass_date ='${grass_date}'
and principal_os>0
and principal_repayable>0
group by instalment_id 
) b on a.instalment_id = b.instalment_id
where a.principal_os<>b.principal_os
) a 
union all 
select 
'error: instalment_id risk os <> credit os' as dqc_type
,'ID' as  grass_region
,'2' as product_id
from (
    select  
     a.instalment_id
    ,a.principal_os 
    ,b.principal_os as principal_os_b 
from(
    select 
    t1.instalment_id 
    ,sum(principal_os) as principal_os
    from risk.dws_risk_scl_id_instalment_repayment_zi_v2 t1 
    left join (
        select 
        instalment_id
        ,count(1)
        from risk.dws_risk_scl_id_instalment_repayment_zi_v2 
        where end_date='9999-12-31'
        group by instalment_id
        having count(1) > 1
    ) t2 on t1.instalment_id = t2.instalment_id
    where end_date='9999-12-31'
    and principal_os>0
    and principal_repayable>0
    and t2.instalment_id is null
    group by t1.instalment_id
) a 
join (
select 
instalment_id 
,sum(principal_os) as principal_os
from credit_mart.dws_scl_id_instalment_repayment_df
where grass_date ='${grass_date}'
and principal_os>0
and principal_repayable>0
group by instalment_id 
) b on a.instalment_id = b.instalment_id
where a.principal_os<>b.principal_os
) a 

union all 
select 
'error: instalment_id risk os <> credit os' as dqc_type
,'TH' as  grass_region
,'2' as product_id
from (
    select  
     a.instalment_id
    ,a.principal_os 
    ,b.principal_os as principal_os_b 
from(
    select 
    t1.instalment_id 
    ,sum(principal_os) as principal_os
    from risk.dws_risk_scl_th_instalment_repayment_zi_v2 t1 
    left join (
        select 
        instalment_id
        ,count(1)
        from risk.dws_risk_scl_th_instalment_repayment_zi_v2 
        where end_date='9999-12-31'
        group by instalment_id
        having count(1) > 1
    ) t2 on t1.instalment_id = t2.instalment_id
    where end_date='9999-12-31'
    and principal_os>0
    and principal_repayable>0
    and t2.instalment_id is null
    group by t1.instalment_id
) a 
join (
select 
instalment_id 
,sum(principal_os) as principal_os
from credit_mart.dws_scl_th_instalment_repayment_df
where grass_date ='${grass_date}'
and principal_os>0
and principal_repayable>0
group by instalment_id 
) b on a.instalment_id = b.instalment_id
where a.principal_os<>b.principal_os
) a

union all 
select 
'error: instalment_id risk os <> credit os' as dqc_type
,'MY' as  grass_region
,'2' as product_id
from (
    select  
     a.instalment_id
    ,a.principal_os 
    ,b.principal_os as principal_os_b 
from(
    select 
    t1.instalment_id 
    ,sum(principal_os) as principal_os
    from risk.dws_risk_scl_my_instalment_repayment_zi_v2 t1 
    left join (
        select 
        instalment_id
        ,count(1)
        from risk.dws_risk_scl_my_instalment_repayment_zi_v2 
        where end_date='9999-12-31'
        group by instalment_id
        having count(1) > 1
    ) t2 on t1.instalment_id = t2.instalment_id
    where end_date='9999-12-31'
    and principal_os>0
    and principal_repayable>0
    and t2.instalment_id is null
    group by t1.instalment_id
) a 
join (
select 
instalment_id 
,sum(principal_os) as principal_os
from credit_mart.dws_scl_my_instalment_repayment_df
where grass_date ='${grass_date}'
and principal_os>0
and principal_repayable>0
group by instalment_id 
) b on a.instalment_id = b.instalment_id
where a.principal_os<>b.principal_os
) a 

union all 
select 
'error: instalment_id risk os <> credit os' as dqc_type
,'VN' as  grass_region
,'2' as product_id
from (
    select  
     a.instalment_id
    ,a.principal_os 
    ,b.principal_os as principal_os_b 
from(
    select 
    t1.instalment_id 
    ,sum(principal_os) as principal_os
    from risk.dws_risk_scl_vn_instalment_repayment_zi_v2 t1 
    left join (
        select 
        instalment_id
        ,count(1)
        from risk.dws_risk_scl_vn_instalment_repayment_zi_v2 
        where end_date='9999-12-31'
        group by instalment_id
        having count(1) > 1
    ) t2 on t1.instalment_id = t2.instalment_id
    where end_date='9999-12-31'
    and principal_os>0
    and principal_repayable>0
    and t2.instalment_id is null
    group by t1.instalment_id
) a 
join (
select 
instalment_id 
,sum(principal_os) as principal_os
from credit_mart.dws_scl_vn_instalment_repayment_df
where grass_date ='${grass_date}'
and principal_os>0
and principal_repayable>0
group by instalment_id 
) b on a.instalment_id = b.instalment_id
where a.principal_os<>b.principal_os
) a 
union all
select 
'error: instalment_id risk os <> credit os' as dqc_type
,'PH' as  grass_region
,'2' as product_id
from (
    select  
     a.instalment_id
    ,a.principal_os 
    ,b.principal_os as principal_os_b 
from(
    select 
    t1.instalment_id 
    ,sum(principal_os) as principal_os
    from risk.dws_risk_scl_ph_instalment_repayment_zi_v2 t1 
    left join (
        select 
        instalment_id
        ,count(1)
        from risk.dws_risk_scl_ph_instalment_repayment_zi_v2 
        where end_date='9999-12-31'
        group by instalment_id
        having count(1) > 1
    ) t2 on t1.instalment_id = t2.instalment_id
    where end_date='9999-12-31'
    and principal_os>0
    and principal_repayable>0
    and t2.instalment_id is null
    group by t1.instalment_id
) a 
join (
select 
instalment_id 
,sum(principal_os) as principal_os
from credit_mart.dws_scl_ph_instalment_repayment_df
where grass_date ='${grass_date}'
and principal_os>0
and principal_repayable>0
group by instalment_id 
) b on a.instalment_id = b.instalment_id
where a.principal_os<>b.principal_os
) a 

union all
select 
'error: instalment_id risk os <> credit os' as dqc_type
,'ID' as  grass_region
,'3' as product_id
from (
    select  
     a.instalment_id
    ,a.principal_os 
    ,b.principal_os as principal_os_b 
from(
    select 
    t1.instalment_id 
    ,sum(principal_os) as principal_os
    from risk.dws_risk_spl_id_instalment_repayment_zi_v2 t1 
    left join (
        select 
        instalment_id
        ,count(1)
        from risk.dws_risk_spl_id_instalment_repayment_zi_v2 
        where end_date='9999-12-31'
        group by instalment_id
        having count(1) > 1
    ) t2 on t1.instalment_id = t2.instalment_id
    where end_date='9999-12-31'
    and principal_os>0
    and principal_repayable>0
    and t2.instalment_id is null
    group by t1.instalment_id
) a 
join (
select 
instalment_id 
,sum(principal_os) as principal_os
from credit_mart.dws_spl_id_instalment_repayment_df
where grass_date ='${grass_date}'
and principal_os>0
and principal_repayable>0
group by instalment_id 
) b on a.instalment_id = b.instalment_id
where a.principal_os<>b.principal_os
) a 

union all
select 
'error: instalment_id risk os <> credit os' as dqc_type
,'MY' as  grass_region
,'3' as product_id
from (
    select  
     a.instalment_id
    ,a.principal_os 
    ,b.principal_os as principal_os_b 
from(
    select 
    t1.instalment_id 
    ,sum(principal_os) as principal_os
    from risk.dws_risk_spl_my_instalment_repayment_zi_v2 t1 
    left join (
        select 
        instalment_id
        ,count(1)
        from risk.dws_risk_spl_my_instalment_repayment_zi_v2 
        where end_date='9999-12-31'
        group by instalment_id
        having count(1) > 1
    ) t2 on t1.instalment_id = t2.instalment_id
    where end_date='9999-12-31'
    and principal_os>0
    and principal_repayable>0
    and t2.instalment_id is null
    group by t1.instalment_id
) a 
join (
select 
instalment_id 
,sum(principal_os) as principal_os
from credit_mart.dws_spl_my_instalment_repayment_df
where grass_date ='${grass_date}'
and principal_os>0
and principal_repayable>0
group by instalment_id 
) b on a.instalment_id = b.instalment_id
where a.principal_os<>b.principal_os
) a 

union all
select 
'error: instalment_id risk os <> credit os' as dqc_type
,'SG' as  grass_region
,'3' as product_id
from (
    select  
     a.instalment_id
    ,a.principal_os 
    ,b.principal_os as principal_os_b 
from(
    select 
    t1.instalment_id 
    ,sum(principal_os) as principal_os
    from risk.dws_risk_spl_sg_instalment_repayment_zi_v2 t1 
    left join (
        select 
        instalment_id
        ,count(1)
        from risk.dws_risk_spl_sg_instalment_repayment_zi_v2 
        where end_date='9999-12-31'
        group by instalment_id
        having count(1) > 1
    ) t2 on t1.instalment_id = t2.instalment_id
    where end_date='9999-12-31'
    and principal_os>0
    and principal_repayable>0
    and t2.instalment_id is null
    group by t1.instalment_id
) a 
join (
select 
instalment_id 
,sum(principal_os) as principal_os
from credit_mart.dws_spl_sg_instalment_repayment_df
where grass_date ='${grass_date}'
and principal_os>0
and principal_repayable>0
group by instalment_id 
) b on a.instalment_id = b.instalment_id
where a.principal_os<>b.principal_os
) a 

union all
select 
'error: instalment_id risk os <> credit os' as dqc_type
,'TH' as  grass_region
,'3' as product_id
from (
    select  
     a.instalment_id
    ,a.principal_os 
    ,b.principal_os as principal_os_b 
from(
    select 
    t1.instalment_id 
    ,sum(principal_os) as principal_os
    from risk.dws_risk_spl_th_instalment_repayment_zi_v2 t1 
    left join (
        select 
        instalment_id
        ,count(1)
        from risk.dws_risk_spl_th_instalment_repayment_zi_v2 
        where end_date='9999-12-31'
        group by instalment_id
        having count(1) > 1
    ) t2 on t1.instalment_id = t2.instalment_id
    where end_date='9999-12-31'
    and principal_os>0
    and principal_repayable>0
    and t2.instalment_id is null
    group by t1.instalment_id
) a 
join (
select 
instalment_id 
,sum(principal_os) as principal_os
from credit_mart.dws_spl_th_instalment_repayment_df
where grass_date ='${grass_date}'
and principal_os>0
and principal_repayable>0
group by instalment_id 
) b on a.instalment_id = b.instalment_id
where a.principal_os<>b.principal_os
) a 

union all
select 
'error: instalment_id risk os <> credit os' as dqc_type
,'VN' as  grass_region
,'3' as product_id
from (
    select  
     a.instalment_id
    ,a.principal_os 
    ,b.principal_os as principal_os_b 
from(
    select 
    t1.instalment_id 
    ,sum(principal_os) as principal_os
    from risk.dws_risk_spl_vn_instalment_repayment_zi_v2 t1 
    left join (
        select 
        instalment_id
        ,count(1)
        from risk.dws_risk_spl_vn_instalment_repayment_zi_v2 
        where end_date='9999-12-31'
        group by instalment_id
        having count(1) > 1
    ) t2 on t1.instalment_id = t2.instalment_id
    where end_date='9999-12-31'
    and principal_os>0
    and principal_repayable>0
    and t2.instalment_id is null
    group by t1.instalment_id
) a 
join (
select 
instalment_id 
,sum(principal_os) as principal_os
from credit_mart.dws_spl_vn_instalment_repayment_df
where grass_date ='${grass_date}'
and principal_os>0
and principal_repayable>0
group by instalment_id 
) b on a.instalment_id = b.instalment_id
where a.principal_os<>b.principal_os
) a 

union all
select 
'error: instalment_id risk os <> credit os' as dqc_type
,'PH' as  grass_region
,'3' as product_id
from (
    select  
     a.instalment_id
    ,a.principal_os 
    ,b.principal_os as principal_os_b 
from(
    select 
    t1.instalment_id 
    ,sum(principal_os) as principal_os
    from risk.dws_risk_spl_ph_instalment_repayment_zi_v2 t1 
    left join (
        select 
        instalment_id
        ,count(1)
        from risk.dws_risk_spl_ph_instalment_repayment_zi_v2 
        where end_date='9999-12-31'
        group by instalment_id
        having count(1) > 1
    ) t2 on t1.instalment_id = t2.instalment_id
    where end_date='9999-12-31'
    and principal_os>0
    and principal_repayable>0
    and t2.instalment_id is null
    group by t1.instalment_id
) a 
join (
select 
instalment_id 
,sum(principal_os) as principal_os
from credit_mart.dws_spl_ph_instalment_repayment_df
where grass_date ='${grass_date}'
and principal_os>0
and principal_repayable>0
group by instalment_id 
) b on a.instalment_id = b.instalment_id
where a.principal_os<>b.principal_os
) a 

union all
select 
'error: instalment_id risk os <> credit os' as dqc_type
,'PH' as  grass_region
,'1' as product_id
from (
    select  
     a.instalment_id
    ,a.principal_os 
    ,b.principal_os as principal_os_b 
from(
    select 
    t1.instalment_id 
    ,sum(principal_os) as principal_os
    from risk.dws_risk_bcl_ph_instalment_repayment_zi_v2 t1 
    left join (
        select 
        instalment_id
        ,count(1)
        from risk.dws_risk_bcl_ph_instalment_repayment_zi_v2 
        where end_date='9999-12-31'
        group by instalment_id
        having count(1) > 1
    ) t2 on t1.instalment_id = t2.instalment_id
    where end_date='9999-12-31'
    and principal_os>0
    and principal_repayable>0
    and t2.instalment_id is null
    group by t1.instalment_id
) a 
join (
select 
instalment_id 
,sum(principal_os) as principal_os
from credit_mart.dws_bcl_ph_instalment_repayment_df
where grass_date ='${grass_date}'
and principal_os>0
and principal_repayable>0
group by instalment_id 
) b on a.instalment_id = b.instalment_id
where a.principal_os<>b.principal_os
) a 

union all
select 
'error: instalment_id risk os <> credit os' as dqc_type
,'VN' as  grass_region
,'1' as product_id
from (
    select  
     a.instalment_id
    ,a.principal_os 
    ,b.principal_os as principal_os_b 
from(
    select 
    t1.instalment_id 
    ,sum(principal_os) as principal_os
    from risk.dws_risk_bcl_vn_instalment_repayment_zi_v2 t1 
    left join (
        select 
        instalment_id
        ,count(1)
        from risk.dws_risk_bcl_vn_instalment_repayment_zi_v2 
        where end_date='9999-12-31'
        group by instalment_id
        having count(1) > 1
    ) t2 on t1.instalment_id = t2.instalment_id
    where end_date='9999-12-31'
    and principal_os>0
    and principal_repayable>0
    and t2.instalment_id is null
    group by t1.instalment_id
) a 
join (
select 
instalment_id 
,sum(principal_os) as principal_os
from credit_mart.dws_bcl_vn_instalment_repayment_df
where grass_date ='${grass_date}'
and principal_os>0
and principal_repayable>0
group by instalment_id 
) b on a.instalment_id = b.instalment_id
where a.principal_os<>b.principal_os
) a 


union all
select 
'error: instalment_id risk os <> credit os' as dqc_type
,'ID' as  grass_region
,'1' as product_id
from (
    select  
     a.instalment_id
    ,a.principal_os 
    ,b.principal_os as principal_os_b 
from(
    select 
    t1.instalment_id 
    ,sum(principal_os) as principal_os
    from risk.dws_risk_bcl_id_instalment_repayment_zi_v2 t1 
    left join (
        select 
        instalment_id
        ,count(1)
        from risk.dws_risk_bcl_id_instalment_repayment_zi_v2 
        where end_date='9999-12-31'
        group by instalment_id
        having count(1) > 1
    ) t2 on t1.instalment_id = t2.instalment_id
    where end_date='9999-12-31'
    and principal_os>0
    and principal_repayable>0
    and t2.instalment_id is null
    group by t1.instalment_id
) a 
join (
select 
instalment_id 
,sum(principal_os) as principal_os
from credit_mart.dws_bcl_id_instalment_repayment_df
where grass_date ='${grass_date}'
and principal_os>0
and principal_repayable>0
group by instalment_id 
) b on a.instalment_id = b.instalment_id
where a.principal_os<>b.principal_os
) a 


union all
select 
'error: instalment_id risk os <> credit os' as dqc_type
,'TH' as  grass_region
,'1' as product_id
from (
    select  
     a.instalment_id
    ,a.principal_os 
    ,b.principal_os as principal_os_b 
from(
    select 
    t1.instalment_id 
    ,sum(principal_os) as principal_os
    from risk.dws_risk_bcl_th_instalment_repayment_zi_v2 t1 
    left join (
        select 
        instalment_id
        ,count(1)
        from risk.dws_risk_bcl_th_instalment_repayment_zi_v2 
        where end_date='9999-12-31'
        group by instalment_id
        having count(1) > 1
    ) t2 on t1.instalment_id = t2.instalment_id
    where end_date='9999-12-31'
    and principal_os>0
    and principal_repayable>0
    and t2.instalment_id is null
    group by t1.instalment_id
) a 
join (
select 
instalment_id 
,sum(principal_os) as principal_os
from credit_mart.dws_bcl_th_instalment_repayment_df
where grass_date ='${grass_date}'
and principal_os>0
and principal_repayable>0
group by instalment_id 
) b on a.instalment_id = b.instalment_id
where a.principal_os<>b.principal_os
) a 
-- 20240819新增主键不重复((bill_id/instalment_id/loan_id)&start_date)
union all
select 
    'bill_id&start_date&product_id not unique' as dqc_type
    ,grass_region
    ,product_id
from(
    select 
    t1.garss_region as grass_region
    ,t1.product_id
    ,bill_id 
    ,start_date 
    ,count(1)
    from risk.dws_aio_bill_repayment_zi_dqc  t1 
    where start_date > end_date  
    and garss_region not in('BR')
    group by t1.garss_region
    ,t1.product_id
    ,bill_id 
    ,start_date 
    having count(1)>1 
) a 
union all
select 
    'instalment_id&start_date&product_id not unique' as dqc_type
    ,grass_region
    ,product_id
from(
    select 
    t1.garss_region as grass_region
    ,t1.product_id
    ,instalment_id 
    ,start_date 
    ,count(1)
    from risk.dws_aio_instalment_repayment_zi_dqc  t1 
    where start_date > end_date  
    and garss_region not in('BR')
    group by t1.garss_region
    ,t1.product_id
    ,instalment_id 
    ,start_date 
    having count(1)>1 
) a 
union all
select 
    'loan_id&start_date&product_id not unique' as dqc_type
    ,grass_region
    ,product_id
from(
    select 
    t1.garss_region as grass_region
    ,t1.product_id
    ,loan_id 
    ,start_date 
    ,count(1)
    from risk.dws_aio_loan_repayment_zi_dqc  t1 
    where start_date > end_date  
    and garss_region not in('BR')
    group by t1.garss_region
    ,t1.product_id
    ,loan_id 
    ,start_date 
    having count(1)>1 
) a
) t 
group by dqc_type
,grass_region
,product_id
;


