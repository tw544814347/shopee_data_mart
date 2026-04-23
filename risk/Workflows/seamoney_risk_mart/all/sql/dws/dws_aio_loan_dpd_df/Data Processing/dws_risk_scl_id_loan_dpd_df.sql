
insert overwrite table ${SCHEMA}.dws_risk_${product}_${region}_loan_dpd_df partition(grass_date)
select 
t1.loan_id                                                      as loan_id
,t1.dpd_eod                                                     as dpd_eod
,case when t2.loan_id is not null then t2.dpd_eod else null end as prev_month_dpd_eod
,t1.loan_tenure                                                 as loan_tenure
,case when t1.dpd_eod <= 0 then '01.current'
    when t1.dpd_eod <= 30 then '1.DPD(0,30]'
    when t1.dpd_eod <= 60 then '2.M1(30,60]'
    when t1.dpd_eod <= 90 then '3.M2(60,90]'
    when t1.dpd_eod <= 120 then '4.M3(90,120]'
    when t1.dpd_eod <= 150 then '5.M4(120,150]'
    when t1.dpd_eod <= 180 then '6.M5(150,180]'
    else '7.M6(180+)' end                                       as current_bucket
,case when t2.loan_id is null then '00.new disburse'
    when t2.dpd_eod <= 0 then '01.current'
    when t2.dpd_eod <= 30 then '1.DPD(0,30]'
    when t2.dpd_eod <= 60 then '2.M1(30,60]'
    when t2.dpd_eod <= 90 then '3.M2(60,90]'
    when t2.dpd_eod <= 120 then '4.M3(90,120]'
    when t2.dpd_eod <= 150 then '5.M4(120,150]'
    when t2.dpd_eod <= 180 then '6.M5(150,180]'
    else '7.M6(180+)' end                                                              as prev_month_bucket
,t1.principal_os                                                                       as current_principal_os
,case when t2.loan_id is not null then t2.principal_os else t1.principal_repayable end as prev_month_principal_os
,'${grass_date}'                                                                       as grass_date
from credit_mart.dws_${product}_${region}_loan_repayment_df t1
left join(
    select 
    loan_id 
    ,dpd_eod
    ,principal_os
    from credit_mart.dws_${product}_${region}_loan_repayment_df
    where grass_date=last_day(add_months('${grass_date}',-1))
) t2 on t1.loan_id = t2.loan_id 
where t1.grass_date='${grass_date}'
;

msck repair table ${SCHEMA}.dws_risk_${product}_${region}_loan_dpd_df;

-- alter table ${SCHEMA}.dws_risk_${product}_${region}_loan_dpd_df drop if exists partition(grass_date='${ds_t_2}');
