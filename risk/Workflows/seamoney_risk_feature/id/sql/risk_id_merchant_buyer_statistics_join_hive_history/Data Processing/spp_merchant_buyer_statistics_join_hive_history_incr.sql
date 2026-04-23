alter table ${SCHEMA}.spp_merchant_buyer_statistics_join_hive_history_incr drop if exists partition(grass_region = '${region_upper}', grass_date < '${delete_limit_date}');

create or replace temporary view filter_view as 
select 
    get_json_object(value, '$.Req.RiskReqHeader.FlowNo') as flow_no, 
    get_json_object(value, '$.Req.RiskReqHeader.AppID') as app_id, 
    get_json_object(value, '$.Req.RiskReqHeader.SceneID') as scene_id, 
    cast(get_json_object(value, '$.Req.RiskReqHeader.ReqTime') as bigint) as req_time,
    get_json_object(value, '$.ReqParams.CommonHeader.platform_user_id') as user_id,

    get_json_object(value, '$.ReqParams.store_id') as unique_merchant_id,
    get_json_object(value, '$.ReqParams.unique_merchant_id_string') as unique_merchant_id_string,
    -- 仅ID
    get_json_object(value, '$.ReqParams.national_merchant_id') as national_merchant_id,
    get_json_object(value, '$.ReqParams.acquirer_id') || get_json_object(value, '$.ReqParams.qris_merchant_id') as qris_merchant_id,
    -- 仅PH
    -- get_json_object(checkout_detail, '$.qrph_merchant_id') as qrph_merchant_id,

    get_json_object(value, '$.ReqParams.CommonHeader.location.GpsHex8') as gps_hex8,
    get_json_object(value, '$.ReqParams.CommonHeader.location.GpsHex10') as gps_hex10,
    get_json_object(value, '$.ReqParams.merchant_city') as merchant_city
from risk.ods_risk_live_kafka_gateway_req_rsp_di_v2
where grass_region = '${region_upper}'
    and dt >= '${limit_date}'
    and tn = '${region_lower}_live_spp_risk_gateway_req_rsp_spp'
    and scene_id = '80016'
    and char_length(get_json_object(value, '$.Req.RiskReqHeader.FlowNo')) > 0
    and cast(get_json_object(value, '$.Req.RiskReqHeader.ReqTime') as bigint) > 0
    and char_length(get_json_object(value, '$.ReqParams.CommonHeader.platform_user_id')) > 0
;

create or replace temporary view gps_hex8_view as
select 
    flow_no,
    scene_id,
    req_time,

    unique_merchant_id,
    unique_merchant_id_string,
    national_merchant_id,
    qris_merchant_id,
    
    'gps-hex8' as verify_type,
    case when t2.change_type = 1 then '-9999' 
        when t2.change_type = 0 then user_id
    end as flag
from filter_view t1 inner join 
(
    select 
        flag_key,
        change_type
    from risk.dimension_merchant_buyer_statistics_join_hive_history_incr
    where grass_region = '${region_upper}'
        and grass_date = '${bizdate}'
        and flag = 'hex8'
) t2 on t1.gps_hex8 = t2.flag_key
where char_length(t1.gps_hex8) > 0
;

create or replace temporary view gps_hex10_view as
select 
    flow_no,
    scene_id,
    req_time,

    unique_merchant_id,
    unique_merchant_id_string,
    national_merchant_id,
    qris_merchant_id,
    
    'gps-hex10' as verify_type,
    case when t2.change_type = 1 then '-9999' 
        when t2.change_type = 0 then user_id
    end as flag
from filter_view t1 inner join 
(
    select 
        flag_key,
        change_type
    from risk.dimension_merchant_buyer_statistics_join_hive_history_incr
    where grass_region = '${region_upper}'
        and grass_date = '${bizdate}'
        and flag = 'hex10'
) t2 on t1.gps_hex10 = t2.flag_key
where char_length(t1.gps_hex10) > 0
;

create or replace temporary view config_address_view as
select 
    flow_no,
    scene_id,
    req_time,

    unique_merchant_id,
    unique_merchant_id_string,
    national_merchant_id,
    qris_merchant_id,
    
    'config-address' as verify_type,
    case when (t2.mp_address is null or t2.mp_address = '') then '0'
	    when t1.merchant_city is null or t1.merchant_city = '' then '0'
        when (
            position(replace(regexp_replace(lower(t2.mp_address), 'kota |kab. |kab ', ''), ' ', '') in replace(regexp_replace(lower(t1.merchant_city), 'kota |kab. |kab ', ''), ' ', '')) > 0
		    or position(replace(regexp_replace(lower(t1.merchant_city), 'kota |kab. |kab ', ''), ' ', '') in replace(regexp_replace(lower(t2.mp_address), 'kota |kab. |kab ', ''), ' ', '')) > 0
		) then '0'
        else user_id
    end as flag
from filter_view t1 inner join 
(
    select 
        flag_key,
        case when change_type = 0 then '' else cast(unbase64(flag_object) as string) end as mp_address
    from risk.dimension_merchant_buyer_statistics_join_hive_history_incr
    where grass_region = '${region_upper}'
        and grass_date = '${bizdate}'
        and flag = 'address'
) t2 on t1.user_id = t2.flag_key
;

create or replace temporary view union_view as
select * from gps_hex8_view 
union all 
select * from gps_hex10_view
union all 
select * from config_address_view
;

create or replace temporary view combine_view as
select 
    substr(md5(unique_merchant_id), 0, 2) || '_1_' || verify_type || '_' || unique_merchant_id || '_' || cast(req_time as string) || '_' || flow_no as rowkey,
    flag,
    req_time * 1000 as ts
from union_view
where char_length(unique_merchant_id) > 0
union all 
select 
    substr(md5(unique_merchant_id_string), 0, 2) || '_2_' || verify_type || '_' || unique_merchant_id_string || '_' || cast(req_time as string) || '_' || flow_no as rowkey,
    flag,
    req_time * 1000 as ts
from union_view
where char_length(unique_merchant_id_string) > 0
union all 
select 
    substr(md5(national_merchant_id), 0, 2) || '_3_' || verify_type || '_' || national_merchant_id || '_' || cast(req_time as string) || '_' || flow_no as rowkey,
    flag,
    req_time * 1000 as ts
from union_view
where char_length(national_merchant_id) > 0
union all 
select 
    substr(md5(qris_merchant_id), 0, 2) || '_4_' || verify_type || '_' || qris_merchant_id || '_' || cast(req_time as string) || '_' || flow_no as rowkey,
    flag,
    req_time * 1000 as ts
from union_view
where char_length(qris_merchant_id) > 0
;

insert overwrite ${SCHEMA}.spp_merchant_buyer_statistics_join_hive_history_incr partition(grass_region = '${region_upper}', grass_date = '${bizdate}')
select 
    rowkey,
    flag as spp_80016,
    ts
from combine_view
;