--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-05-10
-- Theme Domain：       risk-spp_ws_remittance
-- Description:          
-- Data Granularity:    spp_user_id
-- 变更历史：
--      update by zongyi.lu@shopee.com，2024-05-10 1. dim_user_device_deviceid_df 改成 dim_user_security_deviceid_linkage(小时任务不用加依赖)  https://jira.shopee.io/browse/SPFDT-37230 2.新增注释
--********************************************************************--
add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar ;
drop temporary function if exists format_time;
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';
insert overwrite ${SCHEMA}.dws_risk_${region_lower}_spp_ws_remittance_wide_di PARTITION (grass_date)
select 
    t1.spp_user_id
    ,t1.order_type_code
    ,t1.order_type_name
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
    ,t1.receiver_apba_account_id
    ,t2.receiver_bank_account_number_encrypted
    ,t2.receiver_bank_account_binding_timestamp
    ,t2.receiver_bank_account_binding_datetime_local
    ,t2.receiver_bank_account_binding_datetime_regional
    ,datediff(t1.create_datetime_regional,t2.receiver_bank_account_binding_datetime_regional) as receiver_bank_account_age
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
    ,t5.apm_provision_entity_id
    ,t5.apm_provision_channel_id
    ,t5.apm_provision_channel_category
    ,if(t6.order_id is null,'old','new') as  system_traffic
    ,t6.flow_no
    ,t6.scene_id
    ,t6.scene_name
    ,t6.Platform_type
    ,t6.app_type
    ,t6.platform_user_id
    ,t6.shopeedf_holmes
    ,t6.shenzhendf_holmes
    ,t6.ip_country
    ,t6.ip_city
    ,t1.grass_date as grass_date
from 
(
    select 
        t11.user_id as spp_user_id
        ,t14.shopee_uid as platform_user_id
        ,t11.order_type as order_type_code
        ,t12.name as order_type_name
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
        ,if(t11.order_type=6,get_json_object(t11.extinfo_json,'${withdraw_account_id_jsonpath}'),get_json_object(t11.extinfo_json,'${remittance_account_id_jsonpath}')) as receiver_apba_account_id--不同国家这个不一样
        ,get_json_object(t11.extinfo_json,'$.shenzhen_df') as szdf
        ,get_json_object(t11.extinfo_json,'$.shopee_df') as shopeedf
        ,lower(sha2(get_json_object(t11.extinfo_json, '$.shopee_df'),256)) as shopeedf_hashed
        ,t11.grass_date
    from 
        --这些order_type代表remittance的数据
        (
            select 
                *,
                date_format(format_time((create_time), '${region_upper}'), 'yyyy-MM-dd') as grass_date 
            from 
                shopeepay.ods__shopeepay_uws_order_${region_lower}_db__order_tab__df__sensitive 
            where 
                sppd_c_date>=date_sub('${begin_ds}' ,4)
                and date_format(format_time((create_time), '${region_upper}'), 'yyyy-MM-dd')>= date_sub('${begin_ds}' ,3)
                and 
                date_format(format_time((create_time), '${region_upper}'), 'yyyy-MM-dd')<='${begin_ds}'
                and order_type in (5,6)
        ) t11 
    left join
        risk.enum_risk_spp t12 on t11.order_type=t12.value and t12.enum_name='uws_order_type'
    left join
        risk.enum_risk_spp t13 on t11.order_status=t13.value and t13.enum_name='uws_order_status'
    left join 
        shopeepay.ods__shopeepay_user_account_${region_lower}_db__user_account_tab__df t14 on t11.user_id=t14.uid 
    left join 
        mp_user.dim_user__reg_s0_live t15 on t14.shopee_uid=t15.user_id and t15.grass_date='${begin_ds}' and t15.grass_region='${region_upper}'
    cross join 
        (select exchange_rate from mp_order.dim_exchange_rate__reg_s0_live where grass_date='${begin_ds}' and grass_region='${region_upper}') t18
) t1
left join
(
    select
        apba_account_id 
        ,max(account_number) as receiver_bank_account_number_encrypted
        ,min(ctime) as receiver_bank_account_binding_timestamp
        ,format_time((min(ctime)), '${region_upper}') as receiver_bank_account_binding_datetime_local
        ,format_time((min(ctime)), 'SG') as receiver_bank_account_binding_datetime_regional
    from 
        shopeepay.dim_apba_${region_lower}_spp_bank_account_df
    group by 
        apba_account_id
) t2 
on t1.receiver_apba_account_id=t2.apba_account_id
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
    from
        (select * from shopeepay.ods__shopeepay_apm_provision_${region_lower}_db__provision_tab__df where sppd_c_date<='${begin_ds}' and channel_id=${region_channel_id}) t51
        left join 
        shopeepay.ods__shopeepay_apm_payment_${region_lower}_db__payment_tab__df__sensitive t52
        on t51.transaction_id=t52.transaction_id and t52.sppd_c_date<='${begin_ds}'
        left join 
        shopeepay.ods__wallet_payment_module_${region_lower}_db__payment_channel_tab__df t53
        on t52.channel_id=t53.channel_id 
 
) t5 
on t1.reference_id=t5.apm_provision_entity_id
left join 
(
    select
        --探查数据会有重复数据，所以需要去重，看了distinct的执行计划和group一致，所以直接写distinct
        distinct
        get_json_object(extension,'$.order_id') as order_id 
        ,flow_no as flow_no
        ,risk_scene_id as scene_id
        ,case risk_scene_id 
            when '80010' then 'Remittance Pre Check'
            when '80011' then 'Remittance'
            when '80009' then 'Withdraw'
            when '80008' then 'Withdraw Pre Check'

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
    and risk_scene_id in ('80011','80010','80008','80009')
    and grass_date<='${begin_ds}'
    and topic_name='${region_lower}_live_spp_risk_gateway_req_rsp_spp'
) t6 on t1.transaction_id=t6.order_id;


