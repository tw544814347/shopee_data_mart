--********************************************************************--
-- Author:              chenyingying@shopee.com
-- Created Time:        2024-08-20
-- Theme Domain：       dpd
-- Description:         anti-fraud dpd in graph info https://docs.google.com/spreadsheets/d/11Bpx701mGtwTHd0-TXZE5ickY4HHPFsVCnsui_cWuUM/edit?gid=524012195#gid=524012195
-- Data Granularity:    platform_user_id
-- 变更历史：

--********************************************************************--
add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';


--drop table if exists ${SCHEMA}.dws_risk_id_user_af_graph_dpd_df;
create external table if not exists ${SCHEMA}.dws_risk_id_user_af_graph_dpd_df  (
    platform_user_id                    string comment 'platform user id'
    ,cnt_ba_link_dpd30_all              bigint comment 'bank account related dpd in 30 days'
    ,cnt_email_link_dpd30_all           bigint comment 'email related dpd in 30 days'
    ,cnt_szdf_90d_all_link_dpd30_all    bigint comment 'szdf_90days related dpd in 30 days'
)
partitioned by (
    grass_date                          string comment 'yyyy-MM-dd',
    grass_region                        string comment 'ID'
)
stored as orc tblproperties ("orc.compress"="zstd") 
location  '${HDFS_PATH}/risk_mart/dws/dws_risk_user_af_graph_dpd_df/grass_region=ID'
comment '
table description: record the graph info of the dpd user in anti-fraud field 
table source:
marketplace.shopee_account_v2_db__account_tab__reg_daily_s0_live
rescbds_credit.rescbds_credit_prod_id__user_graph_linkage_info
mp_order.dwd_order_all_ent_df__reg_s0_live
mp_user.dim_user__reg_s0_live 
';
--msck repair table ${SCHEMA}.dws_risk_id_user_af_graph_dpd_df;

create or replace temporary view tmp_base as (
    select 
    userid as userid -- corresponding to the user id in rescbds_credit.rescbds_credit_prod_id__user_graph_linkage_info
    from marketplace.shopee_account_v2_db__account_tab__id_df
);

-- optimization
create or replace temporary view tmp_ds as (
    select  linkage_type
            ,userid -- platform_user_id
            ,userid2
    from    rescbds_credit.rescbds_credit_prod_id__user_graph_linkage_info
        -- 5天以内
    where   grass_date = (
                            select  max(grass_date) 
                            from    rescbds_credit.rescbds_credit_prod_id__user_graph_linkage_info 
                            --where   grass_date >= current_date - interval '5' day
                        ) 
    and     linkage_type in ('bankAccount','email', 'SZDF_all_90days') 
    -- where   rn = 1
);

-- 取消了deduplicated
create or replace temporary view tmp_dft as (
    select  distinct platform_user_id   as platform_user_id
    from    (
        select  platform_user_id
        from    credit_mart.dws_spl_id_bill_repayment_df
        where   cast(grass_date as date) between current_date - interval '30' day 
        and     current_date - interval '1' day
        -- datediff(date(grass_date), date('${ds}')) <= 30
        -- time-wasted
        and     total_amount_repayable > 0
        and     dpd >= 30
        union all
        select  platform_user_id
        from    credit_mart.dws_bcl_id_loan_repayment_df
        where   cast(grass_date as date) between current_date - interval '30' day 
        and     current_date - interval '1' day 
        --datediff(date(grass_date), date('${ds}')) <= 30
        and     total_amount_repayable > 0
        and     dpd >= 30
        union all 
        select  platform_user_id
        from    credit_mart.dws_scl_id_loan_repayment_df
        where   cast(grass_date as date) between current_date - interval '30' day and current_date - interval '1' day
        -- datediff(date(grass_date), date('${ds}')) <= 30
        and     total_amount_repayable > 0
        and     dpd >= 30
    ) a
);


insert overwrite table ${SCHEMA}.dws_risk_id_user_af_graph_dpd_df partition (grass_date, grass_region)
select  userid                                          as platform_user_id
        ,nvl(sum(cnt_ba_link_dpd30_all),0)              as cnt_ba_link_dpd30_al
        ,nvl(sum(cnt_email_link_dpd30_all),0)           as cnt_email_link_dpd30_all
        ,nvl(sum(cnt_szdf_90d_all_link_dpd30_all),0)    as cnt_szdf_90d_all_link_dpd30_all
        ,'${ds}'                                        as grass_date
        ,'ID'                                           as grass_region
from    (
    select  tmp_base.userid
            ,count(distinct case    when linkage_type='bankAccount' then platform_user_id end) as cnt_ba_link_dpd30_all
            ,0                                                                                 as cnt_email_link_dpd30_all
            ,0                                                                                 as cnt_szdf_90d_all_link_dpd30_all
    from    tmp_base 
    left join 
            tmp_ds
    on      tmp_ds.userid=tmp_base.userid
    left join 
            tmp_dft 
    on      tmp_ds.userid2 = tmp_dft.platform_user_id
    group by 
            tmp_base.userid
    union all
    select  tmp_base.userid
            ,0                                                                                 as cnt_ba_link_dpd30_all
            ,count( distinct case when linkage_type='email' then platform_user_id end)         as cnt_email_link_dpd30_all
            ,0                                                                                 as cnt_szdf_90d_all_link_dpd30_all
    from    tmp_base 
    left join 
            tmp_ds
    on      tmp_ds.userid=tmp_base.userid
    left join 
            tmp_dft 
    on      tmp_ds.userid2 = tmp_dft.platform_user_id
    group by 
            tmp_base.userid
    union all
    select  tmp_base.userid
    ,0                                                                                         as cnt_ba_link_dpd30_all
    ,0                                                                                         as cnt_email_link_dpd30_all
    ,count( distinct case when linkage_type='SZDF_all_90days' then platform_user_id end)       as cnt_szdf_90d_all_link_dpd30_all
    from    tmp_base 
    left join 
            tmp_ds
    on      tmp_ds.userid=tmp_base.userid
    left join 
            tmp_dft 
    on      tmp_ds.userid2 = tmp_dft.platform_user_id
    group by 
            tmp_base.userid
) a                                            
group by a.userid
;


