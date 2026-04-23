--drop table if exists ${SCHEMA}.dws_risk_${region}_user_behavior_app_info_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_behavior_app_info_df (
    shopee_user_id string comment 'shopee user id'
    ,platform_user_id string comment 'shopee user id'
    ,is_app_version_supported bigint comment 'is app version supported'
) partitioned by (
    grass_date string comment "YYYY-MM-DD"
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location '${HDFS_PATH}/risk_mart/dws/dws_risk_reg_user_behavior_app_info_df/grass_region=${grass_region}'
;
--msck repair table ${SCHEMA}.dws_risk_${region}_user_behavior_app_info_df;


create or replace temporary view user_full_scope_tab as
select
    userid
    ,case
        when app_type = 'ios' and app_length = 5 and appversion >= 25300 then 1
        when app_type = 'android' and app_length = 3 and appversion >= 332 then 1
        else 0
    end as is_app_version_supported
    ,mtime
from
    (
        select
            userid
            ,case
                when machine_code like '%apple%' then 'ios'
                when machine_code like '%android%' then 'android'
                else 'unknown'
            end as app_type
            ,appversion
            ,char_length(cast(appversion as string)) as app_length
            ,mtime
        from marketplace.shopee_device_db__device_tab__br_df
        where grass_date = '${grass_date}'
        and country = '${grass_region}'
    )
;

create or replace temporary view app_supported_tab as
select
    userid
    ,is_app_version_supported
from
    (
        select
            userid
            ,is_app_version_supported
            ,row_number() over (
                partition by userid
                order by mtime desc
            ) as rnk
        from user_full_scope_tab
    )
where rnk = 1
;

insert overwrite table ${SCHEMA}.dws_risk_${region}_user_behavior_app_info_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id as shopee_user_id
    ,t1.platform_user_id
    ,t2.is_app_version_supported
from
    (
        select
            platform_user_id
        from ${SCHEMA}.dim_risk_${region}_user_info_df
        where grass_date = '${grass_date}'
    ) t1
    left join app_supported_tab t2 on t1.platform_user_id = t2.userid
;

