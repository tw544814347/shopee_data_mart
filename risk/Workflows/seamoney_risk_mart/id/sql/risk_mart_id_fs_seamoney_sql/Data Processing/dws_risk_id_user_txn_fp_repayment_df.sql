--********************************************************************--
-- Author:              chenyingying@shopee.com
-- Created Time:        2024-08-20
-- Theme Domain：       transaction
-- Description:         transaction financial product repayment info
-- 开发要求:             https://docs.google.com/spreadsheets/d/11Bpx701mGtwTHd0-TXZE5ickY4HHPFsVCnsui_cWuUM/edit?gid=524012195#gid=524012195
-- FS:                  https://fs.idata.shopeemobile.com/job-management/job-edit/381
-- FS:                  https://fs.idata.shopeemobile.com/job-management/job-edit/452
-- FS:                  https://fs.idata.shopeemobile.com/job-management/job-edit/680
-- Data Granularity:    platform_user_id
-- 变更历史：
-- 2024-08-27 删除了month_due_cl, month_due字段，因为业务不使用 chenyingying
-- 2024-10-10 增加了spl_max_dpd_l3m, spl_max_dpd_l12m, number_of_curr_loans, 
-- sl_max_dpd_l1m, sl_max_dpd_l2m, sl_max_dpd_l3m, sl_max_dpd_l6m, sl_max_dpd_l12m字段 chenyingying
--********************************************************************--

add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';


--drop table if exists ${SCHEMA}.dws_risk_id_user_txn_fp_repayment_df;

create external table if not exists ${SCHEMA}.dws_risk_id_user_txn_fp_repayment_df (
    platform_user_id            string comment 'platform user id'
    ,month_due_spl              bigint comment 'shopee pay later due this month'
    ,flag_existing_credit_user  bigint comment 'if exist a flag'
    ,spl_max_dpd_l3m            bigint comment 'last 3 months spl max dpd'
    ,spl_max_dpd_l12m           bigint comment 'last 12 months spl max dpd'
    ,number_of_curr_loans       bigint comment 'total number of current loans'
    ,sl_max_dpd_l1m             bigint comment 'last month sl(seller loan) max dpd'
    ,sl_max_dpd_l2m             bigint comment 'last 2 months sl max dpd'
    ,sl_max_dpd_l3m             bigint comment 'last 3 months sl max dpd'
    ,sl_max_dpd_l6m             bigint comment 'last 6 months sl max dpd'
    ,sl_max_dpd_l12m            bigint comment 'last 12 months sl max dpd'
)
partitioned by (grass_date string comment 'YYYY-MM-DD') 
stored as orc tblproperties ("orc.compress" = "zstd") 
location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_txn_fp_repayment_df/grass_region=ID' 
comment 
'
Tag:risk summary table
table description: record the user repayment in financial transaction
table source: 
credit_mart.dws_spl_id_bill_repayment_df -- 定期还款模式
credit_mart.dws_bcl_id_bill_repayment_df
credit_mart.dws_bcl_id_loan_repayment_df -- 30天还款模式，已取消
credit_mart.dws_scl_id_loan_repayment_df
marketplace.shopee_account_v2_db__account_tab__reg_daily_s0_live
credit_mart.dws_spl_id_bill_repayment_df
credit_mart.dws_scl_id_loan_repayment_df
'
;

--msck repair table ${SCHEMA}.dws_risk_id_user_txn_fp_repayment_df;

create or replace temporary view tmp_credit_user as (
    select  cast(platform_user_id as bigint) platform_user_id
            ,user_id
    from    credit.ods__credit_usercenter_member_id_db__user_activate_product_tab__df
    where grass_date = '${grass_date}'
    group by 
            cast(platform_user_id as bigint), user_id
)
;


create or replace temporary view tmp_id_af_user_tag as (
    select  cast(kredit_user_id as bigint)                                                  as kredit_user_id
            ,coalesce(count(distinct case when product_tag = 'SPL' then month_due end), 0)  as month_due_spl
    from    (
        select  credit_user_id          as kredit_user_id -- credit_user_id kredit_user_id
                ,date_format(month_due_time, 'yyyy-MM')  as month_due -- FLOOR(cast(month_due_time as date) )
                ,'SPL'                  as product_tag
        from    credit_mart.dws_spl_id_bill_repayment_df
        where   bill_term <> ''
        and     bill_term is not null
        and     principal_repayable > 0
        and     current_date > cast(month_due_time as date)
        and     grass_date = '${grass_date}'
    ) a
    group by    kredit_user_id 
)
;

create or replace temporary view tmp_feature as (
    select  platform_user_id
    , tmp_credit_user.user_id kredit_user_id
    , month_due_spl
from
    tmp_credit_user
left join 
    tmp_id_af_user_tag on tmp_credit_user.user_id = tmp_id_af_user_tag.kredit_user_id
)
;


