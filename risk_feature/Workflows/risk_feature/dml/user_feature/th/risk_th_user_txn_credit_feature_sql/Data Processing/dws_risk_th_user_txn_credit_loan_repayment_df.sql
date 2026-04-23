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
    ,has_repaid_bcl_bills_flag                          bigint          comment 'has repaid bcl bills flag'
    ,month_due_spl                                      bigint           comment 'month due spl cnt'
    ,preloan_reject_cnt_chp                             bigint          comment 'preloan_reject_cnt_chp'
    ,preloan_reject_cnt_90d_chp                         bigint          comment 'preloan_reject_cnt_90d_chp'
    ,preloan_reject_cnt_180d_chp                        bigint          comment 'preloan_reject_cnt_180d_chp'
    ,first_postloan_reject_date_chp                     string         comment 'first_postloan_reject_date_chp'
    ,repaid_bills_num_spl                               bigint          comment 'repaid_bills_num_spl'
    ,repaid_bills_num_bcl                               bigint          comment 'repaid_bills_num_bcl'
    ,postloan_reject_cnt_bcl                            bigint          comment 'BCL post-loan reject cnt'
    ,preloan_reject_cnt_bcl                             bigint          comment 'BCL pre-loan reject cnt'
    ,postloan_reject_cnt_90d_bcl                        bigint          comment 'BCL post-loan reject cnt in 90 days'
    ,preloan_reject_cnt_90d_bcl                         bigint          comment 'BCL pre-loan reject cnt in 90 days'
    ,postloan_reject_cnt_180d_bcl                       bigint          comment 'BCL post-loan reject cnt in 180 days'
    ,preloan_reject_cnt_180d_bcl                        bigint          comment 'BCL pre-loan reject cnt in 180 days'
    ,rejected_num_90d_bcl                               bigint          comment 'BCL rejected num in 90 days'
    ,postloan_reject_cnt_spl                            bigint          comment 'SPL post-loan reject cnt'
    ,preloan_reject_cnt_spl                             bigint          comment 'SPL pre-loan reject cnt'
    ,postloan_reject_cnt_90d_spl                        bigint          comment 'SPL post-loan reject cnt in 90 days'
    ,preloan_reject_cnt_90d_spl                         bigint          comment 'SPL pre-loan reject cnt in 90 days'
    ,postloan_reject_cnt_180d_spl                       bigint          comment 'SPL post-loan reject cnt in 180 days'
    ,preloan_reject_cnt_180d_spl                        bigint          comment 'SPL pre-loan reject cnt in 180 days'
)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reguser_txn_credit_loan_repayment_df/grass_region=${grass_region}';
-- msck repair table ${SCHEMA}.dws_risk_${region}_user_txn_credit_loan_repayment_df;


ADD JAR hdfs://${IDC_NAMESPACE}/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
drop temporary function if exists json_to_array;
create temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';

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

