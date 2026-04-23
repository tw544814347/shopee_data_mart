--drop table if exists ${SCHEMA}.dws_risk_my_user_txn_fp_repayment_df;
create external table if not exists ${SCHEMA}.dws_risk_my_user_txn_fp_repayment_df (
    shop_id                     string comment 'shop_id'
    ,platform_user_id            string comment 'platform user id'
    ,spl_max_dpd_l1m            bigint comment 'last 1 months spl max dpd'
    ,spl_max_dpd_l2m            bigint comment 'last 2 months spl max dpd'
    ,spl_max_dpd_l3m            bigint comment 'last 3 months spl max dpd'
    ,spl_max_dpd_l6m            bigint comment 'last 6 months spl max dpd'
    ,spl_max_dpd_l12m           bigint comment 'last 12 months spl max dpd'
    ,sl_max_dpd_l1m             bigint comment 'last 1 months sl max dpd'
    ,sl_max_dpd_l2m             bigint comment 'last 2 months sl max dpd'
    ,sl_max_dpd_l3m             bigint comment 'last 3 months sl max dpd'
    ,sl_max_dpd_l6m             bigint comment 'last 6 months sl max dpd'
    ,sl_max_dpd_l12m             bigint comment 'last 12 months sl max dpd'
)
partitioned by (grass_date string comment 'YYYY-MM-DD') 
stored as orc tblproperties ("orc.compress" = "zstd") 
location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_txn_fp_repayment_df/grass_region=${grass_region}'
;
--msck repair table ${SCHEMA}.dws_risk_my_user_txn_fp_repayment_df;


create or replace temporary view spl_history_dpd_features as (
    select  platform_user_id
     		,max(case when cast(grass_date as date) >= current_date - interval '1' month then dpd else 0 end) as spl_max_dpd_l1m
            ,max(case when cast(grass_date as date) >= current_date - interval '2' month then dpd else 0 end) as spl_max_dpd_l2m
            ,max(case when cast(grass_date as date) >= current_date - interval '3' month then dpd else 0 end) as spl_max_dpd_l3m
            ,max(case when cast(grass_date as date) >= current_date - interval '6' month then dpd else 0 end) as spl_max_dpd_l6m
            ,max(dpd) as spl_max_dpd_l12m
    from    credit_mart.dws_spl_my_bill_repayment_df
    where   cast(grass_date as date) >= current_date - interval '1' year
    and     total_amount_repayable > 0
    and     bill_status = 2
    group by platform_user_id
)
;

create or replace temporary view sl_history_dpd_features as (
    select  platform_user_id
     		,max(case when cast(grass_date as date) >= current_date - interval '1' month then dpd else 0 end) as sl_max_dpd_l1m
            ,max(case when cast(grass_date as date) >= current_date - interval '2' month then dpd else 0 end) as sl_max_dpd_l2m
            ,max(case when cast(grass_date as date) >= current_date - interval '3' month then dpd else 0 end) as sl_max_dpd_l3m
            ,max(case when cast(grass_date as date) >= current_date - interval '6' month then dpd else 0 end) as sl_max_dpd_l6m
            ,max(dpd) as sl_max_dpd_l12m
    from    credit_mart.dws_scl_my_loan_repayment_df 
    where   cast(grass_date as date) >= current_date - interval '1' year
    and     total_amount_repayable > 0
    group by platform_user_id
)
;

insert overwrite table ${SCHEMA}.dws_risk_my_user_txn_fp_repayment_df partition(grass_date = '${grass_date}')
select
    t1.shop_id
    ,t1.platform_user_id
    ,coalesce(t2.spl_max_dpd_l1m, -9999) as spl_max_dpd_l1m
    ,coalesce(t2.spl_max_dpd_l2m, -9999) as spl_max_dpd_l2m
    ,coalesce(t2.spl_max_dpd_l3m, -9999) as spl_max_dpd_l3m
    ,coalesce(t2.spl_max_dpd_l6m, -9999) as spl_max_dpd_l6m
    ,coalesce(t2.spl_max_dpd_l12m, -9999) as spl_max_dpd_l12m
    ,coalesce(t3.sl_max_dpd_l1m, -9999) as sl_max_dpd_l1m
    ,coalesce(t3.sl_max_dpd_l2m, -9999) as sl_max_dpd_l2m
    ,coalesce(t3.sl_max_dpd_l3m, -9999) as sl_max_dpd_l3m
    ,coalesce(t3.sl_max_dpd_l6m, -9999) as sl_max_dpd_l6m
    ,coalesce(t3.sl_max_dpd_l12m, -9999) as sl_max_dpd_l12m
from
(
    select
        shop_id
        ,user_id as platform_user_id
    from mp_user.dim_shop__reg_s0_live
    where
        tz_type = 'local'
        and grass_region = '${grass_region}'
        and grass_date = '${grass_date}'
) t1
left join spl_history_dpd_features t2 on t1.platform_user_id = t2.platform_user_id
left join sl_history_dpd_features t3 on t1.platform_user_id = t3.platform_user_id
;



