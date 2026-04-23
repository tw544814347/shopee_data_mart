--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-05-22
-- Theme Domain：       loan_mob_dpd
-- Description:         
-- Data Granularity:    loan_id
-- update by zongyi.lu@shopee.com id bcl/scl切换成floating_due_day 因此单独使用此模板
-- 2025-11-27           disbursement_term改为first_instalment_due_time - 1month - 1day
--********************************************************************--

-- dpd0_outstanding_by_tenure
create or replace temporary view dpd0_outstanding_by_tenure_${product}_${region} as
select 
    loan_id  
    ,loan_disbursed_month as loan_disbursed_month
    ,case when due_time_day ${org_first_due_day} then due_time_day else  due_time_day -${floating_due_day} end        as due_time_day
    ,new_repeat_user     as new_repeat_user
    ,tenure              as tenure
    ,regexp_replace(split(split(sub_mob_info,':')[0],'-')[0],'"','') as month_on_book
    ,cast(regexp_replace(split(sub_mob_info,':')[1],'"','') as decimal(30,10)) as dpd_amt
    ,dpd_filter
from (
    select 
    a.loan_id  
    ,loan_disbursed_month        as loan_disbursed_month
    ,due_time_day                as due_time_day
    ,new_repeat_user             as new_repeat_user
    ,first_instalment_due_time   as first_instalment_due_time
    ,tenure                      as tenure
    ,to_json(
            named_struct(
                'MOB01-1', cast(dpd0_mob1_principal_os as decimal(30,10))
                ,'MOB02-2',cast(dpd0_mob2_principal_os as decimal(30,10))
                ,'MOB03-3',cast(dpd0_mob3_principal_os as decimal(30,10))
                ,'MOB04-4',cast(dpd0_mob4_principal_os as decimal(30,10))
                ,'MOB05-5',cast(dpd0_mob5_principal_os as decimal(30,10))
                ,'MOB06-6',cast(dpd0_mob6_principal_os as decimal(30,10))
                ,'MOB07-7',cast(dpd0_mob7_principal_os as decimal(30,10))
                ,'MOB08-8',cast(dpd0_mob8_principal_os as decimal(30,10))
                ,'MOB09-9',cast(dpd0_mob9_principal_os as decimal(30,10))
                ,'MOB10-10',cast(dpd0_mob10_principal_os as decimal(30,10))
                ,'MOB11-11',cast(dpd0_mob11_principal_os as decimal(30,10))
                ,'MOB12-12',cast(dpd0_mob12_principal_os as decimal(30,10))
                ,'MOB13-13',cast(dpd0_mob13_principal_os as decimal(30,10))
                ,'MOB14-14',cast(dpd0_mob14_principal_os as decimal(30,10))
                ,'MOB15-15',cast(dpd0_mob15_principal_os as decimal(30,10))
                ,'MOB16-16',cast(dpd0_mob16_principal_os as decimal(30,10))
                ,'MOB17-17',cast(dpd0_mob17_principal_os as decimal(30,10))
                ,'MOB18-18',cast(dpd0_mob18_principal_os as decimal(30,10))
                ,'MOB19-19',cast(dpd0_mob19_principal_os as decimal(30,10))
                ,'MOB20-20',cast(dpd0_mob20_principal_os as decimal(30,10))
                ,'MOB21-21',cast(dpd0_mob21_principal_os as decimal(30,10))
                ,'MOB22-22',cast(dpd0_mob22_principal_os as decimal(30,10))
                ,'MOB23-23',cast(dpd0_mob23_principal_os as decimal(30,10))
                ,'MOB24-24',cast(dpd0_mob24_principal_os as decimal(30,10))
            )
        )                as mob_info
    ,'01.DPD0+'          as dpd_filter
    from(
    select
        a.loan_id  
        ,case when a.loan_disbursed_month is null and a.first_instalment_due_time is not null 
            then add_months(a.first_instalment_due_time,-1) 
            else a.loan_disbursed_month end                                                                                     as loan_disbursed_month
        ,day(a.first_instalment_due_time)                                                                                       as due_time_day
        ,a.first_instalment_due_time
        ,max(a.new_repeat_user)                                                                                                        as new_repeat_user
        ,case when a.loan_tenure < 10 then concat('0', cast(a.loan_tenure as string)) else cast(a.loan_tenure as string) end    as tenure
        ,sum(case when clear_status<>3 and dpd_eod>0 and add_months(date_add(to_date(first_instalment_due_time),-1),0 )>=start_date and add_months(date_add(to_date(first_instalment_due_time),-1),0 )<=end_date and add_months(date_add(to_date(first_instalment_due_time),-1),0 )>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob1_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>0 and add_months(date_add(to_date(first_instalment_due_time),-1),1 )>=start_date and add_months(date_add(to_date(first_instalment_due_time),-1),1 )<=end_date and add_months(date_add(to_date(first_instalment_due_time),-1),1 )>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob2_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>0 and add_months(date_add(to_date(first_instalment_due_time),-1),2 )>=start_date and add_months(date_add(to_date(first_instalment_due_time),-1),2 )<=end_date and add_months(date_add(to_date(first_instalment_due_time),-1),2 )>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob3_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>0 and add_months(date_add(to_date(first_instalment_due_time),-1),3 )>=start_date and add_months(date_add(to_date(first_instalment_due_time),-1),3 )<=end_date and add_months(date_add(to_date(first_instalment_due_time),-1),3 )>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob4_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>0 and add_months(date_add(to_date(first_instalment_due_time),-1),4 )>=start_date and add_months(date_add(to_date(first_instalment_due_time),-1),4 )<=end_date and add_months(date_add(to_date(first_instalment_due_time),-1),4 )>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob5_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>0 and add_months(date_add(to_date(first_instalment_due_time),-1),5 )>=start_date and add_months(date_add(to_date(first_instalment_due_time),-1),5 )<=end_date and add_months(date_add(to_date(first_instalment_due_time),-1),5 )>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob6_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>0 and add_months(date_add(to_date(first_instalment_due_time),-1),6 )>=start_date and add_months(date_add(to_date(first_instalment_due_time),-1),6 )<=end_date and add_months(date_add(to_date(first_instalment_due_time),-1),6 )>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob7_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>0 and add_months(date_add(to_date(first_instalment_due_time),-1),7 )>=start_date and add_months(date_add(to_date(first_instalment_due_time),-1),7 )<=end_date and add_months(date_add(to_date(first_instalment_due_time),-1),7 )>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob8_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>0 and add_months(date_add(to_date(first_instalment_due_time),-1),8 )>=start_date and add_months(date_add(to_date(first_instalment_due_time),-1),8 )<=end_date and add_months(date_add(to_date(first_instalment_due_time),-1),8 )>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob9_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>0 and add_months(date_add(to_date(first_instalment_due_time),-1),9 )>=start_date and add_months(date_add(to_date(first_instalment_due_time),-1),9 )<=end_date and add_months(date_add(to_date(first_instalment_due_time),-1),9 )>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob10_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>0 and add_months(date_add(to_date(first_instalment_due_time),-1),10)>=start_date and add_months(date_add(to_date(first_instalment_due_time),-1),10)<=end_date and add_months(date_add(to_date(first_instalment_due_time),-1),10)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob11_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>0 and add_months(date_add(to_date(first_instalment_due_time),-1),11)>=start_date and add_months(date_add(to_date(first_instalment_due_time),-1),11)<=end_date and add_months(date_add(to_date(first_instalment_due_time),-1),11)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob12_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>0 and add_months(date_add(to_date(first_instalment_due_time),-1),12)>=start_date and add_months(date_add(to_date(first_instalment_due_time),-1),12)<=end_date and add_months(date_add(to_date(first_instalment_due_time),-1),12)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob13_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>0 and add_months(date_add(to_date(first_instalment_due_time),-1),13)>=start_date and add_months(date_add(to_date(first_instalment_due_time),-1),13)<=end_date and add_months(date_add(to_date(first_instalment_due_time),-1),13)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob14_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>0 and add_months(date_add(to_date(first_instalment_due_time),-1),14)>=start_date and add_months(date_add(to_date(first_instalment_due_time),-1),14)<=end_date and add_months(date_add(to_date(first_instalment_due_time),-1),14)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob15_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>0 and add_months(date_add(to_date(first_instalment_due_time),-1),15)>=start_date and add_months(date_add(to_date(first_instalment_due_time),-1),15)<=end_date and add_months(date_add(to_date(first_instalment_due_time),-1),15)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob16_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>0 and add_months(date_add(to_date(first_instalment_due_time),-1),16)>=start_date and add_months(date_add(to_date(first_instalment_due_time),-1),16)<=end_date and add_months(date_add(to_date(first_instalment_due_time),-1),16)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob17_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>0 and add_months(date_add(to_date(first_instalment_due_time),-1),17)>=start_date and add_months(date_add(to_date(first_instalment_due_time),-1),17)<=end_date and add_months(date_add(to_date(first_instalment_due_time),-1),17)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob18_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>0 and add_months(date_add(to_date(first_instalment_due_time),-1),18)>=start_date and add_months(date_add(to_date(first_instalment_due_time),-1),18)<=end_date and add_months(date_add(to_date(first_instalment_due_time),-1),18)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob19_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>0 and add_months(date_add(to_date(first_instalment_due_time),-1),19)>=start_date and add_months(date_add(to_date(first_instalment_due_time),-1),19)<=end_date and add_months(date_add(to_date(first_instalment_due_time),-1),19)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob20_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>0 and add_months(date_add(to_date(first_instalment_due_time),-1),20)>=start_date and add_months(date_add(to_date(first_instalment_due_time),-1),20)<=end_date and add_months(date_add(to_date(first_instalment_due_time),-1),20)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob21_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>0 and add_months(date_add(to_date(first_instalment_due_time),-1),21)>=start_date and add_months(date_add(to_date(first_instalment_due_time),-1),21)<=end_date and add_months(date_add(to_date(first_instalment_due_time),-1),21)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob22_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>0 and add_months(date_add(to_date(first_instalment_due_time),-1),22)>=start_date and add_months(date_add(to_date(first_instalment_due_time),-1),22)<=end_date and add_months(date_add(to_date(first_instalment_due_time),-1),22)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob23_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>0 and add_months(date_add(to_date(first_instalment_due_time),-1),23)>=start_date and add_months(date_add(to_date(first_instalment_due_time),-1),23)<=end_date and add_months(date_add(to_date(first_instalment_due_time),-1),23)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob24_principal_os
    from risk.dws_risk_${product}_${region}_loan_repayment_zi a
    where loan_disbursed_month>=from_unixtime(unix_timestamp(add_months('${grass_date}',-24), 'yyyy-MM-dd'), 'yyyyMM')
    -- and months_on_book > 0
    -- and months_on_book <=24
    and if(trunc('${grass_date}','MM')>=trunc(first_instalment_due_time,'MM'),floor(months_between(trunc('${grass_date}','MM'),trunc(first_instalment_due_time,'MM')))+1,0) >0 
    and if(trunc('${grass_date}','MM')>=trunc(first_instalment_due_time,'MM'),floor(months_between(trunc('${grass_date}','MM'),trunc(first_instalment_due_time,'MM')))+1,0) <=24
    and day(a.first_instalment_due_time) ${first_due_day}
    group by
    a.loan_id  
    ,case when a.loan_disbursed_month is null and a.first_instalment_due_time is not null 
        then add_months(a.first_instalment_due_time,-1) 
        else a.loan_disbursed_month end                                                                                
    ,day(a.first_instalment_due_time)                                                                                              
    ,a.first_instalment_due_time                                         
    ,case when a.loan_tenure < 10 then concat('0', cast(a.loan_tenure as string)) else cast(a.loan_tenure as string) end
    ) a 
) a 
lateral view explode(split(regexp_replace(mob_info,'[{}]',''),','))tab as  sub_mob_info
-- where date_format(add_months(from_unixtime(unix_timestamp(loan_disbursed_month, 'yyyyMM'), 'yyyy-MM-dd'),cast(regexp_replace(split(split(sub_mob_info,':')[0],'-')[1],'"','') as int)), 'yyyy-MM')<=substr('${grass_date}',1,7)
where date_add(add_months(to_date(a.first_instalment_due_time),cast(regexp_replace(split(split(sub_mob_info,':')[0],'-')[1],'"','') as int)-1),-1) <='${grass_date}'
;



-- dpd7_outstanding_by_tenure
create or replace temporary view dpd7_outstanding_by_tenure_${product}_${region} as
select
    loan_id 
    ,loan_disbursed_month as loan_disbursed_month
    ,case when due_time_day ${org_first_due_day} then due_time_day else  due_time_day -${floating_due_day} end        as due_time_day
    ,new_repeat_user     as new_repeat_user
    ,tenure              as tenure
    ,regexp_replace(split(split(sub_mob_info,':')[0],'-')[0],'"','') as month_on_book
    ,cast(regexp_replace(split(sub_mob_info,':')[1],'"','') as decimal(30,10)) as dpd_amt
    ,dpd_filter
from (
    select
    loan_id 
    ,loan_disbursed_month as loan_disbursed_month
    ,due_time_day        as due_time_day
    ,new_repeat_user     as new_repeat_user
    ,tenure              as tenure
    ,first_instalment_due_time
    ,to_json(
            named_struct(
                'MOB01-1', cast(dpd7_mob1_principal_os as decimal(30,10))
                ,'MOB02-2',cast(dpd7_mob2_principal_os as decimal(30,10))
                ,'MOB03-3',cast(dpd7_mob3_principal_os as decimal(30,10))
                ,'MOB04-4',cast(dpd7_mob4_principal_os as decimal(30,10))
                ,'MOB05-5',cast(dpd7_mob5_principal_os as decimal(30,10))
                ,'MOB06-6',cast(dpd7_mob6_principal_os as decimal(30,10))
                ,'MOB07-7',cast(dpd7_mob7_principal_os as decimal(30,10))
                ,'MOB08-8',cast(dpd7_mob8_principal_os as decimal(30,10))
                ,'MOB09-9',cast(dpd7_mob9_principal_os as decimal(30,10))
                ,'MOB10-10',cast(dpd7_mob10_principal_os as decimal(30,10))
                ,'MOB11-11',cast(dpd7_mob11_principal_os as decimal(30,10))
                ,'MOB12-12',cast(dpd7_mob12_principal_os as decimal(30,10))
                ,'MOB13-13',cast(dpd7_mob13_principal_os as decimal(30,10))
                ,'MOB14-14',cast(dpd7_mob14_principal_os as decimal(30,10))
                ,'MOB15-15',cast(dpd7_mob15_principal_os as decimal(30,10))
                ,'MOB16-16',cast(dpd7_mob16_principal_os as decimal(30,10))
                ,'MOB17-17',cast(dpd7_mob17_principal_os as decimal(30,10))
                ,'MOB18-18',cast(dpd7_mob18_principal_os as decimal(30,10))
                ,'MOB19-19',cast(dpd7_mob19_principal_os as decimal(30,10))
                ,'MOB20-20',cast(dpd7_mob20_principal_os as decimal(30,10))
                ,'MOB21-21',cast(dpd7_mob21_principal_os as decimal(30,10))
                ,'MOB22-22',cast(dpd7_mob22_principal_os as decimal(30,10))
                ,'MOB23-23',cast(dpd7_mob23_principal_os as decimal(30,10))
                ,'MOB24-24',cast(dpd7_mob24_principal_os as decimal(30,10))
            )
        )                as mob_info
    ,'02.DPD7+'          as dpd_filter
    from(
    select
        a.loan_id  
        ,a.loan_disbursed_month                                                                                
        ,a.due_time_day
        ,max(a.new_repeat_user) as new_repeat_user
        ,a.tenure
        ,a.first_instalment_due_time
        ,sum(case when clear_status<>3 and dpd_eod>7 and mob1_date  >=start_date and mob1_date  <=end_date and mob1_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob1_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>7 and mob2_date  >=start_date and mob2_date  <=end_date and mob2_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob2_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>7 and mob3_date  >=start_date and mob3_date  <=end_date and mob3_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob3_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>7 and mob4_date  >=start_date and mob4_date  <=end_date and mob4_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob4_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>7 and mob5_date  >=start_date and mob5_date  <=end_date and mob5_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob5_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>7 and mob6_date  >=start_date and mob6_date  <=end_date and mob6_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob6_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>7 and mob7_date  >=start_date and mob7_date  <=end_date and mob7_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob7_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>7 and mob8_date  >=start_date and mob8_date  <=end_date and mob8_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob8_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>7 and mob9_date  >=start_date and mob9_date  <=end_date and mob9_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob9_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>7 and mob10_date >=start_date and mob10_date <=end_date and mob10_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob10_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>7 and mob11_date >=start_date and mob11_date <=end_date and mob11_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob11_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>7 and mob12_date >=start_date and mob12_date <=end_date and mob12_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob12_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>7 and mob13_date >=start_date and mob13_date <=end_date and mob13_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob13_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>7 and mob14_date >=start_date and mob14_date <=end_date and mob14_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob14_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>7 and mob15_date >=start_date and mob15_date <=end_date and mob15_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob15_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>7 and mob16_date >=start_date and mob16_date <=end_date and mob16_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob16_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>7 and mob17_date >=start_date and mob17_date <=end_date and mob17_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob17_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>7 and mob18_date >=start_date and mob18_date <=end_date and mob18_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob18_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>7 and mob19_date >=start_date and mob19_date <=end_date and mob19_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob19_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>7 and mob20_date >=start_date and mob20_date <=end_date and mob20_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob20_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>7 and mob21_date >=start_date and mob21_date <=end_date and mob21_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob21_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>7 and mob22_date >=start_date and mob22_date <=end_date and mob22_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob22_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>7 and mob23_date >=start_date and mob23_date <=end_date and mob23_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob23_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>7 and mob24_date >=start_date and mob24_date <=end_date and mob24_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob24_principal_os
    from(
        
        select 
            a.loan_id  
            ,case when a.loan_disbursed_month is null and a.first_instalment_due_time is not null 
                then add_months(a.first_instalment_due_time,-1) 
                else a.loan_disbursed_month end                                                                                     as loan_disbursed_month
            ,day(a.first_instalment_due_time)                                                                                       as due_time_day
            ,new_repeat_user                                                                                                        as new_repeat_user
            ,a.first_instalment_due_time
            ,case when a.loan_tenure < 10 then concat('0', cast(a.loan_tenure as string)) else cast(a.loan_tenure as string) end    as tenure
            ,clear_status
            ,dpd_eod
            ,start_date
            ,end_date
            ,principal_os
            ,date_add(add_months(to_date(a.first_instalment_due_time),0),6) as mob1_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),1),6) as mob2_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),2),6) as mob3_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),3),6) as mob4_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),4),6) as mob5_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),5),6)as mob6_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),6),6) as mob7_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),7),6) as mob8_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),8),6) as mob9_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),9),6) as mob10_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),10),6) as mob11_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),11),6) as mob12_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),12),6) as mob13_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),13),6) as mob14_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),14),6) as mob15_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),15),6) as mob16_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),16),6) as mob17_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),17),6) as mob18_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),18),6) as mob19_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),19),6) as mob20_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),20),6) as mob21_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),21),6) as mob22_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),22),6) as mob23_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),23),6) as mob24_date
        from risk.dws_risk_${product}_${region}_loan_repayment_zi a
        where loan_disbursed_month>=from_unixtime(unix_timestamp(add_months('${grass_date}',-24), 'yyyy-MM-dd'), 'yyyyMM')
        and if(trunc('${grass_date}','MM')>=trunc(first_instalment_due_time,'MM'),floor(months_between(trunc('${grass_date}','MM'),trunc(first_instalment_due_time,'MM')))+1,0) >0 
        and if(trunc('${grass_date}','MM')>=trunc(first_instalment_due_time,'MM'),floor(months_between(trunc('${grass_date}','MM'),trunc(first_instalment_due_time,'MM')))+1,0) <=24
        and day(a.first_instalment_due_time) ${first_due_day}
        )a
    group by a.loan_id  
    ,a.loan_disbursed_month                                                                                
    ,a.due_time_day
    ,a.tenure
    ,a.first_instalment_due_time
    ) a 
) a 
lateral view explode(split(regexp_replace(mob_info,'[{}]',''),','))tab as  sub_mob_info
where date_add(add_months(to_date(a.first_instalment_due_time),cast(regexp_replace(split(split(sub_mob_info,':')[0],'-')[1],'"','') as int)-1),6) <='${grass_date}'
;



