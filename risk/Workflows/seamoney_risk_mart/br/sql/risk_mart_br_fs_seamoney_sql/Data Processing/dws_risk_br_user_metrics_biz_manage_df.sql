------------------------------------------------------------------------
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-06-04
-- Description:         业务维护的指标，user维度的融合成一张dws表
-- Data Granularity:    platform_user_id
-- PRD:                 
-- Version:
--          2026-04-07 - chengguo.liu - 新增credit_sp_device_v2/credit_sz_device_v2,FS迁移逻辑 https://fs.idata.shopeemobile.com/job-management/job-edit/852
------------------------------------------------------------------------


drop table if exists ${SCHEMA}.dws_risk_${region}_user_metrics_biz_manage_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_metrics_biz_manage_df (
    platform_user_id string comment 'platform_user_id'
    ,confirmed_gmv_usd_in_30d_br decimal(30, 10) comment 'Confirmed GMV USD in last 30 days'
    ,confirmed_gmv_usd_in_60d_br decimal(30, 10) comment 'Confirmed GMV USD in last 60 days'
    ,confirmed_gmv_usd_in_90d_br decimal(30, 10) comment 'Confirmed GMV USD in last 90 days'
    ,confirmed_gmv_usd_in_180d_br decimal(30, 10) comment 'Confirmed GMV USD in last 180 days'
    ,confirmed_gmv_usd_in_360d_br decimal(30, 10) comment 'Confirmed GMV USD in last 360 days'
    ,confirmed_gmv_usd_in_lifetime_br decimal(30, 10) comment 'Confirmed GMV USD in lifetime'
    ,confirmed_order_in_30d_br bigint comment 'Confirmed order in last 30 days'
    ,confirmed_order_in_60d_br bigint comment 'Confirmed order in last 60 days'
    ,confirmed_order_in_90d_br bigint comment 'Confirmed order in last 90 days'
    ,confirmed_order_in_180d_br bigint comment 'Confirmed order in last 180 days'
    ,confirmed_order_in_360d_br bigint comment 'Confirmed order in last 360 days'
    ,confirmed_order_in_lifetime_br bigint comment 'Confirmed order in lifetime'
    ,pctg_of_cc__order_in_30d_br double comment 'Percentage of cc installment orders in last 30 days'
    ,pctg_of_cc__order_in_90d_br double comment 'Percentage of cc installment orders in last 90 days'
    ,pctg_of_cc__order_in_180d_br double comment 'Percentage of cc installment orders in last 180 days'
    ,pctg_of_cc__order_in_360d_br double comment 'Percentage of cc installment orders in last 360 days'
    ,pctg_of_cc__order_in_lifetime_br double comment 'Percentage of cc installment orders in lifetime'
    ,pctg_of_cc__gmv_in_30d_br double comment 'Percentage of cc installment gmv in last 30 days'    
    ,pctg_of_cc__gmv_in_90d_br double comment 'Percentage of cc installment gmv in last 90 days'
    ,pctg_of_cc__gmv_in_180d_br double comment 'Percentage of cc installment gmv in last 180 days'
    ,pctg_of_cc__gmv_in_360d_br double comment 'Percentage of cc installment gmv in last 360 days'
    ,pctg_of_cc__gmv_in_lifetime_br double comment 'Percentage of cc installment gmv in lifetime'
    ,abs_usd_in_30d_br decimal(30, 10) comment 'ABS of confirmed orders in last 30 days'
    ,abs_usd_in_90d_br decimal(30, 10) comment 'ABS of confirmed orders in last 90 days'
    ,abs_usd_in_180d_br decimal(30, 10) comment 'ABS of confirmed orders in last 180 days'
    ,abs_usd_in_360d_br decimal(30, 10) comment 'ABS of confirmed orders in last 360 days'
    ,abs_usd_in_lifetime_br decimal(30, 10) comment 'ABS of confirmed orders in lifetime'
    ,linked_overdue_phone_reg_reg bigint comment 'linked to HPD60 user'
    ,linked_overdue_phone_reg_mp bigint comment 'linked to HPD60 user'
    ,linked_overdue_phone_reg_ec bigint comment 'linked to HPD60 user'
    ,linked_overdue_phone_mp_mp bigint comment 'linked to HPD60 user'
    ,linked_overdue_phone_mp_reg bigint comment 'linked to HPD60 user'
    ,linked_overdue_phone_mp_ec bigint comment 'linked to HPD60 user'
    ,linked_overdue_phone_ec_ec bigint comment 'linked to HPD60 user'
    ,linked_overdue_phone_ec_reg bigint comment 'linked to HPD60 user'
    ,linked_overdue_phone_ec_mp bigint comment 'linked to HPD60 user'
    ,lending_count bigint comment 'lending count'
    ,uninstall_loan_last30 bigint comment 'uninstalled loan app count in last 30 days'
    ,is_shopee_fraud_tag_fes bigint comment 'is shopee fraud tag fes'
    ,login_days_in_30d bigint comment 'login days in last 30 days'
    ,login_days_in_60d bigint comment 'login days in last 60 days'
    ,login_days_in_90d bigint comment 'login days in last 90 days'
    ,login_days_in_360d bigint comment 'login days in last 360 days'
    ,community_id string comment 'community id'
    ,credit_sp_device_v2 string comment 'credit sp device v2'
    ,credit_sz_device_v2 string comment 'credit sz device v2'
)
partitioned by
    (grass_date string comment "YYYY-MM-DD") stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_metrics_biz_manage_df/grass_region=${grass_region}'
