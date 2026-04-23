--********************************************************************--
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2024-05-08
-- Theme Domain：       user_loan dpd
-- Description:         user_loan dpd
-- Data Granularity:    platform_user_id
-- 变更历史：
--      2024-05-08 update by zongyi.lu@shopee.com 1.新增7-12mob https://jira.shopee.io/browse/SPFDT-37236 2. 新增注释
--********************************************************************--


-- This table will calculate the exact flow rate for each user in each product.
-- Update each grass_date until we can see the performance up to mob6.

create or replace temporary view  end_of_months 
as
    SELECT 
        last_day(add_months(date('${grass_date}'), -n)) AS grass_date
    FROM (SELECT id as n from range(0, 24))
;

create or replace temporary view  tmp_unpaid_loans 
as
select  *
        ,(case  when max_dpd <= 0 THEN '0.current'
                when max_dpd <= 30 THEN '1.DPD(0,30]'
                when max_dpd <= 60 THEN '2.M1(30,60]'
                when max_dpd <= 90 THEN '3.M2(60,90]'
                when max_dpd <= 120 THEN '4.M3(90,120]'
                when max_dpd <= 150 THEN '5.M4(120,150]'
                when max_dpd <= 180 THEN '6.M5(150,180]'

                when max_dpd <= 210 THEN '7.M6(180,210]'
                when max_dpd <= 240 THEN '8.M7(210,240]'
                when max_dpd <= 270 THEN '9.M8(240,270]'
                when max_dpd <= 300 THEN '10.M9(270,300]'
                when max_dpd <= 330 THEN '11.M10(300,330]'
                when max_dpd <= 360 THEN '12.M11(330,360]'
                ELSE '13.M12(360+)'
          end) as dpd_bucket
from    (
    select  a.grass_date
            ,a.credit_user_id
            ,a.platform_user_id
            ,a.loan_id
            ,a.principal_os as total_principal
            ,MAX(a.dpd_eod) OVER(PARTITION BY a.credit_user_id, a.grass_date) AS max_dpd	--userlevel dpd
            ,last_day(date(grass_date) + interval '1' month) as mob1_date
            ,last_day(date(grass_date) + interval '2' month) as mob2_date
            ,last_day(date(grass_date) + interval '3' month) as mob3_date
            ,last_day(date(grass_date) + interval '4' month) as mob4_date
            ,last_day(date(grass_date) + interval '5' month) as mob5_date
            ,last_day(date(grass_date) + interval '6' month) as mob6_date
            ,last_day(date(grass_date) + interval '7' month) as mob7_date
            ,last_day(date(grass_date) + interval '8' month) as mob8_date
            ,last_day(date(grass_date) + interval '9' month) as mob9_date
            ,last_day(date(grass_date) + interval '10' month) as mob10_date
            ,last_day(date(grass_date) + interval '11' month) as mob11_date
            ,last_day(date(grass_date) + interval '12' month) as mob12_date
    from    credit_mart.dws_${product}_${region}_loan_repayment_df a
    where   a.grass_date in (select grass_date from end_of_months)
      and   a.principal_os > 0
)
;

create or replace temporary view  tmp_m_label 
as
select  *
        ,(case  when max_dpd <= 0 THEN '0.current'
                when max_dpd <= 30 THEN '1.DPD(0,30]'
                when max_dpd <= 60 THEN '2.M1(30,60]'
                when max_dpd <= 90 THEN '3.M2(60,90]'
                when max_dpd <= 120 THEN '4.M3(90,120]'
                when max_dpd <= 150 THEN '5.M4(120,150]'
                when max_dpd <= 180 THEN '6.M5(150,180]'
                when max_dpd <= 210 THEN '7.M6(180,210]'
                when max_dpd <= 240 THEN '8.M7(210,240]'
                when max_dpd <= 270 THEN '9.M8(240,270]'
                when max_dpd <= 300 THEN '10.M9(270,300]'
                when max_dpd <= 330 THEN '11.M10(300,330]'
                when max_dpd <= 360 THEN '12.M11(330,360]'
                ELSE '13.M12(360+)'
          end) as dpd_bucket
from    (
    select  credit_user_id
            ,grass_date
            ,loan_id
            ,principal_os as principal_os
            ,MAX(a.dpd_eod) OVER(PARTITION BY a.credit_user_id, a.grass_date) AS max_dpd	--userlevel dpd
    from    credit_mart.dws_${product}_${region}_loan_repayment_df a
    where   grass_date in (select grass_date from end_of_months)
)
;

