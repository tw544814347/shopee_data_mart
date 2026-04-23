------------------------------------------------------------------------
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2024-10-15
-- Description:         FS迁移，underwriting buyer 指标
-- Data Granularity:    platform_user_id
-- PRD:                 https://docs.google.com/spreadsheets/d/11Bpx701mGtwTHd0-TXZE5ickY4HHPFsVCnsui_cWuUM/edit?gid=899753510#gid=899753510
-- update by zongyi.lu@shopee.com 2024-10-23 新增字段  jira https://jira.shopee.io/browse/SPFDT-45159
-- update by zongyi.lu@shopee.com 2024-11-11 将10-23新增的字段 改成双下划线
------------------------------------------------------------------------
-- drop table if exists ${SCHEMA}.ads_risk_id_fs_seamoney_underwriting_buyer_df;
create table if not exists ${SCHEMA}.ads_risk_id_fs_seamoney_underwriting_buyer_df (
    platform_user_id string comment 'platform_user_id'
    ,shopee_age bigint comment 'shopee_age'
    ,is_wholeseller bigint comment 'is_wholeseller'
    ,pctg_of_wholeseller_order double comment 'pctg_of_wholeseller_order'
    ,is_dropshipper bigint comment 'is_dropshipper'
    ,pctg_of_dropshipper_gmv double comment 'pctg_of_dropshipper_gmv'
    ,pctg_of_dropshipper_order double comment 'pctg_of_dropshipper_order'
    ,af_blacklist_color_sub_category_tag string comment '欺诈标签, Grey、Black、空值'
    ,af_blacklist_color_tag string comment '欺诈标签, subcategory 分类： 1）Overdue 2）Device Concentration 3）Cash-out 4）Shopee Fraud Tag 5）ATO'
    ,lite_limit_expire_flag bigint comment 'lite_limit_expire_flag'
    ,pctg_of_cod__order_in_30d                  double               comment 'pctg_of_cod__order_in_30d'
    ,pctg_of_cod__order_in_90d                  double               comment 'pctg_of_cod__order_in_90d'
    ,pctg_of_cod__order_in_180d                 double               comment 'pctg_of_cod__order_in_180d'
    ,pctg_of_cod__order_in_360d                 double               comment 'pctg_of_cod__order_in_360d'
    ,pctg_of_cod__order_in_lifetime             double               comment 'pctg_of_cod__order_in_lifetime'
    ,confirmed_gmv_usd_in_30d decimal(30, 10) comment 'confirmed_gmv_usd_in_30d'
    ,confirmed_gmv_usd_in_30d_spl_only decimal(30, 10) comment 'confirmed_gmv_usd_in_30d_spl_only'
    ,confirmed_gmv_usd_in_30d_spl_exclude decimal(30, 10) comment 'confirmed_gmv_usd_in_30d_spl_exclude'
    ,confirmed_gmv_usd_in_60d decimal(30, 10) comment 'confirmed_gmv_usd_in_60d'
    ,confirmed_gmv_usd_in_60d_spl_only decimal(30, 10) comment 'confirmed_gmv_usd_in_60d_spl_only'
    ,confirmed_gmv_usd_in_60d_spl_exclude decimal(30, 10) comment 'confirmed_gmv_usd_in_60d_spl_exclude'
    ,confirmed_gmv_usd_in_90d_spl_only decimal(30, 10) comment 'confirmed_gmv_usd_in_90d_spl_only'
    ,confirmed_gmv_usd_in_90d_spl_exclude decimal(30, 10) comment 'confirmed_gmv_usd_in_90d_spl_exclude'
    ,confirmed_gmv_usd_in_180d_spl_only decimal(30, 10) comment 'confirmed_gmv_usd_in_180d_spl_only'
    ,confirmed_gmv_usd_in_180d_spl_exclude decimal(30, 10) comment 'confirmed_gmv_usd_in_180d_spl_exclude'
    ,confirmed_gmv_usd_in_360d_spl_only decimal(30, 10) comment 'confirmed_gmv_usd_in_360d_spl_only'
    ,confirmed_gmv_usd_in_360d_spl_exclude decimal(30, 10) comment 'confirmed_gmv_usd_in_360d_spl_exclude'
    ,confirmed_gmv_usd_in_lifetime decimal(30, 10) comment 'confirmed_gmv_usd_in_lifetime'
    ,login_days_cnt_90d bigint comment 'login days cnt in the past 90 days'
    ,login_days_cnt_360d bigint comment 'login days cnt in the past 360 days'
    ,is_account_recovery int comment 'is account recovery'
)
partitioned by
    (grass_date string comment 'grass_date, partition key') 
    stored as orc tblproperties ("orc.compress" = "zstd") 
    location '${HDFS_PATH}/risk_mart/ads/ads_risk_fs_seamoney_underwriting_buyer_df/grass_region=ID'
