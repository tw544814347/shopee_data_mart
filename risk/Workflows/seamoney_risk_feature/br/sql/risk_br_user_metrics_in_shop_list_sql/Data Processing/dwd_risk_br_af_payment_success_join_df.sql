--********************************************************************--
-- Author:         jiaqi.chen@shopee.com
-- Created Time:   2023-04-26T16:23:08.830Z
-- Description:    用户在指定商家list下支付的次数和金额
--********************************************************************--

-- kredit 10035 success join（30d）
with request_table_35 as (
    select  value,
            get_json_object(value,'$.ReqParams.CheckOutId') as join_field,
            cast(get_json_object(value,'$.Req.RiskReqHeader.SceneID') as int) as sceneid,
            get_json_object(value,'$.Req.RiskReqHeader.AppID') as appid,
            dt
    from  ${SCHEMA}.ods_risk_live_kafka_gateway_req_rsp_di_v2
    where grass_region = '${REGION}'
    and tn='${region}_live_credit_risk_gateway_req_rsp_kredit'
    and scene_id = 10035
    and dt >= '${begin_30ds}'
),
result_table_35 as (
    select  value,
        get_json_object(value,'$.ReqParams.CheckoutId') as join_field,
        cast(get_json_object(value,'$.Req.RiskReqHeader.SceneID') as int) as sceneid,
        get_json_object(value,'$.Req.RiskReqHeader.AppID') as appid,
        get_json_object(value,'$.ReqParams.Result') as result_val
    from ${SCHEMA}.ods_risk_live_kafka_gateway_req_rsp_di_v2
    where tn='${region}_live_credit_risk_gateway_req_rsp_kredit'
    and scene_id = 10006
    and dt >= '${begin_30ds}'
),
join_view_35 as (
    select  request_table_35.value,
            request_table_35.appid as app_id,
            request_table_35.sceneid as scene_id,
            request_table_35.dt
    from request_table_35 inner join result_table_35
    on result_table_35.join_field = request_table_35.join_field
    where request_table_35.appid = 'kredit' and request_table_35.sceneid = 10035
        and result_table_35.appid = 'kredit' and result_table_35.sceneid = 10006
        and CHAR_LENGTH(request_table_35.join_field) > 0 and CHAR_LENGTH(result_table_35.join_field) > 0
        and result_table_35.result_val = '0'
)

insert overwrite  ${SCHEMA}.dwd_risk_af_payment_success_join_df partition(grass_region='${region}', app_id, scene_id, grass_date)
select value, app_id, scene_id, dt as grass_date from join_view_35;

-- kredit 10045 success join（30d）
with request_table_45 as (
    select  value,
            get_json_object(value,'$.Req.RiskReqHeader.FlowNo') as join_field,
            cast(get_json_object(value,'$.Req.RiskReqHeader.SceneID') as int) as sceneid,
            get_json_object(value,'$.Req.RiskReqHeader.AppID') as appid,
            dt
    from  ${SCHEMA}.ods_risk_live_kafka_gateway_req_rsp_di_v2
    where tn='${region}_live_credit_risk_gateway_req_rsp_kredit'
    and scene_id = 10045
    and dt >= '${begin_30ds}'
),
result_table_45 as (
    select  value,
            get_json_object(value,'$.ReqParams.RiskRspFlowNo') as join_field,
            cast(get_json_object(value,'$.Req.RiskReqHeader.SceneID') as int) as sceneid,
            get_json_object(value,'$.Req.RiskReqHeader.AppID') as appid,
            get_json_object(value,'$.ReqParams.Result') as result_val
    from  ${SCHEMA}.ods_risk_live_kafka_gateway_req_rsp_di_v2
    where tn='${region}_live_credit_risk_gateway_req_rsp_kredit'
    and scene_id = 10046
    and dt >= '${begin_30ds}'
),
join_view_45 as (
    select  request_table_45.value,
            request_table_45.appid as app_id,
            request_table_45.sceneid as scene_id,
            request_table_45.dt
    from request_table_45 inner join result_table_45
    on result_table_45.join_field = request_table_45.join_field
    where request_table_45.appid = 'kredit' and request_table_45.sceneid = 10045
        and result_table_45.appid = 'kredit' and result_table_45.sceneid = 10046
        and CHAR_LENGTH(request_table_45.join_field) > 0 and CHAR_LENGTH(result_table_45.join_field) > 0
        and result_table_45.result_val = '0'
)

