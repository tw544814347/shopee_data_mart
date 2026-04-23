--DROP TABLE IF EXISTS ${SCHEMA}.dws_risk_id_graph_edge_user_login_version_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dws_risk_id_graph_edge_user_login_version_df
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
location '${HDFS_PATH}/risk_mart/dws/dws_risk_graph_edge_user_login_version_df/grass_region=${grass_region}';
--MSCK REPAIR TABLE ${SCHEMA}.dws_risk_id_graph_edge_user_login_version_df;

create or replace temporary function phone_number_parse as 'com.shopee.udf.PhoneNumberParse' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-tool-udf-1.0-SNAPSHOT-jar-with-dependencies.jar';
create or replace temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp' using jar 'hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar';


insert overwrite table ${SCHEMA}.dws_risk_id_graph_edge_user_login_version_df partition(version_name,edge_name,grass_date)
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
) t2
on t1.hash_platform_user_id = t2.hash_platform_user_id
;