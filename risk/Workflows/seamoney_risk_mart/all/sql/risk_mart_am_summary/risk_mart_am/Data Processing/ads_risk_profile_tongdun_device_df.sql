create or replace temporary view tongdun_device_first_appear_merge as
select
    coalesce(t1.tongdun_device_id,t2.tongdun_device_id,t3.tongdun_device_id) as tongdun_device_id
    ,coalesce(t1.tddf_fst_login_timestamp,t2.tddf_fst_login_timestamp) as tddf_fst_login_timestamp
    ,coalesce(t1.tddf_fst_req_credit_timestamp,t3.tddf_fst_req_credit_timestamp) as tddf_fst_req_credit_timestamp
from
(
    select
        tongdun_device_id
        ,tddf_fst_login_timestamp
        ,tddf_fst_req_credit_timestamp
    from ${SCHEMA}.ads_risk_profile_tongdun_device_df
    where tz_type = 'local'
        and grass_region = 'ID'
        and grass_date = date_sub(date('${bizdate}'), 1)
) t1
full outer join
(
    select
        tongdun_device_id
        ,min(login_timestamp) as tddf_fst_login_timestamp
    from ${SCHEMA}.dwd_risk_login_di
    where tz_type = 'local'
        and grass_region = 'ID'
        and grass_date = date('${bizdate}')
        and is_device = 'Y'
    group by tongdun_device_id
) t2
on t1.tongdun_device_id = t2.tongdun_device_id
full outer join
(
    select
        tongdun_df as tongdun_device_id
        ,min(req_time) as tddf_fst_req_credit_timestamp
    from
    (
        select
            coalesce(get_json_object(extension, '$.tongdun_df'), get_json_object(extension, '$.CommonHeader.extension_process_data.tongdun_deviec_info.tongdun_df')) as tongdun_df
            ,req_time
        from ${SCHEMA}.dwd_risk_id_strategy_final_result_merge_di
        where grass_date = '${bizdate}'
            and scene_id in (10013,10034,10024,10026)
    ) t
    group by tongdun_device_id
) t3
on t1.tongdun_device_id = t3.tongdun_device_id
;

insert overwrite table ${SCHEMA}.ads_risk_profile_tongdun_device_df partition (tz_type='local', grass_region, grass_date )
select
    t1.tongdun_device_id
    ,t2.tddf_fst_login_timestamp
    ,t2.tddf_fst_req_credit_timestamp
    ,'ID' as grass_region
    ,date('${bizdate}') as grass_date
from
(
    select
        tongdun_device_id
    from ${SCHEMA}.dim_risk_user_device_df
    where tz_type = 'local'
        and grass_region = 'ID'
        and grass_date = date '${bizdate}'
    group by tongdun_device_id
) t1
left join tongdun_device_first_appear_merge t2
    on t1.tongdun_device_id = t2.tongdun_device_id
;