create or replace temporary view tmp_credit_existing_list as (
    select 
    distinct platform_user_id as platform_user_id
    ,credit_user_id as credit_existing_user_list
    ,1 as flag_existing_credit_user
    from
        (select
        credit_user_id
        ,platform_user_id
        from credit_mart.dws_spl_id_bill_repayment_df
        where
        total_amount_repayable > 0
        and is_first_bill = 1
        and bill_clear_status = 4
        and to_date(grass_date, 'yyyy-MM-dd') = current_date - interval '1' day
        union all
        select
        credit_user_id
        ,platform_user_id
        from credit_mart.dws_bcl_id_loan_repayment_df
        where
        total_amount_repayable > 0
        and is_first_bill_loan = 1
        and clear_status > 1
        and to_date(grass_date, 'yyyy-MM-dd') = current_date - interval '1' day
        union all
        select
        credit_user_id
        ,platform_user_id
        from credit_mart.dws_scl_id_loan_repayment_df
        where
        total_amount_repayable > 0
        and is_first_bill_loan = 1
        and clear_status > 1
        and to_date(grass_date, 'yyyy-MM-dd') = current_date - interval '1' day
    )
)
;


create or replace temporary view tmp_spl_history as (
    select  cast(platform_user_id as bigint)    as user_id
            ,max(dpd) as spl_max_dpd_l12m
            ,max(case when cast(grass_date as date) >= current_date - interval '3' month then dpd_eod else 0 end) as spl_max_dpd_l3m
    from    credit_mart.dws_spl_id_bill_repayment_df
    where   cast(grass_date as date) >= current_date - interval '1' year
    and     total_amount_repayable > 0
    and     bill_status IN (2,3)
    group by platform_user_id
)
;

create or replace temporary view tmp_sl_history as (
    select  cast(platform_user_id as bigint) as user_id
            ,max(dpd) as sl_max_dpd_l12m
            ,max(case when cast(grass_date as date) >= current_date - interval '6' month then dpd else 0 end) as sl_max_dpd_l6m
            ,max(case when cast(grass_date as date) >= current_date - interval '3' month then dpd else 0 end) as sl_max_dpd_l3m
            ,max(case when cast(grass_date as date) >= current_date - interval '2' month then dpd else 0 end) as sl_max_dpd_l2m
            ,max(case when cast(grass_date AS DATE) >= current_date - interval '1' month then dpd else 0 end) as sl_max_dpd_l1m
    from    credit_mart.dws_scl_id_loan_repayment_df
    where   cast(grass_date as date) > current_date - interval '1' year
    and     total_amount_repayable > 0
    group by platform_user_id
)
;

create or replace temporary view tmp_sl_curr as (
    select  cast(platform_user_id as bigint)    as user_id
            ,count(distinct loan_id)            as number_of_curr_loans
    from    credit_mart.dws_scl_id_loan_repayment_df
    where   grass_date = '${ds}'
    and     clear_status <> 3
    group by platform_user_id
)
;


insert overwrite table ${SCHEMA}.dws_risk_id_user_txn_fp_repayment_df partition (grass_date = '${ds}')
select  t1.platform_user_id             as platform_user_id
        ,t3.month_due_spl               as month_due_spl
        ,t2.flag_existing_credit_user   as flag_existing_credit_user
        ,coalesce(t4.spl_max_dpd_l3m, -9999)             as spl_max_dpd_l3m
        ,coalesce(t4.spl_max_dpd_l12m, -9999)            as spl_max_dpd_l12m
        ,coalesce(t5.number_of_curr_loans, 0)        as number_of_curr_loans
        ,coalesce(t6.sl_max_dpd_l1m, -9999)             as sl_max_dpd_l1m
        ,coalesce(t6.sl_max_dpd_l2m, -9999)              as sl_max_dpd_l2m
        ,coalesce(t6.sl_max_dpd_l3m, -9999)              as sl_max_dpd_l3m 
        ,coalesce(t6.sl_max_dpd_l6m, -9999)             as sl_max_dpd_l6m 
        ,coalesce(t6.sl_max_dpd_l12m, -9999)             as sl_max_dpd_l12m
from    (
    select  userid as platform_user_id
    from    marketplace.shopee_account_v2_db__account_tab__id_df
) t1
left join 
    tmp_credit_existing_list    as t2
on  t1.platform_user_id = t2.platform_user_id
left join 
    tmp_feature          as t3
on  t1.platform_user_id = t3.platform_user_id
left join 
    tmp_spl_history     as t4 
on  t1.platform_user_id = t4.user_id
left join 
    tmp_sl_curr         as t5 
on  t1.platform_user_id = t5.user_id
left join 
    tmp_sl_history      as t6 
on  t1.platform_user_id = t6.user_id 
