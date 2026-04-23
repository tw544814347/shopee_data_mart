--drop table if exists ${SCHEMA}.ads_risk_my_fs_seamoney_antifraud_seller_df;

create external table if not exists ${SCHEMA}.ads_risk_my_fs_seamoney_antifraud_seller_df (
    shop_id string
    ,platform_user_id string comment 'platform_user_id'
    ,none_buyer_l7d boolean
    ,none_gmv_l7d boolean
    ,cnt_hit_blacklist_sme bigint
)
partitioned by
    (grass_date string comment "YYYY-MM-DD") stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_mart/ads/ads_risk_reg_fs_seamoney_antifraud_seller_df/grass_region=${grass_region}'
;
--msck repair table ${SCHEMA}.ads_risk_my_fs_seamoney_antifraud_seller_df;

insert overwrite table
    ${SCHEMA}.ads_risk_my_fs_seamoney_antifraud_seller_df partition (grass_date = '${grass_date}')
select
    t1.shop_id
    ,t1.platform_user_id
    ,t2.none_buyer_l7d
    ,t2.none_gmv_l7d
    ,t2.cnt_hit_blacklist_sme
from
    (
        select
            user_id as platform_user_id
            ,shop_id
        from mp_user.dim_user__reg_s0_live
        where
            tz_type = 'local'
            and grass_region = '${grass_region}'
            and grass_date = '${grass_date}'
    ) t1
    left join smcdrisk_antifraud.seller_loan_blacklist_fs_last t2 on t1.platform_user_id = t2.user_id
;