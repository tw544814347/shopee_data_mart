------------------------------------------------------------------------
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2024-03-06
-- Description:         ID Local BI 外数需求，查看用户是否已经有credit放款，包括SPL/BCL/SCL/FES
-- Data Granularity:    id_card_no
-- PRD:                 
-- Jira:                https://jira.shopee.io/browse/SPFDT-33269
------------------------------------------------------------------------

drop table if exists ${SCHEMA}.tmp_dws_risk_user_disbursed_spl_cl_df;
create table ${SCHEMA}.tmp_dws_risk_user_disbursed_spl_cl_df stored as orc as
select
    credit_user_id
    ,loan_id
from
    (
        select
            credit_user_id
            ,loan_id
        from credit_mart.dws_bcl_id_loan_repayment_df a
        where grass_date = '${grass_date}'
        union
        select
            credit_user_id
            ,loan_id
        from credit_mart.dws_scl_id_loan_repayment_df a
        where grass_date = '${grass_date}'
        union
        select
            credit_user_id
            ,loan_id
        from credit_mart.dws_mcl_id_loan_repayment_df a
        where grass_date = '${grass_date}'
        union
        select
            t1.credit_user_id
            ,t1.loan_id
        from
            credit_mart.dws_spl_id_loan_repayment_df t1
            inner join idecbi_compliance.ec_shopee_user_loan_dwd__ldn_spl_p2p_list_td t2 on t1.loan_id = t2.loan_id
        where
            t1.grass_date = '${grass_date}'
            and date(t1.confirm_time) > date '2019-03-01'
    )
group by credit_user_id, loan_id
;

drop table if exists ${SCHEMA}.tmp_dws_risk_user_disbursed_fes_df;
create table ${SCHEMA}.tmp_dws_risk_user_disbursed_fes_df stored as orc as
select
    t2.fast_escrow_user_id as credit_user_id
    ,t1.fast_escrow_group_id as loan_id
from
    credit_mart.dwd_fes_id_instalment_repayment_df t1
    inner join (
        select
            fast_escrow_user_id
            ,platform_user_id
        from credit_mart.dim_fes_id_seller_info_df
        where grass_date = '${grass_date}'
    ) t2 on t1.platform_user_id = t2.platform_user_id
where
    t1.grass_date = '${grass_date}'
    and t1.principal_repayable > 0
    and t1.actual_disbursed_time is not null
    and t1.actual_disbursed_time <> '0'
group by t2.fast_escrow_user_id, t1.fast_escrow_group_id
;

drop table if exists ${SCHEMA}.tmp_dws_risk_user_disbursed_df;
create table ${SCHEMA}.tmp_dws_risk_user_disbursed_df stored as orc as
select
    t1.credit_user_id
from
    (
        select
            credit_user_id
            ,loan_id
        from ${SCHEMA}.tmp_dws_risk_user_disbursed_spl_cl_df
        union
        select
            credit_user_id
            ,loan_id
        from ${SCHEMA}.tmp_dws_risk_user_disbursed_fes_df
    ) t1
    left join idecbi_compliance.ec_shopee_testing_loans_daily t2 on t1.loan_id = t2.loan_id
where t2.loan_id is null
group by t1.credit_user_id
;

drop table if exists ${SCHEMA}.tmp_dws_risk_user_id_card_no_df;
create table ${SCHEMA}.tmp_dws_risk_user_id_card_no_df stored as orc as
select
    credit_user_id
    ,id_card_no
from
    (
        select
            credit_user_id
            ,id_card_no
            ,rank() over (
                partition by credit_user_id
                order by first_activation_time desc
            ) rnk
        from
            (
                select
                    credit_user_id
                    ,id_card_no
                    ,first_activation_time
                from credit_uc.dws_bcl_id_uc_user_df
                where grass_date = '${grass_date}'
                union
                select
                    credit_user_id
                    ,id_card_no
                    ,first_activation_time
                from credit_uc.dws_scl_id_uc_user_df
                where grass_date = '${grass_date}'
                union
                select
                    credit_user_id
                    ,id_card_no
                    ,first_activation_time
                from credit_uc.dws_mcl_id_uc_user_df
                where grass_date = '${grass_date}'
                union
                select
                    credit_user_id
                    ,id_card_no
                    ,first_activation_time
                from credit_uc.dws_fes_id_uc_user_df
                where grass_date = '${grass_date}'
                union
                select
                    credit_user_id
                    ,id_card_no
                    ,first_activation_time
                from credit_uc.dws_spl_id_uc_user_df
                where grass_date = '${grass_date}'
            )
        where first_activation_time is not null
    )
where rnk = 1
;

insert overwrite table ${SCHEMA}.ads_risk_id_user_third_party_report_info_df partition (grass_date = '${grass_date}')
select
    t1.id_card_no
    ,if(t2.credit_user_id is not null, 1, 0) as has_fdc_reported
from
    ${SCHEMA}.tmp_dws_risk_user_id_card_no_df t1
    left join ${SCHEMA}.tmp_dws_risk_user_disbursed_df t2 on t1.credit_user_id = t2.credit_user_id
;