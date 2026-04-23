insert overwrite table ${SCHEMA}.dim_risk_device_df partition (tz_type='local', grass_region, grass_date)
select 
    base64(unhex(hashed_shopee_df)) as hash_shopee_df
    ,tongdun_df as tongdun_device_id
    ,security_device_id as sz_dfp_device_id
    ,grass_region
    ,date('${bizdate}') as grass_date
from risk.dwd_risk_user_device_metrics_df
where grass_region = upper('${region}')
group by base64(unhex(hashed_shopee_df)), tongdun_df, security_device_id, grass_region
;

insert overwrite table ${SCHEMA}.dim_risk_sz_dfp_device_mapping_df partition (tz_type='local', grass_region, grass_date)
select
    device_type
    ,device_id
    ,sz_dfp_device_id
    ,grass_region
    ,date('${bizdate}') as grass_date
from
    (
        select
            'spdf' as device_type
            ,hash_shopee_df as device_id
            ,first(sz_dfp_device_id) as sz_dfp_device_id
            ,count(distinct sz_dfp_device_id) as cnt
            ,grass_region
        from ${SCHEMA}.dim_risk_device_df
        where tz_type = 'local'
            and grass_region = upper('${region}')
            and grass_date = date('${bizdate}')
            and coalesce(trim(hash_shopee_df), '') <> ''
            and coalesce(trim(sz_dfp_device_id), '') <> ''
        group by hash_shopee_df, grass_region
        having count(distinct sz_dfp_device_id) = 1

        union all

        select
            'tddf' as device_type
            ,tongdun_device_id as device_id
            ,first(sz_dfp_device_id) as sz_dfp_device_id
            ,count(distinct sz_dfp_device_id) as cnt
            ,grass_region
        from ${SCHEMA}.dim_risk_device_df
        where tz_type = 'local'
            and grass_region = upper('${region}')
            and grass_date = date('${bizdate}')
            and coalesce(trim(tongdun_device_id), '') <> ''
            and coalesce(trim(sz_dfp_device_id), '') <> ''
        group by tongdun_device_id,  grass_region
        having count(distinct sz_dfp_device_id) = 1
    )
;