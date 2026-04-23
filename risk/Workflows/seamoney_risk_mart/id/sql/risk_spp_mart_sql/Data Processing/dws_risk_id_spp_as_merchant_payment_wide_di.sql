--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-05-10
-- Theme Domain：       risk-spp_as_merchant_payment
-- Description:         
-- Data Granularity:    spp_user_id
-- 变更历史：
--      update by zongyi.lu@shopee.com，2024-05-10 1. dim_user_device_deviceid_df 改成 dim_user_security_deviceid_linkage(小时任务不用加依赖)  https://jira.shopee.io/browse/SPFDT-37230 2.新增注释
--      wei.tao 从 shopee_device_extension_db__device_ext_tab__reg_continuous_s0_live 换表 dim_shopee_device_extension_v2_db__device_ext_tab__reg_df     
--      wei.tao shopeepay_acquiring_linkage_my_db__linkage_tab -> mart_dwd_as_linkage_tab_df__{region} - ods 表迁移
--              shopeepay_user_account_${region_lower}_db__user_account_tab -> mart_dwd_us_user_account_tab_df__{region} - ods 表迁移
--********************************************************************--



add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar
;

drop temporary function if exists format_time
;

create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp'
;

insert overwrite
    ${SCHEMA}.dws_risk_${region_lower}_spp_as_merchant_payment_wide_di partition (grass_date)
select
    t1.shopeepay_user_id as spp_user_id
    ,12 as order_type_code
    ,t1.product_flow as transaction_flow
    ,case
        when t1.product_flow in (1, 2) then 'C Scan B'
        when t1.product_flow in (4) then 'B Scan C'
        when t1.product_flow in (16) then 'Jump App'
        when t1.product_flow in (128) then 'Tokenized Payment'
        when t1.product_flow in (1024) then 'Ticket Linking'
    end as order_type_name
    ,t1.as_transaction_id as transaction_id
    ,t1.as_transaction_sn as transaction_sn
    ,t1.as_order_sn as order_sn
    ,case
        when t1.transaction_status = 1 then 1
        when t1.transaction_status = 4 then 3
        when t1.transaction_status = 5 then 4
        else t1.transaction_status
    end as order_status_code
    ,case
        when t1.transaction_status = 1 then 'TRX_PENDING'
        when t1.transaction_status = 4 then 'TRX_SUCCESSFUL'
        when t1.transaction_status = 5 then 'TRX_FAILED'
        else 'Others'
    end as order_status_name
    ,t1.order_create_time as create_timestamp
    ,format_time ((t1.order_create_time), '${region_upper}') as create_datetime_local
    ,format_time ((t1.order_create_time), 'SG') as create_datetime_regional
    ,t1.user_age
    ,t1.actual_amount as event_amount_local
    ,t1.actual_amount_usd as event_amount_usd
    ,t1.merchant_scope_name as merchant_scope
    ,case
        when lower(merchant_scope_name) like 'on%' then concat(merchant_host_id, '#', t1.merchant_id, '#', t1.store_id)
        when lower(merchant_scope_name) like 'off%' then if (
            '${region_lower}' = 'id'
            ,t1.acquirer_id
            ,t1.acquirer_id || t1.external_merchant_id
        )
        else 'abnormal'
    end as merchant_id_merge
    ,case
        when lower(merchant_scope_name) like 'on%' then concat(t1.merchant_name, '#', t1.store_name)
        when lower(merchant_scope_name) like 'off%' then get_json_object(order_info, '$.merchant_info.merchant_name')
        else 'abnormal'
    end as merchant_name_merge
    ,if (
        '${region_lower}' = 'id'
        ,t1.acquirer_id
        ,t1.acquirer_id || t1.external_merchant_id
    ) as unique_merchant_id
    ,get_json_object(order_info, '$.merchant_info.merchant_name') as off_us_merchant_name
    ,merchant_host_id as merchant_host_id
    ,t1.merchant_id
    ,t1.merchant_name
    ,t1.store_id
    ,t1.store_name
    ,t1.shopee_df as shopeedf
    ,t1.shopeedf_hashed
    ,t3.shopeedf_first_login_datetime_local
    ,t3.shopeedf_first_login_datetime_regional
    ,datediff(
        format_time ((t1.order_create_time), 'SG')
        ,t3.shopeedf_first_login_datetime_regional
    ) as shopeedf_age
    ,t1.sz_df as szdf
    ,szdf_first_login_datetime_local
    ,szdf_first_login_datetime_regional
    ,datediff(
        format_time ((t1.order_create_time), 'SG')
        ,t4.szdf_first_login_datetime_regional
    ) as szdf_age
    ,t1.apm_payment_channel_id as payment_channel_id
    ,t1.payment_method_name as payment_channel_name
    ,t1.apm_transaction_id
    ,t1.apm_payment_id
    ,t1.apm_payment_channel_ref as apm_channel_ref
    ,t1.apm_payment_channel_ref2 as apm_channel_ref2
    ,t1.apm_payment_channel_status as apm_channel_status
    ,t1.apm_encrypted_payment_id as encrypted_payment_id --extra是敏感，需修改
    ,t1.apm_provision_channel_id
    ,t1.apm_entity_id as apm_provision_entity_id
    ,t7.provision_channel_category as apm_provision_channel_category
    ,if (t8.reqno is null, 'old', 'new') as system_traffic
    ,t8.flow_no
    ,t8.scene_id
    ,t8.scene_name
    ,t8.Platform_type
    ,t8.app_type
    ,t8.platform_user_id
    ,t8.shopeedf_holmes
    ,t8.shenzhendf_holmes
    ,t8.ip_country
    ,t8.ip_city
    ,t1.currency
    ,get_json_object(t1.order_info, '$.off_us_details.off_us_switch') as off_us_switch
    ,get_json_object(
        order_info
        ,'$.off_us_details.duitnow_info.account_transaction.qr_category'
    ) as duitnow_qr_category
    ,t1.acquirer_id
    ,t1.external_merchant_id
    ,t1.merchant_host_name as merchant_host_name
    ,t1.publisher_name
    ,t1.tokenized_linking_id
    ,t2.status
    ,format_time ((t2.create_time), 'SG') as link_time_datetime_regional
    ,format_time ((t2.create_time), '${region_upper}') as link_time_datetime_local
    ,datediff(
        format_time ((t1.order_create_time), 'SG')
        ,format_time ((t2.create_time), 'SG')
    ) as link_age
    ,t1.order_create_date
