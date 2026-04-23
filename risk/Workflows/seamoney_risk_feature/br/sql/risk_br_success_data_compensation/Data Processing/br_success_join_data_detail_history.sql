insert overwrite ${SCHEMA}.success_join_data_detail_history partition(grass_region='${region}', scene_id, dt)
select 
    request_table.request_flowno as request_flowno,
    request_table.request_reqtime as request_reqtime,
    result_table.result_flowno as result_flowno,
    result_table.result_reqtime as result_reqtime,
    request_table.join_field as join_field,
	request_table.value as value,
	request_table.app_id || '_' || request_table.scene_id  as scene_id,
	result_table.dt as dt
from 
	(
		select
			get_json_object(value,'$.ReqParams.FlowNo') as join_field,
            get_json_object(value,'$.Req.RiskReqHeader.FlowNo') as request_flowno,
            cast(get_json_object(value,'$.Req.RiskReqHeader.ReqTime') as bigint) as request_reqtime,
            get_json_object(value,'$.Req.RiskReqHeader.AppID') as app_id,
			get_json_object(value,'$.Req.RiskReqHeader.SceneID') as scene_id,
			value
        from risk.ods_risk_live_kafka_gateway_req_rsp_di_v2
        where grass_region = '${REGION}'
            and tn = '${region}_live_credit_risk_gateway_req_rsp_kredit'
            and scene_id = '10011'
            and dt >= '${begin_30ds}'
	) request_table inner join
	(
		select
			get_json_object(value,'$.ReqParams.FlowNo') as join_field,
			get_json_object(value,'$.Req.RiskReqHeader.FlowNo') as result_flowno,
			cast(get_json_object(value,'$.Req.RiskReqHeader.ReqTime') as bigint) as result_reqtime,
			get_json_object(value,'$.ReqParams.Result') as result_val,
            dt
        from risk.ods_risk_live_kafka_gateway_req_rsp_di_v2
        where grass_region = '${REGION}'
            and tn = '${region}_live_credit_risk_gateway_req_rsp_kredit'
            and scene_id = '10002'
            and dt >= '${begin_3ds}'
	) result_table 
	on request_table.join_field = result_table.join_field
	where char_length(request_table.join_field) > 0 
		and char_length(result_table.join_field) > 0
		and result_table.result_val = '0'
union all 
select 
    request_table.request_flowno as request_flowno,
    request_table.request_reqtime as request_reqtime,
    result_table.result_flowno as result_flowno,
    result_table.result_reqtime as result_reqtime,
    request_table.join_field as join_field,
	request_table.value as value,
	request_table.app_id || '_' || request_table.scene_id  as scene_id,
	result_table.dt as dt
from 
	(
		select
			get_json_object(value,'$.ReqParams.FlowNo') as join_field,
            get_json_object(value,'$.Req.RiskReqHeader.FlowNo') as request_flowno,
            cast(get_json_object(value,'$.Req.RiskReqHeader.ReqTime') as bigint) as request_reqtime,
            get_json_object(value,'$.Req.RiskReqHeader.AppID') as app_id,
			get_json_object(value,'$.Req.RiskReqHeader.SceneID') as scene_id,
			value
        from risk.ods_risk_live_kafka_gateway_req_rsp_di_v2
        where grass_region = '${REGION}'
            and tn = '${region}_live_credit_risk_gateway_req_rsp_spj'
            and scene_id = '10001'
            and dt >= '${begin_30ds}'
	) request_table inner join
	(
		select
			get_json_object(value,'$.ReqParams.FlowNo') as join_field,
			get_json_object(value,'$.Req.RiskReqHeader.FlowNo') as result_flowno,
			cast(get_json_object(value,'$.Req.RiskReqHeader.ReqTime') as bigint) as result_reqtime,
			get_json_object(value,'$.ReqParams.Result') as result_val,
            dt
        from risk.ods_risk_live_kafka_gateway_req_rsp_di_v2
        where grass_region = '${REGION}'
            and tn = '${region}_live_credit_risk_gateway_req_rsp_spj'
            and scene_id = '10002'
            and dt >= '${begin_3ds}'
	) result_table 
	on request_table.join_field = result_table.join_field
	where char_length(request_table.join_field) > 0 
		and char_length(result_table.join_field) > 0
		and result_table.result_val = '0'
;