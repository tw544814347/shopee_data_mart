------------------------------------------------------------------------
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2024-05-21
-- Description:         业务维护的指标，user维度的融合成一张dws表
-- Data Granularity:    platform_user_id
-- PRD:                 
-- 变更历史：
    --t3 字段置为 null
    --2025.7.31 新增 spl_cpd30_cnt_in_cluster 字段，jira: https://jira.shopee.io/browse/SPFDT-54075
    --2025.8.8  上游任务smcdrisk_antifraud.ph_risk_level 下线，已确认线上未使用
    --          上游任务smcdrisk_antifraud.fs_ph_spl_payment_blacklist_hit.ph_spl_blacklist_hit 下线，已确认线上未使用
    --          上游smcdrisk_antifraud.anti_fraud_ph_phone_contact_user_graph_linkage相关表下线，共下线9个feature
------------------------------------------------------------------------

--drop table if exists ${SCHEMA}.dws_risk_ph_user_metrics_biz_manage_df;
create external table if not exists ${SCHEMA}.dws_risk_ph_user_metrics_biz_manage_df (
    platform_user_id string comment 'platform_user_id'
    ,lending_cnt bigint comment 'lending_cnt'
    ,lending_high_cnt bigint comment 'lending_high_cnt'
    ,casino_cnt bigint comment 'casino_cnt'
    ,suspicious_cnt bigint comment 'suspicious_cnt'
    ,dp_abtesting_user_tag string comment 'dp_abtesting_user_tag'
    ,spl_wifi_shared_dpd60_ind int comment 'spl_wifi_shared_dpd60_ind'
    ,spl_wifi_graph_risk_ind int comment 'spl_wifi_graph_risk_ind'
    ,bcl_wifi_shared_dpd60_ind int comment 'bcl_wifi_shared_dpd60_ind'
    ,phone_ec_mp_cur_dpd15 int comment 'phone_ec_mp_cur_dpd15'
    ,phone_ec_mp_cur_dpd30 int comment 'phone_ec_mp_cur_dpd30'
    ,linked_dpd60_sellerbankaccount int comment 'linked_dpd60_sellerbankaccount'
    ,linked_sellbankaccount_user_count int comment 'linked_sellbankaccount_user_count'
    ,is_af_blacklist int comment 'is_af_blacklist'
    ,is_spl_incre_control int comment 'is_spl_incre_control'
    ,is_plm_decre_control int comment 'is_plm_decre_control'
    ,is_plm_freeze_control int comment 'is_plm_freeze_control'
    ,is_af_blacklist_p30d int comment 'is_af_blacklist_p30d'
    ,lending_high_m6_cnt int comment 'lending_high_m6_cnt'
    ,spl_cpd30_cnt_in_cluster bigint comment 'spl_cpd30_cnt_in_cluster'
) partitioned by (
    grass_date string comment "YYYY-MM-DD"
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_metrics_biz_manage_df/garss_region=PH'
;
--msck repair table ${SCHEMA}.dws_risk_ph_user_metrics_biz_manage_df;

create or replace temporary view v_dws_risk_ph_user_graph_tag_df as
select
    platform_user_id
    ,community_id
    ,sum(if (spl_dpd30 = 1, 1, 0)) over (partition by community_id) as spl_cpd30_cnt_in_cluster
from regsm_riskmgmt.user_graph_community_risk_antifraud_v1
where
    grass_region = 'PH'
    and grass_date = (select max(grass_date) from regsm_riskmgmt.user_graph_community_risk_antifraud_v1 where grass_region = 'PH')
;

insert overwrite table
    ${SCHEMA}.dws_risk_${region}_user_metrics_biz_manage_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id
    ,t2.lending_cnt
    ,t2.lending_high_cnt
    ,t2.casino_cnt
    ,t2.suspicious_cnt
    ,null as dp_abtesting_user_tag
    ,t6.spl_wifi_shared_dpd60_ind
    ,t6.spl_wifi_graph_risk_ind
    ,t6.bcl_wifi_shared_dpd60_ind
    ,coalesce(t7.phone_ec_mp_cur_dpd15,0) as phone_ec_mp_cur_dpd15
    ,coalesce(t7.phone_ec_mp_cur_dpd30,0) as phone_ec_mp_cur_dpd30
    ,t7.linked_dpd60_sellerbankaccount
    ,t7.linked_sellbankaccount_user_count
    ,t8.is_af_blacklist
    ,t9.is_spl_incre_control
    ,t10.is_plm_decre_control
    ,t11.is_plm_freeze_control
    ,t12.is_af_blacklist_p30d
    ,t13.lending_high_m6_cnt
    ,t14.spl_cpd30_cnt_in_cluster
from
    (
        select
            platform_user_id
        from ${SCHEMA}.dim_risk_${region}_user_info_df
        where grass_date = '${grass_date}'
    ) t1
    left join (
        select
            user_id as platform_user_id
            ,lending_cnt
            ,lending_high_cnt
            ,lending_high_m6_cnt
            ,casino_cnt
            ,suspicious_cnt
        from smcdrisk_antifraud.fs_ph_applist
    ) t2 on t1.platform_user_id = t2.platform_user_id
    left join (
        select
            user_id as platform_user_id
            ,spl_wifi_shared_dpd60_ind
            ,spl_wifi_graph_risk_ind
            ,bcl_wifi_shared_dpd60_ind
        from smcdrisk_antifraud.hy_ph_spl_wifi_feature
    ) t6 on t1.platform_user_id = t6.platform_user_id
    left join ${SCHEMA}.dws_risk_ph_user_graph_tag_df t7 on t1.platform_user_id = t7.platform_user_id
    left join
    (
        select
            platform_user_id
            ,1 as is_af_blacklist
        from smcdrisk_antifraud.ph_blacklist_uid_uw
        group by platform_user_id
    ) t8 on t1.platform_user_id = t8.platform_user_id
    left join
    (
        select
            userid as platform_user_id
            ,1 as is_spl_incre_control
        from smcdrisk_policy.ph_spl_plm_table
        where release_date >= date_sub('${smd_grass_date}',45)
        and is_control = 1
        group by userid
    ) t9 on t1.platform_user_id = t9.platform_user_id
    left join
    (
        select
            userid as platform_user_id
            ,1 as is_plm_decre_control
        from smcdrisk_policy.ph_spl_decrease_user_base
        where release_date >= date_sub('${smd_grass_date}',180)
        group by userid
    ) t10 on t1.platform_user_id = t10.platform_user_id
    left join
    (
        select
            platform_user_id
            ,1 as is_plm_freeze_control
        from
            (
                select
                    platform_user_id
                from credit_uc.dwd_uc_ph_user_lock_product_info_df
                where
                    grass_date = '${grass_date}'
                    and biz_type in (1, 3)
                    and lock_status = 1
                union
                select
                    userid as platform_user_id
                from smcdrisk_policy.ph_spl_freeze_user_base_v2
                where remark like '%ontrol%'
            )
        group by platform_user_id
    ) t11 on t1.platform_user_id = t11.platform_user_id
    left join
    (
        select
            platform_user_id
            ,1 as is_af_blacklist_p30d
        from smcdrisk_antifraud.ph_blacklist_uid_for_uw_limit_inc_df
        where
            grass_date = (select max(grass_date) from smcdrisk_antifraud.ph_blacklist_uid_for_uw_limit_inc_df)
            and hit_rule_date >= date_sub('${smd_grass_date}', 30)
            and product <> 'linked'
        group by platform_user_id
    ) t12 on t1.platform_user_id = t12.platform_user_id
    left join
    (
        select
            userid as platform_user_id
            ,max(lending_high_m6_cnt) as lending_high_m6_cnt
        from smcdrisk_policy.ph_lending_cnt_base
        group by userid
    ) t13 on t1.platform_user_id = t13.platform_user_id
    left join
    (
        select
            platform_user_id
            ,community_id
            ,spl_cpd30_cnt_in_cluster
        from v_dws_risk_ph_user_graph_tag_df
    ) t14 on t1.platform_user_id = t14.platform_user_id
;