create or replace temporary view withdraw_info as (
    select  t1.user_id as credit_user_id,
            count(
                distinct if(
                    days_after_first_due_date_cashloan >= 1
                    and t2.is_bcl_policy,
                    t2.flow_no,
                    null
                )
            ) as postloan_reject_cnt_bcl,
            count(
                distinct if(
                    days_after_first_due_date_spl >= 1
                    and t2.is_spl_policy,
                    t2.flow_no,
                    null
                )
            ) as postloan_reject_cnt_spl,
            count(
                distinct if(
                    days_after_first_due_date_cashloan < 1
                    and t2.is_bcl_policy,
                    t2.flow_no,
                    null
                )
            ) as preloan_reject_cnt_bcl,
            count(
                distinct if(
                    days_after_first_due_date_spl < 1
                    and t2.is_spl_policy,
                    t2.flow_no,
                    null
                )
            ) as preloan_reject_cnt_spl,
            count(
                distinct if(
                    days_after_first_due_date_cashloan >= 1
                    and t2.is_90d
                    and t2.is_bcl_policy,
                    t2.flow_no,
                    null
                )
            ) as postloan_reject_cnt_90d_bcl,
            count(
                distinct if(
                    days_after_first_due_date_spl >= 1
                    and t2.is_90d
                    and t2.is_spl_policy,
                    t2.flow_no,
                    null
                )
            ) as postloan_reject_cnt_90d_spl,
            count(
                distinct if(
                    days_after_first_due_date_cashloan < 1
                    and t2.is_90d
                    and t2.is_bcl_policy,
                    t2.flow_no,
                    null
                )
            ) as preloan_reject_cnt_90d_bcl,
            count(
                distinct if(
                    days_after_first_due_date_spl < 1
                    and t2.is_90d
                    and t2.is_spl_policy,
                    t2.flow_no,
                    null
                )
            ) as preloan_reject_cnt_90d_spl,
            count(
                distinct if(
                    days_after_first_due_date_cashloan >= 1
                    and t2.is_180d
                    and t2.is_bcl_policy,
                    t2.flow_no,
                    null
                )
            ) as postloan_reject_cnt_180d_bcl,
            count(
                distinct if(
                    days_after_first_due_date_spl >= 1
                    and t2.is_180d
                    and t2.is_spl_policy,
                    t2.flow_no,
                    null
                )
            ) as postloan_reject_cnt_180d_spl,
            count(
                distinct if(
                    days_after_first_due_date_cashloan < 1
                    and t2.is_180d
                    and t2.is_bcl_policy,
                    t2.flow_no,
                    null
                )
            ) as preloan_reject_cnt_180d_bcl,
            count(
                distinct if(
                    days_after_first_due_date_spl < 1
                    and t2.is_180d
                    and t2.is_spl_policy,
                    t2.flow_no,
                    null
                )
            ) as preloan_reject_cnt_180d_spl,
            count(
                distinct if(
                    t2.is_90d 
                    and t2.is_bcl_policy,
                    t2.flow_no,
                    null ) 
            )as rejected_num_90d_bcl
    from   (
        select  *
        from    risk.dws_risk_${region}_user_dpd_df
        where   grass_date = '${ds}'
    ) t1
    left join (
        select
            credit_user_id,
            flow_no,
            topic_name,
            risk_scene_id,
            date_sub('${ds}', 90) <= grass_date as is_90d,
            date_sub('${ds}', 180) <= grass_date as is_180d,
            topic_name = '${region}_live_credit_risk_gateway_req_rsp_kredit'
            and risk_scene_id in ('10025', '10035', '10045', '10055', '10075') as is_spl_policy,
            topic_name = '${region}_live_credit_risk_gateway_req_rsp_spj'
            and risk_scene_id = '10025' as is_bcl_policy
        from    risk.dwd_risk_${region}_strategy_task_result_merge_di
        where   task_name = 'invoke_policy'
        and task_result = 2
        and (
            -- 原有 spl 条件
            (
                topic_name = '${region}_live_credit_risk_gateway_req_rsp_kredit'
                and risk_scene_id in('10025', '10035', '10045', '10055', '10075')
            )
            -- 原有 bcl 条件
            or (
                topic_name = '${region}_live_credit_risk_gateway_req_rsp_spj'
                and risk_scene_id ='10025'
            )
        )
    ) t2 
    on t1.user_id = t2.credit_user_id
    group by    t1.user_id
)
;