-- dpd15_outstanding_by_tenure
create or replace temporary view dpd15_outstanding_by_tenure_${product}_${region} as
select 
    loan_id 
    ,loan_disbursed_month as loan_disbursed_month
    ,case when due_time_day ${org_first_due_day} then due_time_day else  due_time_day -${floating_due_day} end        as due_time_day
    ,new_repeat_user      as new_repeat_user
    ,tenure              as tenure
    ,regexp_replace(split(split(sub_mob_info,':')[0],'-')[0],'"','') as month_on_book
    ,cast(regexp_replace(split(sub_mob_info,':')[1],'"','') as decimal(30,10)) as dpd_amt
    ,dpd_filter
from (
    select
     loan_id  
    ,loan_disbursed_month as loan_disbursed_month
    ,due_time_day        as due_time_day
    ,new_repeat_user     as new_repeat_user
    ,tenure              as tenure
    ,first_instalment_due_time
    ,to_json(
            named_struct(
                'MOB01-1', cast(dpd15_mob1_principal_os as decimal(30,10))
                ,'MOB02-2',cast(dpd15_mob2_principal_os as decimal(30,10))
                ,'MOB03-3',cast(dpd15_mob3_principal_os as decimal(30,10))
                ,'MOB04-4',cast(dpd15_mob4_principal_os as decimal(30,10))
                ,'MOB05-5',cast(dpd15_mob5_principal_os as decimal(30,10))
                ,'MOB06-6',cast(dpd15_mob6_principal_os as decimal(30,10))
                ,'MOB07-7',cast(dpd15_mob7_principal_os as decimal(30,10))
                ,'MOB08-8',cast(dpd15_mob8_principal_os as decimal(30,10))
                ,'MOB09-9',cast(dpd15_mob9_principal_os as decimal(30,10))
                ,'MOB10-10',cast(dpd15_mob10_principal_os as decimal(30,10))
                ,'MOB11-11',cast(dpd15_mob11_principal_os as decimal(30,10))
                ,'MOB12-12',cast(dpd15_mob12_principal_os as decimal(30,10))
                ,'MOB13-13',cast(dpd15_mob13_principal_os as decimal(30,10))
                ,'MOB14-14',cast(dpd15_mob14_principal_os as decimal(30,10))
                ,'MOB15-15',cast(dpd15_mob15_principal_os as decimal(30,10))
                ,'MOB16-16',cast(dpd15_mob16_principal_os as decimal(30,10))
                ,'MOB17-17',cast(dpd15_mob17_principal_os as decimal(30,10))
                ,'MOB18-18',cast(dpd15_mob18_principal_os as decimal(30,10))
                ,'MOB19-19',cast(dpd15_mob19_principal_os as decimal(30,10))
                ,'MOB20-20',cast(dpd15_mob20_principal_os as decimal(30,10))
                ,'MOB21-21',cast(dpd15_mob21_principal_os as decimal(30,10))
                ,'MOB22-22',cast(dpd15_mob22_principal_os as decimal(30,10))
                ,'MOB23-23',cast(dpd15_mob23_principal_os as decimal(30,10))
                ,'MOB24-24',cast(dpd15_mob24_principal_os as decimal(30,10))
            )
        )                 as mob_info
    ,'03.DPD15+'          as dpd_filter
    from(
    select
        a.loan_id  
        ,a.loan_disbursed_month                                                                                
        ,a.due_time_day
        ,max(a.new_repeat_user) as new_repeat_user
        ,a.tenure
        ,a.first_instalment_due_time
        ,sum(case when clear_status<>3 and dpd_eod>15 and mob1_date  >=start_date and mob1_date  <=end_date and mob1_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob1_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>15 and mob2_date  >=start_date and mob2_date  <=end_date and mob2_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob2_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>15 and mob3_date  >=start_date and mob3_date  <=end_date and mob3_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob3_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>15 and mob4_date  >=start_date and mob4_date  <=end_date and mob4_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob4_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>15 and mob5_date  >=start_date and mob5_date  <=end_date and mob5_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob5_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>15 and mob6_date  >=start_date and mob6_date  <=end_date and mob6_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob6_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>15 and mob7_date  >=start_date and mob7_date  <=end_date and mob7_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob7_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>15 and mob8_date  >=start_date and mob8_date  <=end_date and mob8_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob8_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>15 and mob9_date  >=start_date and mob9_date  <=end_date and mob9_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob9_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>15 and mob10_date >=start_date and mob10_date <=end_date and mob10_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob10_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>15 and mob11_date >=start_date and mob11_date <=end_date and mob11_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob11_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>15 and mob12_date >=start_date and mob12_date <=end_date and mob12_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob12_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>15 and mob13_date >=start_date and mob13_date <=end_date and mob13_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob13_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>15 and mob14_date >=start_date and mob14_date <=end_date and mob14_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob14_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>15 and mob15_date >=start_date and mob15_date <=end_date and mob15_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob15_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>15 and mob16_date >=start_date and mob16_date <=end_date and mob16_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob16_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>15 and mob17_date >=start_date and mob17_date <=end_date and mob17_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob17_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>15 and mob18_date >=start_date and mob18_date <=end_date and mob18_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob18_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>15 and mob19_date >=start_date and mob19_date <=end_date and mob19_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob19_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>15 and mob20_date >=start_date and mob20_date <=end_date and mob20_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob20_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>15 and mob21_date >=start_date and mob21_date <=end_date and mob21_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob21_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>15 and mob22_date >=start_date and mob22_date <=end_date and mob22_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob22_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>15 and mob23_date >=start_date and mob23_date <=end_date and mob23_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob23_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>15 and mob24_date >=start_date and mob24_date <=end_date and mob24_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob24_principal_os
    from(
        
        select 
            a.loan_id  
            ,case when a.loan_disbursed_month is null and a.first_instalment_due_time is not null 
                then add_months(a.first_instalment_due_time,-1) 
                else a.loan_disbursed_month end                                                                                     as loan_disbursed_month
            ,day(a.first_instalment_due_time)                                                                                       as due_time_day
            ,new_repeat_user                                                                                                        as new_repeat_user
            ,a.first_instalment_due_time
            ,case when a.loan_tenure < 10 then concat('0', cast(a.loan_tenure as string)) else cast(a.loan_tenure as string) end    as tenure
            ,clear_status
            ,dpd_eod
            ,start_date
            ,end_date
            ,principal_os
            ,date_add(add_months(to_date(a.first_instalment_due_time),0),14) as mob1_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),1),14) as mob2_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),2),14) as mob3_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),3),14) as mob4_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),4),14) as mob5_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),5),14) as mob6_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),6),14) as mob7_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),7),14) as mob8_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),8),14) as mob9_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),9),14) as mob10_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),10),14) as mob11_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),11),14) as mob12_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),12),14) as mob13_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),13),14) as mob14_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),14),14) as mob15_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),15),14) as mob16_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),16),14) as mob17_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),17),14) as mob18_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),18),14) as mob19_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),19),14) as mob20_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),20),14) as mob21_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),21),14) as mob22_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),22),14) as mob23_date
            ,date_add(add_months(to_date(a.first_instalment_due_time),23),14) as mob24_date
        from risk.dws_risk_${product}_${region}_loan_repayment_zi a
        where loan_disbursed_month>=from_unixtime(unix_timestamp(add_months('${grass_date}',-24), 'yyyy-MM-dd'), 'yyyyMM')
        and if(trunc('${grass_date}','MM')>=trunc(first_instalment_due_time,'MM'),floor(months_between(trunc('${grass_date}','MM'),trunc(first_instalment_due_time,'MM')))+1,0) >0 
        and if(trunc('${grass_date}','MM')>=trunc(first_instalment_due_time,'MM'),floor(months_between(trunc('${grass_date}','MM'),trunc(first_instalment_due_time,'MM')))+1,0) <=24
        and day(a.first_instalment_due_time) ${first_due_day}
        )a
    group by a.loan_id  
    ,a.loan_disbursed_month                                                                                
    ,a.due_time_day
    ,a.tenure
    ,a.first_instalment_due_time
    ) a 
) a 
lateral view explode(split(regexp_replace(mob_info,'[{}]',''),','))tab as  sub_mob_info
where date_add(add_months(to_date(a.first_instalment_due_time),cast(regexp_replace(split(split(sub_mob_info,':')[0],'-')[1],'"','') as int)-1),14) <='${grass_date}'
;



