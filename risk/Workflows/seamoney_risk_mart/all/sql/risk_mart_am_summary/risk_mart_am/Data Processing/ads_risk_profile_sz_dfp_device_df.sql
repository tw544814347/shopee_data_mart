create or replace temporary view sz_dfp_first_appear_merge as
select
    coalesce(t1.sz_dfp_device_id,t2.sz_dfp_device_id,t3.sz_dfp_device_id) as sz_dfp_device_id
    ,coalesce(t1.szdf_fst_login_timestamp,t2.szdf_fst_login_timestamp) as szdf_fst_login_timestamp
    ,coalesce(t1.szdf_fst_req_credit_timestamp,t3.szdf_fst_req_credit_timestamp) as szdf_fst_req_credit_timestamp
from
(
    select
        sz_dfp_device_id
        ,szdf_fst_login_timestamp
        ,szdf_fst_req_credit_timestamp
    from ${SCHEMA}.ads_risk_profile_sz_dfp_device_df
    where tz_type = 'local'
        and grass_region = 'ID'
        and grass_date = date_sub(date('${bizdate}'), 1)
) t1
full outer join
(
    select
        sz_dfp_device_id
        ,min(login_timestamp) as szdf_fst_login_timestamp
    from ${SCHEMA}.dwd_risk_login_di
    where tz_type = 'local'
        and grass_region = 'ID'
        and grass_date = date('${bizdate}')
        and is_device = 'Y'
    group by sz_dfp_device_id
) t2
on t1.sz_dfp_device_id = t2.sz_dfp_device_id
full outer join
(
    select
        sz_dfp_device_id
        ,min(req_time) as szdf_fst_req_credit_timestamp
    from
    (
        select
            get_json_object(extension, '$.CommonHeader.extension_process_data.sz_dfp.device_id') as sz_dfp_device_id
            ,req_time
        from ${SCHEMA}.dwd_risk_id_strategy_final_result_merge_di
        where grass_date = '${bizdate}'
            and scene_id in (10013,10034,10024,10026)
    ) t
    group by sz_dfp_device_id
) t3
on t1.sz_dfp_device_id = t3.sz_dfp_device_id
;

insert overwrite table ${SCHEMA}.ads_risk_profile_sz_dfp_device_df partition (tz_type='local', grass_region, grass_date )
select
    t1.sz_dfp_device_id
    ,t2.szdf_fst_login_timestamp
    ,t2.szdf_fst_req_credit_timestamp
    ,'ID' as grass_region
    ,date('${bizdate}') as grass_date
from
(
    select
        sz_dfp_device_id
    from ${SCHEMA}.dim_risk_user_device_df
    where tz_type = 'local'
        and grass_region = 'ID'
        and grass_date = date '${bizdate}'
    group by sz_dfp_device_id
) t1
left join sz_dfp_first_appear_merge t2
    on t1.sz_dfp_device_id = t2.sz_dfp_device_id
;
