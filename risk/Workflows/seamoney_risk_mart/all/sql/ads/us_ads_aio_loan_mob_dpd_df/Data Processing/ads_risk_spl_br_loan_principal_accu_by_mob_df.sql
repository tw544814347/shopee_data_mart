--********************************************************************--
-- Author:              lisheng@shopee.com
-- Created Time:        2025-10-29
-- Description:         累计本金计算表（计算每个 loan_id + MOB 的累计本金，包括实际和理论值）
-- history:
-- 2025-10-29   lisheng    本表从loan_mob_dpd中拆分出来作为子表
-- 2026-01-15   lisheng    调整了计算顺序，对冗余部分剪枝，广播小表，优化计算性能
--********************************************************************--

-- DDL for loan_principal_accu_by_mob
-- DROP TABLE IF EXISTS ${SCHEMA}.ads_risk_${product}_${region}_loan_principal_accu_by_mob_df;
CREATE TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_${product}_${region}_loan_principal_accu_by_mob_df(
    loan_id                      string             comment "loan id"
    ,month_on_book              string              comment "month on book"
    ,dpd_filter                 string              comment "dpd filter"
    ,disburse_date              date                comment "disburse date"
    ,principal_accu             decimal(30,10)      comment "principal accumulated"
    ,mob_date                   date                comment "mob date"
    ,principal_accu_no_early_repay decimal(30,10)   comment "principal accumulated no early repay"
)
partitioned by
(
    grass_date                  string              comment "YYYY-MM-DD"
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/ads/ads_risk_aio_loan_principal_accu_by_mob/grass_region=${upper_region}/product_id=${product_id}';

-- msck repair table ${SCHEMA}.ads_risk_${product}_${region}_loan_principal_accu_by_mob_df;

-- 创建临时视图 loan_disbursed_by_tenure（用于计算理论累计本金）
create or replace temporary view loan_disbursed_by_tenure_${product}_${region} as
select
    a.loan_id
    ,to_date(a.disburse_time) as disburse_date
    ,a.first_instalment_due_time as first_instalment_due_time
    ,sum(a.principal_repayable) as loan_amt
from credit_mart.dws_${product}_aio_${region}_loan_repayment_df a
where a.grass_date = '${grass_date}'
and a.product_id = ${product_id}
group by a.loan_id
    ,to_date(a.disburse_time)
    ,a.first_instalment_due_time
;

-- DML
-- loan_principal_accu_by_mob 计算每个 loan_id + MOB 的累计本金（包括实际和理论值）
WITH
-- 1. 基础配置：MOB 和 DPD 偏移量定义
mob_config as (
    select mob_num
    from (select posexplode(array(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24)) as (idx, mob_num))
),

dpd_config as (
    select '01.DPD0+' as dpd_filter, -1 as off_m, -1 as off_d
    union all select '02.DPD7+', -1, 6
    union all select '03.DPD15+', -1, 14
    union all select '04.DPD30+', -2, 29
    union all select '05.DPD60+', -3, 59
    union all select '06.DPD90+', -4, 89
),

-- 2. 理论还款计划轴：在膨胀前完成窗口计算
theoretical_timeline as (
    select
        base.loan_id
        ,base.disburse_date
        ,base.loan_amt
        ,to_date(base.first_instalment_due_time) as first_due_date
        ,to_date(inst.month_due_time) as period_end
        -- 获取上一期结束日
        ,coalesce(
            lag(to_date(inst.month_due_time)) over (partition by base.loan_id order by to_date(inst.month_due_time)),
            base.disburse_date
        ) as period_start
        -- 计算本期开始时的剩余本金（总额 - 之前各期应还之和）
        ,base.loan_amt - coalesce(
            sum(inst.principal_repayable) over (partition by base.loan_id order by to_date(inst.month_due_time) rows between unbounded preceding and 1 preceding),
            0
        ) as remaining_principal
        ,inst.principal_repayable
    from loan_disbursed_by_tenure_${product}_${region} base
    inner join credit_mart.dws_${product}_aio_${region}_instalment_repayment_df inst
        on base.loan_id = inst.loan_id
        and inst.grass_date = '${grass_date}'
        and inst.product_id = ${product_id}
),

-- 3. 计算理论累计本金 
theoretical_final as (
    select /*+ BROADCAST(m), BROADCAST(d) */
        t.loan_id
        ,concat('MOB', lpad(cast(m.mob_num as string), 2, '0')) as month_on_book
        ,d.dpd_filter
        ,sum(
            -- 标准分期时间段内的accu
            case
                -- 情况1: 观测点 mob_date 在该期结束之后 
                when t.period_end <= calc.mob_date
                then t.remaining_principal * greatest(datediff(t.period_end, t.period_start), 0)
                -- 情况2: 观测点 mob_date 落在该期中间 
                when t.period_start < calc.mob_date and t.period_end > calc.mob_date
                then t.remaining_principal * (datediff(calc.mob_date, t.period_start) + 1)
                else 0
            end
        ) as principal_accu_no_early_repay_raw
    from theoretical_timeline t
    cross join mob_config m
    cross join dpd_config d
    lateral view outer explode(array(
        case
            when d.dpd_filter = '01.DPD0+' then add_months(date_add(t.first_due_date, -1), m.mob_num - 1)
            else date_add(add_months(t.first_due_date, m.mob_num + d.off_m), d.off_d)
        end
    )) calc as mob_date
    group by t.loan_id, m.mob_num, d.dpd_filter
),

-- 4. 计算实际累计本金
actual_final as (
    select /*+ BROADCAST(m), BROADCAST(d) */
        a.loan_id
        ,concat('MOB', lpad(cast(m.mob_num as string), 2, '0')) as month_on_book
        ,d.dpd_filter
        ,a.disburse_date
        ,sum(
            case
                when to_date(a.start_date) <= calc.mob_date
                and to_date(if(a.end_date='9999-12-31','${grass_date}',a.end_date)) >= a.disburse_date
                and least(to_date(if(a.end_date='9999-12-31','${grass_date}',a.end_date)), calc.mob_date) >= greatest(to_date(a.start_date), a.disburse_date)
                then a.principal_os * (
                    datediff(
                        least(to_date(if(a.end_date='9999-12-31','${grass_date}',a.end_date)), calc.mob_date),
                        greatest(to_date(a.start_date), a.disburse_date)
                    ) + 1
                )
                else 0
            end
        ) as principal_accu
        ,max(calc.mob_date) as mob_date
    from (
        select
            zi.loan_id
            ,to_date(zi.first_instalment_due_time) as first_due_date
            ,zi.start_date
            ,zi.end_date
            ,zi.principal_os
            ,to_date(zi.disburse_time) as disburse_date
        from risk.dws_risk_${product}_${region}_loan_repayment_zi zi
        where zi.loan_disbursed_month >= from_unixtime(unix_timestamp(add_months('${grass_date}',-24), 'yyyy-MM-dd'), 'yyyyMM')
    ) a
    cross join mob_config m
    cross join dpd_config d
    lateral view outer explode(array(
        case
            when d.dpd_filter = '01.DPD0+' then add_months(date_add(a.first_due_date, -1), m.mob_num - 1)
            else date_add(add_months(a.first_due_date, m.mob_num + d.off_m), d.off_d)
        end
    )) calc as mob_date
    -- 移除剪枝优化，确保 0 值行依然输出，保持与原逻辑数据量完全一致
    -- where to_date(a.start_date) <= calc.mob_date
    group by a.loan_id, m.mob_num, a.disburse_date, d.dpd_filter
)

-- 5. 最终结果关联
INSERT OVERWRITE TABLE ${SCHEMA}.ads_risk_${product}_${region}_loan_principal_accu_by_mob_df PARTITION(grass_date)
select
    act.loan_id
    ,act.month_on_book
    ,act.dpd_filter
    ,act.disburse_date
    ,act.principal_accu
    ,act.mob_date
    -- 兼容旧逻辑：如果无理论本金，转为NULL
    ,case when theo.principal_accu_no_early_repay_raw = 0 then NULL else theo.principal_accu_no_early_repay_raw end as principal_accu_no_early_repay
    ,'${grass_date}' as grass_date
from actual_final act
left join theoretical_final theo
    on act.loan_id = theo.loan_id
    and act.month_on_book = theo.month_on_book
    and act.dpd_filter = theo.dpd_filter;