-- m1_outstanding_by_tenure
create or replace temporary view m1_outstanding_by_tenure_${product}_${region} as
select
    loan_id  
    ,loan_disbursed_month as loan_disbursed_month
    ,case when due_time_day ${org_first_due_day} then due_time_day else  due_time_day -${floating_due_day} end        as due_time_day
    ,new_repeat_user      as new_repeat_user
    ,tenure              as tenure
    ,regexp_replace(split(split(sub_mob_info,':')[0],'-')[0],'"','') as month_on_book
    ,cast(regexp_replace(split(sub_mob_info,':')[1],'"','') as decimal(30,10)) as dpd_amt
    ,dpd_filter
from (
    select
    loan_id  
    ,loan_disbursed_month as loan_disbursed_month
    ,due_time_day        as due_time_day
    ,new_repeat_user     as new_repeat_user
    ,tenure              as tenure
    ,a.first_instalment_due_time
    ,to_json(
            named_struct(
                 'MOB01-1',cast(m1_mob1_principal_os as decimal(30,10))
                ,'MOB02-2',cast(m1_mob2_principal_os as decimal(30,10))
                ,'MOB03-3',cast(m1_mob3_principal_os as decimal(30,10))
                ,'MOB04-4',cast(m1_mob4_principal_os as decimal(30,10))
                ,'MOB05-5',cast(m1_mob5_principal_os as decimal(30,10))
                ,'MOB06-6',cast(m1_mob6_principal_os as decimal(30,10))
                ,'MOB07-7',cast(m1_mob7_principal_os as decimal(30,10))
                ,'MOB08-8',cast(m1_mob8_principal_os as decimal(30,10))
                ,'MOB09-9',cast(m1_mob9_principal_os as decimal(30,10))
                ,'MOB10-10',cast(m1_mob10_principal_os as decimal(30,10))
                ,'MOB11-11',cast(m1_mob11_principal_os as decimal(30,10))
                ,'MOB12-12',cast(m1_mob12_principal_os as decimal(30,10))
                ,'MOB13-13',cast(m1_mob13_principal_os as decimal(30,10))
                ,'MOB14-14',cast(m1_mob14_principal_os as decimal(30,10))
                ,'MOB15-15',cast(m1_mob15_principal_os as decimal(30,10))
                ,'MOB16-16',cast(m1_mob16_principal_os as decimal(30,10))
                ,'MOB17-17',cast(m1_mob17_principal_os as decimal(30,10))
                ,'MOB18-18',cast(m1_mob18_principal_os as decimal(30,10))
                ,'MOB19-19',cast(m1_mob19_principal_os as decimal(30,10))
                ,'MOB20-20',cast(m1_mob20_principal_os as decimal(30,10))
                ,'MOB21-21',cast(m1_mob21_principal_os as decimal(30,10))
                ,'MOB22-22',cast(m1_mob22_principal_os as decimal(30,10))
                ,'MOB23-23',cast(m1_mob23_principal_os as decimal(30,10))
                ,'MOB24-24',cast(m1_mob24_principal_os as decimal(30,10))
            )
        )                 as mob_info
    ,'04.DPD30+'          as dpd_filter
    from(
    select
        loan_id  
        ,case when a.loan_disbursed_month is null and a.first_instalment_due_time is not null 
            then add_months(a.first_instalment_due_time,-1) 
            else a.loan_disbursed_month end                                                                                    as loan_disbursed_month
        ,day(a.first_instalment_due_time)                                                                                       as due_time_day
        ,max(a.new_repeat_user)                                                                                                       as new_repeat_user
        ,a.first_instalment_due_time
        ,case when a.loan_tenure < 10 then concat('0', cast(a.loan_tenure as string)) else cast(a.loan_tenure as string) end    as tenure
        ,sum(case when clear_status<>3 and dpd_eod>30 and date_add(add_months(to_date(first_instalment_due_time),-1),29)>=start_date and date_add(add_months(to_date(first_instalment_due_time),-1),29)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),-1),29)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob1_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>30 and date_add(add_months(to_date(first_instalment_due_time),0),29) >=start_date and date_add(add_months(to_date(first_instalment_due_time),0),29) <=end_date  and date_add(add_months(to_date(first_instalment_due_time),0),29) >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob2_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>30 and date_add(add_months(to_date(first_instalment_due_time),1),29) >=start_date and date_add(add_months(to_date(first_instalment_due_time),1),29) <=end_date  and date_add(add_months(to_date(first_instalment_due_time),1),29) >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob3_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>30 and date_add(add_months(to_date(first_instalment_due_time),2),29) >=start_date and date_add(add_months(to_date(first_instalment_due_time),2),29) <=end_date  and date_add(add_months(to_date(first_instalment_due_time),2),29) >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob4_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>30 and date_add(add_months(to_date(first_instalment_due_time),3),29) >=start_date and date_add(add_months(to_date(first_instalment_due_time),3),29) <=end_date  and date_add(add_months(to_date(first_instalment_due_time),3),29) >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob5_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>30 and date_add(add_months(to_date(first_instalment_due_time),4),29) >=start_date and date_add(add_months(to_date(first_instalment_due_time),4),29) <=end_date  and date_add(add_months(to_date(first_instalment_due_time),4),29) >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob6_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>30 and date_add(add_months(to_date(first_instalment_due_time),5),29) >=start_date and date_add(add_months(to_date(first_instalment_due_time),5),29) <=end_date  and date_add(add_months(to_date(first_instalment_due_time),5),29) >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob7_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>30 and date_add(add_months(to_date(first_instalment_due_time),6),29) >=start_date and date_add(add_months(to_date(first_instalment_due_time),6),29) <=end_date  and date_add(add_months(to_date(first_instalment_due_time),6),29) >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob8_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>30 and date_add(add_months(to_date(first_instalment_due_time),7),29) >=start_date and date_add(add_months(to_date(first_instalment_due_time),7),29) <=end_date  and date_add(add_months(to_date(first_instalment_due_time),7),29) >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob9_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>30 and date_add(add_months(to_date(first_instalment_due_time),8),29) >=start_date and date_add(add_months(to_date(first_instalment_due_time),8),29) <=end_date  and date_add(add_months(to_date(first_instalment_due_time),8),29) >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob10_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>30 and date_add(add_months(to_date(first_instalment_due_time),9),29) >=start_date and date_add(add_months(to_date(first_instalment_due_time),9),29) <=end_date  and date_add(add_months(to_date(first_instalment_due_time),9),29) >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob11_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>30 and date_add(add_months(to_date(first_instalment_due_time),10),29)>=start_date and date_add(add_months(to_date(first_instalment_due_time),10),29)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),10),29)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob12_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>30 and date_add(add_months(to_date(first_instalment_due_time),11),29)>=start_date and date_add(add_months(to_date(first_instalment_due_time),11),29)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),11),29)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob13_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>30 and date_add(add_months(to_date(first_instalment_due_time),12),29)>=start_date and date_add(add_months(to_date(first_instalment_due_time),12),29)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),12),29)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob14_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>30 and date_add(add_months(to_date(first_instalment_due_time),13),29)>=start_date and date_add(add_months(to_date(first_instalment_due_time),13),29)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),13),29)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob15_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>30 and date_add(add_months(to_date(first_instalment_due_time),14),29)>=start_date and date_add(add_months(to_date(first_instalment_due_time),14),29)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),14),29)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob16_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>30 and date_add(add_months(to_date(first_instalment_due_time),15),29)>=start_date and date_add(add_months(to_date(first_instalment_due_time),15),29)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),15),29)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob17_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>30 and date_add(add_months(to_date(first_instalment_due_time),16),29)>=start_date and date_add(add_months(to_date(first_instalment_due_time),16),29)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),16),29)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob18_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>30 and date_add(add_months(to_date(first_instalment_due_time),17),29)>=start_date and date_add(add_months(to_date(first_instalment_due_time),17),29)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),17),29)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob19_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>30 and date_add(add_months(to_date(first_instalment_due_time),18),29)>=start_date and date_add(add_months(to_date(first_instalment_due_time),18),29)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),18),29)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob20_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>30 and date_add(add_months(to_date(first_instalment_due_time),19),29)>=start_date and date_add(add_months(to_date(first_instalment_due_time),19),29)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),19),29)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob21_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>30 and date_add(add_months(to_date(first_instalment_due_time),20),29)>=start_date and date_add(add_months(to_date(first_instalment_due_time),20),29)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),20),29)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob22_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>30 and date_add(add_months(to_date(first_instalment_due_time),21),29)>=start_date and date_add(add_months(to_date(first_instalment_due_time),21),29)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),21),29)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob23_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>30 and date_add(add_months(to_date(first_instalment_due_time),22),29)>=start_date and date_add(add_months(to_date(first_instalment_due_time),22),29)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),22),29)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob24_principal_os
    from risk.dws_risk_${product}_${region}_loan_repayment_zi a
    where loan_disbursed_month>=from_unixtime(unix_timestamp(add_months('${grass_date}',-24), 'yyyy-MM-dd'), 'yyyyMM')
    and if(trunc('${grass_date}','MM')>=trunc(first_instalment_due_time,'MM'),floor(months_between(trunc('${grass_date}','MM'),trunc(first_instalment_due_time,'MM')))+1,0) >0 
    and if(trunc('${grass_date}','MM')>=trunc(first_instalment_due_time,'MM'),floor(months_between(trunc('${grass_date}','MM'),trunc(first_instalment_due_time,'MM')))+1,0) <=24
    
    and day(a.first_instalment_due_time) ${first_due_day}
    group by a.loan_id  
    ,case when a.loan_disbursed_month is null and a.first_instalment_due_time is not null 
        then add_months(a.first_instalment_due_time,-1) 
        else a.loan_disbursed_month end                                                                                
    ,day(a.first_instalment_due_time)                                                                                                                                       
    ,a.first_instalment_due_time
    ,case when a.loan_tenure < 10 then concat('0', cast(a.loan_tenure as string)) else cast(a.loan_tenure as string) end
    ) a 
) a 
lateral view explode(split(regexp_replace(mob_info,'[{}]',''),','))tab as  sub_mob_info
where date_add(add_months(to_date(a.first_instalment_due_time),cast(regexp_replace(split(split(sub_mob_info,':')[0],'-')[1],'"','') as int)-2),29) <='${grass_date}'
;


