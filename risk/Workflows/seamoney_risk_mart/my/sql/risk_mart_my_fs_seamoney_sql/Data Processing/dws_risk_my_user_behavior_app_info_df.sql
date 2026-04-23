--drop table if exists ${SCHEMA}.dws_risk_${region}_user_behavior_app_info_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_behavior_app_info_df (
    platform_user_id string comment 'platform_user_id'
    ,app_type string comment 'app_type'
    ,app_version string comment 'app_version'
    ,app_flag bigint comment 'app_flag'
) partitioned by (
    grass_date string comment "YYYY-MM-DD"
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location '${HDFS_PATH}/risk_mart/dws/dws_risk_reg_user_behavior_app_info_df/grass_region=${grass_region}'
;
--msck repair table ${SCHEMA}.dws_risk_${region}_user_behavior_app_info_df;


create or replace temporary view user_app_info AS
SELECT userid AS platform_user_id,
        case
            when machine_code like '%apple%' then 'ios'
            when machine_code like '%android%' then 'android'
        end as app_type,
        case
            when machine_code like '%apple%' then concat(substr(CAST(appversion AS string),0,1),'.',substr(CAST(appversion AS string),2,2),'.',substr(CAST(appversion AS string),CHAR_LENGTH(CAST(appversion AS string))-1,2))
            when machine_code like '%android%' then CAST(appversion AS string)
        end as app_version
FROM marketplace.shopee_device_db__device_tab__my_df
WHERE grass_region = '${grass_region}'
and grass_date = '${grass_date}'
;

create or replace temporary view user_app_metrics as
SELECT 
    platform_user_id,
    max(app_type) as app_type,
    max(app_version) as app_version,
    max(CASE
        WHEN app_type = 'ios' AND CAST(split(app_version, '.')[0] AS INT) > 2 THEN 1
        WHEN app_type = 'ios' AND CAST(split(app_version, '.')[0] AS INT) = 2 AND CAST(split(app_version, '.')[1] AS INT) > 32 THEN 1
        WHEN app_type = 'ios' AND CAST(split(app_version, '.')[0] AS INT) = 2 AND CAST(split(app_version, '.')[1] AS INT) = 32 AND CAST(split(app_version, '.')[2] AS INT) >= 40 THEN 1
        WHEN app_type = 'android' AND app_version >= 232 THEN 1
        ELSE 0
    END) AS app_flag
FROM user_app_info
group by platform_user_id
;


insert overwrite table ${SCHEMA}.dws_risk_my_user_behavior_app_info_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id
    ,t2.app_type
    ,t2.app_version
    ,t2.app_flag
from
    (
        select
            platform_user_id
        from ${SCHEMA}.dim_risk_my_user_info_df
        where grass_date = '${grass_date}'
    ) t1
    left join
    (
        select
            platform_user_id
            ,app_type
            ,app_version
            ,app_flag
        from
        user_app_metrics
    ) t2 on t1.platform_user_id = t2.platform_user_id
;