;
msck repair table ${SCHEMA}.dws_risk_${region}_user_metrics_biz_manage_df;

create or replace temporary view overdue as (
    select
        data as platform_user_id
    from smcdrisk_antifraud.br_blacklist_overdue
    where datatype = 'shopeeAccount'
)
;

create or replace temporary view linked_overdue_aggregated as (
select 
    t1.platform_user_id,
    max(case when t2.linkage_type = 'phone_reg_reg' then 1 else 0 end) as linked_overdue_phone_reg_reg,
    max(case when t2.linkage_type = 'phone_reg_mp' then 1 else 0 end) as linked_overdue_phone_reg_mp,
    max(case when t2.linkage_type = 'phone_reg_ec' then 1 else 0 end) as linked_overdue_phone_reg_ec,
    max(case when t2.linkage_type = 'phone_mp_mp' then 1 else 0 end) as linked_overdue_phone_mp_mp,
    max(case when t2.linkage_type = 'phone_mp_reg' then 1 else 0 end) as linked_overdue_phone_mp_reg,
    max(case when t2.linkage_type = 'phone_mp_ec' then 1 else 0 end) as linked_overdue_phone_mp_ec,
    max(case when t2.linkage_type = 'phone_ec_ec' then 1 else 0 end) as linked_overdue_phone_ec_ec,
    max(case when t2.linkage_type = 'phone_ec_reg' then 1 else 0 end) as linked_overdue_phone_ec_reg,
    max(case when t2.linkage_type = 'phone_ec_mp' then 1 else 0 end) as linked_overdue_phone_ec_mp
from (
    select  userid
            ,userid2
            ,linkage_type
    from rescbds_credit.rescbds_credit_prod_${region}__user_graph_linkage_info
    where grass_date = (select max(grass_date) from rescbds_credit.rescbds_credit_prod_${region}__user_graph_linkage_info)
) t2
inner join overdue t1 
on t1.platform_user_id = t2.userid2 
where linkage_type in ('phone_reg_reg', 'phone_reg_mp', 'phone_reg_ec', 
                     'phone_mp_mp', 'phone_mp_reg', 'phone_mp_ec',
                     'phone_ec_ec', 'phone_ec_reg', 'phone_ec_mp')
group by t1.platform_user_id
);

create or replace temporary view user_login_info as (
    select  userid as platform_user_id
            ,coalesce(login_days_in_30d, 0) as login_days_in_30d
            ,coalesce(login_days_in_60d, 0) as login_days_in_60d
            ,coalesce(login_days_in_90d, 0) as login_days_in_90d
            ,coalesce(login_days_in_360d, 0) as login_days_in_360d
        from smcdrisk_policy.br_order_fs_tmp_607
);

