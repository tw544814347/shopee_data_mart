--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-05-16
-- Theme Domain：       risk graph
-- Description:         user graph相关的数据(边)
-- Data Granularity:    platform_user_id
-- update by zongyi.lu@shopee.com 2024-05-16 https://jira.shopee.io/browse/SPFDT-36928 1.新增dp_account_no边,ph 不需要kyc边, 2.优化-数据源改成mart表
-- credit.ods__credit_usercenter_member_${region}_db__user_contact_info_tab__sensitive -> credit_uc.dwd_uc_{region}_user_contact_info_df
-- digitalpurchase.shopee_digital_product_order_v2_${region}_db__order_tab__reg_daily_s0_live -> digitalpurchase.order_dwd_dp_trd_ord_df
-- 因为BR 很多表虽然存在但是marker跟sg都不太一样,因此先不用模板
-- update by zongyi.lu@shopee.com 2024-09-19 credit_card 逻辑更新https://jira.shopee.io/browse/SPFDT-43764
-- update by zongyi.lu@shopee.com dwd_ofo_all_ent_df__reg_live 中的extinfo 改了结构, 多加一层 logistics_info
-- update by wei.tao@shopee.com jira:https://jira.shopee.io/browse/SPFDT-46841
--********************************************************************--
 
create or replace temporary function phone_number_parse as 'com.shopee.udf.PhoneNumberParse' using jar 'hdfs://${IDC_NAMESPACE}/projects/risk/hdfs/udf/seamoney-risk-tool-udf-1.0-SNAPSHOT-jar-with-dependencies.jar';
create or replace temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp' using jar 'hdfs://${IDC_NAMESPACE}/projects/credit/hdfs/udf/hive-udf.jar';

insert overwrite table risk.dws_risk_graph_edge_user_info_df partition(grass_region,edge_name,grass_date)
select 
    t2.platform_user_id,
    t1.hash_platform_user_id,
    t2.destination_node,
    t2.hash_destination_node,
    t2.create_date,
    t2.last_date,
    t2.extend_info,
    t2.grass_region,
    t2.edge_name,
    t2.grass_date
