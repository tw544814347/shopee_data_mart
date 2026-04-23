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

create external table if not exists ${SCHEMA}.dws_risk_${region}_user_txn_credit_loan_info_df (
    credit_user_id              string comment 'credit_user_id'
    ,is_bcl_disbursed           bigint comment 'BCL Disbursed flag'
    ,is_spl_disbursed           bigint comment 'SPL Disbursed flag'
)
partitioned by (grass_date string comment 'grass_date, partition key')
stored as orc tblproperties ("orc.compress" = "zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_reg_user_txn_credit_loan_info_df/grass_region=${grass_region}';
msck repair table ${SCHEMA}.dws_risk_${region}_user_txn_credit_loan_info_df;



insert overwrite table ${SCHEMA}.dws_risk_${region}_user_txn_credit_loan_info_df partition(grass_date='${ds}')
select  t1.credit_user_id
        ,t3.is_bcl_disbursed
        ,t2.is_spl_disbursed
from (
    select credit_user_id
    from   credit_uc.dws_all_prod_${region}_uc_user_df
    where   grass_date = '${ds}'
    and     credit_user_id is not null
    and     credit_user_id <> '0'
    and     credit_user_id <> ''  
    group by    credit_user_id
) t1
left join (
    select
        credit_user_id
        ,max(case when spl_disbursed_amount > 0 then 1 else null end) as is_spl_disbursed
    from    (
            select
                credit_user_id
                ,loan_id
                ,sum(case when biz_type = 3 then principal_repayable - principal_refund else null end) as spl_disbursed_amount
            from credit_mart.dws_spl_br_instalment_repayment_df
            where grass_date = '${ds}'
            group by 1, 2
    ) t
    group by credit_user_id
) t2 
on t1.credit_user_id = t2.credit_user_id
left join (
    select  credit_user_id
            ,is_disbursed as is_bcl_disbursed
    from credit_mart.dws_bcl_br_user_df
    where grass_date = '${ds}'
) t3
on t1.credit_user_id = t3.credit_user_id