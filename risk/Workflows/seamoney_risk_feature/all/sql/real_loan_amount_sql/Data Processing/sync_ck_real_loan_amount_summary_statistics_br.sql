create database if not exists  clickhouse.risk_credit_promotion;

create table if not exists clickhouse.risk_credit_promotion.monitor_real_loan_amount_summary_result_br (
    `grass_region` String,
    `dt` String,
    `app_id` String,
    `scene_id` String,
    `amount_flag` String,
    `amount_total_cnt` bigint,
    `amount_null_cnt` bigint,
    `match_cnt` bigint,
    `dismatch_cnt` bigint,
    `match_ratio` double
) tblproperties (
    'url' = 'jdbc:clickhouse://10.180.128.24:80/credit_promotion',
    'user' = 'credit_promotion',
    'password' = 'credit_promotion',
    'table-name' = 'monitor_real_loan_amount_summary',
    'cluster' = 'cluster_mpp_Financial_Products_credit_promotion_online'
);

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
where dt <= '${ds}' and grass_region = 'br'
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
where dt <= '${ds}' and grass_region = 'br'
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
where dt <= '${ds}' and grass_region = 'br'
group by grass_region, dt, app_id, scene_id, order_amount_diff
;

insert into table clickhouse.risk_credit_promotion.monitor_real_loan_amount_summary_result_br
select 
    grass_region, 
    dt, 
    app_id, 
    scene_id,
    amount_flag,
    sum(cnt) as amount_total_cnt,
    sum(case when diff_val is null then cnt else 0 end) as amount_null_cnt,
    sum(case when diff_val = 0 then cnt else 0 end) as match_cnt,
    sum(case when diff_val = 1 then cnt else 0 end) as dismatch_cnt,
    cast(sum(case when diff_val = 0 then cnt else 0 end) as double) / 
        sum(cnt) as match_ratio
from simple_agg_view
group by grass_region, dt, app_id, scene_id, amount_flag
;
