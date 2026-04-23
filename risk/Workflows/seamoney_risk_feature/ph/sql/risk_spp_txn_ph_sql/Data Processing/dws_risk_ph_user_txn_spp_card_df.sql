--********************************************************************--
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-03-31
-- Theme Domain：       User Txn SPP
-- Description:         SPP credit card releated feature
-- Data Granularity:    platform_user_id
-- Jira:                https://jira.shopee.io/browse/SPFDT-50707
--Update:
--2025.5.29  shopeepay.mart_dwd_wide_spm_payment_flow_df__ph 迁移至 shopeepay.mart_dwd_wide_pps_inbound_payment_flow_df__ph
--2025.10.21 by wei.tao 新增指标 https://jira.shopee.io/browse/SPFDT-56503 
--********************************************************************--


drop table if exists ${SCHEMA}.dws_risk_${region}_user_txn_spp_card_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_txn_spp_card_df (
    platform_user_id string comment 'platform_user_id'
    ,has_shopee_cc_transaction_90d bigint comment '用户是否在过去90d通过shopeepay flow 用cc进行过成功支付'
    ,has_shopee_cc_transaction_180d bigint comment '用户是否在过去180d通过shopeepay flow 用cc进行过成功支付'
    ,has_shopee_cc_transaction_360d bigint comment '用户是否在过去360d通过shopeepay flow 用cc进行过成功支付'
    ,has_shopee_cc_transaction_ever bigint comment '用户是否在过去通过shopeepay flow 用cc进行过成功支付'
    ,is_bcl_withdrawal_rejected_p30d bigint comment ''
)
partitioned by
    (grass_date string comment "YYYY-MM-DD") stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_fearure/dws/dws_risk_reg_user_txn_spp_card_df/grass_region=${grass_region}'
;
msck repair table ${SCHEMA}.dws_risk_${region}_user_txn_spp_card_df;

create or replace temporary view user_txn_spp_card_feature_df as
select
    shopee_user_id as platform_user_id
    ,count(if(payment_create_date >= date_sub('${current_grass_date}', 90), 1, null)) as shopee_cc_transaction_cnt_90d
    ,count(if(payment_create_date >= date_sub('${current_grass_date}', 180), 1, null)) as shopee_cc_transaction_cnt_180d
    ,count(if(payment_create_date >= date_sub('${current_grass_date}', 360), 1, null)) as shopee_cc_transaction_cnt_360d
    ,count(1) as shopee_cc_transaction_cnt_ever
from shopeepay.mart_dwd_wide_pps_inbound_payment_flow_df__ph a
where
    payment_create_date < '${current_grass_date}'
    and payment_type = 4
    and provision_channel_category_name != 'PAYMENT_CHANNEL_ITEM'
    and provision_channel_level_2 in ('General Order', 'Checkout')
    and card_type = 1 -- 1: credit card, 2: debit card
    and payment_status = 20 -- success
    and payment_actual_amount_usd > 0
    and module = 'PPS'
    and is_apm_merge = 0
group by shopee_user_id
;

insert overwrite table
    ${SCHEMA}.dws_risk_${region}_user_txn_spp_card_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id
    ,if(t2.shopee_cc_transaction_cnt_90d > 0, 1, 0) as has_shopee_cc_transaction_90d
    ,if(t2.shopee_cc_transaction_cnt_180d > 0, 1, 0) as has_shopee_cc_transaction_180d
    ,if(t2.shopee_cc_transaction_cnt_360d > 0, 1, 0) as has_shopee_cc_transaction_360d
    ,if(t2.shopee_cc_transaction_cnt_ever > 0, 1, 0) as has_shopee_cc_transaction_ever
    ,t3.is_bcl_withdrawal_rejected_p30d
from
    (
        select
            user_id as platform_user_id
        from mp_user.dim_user__reg_s0_live
        where
            tz_type = 'local'
            and grass_region = '${grass_region}'
            and grass_date = '${grass_date}'
    ) t1
    left join (
        select
            platform_user_id
            ,shopee_cc_transaction_cnt_90d
            ,shopee_cc_transaction_cnt_180d
            ,shopee_cc_transaction_cnt_360d
            ,shopee_cc_transaction_cnt_ever
        from user_txn_spp_card_feature_df
    ) t2 on t1.platform_user_id = t2.platform_user_id
    left join (
        SELECT userid as platform_user_id, is_bcl_withdrawal_rejected_p30d
        FROM smcdrisk_policy.ph_bcl_rejected_withdrawal_p30
        WHERE grass_date = (select max(grass_date) from smcdrisk_policy.ph_bcl_rejected_withdrawal_p30)
    ) t3 on t1.platform_user_id = t3.platform_user_id
;