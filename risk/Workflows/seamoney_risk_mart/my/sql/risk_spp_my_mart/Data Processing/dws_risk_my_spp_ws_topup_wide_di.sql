--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-05-10
-- Theme Domain：       risk-spp_ws_topup
-- Description:         
-- Data Granularity:    spp_user_id
-- 变更历史：
--      update by zongyi.lu@shopee.com，2024-05-10 1. dim_user_device_deviceid_df 改成 dim_user_security_deviceid_linkage(小时任务不用加依赖)  https://jira.shopee.io/browse/SPFDT-37230 2.新增注释
--      变更: wei.tao 从 shopee_device_extension_db__device_ext_tab__reg_continuous_s0_live 换表 dim_shopee_device_extension_v2_db__device_ext_tab__reg_df 
--      update by chengguo.liu@shopee.com:
--          card_tab逻辑更新为从3张表合并取数,shopeepay.ods__shopee_payment_module_my_db__card_tab__df + shopeepay.ods__wallet_payment_module_my_db__card_tab__df + shopeepay.ods__shopeepay_pps_user_asset_my_db__card_tab__df
--          linked_bank_account_tab逻辑更新为从3张表合并取数: ods__wallet_payment_module_my_db__linked_bank_account_tab__df__sensitive + shopee_payment_module_my_db__linked_bank_account_tab__reg_daily_s0_live + ods__shopeepay_pps_user_asset_my_db__linked_bank_account_tab__df
--********************************************************************--


add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar ;
drop temporary function if exists format_time;
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';
insert overwrite ${SCHEMA}.dws_risk_${region_lower}_spp_ws_topup_wide_di PARTITION (grass_date)
select 
    t1.spp_user_id
    ,t1.order_type_code
    ,t1.order_type_name
    ,case 
        when t1.topup_method = '0' then 'Manual Topup' 
        when t1.topup_method = '1' then 'Auto Topup'
        when t1.topup_method = '2' then 'Reverse Topup' 
        when t1.topup_method = '3' then 'Disbursement Topup' 
        when t1.topup_method = '4' then 'Cashin_onus Topup'
        when t1.topup_method = '5' then 'Cashin_offus Topup'
        else 'unknown' end as  topup_method
    ,t1.transaction_id
    ,t1.transaction_sn
    ,t1.reference_id
    ,t1.order_status_code
    ,t1.order_status_name
    ,t1.create_timestamp
    ,t1.create_datetime_local
    ,t1.create_datetime_regional
    ,t1.user_age
    ,t1.event_amount_local
    ,t1.event_amount_usd
    ,t1.shopeedf
    ,t1.shopeedf_hashed
    ,t3.shopeedf_first_login_datetime_local
    ,t3.shopeedf_first_login_datetime_regional
    ,datediff(t1.create_datetime_regional,t3.shopeedf_first_login_datetime_regional) as shopeedf_age
    ,t1.szdf
    ,t4.szdf_first_login_datetime_local
    ,t4.szdf_first_login_datetime_regional
    ,datediff(t1.create_datetime_regional,t4.szdf_first_login_datetime_regional) as szdf_age
    ,t5.payment_channel_id
    ,t5.payment_channel_name
    ,t5.apm_transaction_id
    ,t5.apm_payment_id
    ,t5.apm_channel_ref
    ,t5.apm_channel_ref2
    ,t5.apm_channel_status
    ,t5.encrypted_payment_id
    ,t5.apm_provision_channel_id
    ,t5.apm_provision_entity_id
    ,t5.apm_provision_channel_category
    ,t5.sent_for_3ds
    ,t5.authenticated_3ds
    ,t5.three_d_secure_version
    ,t5.eci
    ,t5.enroll_check
    ,t1.payment_channel_item_id
    ,t2.item_type
    ,t2.item_ref
    ,t2.channel_category
    ,t2.flag
    ,t2.channel_item_binding_time
    ,t2.channel_item_modified_time
    ,t2.card_brand_id
    ,t2.card_number
    ,t2.card_bin
    ,t2.status
    ,t2.card_tab_channel_category
    ,t2.fingerprint
    ,t2.identifier
    ,t2.identifier_new
    ,t2.expiry_date
    ,t2.card_index 
    ,t2.ctime
    ,t2.mtime
    ,t2.last_3ds_authenticated_time
    ,t2.card_name
    ,t7.bank_id
    ,t7.bank_number_type
    ,t7.bank_number_type_name
    ,t7.bank_number_brand
    ,t7.bank_number_brand_name
    ,t8.card_issuer_name
    ,t8.card_issue_country
    ,t8.card_category
    ,t8.card_bank_status
    ,t9.linkage_status
    ,t9.account_number
    ,t9.linked_bank_tab_channel_category
    ,t9.giro_bind_time
    ,t9.giro_etime
    ,t9.giro_mtime
    ,t9.device_fingerprint
    ,t9.is_handshake_successful
    ,if(t6.order_id is null,'old','new') as  system_traffic
    ,t6.flow_no
    ,t6.scene_id
    ,t6.scene_name
    ,t6.platform_type
    ,t6.app_type
    ,t6.platform_user_id
    ,t6.shopeedf_holmes
    ,t6.shenzhendf_holmes
    ,t6.ip_country
    ,t6.ip_city
    ,t1.user_registration_datetime
    ,t1.registration_channel
    ,t1.registration_ip_country
    ,t1.registration_ip_state
    ,t1.is_phone_verified
    ,t1.is_email_verified
    ,t1.has_set_up_password
    ,t1.kyc_level
    ,t1.kyc_create_time
    ,t1.kyc_id_no
    ,t1.id_type
    ,t1.kyc_device_fingerprint
    ,t1.kyc_device_ip
    ,t1.grass_date as grass_date
