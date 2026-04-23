-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2026-01-20
-- Theme Domain:        User Txn Loan Repayment Credit Feature
-- Data Granularity:    credit_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-01-20 - chengguo.liu - 初始化
-- =============================================================================

-- drop table if exists ${SCHEMA}.dws_risk_${region}_user_txn_credit_loan_repayment_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_txn_credit_loan_repayment_df
(
    credit_user_id                                      string         comment 'credit user id'
    ,shopee_user_id                                     string         comment 'shopee user id'
    ,has_repaid_bcl_bills_flag                          bigint          comment 'has repaid bcl bills flag'
    ,month_due_spl                                     bigint           comment 'month due spl cnt'
    ,preloan_reject_cnt_chp                             bigint          comment 'preloan_reject_cnt_chp'
    ,preloan_reject_cnt_90d_chp                         bigint          comment 'preloan_reject_cnt_90d_chp'
    ,preloan_reject_cnt_180d_chp                        bigint          comment 'preloan_reject_cnt_180d_chp'
    ,first_postloan_reject_date_chp                     string         comment 'first_postloan_reject_date_chp'
)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reguser_txn_credit_loan_repayment_df/grass_region=${grass_region}';
-- msck repair table ${SCHEMA}.dws_risk_${region}_user_txn_credit_loan_repayment_df;


create or replace temporary view view_spl_repayment as
select
    credit_user_id
    ,sum(case when product_tag = 'SPL' then 1 else 0 end) as month_due_spl
from (
    select
        credit_user_id
        ,trunc(month_due_time, 'MONTH') as month_due
        ,'SPL' as product_tag
    from credit_mart.dws_spl_th_bill_repayment_df
    where   grass_date = '${ds}'
    and coalesce(bill_term, '') <> ''
    and principal_repayable > 0
    and '${tomorrow_ds}' > cast(month_due_time as date)
    group by credit_user_id, trunc(month_due_time, 'MONTH')
) a
group by credit_user_id
;



insert overwrite table ${SCHEMA}.dws_risk_${region}_user_txn_credit_loan_repayment_df partition (grass_date = '${grass_date}')
select
    t1.credit_user_id
    ,t1.shopee_user_id
    ,t3.has_repaid_bcl_bills_flag
    ,t4.month_due_spl
    ,t2.preloan_reject_cnt_chp
    ,t2.preloan_reject_cnt_90d_chp
    ,t2.preloan_reject_cnt_180d_chp
    ,t2.first_postloan_reject_date_chp
from 
(
    select
        credit_user_id
        ,platform_user_id   as shopee_user_id
    from credit_uc.dws_all_prod_${region}_uc_user_df
    where
        grass_date = '${grass_date}'
        and credit_user_id <> ''
        and credit_user_id is not null
        and credit_user_id <> '0'
    group by credit_user_id, platform_user_id
) t1
left join
(
    select 
        a.credit_user_id 
        ,count(distinct a.flow_no) as preloan_reject_cnt_chp
        ,count(distinct case when a.grass_date >=date_sub('${grass_date}',90) then a.flow_no else null end) as preloan_reject_cnt_90d_chp
        ,count(distinct case when a.grass_date >=date_sub('${grass_date}',180) then a.flow_no else null end) as preloan_reject_cnt_180d_chp
        ,min(a.grass_date) as first_postloan_reject_date_chp
    from risk.dwd_risk_${region}_strategy_task_result_merge_di a 
    join(
        select 
        user_id as credit_user_id 
        ,days_after_first_due_date_chp
        from  risk.dws_risk_${region}_user_dpd_df 
        where grass_date='${grass_date}'
    ) b on a.credit_user_id  = b.credit_user_id
    where a.topic_name = 'tn_live_credit_risk_gateway_req_rsp_chp'
        and a.risk_scene_id = '10045'
        and a.task_name = 'invoke_policy'
        and a.task_result = 2
        and b.days_after_first_due_date_chp < 1 
    group by a.credit_user_id 
) t2 on t1.credit_user_id = t2.credit_user_id
left join (
    select  credit_user_id
            ,case when first_due_time_bcl<='${ds}' then 1 else 0 end has_repaid_bcl_bills_flag
    from (
        select
            credit_user_id
            ,min(first_instalment_due_time) as first_due_time_bcl
        from credit_mart.dws_bcl_th_loan_repayment_df
        where grass_date = '${ds}'
        and principal_repayable - principal_refund - principal_deduct> 0
        group by credit_user_id 
    ) 
) t3
on t1.credit_user_id = t3.credit_user_id
left join 
(
    select credit_user_id
            ,month_due_spl
    from    view_spl_repayment
) t4
on t1.credit_user_id = t4.credit_user_id
;