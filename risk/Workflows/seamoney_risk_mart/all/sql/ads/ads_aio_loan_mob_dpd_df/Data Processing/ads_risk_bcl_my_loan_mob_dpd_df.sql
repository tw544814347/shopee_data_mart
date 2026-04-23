--********************************************************************--
-- Author:              huangyue@shopee.com
-- Created Time:        2025-10-20T14:00:00
-- Theme Domain：       loan_mob_dpd
-- Description:         vintage分析. MY BCL专用模版. simple_disburse_month as loan_disbured_month, disburse_time 计算mob_date 
                        -- MY BCL需要adjust month due time
                        -- ,case
                        --     when dayofweek(month_due_date) = 7 then month_due_date + interval '2' day
                        --     when dayofweek(month_due_date) = 1 then month_due_date + interval '1' day
                        --     else month_due_date
                        -- end as month_due_date

-- Data Granularity:    loan_id + dpd_filter + month_on_book
-- 文档:                 https://confluence.shopee.io/pages/viewpage.action?spaceKey=FSDT&title=ads_aio_loan_mob_dpd_df
-- 变更历史：
-- 2025-11-27           disbursement_term改为first_instalment_due_time - 1month - 1day

--********************************************************************--


-- dpd0_outstanding_by_tenure
create or replace temporary view dpd0_outstanding_by_tenure_${product}_${region} as
select 
    loan_id  
    ,loan_disbursed_month as loan_disbursed_month
    ,due_time_day        as due_time_day
    ,new_repeat_user      as new_repeat_user
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
    ,disburse_date  
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
        ,a.loan_disbursed_month                                                                                
        ,a.due_time_day
        ,max(a.new_repeat_user) as new_repeat_user
        ,min(a.tenure) as tenure
        ,a.first_instalment_due_time
        ,disburse_date
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob1_date, if(end_date='9999-12-31','${grass_date}',end_date))>0 and  mob1_date  >=start_date and mob1_date <=end_date and mob1_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob1_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob2_date, if(end_date='9999-12-31','${grass_date}',end_date))>0 and  mob2_date  >=start_date and mob2_date <=end_date and mob2_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob2_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob3_date, if(end_date='9999-12-31','${grass_date}',end_date))>0 and  mob3_date  >=start_date and mob3_date <=end_date and mob3_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob3_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob4_date, if(end_date='9999-12-31','${grass_date}',end_date))>0 and  mob4_date  >=start_date and mob4_date <=end_date and mob4_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob4_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob5_date, if(end_date='9999-12-31','${grass_date}',end_date))>0 and  mob5_date  >=start_date and mob5_date <=end_date and mob5_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob5_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob6_date, if(end_date='9999-12-31','${grass_date}',end_date))>0 and  mob6_date  >=start_date and mob6_date <=end_date and mob6_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob6_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob7_date, if(end_date='9999-12-31','${grass_date}',end_date))>0 and  mob7_date  >=start_date and mob7_date <=end_date and mob7_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob7_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob8_date, if(end_date='9999-12-31','${grass_date}',end_date))>0 and  mob8_date  >=start_date and mob8_date <=end_date and mob8_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob8_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob9_date, if(end_date='9999-12-31','${grass_date}',end_date))>0 and  mob9_date  >=start_date and mob9_date <=end_date and mob9_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob9_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob10_date, if(end_date='9999-12-31','${grass_date}',end_date))>0 and mob10_date >=start_date and mob10_date<=end_date and mob10_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob10_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob11_date, if(end_date='9999-12-31','${grass_date}',end_date))>0 and mob11_date >=start_date and mob11_date<=end_date and mob11_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob11_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob12_date, if(end_date='9999-12-31','${grass_date}',end_date))>0 and mob12_date >=start_date and mob12_date<=end_date and mob12_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob12_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob13_date, if(end_date='9999-12-31','${grass_date}',end_date))>0 and mob13_date >=start_date and mob13_date<=end_date and mob13_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob13_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob14_date, if(end_date='9999-12-31','${grass_date}',end_date))>0 and mob14_date >=start_date and mob14_date<=end_date and mob14_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob14_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob15_date, if(end_date='9999-12-31','${grass_date}',end_date))>0 and mob15_date >=start_date and mob15_date<=end_date and mob15_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob15_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob16_date, if(end_date='9999-12-31','${grass_date}',end_date))>0 and mob16_date >=start_date and mob16_date<=end_date and mob16_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob16_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob17_date, if(end_date='9999-12-31','${grass_date}',end_date))>0 and mob17_date >=start_date and mob17_date<=end_date and mob17_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob17_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob18_date, if(end_date='9999-12-31','${grass_date}',end_date))>0 and mob18_date >=start_date and mob18_date<=end_date and mob18_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob18_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob19_date, if(end_date='9999-12-31','${grass_date}',end_date))>0 and mob19_date >=start_date and mob19_date<=end_date and mob19_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob19_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob20_date, if(end_date='9999-12-31','${grass_date}',end_date))>0 and mob20_date >=start_date and mob20_date<=end_date and mob20_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob20_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob21_date, if(end_date='9999-12-31','${grass_date}',end_date))>0 and mob21_date >=start_date and mob21_date<=end_date and mob21_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob21_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob22_date, if(end_date='9999-12-31','${grass_date}',end_date))>0 and mob22_date >=start_date and mob22_date<=end_date and mob22_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob22_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob23_date, if(end_date='9999-12-31','${grass_date}',end_date))>0 and mob23_date >=start_date and mob23_date<=end_date and mob23_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob23_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob24_date, if(end_date='9999-12-31','${grass_date}',end_date))>0 and mob24_date >=start_date and mob24_date<=end_date and mob24_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end) as dpd0_mob24_principal_os
    from (
            select a.loan_id  
                ,case when a.simple_disburse_month is null and a.first_instalment_due_time is not null 
                    then add_months(a.first_instalment_due_time,-1) 
                    else a.simple_disburse_month end                                                                                     as loan_disbursed_month
                ,day(a.first_instalment_due_time)                                                                                       as due_time_day
                ,new_repeat_user                                                                                                        as new_repeat_user
                ,a.first_instalment_due_time
                ,case when a.loan_tenure < 10 then concat('0', cast(a.loan_tenure as string)) else cast(a.loan_tenure as string) end    as tenure
                ,clear_status
                ,dpd_eod
                ,start_date
                ,end_date
                ,principal_os
                ,to_date(a.disburse_time)   as disburse_date
                ,case when dayofweek(add_months(to_date(disburse_time),0 +1 )) = 7 then add_months(to_date(disburse_time),0 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),0 +1 )) = 1 then add_months(to_date(disburse_time),0 +1 ) + interval '1' day else add_months(to_date(disburse_time),0 +1 ) end as mob1_date
                ,case when dayofweek(add_months(to_date(disburse_time),1 +1 )) = 7 then add_months(to_date(disburse_time),1 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),1 +1 )) = 1 then add_months(to_date(disburse_time),1 +1 ) + interval '1' day else add_months(to_date(disburse_time),1 +1 ) end as mob2_date
                ,case when dayofweek(add_months(to_date(disburse_time),2 +1 )) = 7 then add_months(to_date(disburse_time),2 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),2 +1 )) = 1 then add_months(to_date(disburse_time),2 +1 ) + interval '1' day else add_months(to_date(disburse_time),2 +1 ) end as mob3_date
                ,case when dayofweek(add_months(to_date(disburse_time),3 +1 )) = 7 then add_months(to_date(disburse_time),3 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),3 +1 )) = 1 then add_months(to_date(disburse_time),3 +1 ) + interval '1' day else add_months(to_date(disburse_time),3 +1 ) end as mob4_date
                ,case when dayofweek(add_months(to_date(disburse_time),4 +1 )) = 7 then add_months(to_date(disburse_time),4 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),4 +1 )) = 1 then add_months(to_date(disburse_time),4 +1 ) + interval '1' day else add_months(to_date(disburse_time),4 +1 ) end as mob5_date
                ,case when dayofweek(add_months(to_date(disburse_time),5 +1 )) = 7 then add_months(to_date(disburse_time),5 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),5 +1 )) = 1 then add_months(to_date(disburse_time),5 +1 ) + interval '1' day else add_months(to_date(disburse_time),5 +1 ) end as mob6_date
                ,case when dayofweek(add_months(to_date(disburse_time),6 +1 )) = 7 then add_months(to_date(disburse_time),6 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),6 +1 )) = 1 then add_months(to_date(disburse_time),6 +1 ) + interval '1' day else add_months(to_date(disburse_time),6 +1 ) end as mob7_date
                ,case when dayofweek(add_months(to_date(disburse_time),7 +1 )) = 7 then add_months(to_date(disburse_time),7 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),7 +1 )) = 1 then add_months(to_date(disburse_time),7 +1 ) + interval '1' day else add_months(to_date(disburse_time),7 +1 ) end as mob8_date
                ,case when dayofweek(add_months(to_date(disburse_time),8 +1 )) = 7 then add_months(to_date(disburse_time),8 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),8 +1 )) = 1 then add_months(to_date(disburse_time),8 +1 ) + interval '1' day else add_months(to_date(disburse_time),8 +1 ) end as mob9_date
                ,case when dayofweek(add_months(to_date(disburse_time),9 +1 )) = 7 then add_months(to_date(disburse_time),9 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),9 +1 )) = 1 then add_months(to_date(disburse_time),9 +1 ) + interval '1' day else add_months(to_date(disburse_time),9 +1 ) end as mob10_date
                ,case when dayofweek(add_months(to_date(disburse_time),10+1 )) = 7 then add_months(to_date(disburse_time),10+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),10+1 )) = 1 then add_months(to_date(disburse_time),10+1 ) + interval '1' day else add_months(to_date(disburse_time),10+1 ) end as mob11_date
                ,case when dayofweek(add_months(to_date(disburse_time),11+1 )) = 7 then add_months(to_date(disburse_time),11+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),11+1 )) = 1 then add_months(to_date(disburse_time),11+1 ) + interval '1' day else add_months(to_date(disburse_time),11+1 ) end as mob12_date
                ,case when dayofweek(add_months(to_date(disburse_time),12+1 )) = 7 then add_months(to_date(disburse_time),12+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),12+1 )) = 1 then add_months(to_date(disburse_time),12+1 ) + interval '1' day else add_months(to_date(disburse_time),12+1 ) end as mob13_date
                ,case when dayofweek(add_months(to_date(disburse_time),13+1 )) = 7 then add_months(to_date(disburse_time),13+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),13+1 )) = 1 then add_months(to_date(disburse_time),13+1 ) + interval '1' day else add_months(to_date(disburse_time),13+1 ) end as mob14_date
                ,case when dayofweek(add_months(to_date(disburse_time),14+1 )) = 7 then add_months(to_date(disburse_time),14+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),14+1 )) = 1 then add_months(to_date(disburse_time),14+1 ) + interval '1' day else add_months(to_date(disburse_time),14+1 ) end as mob15_date
                ,case when dayofweek(add_months(to_date(disburse_time),15+1 )) = 7 then add_months(to_date(disburse_time),15+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),15+1 )) = 1 then add_months(to_date(disburse_time),15+1 ) + interval '1' day else add_months(to_date(disburse_time),15+1 ) end as mob16_date
                ,case when dayofweek(add_months(to_date(disburse_time),16+1 )) = 7 then add_months(to_date(disburse_time),16+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),16+1 )) = 1 then add_months(to_date(disburse_time),16+1 ) + interval '1' day else add_months(to_date(disburse_time),16+1 ) end as mob17_date
                ,case when dayofweek(add_months(to_date(disburse_time),17+1 )) = 7 then add_months(to_date(disburse_time),17+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),17+1 )) = 1 then add_months(to_date(disburse_time),17+1 ) + interval '1' day else add_months(to_date(disburse_time),17+1 ) end as mob18_date
                ,case when dayofweek(add_months(to_date(disburse_time),18+1 )) = 7 then add_months(to_date(disburse_time),18+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),18+1 )) = 1 then add_months(to_date(disburse_time),18+1 ) + interval '1' day else add_months(to_date(disburse_time),18+1 ) end as mob19_date
                ,case when dayofweek(add_months(to_date(disburse_time),19+1 )) = 7 then add_months(to_date(disburse_time),19+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),19+1 )) = 1 then add_months(to_date(disburse_time),19+1 ) + interval '1' day else add_months(to_date(disburse_time),19+1 ) end as mob20_date
                ,case when dayofweek(add_months(to_date(disburse_time),20+1 )) = 7 then add_months(to_date(disburse_time),20+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),20+1 )) = 1 then add_months(to_date(disburse_time),20+1 ) + interval '1' day else add_months(to_date(disburse_time),20+1 ) end as mob21_date
                ,case when dayofweek(add_months(to_date(disburse_time),21+1 )) = 7 then add_months(to_date(disburse_time),21+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),21+1 )) = 1 then add_months(to_date(disburse_time),21+1 ) + interval '1' day else add_months(to_date(disburse_time),21+1 ) end as mob22_date
                ,case when dayofweek(add_months(to_date(disburse_time),22+1 )) = 7 then add_months(to_date(disburse_time),22+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),22+1 )) = 1 then add_months(to_date(disburse_time),22+1 ) + interval '1' day else add_months(to_date(disburse_time),22+1 ) end as mob23_date
                ,case when dayofweek(add_months(to_date(disburse_time),23+1 )) = 7 then add_months(to_date(disburse_time),23+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),23+1 )) = 1 then add_months(to_date(disburse_time),23+1 ) + interval '1' day else add_months(to_date(disburse_time),23+1 ) end as mob24_date
            from risk.dws_risk_${product}_${region}_loan_repayment_zi a
            where loan_disbursed_month>=from_unixtime(unix_timestamp(add_months('${grass_date}',-24), 'yyyy-MM-dd'), 'yyyyMM')
            and if(trunc('${grass_date}','MM')>=trunc(first_instalment_due_time,'MM'),floor(months_between(trunc('${grass_date}','MM'),trunc(first_instalment_due_time,'MM')))+1,0) >0 
            and if(trunc('${grass_date}','MM')>=trunc(first_instalment_due_time,'MM'),floor(months_between(trunc('${grass_date}','MM'),trunc(first_instalment_due_time,'MM')))+1,0) <=24
            and day(a.first_instalment_due_time) ${first_due_day}
        ) a
    group by a.loan_id  
    ,a.loan_disbursed_month                                                                                
    ,a.due_time_day
    -- ,a.tenure
    ,a.first_instalment_due_time
    ,disburse_date
    ) a 
) a 
lateral view explode(split(regexp_replace(mob_info,'[{}]',''),','))tab as  sub_mob_info
-- where date_format(add_months(from_unixtime(unix_timestamp(loan_disbursed_month, 'yyyyMM'), 'yyyy-MM-dd'),cast(regexp_replace(split(split(sub_mob_info,':')[0],'-')[1],'"','') as int)), 'yyyy-MM')<=substr('${grass_date}',1,7)
where date_add(add_months(disburse_date,cast(regexp_replace(split(split(sub_mob_info,':')[0],'-')[1],'"','') as int)-1+1),-1+1) <='${grass_date}'
;