-- m2_outstanding_by_tenure
create or replace temporary view m2_outstanding_by_tenure_${product}_${region} as
select
     loan_id  
    ,loan_disbursed_month as loan_disbursed_month
    ,case when due_time_day ${org_first_due_day} then due_time_day else  due_time_day -${floating_due_day} end        as due_time_day
    ,new_repeat_user      as new_repeat_user
    ,tenure              as tenure
    ,regexp_replace(split(split(sub_mob_info,':')[0],'-')[0],'"','') as month_on_book
    ,cast(regexp_replace(split(sub_mob_info,':')[1],'"','') as decimal(30,10)) as dpd_amt
    ,dpd_filter
from (
    select
    loan_id  
    ,loan_disbursed_month as loan_disbursed_month
    ,due_time_day        as due_time_day
    ,new_repeat_user     as new_repeat_user
    ,tenure              as tenure
    ,a.first_instalment_due_time
    ,to_json(
            named_struct(
                 'MOB01-1',cast(m2_mob1_principal_os as decimal(30,10))
                ,'MOB02-2',cast(m2_mob2_principal_os as decimal(30,10))
                ,'MOB03-3',cast(m2_mob3_principal_os as decimal(30,10))
                ,'MOB04-4',cast(m2_mob4_principal_os as decimal(30,10))
                ,'MOB05-5',cast(m2_mob5_principal_os as decimal(30,10))
                ,'MOB06-6',cast(m2_mob6_principal_os as decimal(30,10))
                ,'MOB07-7',cast(m2_mob7_principal_os as decimal(30,10))
                ,'MOB08-8',cast(m2_mob8_principal_os as decimal(30,10))
                ,'MOB09-9',cast(m2_mob9_principal_os as decimal(30,10))
                ,'MOB10-10',cast(m2_mob10_principal_os as decimal(30,10))
                ,'MOB11-11',cast(m2_mob11_principal_os as decimal(30,10))
                ,'MOB12-12',cast(m2_mob12_principal_os as decimal(30,10))
                ,'MOB13-13',cast(m2_mob13_principal_os as decimal(30,10))
                ,'MOB14-14',cast(m2_mob14_principal_os as decimal(30,10))
                ,'MOB15-15',cast(m2_mob15_principal_os as decimal(30,10))
                ,'MOB16-16',cast(m2_mob16_principal_os as decimal(30,10))
                ,'MOB17-17',cast(m2_mob17_principal_os as decimal(30,10))
                ,'MOB18-18',cast(m2_mob18_principal_os as decimal(30,10))
                ,'MOB19-19',cast(m2_mob19_principal_os as decimal(30,10))
                ,'MOB20-20',cast(m2_mob20_principal_os as decimal(30,10))
                ,'MOB21-21',cast(m2_mob21_principal_os as decimal(30,10))
                ,'MOB22-22',cast(m2_mob22_principal_os as decimal(30,10))
                ,'MOB23-23',cast(m2_mob23_principal_os as decimal(30,10))
                ,'MOB24-24',cast(m2_mob24_principal_os as decimal(30,10))
            )
        )                 as mob_info
    ,'05.DPD60+'          as dpd_filter
    from(
    select 
        loan_id 
        ,case when a.loan_disbursed_month is null and a.first_instalment_due_time is not null 
            then add_months(a.first_instalment_due_time,-1) 
            else a.loan_disbursed_month end                                                                                    as loan_disbursed_month
        ,day(a.first_instalment_due_time)                                                                                       as due_time_day
        ,max(a.new_repeat_user)                                                                                                      as new_repeat_user
        ,a.first_instalment_due_time
        ,case when a.loan_tenure < 10 then concat('0', cast(a.loan_tenure as string)) else cast(a.loan_tenure as string) end    as tenure
        ,sum(case when clear_status<>3 and dpd_eod>60 and date_add(add_months(to_date(first_instalment_due_time),-2),59)>=start_date and date_add(add_months(to_date(first_instalment_due_time),-2),59)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),-2),59)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob1_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>60 and date_add(add_months(to_date(first_instalment_due_time),-1),59)>=start_date and date_add(add_months(to_date(first_instalment_due_time),-1),59)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),-1),59)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob2_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>60 and date_add(add_months(to_date(first_instalment_due_time),0),59) >=start_date and date_add(add_months(to_date(first_instalment_due_time),0),59) <=end_date  and date_add(add_months(to_date(first_instalment_due_time),0),59) >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob3_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>60 and date_add(add_months(to_date(first_instalment_due_time),1),59) >=start_date and date_add(add_months(to_date(first_instalment_due_time),1),59) <=end_date  and date_add(add_months(to_date(first_instalment_due_time),1),59) >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob4_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>60 and date_add(add_months(to_date(first_instalment_due_time),2),59) >=start_date and date_add(add_months(to_date(first_instalment_due_time),2),59) <=end_date  and date_add(add_months(to_date(first_instalment_due_time),2),59) >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob5_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>60 and date_add(add_months(to_date(first_instalment_due_time),3),59) >=start_date and date_add(add_months(to_date(first_instalment_due_time),3),59) <=end_date  and date_add(add_months(to_date(first_instalment_due_time),3),59) >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob6_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>60 and date_add(add_months(to_date(first_instalment_due_time),4),59) >=start_date and date_add(add_months(to_date(first_instalment_due_time),4),59) <=end_date  and date_add(add_months(to_date(first_instalment_due_time),4),59) >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob7_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>60 and date_add(add_months(to_date(first_instalment_due_time),5),59) >=start_date and date_add(add_months(to_date(first_instalment_due_time),5),59) <=end_date  and date_add(add_months(to_date(first_instalment_due_time),5),59) >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob8_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>60 and date_add(add_months(to_date(first_instalment_due_time),6),59) >=start_date and date_add(add_months(to_date(first_instalment_due_time),6),59) <=end_date  and date_add(add_months(to_date(first_instalment_due_time),6),59) >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob9_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>60 and date_add(add_months(to_date(first_instalment_due_time),7),59) >=start_date and date_add(add_months(to_date(first_instalment_due_time),7),59) <=end_date  and date_add(add_months(to_date(first_instalment_due_time),7),59) >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob10_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>60 and date_add(add_months(to_date(first_instalment_due_time),8),59) >=start_date and date_add(add_months(to_date(first_instalment_due_time),8),59) <=end_date  and date_add(add_months(to_date(first_instalment_due_time),8),59) >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob11_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>60 and date_add(add_months(to_date(first_instalment_due_time),9),59) >=start_date and date_add(add_months(to_date(first_instalment_due_time),9),59) <=end_date  and date_add(add_months(to_date(first_instalment_due_time),9),59) >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob12_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>60 and date_add(add_months(to_date(first_instalment_due_time),10),59)>=start_date and date_add(add_months(to_date(first_instalment_due_time),10),59)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),10),59)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob13_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>60 and date_add(add_months(to_date(first_instalment_due_time),11),59)>=start_date and date_add(add_months(to_date(first_instalment_due_time),11),59)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),11),59)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob14_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>60 and date_add(add_months(to_date(first_instalment_due_time),12),59)>=start_date and date_add(add_months(to_date(first_instalment_due_time),12),59)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),12),59)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob15_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>60 and date_add(add_months(to_date(first_instalment_due_time),13),59)>=start_date and date_add(add_months(to_date(first_instalment_due_time),13),59)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),13),59)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob16_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>60 and date_add(add_months(to_date(first_instalment_due_time),14),59)>=start_date and date_add(add_months(to_date(first_instalment_due_time),14),59)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),14),59)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob17_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>60 and date_add(add_months(to_date(first_instalment_due_time),15),59)>=start_date and date_add(add_months(to_date(first_instalment_due_time),15),59)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),15),59)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob18_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>60 and date_add(add_months(to_date(first_instalment_due_time),16),59)>=start_date and date_add(add_months(to_date(first_instalment_due_time),16),59)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),16),59)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob19_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>60 and date_add(add_months(to_date(first_instalment_due_time),17),59)>=start_date and date_add(add_months(to_date(first_instalment_due_time),17),59)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),17),59)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob20_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>60 and date_add(add_months(to_date(first_instalment_due_time),18),59)>=start_date and date_add(add_months(to_date(first_instalment_due_time),18),59)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),18),59)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob21_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>60 and date_add(add_months(to_date(first_instalment_due_time),19),59)>=start_date and date_add(add_months(to_date(first_instalment_due_time),19),59)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),19),59)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob22_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>60 and date_add(add_months(to_date(first_instalment_due_time),20),59)>=start_date and date_add(add_months(to_date(first_instalment_due_time),20),59)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),20),59)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob23_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>60 and date_add(add_months(to_date(first_instalment_due_time),21),59)>=start_date and date_add(add_months(to_date(first_instalment_due_time),21),59)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),21),59)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob24_principal_os
    from risk.dws_risk_${product}_${region}_loan_repayment_zi a
    where loan_disbursed_month>=from_unixtime(unix_timestamp(add_months('${grass_date}',-24), 'yyyy-MM-dd'), 'yyyyMM')
    and if(trunc('${grass_date}','MM')>=trunc(first_instalment_due_time,'MM'),floor(months_between(trunc('${grass_date}','MM'),trunc(first_instalment_due_time,'MM')))+1,0) >0 
    and if(trunc('${grass_date}','MM')>=trunc(first_instalment_due_time,'MM'),floor(months_between(trunc('${grass_date}','MM'),trunc(first_instalment_due_time,'MM')))+1,0) <=24
    
    and day(a.first_instalment_due_time) ${first_due_day}
    group by a.loan_id  
    ,case when a.loan_disbursed_month is null and a.first_instalment_due_time is not null 
        then add_months(a.first_instalment_due_time,-1) 
        else a.loan_disbursed_month end                                                                                
    ,day(a.first_instalment_due_time)                                                                                                                                       
    ,a.first_instalment_due_time
    ,case when a.loan_tenure < 10 then concat('0', cast(a.loan_tenure as string)) else cast(a.loan_tenure as string) end
    ) a 
) a 
lateral view explode(split(regexp_replace(mob_info,'[{}]',''),','))tab as  sub_mob_info
where date_add(add_months(to_date(a.first_instalment_due_time),cast(regexp_replace(split(split(sub_mob_info,':')[0],'-')[1],'"','') as int)-3),59) <='${grass_date}'
;

