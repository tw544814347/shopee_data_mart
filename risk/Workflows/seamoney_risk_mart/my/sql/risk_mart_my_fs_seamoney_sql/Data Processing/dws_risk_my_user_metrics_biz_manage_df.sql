------------------------------------------------------------------------
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2024-09-08
-- Description:         业务维护的指标，user维度的融合成一张dws表
-- Data Granularity:    platform_user_id
-- PRD:           
-- Version:
-- 2025-08-08，跟业务确认，下线smcdrisk_antifraud.seller_loan_blacklist_fs_last表相关特征
-- 2025-08-29，跟业务确认，下线smcdrisk_antifraud.my_user_graph_linkage_table_all_cur_30d表特征     
------------------------------------------------------------------------
--drop table if exists ${SCHEMA}.dws_risk_my_user_metrics_biz_manage_df;
create table if not exists ${SCHEMA}.dws_risk_my_user_metrics_biz_manage_df
(
    platform_user_id string comment 'platform_user_id'
    ,shopee_age        string comment 'How long a user has been with Shopee'
    ,user_bcard_v3_score double comment 'user_level_bcard_v3_score'
    ,user_bcard_v3_user_overdue_tag bigint comment 'user_bcard_v3_user_overdue_tag'
    ,is_bad_user bigint comment 'is_bad_user'
    ,last_spl_increment_control_live_days_from_now bigint comment 'last_spl_increment_control_live_days_from_now'
    ,is_low_limit_users bigint comment 'is_low_limit_users'
    ,is_recoverd_users bigint comment 'is_recoverd_users'
    ,ctos_model_v2 double comment 'ctos_model_v2'
    ,ctos_credit_card_max_limit double comment 'ctos_credit_card_max_limit'
    ,repayment_channel_flag bigint
    ,cnt_network_linked_spldpd30 bigint
    ,cnt_network_linked_frozen bigint
    ,cnt_network_linked_banned bigint
    ,spp_bcl_whitelist_uid_test bigint
    ,hit_rule_bad_user_in_cluster bigint  --待下线，新feature hit_rule_bad_user_in_cluster_v2
    ,hit_rule_bad_user_in_cluster_v2 bigint
) 
partitioned by
(
    grass_date string comment 'grass_date, partition key'
)
stored as parquet
tblproperties
(
    "parquet.compress" = "zstd"
)
location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_metrics_biz_manage_df/grass_region=my';
--msck repair table ${SCHEMA}.dws_risk_my_user_metrics_biz_manage_df;

create or replace temporary view ctos_model_v2 as 
select
    userid as platform_user_id
    ,score as ctos_model_v2
from rescbds_credit.my_ctos_report_score
where
    grass_date = (
        select
            max(grass_date)
        from rescbds_credit.my_ctos_report_score
        where model_version = 'v2.0'
    )
    and product = 'kredit'
;

create or replace temporary view ctos_credit_limit as
select
    userid as platform_user_id
    ,max(cast(credit_limit as double)) ctos_credit_card_max_limit
from
    (
        select
            userid
            ,credit_limit
            ,row_number() over (partition by userid, loan_id order by position_date desc) position_date_rnk
        from
            (
                select
                    userid
                    ,loan_id
                    ,position_date
                    ,enquiry_datetime
                    ,max(instalment_in_arrears) instalment_in_arrears
                    ,max(`limit`) credit_limit
                    ,sum(os_balance) os_balance -- in case there are supplementary card           
                from
                    (
                        select
                            userid
                            ,loan_id
                            ,position_date
                            ,enquiry_datetime
                            ,instalment_in_arrears
                            ,`limit`
                            ,os_balance
                            ,facility
                            ,dense_rank() over (partition by userid order by enquiry_datetime desc) enquiry_time_rank
                        from rescbds_credit.dao_ctos_ccris_loan_repayment
                        where grass_date = (select max(grass_date) from rescbds_credit.dao_ctos_ccris_loan_repayment)
                    )
                where
                    enquiry_time_rank = 1
                    and facility = 'Credit Card'
                group by userid, loan_id, position_date, enquiry_datetime
            )
    )
where position_date_rnk = 1
group by 1
;

uncache table if exists dim_user_base;
cache table dim_user_base options ('storageLevel' 'MEMORY_AND_DISK')
    select  user_id as platform_user_id
    from    mp_user.dim_user__reg_s0_live
    where   tz_type = 'local'
    and     grass_region = 'MY'
    and     grass_date = '${grass_date}'
;

--跟FS逻辑base表保持一致
uncache table if exists user_network_base;
cache table user_network_base options ('storageLevel' 'MEMORY_AND_DISK')
select
    t1.platform_user_id
    ,t2.groupid
    ,t2.spl_dpd30
    ,t2.is_banned
    ,t2.is_frozen
    ,case when t2.hit_rule_bad_user_in_cluster = 1 then 1 else 0 end as hit_rule_bad_user_in_cluster