from 
(
    select 
        t11.user_id as spp_user_id
        ,t14.shopee_uid as platform_user_id
        ,t11.order_type as order_type_code
        ,t12.name as order_type_name
        ,get_json_object(t11.extinfo_json,'$.topup_extinfo.topup_type') as topup_method
        ,t11.order_id as transaction_id
        ,t11.order_sn as transaction_sn
        ,t11.reference_id as reference_id
        ,t11.order_status as order_status_code
        ,t13.name as order_status_name
        ,t11.create_time as create_timestamp
        ,format_time((t11.create_time), '${region_upper}') as create_datetime_local
        ,format_time((t11.create_time), 'SG') as create_datetime_regional
        ,datediff(format_time((t11.create_time), '${region_upper}'),t15.registration_datetime) as user_age
        ,t11.amount/100000 as event_amount_local
        ,t11.amount/(100000*t18.exchange_rate) as event_amount_usd
        ,get_json_object(t11.extinfo_json,'$.shenzhen_df') as szdf
        ,get_json_object(t11.extinfo_json,'$.shopee_df') as shopeedf
        ,lower(sha2(get_json_object(t11.extinfo_json, '$.shopee_df'),256)) as shopeedf_hashed
        ,t11.grass_date
        ,get_json_object(t11.extinfo_json,'$.topup_extinfo.payment_channel_options.channel_item_id') as payment_channel_item_id
        ,t15.registration_datetime as user_registration_datetime
        ,t16.registration_channel as registration_channel
        ,t16.registration_country as registration_ip_country
        ,t16.registration_state as registration_ip_state
        ,t15.is_phone_verified
        ,t15.is_email_verified
        ,t15.has_set_up_password
        ,t17.kyc_level
        ,t17.kyc_create_time
        ,t17.kyc_id_no
        ,t17.id_type
        ,t17.kyc_device_fingerprint
        ,t17.kyc_device_ip
    from (--这些order_type代表transfer的数据
            select 
                *,
                date_format(format_time((create_time), '${region_upper}'), 'yyyy-MM-dd') as grass_date 
            from shopeepay.ods__shopeepay_uws_order_${region_lower}_db__order_tab__df__sensitive 
            where 
            sppd_c_date>=date_sub('${begin_ds}' ,4)
            and date_format(format_time((create_time), '${region_upper}'), 'yyyy-MM-dd')>= date_sub('${begin_ds}' ,3)
            and 
            date_format(format_time((create_time), '${region_upper}'), 'yyyy-MM-dd')<='${begin_ds}'
            and order_type in (1)
        ) t11 
    left join   risk.enum_risk_spp t12 
    on t11.order_type=t12.value and t12.enum_name='uws_order_type'
    left join   risk.enum_risk_spp t13 
    on t11.order_status=t13.value and t13.enum_name='uws_order_status'
    left join   shopeepay.ods__shopeepay_user_account_${region_lower}_db__user_account_tab__df t14 
    on t11.user_id=t14.uid 
    left join   mp_user.dim_user__reg_s0_live t15 
    on t14.shopee_uid=t15.user_id and t15.grass_date='${begin_ds}' and t15.grass_region='${region_upper}'
    left join   mp_user.dwd_register_ent_di__reg_s0_live t16
    on t14.shopee_uid=t16.user_id  and t16.grass_region='${region_upper}'
    left join   ( 
                    select  t161.uid
                            ,case when t162.version_name like 'no%' then 'NO KYC'
                            when t162.version_name like 'partial%' then 'Partial KYC'
                            when t162.version_name like 'full%' then 'Full KYC' end as kyc_level
                            ,t162.create_time as kyc_create_time
                            ,t163.id_number_encrypt as kyc_id_no
                            ,t163.id_type as id_type
                            ,get_json_object(t163.extra_data,'$.device_fingerprint') as kyc_device_fingerprint
                            ,get_json_object(t163.extra_data,'$.device_ip') as kyc_device_ip

                    from    (
                                select  uid
                                        ,template_version
                                from    shopeepay.ods__shopeepay_kyc_${region_lower}_db__kyc_approved_info_tab__df
                            ) t161
                    left join shopeepay.ods__shopeepay_kyc_${region_lower}_db__kyc_version_tab__df t162
                    on  t161.template_version = t162.template_version
                    left join (select * from (
                                                select *,row_number() over (partition by uid,template_version order by create_time desc) as rn  from shopeepay.ods__shopeepay_kyc_${region_lower}_db__kyc_case_record_tab__df__sensitive
                                                ) where rn=1
                                ) t163
                    on t163.uid=t161.uid and t161.template_version=t163.template_version
                ) t17
    on t17.uid=t11.user_id   
    cross join  (
                    select 
                        exchange_rate 
                    from 
                        mp_order.dim_exchange_rate__reg_s0_live 
                    where 
                        grass_date='${begin_ds}' and grass_region='${region_upper}'
                ) t18
) t1
left join(
    select 
        channel_item_id
        ,t21.user_id
        ,item_type
        ,item_ref
        ,channel_category
        ,flag
        ,t21.ctime as channel_item_binding_time
        ,t21.mtime as channel_item_modified_time
        ,card_brand_id
        ,card_number
        ,card_bin
        ,status
        ,card_tab_channel_category
        ,fingerprint
        ,identifier
        ,identifier_new
        ,expiry_date
        ,card_index 
        ,t22.ctime
        ,t22.mtime
        ,last_3ds_authenticated_time
        ,card_name
    from (
            (select channel_item_id,user_id,item_type,item_ref,channel_category,flag,ctime,mtime from shopeepay.shopee_payment_module_${region_lower}_db__payment_channel_item_tab__reg_daily_s0_live) 
            union
            (select channel_item_id,user_id,item_type,item_ref,channel_category,flag,ctime,mtime from shopeepay.ods__wallet_payment_module_${region_lower}_db__payment_channel_item_tab__df)
            union
            (select channel_item_id,user_id,item_type,item_ref,channel_category,flag,ctime,mtime from shopeepay.ods__shopeepay_pps_user_asset_${region_lower}_db__payment_channel_item_tab__df) 
         ) t21
    left join (
            (select 
                user_id
                ,card_id
                ,card_brand_id
                ,card_number
                ,regexp_extract(card_number,'(^[0-9]{6,8})[xX]*',1) as card_bin
                ,status
                ,channel_category as card_tab_channel_category
                ,fingerprint
                ,identifier
                ,identifier_new
                ,expiry_date
                ,concat(card_number, '#', expiry_date) as card_index 
                ,ctime
                ,mtime
                ,get_json_object(extra_data, '$.last_3ds_authenticated_time') as last_3ds_authenticated_time
                ,get_json_object(extra_data, '$.card_name') as card_name
            from shopeepay.ods__shopee_payment_module_${region_lower}_db__card_tab__df)
            union
            (select 
                user_id
                ,card_id
                ,card_brand_id
                ,card_number
                ,regexp_extract(card_number,'(^[0-9]{6,8})[xX]*',1) as card_bin
                ,status
                ,channel_category as card_tab_channel_category
                ,fingerprint
                ,identifier
                ,identifier_new
                ,expiry_date
                ,concat(card_number, '#', expiry_date) as card_index 
                ,ctime
                ,mtime
                ,get_json_object(extra_data, '$.last_3ds_authenticated_time') as last_3ds_authenticated_time
                ,get_json_object(extra_data, '$.card_name') as card_name
             from shopeepay.ods__wallet_payment_module_${region_lower}_db__card_tab__df)
            union
            (select 
                user_id
                ,card_id
                ,card_brand_id
                ,card_number
                ,regexp_extract(card_number,'(^[0-9]{6,8})[xX]*',1) as card_bin
                ,status
                ,channel_category as card_tab_channel_category
                ,fingerprint
                ,identifier
                ,identifier_new
                ,expiry_date
                ,concat(card_number, '#', expiry_date) as card_index 
                ,ctime
                ,mtime
                ,get_json_object(extra_data, '$.last_3ds_authenticated_time') as last_3ds_authenticated_time
                ,get_json_object(extra_data, '$.card_name') as card_name
             from shopeepay.ods__shopeepay_pps_user_asset_${region_lower}_db__card_tab__df)
            )  t22
    on t21.user_id=t22.user_id
    and t21.item_ref=t22.card_id

) t2 
on t1.payment_channel_item_id=t2.channel_item_id
and t1.spp_user_id=t2.user_id
left join 
(
    select
        userid 
        ,lower(hex(hashed_fingerprint)) as shopeedf_hashed
        ,format_time((min(ctime)), '${region_upper}') as shopeedf_first_login_datetime_local
        ,format_time((min(ctime)), 'SG') as shopeedf_first_login_datetime_regional
    from 
        risk.dim_shopee_device_extension_v2_db__device_ext_tab__reg_df
    where 
        grass_region='${region_upper}'
    group by 
        1,2
) t3
on t1.platform_user_id=t3.userid and t1.shopeedf_hashed=t3.shopeedf_hashed
left join
(
    select 
        user_id
        ,security_device_id as szdf
        ,format_time((min(created_timestamp)), '${region_upper}') as szdf_first_login_datetime_local
        ,format_time((min(created_timestamp)), 'SG') as szdf_first_login_datetime_regional
    from 
        antifraud_dw.dim_user_security_deviceid_linkage
    where 
        grass_region='${region_upper}'
    group by 
        1,2
) t4
on t1.platform_user_id=t4.user_id and t1.szdf=t4.szdf
left join 
(
    select 
        t51.entity_id as apm_provision_entity_id
        ,t52.channel_id as payment_channel_id
        ,t53.name as payment_channel_name
        ,t51.transaction_id as apm_transaction_id
        ,t52.payment_id as  apm_payment_id
        ,t52.channel_ref as apm_channel_ref
        ,t52.channel_ref2 as apm_channel_ref2
        ,t52.channel_status as apm_channel_status
        ,get_json_object(t52.extra_data,'$.encrypted_payment_id') as encrypted_payment_id
        ,t52.channel_id as apm_provision_channel_id
        ,t53.category as apm_provision_channel_category
        ,cast(get_json_object(t52.extra_data,'$.use_3ds.is_enabled') as boolean) as sent_for_3ds
        ,cast(get_json_object(t52.extra_data,'$.use_3ds.is_authenticated') as boolean) as authenticated_3ds
        ,get_json_object(t52.extra_data,'$.three_d_secure_version') as three_d_secure_version
        ,cast(get_json_object(t52.extra_data,'$.commit_log.eci') as string) as eci
        ,cast(get_json_object(t52.extra_data,'$.commit_log.enroll_check') as string) as enroll_check
    from
        (select * from shopeepay.ods__shopeepay_apm_provision_${region_lower}_db__provision_tab__df where sppd_c_date<='${begin_ds}' ) t51
        left join 
        shopeepay.ods__shopeepay_apm_payment_${region_lower}_db__payment_tab__df__sensitive t52
        on t51.transaction_id=t52.transaction_id and t52.sppd_c_date<='${begin_ds}'
        left join 
        shopeepay.ods__wallet_payment_module_${region_lower}_db__payment_channel_tab__df t53
        on t52.channel_id=t53.channel_id 
 
) t5 
on t1.transaction_id=t5.apm_provision_entity_id
left join 
(
    select
        --探查数据会有重复数据，所以需要去重，看了distinct的执行计划和group一致，所以直接写distinct
        distinct
        get_json_object(extension,'$.order_id') as order_id 
        ,flow_no as flow_no
        ,risk_scene_id as scene_id
        ,case risk_scene_id 
            when '80012' then 'OPUP_PRE_CHECK' 
            when '80013' then 'TOPUP' 
            when '80014' then 'SETUP_AUTO_TOPUP' 
            when '80015' then 'AUTO_TOPUP' 
            end as scene_name
        ,platform_type as platform_type
        ,app_type as app_type
        ,platform_user_id as platform_user_id
        ,device_fingerprint as shopeedf_holmes
        ,get_json_object(extension,'$.CommonHeader.extension_process_data.sz_dfp.device_id') as shenzhendf_holmes
        ,get_json_object(extension,'$.CommonHeader.extension_process_data.ip_city_info.ip_country_name_v2') as ip_country
        ,get_json_object(extension,'$.CommonHeader.extension_process_data.ip_city_info.ip_city_name_v2') as ip_city
    from 
        risk.dwd_risk_spp_gateway_req_rsp_final_result_di
    where get_json_object(extension,'$.order_id') is not null 
    and risk_scene_id in ('80012','80013','80014','80015')
    and grass_date<='${begin_ds}'
    and topic_name='${region_lower}_live_spp_risk_gateway_req_rsp_spp'
) t6 on t1.transaction_id=t6.order_id
left join  (
                select 
                    bin
                    ,bank_id
                    ,type as bank_number_type
                    ,e71.name as bank_number_type_name
                    ,brand as bank_number_brand
                    ,e72.name as bank_number_brand_name
                from
                    shopeepay.ods__shopee_payment_module_${region_lower}_db__bank_identification_number_tab__df t71 
                left join risk.enum_risk_spp e71
                on t71.type=e71.value and e71.enum_name='bank_number_type'
                left join risk.enum_risk_spp e72
                on t71.brand=e72.value and e72.enum_name='bank_number_brand'
           ) t7 
