--********************************************************************--
-- Author:              chenyingying@shopee.com
-- Created Time:        2024-10-23
-- Theme Domain：       user
-- Description:         user metrics manage by biz
-- 开发要求:             https://docs.google.com/spreadsheets/d/11Bpx701mGtwTHd0-TXZE5ickY4HHPFsVCnsui_cWuUM/edit?gid=524012195#gid=524012195
-- Data Granularity:    platform_user_id
-- 变更历史：
--********************************************************************--


--drop table if exists ${SCHEMA}.dws_risk_th_user_metrics_biz_manage_df;
create external table if not exists ${SCHEMA}.dws_risk_th_user_metrics_biz_manage_df (
    platform_user_id            string comment 'platform user id'
    ,user_risk_level            string comment 'user risk level'
    ,dp_abtesting_user_tag_th   string comment ''
    ,th_seller_order_cancel_rate_past15d    bigint comment ''
    ,hit_rule_bad_user_in_cluster bigint comment ''
)
partitioned by (grass_date string comment 'YYYY-MM-DD') 
stored as orc tblproperties ("orc.compress" = "zstd") 
location '${HDFS_PATH}/risk_mart/dws/dws_risk_th_user_metrics_biz_manage_df/' 
comment 
'
Tag:risk summary table
table description: record the user metrics in TH
table source: 
smcdrisk_antifraud.seamoney_regional_risk_team__th_user_risk_level
rescbds_credit.rescbds_credit_prod_th__application_credit_score_mega
smcdrisk_antifraud.th_blacklist_overdue_users
rescbds_credit.rescbds_credit_prod_th__user_graph_linkage_info
smcdrisk_policy.th_bcl_limit_decrement_record
smcdrisk_antifraud.th_dp_whitelist_raw_tab
smcdrisk_antifraud.credit_device_th_v2
smcdrisk_antifraud.th_fes_refund_rate_bin_15d
smcdrisk_antifraud.th_blacklist_dpd_users
'
;
--msck repair table ${SCHEMA}.dws_risk_th_user_metrics_biz_manage_df;


create or replace temporary view user_info as (
    select  userid
    from    marketplace.shopee_account_v2_db__account_tab__th_df
    WHERE   grass_region = 'TH'
    and     grass_date = date('${ds}')

)
;

create or replace temporary view fs_user_risk_level as (
    select  userid                      as platform_user_id
            ,nvl(user_risk_level, null) as user_risk_level
    from    smcdrisk_antifraud.seamoney_regional_risk_team__th_user_risk_level
)
;

create or replace temporary view fs_swap_out as (
        select  cast(userid as bigint)  as user_id
                ,'swap out'             as tag
        from smcdrisk_antifraud.th_dp_whitelist_raw_tab  
        where cast(curr_date as date)= (
                                        select max(cast(curr_date as date)) as max_date 
                                        from    smcdrisk_antifraud.th_dp_whitelist_raw_tab
                                    )
        and user_segmentation = 'swap out' 
        and user_risk_level <> 'swap out'
)
;

create or replace temporary view fs_refund_rate_15d as (
        select  distinct cast(platform_user_id as bigint) as userid
                ,1                                        as th_seller_order_cancel_rate_past15d
        from    smcdrisk_antifraud.th_fes_refund_rate_bin_15d
        where   cast(grass_date as string) = '${ds}'
        and     gmv_cancel_rate > 0.5
)
;


insert overwrite ${SCHEMA}.dws_risk_th_user_metrics_biz_manage_df partition(grass_date = '${ds}')
select  t1.userid                       as platform_user_id
        ,nvl(t2.user_risk_level, null)  as user_risk_level          
       ,case when t7.tag is not null then t7.tag else 'none' end       as dp_abtesting_user_tag_th   
        ,case when t12.th_seller_order_cancel_rate_past15d is not null then 1 else 0 end as th_seller_order_cancel_rate_past15d
        ,t13.hit_rule_bad_user_in_cluster
from    user_info as t1
left join fs_user_risk_level as t2
on      t1.userid = cast(t2.platform_user_id as bigint)
left join fs_swap_out as t7
on      t1.userid = cast(t7.user_id as bigint)
left join fs_refund_rate_15d as t12
on      t1.userid = t12.userid 
left join (
        select  platform_user_id
                ,hit_rule_bad_user_in_cluster
        from regsm_riskmgmt.user_graph_community_risk_antifraud_v1
        where grass_region = 'TH'
        and grass_date = (select max(grass_date) from regsm_riskmgmt.user_graph_community_risk_antifraud_v1 where grass_region = 'TH')
) as t13
on      t1.userid = t13.platform_user_id 
;