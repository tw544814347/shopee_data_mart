drop table if exists ${SCHEMA}.ads_risk_${region}_fs_seamoney_underwriting_buyer_df;
create external table if not exists ${SCHEMA}.ads_risk_${region}_fs_seamoney_underwriting_buyer_df (
    platform_user_id string comment 'platform_user_id'
    ,pctg_of_cod__order_in_30d double comment 'Percentage of Cash-On-Delivery orders in last 30 days	'
    ,pctg_of_cod__order_in_90d double comment 'Percentage of Cash-On-Delivery orders in last 90 days	'
    ,pctg_of_cod__order_in_180d double comment 'Percentage of Cash-On-Delivery orders in last 180 days	'
    ,pctg_of_cod__order_in_360d double comment 'Percentage of Cash-On-Delivery orders in last 3360 days	'
    ,pctg_of_cod__order_in_lifetime double comment 'Percentage of Cash-On-Delivery orders in lifetime	'
    ,max_inactive_days_in_180d int comment 'Max inactive days in last 180 days'
) partitioned by (
    grass_date string comment "YYYY-MM-DD"
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location '${HDFS_PATH}/risk_mart/dim/ads_risk_reg_fs_seamoney_underwriting_buyer_df/garss_region=${upper_region}'
;
msck repair table ${SCHEMA}.ads_risk_${region}_fs_seamoney_underwriting_buyer_df;

insert overwrite table
    ${SCHEMA}.ads_risk_${region}_fs_seamoney_underwriting_buyer_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id
    ,coalesce(t2.pctg_of_cod__order_in_30d, -1) as pctg_of_cod__order_in_30d
    ,coalesce(t2.pctg_of_cod__order_in_90d, -1) as pctg_of_cod__order_in_90d
    ,coalesce(t2.pctg_of_cod__order_in_180d, -1) as pctg_of_cod__order_in_180d
    ,coalesce(t2.pctg_of_cod__order_in_360d, -1) as pctg_of_cod__order_in_360d
    ,coalesce(t2.pctg_of_cod__order_in_lifetime, -1) as pctg_of_cod__order_in_lifetime
    ,t3.max_inactive_days_in_180d
from
    (
        select
            platform_user_id
        from ${SCHEMA}.dim_risk_ph_user_info_df
        where grass_date = '${grass_date}'
    ) t1
    left join (
        select
            *
        from ${SCHEMA}.dws_risk_ph_user_txn_mp_order_complete_df
        where grass_date = '${grass_date}'
    ) t2 on t1.platform_user_id = t2.platform_user_id
    left join (
        select
            shopee_user_id
            ,max_inactive_days_in_180d
        from risk_feature.dws_risk_ph_user_txn_mp_feature_df
        where grass_date = '${grass_date}'
    ) t3 on t1.platform_user_id = t3.shopee_user_id
;