;
-- msck repair table ${SCHEMA}.ads_risk_id_fs_seamoney_underwriting_buyer_df;

insert overwrite table ${SCHEMA}.ads_risk_id_fs_seamoney_underwriting_buyer_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id
    ,t1.shopee_age
    ,t2.is_wholeseller
    ,t2.pctg_of_wholeseller_order
    ,t2.is_dropshipper
    ,t2.pctg_of_dropshipper_gmv
    ,t2.pctg_of_dropshipper_order
    ,t3.af_blacklist_color_sub_category_tag
    ,t3.af_blacklist_color_tag
    ,t3.lite_limit_expire_flag
    ,t2.pctg_of_cod__order_in_30d       as pctg_of_cod__order_in_30d      
    ,t2.pctg_of_cod__order_in_90d       as pctg_of_cod__order_in_90d      
    ,t2.pctg_of_cod__order_in_180d      as pctg_of_cod__order_in_180d     
    ,t2.pctg_of_cod__order_in_360d      as pctg_of_cod__order_in_360d     
    ,t2.pctg_of_cod__order_in_lifetime  as pctg_of_cod__order_in_lifetime
    ,t2.confirmed_gmv_usd_in_30d
    ,t2.confirmed_gmv_usd_in_30d_spl_only
    ,t2.confirmed_gmv_usd_in_30d_spl_exclude
    ,t2.confirmed_gmv_usd_in_60d
    ,t2.confirmed_gmv_usd_in_60d_spl_only
    ,t2.confirmed_gmv_usd_in_60d_spl_exclude
    ,t2.confirmed_gmv_usd_in_90d_spl_only
    ,t2.confirmed_gmv_usd_in_90d_spl_exclude
    ,t2.confirmed_gmv_usd_in_180d_spl_only
    ,t2.confirmed_gmv_usd_in_180d_spl_exclude
    ,t2.confirmed_gmv_usd_in_360d_spl_only
    ,t2.confirmed_gmv_usd_in_360d_spl_exclude
    ,t2.confirmed_gmv_usd_in_lifetime
    ,t4.login_days_cnt_90d
    ,t4.login_days_cnt_360d
    ,t3.is_account_recovery
from
    (
        select
            platform_user_id
            ,shopee_age
        from ${SCHEMA}.dim_risk_id_user_info_df
        where grass_date = '${ds}'
    ) t1
    left join (
        select
            platform_user_id
            ,is_wholeseller
            ,pctg_of_wholeseller_order
            ,is_dropshipper
            ,pctg_of_dropshipper_gmv
            ,pctg_of_dropshipper_order
            ,pctg_of_cod__order_in_30d      
            ,pctg_of_cod__order_in_90d      
            ,pctg_of_cod__order_in_180d     
            ,pctg_of_cod__order_in_360d     
            ,pctg_of_cod__order_in_lifetime
            ,confirmed_gmv_usd_in_30d
            ,confirmed_gmv_usd_in_30d_spl_only
            ,confirmed_gmv_usd_in_30d_spl_exclude
            ,confirmed_gmv_usd_in_60d
            ,confirmed_gmv_usd_in_60d_spl_only
            ,confirmed_gmv_usd_in_60d_spl_exclude
            ,confirmed_gmv_usd_in_90d_spl_only
            ,confirmed_gmv_usd_in_90d_spl_exclude
            ,confirmed_gmv_usd_in_180d_spl_only
            ,confirmed_gmv_usd_in_180d_spl_exclude
            ,confirmed_gmv_usd_in_360d_spl_only
            ,confirmed_gmv_usd_in_360d_spl_exclude
            ,confirmed_gmv_usd_in_lifetime
        from ${SCHEMA}.dws_risk_id_user_txn_mp_order_complete_df
        where grass_date = '${grass_date}'
    ) t2 on t1.platform_user_id = t2.platform_user_id
    left join (
        select
            platform_user_id 
            ,af_blacklist_color_sub_category_tag
            ,af_blacklist_color_tag
            ,lite_limit_expire_flag
            ,is_account_recovery
        from ${SCHEMA}.dws_risk_id_user_metrics_biz_manage_df
        where grass_date = '${grass_date}'
    ) t3 on t1.platform_user_id = t3.platform_user_id
    left join (
        select
            platform_user_id
            ,login_days_cnt_90d
            ,login_days_cnt_360d
        from ${SCHEMA}.dws_risk_id_user_behavior_mp_login_info_df
        where grass_date = '${grass_date}'
    ) t4 on t1.platform_user_id = t4.platform_user_id
;