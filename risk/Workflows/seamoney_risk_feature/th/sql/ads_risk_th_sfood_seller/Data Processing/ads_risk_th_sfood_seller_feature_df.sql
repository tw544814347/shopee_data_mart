add jar hdfs://R2/projects/credit/hdfs/prod/jar/column_encrypt_for_th.jar;
drop temporary function if exists ms_encrypt;
create temporary function ms_encrypt as "com.shopee.seamoney.udf.ColumnEncryptUDF";

-- drop table if exists ${SCHEMA}.ads_risk_th_sfood_seller_feature_df;
create table if not exists ${SCHEMA}.ads_risk_th_sfood_seller_feature_df
(
    national_id                                            string
    ,national_id_encrypt                                   string
    ,platform_user_id                                      string
    ,credit_user_id                                        string
    ,spp_user_id                                           string
    ,has_activated_scl                                     bigint
    ,num_mid                                               bigint
    ,merchant_id_list                                      string
    ,num_sid                                               bigint
    ,store_id_list                                         string
    ,has_non_individual_store                              bigint
    ,has_greylist_store                                    bigint
    ,has_blacklist_store                                   bigint
    ,has_whitelist_store                                   bigint
    ,has_ban_sus_store                                     bigint
    ,has_site_verified_store                               bigint
    ,txn_days_l6m                                          bigint
    ,has_txn_l12m                                          bigint
    ,avg_active_months                                     decimal(30,10)
    ,num_inactive_4_consec_days                            bigint
    ,order_cnt_l1m                                         bigint
    ,order_cnt_l5_l6m                                      bigint
    ,order_cnt_drop_16                                     decimal(30,10)
    ,avg_order_cnt_l6m                                     decimal(30,10)
    ,nmv_l1m                                               decimal(30,10)
    ,nmv_l1_l2m                                            decimal(30,10)
    ,nmv_l2_l3m                                            decimal(30,10)
    ,avg_nmv_l3m                                           decimal(30,10)
    ,nmv_l3_l4m                                            decimal(30,10)
    ,nmv_l4_l5m                                            decimal(30,10)
    ,nmv_l5_l6m                                            decimal(30,10)
    ,nmv_drop_16                                           decimal(30,10)
    ,avg_nmv_l6m                                           decimal(30,10)
    ,weighted_avg_nmv_l6m                                  decimal(30,10)
    ,avg_buyer_cnt_l6m                                     decimal(30,10)
    ,cancel_rate_l7d                                       decimal(30,10)
    ,has_on_us_merchant                                    bigint
    ,has_individual_merchant                               bigint
    ,is_enable_wallet                                      decimal(30,10)
    ,has_whitelist_merchant                                bigint
    ,has_blacklist_merchant                                bigint
    ,has_spl_sus_merchant                                  bigint
    ,has_spl_whitelist_merchant                            bigint
    ,avg_merchant_ktp_chg_7d                               decimal(30,10)
    ,avg_merchant_ktp_chg_30d                              decimal(30,10)
)
partitioned by
(
    grass_date string comment 'yyyy-MM-dd'
)
comment 'tag: risk feature summary table'
stored as orc tblproperties ("orc.compress"="ZSTD","orc.stripe.size"="268435456")
LOCATION '${HDFS_PATH}/ads/ads_risk_th_sfood_seller_feature_df';

-- MSCK REPAIR TABLE ${SCHEMA}.ads_risk_th_sfood_seller_feature_df;

insert overwrite table ${SCHEMA}.ads_risk_th_sfood_seller_feature_df partition (grass_date = '${ds}')
select
    -- 基本信息字段
    a.national_id
    ,ms_encrypt(a.national_id, 'th')                        as national_id_encrypt
    ,a.platform_user_id
    ,a.credit_user_id
    ,a.spp_user_id
    ,a.has_activated_scl
    ,a.num_mid
    ,a.merchant_id_list
    ,a.num_sid
    ,a.store_id_list
    
    -- 店铺相关字段
    ,b.food_has_non_individual_store                       as has_non_individual_store
    ,b.food_has_greylist_store                             as has_greylist_store
    ,b.food_has_blacklist_store                            as has_blacklist_store
    ,b.food_has_whitelist_store                            as has_whitelist_store
    ,b.food_has_ban_sus_store                              as has_ban_sus_store
    ,b.food_has_site_verified_store                        as has_site_verified_store
    
    -- 交易相关字段
    ,b.food_txn_days_l6m                                   as txn_days_l6m
    ,b.food_txn_mth_l12m                                   as has_txn_l12m
    ,c.food_avg_active_months                              as avg_active_months
    ,b.food_inactive_4_days                                as num_inactive_4_consec_days
    
    -- 订单相关字段
    ,b.food_order_cnt_l1m                                  as order_cnt_l1m
    ,b.food_order_cnt_l5_l6m                               as order_cnt_l5_l6m
    ,b.food_order_cnt_drop_16                              as order_cnt_drop_16
    ,b.food_avg_order_cnt_l6m                              as avg_order_cnt_l6m
    
    -- 交易金额相关字段
    ,b.food_nmv_l1m                                        as nmv_l1m
    ,b.food_nmv_l1_l2m                                     as nmv_l1_l2m
    ,b.food_nmv_l2_l3m                                     as nmv_l2_l3m
    ,b.food_avg_nmv_l3m                                    as avg_nmv_l3m
    ,b.food_nmv_l3_l4m                                     as nmv_l3_l4m
    ,b.food_nmv_l4_l5m                                     as nmv_l4_l5m
    ,b.food_nmv_l5_l6m                                     as nmv_l5_l6m
    ,b.food_nmv_drop_16                                    as nmv_drop_16
    ,b.food_avg_nmv_l6m                                    as avg_nmv_l6m
    ,(0.5 * b.food_nmv_l1m + 0.3 * b.food_avg_nmv_l3m + 0.2 * b.food_avg_nmv_l6m) as weighted_avg_nmv_l6m
    
    -- 买家相关字段
    ,b.food_avg_buyer_cnt_l6m                              as avg_buyer_cnt_l6m
    
    -- 取消率相关字段
    ,b.food_cancel_rate_l7d                                as cancel_rate_l7d
    
    -- 商户相关字段
    ,c.food_has_on_us                                      as has_on_us_merchant
    ,c.food_has_individual_merchant                        as has_individual_merchant
    ,c.food_is_enable_wallet                               as is_enable_wallet
    ,c.food_has_whitelist                                  as has_whitelist_merchant
    ,c.food_has_blacklist                                  as has_blacklist_merchant
    ,c.food_has_spl_sus                                    as has_spl_sus_merchant
    ,c.food_has_spl_whitelist                              as has_spl_whitelist_merchant

    -- KTP 变更特征
    ,a.avg_merchant_ktp_chg_7d                             as avg_merchant_ktp_chg_7d
    ,a.avg_merchant_ktp_chg_30d                            as avg_merchant_ktp_chg_30d

from ${SCHEMA}.ads_risk_th_sfood_seller_info_df a
    left join ${SCHEMA}.ads_risk_th_sfood_seller_store_info_df b
        on a.national_id = b.national_id
        and a.grass_date = b.grass_date
    left join ${SCHEMA}.ads_risk_th_sfood_seller_merchant_info_df c
        on a.national_id = c.national_id
        and a.grass_date = c.grass_date
where a.grass_date = '${ds}'
;
