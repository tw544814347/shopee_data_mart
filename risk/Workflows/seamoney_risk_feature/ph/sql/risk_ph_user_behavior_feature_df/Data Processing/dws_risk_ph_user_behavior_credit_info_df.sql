--drop table if exists ${SCHEMA}.dws_risk_ph_user_behavior_credit_info_df;
create table if not exists ${SCHEMA}.dws_risk_ph_user_behavior_credit_info_df (
    credit_user_id string comment 'credit_user_id'
    ,is_spl_disbursed bigint
    ,is_chp_disbursed bigint
    ,is_spl_billed bigint
    ,first_spl_disburse_time string
    ,is_bcl_disbursed bigint
    ,repaid_bills_num_spl bigint
    ,repaid_bills_num_bcl_floating bigint
    ,repaid_bills_num_chp bigint
)
partitioned by
    (grass_date string comment 'grass_date, partition key') stored as orc tblproperties ("orc.compress" = "zstd") 
    location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_behavior_credit_info_df/grass_region=PH'
;
--msck repair table ${SCHEMA}.dws_risk_ph_user_behavior_credit_info_df;

uncache table if exists credit_user_base;
cache table credit_user_base options ('storageLevel' 'MEMORY_AND_DISK')
select
    credit_user_id
from credit_uc.dws_aio_ph_uc_user_df
where grass_date = '${grass_date}'
and credit_user_id is not null
group by credit_user_id
;

create or replace temporary view v_is_spl_disbursed as
select
    t1.credit_user_id
    ,t2.is_spl_disbursed
    ,t2.is_chp_disbursed
from credit_user_base t1
    left join (
        select
            credit_user_id
            ,max(case when spl_disbursed_amount > 0 then 1 else null end) as is_spl_disbursed
            ,max(case when chp_disbursed_amount > 0 then 1 else null end) as is_chp_disbursed
        from
            (
                select
                    credit_user_id
                    ,loan_id
                    ,sum(case when biz_type = 3 then principal_repayable - principal_refund else null end) as spl_disbursed_amount
                    ,sum(case when biz_type = 7 then principal_repayable - principal_refund else null end) as chp_disbursed_amount
                from credit_mart.dws_spl_ph_instalment_repayment_df
                where grass_date = '${grass_date}'
                group by 1, 2
            ) t
        group by credit_user_id
    ) t2 on t1.credit_user_id = t2.credit_user_id
;

create or replace temporary view v_is_spl_billed as
select
    credit_user_id
from credit_mart.dws_spl_ph_bill_repayment_df
where
    grass_date = '${grass_date}'
    and biz_type = 3
    and bill_status in (2, 3)
    and total_amount_repayable - total_amount_refund - total_amount_deduct > 0
group by credit_user_id
;

insert overwrite table
    ${SCHEMA}.dws_risk_ph_user_behavior_credit_info_df partition (grass_date = '${grass_date}')
select
    t1.credit_user_id
    ,t2.is_spl_disbursed
    ,t2.is_chp_disbursed
    ,if(t7.credit_user_id is not null, 1, null) as is_spl_billed
    ,t4.first_spl_disburse_time
    ,t6.is_bcl_disbursed
    ,t4.repaid_bills_num_spl
    ,t5.repaid_bills_num_bcl_floating
    ,t4.repaid_bills_num_chp
from credit_user_base t1
    left join v_is_spl_disbursed t2 on t1.credit_user_id = t2.credit_user_id
    left join
    (
        select
            credit_user_id
            ,first_spl_disburse_time
            ,repaid_bills_num_spl
            ,repaid_bills_num_chp
        from credit_mart.dws_spl_ph_user_risk_df
        where grass_date = '${grass_date}'
    ) t4 on t1.credit_user_id = t4.credit_user_id
     left join
    (
        select
            credit_user_id
            ,repaid_bills_num_floating as repaid_bills_num_bcl_floating
        from credit_mart.dws_bcl_ph_user_risk_df
        where grass_date = '${grass_date}'
    ) t5 on t1.credit_user_id = t5.credit_user_id
    left join
    (
        select
            credit_user_id
            ,is_disbursed as is_bcl_disbursed
        from credit_mart.dws_bcl_ph_user_df
        where grass_date = '${grass_date}'
    ) t6 on t1.credit_user_id = t6.credit_user_id
    left join v_is_spl_billed t7 on t1.credit_user_id = t7.credit_user_id
;