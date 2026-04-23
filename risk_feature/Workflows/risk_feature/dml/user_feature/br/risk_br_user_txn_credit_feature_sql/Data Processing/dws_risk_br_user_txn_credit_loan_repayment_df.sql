-- =============================================================================
-- Author:              chenyingying
-- Created Time:        2026-01-16
-- Theme Domain:        User Loan Info Credit Feature
-- Data Granularity:    credit_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-02-14 - chenyingying - 初始化
-- =============================================================================
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_txn_credit_loan_repayment_df
(
    credit_user_id                                      string comment 'credit user id'
    ,repaid_bills_num_spl                               bigint comment 'has repaid bcl bills flag'
    ,postloan_reject_cnt_bcl                            bigint comment 'BCL post-loan reject count'
    ,postloan_reject_cnt_spl                            bigint comment 'SPL post-loan reject count'
    ,preloan_reject_cnt_bcl                             bigint comment 'BCL pre-loan reject count'
    ,preloan_reject_cnt_spl                             bigint comment 'SPL pre-loan reject count in 90d'
    ,postloan_reject_cnt_90d_bcl                        bigint comment 'BCL post-loan reject count in 90d'
    ,postloan_reject_cnt_90d_spl                        bigint comment 'SPL post-loan reject count in 90d'
    ,preloan_reject_cnt_90d_bcl                         bigint comment 'BCL pre-loan reject count in 90d'
    ,preloan_reject_cnt_90d_spl                         bigint comment 'SPL pre-loan reject count in 90d'
    ,postloan_reject_cnt_180d_bcl                       bigint comment 'BCL post-loan reject count in 180d'
    ,postloan_reject_cnt_180d_spl                       bigint comment 'SPL post-loan reject count in 180d'
    ,preloan_reject_cnt_180d_bcl                        bigint comment 'BCL pre-loan reject count in 180d'
    ,preloan_reject_cnt_180d_spl                        bigint comment 'BCL pre-loan reject count in 180d'
)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reguser_txn_credit_loan_repayment_df/grass_region=${grass_region}';
-- msck repair table ${SCHEMA}.dws_risk_${region}_user_txn_credit_loan_repayment_df;



create or replace temporary view user_withdraw_info_df as (
    select
        --substring(md5(cast(t1.user_id as string)), 0, 2) || '_' || t1.user_id as row_key,
        t1.user_id as credit_user_id,
        count(
            distinct if(
                days_after_first_due_date_cashloan >= 1    
                and is_bcl_policy,
                flow_no,
                null
            )
        ) as postloan_reject_cnt_bcl,
        count(
            distinct if(
                days_after_first_due_date_spl >= 1
                and is_spl_policy,
                flow_no,
                null
            )
        ) as postloan_reject_cnt_spl,
        count(
            distinct if(
                days_after_first_due_date_cashloan < 1
                and is_bcl_policy,
                flow_no,
                null
            )
        ) as preloan_reject_cnt_bcl,
        count(
            distinct if(
                days_after_first_due_date_spl < 1
                and is_spl_policy,
                flow_no,
                null
            )
        ) as preloan_reject_cnt_spl,
        count(
            distinct if(
                days_after_first_due_date_cashloan >= 1
                and is_90d
                and is_bcl_policy,
                flow_no,
                null
            )
        ) as postloan_reject_cnt_90d_bcl,
        count(
            distinct if(
                days_after_first_due_date_spl >= 1
                and is_90d
                and is_spl_policy,
                flow_no,
                null
            )
        ) as postloan_reject_cnt_90d_spl,
        count(
            distinct if(
                days_after_first_due_date_cashloan < 1
                and is_90d
                and is_bcl_policy,
                flow_no,
                null
            )
        ) as preloan_reject_cnt_90d_bcl,
        count(
            distinct if(
                days_after_first_due_date_spl < 1
                and is_90d
                and is_spl_policy,
                flow_no,
                null
            )
        ) as preloan_reject_cnt_90d_spl,
        count(
            distinct if(
                days_after_first_due_date_cashloan >= 1
                and is_180d
                and is_bcl_policy,
                flow_no,
                null
            )
        ) as postloan_reject_cnt_180d_bcl,
        count(
            distinct if(
                days_after_first_due_date_spl >= 1
                and is_180d
                and is_spl_policy,
                flow_no,
                null
            )
        ) as postloan_reject_cnt_180d_spl,
        count(
            distinct if(
                days_after_first_due_date_cashloan < 1
                and is_180d
                and is_bcl_policy,
                flow_no,
                null
            )
        ) as preloan_reject_cnt_180d_bcl,
        count(
            distinct if(
                days_after_first_due_date_spl < 1
                and is_180d
                and is_spl_policy,
                flow_no,
                null
            )
        ) as preloan_reject_cnt_180d_spl,
        count(
            distinct if(
                is_90d 
                and is_bcl_policy,
                flow_no,
                null ) 
        )as rejected_num_90d_bcl,
        '${ds}' as grass_date
    from
        (
            select
                *
            from
                risk.dws_risk_${region}_user_dpd_df
            where
                grass_date = '${ds}'
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
            from
                risk.dwd_risk_${region}_strategy_task_result_merge_di
            where
                task_name = 'invoke_policy'
                and task_result = 2
                and (
                    (
                        topic_name = '${region}_live_credit_risk_gateway_req_rsp_kredit'
                        and risk_scene_id in('10025', '10035', '10045', '10055', '10075')
                    )
                    or (
                        topic_name = '${region}_live_credit_risk_gateway_req_rsp_spj'
                        and risk_scene_id ='10025'
                    )
                )
        ) t2 on t1.user_id = t2.credit_user_id
    group by    t1.user_id
);

insert overwrite ${SCHEMA}.dws_risk_${region}_user_txn_credit_loan_repayment_df partition (grass_date = '${ds}')
select t1.credit_user_id
        ,null as repaid_bills_num_spl
        ,postloan_reject_cnt_bcl     
        ,t2.postloan_reject_cnt_spl     
        ,t2.preloan_reject_cnt_bcl      
        ,t2.preloan_reject_cnt_spl      
        ,t2.postloan_reject_cnt_90d_bcl 
        ,t2.postloan_reject_cnt_90d_spl 
        ,t2.preloan_reject_cnt_90d_bcl  
        ,t2.preloan_reject_cnt_90d_spl  
        ,t2.postloan_reject_cnt_180d_bcl
        ,t2.postloan_reject_cnt_180d_spl
        ,t2.preloan_reject_cnt_180d_bcl 
        ,t2.preloan_reject_cnt_180d_spl 
from (
    select credit_user_id
    from credit_uc.dws_all_prod_br_uc_user_df
    where   grass_date = '${ds}'
    and     credit_user_id is not null
    and     credit_user_id <> '0'
    and     credit_user_id <> ''
    group by credit_user_id
) t1
left join (
    select credit_user_id
            ,postloan_reject_cnt_bcl     
            ,postloan_reject_cnt_spl     
            ,preloan_reject_cnt_bcl      
            ,preloan_reject_cnt_spl      
            ,postloan_reject_cnt_90d_bcl 
            ,postloan_reject_cnt_90d_spl 
            ,preloan_reject_cnt_90d_bcl  
            ,preloan_reject_cnt_90d_spl  
            ,postloan_reject_cnt_180d_bcl
            ,postloan_reject_cnt_180d_spl
            ,preloan_reject_cnt_180d_bcl 
            ,preloan_reject_cnt_180d_spl 
    from    user_withdraw_info_df
) t2
on t1.credit_user_id = t2.credit_user_id