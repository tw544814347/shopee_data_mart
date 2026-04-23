------------------------------------------------------------------------
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2024-09-03
-- Description:         业务维护的指标，user维度的融合成一张dws表
-- Data Granularity:    platform_user_id
-- PRD:                 https://docs.google.com/spreadsheets/d/11Bpx701mGtwTHd0-TXZE5ickY4HHPFsVCnsui_cWuUM/edit?gid=2074508871#gid=2074508871    
--Version:
--      2025-08-11,跟业务确认，下线smcdrisk_antifraud.id_mta_user_rule_info_v1表相关feature
--      2025-09-11 新增is_account_recovery by zhicheng.chen
--      2026-01-12 新增 marker 依赖 by wei.tao
--      2026-02-18 chengguo.liu, 已跟jinglei确认hit_overdue_network_id下线处理
------------------------------------------------------------------------
-- drop table if exists ${SCHEMA}.dws_risk_id_user_metrics_biz_manage_df;
create external table if not exists ${SCHEMA}.dws_risk_id_user_metrics_biz_manage_df (
    platform_user_id string comment 'platform_user_id'
    ,shop_id string comment 'shop_id'
    ,af_blacklist_color_tag  string comment '欺诈标签, Grey、Black、空值'
    ,af_blacklist_color_sub_category_tag string comment '欺诈标签, subcategory 分类： 1）Overdue 2）Device Concentration 3）Cash-out 4）Shopee Fraud Tag 5）ATO'
    ,lite_limit_expire_flag  bigint comment 'lite_limit_expire_flag'
    ,none_buyer_l7d  boolean comment 'flag of no buyer in last 7 days'
    ,none_gmv_l7d    boolean comment 'flag of no GMV in last 7 days'
    ,none_buyer_l3d  boolean comment 'flag of no buyer in last 3 days'
    ,spl_hist_dpd_30 boolean comment 'flag of SPL dpd30+ ever'
    ,cnt_hit_blacklist_sme   bigint comment 'the number of hit times of seller blacklist'
    ,bad_user_group_ds   bigint comment 'the user fall in the bad group defined by DS team'  --待下线，新featurre hit_rule_bad_user_in_cluster
    ,phone_book_cluster_blacklist_1  bigint comment 'user tag for phone book cluster blacklist maintained by DS team'
    ,hit_ds_community_tag_l14d_v2    bigint comment 'hit_ds_community_tag_l14d_v2'
    ,hit_ds_community_tag_l7d_v2 bigint comment 'hit_ds_community_tag_l7d_v2'  --待下线，新feature hit_rule_bad_user_in_cluster_l7d
    ,hit_ds_community_tag_l14d   bigint comment 'hit_ds_community_tag_l14d'  --待下线，新feature hit_rule_bad_user_in_cluster_l14d
    ,hit_ds_community_tag_l7d    bigint comment 'hit_ds_community_tag_l7d'
    ,cash_out_tag    bigint comment 'cash_out_tag'
    ,hit_rule_bad_user_in_cluster bigint comment 'hit_rule_bad_user_in_cluster'
    ,hit_rule_bad_user_in_cluster_l7d bigint comment 'hit_rule_bad_user_in_cluster_l7d'
    ,hit_rule_bad_user_in_cluster_l14d bigint comment 'hit_rule_bad_user_in_cluster_l14d'
    ,abnormal_ratio_in_cluster double comment 'abnormal_ratio_in_cluster'
    ,is_account_recovery int comment 'is account recovery'
)
partitioned by (grass_date string comment "YYYY-MM-DD") 
stored as orc tblproperties ("orc.compress" = "zstd") 
location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_metrics_biz_manage_df/garss_region=ID'
;
-- msck repair table ${SCHEMA}.dws_risk_id_user_metrics_biz_manage_df;

--dim_user为主表，赋默认值的feature
create or replace temporary view dim_user_base_feature as
select
    t1.platform_user_id
    ,t1.shop_id
    ,coalesce(t2.hit_rule_bad_user_in_cluster, 0) as bad_user_group_ds
    ,coalesce(t3.cash_out_tag,0) as cash_out_tag