-- dpd7_outstanding_by_tenure
create or replace temporary view dpd7_outstanding_by_tenure_${product}_${region} as
select
    loan_id 
    ,loan_disbursed_month as loan_disbursed_month
    ,due_time_day        as due_time_day
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
    ,a.disburse_date
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
        ,min(a.tenure) as tenure
        ,a.first_instalment_due_time
        ,a.disburse_date
        ,sum(case when clear_status<>3 and dpd_eod+ datediff(mob1_date , if(end_date='9999-12-31','${grass_date}',end_date))>7 and mob1_date  >=start_date and mob1_date  <=end_date and mob1_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob1_principal_os
        ,sum(case when clear_status<>3 and dpd_eod+ datediff(mob2_date , if(end_date='9999-12-31','${grass_date}',end_date))>7 and mob2_date  >=start_date and mob2_date  <=end_date and mob2_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob2_principal_os
        ,sum(case when clear_status<>3 and dpd_eod+ datediff(mob3_date , if(end_date='9999-12-31','${grass_date}',end_date))>7 and mob3_date  >=start_date and mob3_date  <=end_date and mob3_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob3_principal_os
        ,sum(case when clear_status<>3 and dpd_eod+ datediff(mob4_date , if(end_date='9999-12-31','${grass_date}',end_date))>7 and mob4_date  >=start_date and mob4_date  <=end_date and mob4_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob4_principal_os
        ,sum(case when clear_status<>3 and dpd_eod+ datediff(mob5_date , if(end_date='9999-12-31','${grass_date}',end_date))>7 and mob5_date  >=start_date and mob5_date  <=end_date and mob5_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob5_principal_os
        ,sum(case when clear_status<>3 and dpd_eod+ datediff(mob6_date , if(end_date='9999-12-31','${grass_date}',end_date))>7 and mob6_date  >=start_date and mob6_date  <=end_date and mob6_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob6_principal_os
        ,sum(case when clear_status<>3 and dpd_eod+ datediff(mob7_date , if(end_date='9999-12-31','${grass_date}',end_date))>7 and mob7_date  >=start_date and mob7_date  <=end_date and mob7_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob7_principal_os
        ,sum(case when clear_status<>3 and dpd_eod+ datediff(mob8_date , if(end_date='9999-12-31','${grass_date}',end_date))>7 and mob8_date  >=start_date and mob8_date  <=end_date and mob8_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob8_principal_os
        ,sum(case when clear_status<>3 and dpd_eod+ datediff(mob9_date , if(end_date='9999-12-31','${grass_date}',end_date))>7 and mob9_date  >=start_date and mob9_date  <=end_date and mob9_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob9_principal_os
        ,sum(case when clear_status<>3 and dpd_eod+ datediff(mob10_date, if(end_date='9999-12-31','${grass_date}',end_date))>7 and mob10_date >=start_date and mob10_date <=end_date and mob10_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob10_principal_os
        ,sum(case when clear_status<>3 and dpd_eod+ datediff(mob11_date, if(end_date='9999-12-31','${grass_date}',end_date))>7 and mob11_date >=start_date and mob11_date <=end_date and mob11_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob11_principal_os
        ,sum(case when clear_status<>3 and dpd_eod+ datediff(mob12_date, if(end_date='9999-12-31','${grass_date}',end_date))>7 and mob12_date >=start_date and mob12_date <=end_date and mob12_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob12_principal_os
        ,sum(case when clear_status<>3 and dpd_eod+ datediff(mob13_date, if(end_date='9999-12-31','${grass_date}',end_date))>7 and mob13_date >=start_date and mob13_date <=end_date and mob13_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob13_principal_os
        ,sum(case when clear_status<>3 and dpd_eod+ datediff(mob14_date, if(end_date='9999-12-31','${grass_date}',end_date))>7 and mob14_date >=start_date and mob14_date <=end_date and mob14_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob14_principal_os
        ,sum(case when clear_status<>3 and dpd_eod+ datediff(mob15_date, if(end_date='9999-12-31','${grass_date}',end_date))>7 and mob15_date >=start_date and mob15_date <=end_date and mob15_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob15_principal_os
        ,sum(case when clear_status<>3 and dpd_eod+ datediff(mob16_date, if(end_date='9999-12-31','${grass_date}',end_date))>7 and mob16_date >=start_date and mob16_date <=end_date and mob16_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob16_principal_os
        ,sum(case when clear_status<>3 and dpd_eod+ datediff(mob17_date, if(end_date='9999-12-31','${grass_date}',end_date))>7 and mob17_date >=start_date and mob17_date <=end_date and mob17_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob17_principal_os
        ,sum(case when clear_status<>3 and dpd_eod+ datediff(mob18_date, if(end_date='9999-12-31','${grass_date}',end_date))>7 and mob18_date >=start_date and mob18_date <=end_date and mob18_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob18_principal_os
        ,sum(case when clear_status<>3 and dpd_eod+ datediff(mob19_date, if(end_date='9999-12-31','${grass_date}',end_date))>7 and mob19_date >=start_date and mob19_date <=end_date and mob19_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob19_principal_os
        ,sum(case when clear_status<>3 and dpd_eod+ datediff(mob20_date, if(end_date='9999-12-31','${grass_date}',end_date))>7 and mob20_date >=start_date and mob20_date <=end_date and mob20_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob20_principal_os
        ,sum(case when clear_status<>3 and dpd_eod+ datediff(mob21_date, if(end_date='9999-12-31','${grass_date}',end_date))>7 and mob21_date >=start_date and mob21_date <=end_date and mob21_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob21_principal_os
        ,sum(case when clear_status<>3 and dpd_eod+ datediff(mob22_date, if(end_date='9999-12-31','${grass_date}',end_date))>7 and mob22_date >=start_date and mob22_date <=end_date and mob22_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob22_principal_os
        ,sum(case when clear_status<>3 and dpd_eod+ datediff(mob23_date, if(end_date='9999-12-31','${grass_date}',end_date))>7 and mob23_date >=start_date and mob23_date <=end_date and mob23_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob23_principal_os
        ,sum(case when clear_status<>3 and dpd_eod+ datediff(mob24_date, if(end_date='9999-12-31','${grass_date}',end_date))>7 and mob24_date >=start_date and mob24_date <=end_date and mob24_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd7_mob24_principal_os
    from(
        select 
            a.loan_id  
            ,case when a.simple_disburse_month is null and a.first_instalment_due_time is not null 
                then add_months(a.first_instalment_due_time,-1) 
                else a.simple_disburse_month end                                                                                     as loan_disbursed_month
            ,day(a.first_instalment_due_time)                                                                                       as due_time_day
            ,new_repeat_user                                                                                                        as new_repeat_user
            ,a.first_instalment_due_time
            ,to_date(a.disburse_time)   as disburse_date
            ,case when a.loan_tenure < 10 then concat('0', cast(a.loan_tenure as string)) else cast(a.loan_tenure as string) end    as tenure
            ,clear_status
            ,dpd_eod
            ,start_date
            ,end_date
            ,principal_os
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),0 +1 )) = 7 then add_months(to_date(disburse_time),0 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),0 +1 )) = 1 then add_months(to_date(disburse_time),0 +1 ) + interval '1' day else add_months(to_date(disburse_time),0 +1 ) end,7)  as mob1_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),1 +1 )) = 7 then add_months(to_date(disburse_time),1 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),1 +1 )) = 1 then add_months(to_date(disburse_time),1 +1 ) + interval '1' day else add_months(to_date(disburse_time),1 +1 ) end,7)  as mob2_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),2 +1 )) = 7 then add_months(to_date(disburse_time),2 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),2 +1 )) = 1 then add_months(to_date(disburse_time),2 +1 ) + interval '1' day else add_months(to_date(disburse_time),2 +1 ) end,7)  as mob3_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),3 +1 )) = 7 then add_months(to_date(disburse_time),3 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),3 +1 )) = 1 then add_months(to_date(disburse_time),3 +1 ) + interval '1' day else add_months(to_date(disburse_time),3 +1 ) end,7)  as mob4_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),4 +1 )) = 7 then add_months(to_date(disburse_time),4 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),4 +1 )) = 1 then add_months(to_date(disburse_time),4 +1 ) + interval '1' day else add_months(to_date(disburse_time),4 +1 ) end,7)  as mob5_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),5 +1 )) = 7 then add_months(to_date(disburse_time),5 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),5 +1 )) = 1 then add_months(to_date(disburse_time),5 +1 ) + interval '1' day else add_months(to_date(disburse_time),5 +1 ) end,7)  as mob6_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),6 +1 )) = 7 then add_months(to_date(disburse_time),6 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),6 +1 )) = 1 then add_months(to_date(disburse_time),6 +1 ) + interval '1' day else add_months(to_date(disburse_time),6 +1 ) end,7)  as mob7_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),7 +1 )) = 7 then add_months(to_date(disburse_time),7 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),7 +1 )) = 1 then add_months(to_date(disburse_time),7 +1 ) + interval '1' day else add_months(to_date(disburse_time),7 +1 ) end,7)  as mob8_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),8 +1 )) = 7 then add_months(to_date(disburse_time),8 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),8 +1 )) = 1 then add_months(to_date(disburse_time),8 +1 ) + interval '1' day else add_months(to_date(disburse_time),8 +1 ) end,7)  as mob9_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),9 +1 )) = 7 then add_months(to_date(disburse_time),9 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),9 +1 )) = 1 then add_months(to_date(disburse_time),9 +1 ) + interval '1' day else add_months(to_date(disburse_time),9 +1 ) end,7)  as mob10_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),10+1 )) = 7 then add_months(to_date(disburse_time),10+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),10+1 )) = 1 then add_months(to_date(disburse_time),10+1 ) + interval '1' day else add_months(to_date(disburse_time),10+1 ) end,7) as mob11_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),11+1 )) = 7 then add_months(to_date(disburse_time),11+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),11+1 )) = 1 then add_months(to_date(disburse_time),11+1 ) + interval '1' day else add_months(to_date(disburse_time),11+1 ) end,7) as mob12_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),12+1 )) = 7 then add_months(to_date(disburse_time),12+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),12+1 )) = 1 then add_months(to_date(disburse_time),12+1 ) + interval '1' day else add_months(to_date(disburse_time),12+1 ) end,7) as mob13_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),13+1 )) = 7 then add_months(to_date(disburse_time),13+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),13+1 )) = 1 then add_months(to_date(disburse_time),13+1 ) + interval '1' day else add_months(to_date(disburse_time),13+1 ) end,7) as mob14_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),14+1 )) = 7 then add_months(to_date(disburse_time),14+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),14+1 )) = 1 then add_months(to_date(disburse_time),14+1 ) + interval '1' day else add_months(to_date(disburse_time),14+1 ) end,7) as mob15_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),15+1 )) = 7 then add_months(to_date(disburse_time),15+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),15+1 )) = 1 then add_months(to_date(disburse_time),15+1 ) + interval '1' day else add_months(to_date(disburse_time),15+1 ) end,7) as mob16_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),16+1 )) = 7 then add_months(to_date(disburse_time),16+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),16+1 )) = 1 then add_months(to_date(disburse_time),16+1 ) + interval '1' day else add_months(to_date(disburse_time),16+1 ) end,7) as mob17_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),17+1 )) = 7 then add_months(to_date(disburse_time),17+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),17+1 )) = 1 then add_months(to_date(disburse_time),17+1 ) + interval '1' day else add_months(to_date(disburse_time),17+1 ) end,7) as mob18_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),18+1 )) = 7 then add_months(to_date(disburse_time),18+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),18+1 )) = 1 then add_months(to_date(disburse_time),18+1 ) + interval '1' day else add_months(to_date(disburse_time),18+1 ) end,7) as mob19_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),19+1 )) = 7 then add_months(to_date(disburse_time),19+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),19+1 )) = 1 then add_months(to_date(disburse_time),19+1 ) + interval '1' day else add_months(to_date(disburse_time),19+1 ) end,7) as mob20_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),20+1 )) = 7 then add_months(to_date(disburse_time),20+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),20+1 )) = 1 then add_months(to_date(disburse_time),20+1 ) + interval '1' day else add_months(to_date(disburse_time),20+1 ) end,7) as mob21_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),21+1 )) = 7 then add_months(to_date(disburse_time),21+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),21+1 )) = 1 then add_months(to_date(disburse_time),21+1 ) + interval '1' day else add_months(to_date(disburse_time),21+1 ) end,7) as mob22_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),22+1 )) = 7 then add_months(to_date(disburse_time),22+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),22+1 )) = 1 then add_months(to_date(disburse_time),22+1 ) + interval '1' day else add_months(to_date(disburse_time),22+1 ) end,7) as mob23_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),23+1 )) = 7 then add_months(to_date(disburse_time),23+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),23+1 )) = 1 then add_months(to_date(disburse_time),23+1 ) + interval '1' day else add_months(to_date(disburse_time),23+1 ) end,7) as mob24_date
        from risk.dws_risk_${product}_${region}_loan_repayment_zi a
        where loan_disbursed_month>=from_unixtime(unix_timestamp(add_months('${grass_date}',-24), 'yyyy-MM-dd'), 'yyyyMM')
        and if(trunc('${grass_date}','MM')>=trunc(first_instalment_due_time,'MM'),floor(months_between(trunc('${grass_date}','MM'),trunc(first_instalment_due_time,'MM')))+1,0) >0 
        and if(trunc('${grass_date}','MM')>=trunc(first_instalment_due_time,'MM'),floor(months_between(trunc('${grass_date}','MM'),trunc(first_instalment_due_time,'MM')))+1,0) <=24
        and day(a.first_instalment_due_time) ${first_due_day}
        )a
    group by a.loan_id  
    ,a.loan_disbursed_month                                                                                
    ,a.due_time_day
    -- ,a.tenure
    ,a.first_instalment_due_time
    ,a.disburse_date
    ) a 
) a 
lateral view explode(split(regexp_replace(mob_info,'[{}]',''),','))tab as  sub_mob_info
where date_add(add_months(disburse_date,cast(regexp_replace(split(split(sub_mob_info,':')[0],'-')[1],'"','') as int)-1+1),6+1) <='${grass_date}'
;