from
(
    select  xxhash64(concat('userid/', user_id)) as hash_platform_user_id
    from    mp_user.dim_user__reg_s0_live
    where   tz_type = 'local'
      and   grass_region = '${grass_region}'
      and   grass_date = '${grass_date}'
) t1
inner join
(
    -- login
    select  concat('userid/', userid) as platform_user_id
            ,xxhash64(concat('userid/', userid)) as hash_platform_user_id
            ,concat('device/', device) as destination_node
            ,xxhash64(concat('device/', device)) as hash_destination_node
            ,cast(create_date as string) as create_date
            ,cast(last_date as string) as last_date
            ,to_json(
                named_struct(
                    'userid',userid
                    ,'device',device
                    ,'event_day_count',event_day_count
                    ,'event_day_count_l3d',event_day_count_l3d
                    ,'event_day_count_l7d',event_day_count_l7d
                    ,'event_day_count_l30d',event_day_count_l30d
                    ,'event_day_count_l90d',event_day_count_l90d
                    ,'event_day_count_l180d',event_day_count_l180d
                    ,'event_day_count_l360d',event_day_count_l360d
                    ,'event_day_count_l720d',event_day_count_l720d
                    ,'device_type',device_type
                )
            ) as extend_info
            ,'${grass_region}' as grass_region
            ,'login' as edge_name
            ,'${grass_date}' as grass_date
    from    (
        --login_spdf--
        select  userid
                ,device
                ,min(grass_date) as create_date
                ,max(grass_date) as last_date
                ,count(grass_date) as event_day_count
                ,count(case when datediff('${grass_date}', grass_date) < 3 then grass_date end) as event_day_count_l3d
                ,count(case when datediff('${grass_date}', grass_date) < 7 then grass_date end) as event_day_count_l7d
                ,count(case when datediff('${grass_date}', grass_date) < 30 then grass_date end) as event_day_count_l30d
                ,count(case when datediff('${grass_date}', grass_date) < 90 then grass_date end) as event_day_count_l90d
                ,count(case when datediff('${grass_date}', grass_date) < 180 then grass_date end) as event_day_count_l180d
                ,count(case when datediff('${grass_date}', grass_date) < 360 then grass_date end) as event_day_count_l360d
                ,count(case when datediff('${grass_date}', grass_date) < 720 then grass_date end) as event_day_count_l720d
                ,'1' as device_type
        from    (
            select  user_id as userid
                    ,shopee_df as device
                    ,grass_date
            from    risk.dws_risk_user_device_login_di
            where   tz_type = 'local'
              and   grass_region = '${grass_region}'
              and   grass_date <= '${grass_date}'
              and   coalesce(trim(shopee_df), '') <> ''
            group by user_id, shopee_df, grass_date
        )
        group by userid, device
        union all
        --login_szdf--
        select  userid
                ,device
                ,min(grass_date) as create_date
                ,max(grass_date) as last_date
                ,count(grass_date) as event_day_count
                ,count(case when datediff('${grass_date}', grass_date) < 3 then grass_date end) as event_day_count_l3d
                ,count(case when datediff('${grass_date}', grass_date) < 7 then grass_date end) as event_day_count_l7d
                ,count(case when datediff('${grass_date}', grass_date) < 30 then grass_date end) as event_day_count_l30d
                ,count(case when datediff('${grass_date}', grass_date) < 90 then grass_date end) as event_day_count_l90d
                ,count(case when datediff('${grass_date}', grass_date) < 180 then grass_date end) as event_day_count_l180d
                ,count(case when datediff('${grass_date}', grass_date) < 360 then grass_date end) as event_day_count_l360d
                ,count(case when datediff('${grass_date}', grass_date) < 720 then grass_date end) as event_day_count_l720d
                ,'2' as device_type
        from    (
            select  user_id as userid
                    ,sz_dfp_device_id as device
                    ,grass_date
            from    risk.dws_risk_user_sz_device_login_di
            where   tz_type = 'local'
              and   grass_region = '${grass_region}'
              and   grass_date <= '${grass_date}'
              and   coalesce(trim(sz_dfp_device_id), '') <> ''
              and   user_id <> 0
            group by user_id, sz_dfp_device_id, grass_date
        )
        group by userid, device
    )

    -- bank_account
    union all
    select  concat('userid/', userid) as src_vertex
            ,xxhash64(concat('userid/', userid)) as hash_src_vertex
            ,concat('bank_account/', full_account) as dst_vertex
            ,xxhash64(concat('bank_account/', full_account)) as hash_dst_vertex
            ,cast(create_date as string) as create_date
            ,cast(last_date as string) as last_date
            ,to_json(
                named_struct(
                    'userid',userid
                    ,'full_account',full_account
                    ,'account_number',account_number
                    ,'account_name',account_name
                    ,'bank_name_id',bank_name_id
                    ,'bank_name',bank_name
                    ,'status',status
                    ,'is_seller_withdrawal_account',is_seller_withdrawal_account
                )
            ) as extend_info
            ,'${grass_region}' as grass_region
            ,'bank_account' as edge_name
            ,'${grass_date}' as grass_date
    from    (
        select  userid
                ,full_account
                ,account_number
                ,account_name
                ,bank_name
                ,is_seller_withdrawal_account
                ,bank_name_id
                ,status
                ,create_date
                ,last_date
        from(
            select  userid
                    ,full_account
                    ,account_number
                    ,account_name
                    ,bank_name
                    ,coalesce(is_seller_withdrawal_account, 0) as is_seller_withdrawal_account
                    ,bank_name_id
                    ,status
                    ,min(create_date) over (partition by userid, full_account) as create_date
                    ,max(create_date) over (partition by userid, full_account) as last_date
                    ,row_number() over (
                        partition by userid, full_account 
                        order by create_date desc
                    ) as rnk
            from    (
                select  shopee_user_id as userid
                        ,concat_ws(',',
                            payout_bank_account_number_sensitive_data_hash,
                            payout_bank_name
                         ) as full_account
                        ,payout_bank_account_number_sensitive_data_hash as account_number
                        ,lower(trim(payout_bank_account_name)) as account_name
                        ,payout_bank_name_id as bank_name_id
                        ,payout_bank_name as bank_name
                        ,payout_bank_account_status as status
                        ,spm_payout_bank_account_id as id
                        ,from_unixtime(create_time, 'yyyy-MM-dd') as create_date
                from    shopeepay.mart_dim_spm_payout_bank_account_df__${region}
                where   from_unixtime(create_time, 'yyyy-MM-dd') <= '${grass_date}'
                  and   coalesce(trim(payout_bank_account_number_sensitive_data_hash), '') <> ''
                  and   payout_bank_name_id <> 0
                  and   lower(payout_bank_account_name) not like '%shopee%'
                  and   create_time <> 0
            ) a
            left join (
                select  bank_account_id
                        ,1 as is_seller_withdrawal_account
                from    mp_order.dwd_seller_wallet_withdrawal_all_ent_df__reg_live
                where   grass_region = '${grass_region}'
                  and   grass_date <= '${grass_date}'
                  and   bank_account_id <> 0
                  and   withdrawal_status_id = 4
                group by bank_account_id
            ) b
            on a.id = b.bank_account_id
        )
        where rnk = 1
    )

    -- register_email
    union all
    select  concat('userid/', userid) as src_vertex
            ,xxhash64(concat('userid/', userid)) as hash_src_vertex
            ,concat('email/', email) as dst_vertex
            ,xxhash64(concat('email/', email)) as hash_dst_vertex
            ,cast(create_date as string) as create_date
            ,cast(last_date as string) as last_date
            ,to_json(
                named_struct(
                    'userid',userid
                    ,'email',email
                )
            ) as extend_info
            ,'${grass_region}' as grass_region
            ,'register_email' as edge_name
            ,'${grass_date}' as grass_date
    from    (
        select  userid
                ,email
                ,min(grass_date) as create_date
                ,max(grass_date) as last_date
        from    (
            select  user_id as userid
                    ,email
                    ,grass_date
            from    mp_user.dim_user__reg_s1_live
            where   tz_type = 'local'
              and   grass_region = '${grass_region}'
              and   grass_date = '${grass_date}'
            union
            select  user_id as userid
                    ,old_value as email
                    ,grass_date
            from    mp_user.dwd_account_audit_changelog_di__reg_s1_live
            where   tz_type = 'local'
              and   grass_region = '${grass_region}'
              and   account_change_type = 'email'
            union
            select  user_id as userid
                    ,new_value as email
                    ,grass_date
            from    mp_user.dwd_account_audit_changelog_di__reg_s1_live
            where   tz_type = 'local'
              and   grass_region = '${grass_region}'
              and   account_change_type = 'email'
        )
        where   coalesce(trim(email), '') <> ''
          and   email like '%_@__%.__%'
          and   email not rlike '@(shopee|seamoney|seagroup|sea|shopeemobile|garena)\\.com'
        group by userid, email
    )

    -- register_phone
    union all
    select  concat('userid/', userid) as src_vertex
            ,xxhash64(concat('userid/', userid)) as hash_src_vertex
            ,concat('phone/', phone) as dst_vertex
            ,xxhash64(concat('phone/', phone)) as hash_dst_vertex
            ,cast(create_date as string) as create_date
            ,cast(last_date as string) as last_date
            ,to_json(
                named_struct(
                    'userid',userid
                    ,'phone',phone
                )
            ) as extend_info
            ,'${grass_region}' as grass_region
            ,'register_phone' as edge_name
            ,'${grass_date}' as grass_date
    from    (
        select  userid
                ,phone
                ,min(grass_date) as create_date
                ,max(grass_date) as last_date
        from    (
            select  user_id as userid
                    ,phone_number_parse(coalesce(phone_number, ''), '${grass_region}') as phone
                    ,grass_date
            from    mp_user.dim_user__reg_s1_live
            where   tz_type = 'local'
              and   grass_region = '${grass_region}'
              and   grass_date = '${grass_date}'
            union
            select  user_id as userid
                    ,phone_number_parse(coalesce(old_value, ''), '${grass_region}') as phone
                    ,grass_date
            from    mp_user.dwd_account_audit_changelog_di__reg_s1_live
            where   tz_type = 'local'
              and   grass_region = '${grass_region}'
              and   account_change_type = 'phone'
            union
            select  user_id as userid
                    ,phone_number_parse(coalesce(new_value, ''), '${grass_region}') as phone
                    ,grass_date
            from    mp_user.dwd_account_audit_changelog_di__reg_s1_live
            where   tz_type = 'local'
              and   grass_region = '${grass_region}'
              and   account_change_type = 'phone'
        )
        where   phone <> ''
        group by userid, phone
    )

    -- ec_phone
    union all
    select  concat('userid/', userid) as platform_user_id
            ,xxhash64(concat('userid/', userid)) as hash_platform_user_id
            ,concat('phone/', phone) as destination_node
            ,xxhash64(concat('phone/', phone)) as hash_destination_node
            ,cast(create_date as string) as create_date
            ,cast(last_date as string) as last_date
            ,to_json(
                named_struct(
                    'userid',userid
                    ,'phone',phone
                    ,'relation',relation
                    ,'name',name
                )
            ) as extend_info
            ,'${grass_region}' as grass_region
            ,'ec_phone' as edge_name
            ,'${grass_date}' as grass_date
    from    (
        select  userid
                ,phone
                ,create_date
                ,create_date as last_date
                ,relation
                ,name
        from    (
            select  credit_user_id as user_id
                    ,phone_number_parse(coalesce(contact_phone, ''), '${grass_region}') as phone
                    ,contact_relationship as relation
                    ,lower(trim(contact_name)) as name
                    ,date_format(create_time, 'yyyy-MM-dd') as create_date
            from credit_uc.dwd_uc_${region}_user_contact_info_df
            where   date(create_time) <= '${grass_date}'
            and grass_date='${grass_date}'
        ) a
        inner join (
            select  platform_user_id as userid
                    ,user_id
            from    credit.ods__credit_usercenter_member_${region}_db__user_platform_info_tab__df
            where   grass_date = '${grass_date}'
              and   platform_type = 1
        ) b
        on a.user_id = b.user_id
        where   phone <> ''
    )

    -- buyer_shipping_phone
    union all
    select  concat('userid/', userid) as platform_user_id
            ,xxhash64(concat('userid/', userid)) as hash_platform_user_id
            ,concat('phone/', phone) as destination_node
            ,xxhash64(concat('phone/', phone)) as hash_destination_node
            ,cast(create_date as string) as create_date
            ,cast(last_date as string) as last_date
            ,to_json(
                named_struct(
                    'userid',userid
                    ,'phone',phone
                    ,'event_count',event_count
                    ,'event_count_l3d',event_count_l3d
                    ,'event_count_l7d',event_count_l7d
                    ,'event_count_l30d',event_count_l30d
                    ,'event_count_l90d',event_count_l90d
                    ,'event_count_l180d',event_count_l180d
                    ,'event_count_l360d',event_count_l360d
                    ,'event_count_l720d',event_count_l720d
                )
            ) as extend_info
            ,'${grass_region}' as grass_region
            ,'buyer_shipping_phone' as edge_name
            ,'${grass_date}' as grass_date
    from    (
        select  userid
                ,phone
                ,min(grass_date) as create_date
                ,max(grass_date) as last_date
                ,sum(1) as event_count
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 3 then 1 end), 0) as event_count_l3d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 7 then 1 end), 0) as event_count_l7d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 30 then 1 end), 0) as event_count_l30d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 90 then 1 end), 0) as event_count_l90d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 180 then 1 end), 0) as event_count_l180d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 360 then 1 end), 0) as event_count_l360d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 720 then 1 end), 0) as event_count_l720d
        from (
            select  buyer_id as userid
                    ,phone_number_parse(coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.phone'), ''), '${grass_region}')  as phone
                    ,cast(date(create_datetime) as string) as grass_date
            from    mp_order.dwd_ofo_all_ent_df__reg_live
            where   grass_region = '${grass_region}'
              and   date(create_datetime) <= '${grass_date}'
        ) a
        inner join (
                select  buyer_id as user_id
            from    mp_order.dwd_ofo_all_ent_df__reg_live
            where   grass_region = '${grass_region}'
            group by buyer_id
            having  coalesce(sum(cast (GET_JSON_OBJECT(extinfo,'$.dropshipping_info.enabled') as int)), 0) = 0
        ) b
        on a.userid = b.user_id
        where   phone <> ''
        group by userid, phone
    )

    -- seller_shipping_phone
    union all
    select  concat('userid/', userid) as platform_user_id
            ,xxhash64(concat('userid/', userid)) as hash_platform_user_id
            ,concat('phone/', phone) as destination_node
            ,xxhash64(concat('phone/', phone)) as hash_destination_node
            ,cast(create_date as string) as create_date
            ,cast(last_date as string) as last_date
            ,to_json(
                named_struct(
                    'userid',userid
                    ,'phone',phone
                    ,'event_count',event_count
                    ,'event_count_l3d',event_count_l3d
                    ,'event_count_l7d',event_count_l7d
                    ,'event_count_l30d',event_count_l30d
                    ,'event_count_l90d',event_count_l90d
                    ,'event_count_l180d',event_count_l180d
                    ,'event_count_l360d',event_count_l360d
                    ,'event_count_l720d',event_count_l720d
                )
            ) as extend_info
            ,'${grass_region}' as grass_region
            ,'seller_shipping_phone' as edge_name
            ,'${grass_date}' as grass_date
    from    (
        select  userid
                ,phone
                ,min(grass_date) as create_date
                ,max(grass_date) as last_date
                ,sum(1) as event_count
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 3 then 1 end), 0) as event_count_l3d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 7 then 1 end), 0) as event_count_l7d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 30 then 1 end), 0) as event_count_l30d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 90 then 1 end), 0) as event_count_l90d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 180 then 1 end), 0) as event_count_l180d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 360 then 1 end), 0) as event_count_l360d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 720 then 1 end), 0) as event_count_l720d
        from (
            select  GET_JSON_OBJECT(extinfo,'$.logistics_info.seller_address.userid') as userid
                ,phone_number_parse(coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.seller_address.phone'), ''), '${grass_region}') as phone
                ,cast(date(create_datetime) as string) as grass_date
            from mp_order.dwd_ofo_all_ent_df__reg_live
            where
                grass_region = '${grass_region}'
                and date(from_unixtime(create_timestamp)) <= date '${grass_date}'
        )
        where   phone <> ''
        group by userid, phone
    )

    -- buyer_topup_phone
    union all
    select  concat('userid/', userid) as platform_user_id
            ,xxhash64(concat('userid/', userid)) as hash_platform_user_id
            ,concat('phone/', phone) as destination_node
            ,xxhash64(concat('phone/', phone)) as hash_destination_node
            ,cast(create_date as string) as create_date
            ,cast(last_date as string) as last_date
            ,to_json(
                named_struct(
                    'userid',userid
                    ,'phone',phone
                    ,'event_count',event_count
                    ,'event_count_l3d',event_count_l3d
                    ,'event_count_l7d',event_count_l7d
                    ,'event_count_l30d',event_count_l30d
                    ,'event_count_l90d',event_count_l90d
                    ,'event_count_l180d',event_count_l180d
                    ,'event_count_l360d',event_count_l360d
                    ,'event_count_l720d',event_count_l720d
                )
            ) as extend_info
            ,'${grass_region}' as grass_region
            ,'buyer_topup_phone' as edge_name
            ,'${grass_date}' as grass_date
    from    (
        select  userid
                ,phone
                ,min(grass_date) as create_date
                ,max(grass_date) as last_date
                ,sum(1) as event_count
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 3 then 1 end), 0) as event_count_l3d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 7 then 1 end), 0) as event_count_l7d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 30 then 1 end), 0) as event_count_l30d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 90 then 1 end), 0) as event_count_l90d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 180 then 1 end), 0) as event_count_l180d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 360 then 1 end), 0) as event_count_l360d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 720 then 1 end), 0) as event_count_l720d
        from    (
            select  user_id as userid
                    ,phone_number_parse(coalesce(phone_number, ''), '${grass_region}') as phone
                    ,from_unixtime(create_time, 'yyyy-MM-dd') as grass_date
            -- from    digitalpurchase.shopee_digital_product_order_v2_${region}_db__order_tab__reg_daily_s0_live
            from    digitalpurchase.order_dwd_dp_trd_ord_df
            where   from_unixtime(create_time, 'yyyy-MM-dd') <= '${grass_date}'
              and   category_id in (10101,10102)
              and   payment_status = 'P2'
              and   order_status = 'OR6'
              and   grass_region ='${grass_region}'
              and   grass_date = '${grass_date}'
        )
        where   phone <> ''
        group by userid, phone
    )

    -- buyer_postpaid_phone
    union all
    select  concat('userid/', userid) as platform_user_id
            ,xxhash64(concat('userid/', userid)) as hash_platform_user_id
            ,concat('phone/', phone) as destination_node
            ,xxhash64(concat('phone/', phone)) as hash_destination_node
            ,cast(create_date as string) as create_date
            ,cast(last_date as string) as last_date
            ,to_json(
                named_struct(
                    'userid',userid
                    ,'phone',phone
                    ,'event_count',event_count
                    ,'event_count_l3d',event_count_l3d
                    ,'event_count_l7d',event_count_l7d
                    ,'event_count_l30d',event_count_l30d
                    ,'event_count_l90d',event_count_l90d
                    ,'event_count_l180d',event_count_l180d
                    ,'event_count_l360d',event_count_l360d
                    ,'event_count_l720d',event_count_l720d
                )
            ) as extend_info
            ,'${grass_region}' as grass_region
            ,'buyer_postpaid_phone' as edge_name
            ,'${grass_date}' as grass_date
    from    (
        select  userid
                ,phone
                ,min(grass_date) as create_date
                ,max(grass_date) as last_date
                ,sum(1) as event_count
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 3 then 1 end), 0) as event_count_l3d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 7 then 1 end), 0) as event_count_l7d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 30 then 1 end), 0) as event_count_l30d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 90 then 1 end), 0) as event_count_l90d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 180 then 1 end), 0) as event_count_l180d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 360 then 1 end), 0) as event_count_l360d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 720 then 1 end), 0) as event_count_l720d
        from    (
            select  user_id as userid
                    -- ,case '${grass_region}'
                    --     when 'ID' then phone_number_parse(coalesce(customer_id, ''), '${grass_region}')
                    --     when 'PH' then phone_number_parse(coalesce(
                    --                     get_json_object(details, '$.bill_fill_detail.ecpay_name'),
                    --                     get_json_object(details, '$.identifier'),
                    --                     ''), '${grass_region}')
                    -- end as phone
                    ,phone_number_parse(coalesce(customer_id, ''), '${grass_region}') as phone
                    ,from_unixtime(create_time, 'yyyy-MM-dd') as grass_date
            -- from    digitalpurchase.shopee_digital_product_order_v2_${region}_db__order_tab__reg_daily_s0_live
            from    digitalpurchase.order_dwd_dp_trd_ord_df
            where   from_unixtime(create_time, 'yyyy-MM-dd') <= '${grass_date}'
              and   category_id in (20108)
              and   payment_status = 'P2'
              and   order_status = 'OR6'
              and   grass_region ='${grass_region}'
              and   grass_date = '${grass_date}'
            --   and   case '${grass_region}'
            --           when 'ID' then true
            --           when 'PH' then item_name in ('SUN CELLULAR','SMART Mobile Phone')
            --         end = true
        )
        where   phone <> ''
        group by userid, phone
    )

    -- credit_card
    union all
    select  concat('userid/', userid) as src_vertex
            ,xxhash64(concat('userid/', userid)) as hash_src_vertex
            ,concat('credit_card/', credit_card) as dst_vertex
            ,xxhash64(concat('credit_card/', credit_card)) as hash_dst_vertex
            ,cast(create_date as string) as create_date
            ,cast(last_date as string) as last_date
            ,to_json(
                named_struct(
                    'userid',userid
                    ,'credit_card',credit_card
                    ,'card_number',card_number
                    ,'expiry_date',expiry_date
                    ,'status',status
                )
            ) as extend_info
            ,'${grass_region}' as grass_region
            ,'credit_card' as edge_name
            ,'${grass_date}' as grass_date
    from    (
        select  userid
                ,credit_card
                ,card_number
                ,expiry_date
                ,status
                ,create_date
                ,last_date
        from(
            select  userid
                    ,credit_card
                    ,card_number
                    ,expiry_date
                    ,status
                    ,min(grass_date) over (partition by userid, credit_card) as create_date
                    ,max(grass_date) over (partition by userid, credit_card) as last_date
                    ,row_number() over (partition by userid, credit_card order by grass_date desc) as rnk
            from    (
                select  shopee_user_id as userid
                        ,case
                            when '${grass_region}' IN ('ID')
                                then concat_ws(
                                    ',',
                                    card_number,
                                    expiry_date
                                )
                            when '${grass_region}' IN ('PH','MY','SG','TH','VN','BR')  then fingerprint
                        end as credit_card
                        ,from_unixtime(create_time, 'yyyy-MM-dd') as grass_date
                        ,card_number
                        ,expiry_date
                        ,linkage_status as status
                from    shopeepay.mart_dim_payment_channel_item_df__${region}
                where   from_unixtime(create_time, 'yyyy-MM-dd') <= '${grass_date}'
                  and  case
                          when '${grass_region}' IN ('ID')  then coalesce(card_number, '') <> '' and coalesce(expiry_date, '') <> ''
                          when '${grass_region}' IN ('PH','MY','SG','TH','VN','BR') then coalesce(fingerprint, '') <> ''
                        end = true
                    and shopee_user_id != 0
            )
            where   credit_card not in ('BIN_NOT_FOUND_IN_APCC','CARD_EXPIRED')
        )
        where rnk = 1
    )

    -- buyer_shipping_address
    union all
    select  concat('userid/', userid) as platform_user_id
            ,xxhash64(concat('userid/', userid)) as hash_platform_user_id
            ,concat('address/', full_address) as destination_node
            ,xxhash64(concat('address/', full_address)) as hash_destination_node
            ,cast(create_date as string) as create_date
            ,cast(last_date as string) as last_date
            ,to_json(
                named_struct(
                    'userid',userid
                    ,'full_address',full_address
                    ,'address',address
                    ,'town',town
                    ,'district',district
                    ,'city',city
                    ,'state',state
                    ,'zipcode',zipcode
                    ,'event_count',event_count
                    ,'event_count_l3d',event_count_l3d
                    ,'event_count_l7d',event_count_l7d
                    ,'event_count_l30d',event_count_l30d
                    ,'event_count_l90d',event_count_l90d
                    ,'event_count_l180d',event_count_l180d
                    ,'event_count_l360d',event_count_l360d
                    ,'event_count_l720d',event_count_l720d
                )
            ) as extend_info
            ,'${grass_region}' as grass_region
            ,'buyer_shipping_address' as edge_name
            ,'${grass_date}' as grass_date
    from    (
        select  userid
                ,full_address
                ,min(grass_date) as create_date
                ,max(grass_date) as last_date
                ,address
                ,town
                ,district
                ,city
                ,state
                ,zipcode
                ,sum(1) as event_count
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 3 then 1 end), 0) as event_count_l3d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 7 then 1 end), 0) as event_count_l7d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 30 then 1 end), 0) as event_count_l30d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 90 then 1 end), 0) as event_count_l90d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 180 then 1 end), 0) as event_count_l180d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 360 then 1 end), 0) as event_count_l360d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 720 then 1 end), 0) as event_count_l720d
        from (
            select  buyer_id as userid
                    ,concat_ws(',',
                        trim(lower(regexp_replace(coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.address'),''), '[^a-zA-Z0-9]+', ' '))),
                        coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.town'),''),
                        coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.district'),''),
                        coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.city'),''),
                        coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.state'),''),
                        coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.zipcode'),'')
                        ) as full_address
                    ,trim(lower(regexp_replace(coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.address'),''), '[^a-zA-Z0-9]+', ' '))) as address
                    ,coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.town'),'')               as town
                    ,coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.district') ,'')          as district
                    ,coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.city') ,'')              as city
                    ,coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.state') ,'')             as state
                    ,coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.zipcode') ,'')           as zipcode
                    ,cast(date(create_datetime) as string) as grass_date
            from    mp_order.dwd_ofo_all_ent_df__reg_live
            where   grass_region = '${grass_region}'
            and   date(create_datetime) <=date( '${grass_date}')
            and   length(trim(lower(regexp_replace(coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.address'),''), '[^a-zA-Z0-9]+', ' ')))) >= 10
        ) a
        inner join (
            select  buyer_id as user_id
            from    mp_order.dwd_ofo_all_ent_df__reg_live
            where   grass_region = '${grass_region}'
            group by buyer_id
            having  coalesce(sum(cast (GET_JSON_OBJECT(extinfo,'$.dropshipping_info.enabled') as int)), 0) = 0
        ) b
        on a.userid = b.user_id
        group by userid, full_address, address, town, district, city, state, zipcode
    )

    -- seller_shipping_address
    union all
    select  concat('userid/', userid) as platform_user_id
            ,xxhash64(concat('userid/', userid)) as hash_platform_user_id
            ,concat('address/', full_address) as destination_node
            ,xxhash64(concat('address/', full_address)) as hash_destination_node
            ,cast(create_date as string) as create_date
            ,cast(last_date as string) as last_date
            ,to_json(
                named_struct(
                    'userid',userid
                    ,'full_address',full_address
                    ,'address',address
                    ,'town',town
                    ,'district',district
                    ,'city',city
                    ,'state',state
                    ,'zipcode',zipcode
                    ,'event_count',event_count
                    ,'event_count_l3d',event_count_l3d
                    ,'event_count_l7d',event_count_l7d
                    ,'event_count_l30d',event_count_l30d
                    ,'event_count_l90d',event_count_l90d
                    ,'event_count_l180d',event_count_l180d
                    ,'event_count_l360d',event_count_l360d
                    ,'event_count_l720d',event_count_l720d
                )
            ) as extend_info
            ,'${grass_region}' as grass_region
            ,'seller_shipping_address' as edge_name
            ,'${grass_date}' as grass_date
    from    (
        select  userid
                ,full_address
                ,min(grass_date) as create_date
                ,max(grass_date) as last_date
                ,address
                ,town
                ,district
                ,city
                ,state
                ,zipcode
                ,sum(1) as event_count
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 3 then 1 end), 0) as event_count_l3d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 7 then 1 end), 0) as event_count_l7d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 30 then 1 end), 0) as event_count_l30d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 90 then 1 end), 0) as event_count_l90d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 180 then 1 end), 0) as event_count_l180d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 360 then 1 end), 0) as event_count_l360d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 720 then 1 end), 0) as event_count_l720d
        from (
            select  GET_JSON_OBJECT(extinfo,'$.logistics_info.seller_address.userid') as userid
                        ,concat_ws(',',
                        trim(lower(regexp_replace(coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.seller_address.address'),''), '[^a-zA-Z0-9]+', ' '))),
                        coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.seller_address.town'),''),
                        coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.seller_address.district'),''),
                        coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.seller_address.city'),''),
                        coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.seller_address.state'),''),
                        coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.seller_address.zipcode'),'')
                        ) as full_address
                    ,trim(lower(regexp_replace(coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.seller_address.address'),''), '[^a-zA-Z0-9]+', ' '))) as address
                    ,coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.seller_address.town') ,'')              as town
                    ,coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.seller_address.district')  ,'')         as district
                    ,coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.seller_address.city')  ,'')             as city
                    ,coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.seller_address.state') ,'')             as state
                    ,coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.seller_address.zipcode') ,'')           as zipcode
                    ,cast(date(create_datetime) as string) as grass_date
            from    mp_order.dwd_ofo_all_ent_df__reg_live
            where   grass_region = '${grass_region}'
            and   date(create_datetime) <=date( '${grass_date}')
            and   length(trim(lower(regexp_replace(coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.seller_address.address'),''), '[^a-zA-Z0-9]+', ' ')))) >= 10
        ) a
        group by userid, full_address, address, town, district, city, state, zipcode
    )

    -- shopeepay_transfer
    -- union all
    -- select  concat('userid/', sender_userid) as platform_user_id
    --         ,xxhash64(concat('userid/', sender_userid)) as hash_platform_user_id
    --         ,concat('userid/', receiver_userid) as destination_node
    --         ,xxhash64(concat('userid/', receiver_userid)) as hash_destination_node
    --         ,cast(create_date as string) as create_date
    --         ,cast(last_date as string) as last_date
    --         ,to_json(
    --             named_struct(
    --                 'sender_userid',sender_userid
    --                 ,'receiver_userid',receiver_userid
    --                 ,'event_count',event_count
    --                 ,'event_amount',event_amount
    --             )
    --         ) as extend_info
    --         ,'${grass_region}' as grass_region
    --         ,'shopeepay_transfer' as edge_name
    --         ,'${grass_date}' as grass_date
    -- from    (
    --     select  sender_userid
    --             ,receiver_userid
    --             ,min(grass_date) as create_date
    --             ,max(grass_date) as last_date
    --             ,sum(1) as event_count
    --             ,sum(amount) as event_amount
    --     from    (
    --         select  user_id as sender_userid
    --                 ,extinfo.transfer_send_details.receiver.user_id as receiver_userid
    --                 ,from_unixtime(create_time, 'yyyy-MM-dd') as grass_date
    --                 ,cast(amount/100000 as integer) as amount
    --         from    shopeepay.dwd_wallet_${person_table_region}_transaction_tab_df
    --         where   from_unixtime(create_time, 'yyyy-MM-dd') <= '${grass_date}'
    --           and   transaction_type = 10
    --           and   user_id <> 0
    --           -- 因为TH/VN没有 dwd_wallet_region_transaction_tab_df表,因此这部分先就不统计
    --           and   '${person_table_region}' = '${region}'
    --     )
    --     group by sender_userid, receiver_userid
    -- )

    -- shopee_transfer
    union all
    select  concat('userid/', buyer_userid) as platform_user_id
            ,xxhash64(concat('userid/', buyer_userid)) as hash_platform_user_id
            ,concat('userid/', seller_userid) as destination_node
            ,xxhash64(concat('userid/', seller_userid)) as hash_destination_node
            ,cast(create_date as string) as create_date
            ,cast(last_date as string) as last_date
            ,to_json(
                named_struct(
                    'buyer_userid',buyer_userid
                    ,'seller_userid',seller_userid
                    ,'event_count',event_count
                    ,'event_item_count',event_item_count
                    ,'event_amount',event_amount
                )
            ) as extend_info
            ,'${grass_region}' as grass_region
            ,'shopee_transfer' as edge_name
            ,'${grass_date}' as grass_date
    from    (
        select  buyer_userid
                ,seller_userid
                ,create_date
                ,last_date
                ,event_count
                ,event_item_count
                ,event_amount
        from (
            select  buyer_id as buyer_userid
                    ,seller_id as seller_userid
                    ,min(from_unixtime(create_timestamp, 'yyyy-MM-dd')) as create_date
                    ,max(from_unixtime(create_timestamp, 'yyyy-MM-dd')) as last_date
                    ,count(distinct order_id) as event_count
                    ,sum(item_amount) as event_item_count
                    ,sum(gmv_usd) as event_amount
            from    mp_order.dwd_order_item_all_ent_df__reg_s0_live
            where   grass_region = '${grass_region}'
              and   from_unixtime(create_timestamp, 'yyyy-MM-dd') <= '${grass_date}'
              and   seller_id is not null
            group by buyer_id, seller_id
        ) a
        inner join (
            select  buyer_id as user_id
            from    mp_order.dwd_ofo_all_ent_df__reg_live
            where   grass_region = '${grass_region}'
            group by buyer_id
            having  coalesce(sum(cast (GET_JSON_OBJECT(extinfo,'$.dropshipping_info.enabled') as int)), 0) = 0
        ) b
        on a.buyer_userid = b.user_id
    )
    -- dp_account_no
    union all
    select  concat('userid/', userid) as platform_user_id
            ,xxhash64(concat('userid/', userid)) as hash_platform_user_id
            ,concat('account_no/', account_no) as destination_node
            ,xxhash64(concat('account_no/', account_no)) as hash_destination_node
            ,cast(create_date as string) as create_date
            ,cast(last_date as string) as last_date
            ,to_json(
                named_struct(
                    'userid',userid
                    ,'category_id', category_id
                    ,'account_no',account_no
                    ,'event_count',event_count
                    ,'event_count_l3d',event_count_l3d
                    ,'event_count_l7d',event_count_l7d
                    ,'event_count_l30d',event_count_l30d
                    ,'event_count_l90d',event_count_l90d
                    ,'event_count_l180d',event_count_l180d
                    ,'event_count_l360d',event_count_l360d
                    ,'event_count_l720d',event_count_l720d
                )
            ) as extend_info
            ,'${grass_region}' as grass_region
            ,'dp_account_no' as edge_name
            ,'${grass_date}' as grass_date
    from    (
        select  userid
                ,account_no
                ,category_id
                ,min(grass_date) as create_date
                ,max(grass_date) as last_date
                ,sum(1) as event_count
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 3 then 1 end), 0) as event_count_l3d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 7 then 1 end), 0) as event_count_l7d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 30 then 1 end), 0) as event_count_l30d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 90 then 1 end), 0) as event_count_l90d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 180 then 1 end), 0) as event_count_l180d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 360 then 1 end), 0) as event_count_l360d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 720 then 1 end), 0) as event_count_l720d
        from    (
            select
                user_id as userid
                ,concat(category_id,'/', customer_id) as account_no
                ,category_id
                ,from_unixtime(create_time, 'yyyy-MM-dd') as grass_date
            from digitalpurchase.order_dwd_dp_trd_ord_df
            where from_unixtime(create_time, 'yyyy-MM-dd') <= '${grass_date}'
                and grass_region = '${grass_region}'
                and category_id in (20102,20103,20125,20127)
                and coalesce(customer_id,'') <> ''
                and payment_status = 'P2'
                and order_status = 'OR6'
                and   grass_region ='${grass_region}'
                and   grass_date = '${grass_date}'
        )
        group by userid, account_no, category_id
    )
    -- buyer_shipping_address_phone
    union all
    select  concat('userid/', userid) as platform_user_id
        ,xxhash64(concat('userid/', userid)) as hash_platform_user_id
        ,concat('address_phone/', address_phone) as destination_node
        ,xxhash64(concat('address_phone/', address_phone)) as hash_destination_node
        ,cast(create_date as string) as create_date
        ,cast(last_date as string) as last_date
        ,to_json(
            named_struct(
                'userid',userid
                ,'address_phone',address_phone
                ,'address',address
                ,'town',town
                ,'district',district
                ,'city',city
                ,'state',state
                ,'zipcode',zipcode
                ,'phone',phone
                ,'event_count',event_count
                ,'event_count_l3d',event_count_l3d
                ,'event_count_l7d',event_count_l7d
                ,'event_count_l30d',event_count_l30d
                ,'event_count_l90d',event_count_l90d
                ,'event_count_l180d',event_count_l180d
                ,'event_count_l360d',event_count_l360d
                ,'event_count_l720d',event_count_l720d
            )
        ) as extend_info
        ,'${grass_region}' as grass_region
        ,'buyer_shipping_address_phone' as edge_name
        ,'${grass_date}' as grass_date
    from    (
        select  userid
                ,address_phone
                ,min(grass_date) as create_date
                ,max(grass_date) as last_date
                ,address
                ,town
                ,district
                ,city
                ,state
                ,zipcode
                ,phone
                ,sum(1) as event_count
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 3 then 1 end), 0) as event_count_l3d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 7 then 1 end), 0) as event_count_l7d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 30 then 1 end), 0) as event_count_l30d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 90 then 1 end), 0) as event_count_l90d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 180 then 1 end), 0) as event_count_l180d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 360 then 1 end), 0) as event_count_l360d
                ,coalesce(sum(case when datediff('${grass_date}', grass_date) < 720 then 1 end), 0) as event_count_l720d
        from (
            select  buyer_id as userid
                    ,concat_ws(',',
                        trim(lower(regexp_replace(coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.address'),''), '[^a-zA-Z0-9]+', ' '))),
                        coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.town'),''),
                        coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.district'),''),
                        coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.city'),''),
                        coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.state'),''),
                        coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.zipcode'),''),
                        phone_number_parse(coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.phone'), ''), '${grass_region}')
                        ) as address_phone
                    ,trim(lower(regexp_replace(coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.address'),''), '[^a-zA-Z0-9]+', ' '))) as address
                    ,coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.town'),'')               as town
                    ,coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.district') ,'')          as district
                    ,coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.city') ,'')              as city
                    ,coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.state') ,'')             as state
                    ,coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.zipcode') ,'')           as zipcode
                    ,phone_number_parse(coalesce(GET_JSON_OBJECT(extinfo,'$.logistics_info.buyer_address.phone'), ''), '${grass_region}')  as phone
                    ,cast(date(create_datetime) as string) as grass_date
            from    mp_order.dwd_ofo_all_ent_df__reg_live
            where   grass_region = '${grass_region}'
            and     date(create_datetime) <= '${grass_date}'
        ) a
        inner join (
            select  buyer_id as user_id
            from    mp_order.dwd_ofo_all_ent_df__reg_live
            where   grass_region = '${grass_region}'
            group by buyer_id
            having  coalesce(sum(cast (GET_JSON_OBJECT(extinfo,'$.dropshipping_info.enabled') as int)), 0) = 0
        ) b
        on a.userid = b.user_id
        where   phone <> ''
        group by userid, address_phone, address, town, district, city, state, zipcode, phone
    )
    -- id kyc 
    union all 
    select  
        platform_user_id       as platform_user_id
        ,hash_platform_user_id as hash_platform_user_id
        ,destination_node      as destination_node
        ,hash_destination_node as hash_destination_node
        ,create_date           as create_date
        ,last_date             as last_date
        ,extend_info           as extend_info
        ,grass_region          as grass_region
        ,edge_name             as edge_name
        ,grass_date            as grass_date
from risk.dwd_risk_${region}_graph_edge_user_kyc_df
where grass_date='${grass_date}' 
-- wei.tao added on 2025/01/20
union all  
    select  concat('userid/', userid) as platform_user_id
        ,xxhash64(concat('userid/', userid)) as hash_platform_user_id
        ,concat('kyc/', id_card_no) as destination_node
        ,xxhash64(concat('kyc/', id_card_no)) as hash_destination_node
        ,cast(create_date as string) as create_date
        ,cast(last_date as string) as last_date
        ,to_json(
            named_struct(
                'userid',userid
                ,'id_card_no', id_card_no
            )
        ) as extend_info
        ,'${grass_region}' as grass_region
        ,concat('kyc_', kyc_data_source) as edge_name
        ,'${grass_date}' as grass_date
    from (
        select
            userid,
            id_card_no,
            min(create_date) as create_date,
            max(create_date) as last_date,
            kyc_data_source
        from(
            
            -- marketplace seller side
            select
                userid
                ,id_card_no
                ,create_date
                ,'mp_verified' as kyc_data_source
            from
                (
                select
                    u.user_id as userid
                    ,cpf_id as id_card_no
                    ,date(create_datetime) as create_date
                from
                    mp_seller.dim_shop_shareholder__br_s1_live s
                    left join mp_user.dim_user__reg_s0_live u on s.shop_id = u.shop_id
                where
                    u.grass_region = '${grass_region}'
                    and u.grass_date = date('${grass_date}')
                    and s.grass_date = date('${grass_date}')
                    and s.kyc_status = 7 -- KYC Validated
                )

            union all 


            select
                userid
                ,id_card_no
                ,create_date
                ,'mp_all' as kyc_data_source
            from
                (
                select
                    u.user_id as userid
                    ,cpf_id as id_card_no
                    ,date(create_datetime) as create_date
                from
                    mp_seller.dim_shop_shareholder__br_s1_live s
                    left join mp_user.dim_user__reg_s0_live u on s.shop_id = u.shop_id
                where
                    u.grass_region = '${grass_region}'
                    and u.grass_date = date('${grass_date}')
                    and s.grass_date = date('${grass_date}')
                    and s.kyc_status in (4,5,6,7) -- KYC application status
                )

            union all 
            
            -- shopeepay
            select
                shopeepay_user_id as userid -- verified shopeepay userid is same as shopee userid
                ,REGEXP_REPLACE(id_number_decrypt, '[^0-9]', '') as id_card_no -- remove non numbers from id number
                ,from_unixtime(create_time, 'yyyy-MM-dd') as create_date
                ,'spp' as kyc_data_source
            from
                shopeepay.mart_dwd_us_kyc_case_record_tab_df__${region}
            where
                id_type = 1
                and kyc_status = 3
                and date(from_unixtime(create_time, 'yyyy-MM-dd')) <= date('${grass_date}')

            union all

            -- credit products
            select
                userid,
                id_card_no,
                create_date,
                'uc' as kyc_data_source
            from (
                select
                    platform_user_id as userid,
                    id_card_no,
                    date(first_application_time) as create_date
                from credit_uc.dws_spl_${region}_uc_user_df
                where
                    grass_date = date('${grass_date}')
                union all
                select
                    platform_user_id as userid,
                    id_card_no,
                    date(first_application_time) as create_date
                from credit_uc.dws_bcl_${region}_uc_user_df
                where
                    grass_date = date('${grass_date}')
                union all
                select
                    platform_user_id as userid,
                    id_card_no,
                    date(first_application_time) as create_date
                from credit_uc.dws_scl_${region}_uc_user_df
                where
                    grass_date = date('${grass_date}')

                union all

                select
                    platform_user_id as userid,
                    id_card_no,
                    date(kyc_update_time) as create_date
                from credit_uc.dws_spl_${region}_uc_user_df
                where
                    grass_date = date('${grass_date}')
                union all
                select
                    platform_user_id as userid,
                    id_card_no, 
                    date(kyc_update_time) as create_date
                from credit_uc.dws_bcl_${region}_uc_user_df
                where
                    grass_date = date('${grass_date}')
                union all
                select
                    platform_user_id as userid,
                    id_card_no,
                    date(kyc_update_time) as create_date
                from credit_uc.dws_scl_br_uc_user_df
                where
                    grass_date = date('${grass_date}')
            )
        )
        where
            id_card_no is not null and 
            length(id_card_no) = 11 -- BR region ID card length is 11
        group by userid, id_card_no, kyc_data_source
    )

--
) t2
on t1.hash_platform_user_id = t2.hash_platform_user_id
;