from
    (
        select
            t11.shopeepay_user_id as shopeepay_user_id
            ,t11.product_flow
            ,t11.as_transaction_id
            ,t11.as_transaction_sn
            ,t11.as_order_sn
            ,t11.transaction_status
            ,t11.create_time
            ,t11.currency
            ,t11.actual_amount
            ,t11.actual_amount_usd
            ,t11.merchant_scope_name
            ,t11.order_info
            ,t11.merchant_host_id
            ,t11.merchant_host_name
            ,t11.merchant_id
            ,t11.merchant_name
            ,t11.store_id
            ,t11.store_name
            ,t11.publisher_name
            ,t11.transaction_extinfo
            ,t11.shopee_df
            ,t11.shopeedf_hashed
            ,t11.sz_df
            ,t11.apm_payment_channel_id
            ,t11.payment_method_name
            ,t11.apm_transaction_id
            ,t11.apm_payment_channel_ref
            ,t11.apm_payment_channel_ref2
            ,t11.apm_entity_id
            ,t11.apm_payment_id
            ,t11.apm_encrypted_payment_id
            ,t11.apm_provision_channel_id
            ,t11.apm_payment_channel_status

            ,t12.shopee_user_id as platform_user_id
            ,t11.create_time as order_create_time
            ,datediff(
                format_time ((t11.create_time), '${region_upper}')
                ,t13.registration_datetime
            ) as user_age
            ,case
                when '${region_lower}' = 'id' and product_flow in (1, 2) then get_json_object(
                    order_info
                    ,'$.off_us_details.qris_info.merchant_account_info.merchant_pan'
                )
                when '${region_lower}' = 'id' and product_flow = 4 then get_json_object(
                    order_info
                    ,'$.off_us_details.iso8583.primary_account_number'
                )
                when '${region_lower}' = 'my' then get_json_object(order_info, '$.off_us_details.acquirer_id')
                when '${region_lower}' = 'ph' then get_json_object(
                    order_info
                    ,'$.off_us_details.iso8583.acquiring_institution_identification_code'
                )
                when '${region_lower}' = 'sg' then get_json_object(
                    order_info
                    ,'$.off_us_details.nets_info.acquirer_institution_code'
                )
                else null
            end as acquirer_id
            ,case
                when '${region_lower}' = 'id' and product_flow in (1, 2) then get_json_object(
                    order_info
                    ,'$.off_us_details.qris_info.merchant_account_info.merchant_id'
                )
                when '${region_lower}' = 'id' and product_flow = 4 then get_json_object(order_info, '$.off_us_details.iso8583.card_acceptor_id')
                when '${region_lower}' = 'my' then get_json_object(
                    order_info
                    ,'$.off_us_details.duitnow_info.account_transaction.creditor_id'
                )
                when '${region_lower}' = 'ph' then get_json_object(
                    order_info
                    ,'$.off_us_details.qrph_info.external_merchant_id'
                )
                when '${region_lower}' = 'sg' then get_json_object(order_info, '$.off_us_details.external_unique_merchant_id')
                else null
            end as external_merchant_id
            ,get_json_object(transaction_extinfo, '$.tokenized_linking_id') as tokenized_linking_id
            ,date_format(
                format_time (t11.create_time, '${region_upper}')
                ,'yyyy-MM-dd'
            ) as order_create_date
        from
            (
                select
                    shopeepay_user_id
                    ,product_flow
                    ,as_transaction_id
                    ,as_transaction_sn
                    ,as_order_sn
                    ,transaction_status
                    ,create_time
                    ,currency
                    ,actual_amount
                    ,actual_amount_usd
                    ,merchant_scope_name
                    ,order_info
                    ,merchant_host_id
                    ,merchant_host_name
                    ,merchant_id
                    ,merchant_name
                    ,store_id
                    ,store_name
                    ,publisher_name
                    ,transaction_extinfo
                    ,shopee_df
                    ,lower(sha2(shopee_df, 256)) as shopeedf_hashed
                    ,sz_df
                    ,apm_payment_channel_id
                    ,payment_method_name
                    ,apm_transaction_id
                    ,apm_payment_channel_ref
                    ,apm_payment_channel_ref2
                    ,apm_entity_id
                    ,apm_payment_id
                    ,apm_encrypted_payment_id
                    ,apm_provision_channel_id
                    ,apm_payment_channel_status
                from shopeepay.mart_dwd_wide_user_order_acquiring_all_ent_df__${region_lower}
                where
                    (
                        transaction_type_name in ('Payment', 'Capture', 'Auth')
                        and partner_type_name = 'Merchant Payment'
                    )
                    and user_scope_name = 'On_us User'
                    and date_format(
                        format_time ((create_time), '${region_upper}')
                        ,'yyyy-MM-dd'
                    ) >= date_sub('${begin_ds}', 3)
                    and date_format(
                        format_time ((create_time), '${region_upper}')
                        ,'yyyy-MM-dd'
                    ) <= '${begin_ds}'
            ) t11
            left join shopeepay.mart_dwd_us_user_account_tab_df__${region_lower} t12 on t11.shopeepay_user_id = t12.shopeepay_user_id
            left join mp_user.dim_user__reg_s0_live t13 on t12.shopee_user_id = t13.user_id
            and t13.grass_date = '${begin_ds}'
            and t13.grass_region = '${region_upper}'
    ) t1
    left join (
        select
            as_linkage_id as linkage_id
            ,linkage_status as status
            ,cast(create_time_millisecond / 1000 as bigint) as create_time
        from shopeepay.mart_dwd_as_linkage_tab_df__${region_lower}
    ) t2 on t1.tokenized_linking_id = t2.linkage_id
    left join (
        select
            userid
            ,lower(hex(hashed_fingerprint)) as shopeedf_hashed
            ,format_time ((min(ctime)), '${region_upper}') as shopeedf_first_login_datetime_local
            ,format_time ((min(ctime)), 'SG') as shopeedf_first_login_datetime_regional
        -- from marketplace.shopee_device_extension_db__device_ext_tab__reg_continuous_s0_live
        from risk.dim_shopee_device_extension_v2_db__device_ext_tab__reg_df
        where grass_region = '${region_upper}'
        group by 1, 2
    ) t3 on t1.platform_user_id = t3.userid
    and t1.shopeedf_hashed = t3.shopeedf_hashed
    left join (
        select
            user_id
            ,security_device_id as szdf
            ,format_time ((min(created_timestamp)), '${region_upper}') as szdf_first_login_datetime_local
            ,format_time ((min(created_timestamp)), 'SG') as szdf_first_login_datetime_regional
        from antifraud_dw.dim_user_security_deviceid_linkage
        where grass_region = '${region_upper}'
        group by 1, 2
    ) t4 on t1.platform_user_id = t4.user_id
    and t1.sz_df = t4.szdf
    left join (
        select
            pps_provision_channel_id as apm_provision_channel_id
            ,provision_channel_category
        from shopeepay.mart_dim_pps_provision_channel_df__${region_lower}
        group by 1, 2
    ) t7 on t1.apm_provision_channel_id = t7.apm_provision_channel_id
    left join (
        select distinct
            seq_id
            ,reqno
            ,flow_no as flow_no
            ,risk_scene_id as scene_id
            ,case risk_scene_id
                when '80016' then 'MERCHANT_PAYMENT'
                when '80017' then 'MERCHANT_PAYMENT_PROMOTION_SELECTION'
                when '80018' then 'MERCHANT_PAYMENT_PROMOTION_REDEMPTION'
            end as scene_name
            ,platform_type as platform_type
            ,app_type as app_type
            ,platform_user_id as platform_user_id
            ,device_fingerprint as shopeedf_holmes
            ,get_json_object(
                extension
                ,'$.CommonHeader.extension_process_data.sz_dfp.device_id'
            ) as shenzhendf_holmes
            ,get_json_object(
                extension
                ,'$.CommonHeader.extension_process_data.ip_city_info.ip_country_name_v2'
            ) as ip_country
            ,get_json_object(
                extension
                ,'$.CommonHeader.extension_process_data.ip_city_info.ip_city_name_v2'
            ) as ip_city
            ,row_number() over (
                partition by reqno, seq_id
                order by create_time desc
            ) as rn
        from risk.dwd_risk_spp_gateway_req_rsp_final_result_di
        where
            risk_scene_id in ('80016', '80017', '80018')
            and grass_date <= '${begin_ds}'
            and grass_date >= date_sub('${begin_ds}', 365)
            and topic_name = '${region_lower}_live_spp_risk_gateway_req_rsp_spp'
    ) t8 on t1.as_transaction_sn = t8.reqno
;