-- dpd15_outstanding_by_tenure
create or replace temporary view dpd15_outstanding_by_tenure_${product}_${region} as
select 
    loan_id 
    ,loan_disbursed_month as loan_disbursed_month
    ,due_time_day        as due_time_day
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
    ,a.disburse_date
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
        ,a.disburse_date
        ,max(a.new_repeat_user) as new_repeat_user
        ,min(a.tenure) as tenure
        ,a.first_instalment_due_time
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob1_date , if(end_date='9999-12-31','${grass_date}',end_date))>15 and mob1_date  >=start_date and mob1_date  <=end_date and mob1_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob1_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob2_date , if(end_date='9999-12-31','${grass_date}',end_date))>15 and mob2_date  >=start_date and mob2_date  <=end_date and mob2_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob2_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob3_date , if(end_date='9999-12-31','${grass_date}',end_date))>15 and mob3_date  >=start_date and mob3_date  <=end_date and mob3_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob3_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob4_date , if(end_date='9999-12-31','${grass_date}',end_date))>15 and mob4_date  >=start_date and mob4_date  <=end_date and mob4_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob4_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob5_date , if(end_date='9999-12-31','${grass_date}',end_date))>15 and mob5_date  >=start_date and mob5_date  <=end_date and mob5_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob5_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob6_date , if(end_date='9999-12-31','${grass_date}',end_date))>15 and mob6_date  >=start_date and mob6_date  <=end_date and mob6_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob6_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob7_date , if(end_date='9999-12-31','${grass_date}',end_date))>15 and mob7_date  >=start_date and mob7_date  <=end_date and mob7_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob7_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob8_date , if(end_date='9999-12-31','${grass_date}',end_date))>15 and mob8_date  >=start_date and mob8_date  <=end_date and mob8_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob8_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob9_date , if(end_date='9999-12-31','${grass_date}',end_date))>15 and mob9_date  >=start_date and mob9_date  <=end_date and mob9_date  >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob9_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob10_date, if(end_date='9999-12-31','${grass_date}',end_date))>15 and mob10_date >=start_date and mob10_date <=end_date and mob10_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob10_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob11_date, if(end_date='9999-12-31','${grass_date}',end_date))>15 and mob11_date >=start_date and mob11_date <=end_date and mob11_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob11_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob12_date, if(end_date='9999-12-31','${grass_date}',end_date))>15 and mob12_date >=start_date and mob12_date <=end_date and mob12_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob12_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob13_date, if(end_date='9999-12-31','${grass_date}',end_date))>15 and mob13_date >=start_date and mob13_date <=end_date and mob13_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob13_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob14_date, if(end_date='9999-12-31','${grass_date}',end_date))>15 and mob14_date >=start_date and mob14_date <=end_date and mob14_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob14_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob15_date, if(end_date='9999-12-31','${grass_date}',end_date))>15 and mob15_date >=start_date and mob15_date <=end_date and mob15_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob15_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob16_date, if(end_date='9999-12-31','${grass_date}',end_date))>15 and mob16_date >=start_date and mob16_date <=end_date and mob16_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob16_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob17_date, if(end_date='9999-12-31','${grass_date}',end_date))>15 and mob17_date >=start_date and mob17_date <=end_date and mob17_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob17_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob18_date, if(end_date='9999-12-31','${grass_date}',end_date))>15 and mob18_date >=start_date and mob18_date <=end_date and mob18_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob18_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob19_date, if(end_date='9999-12-31','${grass_date}',end_date))>15 and mob19_date >=start_date and mob19_date <=end_date and mob19_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob19_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob20_date, if(end_date='9999-12-31','${grass_date}',end_date))>15 and mob20_date >=start_date and mob20_date <=end_date and mob20_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob20_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob21_date, if(end_date='9999-12-31','${grass_date}',end_date))>15 and mob21_date >=start_date and mob21_date <=end_date and mob21_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob21_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob22_date, if(end_date='9999-12-31','${grass_date}',end_date))>15 and mob22_date >=start_date and mob22_date <=end_date and mob22_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob22_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob23_date, if(end_date='9999-12-31','${grass_date}',end_date))>15 and mob23_date >=start_date and mob23_date <=end_date and mob23_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob23_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + datediff(mob24_date, if(end_date='9999-12-31','${grass_date}',end_date))>15 and mob24_date >=start_date and mob24_date <=end_date and mob24_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)) then principal_os else 0 end)  dpd15_mob24_principal_os
    from(
        
        select 
            a.loan_id  
            ,case when a.simple_disburse_month is null and a.first_instalment_due_time is not null 
                then add_months(a.first_instalment_due_time,-1) 
                else a.simple_disburse_month end                                                                                     as loan_disbursed_month
            ,day(a.first_instalment_due_time)                                                                                       as due_time_day
            ,new_repeat_user                                                                                                        as new_repeat_user
            ,a.first_instalment_due_time
            ,case when a.loan_tenure < 10 then concat('0', cast(a.loan_tenure as string)) else cast(a.loan_tenure as string) end    as tenure
            ,clear_status
            ,dpd_eod
            ,start_date
            ,end_date
            ,principal_os
            ,to_date(a.disburse_time)   as disburse_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),0 +1 )) = 7 then add_months(to_date(disburse_time),0 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),0 +1 )) = 1 then add_months(to_date(disburse_time),0 +1 ) + interval '1' day else add_months(to_date(disburse_time),0 +1 ) end,15)  as mob1_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),1 +1 )) = 7 then add_months(to_date(disburse_time),1 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),1 +1 )) = 1 then add_months(to_date(disburse_time),1 +1 ) + interval '1' day else add_months(to_date(disburse_time),1 +1 ) end,15)  as mob2_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),2 +1 )) = 7 then add_months(to_date(disburse_time),2 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),2 +1 )) = 1 then add_months(to_date(disburse_time),2 +1 ) + interval '1' day else add_months(to_date(disburse_time),2 +1 ) end,15)  as mob3_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),3 +1 )) = 7 then add_months(to_date(disburse_time),3 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),3 +1 )) = 1 then add_months(to_date(disburse_time),3 +1 ) + interval '1' day else add_months(to_date(disburse_time),3 +1 ) end,15)  as mob4_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),4 +1 )) = 7 then add_months(to_date(disburse_time),4 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),4 +1 )) = 1 then add_months(to_date(disburse_time),4 +1 ) + interval '1' day else add_months(to_date(disburse_time),4 +1 ) end,15)  as mob5_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),5 +1 )) = 7 then add_months(to_date(disburse_time),5 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),5 +1 )) = 1 then add_months(to_date(disburse_time),5 +1 ) + interval '1' day else add_months(to_date(disburse_time),5 +1 ) end,15)  as mob6_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),6 +1 )) = 7 then add_months(to_date(disburse_time),6 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),6 +1 )) = 1 then add_months(to_date(disburse_time),6 +1 ) + interval '1' day else add_months(to_date(disburse_time),6 +1 ) end,15)  as mob7_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),7 +1 )) = 7 then add_months(to_date(disburse_time),7 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),7 +1 )) = 1 then add_months(to_date(disburse_time),7 +1 ) + interval '1' day else add_months(to_date(disburse_time),7 +1 ) end,15)  as mob8_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),8 +1 )) = 7 then add_months(to_date(disburse_time),8 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),8 +1 )) = 1 then add_months(to_date(disburse_time),8 +1 ) + interval '1' day else add_months(to_date(disburse_time),8 +1 ) end,15)  as mob9_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),9 +1 )) = 7 then add_months(to_date(disburse_time),9 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),9 +1 )) = 1 then add_months(to_date(disburse_time),9 +1 ) + interval '1' day else add_months(to_date(disburse_time),9 +1 ) end,15)  as mob10_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),10+1 )) = 7 then add_months(to_date(disburse_time),10+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),10+1 )) = 1 then add_months(to_date(disburse_time),10+1 ) + interval '1' day else add_months(to_date(disburse_time),10+1 ) end,15) as mob11_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),11+1 )) = 7 then add_months(to_date(disburse_time),11+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),11+1 )) = 1 then add_months(to_date(disburse_time),11+1 ) + interval '1' day else add_months(to_date(disburse_time),11+1 ) end,15) as mob12_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),12+1 )) = 7 then add_months(to_date(disburse_time),12+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),12+1 )) = 1 then add_months(to_date(disburse_time),12+1 ) + interval '1' day else add_months(to_date(disburse_time),12+1 ) end,15) as mob13_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),13+1 )) = 7 then add_months(to_date(disburse_time),13+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),13+1 )) = 1 then add_months(to_date(disburse_time),13+1 ) + interval '1' day else add_months(to_date(disburse_time),13+1 ) end,15) as mob14_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),14+1 )) = 7 then add_months(to_date(disburse_time),14+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),14+1 )) = 1 then add_months(to_date(disburse_time),14+1 ) + interval '1' day else add_months(to_date(disburse_time),14+1 ) end,15) as mob15_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),15+1 )) = 7 then add_months(to_date(disburse_time),15+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),15+1 )) = 1 then add_months(to_date(disburse_time),15+1 ) + interval '1' day else add_months(to_date(disburse_time),15+1 ) end,15) as mob16_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),16+1 )) = 7 then add_months(to_date(disburse_time),16+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),16+1 )) = 1 then add_months(to_date(disburse_time),16+1 ) + interval '1' day else add_months(to_date(disburse_time),16+1 ) end,15) as mob17_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),17+1 )) = 7 then add_months(to_date(disburse_time),17+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),17+1 )) = 1 then add_months(to_date(disburse_time),17+1 ) + interval '1' day else add_months(to_date(disburse_time),17+1 ) end,15) as mob18_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),18+1 )) = 7 then add_months(to_date(disburse_time),18+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),18+1 )) = 1 then add_months(to_date(disburse_time),18+1 ) + interval '1' day else add_months(to_date(disburse_time),18+1 ) end,15) as mob19_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),19+1 )) = 7 then add_months(to_date(disburse_time),19+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),19+1 )) = 1 then add_months(to_date(disburse_time),19+1 ) + interval '1' day else add_months(to_date(disburse_time),19+1 ) end,15) as mob20_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),20+1 )) = 7 then add_months(to_date(disburse_time),20+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),20+1 )) = 1 then add_months(to_date(disburse_time),20+1 ) + interval '1' day else add_months(to_date(disburse_time),20+1 ) end,15) as mob21_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),21+1 )) = 7 then add_months(to_date(disburse_time),21+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),21+1 )) = 1 then add_months(to_date(disburse_time),21+1 ) + interval '1' day else add_months(to_date(disburse_time),21+1 ) end,15) as mob22_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),22+1 )) = 7 then add_months(to_date(disburse_time),22+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),22+1 )) = 1 then add_months(to_date(disburse_time),22+1 ) + interval '1' day else add_months(to_date(disburse_time),22+1 ) end,15) as mob23_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),23+1 )) = 7 then add_months(to_date(disburse_time),23+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),23+1 )) = 1 then add_months(to_date(disburse_time),23+1 ) + interval '1' day else add_months(to_date(disburse_time),23+1 ) end,15) as mob24_date
        from risk.dws_risk_${product}_${region}_loan_repayment_zi a
        where loan_disbursed_month>=from_unixtime(unix_timestamp(add_months('${grass_date}',-24), 'yyyy-MM-dd'), 'yyyyMM')
        and if(trunc('${grass_date}','MM')>=trunc(first_instalment_due_time,'MM'),floor(months_between(trunc('${grass_date}','MM'),trunc(first_instalment_due_time,'MM')))+1,0) >0 
        and if(trunc('${grass_date}','MM')>=trunc(first_instalment_due_time,'MM'),floor(months_between(trunc('${grass_date}','MM'),trunc(first_instalment_due_time,'MM')))+1,0) <=24
        and day(a.first_instalment_due_time) ${first_due_day}
        )a
    group by a.loan_id  
    ,a.loan_disbursed_month                                                                                
    ,a.due_time_day
    -- ,a.tenure
    ,a.first_instalment_due_time
    ,a.disburse_date
    ) a 
) a 
lateral view explode(split(regexp_replace(mob_info,'[{}]',''),','))tab as  sub_mob_info
where date_add(add_months(disburse_date,cast(regexp_replace(split(split(sub_mob_info,':')[0],'-')[1],'"','') as int)-1+1),14+1) <='${grass_date}'
;



