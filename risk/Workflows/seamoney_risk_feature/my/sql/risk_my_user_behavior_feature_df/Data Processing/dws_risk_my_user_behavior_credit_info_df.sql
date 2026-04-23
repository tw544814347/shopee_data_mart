--drop table if exists ${SCHEMA}.dws_risk_my_user_behavior_credit_info_df;
create table if not exists ${SCHEMA}.dws_risk_my_user_behavior_credit_info_df (
    credit_user_id string comment 'credit_user_id'
    ,is_spl_disbursed bigint
    ,repaid_bills_num_spl bigint
    ,first_spl_disburse_time string
    ,is_bcl_disbursed bigint
    ,repaid_bills_num_bcl_floating bigint
)
partitioned by
    (grass_date string comment 'grass_date, partition key') stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_behavior_credit_info_df/grass_region=MY'
;
--msck repair table ${SCHEMA}.dws_risk_my_user_behavior_credit_info_df;

uncache table if exists credit_user_base;
cache table credit_user_base options ('storageLevel' 'MEMORY_AND_DISK')
select
    credit_user_id
from credit_uc.dws_aio_my_uc_user_df
where grass_date = '${grass_date}'
and credit_user_id is not null
group by credit_user_id
;

create or replace temporary view risk_is_disbursed as
select
    t1.credit_user_id
    ,t2.is_spl_disbursed
from credit_user_base t1
    left join (
        select
            credit_user_id
            ,max(case when spl_disbursed_amount > 0 then 1 else null end) as is_spl_disbursed
        from
            (
                select
                    credit_user_id
                    ,loan_id
                    ,sum(case when biz_type = 3 then principal_repayable - principal_refund else null end) as spl_disbursed_amount
                from credit_mart.dws_spl_my_instalment_repayment_df
                where grass_date = '${grass_date}'
                group by 1, 2
            ) t
        group by credit_user_id
    ) t2 on t1.credit_user_id = t2.credit_user_id
;

insert overwrite table
    ${SCHEMA}.dws_risk_my_user_behavior_credit_info_df partition (grass_date = '${grass_date}')
select
    t1.credit_user_id
    ,t2.is_spl_disbursed
    ,t3.repaid_bills_num_spl
    ,t3.first_spl_disburse_time
    ,t4.is_bcl_disbursed
    ,t5.repaid_bills_num_bcl_floating
from credit_user_base t1
    left join risk_is_disbursed t2 on t1.credit_user_id = t2.credit_user_id
    left join
    (
        select
            credit_user_id
            ,repaid_bills_num_spl
            ,first_spl_disburse_time
        from credit_mart.dws_spl_my_user_risk_df
        where grass_date = '${grass_date}'
    ) t3 on t1.credit_user_id = t3.credit_user_id
    left join
    (
        select
            credit_user_id
            ,is_disbursed as is_bcl_disbursed
        from credit_mart.dws_bcl_my_user_df
        where grass_date = '${grass_date}'
    ) t4 on t1.credit_user_id = t4.credit_user_id
    left join
    (
        select
            credit_user_id
            ,repaid_bills_num_floating as repaid_bills_num_bcl_floating
        from credit_mart.dws_bcl_my_user_risk_df
        where grass_date = '${grass_date}'
    ) t5 on t1.credit_user_id = t5.credit_user_id
;