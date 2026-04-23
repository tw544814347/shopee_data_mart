--********************************************************************--
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2024-05-08
-- Theme Domain：       user behavior info
-- Description:         不从credit behavior mart取，risk个性化计算的feature
-- Data Granularity:    credit_user_id
-- 变更历史：
--********************************************************************--

insert overwrite table
    ${SCHEMA}.dws_risk_user_behavior_credit_info_df partition (grass_region = 'ID', grass_date = '${ds}')
select
    t1.credit_user_id
    ,t2.is_spl_disbursed
    ,t2.is_chp_disbursed
from
    (
        select
            credit_user_id
        from credit_uc.dwd_aio_id_uc_user_df
        where grass_date = '${grass_date}'
        group by credit_user_id
    ) t1
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
                from credit_mart.dwd_spl_aio_id_plan_df
                where grass_date = '${grass_date}'
                group by 1, 2
            ) t
        group by credit_user_id
    ) t2 on t1.credit_user_id = t2.credit_user_id
;