-- m1_outstanding_by_tenure
create or replace temporary view m1_outstanding_by_tenure_${product}_${region} as
select
    loan_id  
    ,loan_disbursed_month as loan_disbursed_month
    ,due_time_day        as due_time_day
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
    ,a.disburse_date
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
        a.loan_id  
        ,a.loan_disbursed_month                                                                                
        ,a.due_time_day
        ,max(a.new_repeat_user) as new_repeat_user
        ,min(a.tenure) as tenure
        ,a.first_instalment_due_time
        ,a.disburse_date
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob1_date , if(end_date='9999-12-31','${grass_date}',end_date))>30 and mob1_date >=start_date and mob1_date <=end_date  and mob1_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob1_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob2_date , if(end_date='9999-12-31','${grass_date}',end_date))>30 and mob2_date >=start_date and mob2_date <=end_date  and mob2_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob2_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob3_date , if(end_date='9999-12-31','${grass_date}',end_date))>30 and mob3_date >=start_date and mob3_date <=end_date  and mob3_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob3_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob4_date , if(end_date='9999-12-31','${grass_date}',end_date))>30 and mob4_date >=start_date and mob4_date <=end_date  and mob4_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob4_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob5_date , if(end_date='9999-12-31','${grass_date}',end_date))>30 and mob5_date >=start_date and mob5_date <=end_date  and mob5_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob5_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob6_date , if(end_date='9999-12-31','${grass_date}',end_date))>30 and mob6_date >=start_date and mob6_date <=end_date  and mob6_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob6_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob7_date , if(end_date='9999-12-31','${grass_date}',end_date))>30 and mob7_date >=start_date and mob7_date <=end_date  and mob7_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob7_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob8_date , if(end_date='9999-12-31','${grass_date}',end_date))>30 and mob8_date >=start_date and mob8_date <=end_date  and mob8_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob8_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob9_date , if(end_date='9999-12-31','${grass_date}',end_date))>30 and mob9_date >=start_date and mob9_date <=end_date  and mob9_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob9_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob10_date, if(end_date='9999-12-31','${grass_date}',end_date))>30 and mob10_date>=start_date and mob10_date<=end_date  and mob10_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob10_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob11_date, if(end_date='9999-12-31','${grass_date}',end_date))>30 and mob11_date>=start_date and mob11_date<=end_date  and mob11_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob11_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob12_date, if(end_date='9999-12-31','${grass_date}',end_date))>30 and mob12_date>=start_date and mob12_date<=end_date  and mob12_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob12_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob13_date, if(end_date='9999-12-31','${grass_date}',end_date))>30 and mob13_date>=start_date and mob13_date<=end_date  and mob13_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob13_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob14_date, if(end_date='9999-12-31','${grass_date}',end_date))>30 and mob14_date>=start_date and mob14_date<=end_date  and mob14_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob14_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob15_date, if(end_date='9999-12-31','${grass_date}',end_date))>30 and mob15_date>=start_date and mob15_date<=end_date  and mob15_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob15_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob16_date, if(end_date='9999-12-31','${grass_date}',end_date))>30 and mob16_date>=start_date and mob16_date<=end_date  and mob16_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob16_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob17_date, if(end_date='9999-12-31','${grass_date}',end_date))>30 and mob17_date>=start_date and mob17_date<=end_date  and mob17_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob17_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob18_date, if(end_date='9999-12-31','${grass_date}',end_date))>30 and mob18_date>=start_date and mob18_date<=end_date  and mob18_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob18_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob19_date, if(end_date='9999-12-31','${grass_date}',end_date))>30 and mob19_date>=start_date and mob19_date<=end_date  and mob19_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob19_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob20_date, if(end_date='9999-12-31','${grass_date}',end_date))>30 and mob20_date>=start_date and mob20_date<=end_date  and mob20_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob20_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob21_date, if(end_date='9999-12-31','${grass_date}',end_date))>30 and mob21_date>=start_date and mob21_date<=end_date  and mob21_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob21_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob22_date, if(end_date='9999-12-31','${grass_date}',end_date))>30 and mob22_date>=start_date and mob22_date<=end_date  and mob22_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob22_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob23_date, if(end_date='9999-12-31','${grass_date}',end_date))>30 and mob23_date>=start_date and mob23_date<=end_date  and mob23_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob23_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob24_date, if(end_date='9999-12-31','${grass_date}',end_date))>30 and mob24_date>=start_date and mob24_date<=end_date  and mob24_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-30) then principal_os else 0 end)  m1_mob24_principal_os
    from ( 
        select 
            a.loan_id  
            ,case when a.simple_disburse_month is null and a.first_instalment_due_time is not null 
                then add_months(a.first_instalment_due_time,-1) 
                else a.simple_disburse_month end                                                                                     as loan_disbursed_month
            ,day(a.first_instalment_due_time)                                                                                       as due_time_day
            ,new_repeat_user                                                                                                        as new_repeat_user
            ,a.first_instalment_due_time
            ,case when a.loan_tenure < 10 then concat('0', cast(a.loan_tenure as string)) else cast(a.loan_tenure as string) end    as tenure
            ,clear_status
            ,dpd_eod
            ,start_date
            ,end_date
            ,principal_os
            ,to_date(a.disburse_time)   as disburse_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),-1+1 )) = 7 then add_months(to_date(disburse_time),-1+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),-1+1 )) = 1 then add_months(to_date(disburse_time),-1+1 ) + interval '1' day else add_months(to_date(disburse_time),-1+1 ) end,30) as mob1_date 
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),0 +1 )) = 7 then add_months(to_date(disburse_time),0 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),0 +1 )) = 1 then add_months(to_date(disburse_time),0 +1 ) + interval '1' day else add_months(to_date(disburse_time),0 +1 ) end,30)  as mob2_date 
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),1 +1 )) = 7 then add_months(to_date(disburse_time),1 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),1 +1 )) = 1 then add_months(to_date(disburse_time),1 +1 ) + interval '1' day else add_months(to_date(disburse_time),1 +1 ) end,30)  as mob3_date 
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),2 +1 )) = 7 then add_months(to_date(disburse_time),2 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),2 +1 )) = 1 then add_months(to_date(disburse_time),2 +1 ) + interval '1' day else add_months(to_date(disburse_time),2 +1 ) end,30)  as mob4_date 
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),3 +1 )) = 7 then add_months(to_date(disburse_time),3 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),3 +1 )) = 1 then add_months(to_date(disburse_time),3 +1 ) + interval '1' day else add_months(to_date(disburse_time),3 +1 ) end,30)  as mob5_date 
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),4 +1 )) = 7 then add_months(to_date(disburse_time),4 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),4 +1 )) = 1 then add_months(to_date(disburse_time),4 +1 ) + interval '1' day else add_months(to_date(disburse_time),4 +1 ) end,30)  as mob6_date 
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),5 +1 )) = 7 then add_months(to_date(disburse_time),5 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),5 +1 )) = 1 then add_months(to_date(disburse_time),5 +1 ) + interval '1' day else add_months(to_date(disburse_time),5 +1 ) end,30)  as mob7_date 
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),6 +1 )) = 7 then add_months(to_date(disburse_time),6 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),6 +1 )) = 1 then add_months(to_date(disburse_time),6 +1 ) + interval '1' day else add_months(to_date(disburse_time),6 +1 ) end,30)  as mob8_date 
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),7 +1 )) = 7 then add_months(to_date(disburse_time),7 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),7 +1 )) = 1 then add_months(to_date(disburse_time),7 +1 ) + interval '1' day else add_months(to_date(disburse_time),7 +1 ) end,30)  as mob9_date 
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),8 +1 )) = 7 then add_months(to_date(disburse_time),8 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),8 +1 )) = 1 then add_months(to_date(disburse_time),8 +1 ) + interval '1' day else add_months(to_date(disburse_time),8 +1 ) end,30)  as mob10_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),9 +1 )) = 7 then add_months(to_date(disburse_time),9 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),9 +1 )) = 1 then add_months(to_date(disburse_time),9 +1 ) + interval '1' day else add_months(to_date(disburse_time),9 +1 ) end,30)  as mob11_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),10+1 )) = 7 then add_months(to_date(disburse_time),10+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),10+1 )) = 1 then add_months(to_date(disburse_time),10+1 ) + interval '1' day else add_months(to_date(disburse_time),10+1 ) end,30) as mob12_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),11+1 )) = 7 then add_months(to_date(disburse_time),11+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),11+1 )) = 1 then add_months(to_date(disburse_time),11+1 ) + interval '1' day else add_months(to_date(disburse_time),11+1 ) end,30) as mob13_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),12+1 )) = 7 then add_months(to_date(disburse_time),12+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),12+1 )) = 1 then add_months(to_date(disburse_time),12+1 ) + interval '1' day else add_months(to_date(disburse_time),12+1 ) end,30) as mob14_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),13+1 )) = 7 then add_months(to_date(disburse_time),13+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),13+1 )) = 1 then add_months(to_date(disburse_time),13+1 ) + interval '1' day else add_months(to_date(disburse_time),13+1 ) end,30) as mob15_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),14+1 )) = 7 then add_months(to_date(disburse_time),14+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),14+1 )) = 1 then add_months(to_date(disburse_time),14+1 ) + interval '1' day else add_months(to_date(disburse_time),14+1 ) end,30) as mob16_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),15+1 )) = 7 then add_months(to_date(disburse_time),15+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),15+1 )) = 1 then add_months(to_date(disburse_time),15+1 ) + interval '1' day else add_months(to_date(disburse_time),15+1 ) end,30) as mob17_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),16+1 )) = 7 then add_months(to_date(disburse_time),16+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),16+1 )) = 1 then add_months(to_date(disburse_time),16+1 ) + interval '1' day else add_months(to_date(disburse_time),16+1 ) end,30) as mob18_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),17+1 )) = 7 then add_months(to_date(disburse_time),17+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),17+1 )) = 1 then add_months(to_date(disburse_time),17+1 ) + interval '1' day else add_months(to_date(disburse_time),17+1 ) end,30) as mob19_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),18+1 )) = 7 then add_months(to_date(disburse_time),18+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),18+1 )) = 1 then add_months(to_date(disburse_time),18+1 ) + interval '1' day else add_months(to_date(disburse_time),18+1 ) end,30) as mob20_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),19+1 )) = 7 then add_months(to_date(disburse_time),19+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),19+1 )) = 1 then add_months(to_date(disburse_time),19+1 ) + interval '1' day else add_months(to_date(disburse_time),19+1 ) end,30) as mob21_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),20+1 )) = 7 then add_months(to_date(disburse_time),20+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),20+1 )) = 1 then add_months(to_date(disburse_time),20+1 ) + interval '1' day else add_months(to_date(disburse_time),20+1 ) end,30) as mob22_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),21+1 )) = 7 then add_months(to_date(disburse_time),21+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),21+1 )) = 1 then add_months(to_date(disburse_time),21+1 ) + interval '1' day else add_months(to_date(disburse_time),21+1 ) end,30) as mob23_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),22+1 )) = 7 then add_months(to_date(disburse_time),22+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),22+1 )) = 1 then add_months(to_date(disburse_time),22+1 ) + interval '1' day else add_months(to_date(disburse_time),22+1 ) end,30) as mob24_date
        from risk.dws_risk_${product}_${region}_loan_repayment_zi a
        where loan_disbursed_month>=from_unixtime(unix_timestamp(add_months('${grass_date}',-24), 'yyyy-MM-dd'), 'yyyyMM')
        and if(trunc('${grass_date}','MM')>=trunc(first_instalment_due_time,'MM'),floor(months_between(trunc('${grass_date}','MM'),trunc(first_instalment_due_time,'MM')))+1,0) >0 
        and if(trunc('${grass_date}','MM')>=trunc(first_instalment_due_time,'MM'),floor(months_between(trunc('${grass_date}','MM'),trunc(first_instalment_due_time,'MM')))+1,0) <=24
        and day(a.first_instalment_due_time) ${first_due_day}
        )a
    group by a.loan_id  
    ,a.loan_disbursed_month                                                                                
    ,a.due_time_day
    -- ,a.tenure
    ,a.first_instalment_due_time
    ,a.disburse_date
    -- ,case when a.loan_tenure < 10 then concat('0', cast(a.loan_tenure as string)) else cast(a.loan_tenure as string) end
    ) a 
) a 
lateral view explode(split(regexp_replace(mob_info,'[{}]',''),','))tab as  sub_mob_info
where date_add(add_months(disburse_date,cast(regexp_replace(split(split(sub_mob_info,':')[0],'-')[1],'"','') as int)-2+1),30) <='${grass_date}'
;



