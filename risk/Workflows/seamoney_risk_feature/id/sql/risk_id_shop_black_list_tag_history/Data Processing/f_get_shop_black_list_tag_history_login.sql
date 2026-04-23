-- drop table if exists ${SCHEMA}.f_get_shop_black_list_tag_history_login;
-- create table if not exists ${SCHEMA}.f_get_shop_black_list_tag_history_login (
--     rowkey string,
--     is_black string,
--     szdf string
-- ) partitioned by (
--     grass_region string,
--     grass_date string
-- ) stored as parquet;

alter table ${SCHEMA}.f_get_shop_black_list_tag_history_login drop if exists partition(grass_region = '${region_upper}', grass_date < '${delete_limit_date}');

create or replace temporary view filter_view as 
select 
    get_json_object(value, '$.Req.RiskReqHeader.FlowNo') as flow_no,
    get_json_object(value, '$.ReqParams.UserId') as user_id,
    regexp_replace(get_json_object(value, '$.ReqParams.spdf_infra_sz'), '_', '-') as szdf,
    get_json_object(value, '$.ReqParams.LoginTime') as login_ts
from risk.ods_risk_live_kafka_gateway_req_rsp_di_v2 
where grass_region = '${region_upper}'
    and dt >= '${limit_date}'
    and tn = '${region_lower}_live_credit_risk_gateway_req_rsp_shopee'
    and scene_id = '10003'
    and get_json_object(value, '$.ReqParams.LoginResult') = 'success'
    and char_length(get_json_object(value, '$.Req.RiskReqHeader.FlowNo')) > 0
    and char_length(get_json_object(value, '$.ReqParams.UserId')) > 0
    and char_length(get_json_object(value, '$.ReqParams.spdf_infra_sz')) > 0
    and cast(get_json_object(value, '$.ReqParams.LoginTime') as bigint) > 0
;

create or replace temporary view join_view as 
select 
    t1.flow_no,
    t1.user_id,
    t1.szdf,
    t1.login_ts,
    t2.data_source,
    case when t2.status = 1 then '1' else '0' end as is_black
from filter_view t1 join (
    select 
        `data` as szdf,
        status,
        data_source
    from smcdrisk_antifraud.id_pii_blacklist_df
    where run_date in (select max(run_date) from smcdrisk_antifraud.id_pii_blacklist_df)
        and char_length(`data`) > 0
        and status is not null
        and datatype = 'szdf'
        and char_length(data_source) > 0
        group by `data`, status, data_source
    ) t2 on t1.szdf = t2.szdf
;

insert overwrite ${SCHEMA}.f_get_shop_black_list_tag_history_login partition(grass_region='${region_upper}', grass_date = '${bizdate}')
select 
    substring(md5(user_id), 0, 2) || '_' || user_id || '_' || data_source || '_' || login_ts || '_' || flow_no as rowkey,
    is_black,
    szdf
from join_view
where char_length(data_source) > 0
;