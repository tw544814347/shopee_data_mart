------------------------------------------------------------------------
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-09-18
-- Description:         Risk Graph需求， user_phone 边关系
-- Data Granularity:    
-- PRD:                 
-- Jira:                https://jira.shopee.io/browse/SPFDT-54938
-- version:
--          2025.9.18  mp_user.dwd_account_audit_changelog_di__reg_s1_live表数据量很小，ID地区全量数据20G，不需要做增量逻辑
------------------------------------------------------------------------


--DROP TABLE IF EXISTS ${SCHEMA}.dws_risk_id_graph_edge_user_phone_version_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dws_risk_id_graph_edge_user_phone_version_df
(
    platform_user_id      string comment 'source vertex',
    hash_platform_user_id string comment 'hash source vertex',
    destination_node      string comment 'destination_vertex',
    hash_destination_node string comment 'hash_destination_vertex',
    create_date      string comment 'create_date',
    last_date       string comment 'last_date',
    extend_info           string comment 'destination_node extend info'
)
comment 'Risk Graph Data Edge'
partitioned by
(
    version_name string comment 'version_name',
    edge_name string comment 'edge name, login/register_mail etc.',
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_graph_edge_user_phone_version_df/grass_region=${grass_region}';
--MSCK REPAIR TABLE ${SCHEMA}.dws_risk_id_graph_edge_user_phone_version_df;

create or replace temporary function phone_number_parse as 'com.shopee.udf.PhoneNumberParse' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-tool-udf-1.0-SNAPSHOT-jar-with-dependencies.jar';
create or replace temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp' using jar 'hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar';


insert overwrite table ${SCHEMA}.dws_risk_id_graph_edge_user_phone_version_df partition(version_name,edge_name,grass_date)
select 
    t2.platform_user_id,
    t1.hash_platform_user_id,
    t2.destination_node,
    t2.hash_destination_node,
    t2.create_date,
    t2.last_date,
    t2.extend_info,
    'v2' as version_name,
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
    -- register_phone
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
            and grass_date ='${grass_date}'
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
            select  buyer_userid as userid
                    ,buyer_phone as phone
                    ,grass_date
            from    ${SCHEMA}.dwd_id_ofo_all_ent_df_buyer_address_di_tmp
        ) a
        inner join (
             select user_id from ${SCHEMA}.dws_id_ofo_all_ent_df_buyer_non_enabled_dropshipping_info_df_tmp
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
            select
                seller_userid as userid
                ,seller_phone as phone
                ,grass_date
            from ${SCHEMA}.dwd_id_ofo_all_ent_df_buyer_address_di_tmp
            where is_cb_seller = 0
        )
        where   phone <> ''
        and userid not in (0, -1)
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
                    ,phone_number_parse(coalesce(customer_id, ''), '${grass_region}') as phone
                    ,from_unixtime(create_time, 'yyyy-MM-dd') as grass_date
            from    digitalpurchase.order_dwd_dp_trd_ord_df
            where   from_unixtime(create_time, 'yyyy-MM-dd') <= '${grass_date}'
              and   category_id in (20108)
              and   payment_status = 'P2'
              and   order_status = 'OR6'
              and   grass_region ='${grass_region}'
              and   grass_date = '${grass_date}'
        )
        where   phone <> ''
        group by userid, phone
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
                ,'address_type', address_type
                ,'is_default_delivery_address', is_default_delivery_address
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
        select  a.userid
                ,address_phone
                ,address_type
                ,is_default_delivery_address
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
            select
                buyer_userid as userid
                ,buyer_shipping_address_id as address_id
                ,CASE WHEN '${grass_region}' IN ('VN') THEN concat_ws(',',buyer_address,buyer_district,buyer_phone)
                    ELSE concat_ws(',',buyer_address,buyer_zipcode,buyer_phone)
                END as address_phone
                ,buyer_address as address
                ,buyer_town as town
                ,buyer_district as district
                ,buyer_city as city
                ,buyer_state as state
                ,buyer_zipcode as zipcode
                ,buyer_phone as phone
                ,grass_date
            from ${SCHEMA}.dwd_id_ofo_all_ent_df_buyer_address_di_tmp
            where buyer_phone <> ''
        ) a
        inner join (
            select user_id from ${SCHEMA}.dws_id_ofo_all_ent_df_buyer_non_enabled_dropshipping_info_df_tmp
        ) b
        on a.userid = b.user_id

        -- Add mp_user tags (home/office/default_address)
        LEFT JOIN (
        select
            userid
            ,address_id
            ,address_type
            ,is_default_delivery_address
        from
            (
        select
            cast(user_id as bigint) as userid
            ,address_id
            ,case
                when address_region in ('BR') then 'BR'
                when address_region in ('CN', 'HK', '中国') then 'CN'
                when address_region in (
                    'Cimahi'
                    ,'ID'
                    ,'INDONESIA'
                    ,'INDONESIA'
                    ,'Indonesia'
                    ,'Jakarta Selatan'
                )
                    then 'ID'
                when address_region in ('MX') then 'MX'
                when address_region in ('MY') then 'MY'
                when address_region in ('PH', 'Philippines', 'Philippines') then 'PH'
                when address_region in ('SG') then 'SG'
                when address_region in ('TH') then 'TH'
                when address_region in ('TW', '台灣') then 'TW'
                when address_region in ('VN', 'Việt Nam') then 'VN'
                else 'not_applicable'
            end as grass_region
            ,case
                when label_id = 1 then 'office'
                when label_id = 2 then 'home'
                else 'unspecified'
            end as address_type
            ,is_default_delivery_address
        from mp_user.dim_user_address__reg_s1_live
        where
            1 = 1
            and tz_type = 'local'
            and grass_region = 'ID'
            and grass_date = '${grass_date}'
            and length(address) >= 10
            )
        ) mp_user_tags
        ON mp_user_tags.userid = a.userid
        AND mp_user_tags.address_id = a.address_id

        group by a.userid, address_phone, address, town, district, city, state, zipcode, phone, address_type, is_default_delivery_address
    )
) t2
on t1.hash_platform_user_id = t2.hash_platform_user_id
;