insert overwrite  ${SCHEMA}.dwd_risk_af_payment_success_join_df partition(grass_region='${region}', app_id, scene_id, grass_date)
select value, app_id, scene_id, dt as grass_date from join_view_45;

-- kredit 10055 success join（30d）
with request_table_55 as (
    select  value,
            get_json_object(value,'$.Req.RiskReqHeader.FlowNo') as join_field,
            cast(get_json_object(value,'$.Req.RiskReqHeader.SceneID') as int) as sceneid,
            get_json_object(value,'$.Req.RiskReqHeader.AppID') as appid,
            dt
    from ${SCHEMA}.ods_risk_live_kafka_gateway_req_rsp_di_v2
    where tn='${region}_live_credit_risk_gateway_req_rsp_kredit'
    and scene_id = 10055
    and dt >= '${begin_30ds}'
),
result_table_55 as (
    select  value,
        get_json_object(value,'$.ReqParams.RiskRspFlowNo') as join_field,
        cast(get_json_object(value,'$.Req.RiskReqHeader.SceneID') as int) as sceneid,
        get_json_object(value,'$.Req.RiskReqHeader.AppID') as appid,
        get_json_object(value,'$.ReqParams.Result') as result_val
    from ${SCHEMA}.ods_risk_live_kafka_gateway_req_rsp_di_v2
    where tn='${region}_live_credit_risk_gateway_req_rsp_kredit'
    and scene_id = 10056
    and dt >= '${begin_30ds}'
),
join_view_55 as (
    select  request_table_55.value,
            request_table_55.appid as app_id,
            request_table_55.sceneid as scene_id,
            request_table_55.dt
    from request_table_55 inner join result_table_55
    on result_table_55.join_field = request_table_55.join_field
    where request_table_55.appid = 'kredit' and request_table_55.sceneid = 10055
        and result_table_55.appid = 'kredit' and result_table_55.sceneid = 10056
        and CHAR_LENGTH(request_table_55.join_field) > 0 and CHAR_LENGTH(result_table_55.join_field) > 0
        and result_table_55.result_val = '0'
)

insert overwrite  ${SCHEMA}.dwd_risk_af_payment_success_join_df partition(grass_region='${region}', app_id, scene_id, grass_date)
select value, app_id, scene_id, dt as grass_date from join_view_55;

-- kredit 10075 success join（30d）
with request_table_75 as (
    select  value,
            get_json_object(value,'$.ReqParams.PayId') as join_field,
            cast(get_json_object(value,'$.Req.RiskReqHeader.SceneID') as int) as sceneid,
            get_json_object(value,'$.Req.RiskReqHeader.AppID') as appid,
            dt
    from ${SCHEMA}.ods_risk_live_kafka_gateway_req_rsp_di_v2
    where tn='${region}_live_credit_risk_gateway_req_rsp_kredit'
    and scene_id = 10075
    and dt >= '${begin_30ds}'
),
result_table_75 as (
    select  value,
        get_json_object(value,'$.ReqParams.PayId') as join_field,
        cast(get_json_object(value,'$.Req.RiskReqHeader.SceneID') as int) as sceneid,
        get_json_object(value,'$.Req.RiskReqHeader.AppID') as appid,
        get_json_object(value,'$.ReqParams.Result') as result_val
    from ${SCHEMA}.ods_risk_live_kafka_gateway_req_rsp_di_v2
    where tn='${region}_live_credit_risk_gateway_req_rsp_kredit'
    and scene_id = 10076
    and dt >= '${begin_30ds}'
),
join_view_75 as (
    select  request_table_75.value,
            request_table_75.appid as app_id,
            request_table_75.sceneid as scene_id,
            request_table_75.dt
    from request_table_75 inner join result_table_75
    on result_table_75.join_field = request_table_75.join_field
    where request_table_75.appid = 'kredit' and request_table_75.sceneid = 10075
        and result_table_75.appid = 'kredit' and result_table_75.sceneid = 10076
        and CHAR_LENGTH(request_table_75.join_field) > 0 and CHAR_LENGTH(result_table_75.join_field) > 0
        and result_table_75.result_val = '0'
)

insert overwrite  ${SCHEMA}.dwd_risk_af_payment_success_join_df partition(grass_region='${region}', app_id, scene_id, grass_date)
select value, app_id, scene_id, dt as grass_date from join_view_75;