insert overwrite table ${SCHEMA}.dws_risk_${product}_${region}_user_mob_dpd_df partition (grass_date = '${grass_date}')
select  a.platform_user_id
        ,a.credit_user_id
        ,a.dpd_bucket
        ,max(case when a.mob1_date = b.grass_date then b.dpd_bucket else null end) as mob1_dpd_bucket
        ,max(case when a.mob2_date = b.grass_date then b.dpd_bucket else null end) as mob2_dpd_bucket
        ,max(case when a.mob3_date = b.grass_date then b.dpd_bucket else null end) as mob3_dpd_bucket
        ,max(case when a.mob4_date = b.grass_date then b.dpd_bucket else null end) as mob4_dpd_bucket
        ,max(case when a.mob5_date = b.grass_date then b.dpd_bucket else null end) as mob5_dpd_bucket
        ,max(case when a.mob6_date = b.grass_date then b.dpd_bucket else null end) as mob6_dpd_bucket
        ,max(case when a.mob7_date = b.grass_date then b.dpd_bucket else null end) as mob7_dpd_bucket
        ,max(case when a.mob8_date = b.grass_date then b.dpd_bucket else null end) as mob8_dpd_bucket
        ,max(case when a.mob9_date = b.grass_date then b.dpd_bucket else null end) as mob9_dpd_bucket
        ,max(case when a.mob10_date = b.grass_date then b.dpd_bucket else null end) as mob10_dpd_bucket
        ,max(case when a.mob11_date = b.grass_date then b.dpd_bucket else null end) as mob11_dpd_bucket
        ,max(case when a.mob12_date = b.grass_date then b.dpd_bucket else null end) as mob12_dpd_bucket

        ,sum(case when a.grass_date = b.grass_date then b.principal_os else null end) as principal_os
        ,sum(case when a.mob1_date = b.grass_date then b.principal_os else null end) as mob1_principal_os
        ,sum(case when a.mob2_date = b.grass_date then b.principal_os else null end) as mob2_principal_os
        ,sum(case when a.mob3_date = b.grass_date then b.principal_os else null end) as mob3_principal_os
        ,sum(case when a.mob4_date = b.grass_date then b.principal_os else null end) as mob4_principal_os
        ,sum(case when a.mob5_date = b.grass_date then b.principal_os else null end) as mob5_principal_os
        ,sum(case when a.mob6_date = b.grass_date then b.principal_os else null end) as mob6_principal_os
        ,sum(case when a.mob7_date = b.grass_date then b.principal_os else null end) as mob7_principal_os
        ,sum(case when a.mob8_date = b.grass_date then b.principal_os else null end) as mob8_principal_os
        ,sum(case when a.mob9_date = b.grass_date then b.principal_os else null end) as mob9_principal_os
        ,sum(case when a.mob10_date = b.grass_date then b.principal_os else null end) as mob10_principal_os
        ,sum(case when a.mob11_date = b.grass_date then b.principal_os else null end) as mob11_principal_os
        ,sum(case when a.mob12_date = b.grass_date then b.principal_os else null end) as mob12_principal_os

        ,max(case when a.mob1_date = b.grass_date then b.max_dpd else null end) as mob1_dpd
        ,max(case when a.mob2_date = b.grass_date then b.max_dpd else null end) as mob2_dpd
        ,max(case when a.mob3_date = b.grass_date then b.max_dpd else null end) as mob3_dpd
        ,max(case when a.mob4_date = b.grass_date then b.max_dpd else null end) as mob4_dpd
        ,max(case when a.mob5_date = b.grass_date then b.max_dpd else null end) as mob5_dpd
        ,max(case when a.mob6_date = b.grass_date then b.max_dpd else null end) as mob6_dpd
        ,max(case when a.mob7_date = b.grass_date then b.max_dpd else null end) as mob7_dpd
        ,max(case when a.mob8_date = b.grass_date then b.max_dpd else null end) as mob8_dpd
        ,max(case when a.mob9_date = b.grass_date then b.max_dpd else null end) as mob9_dpd
        ,max(case when a.mob10_date = b.grass_date then b.max_dpd else null end) as mob10_dpd
        ,max(case when a.mob11_date = b.grass_date then b.max_dpd else null end) as mob11_dpd
        ,max(case when a.mob12_date = b.grass_date then b.max_dpd else null end) as mob12_dpd

        ,a.grass_date as mob_on_date
from    tmp_unpaid_loans a
left join tmp_m_label b
on      a.loan_id = b.loan_id
group by a.platform_user_id, a.credit_user_id, a.dpd_bucket, a.grass_date
;