insert overwrite table
    ${SCHEMA}.dws_risk_${region}_user_metrics_biz_manage_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id
    ,coalesce(t2.confirmed_gmv_usd_in_30d, 0) as confirmed_gmv_usd_in_30d_br
    ,coalesce(t2.confirmed_gmv_usd_in_60d, 0) as confirmed_gmv_usd_in_60d_br
    ,coalesce(t2.confirmed_gmv_usd_in_90d, 0) as confirmed_gmv_usd_in_90d_br
    ,coalesce(t2.confirmed_gmv_usd_in_180d, 0) as confirmed_gmv_usd_in_180d_br
    ,coalesce(t2.confirmed_gmv_usd_in_360d, 0) as confirmed_gmv_usd_in_360d_br
    ,coalesce(t2.confirmed_gmv_usd_in_lifetime, 0) as confirmed_gmv_usd_in_lifetime_br
    ,coalesce(t2.confirmed_order_in_30d, 0) as confirmed_order_in_30d_br
    ,coalesce(t2.confirmed_order_in_60d, 0) as confirmed_order_in_60d_br
    ,coalesce(t2.confirmed_order_in_90d, 0) as confirmed_order_in_90d_br
    ,coalesce(t2.confirmed_order_in_180d, 0) as confirmed_order_in_180d_br
    ,coalesce(t2.confirmed_order_in_360d, 0) as confirmed_order_in_360d_br
    ,coalesce(t2.confirmed_order_in_lifetime, 0) as confirmed_order_in_lifetime_br
    ,coalesce(t2.pctg_of_cc__order_in_30d, -1) as pctg_of_cc__order_in_30d_br
    ,coalesce(t2.pctg_of_cc__order_in_90d, -1) as pctg_of_cc__order_in_90d_br
    ,coalesce(t2.pctg_of_cc__order_in_180d, -1) as pctg_of_cc__order_in_180d_br
    ,coalesce(t2.pctg_of_cc__order_in_360d, -1) as pctg_of_cc__order_in_360d_br
    ,coalesce(t2.pctg_of_cc__order_in_lifetime, -1) as pctg_of_cc__order_in_lifetime_br
    ,coalesce(t2.pctg_of_cc__gmv_in_30d, -1) as pctg_of_cc__gmv_in_30d_br
    ,coalesce(t2.pctg_of_cc__gmv_in_90d, -1) as pctg_of_cc__gmv_in_90d_br
    ,coalesce(t2.pctg_of_cc__gmv_in_180d, -1) as pctg_of_cc__gmv_in_180d_br
    ,coalesce(t2.pctg_of_cc__gmv_in_360d, -1) as pctg_of_cc__gmv_in_360d_br
    ,coalesce(t2.pctg_of_cc__gmv_in_lifetime, -1) as pctg_of_cc__gmv_in_lifetime_br
    ,coalesce(t2.abs_usd_in_30d, 0) as abs_usd_in_30d_br
    ,coalesce(t2.abs_usd_in_90d, 0) as abs_usd_in_90d_br
    ,coalesce(t2.abs_usd_in_180d, 0) as abs_usd_in_180d_br
    ,coalesce(t2.abs_usd_in_360d, 0) as abs_usd_in_360d_br
    ,coalesce(t2.abs_usd_in_lifetime, 0) as abs_usd_in_lifetime_br
    ,coalesce(t3.linked_overdue_phone_reg_reg, 0) as linked_overdue_phone_reg_reg
    ,coalesce(t3.linked_overdue_phone_reg_mp, 0) as linked_overdue_phone_reg_mp
    ,coalesce(t3.linked_overdue_phone_reg_ec, 0) as linked_overdue_phone_reg_ec
    ,coalesce(t3.linked_overdue_phone_mp_mp, 0) as linked_overdue_phone_mp_mp
    ,coalesce(t3.linked_overdue_phone_mp_reg, 0) as linked_overdue_phone_mp_reg
    ,coalesce(t3.linked_overdue_phone_mp_ec, 0) as linked_overdue_phone_mp_ec
    ,coalesce(t3.linked_overdue_phone_ec_ec, 0) as linked_overdue_phone_ec_ec
    ,coalesce(t3.linked_overdue_phone_ec_reg, 0) as linked_overdue_phone_ec_reg
    ,coalesce(t3.linked_overdue_phone_ec_mp, 0) as linked_overdue_phone_ec_mp
    ,t4.lending_cnt as lending_count
    ,t4.off_last30_cnt as uninstall_loan_last30
    ,coalesce(t5.is_shopee_fraud_tag_fes, 0) as is_shopee_fraud_tag_fes
    ,t6.login_days_in_30d
    ,t6.login_days_in_60d
    ,t6.login_days_in_90d
    ,t6.login_days_in_360d
    ,t7.community_id
    ,t8.credit_sp_device_v2
    ,t8.credit_sz_device_v2
from
    (
        select
            platform_user_id
        from risk.dim_risk_${region}_user_info_df
        where grass_date = '${grass_date}'
    ) t1
    left join smcdrisk_policy.br_order_fs_tmp_0222 t2 on t1.platform_user_id = t2.userid
    left join linked_overdue_aggregated t3 on t1.platform_user_id = t3.platform_user_id
    left join smcdrisk_antifraud.fs_br_applist t4 on t1.platform_user_id = t4.user_id
    left join
    (
        select  userid as platform_user_id
                ,1 as is_shopee_fraud_tag_fes
        from smcdrisk_antifraud.br_shopee_fraud_tag
        where grass_date = (select max(grass_date) from smcdrisk_antifraud.br_shopee_fraud_tag)
        group by userid
    ) t5 on t1.platform_user_id = t5.platform_user_id
    left join user_login_info t6 on t1.platform_user_id = t6.platform_user_id
    left join (
        select  platform_user_id
                ,community_id
        from regsm_riskmgmt.user_graph_community_risk_antifraud_v1
        where grass_region = '${grass_region}'
        and grass_date = (select max(grass_date) from regsm_riskmgmt.user_graph_community_risk_antifraud_v1 where grass_region = '${grass_region}')
    ) t7 on t1.platform_user_id = t7.platform_user_id
    left join (
        select
            platform_user_id
            ,max(df_list) as credit_sp_device_v2
            ,max(szdf_list) as credit_sz_device_v2
        from smcdrisk_antifraud.credit_device_br_v2
        where grass_date = (select max(grass_date) from smcdrisk_antifraud.credit_device_br_v2)
        group by platform_user_id
    ) t8 on t1.platform_user_id = t8.platform_user_id
;