insert overwrite table ${SCHEMA}.dws_risk_${region}_user_txn_credit_loan_repayment_df partition (grass_date = '${ds}')
select
    t1.credit_user_id
    ,t3.has_repaid_bcl_bills_flag
    ,coalesce(t4.month_due_spl, 0) as month_due_spl
    ,t7.preloan_reject_cnt_spl_extra as preloan_reject_cnt_chp
    ,t7.preloan_reject_cnt_90d_spl_extra as preloan_reject_cnt_90d_chp
    ,t7.preloan_reject_cnt_180d_spl_extra as preloan_reject_cnt_180d_chp
    ,t7.first_postloan_reject_date_spl_extra as first_postloan_reject_date_chp
    ,t5.repaid_bills_num_spl
    ,t6.repaid_bills_num_bcl
    ,t2.postloan_reject_cnt_bcl     
    ,t2.preloan_reject_cnt_bcl      
    ,t2.postloan_reject_cnt_90d_bcl 
    ,t2.preloan_reject_cnt_90d_bcl  
    ,t2.postloan_reject_cnt_180d_bcl
    ,t2.preloan_reject_cnt_180d_bcl 
    ,t2.rejected_num_90d_bcl        
    ,t2.postloan_reject_cnt_spl     
    ,t2.preloan_reject_cnt_spl      
    ,t2.postloan_reject_cnt_90d_spl 
    ,t2.preloan_reject_cnt_90d_spl  
    ,t2.postloan_reject_cnt_180d_spl
    ,t2.preloan_reject_cnt_180d_spl 
from 
(
    select
        credit_user_id
    from credit_uc.dws_all_prod_${region}_uc_user_df
    where
        grass_date = '${ds}'
        and credit_user_id <> ''
        and credit_user_id is not null
        and credit_user_id <> '0'
    group by credit_user_id
) t1
left join
(
    select  credit_user_id
            ,postloan_reject_cnt_bcl     
            ,preloan_reject_cnt_bcl      
            ,postloan_reject_cnt_90d_bcl 
            ,preloan_reject_cnt_90d_bcl  
            ,postloan_reject_cnt_180d_bcl
            ,preloan_reject_cnt_180d_bcl 
            ,rejected_num_90d_bcl        
            ,postloan_reject_cnt_spl     
            ,preloan_reject_cnt_spl      
            ,postloan_reject_cnt_90d_spl 
            ,preloan_reject_cnt_90d_spl  
            ,postloan_reject_cnt_180d_spl
            ,preloan_reject_cnt_180d_spl  
    from    withdraw_info
) t2 
on t1.credit_user_id = t2.credit_user_id
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
left join (
    select  credit_user_id
            ,repaid_bills_num_spl
    from    credit_mart.dws_spl_${region}_user_risk_df
    where   grass_date = '${ds}'
) t5
on t1.credit_user_id = t5.credit_user_id
left join (
    select
        credit_user_id
        ,repaid_bills_num as repaid_bills_num_bcl
    from credit_mart.dws_bcl_${region}_user_risk_df
    where grass_date = '${ds}'
) t6
on t1.credit_user_id = t6.credit_user_id
left join(
    select 
    a.credit_user_id 
    ,count(distinct a.flow_no) as preloan_reject_cnt_spl_extra
    ,count(distinct case when a.grass_date >=date_sub('${grass_date}',90) then a.flow_no else null end) as preloan_reject_cnt_90d_spl_extra
    ,count(distinct case when a.grass_date >=date_sub('${grass_date}',180) then a.flow_no else null end) as preloan_reject_cnt_180d_spl_extra
    ,min(a.grass_date) as first_postloan_reject_date_spl_extra
    from risk.dwd_risk_th_strategy_task_result_merge_di a 
    join(
        select 
        user_id as credit_user_id 
        ,null as days_after_first_due_date_chp
        from  risk.dws_risk_${region}_user_dpd_df 
        where grass_date='${ds}'
    ) b on a.credit_user_id  = b.credit_user_id
    where a.topic_name = 'tn_live_credit_risk_gateway_req_rsp_chp'
    and a.risk_scene_id = '10045'
    and a.task_name = 'invoke_policy'
    and a.task_result = 2
    and b.days_after_first_due_date_chp < 1 
    group by a.credit_user_id 
) t7 on t1.credit_user_id = t7.credit_user_id
;