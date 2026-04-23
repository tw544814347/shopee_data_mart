------------------------------------------------------------------------
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-10-29
-- Description:         Feature Station迁移， underwriting_buyer 宽表
-- Data Granularity:    platform_user_id
-- PRD:                 
------------------------------------------------------------------------
drop table if exists ${SCHEMA}.ads_risk_th_fs_seamoney_antifraud_buyer_df;
create table if not exists ${SCHEMA}.ads_risk_th_fs_seamoney_antifraud_buyer_df (
    platform_user_id string comment 'platform_user_id'
    ,frequency_city_name_list_6m string comment ''
    ,frequency_hex_hash_shopee_df_list_1y string comment ''
    ,frequency_sz_dfp_device_id_list_1y string comment ''
    ,frequency_shopee_df_list_seller_1y string comment ''
    ,frequency_sz_dfp_device_id_list_seller_1y string comment ''
    ,is_shopee_fraud_tag bigint comment ''
    ,uui_dpd30_cluster_user_cnt bigint comment ''
    ,succ_device_list_6m string comment ''
    ,succ_szdf_list_6m string comment ''
    ,cnt_buyer_pccheckout_frequency bigint comment ''
    ,user_risk_level string
    ,dp_abtesting_user_tag_th string
    ,th_seller_order_cancel_rate_past15d bigint
    ,month_due_spl bigint
    ,hit_rule_bad_user_in_cluster bigint comment ''
    ,silent_days_cnt bigint comment ''
) comment 'risk feature summary table'
partitioned by
    (grass_date string comment 'grass_date, partition key') stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_mart/ads/ads_risk_fs_seamoney_antifraud_buyer_df/grass_region=TH'
;
msck repair table ${SCHEMA}.ads_risk_th_fs_seamoney_antifraud_buyer_df;

insert overwrite table risk.ads_risk_th_fs_seamoney_antifraud_buyer_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id
    ,t2.frequency_city_name_list_6m as frequency_city_name_list_6m
    ,t2.frequency_hex_hash_shopee_df_list_1y as frequency_hex_hash_shopee_df_list_1y
    ,t2.frequency_sz_dfp_device_id_list_1y as frequency_sz_dfp_device_id_list_1y
    ,t2.frequency_shopee_df_list_seller_1y
    ,t2.frequency_sz_dfp_device_id_list_seller_1y
    ,case
        when t3.status <> 1 then 1
        else 0
    end as is_shopee_fraud_tag
    ,t4.uui_dpd30_cluster_user_cnt as uui_dpd30_cluster_user_cnt
    ,t5.succ_device_list_6m as succ_device_list_6m
    ,t5.succ_szdf_list_6m as succ_szdf_list_6m
    ,t6.cnt_buyer_pccheckout_frequency as cnt_buyer_pccheckout_frequency
    ,t7.user_risk_level
    ,t7.dp_abtesting_user_tag_th
    ,t7.th_seller_order_cancel_rate_past15d
    ,coalesce(t8.month_due_spl, 0) as month_due_spl
    ,t7.hit_rule_bad_user_in_cluster
    ,t9.silent_days_cnt
