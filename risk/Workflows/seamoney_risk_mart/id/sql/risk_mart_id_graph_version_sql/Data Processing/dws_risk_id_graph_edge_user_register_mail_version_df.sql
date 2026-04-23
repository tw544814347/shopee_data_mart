------------------------------------------------------------------------
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2023-12-06
-- Description:         Risk Graph需求， register_mail
-- Data Granularity:    
-- PRD:                 
-- Jira:                https://jira.shopee.io/browse/SPFDT-54938
-- version:
--          2025.9.18  mp_user.dwd_account_audit_changelog_di__reg_s1_live表数据量很小，ID地区全量数据20G，不需要做增量逻辑
------------------------------------------------------------------------


--DROP TABLE IF EXISTS ${SCHEMA}.dws_risk_id_graph_edge_user_register_mail_version_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dws_risk_id_graph_edge_user_register_mail_version_df
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
location '${HDFS_PATH}/risk_mart/dws/dws_risk_graph_edge_user_register_mail_version_df/grass_region=${grass_region}';
--MSCK REPAIR TABLE ${SCHEMA}.dws_risk_id_graph_edge_user_register_mail_version_df;

create or replace temporary function phone_number_parse as 'com.shopee.udf.PhoneNumberParse' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-tool-udf-1.0-SNAPSHOT-jar-with-dependencies.jar';
create or replace temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp' using jar 'hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar';


insert overwrite table ${SCHEMA}.dws_risk_id_graph_edge_user_register_mail_version_df partition(version_name,edge_name,grass_date)
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
    -- register_email
    select  concat('userid/', userid) as platform_user_id
            ,xxhash64(concat('userid/', userid)) as hash_platform_user_id
            ,concat('email/', email) as destination_node
            ,xxhash64(concat('email/', email)) as hash_destination_node
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
        AND (
            REGEXP_LIKE(email,
            '^[a-zA-Z0-9][a-zA-Z0-9._!#$%&*+\-/=?^`{|}~-]+[a-zA-Z0-9]@[a-zA-Z0-9][a-zA-Z0-9.-]+[a-zA-Z0-9]$')
            OR REGEXP_LIKE(email,
            '[a-zA-Z0-9]([a-zA-Z0-9])?@[a-zA-Z0-9][a-zA-Z0-9.\-]+[a-zA-Z0-9]')
        )
        AND email NOT LIKE '%%..%%'
        AND email NOT LIKE '%%@%%.-%%'
        AND email NOT LIKE '%%@%%-.%%'
        AND email NOT LIKE '%%test%%'
        and email not rlike '@(shopee|seamoney|monee|seagroup|sea|shopeemobile|garena)\\.com'
        group by userid, email
    )
) t2
on t1.hash_platform_user_id = t2.hash_platform_user_id
;