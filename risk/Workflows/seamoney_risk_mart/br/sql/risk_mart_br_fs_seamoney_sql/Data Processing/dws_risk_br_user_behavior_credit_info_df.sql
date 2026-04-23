--drop table if exists ${SCHEMA}.dws_risk_br_user_behavior_credit_info_df;
create table if not exists ${SCHEMA}.dws_risk_br_user_behavior_credit_info_df (
    credit_user_id string comment 'credit_user_id'
    ,is_bcl_disbursed bigint
    ,is_spl_disbursed bigint
)
partitioned by
    (grass_date string comment 'grass_date, partition key') stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_behavior_credit_info_df/grass_region=BR'
;
--msck repair table ${SCHEMA}.dws_risk_br_user_behavior_credit_info_df;

create or replace temporary view dws_spl_is_disbursed as
select
    t1.credit_user_id
    ,t1.is_spl_disbursed
from (
        select
            credit_user_id
            ,max(case when spl_disbursed_amount > 0 then 1 else null end) as is_spl_disbursed
        from
            (
                select
                    credit_user_id
                    ,loan_id
                    ,sum(case when biz_type = 3 then principal_repayable - principal_refund else null end) as spl_disbursed_amount
                from credit_mart.dws_spl_br_instalment_repayment_df
                where grass_date = '${grass_date}'
                group by 1, 2
            ) t
        group by credit_user_id
    ) t1
;


insert overwrite table ${SCHEMA}.dws_risk_br_user_behavior_credit_info_df partition (grass_date = '${grass_date}')
select
    t1.credit_user_id
    ,t2.is_bcl_disbursed
    ,t3.is_spl_disbursed
from
    (
        select
            credit_user_id
        from credit_uc.dws_aio_br_uc_user_df
        where grass_date = '${grass_date}'
        group by credit_user_id
    ) t1
    left join (
        select
            credit_user_id
            ,is_disbursed as is_bcl_disbursed
        from credit_mart.dws_bcl_br_user_df
        where grass_date = '${grass_date}'
    ) t2 on t1.credit_user_id = t2.credit_user_id
    left join dws_spl_is_disbursed t3 on t1.credit_user_id = t3.credit_user_id
;