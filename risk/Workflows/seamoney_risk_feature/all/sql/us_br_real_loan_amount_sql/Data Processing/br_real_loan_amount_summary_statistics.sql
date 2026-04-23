create or replace temporary view simple_agg_view as 
select 
    grass_region, 
    dt, 
    app_id, 
    scene_id, 
    'loan_amount' as amount_flag,
    loan_amount_diff as diff_val, 
    count(*) as cnt
from risk.check_real_loan_amount_history
where dt <= '${ds}'
group by grass_region, dt, app_id, scene_id, loan_amount_diff
union all 
select 
    grass_region, 
    dt, 
    app_id, 
    scene_id, 
    'combine_payment_amount' as amount_flag,
    combine_payment_amount_diff as diff_val, 
    count(*) as cnt
from risk.check_real_loan_amount_history
where dt <= '${ds}'
group by grass_region, dt, app_id, scene_id, combine_payment_amount_diff
union all 
select 
    grass_region, 
    dt, 
    app_id, 
    scene_id, 
    'order_amount' as amount_flag,
    order_amount_diff as diff_val, 
    count(*) as cnt
from risk.check_real_loan_amount_history
where dt <= '${ds}'
group by grass_region, dt, app_id, scene_id, order_amount_diff
;

insert overwrite ${SCHEMA}.monitor_real_loan_amount_summary partition(grass_region, app_id, scene_id, dt)
select
    amount_flag,
    sum(cnt) as amount_total_cnt,
    sum(case when diff_val is null then cnt else 0 end) as amount_null_cnt,
    sum(case when diff_val = 0 then cnt else 0 end) as match_cnt,
    sum(case when diff_val = 1 then cnt else 0 end) as dismatch_cnt,
    cast(sum(case when diff_val = 0 then cnt else 0 end) as double) / 
        sum(cnt) as match_ratio,
    grass_region,
    app_id, 
    scene_id,
    dt
from simple_agg_view
group by grass_region, dt, app_id, scene_id, amount_flag
;
