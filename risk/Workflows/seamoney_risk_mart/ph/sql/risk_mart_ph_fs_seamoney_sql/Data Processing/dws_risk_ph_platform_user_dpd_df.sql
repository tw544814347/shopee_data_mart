create external table if not exists ${SCHEMA}.dws_risk_${region}_platform_user_dpd_df (
    platform_user_id string comment 'platform_user_id'
    ,month_due_cnt bigint comment 'count the month of all credit dued'
    ,month_due_spl_cnt bigint comment 'count the month of SPL dued'
) partitioned by (
    grass_date string comment "YYYY-MM-DD"
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location '${HDFS_PATH}/risk_mart/dim/dws_risk_reg_platform_user_dpd_df/garss_region=${upper_region}'
;


insert overwrite table ${SCHEMA}.dws_risk_${region}_platform_user_dpd_df partition (grass_date = '${grass_date}')
select
    platform_user_id
    ,count(distinct month_due) month_due_cnt
    ,count(distinct case when product_tag = 'SPL' then month_due end) month_due_spl_cnt
from
    (
        select
            platform_user_id
            ,trunc(month_due_time, 'MONTH') as month_due
            ,'SPL' product_tag
        from credit_mart.dws_spl_ph_bill_repayment_df
        where grass_date = '${grass_date}'
            and COALESCE(bill_term, '') <> ''
            and principal_repayable > 0
            and '${current_grass_date}' > cast(month_due_time as date)
    ) a
group by platform_user_id
;