from dim_user_base t1
left join
(
    select
        platform_user_id
        ,groupid
        ,spl_dpd30
        ,is_banned
        ,is_frozen
        ,hit_rule_bad_user_in_cluster
    from rescbds_credit.rescbds_credit_prod_my__relation_network_user_info
    where grass_date = (select max(grass_date) from rescbds_credit.rescbds_credit_prod_my__relation_network_user_info)
) t2
on t1.platform_user_id = t2.platform_user_id
;

create or replace temporary view user_network_features
as
select
    t1.platform_user_id
    ,max(t2.spl_dpd30) as cnt_network_linked_spldpd30
    ,max(t2.is_banned) as cnt_network_linked_banned
    ,max(t2.is_frozen) as cnt_network_linked_frozen
from
    (
        select
            platform_user_id
            ,groupid
        from user_network_base
    ) t1
    inner join (
        select
            groupid
            ,sum(spl_dpd30) as spl_dpd30
            ,sum(is_banned) is_banned
            ,sum(is_frozen) is_frozen
        from user_network_base
        where groupid is not null
        group by groupid
    ) t2 on t1.groupid = t2.groupid
group by t1.platform_user_id
;

insert overwrite table ${SCHEMA}.dws_risk_my_user_metrics_biz_manage_df partition (grass_date = '${grass_date}')
select
     t1.platform_user_id
    ,t1.shopee_age
    ,t2.user_bcard_v3_score
    ,t2.user_bcard_v3_user_overdue_tag
    ,if(t3.platform_user_id  is not null,1,0) as is_bad_user
    ,t4.last_spl_increment_control_live_days_from_now
    ,t4.is_low_limit_users
    ,t4.is_recoverd_users
    ,t5.ctos_model_v2
    ,t6.ctos_credit_card_max_limit
    ,coalesce(t9.repayment_channel_flag,-9999) as repayment_channel_flag
    ,t10.cnt_network_linked_spldpd30
    ,t10.cnt_network_linked_frozen
    ,t10.cnt_network_linked_banned
    ,t12.is_whitelist_user as spp_bcl_whitelist_uid_test
    ,t14.hit_rule_bad_user_in_cluster
    ,t15.hit_rule_bad_user_in_cluster_v2
from(
        select
            platform_user_id
            ,shopee_age
        from ${SCHEMA}.dim_risk_my_user_info_df
        where grass_date = '${grass_date}'
    ) t1
    left join (
        select
            platform_user_id
            ,cast(get_json_object(score, '$.score') as double) as user_bcard_v3_score
            ,cast(get_json_object(score, '$.user_overdue_tag') as bigint) as user_bcard_v3_user_overdue_tag
        from risk.dws_risk_user_score_df
        where
            grass_region = 'MY'
            and grass_date = '${grass_date}'
            and biz_type = 'user_bcard_credit_score'
            and model_type = '3term_dpd30'
            and model_version = 'v3.0'
    ) t2 on t1.platform_user_id = t2.platform_user_id
    left join (
        select
            cast(userid as string) as platform_user_id
        from smcdrisk_antifraud.uw_blacklist_selection_my
        where exec_ts >= '20240101'
        and grass_date = (select max(grass_date) from smcdrisk_antifraud.uw_blacklist_selection_my)
        group by userid
    ) t3 on t1.platform_user_id = t3.platform_user_id
    left join
    (
        select
            platform_user_id
            ,last_spl_increment_control_live_days_from_now
            ,is_low_limit_users
            ,is_recoverd_users
        from smcdrisk_policy.my_spl_records_for_user_base_online
        where grass_date = (select max(grass_date) from smcdrisk_policy.my_spl_records_for_user_base_online)
    ) t4 on t1.platform_user_id = t4.platform_user_id
    left join ctos_model_v2 t5 on t1.platform_user_id = t5.platform_user_id
    left join ctos_credit_limit t6 on t1.platform_user_id = t6.platform_user_id
    left join
    (
        select
            userid as platform_user_id
            ,max(channelsupported) as repayment_channel_flag
        from smcdrisk_policy.temp_my_siyuan_paymentchannel
        group by userid
    ) t9 on t1.platform_user_id = t9.platform_user_id
    left join user_network_features t10 on t1.platform_user_id = t10.platform_user_id
    left join smcdrisk_antifraud.spp_bcl_bursement_whitelist_uid t12 on t1.platform_user_id = t12.uid
    left join user_network_base t14 on t1.platform_user_id = t14.platform_user_id
    left join
    (
        select
            platform_user_id
            ,hit_rule_bad_user_in_cluster as hit_rule_bad_user_in_cluster_v2
        from regsm_riskmgmt.user_graph_community_risk_antifraud_v1
        where grass_region = 'MY'
        and grass_date = (select max(grass_date) from regsm_riskmgmt.user_graph_community_risk_antifraud_v1 where grass_region = 'MY')
    ) t15 on t1.platform_user_id = t15.platform_user_id
;