from
    (
        select
            platform_user_id
            ,is_seller
            ,shopee_age
            ,is_phone_verified
        from ${SCHEMA}.dim_risk_th_user_info_df
        where grass_date = '${grass_date}'
    ) t1
    left join (
        select
            user_id as platform_user_id
            ,frequency_city_name_list_6m as frequency_city_name_list_6m
            ,frequency_hex_hash_shopee_df_list_1y as frequency_hex_hash_shopee_df_list_1y
            ,frequency_sz_dfp_device_id_list_1y as frequency_sz_dfp_device_id_list_1y
            ,frequency_shopee_df_list_seller_1y
            ,frequency_sz_dfp_device_id_list_seller_1y
        from risk.ads_risk_profile_user_df
        where
            grass_region = 'TH'
            and grass_date = '${grass_date}'
    ) t2 on t1.platform_user_id = t2.platform_user_id
    left join (
        select
            user_id
            ,status
        from mp_user.dim_user__reg_s0_live
        where
            grass_region = 'TH'
            and grass_date = '${grass_date}'
    ) t3 on t1.platform_user_id = t3.user_id
    left join (
        select
            platform_user_id
            ,uui_dpd30_cluster_user_cnt
        from risk.dws_risk_th_user_af_graph_dpd_df
        where grass_date = '${grass_date}'
    ) t4 on t1.platform_user_id = t4.platform_user_id
    left join (
        select
            platform_user_id
            ,cast(collect_set(device_fingerprint) as string) as succ_device_list_6m
            ,cast(
                collect_set(
                    get_json_object(
                        extension
                        ,'$.CommonHeader.extension_proces_data.sz_dfp.device_id'
                    )
                ) as string
            ) as succ_szdf_list_6m
        from risk.dwd_risk_th_strategy_final_result_merge_di
        where
            (
                device_fingerprint is not null
                or get_json_object(
                    extension
                    ,'$.CommonHeader.extension_proces_data.sz_dfp.device_id'
                ) is not null
            )
            and (
                device_fingerprint <> ''
                or get_json_object(
                    extension
                    ,'$.CommonHeader.extension_proces_data.sz_dfp.device_id'
                ) <> ''
            )
            and (
                trim(device_fingerprint) <> ''
                or trim(
                    get_json_object(
                        extension
                        ,'$.CommonHeader.extension_proces_data.sz_dfp.device_id'
                    )
                ) <> ''
            )
            and final_result = 1
            and topic_name in (
                'th_live_credit_risk_gateway_req_rsp_kredit'
                ,'th_live_credit_risk_gateway_req_rsp_spj'
                ,'th_live_credit_risk_gateway_req_rsp_spjup'
                ,'th_live_credit_risk_gateway_req_rsp_fes'
            )
            and (
                concat(topic_name, '_', risk_scene_id) in (
                    'th_live_credit_risk_gateway_req_rsp_kredit_10013'
                    ,'th_live_credit_risk_gateway_req_rsp_kredit_10001'
                    ,'th_live_credit_risk_gateway_req_rsp_spj_10013'
                    ,'th_live_credit_risk_gateway_req_rsp_spj_10001'
                    ,'th_live_credit_risk_gateway_req_rsp_spjup_10003'
                    ,'th_live_credit_risk_gateway_req_rsp_spjup_10001'
                    ,'th_live_credit_risk_gateway_req_rsp_fe_10013'
                )
                or (
                    grass_date >= add_months('${grass_date}', 12)
                    and concat(topic_name, '_', risk_scene_id) in (
                        'th_live_credit_risk_gateway_req_rsp_kredit_10024'
                        ,'th_live_credit_risk_gateway_req_rsp_kredit_10025'
                        ,'th_live_credit_risk_gateway_req_rsp_kredit_10035'
                        ,'th_live_credit_risk_gateway_req_rsp_kredit_10034'
                        ,'th_live_credit_risk_gateway_req_rsp_spj_10024'
                        ,'th_live_credit_risk_gateway_req_rsp_spj_10025'
                        ,'th_live_credit_risk_gateway_req_rsp_spj_10026'
                        ,'th_live_credit_risk_gateway_req_rsp_spjup_10004'
                        ,'th_live_credit_risk_gateway_req_rsp_spjup_10005'
                        ,'th_live_credit_risk_gateway_req_rsp_fes_10004'
                        ,'th_live_credit_risk_gateway_req_rsp_fes_10005'
                    )
                )
            )
        group by platform_user_id
    ) t5 on t1.platform_user_id = t5.platform_user_id
    left join (
        select
            shopee_user_id as platform_user_id
            ,cnt_buyer_pccheckout_frequency
        from risk_feature.dws_risk_th_user_txn_mp_feature_df
        where grass_date = '${grass_date}'
    ) t6 on t1.platform_user_id = t6.platform_user_id
    left join (
        select
            platform_user_id
            ,user_risk_level
            ,dp_abtesting_user_tag_th
            ,th_seller_order_cancel_rate_past15d
            ,hit_rule_bad_user_in_cluster
        from ${SCHEMA}.dws_risk_th_user_metrics_biz_manage_df
        where grass_date = '${grass_date}'
    ) t7 on t1.platform_user_id = t7.platform_user_id
    left join (
        select
            platform_user_id
            ,month_due_spl
        from ${SCHEMA}.dws_risk_th_user_txn_fp_repayment_df
        where grass_date = '${grass_date}'
    ) t8 on t1.platform_user_id = t8.platform_user_id
    left join (
        select
            platform_user_id
            ,silent_days_cnt
        from ${SCHEMA}.dws_risk_th_user_behavior_mp_login_info_df
        where grass_date = '${grass_date}'
    ) t9 on t1.platform_user_id = t9.platform_user_id
;