-- m2_outstanding_by_tenure
create or replace temporary view m2_outstanding_by_tenure_${product}_${region} as
select
     loan_id  
    ,loan_disbursed_month as loan_disbursed_month
    ,due_time_day        as due_time_day
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
    ,a.disburse_date
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
        a.loan_id  
        ,a.loan_disbursed_month                                                                                
        ,a.due_time_day
        ,max(a.new_repeat_user) as new_repeat_user
        ,min(a.tenure) as tenure
        ,a.first_instalment_due_time
        ,a.disburse_date
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob1_date , if(end_date='9999-12-31','${grass_date}',end_date))>60 and mob1_date >=start_date and mob1_date <=end_date  and mob1_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob1_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob2_date , if(end_date='9999-12-31','${grass_date}',end_date))>60 and mob2_date >=start_date and mob2_date <=end_date  and mob2_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob2_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob3_date , if(end_date='9999-12-31','${grass_date}',end_date))>60 and mob3_date >=start_date and mob3_date <=end_date  and mob3_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob3_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob4_date , if(end_date='9999-12-31','${grass_date}',end_date))>60 and mob4_date >=start_date and mob4_date <=end_date  and mob4_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob4_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob5_date , if(end_date='9999-12-31','${grass_date}',end_date))>60 and mob5_date >=start_date and mob5_date <=end_date  and mob5_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob5_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob6_date , if(end_date='9999-12-31','${grass_date}',end_date))>60 and mob6_date >=start_date and mob6_date <=end_date  and mob6_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob6_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob7_date , if(end_date='9999-12-31','${grass_date}',end_date))>60 and mob7_date >=start_date and mob7_date <=end_date  and mob7_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob7_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob8_date , if(end_date='9999-12-31','${grass_date}',end_date))>60 and mob8_date >=start_date and mob8_date <=end_date  and mob8_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob8_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob9_date , if(end_date='9999-12-31','${grass_date}',end_date))>60 and mob9_date >=start_date and mob9_date <=end_date  and mob9_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob9_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob10_date, if(end_date='9999-12-31','${grass_date}',end_date))>60 and mob10_date>=start_date and mob10_date<=end_date  and mob10_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob10_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob11_date, if(end_date='9999-12-31','${grass_date}',end_date))>60 and mob11_date>=start_date and mob11_date<=end_date  and mob11_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob11_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob12_date, if(end_date='9999-12-31','${grass_date}',end_date))>60 and mob12_date>=start_date and mob12_date<=end_date  and mob12_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob12_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob13_date, if(end_date='9999-12-31','${grass_date}',end_date))>60 and mob13_date>=start_date and mob13_date<=end_date  and mob13_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob13_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob14_date, if(end_date='9999-12-31','${grass_date}',end_date))>60 and mob14_date>=start_date and mob14_date<=end_date  and mob14_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob14_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob15_date, if(end_date='9999-12-31','${grass_date}',end_date))>60 and mob15_date>=start_date and mob15_date<=end_date  and mob15_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob15_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob16_date, if(end_date='9999-12-31','${grass_date}',end_date))>60 and mob16_date>=start_date and mob16_date<=end_date  and mob16_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob16_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob17_date, if(end_date='9999-12-31','${grass_date}',end_date))>60 and mob17_date>=start_date and mob17_date<=end_date  and mob17_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob17_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob18_date, if(end_date='9999-12-31','${grass_date}',end_date))>60 and mob18_date>=start_date and mob18_date<=end_date  and mob18_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob18_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob19_date, if(end_date='9999-12-31','${grass_date}',end_date))>60 and mob19_date>=start_date and mob19_date<=end_date  and mob19_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob19_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob20_date, if(end_date='9999-12-31','${grass_date}',end_date))>60 and mob20_date>=start_date and mob20_date<=end_date  and mob20_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob20_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob21_date, if(end_date='9999-12-31','${grass_date}',end_date))>60 and mob21_date>=start_date and mob21_date<=end_date  and mob21_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob21_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob22_date, if(end_date='9999-12-31','${grass_date}',end_date))>60 and mob22_date>=start_date and mob22_date<=end_date  and mob22_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob22_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob23_date, if(end_date='9999-12-31','${grass_date}',end_date))>60 and mob23_date>=start_date and mob23_date<=end_date  and mob23_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob23_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob24_date, if(end_date='9999-12-31','${grass_date}',end_date))>60 and mob24_date>=start_date and mob24_date<=end_date  and mob24_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-60) then principal_os else 0 end)  m2_mob24_principal_os
    from ( 
        select 
            a.loan_id  
            ,case when a.simple_disburse_month is null and a.first_instalment_due_time is not null 
                then add_months(a.first_instalment_due_time,-1) 
                else a.simple_disburse_month end                                                                                     as loan_disbursed_month
            ,day(a.first_instalment_due_time)                                                                                       as due_time_day
            ,new_repeat_user                                                                                                        as new_repeat_user
            ,a.first_instalment_due_time
            ,case when a.loan_tenure < 10 then concat('0', cast(a.loan_tenure as string)) else cast(a.loan_tenure as string) end    as tenure
            ,clear_status
            ,dpd_eod
            ,start_date
            ,end_date
            ,principal_os
            ,to_date(a.disburse_time)   as disburse_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),-2+1 )) = 7 then add_months(to_date(disburse_time),-2+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),-2+1 )) = 1 then add_months(to_date(disburse_time),-2+1 ) + interval '1' day else add_months(to_date(disburse_time),-2+1 ) end,60) as mob1_date 
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),-1+1 )) = 7 then add_months(to_date(disburse_time),-1+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),-1+1 )) = 1 then add_months(to_date(disburse_time),-1+1 ) + interval '1' day else add_months(to_date(disburse_time),-1+1 ) end,60) as mob2_date 
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),0 +1 )) = 7 then add_months(to_date(disburse_time),0 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),0 +1 )) = 1 then add_months(to_date(disburse_time),0 +1 ) + interval '1' day else add_months(to_date(disburse_time),0 +1 ) end ,60)  as mob3_date 
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),1 +1 )) = 7 then add_months(to_date(disburse_time),1 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),1 +1 )) = 1 then add_months(to_date(disburse_time),1 +1 ) + interval '1' day else add_months(to_date(disburse_time),1 +1 ) end ,60)  as mob4_date 
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),2 +1 )) = 7 then add_months(to_date(disburse_time),2 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),2 +1 )) = 1 then add_months(to_date(disburse_time),2 +1 ) + interval '1' day else add_months(to_date(disburse_time),2 +1 ) end ,60)  as mob5_date 
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),3 +1 )) = 7 then add_months(to_date(disburse_time),3 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),3 +1 )) = 1 then add_months(to_date(disburse_time),3 +1 ) + interval '1' day else add_months(to_date(disburse_time),3 +1 ) end ,60)  as mob6_date 
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),4 +1 )) = 7 then add_months(to_date(disburse_time),4 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),4 +1 )) = 1 then add_months(to_date(disburse_time),4 +1 ) + interval '1' day else add_months(to_date(disburse_time),4 +1 ) end ,60)  as mob7_date 
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),5 +1 )) = 7 then add_months(to_date(disburse_time),5 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),5 +1 )) = 1 then add_months(to_date(disburse_time),5 +1 ) + interval '1' day else add_months(to_date(disburse_time),5 +1 ) end ,60)  as mob8_date 
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),6 +1 )) = 7 then add_months(to_date(disburse_time),6 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),6 +1 )) = 1 then add_months(to_date(disburse_time),6 +1 ) + interval '1' day else add_months(to_date(disburse_time),6 +1 ) end ,60)  as mob9_date 
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),7 +1 )) = 7 then add_months(to_date(disburse_time),7 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),7 +1 )) = 1 then add_months(to_date(disburse_time),7 +1 ) + interval '1' day else add_months(to_date(disburse_time),7 +1 ) end ,60)  as mob10_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),8 +1 )) = 7 then add_months(to_date(disburse_time),8 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),8 +1 )) = 1 then add_months(to_date(disburse_time),8 +1 ) + interval '1' day else add_months(to_date(disburse_time),8 +1 ) end ,60)  as mob11_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),9 +1 )) = 7 then add_months(to_date(disburse_time),9 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),9 +1 )) = 1 then add_months(to_date(disburse_time),9 +1 ) + interval '1' day else add_months(to_date(disburse_time),9 +1 ) end ,60)  as mob12_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),10+1 )) = 7 then add_months(to_date(disburse_time),10+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),10+1 )) = 1 then add_months(to_date(disburse_time),10+1 ) + interval '1' day else add_months(to_date(disburse_time),10+1 ) end,60) as mob13_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),11+1 )) = 7 then add_months(to_date(disburse_time),11+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),11+1 )) = 1 then add_months(to_date(disburse_time),11+1 ) + interval '1' day else add_months(to_date(disburse_time),11+1 ) end,60) as mob14_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),12+1 )) = 7 then add_months(to_date(disburse_time),12+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),12+1 )) = 1 then add_months(to_date(disburse_time),12+1 ) + interval '1' day else add_months(to_date(disburse_time),12+1 ) end,60) as mob15_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),13+1 )) = 7 then add_months(to_date(disburse_time),13+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),13+1 )) = 1 then add_months(to_date(disburse_time),13+1 ) + interval '1' day else add_months(to_date(disburse_time),13+1 ) end,60) as mob16_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),14+1 )) = 7 then add_months(to_date(disburse_time),14+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),14+1 )) = 1 then add_months(to_date(disburse_time),14+1 ) + interval '1' day else add_months(to_date(disburse_time),14+1 ) end,60) as mob17_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),15+1 )) = 7 then add_months(to_date(disburse_time),15+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),15+1 )) = 1 then add_months(to_date(disburse_time),15+1 ) + interval '1' day else add_months(to_date(disburse_time),15+1 ) end,60) as mob18_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),16+1 )) = 7 then add_months(to_date(disburse_time),16+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),16+1 )) = 1 then add_months(to_date(disburse_time),16+1 ) + interval '1' day else add_months(to_date(disburse_time),16+1 ) end,60) as mob19_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),17+1 )) = 7 then add_months(to_date(disburse_time),17+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),17+1 )) = 1 then add_months(to_date(disburse_time),17+1 ) + interval '1' day else add_months(to_date(disburse_time),17+1 ) end,60) as mob20_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),18+1 )) = 7 then add_months(to_date(disburse_time),18+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),18+1 )) = 1 then add_months(to_date(disburse_time),18+1 ) + interval '1' day else add_months(to_date(disburse_time),18+1 ) end,60) as mob21_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),19+1 )) = 7 then add_months(to_date(disburse_time),19+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),19+1 )) = 1 then add_months(to_date(disburse_time),19+1 ) + interval '1' day else add_months(to_date(disburse_time),19+1 ) end,60) as mob22_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),20+1 )) = 7 then add_months(to_date(disburse_time),20+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),20+1 )) = 1 then add_months(to_date(disburse_time),20+1 ) + interval '1' day else add_months(to_date(disburse_time),20+1 ) end,60) as mob23_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),21+1 )) = 7 then add_months(to_date(disburse_time),21+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),21+1 )) = 1 then add_months(to_date(disburse_time),21+1 ) + interval '1' day else add_months(to_date(disburse_time),21+1 ) end,60) as mob24_date
        from risk.dws_risk_${product}_${region}_loan_repayment_zi a
        where loan_disbursed_month>=from_unixtime(unix_timestamp(add_months('${grass_date}',-24), 'yyyy-MM-dd'), 'yyyyMM')
        and if(trunc('${grass_date}','MM')>=trunc(first_instalment_due_time,'MM'),floor(months_between(trunc('${grass_date}','MM'),trunc(first_instalment_due_time,'MM')))+1,0) >0 
        and if(trunc('${grass_date}','MM')>=trunc(first_instalment_due_time,'MM'),floor(months_between(trunc('${grass_date}','MM'),trunc(first_instalment_due_time,'MM')))+1,0) <=24
        and day(a.first_instalment_due_time) ${first_due_day}
        )a
    group by a.loan_id  
    ,a.loan_disbursed_month                                                                                
    ,a.due_time_day
    -- ,a.tenure
    ,a.first_instalment_due_time
    ,a.disburse_date
    -- ,case when a.loan_tenure < 10 then concat('0', cast(a.loan_tenure as string)) else cast(a.loan_tenure as string) end
    ) a 
) a 
lateral view explode(split(regexp_replace(mob_info,'[{}]',''),','))tab as  sub_mob_info
where date_add(add_months(to_date(a.disburse_date),cast(regexp_replace(split(split(sub_mob_info,':')[0],'-')[1],'"','') as int)-3+1),60) <='${grass_date}'
;