from
    (
        select
            user_id as platform_user_id
            ,shop_id
        from mp_user.dim_user__reg_s0_live
        where
            tz_type = 'local'
            and grass_region = 'ID'
            and grass_date = '${ds}'
    ) t1
    left join smcdrisk_antifraud.ds_community_model_result t2 on t1.platform_user_id = t2.platform_user_id
    left join
    (
        select tt1.platform_user_id
                ,tt2.cash_out_tag
        from
        (
            select platform_user_id
                    ,credit_user_id
            from credit_uc.dws_spl_id_uc_user_df
            where grass_date = '${ds}'
        ) tt1
        left join
        (
            select
                credit_user_id
                ,1 as cash_out_tag
            from smcdrisk_antifraud.tag_uw_userid_unique_limit_increment_cashout
            where grass_date = (select max(grass_date) from smcdrisk_antifraud.tag_uw_userid_unique_limit_increment_cashout)
            and   level in ('medium', 'Severe', 'Very Severe')
            group by credit_user_id
        )  tt2 on tt1.credit_user_id = tt2.credit_user_id
    )  t3 on t1.platform_user_id = t3.platform_user_id
;

create temporary view phone_book_blacklist_feature as (
    select
        userr.userid as platform_user_id
    from
        (
            select
                *
            from rescbds_credit.rescbds_credit_prod_id__phonebook_clusters
            where grass_date = (select max(grass_date) from rescbds_credit.rescbds_credit_prod_id__phonebook_clusters)
        ) userr
        inner join (
            select
                *
            from rescbds_credit.rescbds_credit_prod_id__phonebook_stat
            where grass_date = (select max(grass_date) from rescbds_credit.rescbds_credit_prod_id__phonebook_stat)
        ) cluster on userr.component = cluster.component
    where
        (cluster.history_dpd_rate >= 0.3)
        or (cluster.avg_loan_app >= 10)
    group by userid
)
;

---- user_graph相关feature
create or replace temporary view v_user_graph_base as
select
    platform_user_id
    ,community_id
    ,hit_rule_bad_user_in_cluster
    ,is_banned
    ,is_frozen
    ,grass_date
from regsm_riskmgmt.user_graph_community_risk_antifraud_v1
where
    grass_region = 'ID'
    and grass_date >= date_sub('${smd_grass_date}', 14)
;

-- 用户维度聚合：计算用户过去7天和14天的风险指标
create or replace temporary view v_user_metrics as
select
    platform_user_id
    ,sum(case when grass_date >= date_sub('${smd_grass_date}', 7) then hit_rule_bad_user_in_cluster else 0 end) as hit_rule_bad_user_in_cluster_l7d
    ,sum(case when grass_date >= date_sub('${smd_grass_date}', 14) then hit_rule_bad_user_in_cluster else 0 end) as hit_rule_bad_user_in_cluster_l14d
from v_user_graph_base
group by platform_user_id
;

-- 社区维度聚合：计算社区当天的异常用户比例
create or replace temporary view v_community_metrics as
select
    community_id
    ,sum(is_banned + is_frozen) * 1.0000 / count(platform_user_id) as abnormal_ratio_in_cluster
from v_user_graph_base
where grass_date = (select max(grass_date) from v_user_graph_base)
group by community_id
;

-- 最终结果视图：关联用户当天基础信息、历史风险指标和社区风险指标
create or replace temporary view v_user_graph_final as
select
    t0.platform_user_id
    ,t0.community_id
    ,t0.hit_rule_bad_user_in_cluster
    ,t1.hit_rule_bad_user_in_cluster_l7d
    ,t1.hit_rule_bad_user_in_cluster_l14d
    ,t2.abnormal_ratio_in_cluster
from
    (
        select
            platform_user_id
            ,community_id
            ,hit_rule_bad_user_in_cluster
        from v_user_graph_base
        where grass_date = (select max(grass_date) from v_user_graph_base)
    ) t0
    left join v_user_metrics t1 on t0.platform_user_id = t1.platform_user_id
    left join v_community_metrics t2 on t0.community_id = t2.community_id