-- m3_outstanding_by_tenure
create or replace temporary view m3_outstanding_by_tenure_${product}_${region} as
select
     loan_id  
    ,loan_disbursed_month as loan_disbursed_month
    ,case when due_time_day ${org_first_due_day} then due_time_day else  due_time_day -${floating_due_day} end       as due_time_day
    ,new_repeat_user      as new_repeat_user
    ,tenure              as tenure
    ,regexp_replace(split(split(sub_mob_info,':')[0],'-')[0],'"','') as month_on_book
    ,cast(regexp_replace(split(sub_mob_info,':')[1],'"','') as decimal(30,10)) as dpd_amt
    ,dpd_filter
from (
    select
    loan_id  
    ,loan_disbursed_month as loan_disbursed_month
    ,due_time_day        as due_time_day
    ,new_repeat_user     as new_repeat_user
    ,tenure              as tenure
    ,a.first_instalment_due_time
    ,to_json(
            named_struct(
                 'MOB01-1',cast(m3_mob1_principal_os as decimal(30,10))
                ,'MOB02-2',cast(m3_mob2_principal_os as decimal(30,10))
                ,'MOB03-3',cast(m3_mob3_principal_os as decimal(30,10))
                ,'MOB04-4',cast(m3_mob4_principal_os as decimal(30,10))
                ,'MOB05-5',cast(m3_mob5_principal_os as decimal(30,10))
                ,'MOB06-6',cast(m3_mob6_principal_os as decimal(30,10))
                ,'MOB07-7',cast(m3_mob7_principal_os as decimal(30,10))
                ,'MOB08-8',cast(m3_mob8_principal_os as decimal(30,10))
                ,'MOB09-9',cast(m3_mob9_principal_os as decimal(30,10))
                ,'MOB10-10',cast(m3_mob10_principal_os as decimal(30,10))
                ,'MOB11-11',cast(m3_mob11_principal_os as decimal(30,10))
                ,'MOB12-12',cast(m3_mob12_principal_os as decimal(30,10))
                ,'MOB13-13',cast(m3_mob13_principal_os as decimal(30,10))
                ,'MOB14-14',cast(m3_mob14_principal_os as decimal(30,10))
                ,'MOB15-15',cast(m3_mob15_principal_os as decimal(30,10))
                ,'MOB16-16',cast(m3_mob16_principal_os as decimal(30,10))
                ,'MOB17-17',cast(m3_mob17_principal_os as decimal(30,10))
                ,'MOB18-18',cast(m3_mob18_principal_os as decimal(30,10))
                ,'MOB19-19',cast(m3_mob19_principal_os as decimal(30,10))
                ,'MOB20-20',cast(m3_mob20_principal_os as decimal(30,10))
                ,'MOB21-21',cast(m3_mob21_principal_os as decimal(30,10))
                ,'MOB22-22',cast(m3_mob22_principal_os as decimal(30,10))
                ,'MOB23-23',cast(m3_mob23_principal_os as decimal(30,10))
                ,'MOB24-24',cast(m3_mob24_principal_os as decimal(30,10))
            )
        )                 as mob_info
    ,'06.DPD90+'          as dpd_filter
    from(
    select
        loan_id  
        ,case when a.loan_disbursed_month is null and a.first_instalment_due_time is not null 
            then add_months(a.first_instalment_due_time,-1) 
            else a.loan_disbursed_month end                                                                                    as loan_disbursed_month
        ,day(a.first_instalment_due_time)                                                                                       as due_time_day
        ,max(a.new_repeat_user)                                                                                                        as new_repeat_user
        ,a.first_instalment_due_time
        ,case when a.loan_tenure < 10 then concat('0', cast(a.loan_tenure as string)) else cast(a.loan_tenure as string) end    as tenure
        ,sum(case when clear_status<>3 and dpd_eod>90 and date_add(add_months(to_date(first_instalment_due_time),-3),89)>=start_date and date_add(add_months(to_date(first_instalment_due_time),-3),89)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),-3),89)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob1_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>90 and date_add(add_months(to_date(first_instalment_due_time),-2),89)>=start_date and date_add(add_months(to_date(first_instalment_due_time),-2),89)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),-2),89)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob2_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>90 and date_add(add_months(to_date(first_instalment_due_time),-1),89)>=start_date and date_add(add_months(to_date(first_instalment_due_time),-1),89)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),-1),89)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob3_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>90 and date_add(add_months(to_date(first_instalment_due_time),0),89) >=start_date and date_add(add_months(to_date(first_instalment_due_time),0),89) <=end_date  and date_add(add_months(to_date(first_instalment_due_time),0),89) >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob4_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>90 and date_add(add_months(to_date(first_instalment_due_time),1),89) >=start_date and date_add(add_months(to_date(first_instalment_due_time),1),89) <=end_date  and date_add(add_months(to_date(first_instalment_due_time),1),89) >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob5_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>90 and date_add(add_months(to_date(first_instalment_due_time),2),89) >=start_date and date_add(add_months(to_date(first_instalment_due_time),2),89) <=end_date  and date_add(add_months(to_date(first_instalment_due_time),2),89) >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob6_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>90 and date_add(add_months(to_date(first_instalment_due_time),3),89) >=start_date and date_add(add_months(to_date(first_instalment_due_time),3),89) <=end_date  and date_add(add_months(to_date(first_instalment_due_time),3),89) >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob7_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>90 and date_add(add_months(to_date(first_instalment_due_time),4),89) >=start_date and date_add(add_months(to_date(first_instalment_due_time),4),89) <=end_date  and date_add(add_months(to_date(first_instalment_due_time),4),89) >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob8_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>90 and date_add(add_months(to_date(first_instalment_due_time),5),89) >=start_date and date_add(add_months(to_date(first_instalment_due_time),5),89) <=end_date  and date_add(add_months(to_date(first_instalment_due_time),5),89) >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob9_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>90 and date_add(add_months(to_date(first_instalment_due_time),6),89) >=start_date and date_add(add_months(to_date(first_instalment_due_time),6),89) <=end_date  and date_add(add_months(to_date(first_instalment_due_time),6),89) >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob10_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>90 and date_add(add_months(to_date(first_instalment_due_time),7),89) >=start_date and date_add(add_months(to_date(first_instalment_due_time),7),89) <=end_date  and date_add(add_months(to_date(first_instalment_due_time),7),89) >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob11_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>90 and date_add(add_months(to_date(first_instalment_due_time),8),89) >=start_date and date_add(add_months(to_date(first_instalment_due_time),8),89) <=end_date  and date_add(add_months(to_date(first_instalment_due_time),8),89) >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob12_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>90 and date_add(add_months(to_date(first_instalment_due_time),9),89) >=start_date and date_add(add_months(to_date(first_instalment_due_time),9),89) <=end_date  and date_add(add_months(to_date(first_instalment_due_time),9),89) >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob13_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>90 and date_add(add_months(to_date(first_instalment_due_time),10),89)>=start_date and date_add(add_months(to_date(first_instalment_due_time),10),89)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),10),89)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob14_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>90 and date_add(add_months(to_date(first_instalment_due_time),11),89)>=start_date and date_add(add_months(to_date(first_instalment_due_time),11),89)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),11),89)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob15_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>90 and date_add(add_months(to_date(first_instalment_due_time),12),89)>=start_date and date_add(add_months(to_date(first_instalment_due_time),12),89)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),12),89)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob16_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>90 and date_add(add_months(to_date(first_instalment_due_time),13),89)>=start_date and date_add(add_months(to_date(first_instalment_due_time),13),89)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),13),89)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob17_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>90 and date_add(add_months(to_date(first_instalment_due_time),14),89)>=start_date and date_add(add_months(to_date(first_instalment_due_time),14),89)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),14),89)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob18_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>90 and date_add(add_months(to_date(first_instalment_due_time),15),89)>=start_date and date_add(add_months(to_date(first_instalment_due_time),15),89)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),15),89)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob19_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>90 and date_add(add_months(to_date(first_instalment_due_time),16),89)>=start_date and date_add(add_months(to_date(first_instalment_due_time),16),89)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),16),89)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob20_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>90 and date_add(add_months(to_date(first_instalment_due_time),17),89)>=start_date and date_add(add_months(to_date(first_instalment_due_time),17),89)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),17),89)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob21_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>90 and date_add(add_months(to_date(first_instalment_due_time),18),89)>=start_date and date_add(add_months(to_date(first_instalment_due_time),18),89)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),18),89)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob22_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>90 and date_add(add_months(to_date(first_instalment_due_time),19),89)>=start_date and date_add(add_months(to_date(first_instalment_due_time),19),89)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),19),89)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob23_principal_os
        ,sum(case when clear_status<>3 and dpd_eod>90 and date_add(add_months(to_date(first_instalment_due_time),20),89)>=start_date and date_add(add_months(to_date(first_instalment_due_time),20),89)<=end_date  and date_add(add_months(to_date(first_instalment_due_time),20),89)>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob24_principal_os
    from risk.dws_risk_${product}_${region}_loan_repayment_zi a
    where  loan_disbursed_month>=from_unixtime(unix_timestamp(add_months('${grass_date}',-24), 'yyyy-MM-dd'), 'yyyyMM')
    and if(trunc('${grass_date}','MM')>=trunc(first_instalment_due_time,'MM'),floor(months_between(trunc('${grass_date}','MM'),trunc(first_instalment_due_time,'MM')))+1,0) >0 
    and if(trunc('${grass_date}','MM')>=trunc(first_instalment_due_time,'MM'),floor(months_between(trunc('${grass_date}','MM'),trunc(first_instalment_due_time,'MM')))+1,0) <=24
    
    and day(a.first_instalment_due_time) ${first_due_day}
    group by a.loan_id  
    ,case when a.loan_disbursed_month is null and a.first_instalment_due_time is not null 
        then add_months(a.first_instalment_due_time,-1) 
        else a.loan_disbursed_month end                                                                                
    ,day(a.first_instalment_due_time)                                                                                                                                       
    ,a.first_instalment_due_time
    ,case when a.loan_tenure < 10 then concat('0', cast(a.loan_tenure as string)) else cast(a.loan_tenure as string) end
    ) a 
) a 
lateral view explode(split(regexp_replace(mob_info,'[{}]',''),','))tab as  sub_mob_info
where date_add(add_months(to_date(a.first_instalment_due_time),cast(regexp_replace(split(split(sub_mob_info,':')[0],'-')[1],'"','') as int)-4),89) <='${grass_date}'
;