on t2.card_bin=t7.bin
left join  (
                select 
                    bank_id
                    ,name as card_issuer_name
                    ,country as card_issue_country
                    ,get_json_object(extra_data,'$.card_category') as card_category
                    ,bank_status as card_bank_status
                from
                    shopeepay.shopee_payment_module_${region_lower}_db__issuing_bank_tab__reg_daily_s0_live
           ) t8 
on t7.bank_id=t8.bank_id
left join   (
                select 
                *
                from 
                (
                    select 
                    *
                    ,row_number() over (partition by id order by prior) as rn
                    from
                        ( 
                            (
                                select
                                    id 
                                    ,user_id
                                    ,linkage_status
                                    ,account_number
                                    ,channel_category as linked_bank_tab_channel_category
                                    ,ctime as giro_bind_time
                                    ,etime as giro_etime
                                    ,mtime as giro_mtime
                                    ,device_fingerprint
                                    ,get_json_object(extra_data,'$.is_handshake_successful') as is_handshake_successful
                                    ,1 as prior
                                from
                                    shopeepay.ods__wallet_payment_module_${region_lower}_db__linked_bank_account_tab__df__sensitive
                            )
                            union
                            (
                                select 
                                    id
                                    ,user_id
                                    ,linkage_status
                                    ,account_number
                                    ,channel_category as linked_bank_tab_channel_category
                                    ,ctime as giro_bind_time
                                    ,etime as giro_etime
                                    ,mtime as giro_mtime
                                    ,device_fingerprint
                                    ,get_json_object(extra_data,'$.is_handshake_successful') as is_handshake_successful
                                    ,2 as prior
                                from
                                    shopeepay.shopee_payment_module_${region_lower}_db__linked_bank_account_tab__reg_daily_s0_live
                            )
                            union
                            (
                                select 
                                    id
                                    ,user_id
                                    ,linkage_status
                                    ,account_number
                                    ,channel_category as linked_bank_tab_channel_category
                                    ,ctime as giro_bind_time
                                    ,etime as giro_etime
                                    ,mtime as giro_mtime
                                    ,device_fingerprint
                                    ,get_json_object(extra_data,'$.is_handshake_successful') as is_handshake_successful
                                    ,asset_type as prior
                                from
                                    shopeepay.ods__shopeepay_pps_user_asset_${region_lower}_db__linked_bank_account_tab__df
                            )
                       )
                ) where rn=1
            ) t9
on t9.id=t2.item_ref and t2.user_id=t9.user_id
;



