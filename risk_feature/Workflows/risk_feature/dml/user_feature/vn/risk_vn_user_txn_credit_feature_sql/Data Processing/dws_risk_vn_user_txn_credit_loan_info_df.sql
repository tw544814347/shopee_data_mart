-- =============================================================================
-- Author:              chenyingying@shopee.com
-- Created Time:        2026-02-05
-- Theme Domain:        User Txn Loan Repayment Credit Feature
-- Data Granularity:    credit_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-01-20 - chenyingying - 初始化
-- =============================================================================


-- drop table if exists ${SCHEMA}.dws_risk_${region}_user_txn_credit_loan_info_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_txn_credit_loan_info_df (
    credit_user_id              string comment 'credit_user_id'
    ,eir_tenure2_bcl            decimal(30,10) comment 'BCL User tenure2 EIR'            
    ,eir_tenure3_bcl            decimal(30,10) comment 'BCL User tenure3 EIR'
    ,eir_tenure6_bcl            decimal(30,10) comment 'BCL User tenure6 EIR'
    ,eir_tenure12_bcl           decimal(30,10) comment 'BCL User tenure12 EIR'
    ,eir_tenure1_spl            decimal(30,10) comment 'SPL User tenure1 EIR'
    ,eir_tenure2_spl            decimal(30,10) comment 'SPL User tenure2 EIR'
    ,eir_tenure3_spl            decimal(30,10) comment 'SPL User tenure3 EIR'
    ,eir_tenure6_spl            decimal(30,10) comment 'SPL User tenure6 EIR'
    ,eir_tenure12_spl           decimal(30,10) comment 'SPL User tenure12 EIR'
    ,eir_tenure18_spl           decimal(30,10) comment 'SPL User tenure18 EIR'
    ,eir_tenure24_spl           decimal(30,10) comment 'SPL User tenure24 EIR'
    ,os_bcl                     decimal(30,10) comment 'BCL Outstanding Balance'
    ,os_spl                     decimal(30,10) comment 'SPL Outstanding Balance'
    ,first_billed_from_now_spl  bigint comment 'First Billed Date From Now SPL'
    ,first_billed_from_now_bcl  bigint comment 'First Billed Date From Now BCL'
    ,repaid_bills_num_cashloan  bigint comment 'Number of repaid bills BCL'
    ,repaid_bills_num_spl       bigint comment 'Number of repaid bills SPL'
)
partitioned by (grass_date string comment 'grass_date, partition key')
stored as orc tblproperties ("orc.compress" = "zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_reg_user_txn_credit_loan_info_df/grass_region=${grass_region}';
-- msck repair table ${SCHEMA}.dws_risk_${region}_user_txn_credit_loan_info_df;



insert overwrite table ${SCHEMA}.dws_risk_${region}_user_txn_credit_loan_info_df partition(grass_date='${grass_date}')
select  t1.credit_user_id
        ,t2.eir_tenure2_bcl
        ,t2.eir_tenure3_bcl
        ,t2.eir_tenure6_bcl
        ,t2.eir_tenure12_bcl
        ,t3.eir_tenure1_spl
        ,t3.eir_tenure2_spl
        ,t3.eir_tenure3_spl 
        ,t3.eir_tenure6_spl 
        ,t3.eir_tenure12_spl
        ,t3.eir_tenure18_spl
        ,t3.eir_tenure24_spl
        ,t4.os_bcl
        ,t5.os_spl
        ,t7.num_months as first_billed_from_now_spl
        ,t6.num_months as first_billed_from_now_bcl
        ,t6.repaid_bills_num_cashloan
        ,t8.repaid_bills_num_spl
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
    select  credit_user_id
            ,eir_tenure2    as eir_tenure2_bcl
            ,eir_tenure3    as eir_tenure3_bcl
            ,eir_tenure6    as eir_tenure6_bcl
            ,eir_tenure12   as eir_tenure12_bcl
    from    credit_mart.tdm_bcl_vn_user_fee_rate_df
    where   grass_date = '${ds}'
) t2
on t1.credit_user_id = t2.credit_user_id
left join (
    select  credit_user_id
            ,eir_tenure1    as eir_tenure1_spl
            ,eir_tenure2    as eir_tenure2_spl
            ,eir_tenure3    as eir_tenure3_spl 
            ,eir_tenure6    as eir_tenure6_spl 
            ,eir_tenure12   as eir_tenure12_spl
            ,eir_tenure18   as eir_tenure18_spl
            ,eir_tenure24   as eir_tenure24_spl
    from    credit_mart.tdm_spl_vn_user_fee_rate_df
    where   grass_date = '${ds}'
) t3
on t1.credit_user_id = t3.credit_user_id
left join (
    select  credit_user_id
            ,principal_os   as os_bcl
    from    credit_mart.dws_bcl_${region}_user_df
    where   grass_date = '${ds}'
) t4
on t1.credit_user_id = t4.credit_user_id
left join (
    select  credit_user_id
            ,principal_os   as os_spl
    from    credit_mart.dws_spl_${region}_user_df
    where   grass_date = '${ds}'
) t5
on t1.credit_user_id = t5.credit_user_id
left join (
    select  credit_user_id
            ,num_months
            ,repaid_bills_num   as repaid_bills_num_cashloan
    from    credit_mart.wide_bcl_vn_behavior_user_df
    where   grass_date = '${ds}'
) t6
on t1.credit_user_id = t6.credit_user_id
left join (
    select credit_user_id
            ,num_months
    from    credit_mart.wide_spl_vn_behavior_user_df
    where   grass_date = '${ds}'
) t7
on t1.credit_user_id = t7.credit_user_id
left join (
    select  credit_user_id
            ,repaid_bills_num_spl
    from    credit_mart.dws_spl_vn_user_risk_df
    where   grass_date = '${ds}'
) t8
on t1.credit_user_id = t8.credit_user_id