-- -- refunded_loan 要剔除统计
-- create or replace temporary view refunded_loan_list_${product}_${region} as
-- select 
--   loan_id 
-- from 
-- (
-- select 
--     loan_id,
--     loan_disbursed_month,
--     datediff(to_date(refund_time),to_date(create_time)) AS refund_diff
-- from credit_mart.dws_${product}_${region}_loan_repayment_df a 
-- WHERE a.loan_disbursed_month >= from_unixtime(unix_timestamp(add_months('${grass_date}',-24), 'yyyy-MM-dd'), 'yyyyMM')
-- and a.grass_date = '${grass_date}'
-- and a.months_on_book > 0
-- and day(a.first_instalment_due_time) ${first_due_day}
-- and refund_time is not null
-- )
-- where refund_diff <= 30
-- ;

-- loan_disbursed_by_tenure loan 的类维度信息
create or replace temporary view loan_disbursed_by_tenure_${product}_${region} as
SELECT
    a.loan_id   
    ,a.platform_user_id
    ,a.credit_user_id 
    ,case when a.loan_disbursed_month is null and a.first_instalment_due_time is not null 
        then add_months(a.first_instalment_due_time,-1) 
        else a.loan_disbursed_month end                                                                                  as loan_disbursed_month
    ,case when day(a.first_instalment_due_time) ${org_first_due_day} then day(a.first_instalment_due_time) else  day(a.first_instalment_due_time) -${floating_due_day} end   as due_time_day
    ,case when a.is_first_bill_loan = 1 then 'New' else 'Repeat' end                                                     as new_repeat_user
    ,case when a.loan_tenure < 10 then concat('0', cast(a.loan_tenure as string)) else cast(a.loan_tenure as string) end as tenure

    -- ,null                                                                                                                as product_type
    -- ,case when upper('${region}')='ID' and '${product}'='spl' and product_code not like '%ciciloan%' then 'SPL' 
    --       when upper('${region}')='ID' and '${product}'='spl'  and product_code like '%ciciloan%' then 'Cicilan Handphone Loan' else null end               as loan_type
    ,${product_flag_column}  as product_type
    ,date_format(date_sub(add_months(to_date(first_instalment_due_time), -1), 1), 'yyyyMM') as disbursement_term
    
    ,sum(a.principal_repayable/b.exchange_rate) as loan_amt_usd
    ,sum(a.principal_repayable)                 as loan_amt
    ,count(distinct a.loan_id)                  as loan_count
