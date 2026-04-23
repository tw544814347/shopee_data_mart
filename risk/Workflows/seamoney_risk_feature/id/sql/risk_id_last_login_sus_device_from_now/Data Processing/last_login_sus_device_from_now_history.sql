alter table ${SCHEMA}.last_login_sus_device_from_now_history drop if exists partition(dt <= '${delete_limit_date}');

create or replace temporary view extract_view as 
select
    get_json_object(value, '$.Req.RiskReqHeader.FlowNo') as flow_no,
    get_json_object(value, '$.ReqParams.UserId') as platform_userid,
    get_json_object(value, '$.ReqParams.spdf_infra_sz') as szdf,
    get_json_object(value, '$.ReqParams.LoginTime') as login_time
from risk.ods_risk_live_kafka_gateway_req_rsp_di_v2
where
    grass_region = '${region_upper}'
    and grass_date >= '${limit_date}'
    and tn='${region_lower}_live_credit_risk_gateway_req_rsp_shopee' 
    and scene_id = '10003'
    and char_length(trim(get_json_object(value, '$.ReqParams.UserId'))) > 0
    and char_length(trim(get_json_object(value, '$.ReqParams.spdf_infra_sz'))) > 0
    and get_json_object(value, '$.ReqParams.LoginResult') = 'success'
    and cast(get_json_object(value, '$.ReqParams.LoginTime') as bigint) > 0
;

create or replace temporary view join_view as 
select 
    t1.flow_no,
    t1.platform_userid,
    t1.szdf,
    t1.login_time,
    t2.status
from extract_view t1 inner join risk.last_login_sus_device_from_now_dimension_status t2 on t1.szdf = t2.szdf
where t2.region = '${region_lower}' 
    and t2.dt = '${bizdate}'
;

insert overwrite ${SCHEMA}.last_login_sus_device_from_now_history partition (region = '${region_lower}', dt = '${bizdate}')
select 
    substring(md5(platform_userid), 0, 2) || '_' || platform_userid || '_' || login_time || '_' || flow_no  as rowkey,
    if(status = '-1', '-1', login_time) as login_time,
    if(status = '-1', '-1', szdf) as szdf
from join_view
;