;
---- user_graph相关feature end

insert overwrite table
    ${SCHEMA}.dws_risk_${region}_user_metrics_biz_manage_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id
    ,t6.shop_id
    ,t2.af_blacklist_color_tag
    ,t2.af_blacklist_color_sub_category_tag
    ,if(t3.platform_user_id is not null, 1, 0) as lite_limit_expire_flag
    ,t4.none_buyer_l7d
    ,t4.none_gmv_l7d
    ,t4.none_buyer_l3d
    ,t4.spl_hist_dpd_30
    ,t4.cnt_hit_blacklist_sme
    ,t6.bad_user_group_ds
    ,if(t7.platform_user_id is not null, 1, 0) as phone_book_cluster_blacklist_1
    ,t10.hit_ds_community_tag_l14d as hit_ds_community_tag_l14d_v2
    ,t10.hit_ds_community_tag_l7d as hit_ds_community_tag_l7d_v2
    ,t10.hit_ds_community_tag_l14d
    ,t10.hit_ds_community_tag_l7d
    ,t6.cash_out_tag
    ,t12.hit_rule_bad_user_in_cluster
    ,t12.hit_rule_bad_user_in_cluster_l7d
    ,t12.hit_rule_bad_user_in_cluster_l14d
    ,t12.abnormal_ratio_in_cluster
    ,t13.is_spl_recovered as is_account_recovery
from
    (
        select
            platform_user_id
        from ${SCHEMA}.dim_risk_${region}_user_info_df
        where grass_date = '${grass_date}'
    ) t1
    left join (
        select
            userid as platform_user_id
            ,concat_ws(',', collect_list(level)) as af_blacklist_color_tag
            ,concat_ws(',', collect_list(cate)) as af_blacklist_color_sub_category_tag
        from smcdrisk_antifraud.blacklist_uw_userid_unique
        where
            grass_date = (
                select
                    max(grass_date)
                from smcdrisk_antifraud.blacklist_uw_userid_unique
            )
        group by userid
    ) t2 on t1.platform_user_id = t2.platform_user_id
    left join (
        select platform_user_id
        from smcdrisk_policy.lite_limit_expiration
        group by platform_user_id
    ) t3 on t1.platform_user_id = t3.platform_user_id
    left join
    (
        select
            user_id as platform_user_id
            ,none_buyer_l7d
            ,none_gmv_l7d
            ,none_buyer_l3d
            ,spl_hist_dpd_30
            ,cnt_hit_blacklist_sme
        from smcdrisk_antifraud.seller_loan_blacklist_fs_last
        where grass_country = 'ID'
    ) t4 on t1.platform_user_id = t4.platform_user_id
    left join dim_user_base_feature t6 on t1.platform_user_id = t6.platform_user_id
    left join phone_book_blacklist_feature t7 on t1.platform_user_id = t7.platform_user_id
    left join
    (
        select
            platform_user_id
            ,max(case when grass_date = '${grass_date}' then 1 end) as hit_ds_community_tag_l1d
            ,count(distinct grass_date) as hit_ds_community_tag_l14d
            ,count(distinct case when grass_date >= date_sub('${smd_grass_date}', 7) then grass_date end) as hit_ds_community_tag_l7d
        from rescbds_credit.rescbds_credit_prod_id__relation_network_user_info  --业务跑批T+2才能完成，依赖T+2 Marker
        where
            model_version = 'v2.0'
            and grass_date >= date_sub('${smd_grass_date}', 14)
            and grass_date <= '${grass_date}'
            and hit_rule_bad_user_in_cluster = 1
        group by platform_user_id
    ) t10
    on t1.platform_user_id = t10.platform_user_id
    left join v_user_graph_final t12 on t1.platform_user_id = t12.platform_user_id
    left join 
    (
        select 
             platform_user_id
             ,is_spl_recovered
        from 
             risk.dim_risk_id_spl_recovery_user_list_df
             where grass_date = '${grass_date}'
    ) t13 
    on t1.platform_user_id = t13.platform_user_id
;