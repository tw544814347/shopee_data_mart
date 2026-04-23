--DROP TABLE IF EXISTS ${SCHEMA}.dws_risk_id_graph_edge_user_shipping_address_version_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dws_risk_id_graph_edge_user_shipping_address_version_df
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
location '${HDFS_PATH}/risk_mart/dws/dws_risk_graph_edge_user_shipping_address_version_df/grass_region=${grass_region}';
--MSCK REPAIR TABLE ${SCHEMA}.dws_risk_id_graph_edge_user_shipping_address_version_df;

create or replace temporary function phone_number_parse as 'com.shopee.udf.PhoneNumberParse' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-tool-udf-1.0-SNAPSHOT-jar-with-dependencies.jar';
create or replace temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp' using jar 'hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar';


insert overwrite table ${SCHEMA}.dws_risk_id_graph_edge_user_shipping_address_version_df partition(version_name,edge_name,grass_date)
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
    -- buyer_shipping_address
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
            ,'buyer_shipping_address' as edge_name
            ,'${grass_date}' as grass_date
    from    (
        select  a.userid
                ,full_address
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
                    ,buyer_shipping_address_id AS address_id
                    ,case when '${grass_region}' IN ('VN') then concat_ws(',',buyer_address,buyer_district)
                    else concat_ws(',',buyer_address,buyer_zipcode)
                    end as full_address
                    ,buyer_address as address
                    ,buyer_town as town
                    ,buyer_district as district
                    ,buyer_city as city
                    ,buyer_state as state
                    ,buyer_zipcode as zipcode
                    ,grass_date
            from ${SCHEMA}.dwd_id_ofo_all_ent_df_buyer_address_di_tmp
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
                        ,row_number() over (
                            partition by user_id, address_id
                            order by modify_datetime desc
                        ) as rn
                    from mp_user.dim_user_address__reg_s1_live
                    where
                        1 = 1
                        and tz_type = 'local'
                        and grass_region = '${grass_region}'
                        and grass_date = '${grass_date}'
                        and length(address) >= 10
                )
            where rn = 1
                
        ) mp_user_tags
        ON mp_user_tags.userid = a.userid
        AND mp_user_tags.address_id = a.address_id
        group by a.userid, full_address, address, town, district, city, state, zipcode, address_type, is_default_delivery_address
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
            select  seller_userid as userid
                    ,case when '${grass_region}' IN ('VN') then concat_ws(',',seller_address,seller_district)
                    else concat_ws(',',seller_address,seller_zipcode)
                    end as full_address
                    ,seller_address as address
                    ,seller_town as town
                    ,seller_district as district
                    ,seller_city as city
                    ,seller_state as state
                    ,seller_zipcode as zipcode
                    ,grass_date
            from    ${SCHEMA}.dwd_id_ofo_all_ent_df_buyer_address_di_tmp
            where   is_cb_seller = 0
            and     length(seller_address) >= 10
            and     length(seller_address) <= 150
        ) a
        group by userid, full_address, address, town, district, city, state, zipcode
    )

) t2
on t1.hash_platform_user_id = t2.hash_platform_user_id
;