from credit_mart.dws_${product}_${region}_loan_repayment_df a 
left join(
    select 
    exchange_rate 
    from mp_order.dim_exchange_rate__reg_s0_live 
    where grass_region = upper('${region}') 
    and grass_date = '${grass_date}'
) b on 1=1 
-- left join refunded_loan_list_${product}_${region} c on a.loan_id = c.loan_id 
where a.loan_disbursed_month >= from_unixtime(unix_timestamp(add_months('${grass_date}',-24), 'yyyy-MM-dd'), 'yyyyMM')
and a.grass_date = '${grass_date}'
and day(a.first_instalment_due_time) ${first_due_day}
-- and c.loan_id is null 
group by 1,2,3,4,5,6,7,8,9
;

insert overwrite table ${SCHEMA}.ads_risk_${product}_${region}_loan_mob_dpd_df partition(grass_date)
select   
    b.platform_user_id      as platform_user_id
    ,b.credit_user_id       as credit_user_id
    ,a.loan_disbursed_month as loan_disbursed_month
    ,a.loan_id              as loan_id 
    ,a.due_time_day         as bill_due_day
    ,a.new_repeat_user      as new_repeat_user
    ,a.tenure               as tenure
    ,case when '${product}' = 'spl' and b.product_type = 3   then 'SPL'
          when '${product}' = 'spl' and b.product_type = 7   then 'SPL Xtra'
          when '${product}' = 'bcl' and b.product_type = 102 then 'BCL Xtra'
          when '${product}' = 'bcl' then 'BCL'
          when '${product}' = 'scl' then 'SCL'
          else null  
     end as product_type        
    ,case when '${product}' = 'spl' and b.product_type = 3   then 'SPL'
          when '${product}' = 'spl' and b.product_type = 7   then 'Cicilan Handphone Loan'
          when '${product}' = 'bcl' and b.product_type = 102 then 'BCL Xtra'
          when '${product}' = 'bcl' then 'BCL'
          when '${product}' = 'scl' then 'SCL'
          else null  
     end as loan_type          
    ,a.dpd_filter           as dpd_filter
    ,a.month_on_book        as month_on_book
    ,a.dpd_amt              as dpd_amt
    ,b.loan_amt_usd         as loan_amt_usd
    ,b.loan_amt             as loan_amt
    ,b.disbursement_term
    ,'${grass_date}'        as grass_date 
