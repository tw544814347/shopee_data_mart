--drop table if exists ${SCHEMA}.dws_risk_th_user_txn_fp_repayment_df;
create external table if not exists ${SCHEMA}.dws_risk_th_user_txn_fp_repayment_df (
    platform_user_id string comment 'platform user id'
    ,month_due_spl bigint comment 'month_due_spl'
)
partitioned by
    (grass_date string comment 'YYYY-MM-DD') stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_txn_fp_repayment_df/grass_region=TH'
;

--msck repair table ${SCHEMA}.dws_risk_th_user_txn_fp_repayment_df;
----
create temporary view view_spl_repayment as
select
    platform_user_id
    ,count(distinct month_due) month_due_cnt
    ,count(
        distinct case
            when product_tag = 'SPL' then month_due
        end
    ) month_due_spl
from
    (
        select
            platform_user_id
            ,trunc(month_due_time, 'MONTH') as month_due
            ,'SPL' product_tag
        from credit_mart.dws_spl_th_bill_repayment_df
        where
            grass_date = '${grass_date}'
            and coalesce(bill_term, '') <> ''
            and principal_repayable > 0
            and '${current_grass_date}' > cast(month_due_time as date)
    ) a
group by platform_user_id
;

insert overwrite table ${SCHEMA}.dws_risk_th_user_txn_fp_repayment_df partition (grass_date = '${ds}')
select
    t1.platform_user_id
    ,t2.month_due_spl
from
    (
        select
            platform_user_id
        from ${SCHEMA}.dim_risk_th_user_info_df
        where grass_date = '${grass_date}'
    ) t1
    left join view_spl_repayment t2 on t1.platform_user_id = t2.platform_user_id
;