-- m3_outstanding_by_tenure
create or replace temporary view m3_outstanding_by_tenure_${product}_${region} as
select
     loan_id  
    ,loan_disbursed_month as loan_disbursed_month
    ,due_time_day        as due_time_day
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
    ,a.disburse_date
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
        a.loan_id  
        ,a.loan_disbursed_month                                                                                
        ,a.due_time_day
        ,max(a.new_repeat_user) as new_repeat_user
        ,min(a.tenure) as tenure
        ,a.first_instalment_due_time
        ,a.disburse_date
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob1_date , if(end_date='9999-12-31','${grass_date}',end_date))>90 and mob1_date >=start_date and mob1_date <=end_date  and mob1_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob1_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob2_date , if(end_date='9999-12-31','${grass_date}',end_date))>90 and mob2_date >=start_date and mob2_date <=end_date  and mob2_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob2_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob3_date , if(end_date='9999-12-31','${grass_date}',end_date))>90 and mob3_date >=start_date and mob3_date <=end_date  and mob3_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob3_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob4_date , if(end_date='9999-12-31','${grass_date}',end_date))>90 and mob4_date >=start_date and mob4_date <=end_date  and mob4_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob4_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob5_date , if(end_date='9999-12-31','${grass_date}',end_date))>90 and mob5_date >=start_date and mob5_date <=end_date  and mob5_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob5_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob6_date , if(end_date='9999-12-31','${grass_date}',end_date))>90 and mob6_date >=start_date and mob6_date <=end_date  and mob6_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob6_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob7_date , if(end_date='9999-12-31','${grass_date}',end_date))>90 and mob7_date >=start_date and mob7_date <=end_date  and mob7_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob7_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob8_date , if(end_date='9999-12-31','${grass_date}',end_date))>90 and mob8_date >=start_date and mob8_date <=end_date  and mob8_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob8_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob9_date , if(end_date='9999-12-31','${grass_date}',end_date))>90 and mob9_date >=start_date and mob9_date <=end_date  and mob9_date >=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob9_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob10_date, if(end_date='9999-12-31','${grass_date}',end_date))>90 and mob10_date>=start_date and mob10_date<=end_date  and mob10_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob10_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob11_date, if(end_date='9999-12-31','${grass_date}',end_date))>90 and mob11_date>=start_date and mob11_date<=end_date  and mob11_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob11_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob12_date, if(end_date='9999-12-31','${grass_date}',end_date))>90 and mob12_date>=start_date and mob12_date<=end_date  and mob12_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob12_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob13_date, if(end_date='9999-12-31','${grass_date}',end_date))>90 and mob13_date>=start_date and mob13_date<=end_date  and mob13_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob13_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob14_date, if(end_date='9999-12-31','${grass_date}',end_date))>90 and mob14_date>=start_date and mob14_date<=end_date  and mob14_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob14_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob15_date, if(end_date='9999-12-31','${grass_date}',end_date))>90 and mob15_date>=start_date and mob15_date<=end_date  and mob15_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob15_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob16_date, if(end_date='9999-12-31','${grass_date}',end_date))>90 and mob16_date>=start_date and mob16_date<=end_date  and mob16_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob16_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob17_date, if(end_date='9999-12-31','${grass_date}',end_date))>90 and mob17_date>=start_date and mob17_date<=end_date  and mob17_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob17_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob18_date, if(end_date='9999-12-31','${grass_date}',end_date))>90 and mob18_date>=start_date and mob18_date<=end_date  and mob18_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob18_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob19_date, if(end_date='9999-12-31','${grass_date}',end_date))>90 and mob19_date>=start_date and mob19_date<=end_date  and mob19_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob19_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob20_date, if(end_date='9999-12-31','${grass_date}',end_date))>90 and mob20_date>=start_date and mob20_date<=end_date  and mob20_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob20_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob21_date, if(end_date='9999-12-31','${grass_date}',end_date))>90 and mob21_date>=start_date and mob21_date<=end_date  and mob21_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob21_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob22_date, if(end_date='9999-12-31','${grass_date}',end_date))>90 and mob22_date>=start_date and mob22_date<=end_date  and mob22_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob22_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob23_date, if(end_date='9999-12-31','${grass_date}',end_date))>90 and mob23_date>=start_date and mob23_date<=end_date  and mob23_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob23_principal_os
        ,sum(case when clear_status<>3 and dpd_eod + DATEDIFF(mob24_date, if(end_date='9999-12-31','${grass_date}',end_date))>90 and mob24_date>=start_date and mob24_date<=end_date  and mob24_date>=date_sub(if(end_date='9999-12-31','${grass_date}',end_date),cast(dpd_eod as int)-90) then principal_os else 0 end)  m3_mob24_principal_os
    from ( 
        select 
            a.loan_id  
            ,case when a.simple_disburse_month is null and a.first_instalment_due_time is not null 
                then add_months(a.first_instalment_due_time,-1) 
                else a.simple_disburse_month end                                                                                     as loan_disbursed_month
            ,day(a.first_instalment_due_time)                                                                                       as due_time_day
            ,new_repeat_user                                                                                                        as new_repeat_user
            ,a.first_instalment_due_time
            ,case when a.loan_tenure < 10 then concat('0', cast(a.loan_tenure as string)) else cast(a.loan_tenure as string) end    as tenure
            ,clear_status
            ,dpd_eod
            ,start_date
            ,end_date
            ,principal_os
            ,to_date(a.disburse_time)   as disburse_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),-3+1 )) = 7 then add_months(to_date(disburse_time),-3+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),-3+1 )) = 1 then add_months(to_date(disburse_time),-3+1 ) + interval '1' day else add_months(to_date(disburse_time),-3+1 ) end ,90) as mob1_date 
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),-2+1 )) = 7 then add_months(to_date(disburse_time),-2+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),-2+1 )) = 1 then add_months(to_date(disburse_time),-2+1 ) + interval '1' day else add_months(to_date(disburse_time),-2+1 ) end ,90) as mob2_date 
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),-1+1 )) = 7 then add_months(to_date(disburse_time),-1+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),-1+1 )) = 1 then add_months(to_date(disburse_time),-1+1 ) + interval '1' day else add_months(to_date(disburse_time),-1+1 ) end ,90) as mob3_date 
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),0 +1 )) = 7 then add_months(to_date(disburse_time),0 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),0 +1 )) = 1 then add_months(to_date(disburse_time),0 +1 ) + interval '1' day else add_months(to_date(disburse_time),0 +1 ) end ,90)  as mob4_date 
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),1 +1 )) = 7 then add_months(to_date(disburse_time),1 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),1 +1 )) = 1 then add_months(to_date(disburse_time),1 +1 ) + interval '1' day else add_months(to_date(disburse_time),1 +1 ) end ,90)  as mob5_date 
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),2 +1 )) = 7 then add_months(to_date(disburse_time),2 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),2 +1 )) = 1 then add_months(to_date(disburse_time),2 +1 ) + interval '1' day else add_months(to_date(disburse_time),2 +1 ) end ,90)  as mob6_date 
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),3 +1 )) = 7 then add_months(to_date(disburse_time),3 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),3 +1 )) = 1 then add_months(to_date(disburse_time),3 +1 ) + interval '1' day else add_months(to_date(disburse_time),3 +1 ) end ,90)  as mob7_date 
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),4 +1 )) = 7 then add_months(to_date(disburse_time),4 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),4 +1 )) = 1 then add_months(to_date(disburse_time),4 +1 ) + interval '1' day else add_months(to_date(disburse_time),4 +1 ) end ,90)  as mob8_date 
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),5 +1 )) = 7 then add_months(to_date(disburse_time),5 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),5 +1 )) = 1 then add_months(to_date(disburse_time),5 +1 ) + interval '1' day else add_months(to_date(disburse_time),5 +1 ) end ,90)  as mob9_date 
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),6 +1 )) = 7 then add_months(to_date(disburse_time),6 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),6 +1 )) = 1 then add_months(to_date(disburse_time),6 +1 ) + interval '1' day else add_months(to_date(disburse_time),6 +1 ) end ,90)  as mob10_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),7 +1 )) = 7 then add_months(to_date(disburse_time),7 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),7 +1 )) = 1 then add_months(to_date(disburse_time),7 +1 ) + interval '1' day else add_months(to_date(disburse_time),7 +1 ) end ,90)  as mob11_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),8 +1 )) = 7 then add_months(to_date(disburse_time),8 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),8 +1 )) = 1 then add_months(to_date(disburse_time),8 +1 ) + interval '1' day else add_months(to_date(disburse_time),8 +1 ) end ,90)  as mob12_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),9 +1 )) = 7 then add_months(to_date(disburse_time),9 +1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),9 +1 )) = 1 then add_months(to_date(disburse_time),9 +1 ) + interval '1' day else add_months(to_date(disburse_time),9 +1 ) end ,90)  as mob13_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),10+1 )) = 7 then add_months(to_date(disburse_time),10+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),10+1 )) = 1 then add_months(to_date(disburse_time),10+1 ) + interval '1' day else add_months(to_date(disburse_time),10+1 ) end ,90) as mob14_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),11+1 )) = 7 then add_months(to_date(disburse_time),11+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),11+1 )) = 1 then add_months(to_date(disburse_time),11+1 ) + interval '1' day else add_months(to_date(disburse_time),11+1 ) end ,90) as mob15_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),12+1 )) = 7 then add_months(to_date(disburse_time),12+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),12+1 )) = 1 then add_months(to_date(disburse_time),12+1 ) + interval '1' day else add_months(to_date(disburse_time),12+1 ) end ,90) as mob16_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),13+1 )) = 7 then add_months(to_date(disburse_time),13+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),13+1 )) = 1 then add_months(to_date(disburse_time),13+1 ) + interval '1' day else add_months(to_date(disburse_time),13+1 ) end ,90) as mob17_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),14+1 )) = 7 then add_months(to_date(disburse_time),14+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),14+1 )) = 1 then add_months(to_date(disburse_time),14+1 ) + interval '1' day else add_months(to_date(disburse_time),14+1 ) end ,90) as mob18_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),15+1 )) = 7 then add_months(to_date(disburse_time),15+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),15+1 )) = 1 then add_months(to_date(disburse_time),15+1 ) + interval '1' day else add_months(to_date(disburse_time),15+1 ) end ,90) as mob19_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),16+1 )) = 7 then add_months(to_date(disburse_time),16+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),16+1 )) = 1 then add_months(to_date(disburse_time),16+1 ) + interval '1' day else add_months(to_date(disburse_time),16+1 ) end ,90) as mob20_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),17+1 )) = 7 then add_months(to_date(disburse_time),17+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),17+1 )) = 1 then add_months(to_date(disburse_time),17+1 ) + interval '1' day else add_months(to_date(disburse_time),17+1 ) end ,90) as mob21_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),18+1 )) = 7 then add_months(to_date(disburse_time),18+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),18+1 )) = 1 then add_months(to_date(disburse_time),18+1 ) + interval '1' day else add_months(to_date(disburse_time),18+1 ) end ,90) as mob22_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),19+1 )) = 7 then add_months(to_date(disburse_time),19+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),19+1 )) = 1 then add_months(to_date(disburse_time),19+1 ) + interval '1' day else add_months(to_date(disburse_time),19+1 ) end ,90) as mob23_date
            ,date_add(case when dayofweek(add_months(to_date(disburse_time),20+1 )) = 7 then add_months(to_date(disburse_time),20+1 ) + interval '2' day when dayofweek(add_months(to_date(disburse_time),20+1 )) = 1 then add_months(to_date(disburse_time),20+1 ) + interval '1' day else add_months(to_date(disburse_time),20+1 ) end ,90) as mob24_date
        from risk.dws_risk_${product}_${region}_loan_repayment_zi a
        where loan_disbursed_month>=from_unixtime(unix_timestamp(add_months('${grass_date}',-24), 'yyyy-MM-dd'), 'yyyyMM')
        and if(trunc('${grass_date}','MM')>=trunc(first_instalment_due_time,'MM'),floor(months_between(trunc('${grass_date}','MM'),trunc(first_instalment_due_time,'MM')))+1,0) >0 
        and if(trunc('${grass_date}','MM')>=trunc(first_instalment_due_time,'MM'),floor(months_between(trunc('${grass_date}','MM'),trunc(first_instalment_due_time,'MM')))+1,0) <=24
        and day(a.first_instalment_due_time) ${first_due_day}
        )a
    group by a.loan_id  
    ,a.loan_disbursed_month                                                                                
    ,a.due_time_day
    -- ,a.tenure
    ,a.first_instalment_due_time
    ,a.disburse_date
    -- ,case when a.loan_tenure < 10 then concat('0', cast(a.loan_tenure as string)) else cast(a.loan_tenure as string) end
    ) a 
) a 
lateral view explode(split(regexp_replace(mob_info,'[{}]',''),','))tab as  sub_mob_info
where date_add(add_months(to_date(a.disburse_date),cast(regexp_replace(split(split(sub_mob_info,':')[0],'-')[1],'"','') as int)-4+1),90) <='${grass_date}'
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
    ,simple_disburse_month
    ,day(a.first_instalment_due_time)                                                                                    as due_time_day
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
group by 1,2,3,4,5,6,7,8,9,10
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
-- and a.loan_disbursed_month = b.simple_disburse_month 
-- and a.due_time_day = b.due_time_day 
-- and a.new_repeat_user = b.new_repeat_user
-- and a.tenure = b.tenure
;