from (
    select
     loan_id   
    ,loan_disbursed_month as loan_disbursed_month
    ,due_time_day        as due_time_day
    ,new_repeat_user     as new_repeat_user
    ,tenure              as tenure
    ,month_on_book       as month_on_book
    ,dpd_amt             as dpd_amt
    ,dpd_filter          as dpd_filter
    from dpd0_outstanding_by_tenure_${product}_${region}
    union all 
    select  
    loan_id   
    ,loan_disbursed_month as loan_disbursed_month
    ,due_time_day        as due_time_day
    ,new_repeat_user     as new_repeat_user
    ,tenure              as tenure
    ,month_on_book       as month_on_book
    ,dpd_amt             as dpd_amt
    ,dpd_filter          as dpd_filter
    from dpd7_outstanding_by_tenure_${product}_${region}
    union all 
    select  
    loan_id   
    ,loan_disbursed_month as loan_disbursed_month
    ,due_time_day        as due_time_day
    ,new_repeat_user     as new_repeat_user
    ,tenure              as tenure
    ,month_on_book       as month_on_book
    ,dpd_amt             as dpd_amt
    ,dpd_filter          as dpd_filter
    from dpd15_outstanding_by_tenure_${product}_${region}
    union all 
    select  
    loan_id   
    ,loan_disbursed_month as loan_disbursed_month
    ,due_time_day        as due_time_day
    ,new_repeat_user     as new_repeat_user
    ,tenure              as tenure
    ,month_on_book       as month_on_book
    ,dpd_amt             as dpd_amt
    ,dpd_filter          as dpd_filter
    from m1_outstanding_by_tenure_${product}_${region}
    union all 
    select  
    loan_id   
    ,loan_disbursed_month as loan_disbursed_month
    ,due_time_day        as due_time_day
    ,new_repeat_user     as new_repeat_user
    ,tenure              as tenure
    ,month_on_book       as month_on_book
    ,dpd_amt             as dpd_amt
    ,dpd_filter          as dpd_filter
    from m2_outstanding_by_tenure_${product}_${region}
    union all 
    select  
    loan_id   
    ,loan_disbursed_month as loan_disbursed_month
    ,due_time_day        as due_time_day
    ,new_repeat_user     as new_repeat_user
    ,tenure              as tenure
    ,month_on_book       as month_on_book
    ,dpd_amt             as dpd_amt
    ,dpd_filter          as dpd_filter
    from m3_outstanding_by_tenure_${product}_${region}
) a 
left join  loan_disbursed_by_tenure_${product}_${region} b on a.loan_id = b.loan_id 
-- and a.loan_disbursed_month = b.loan_disbursed_month 
-- and a.due_time_day = b.due_time_day 
-- and a.new_repeat_user = b.new_repeat_user
-- and a.tenure = b.tenure
;

