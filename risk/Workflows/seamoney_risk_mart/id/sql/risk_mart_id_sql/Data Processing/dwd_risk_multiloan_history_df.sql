------------------------------------------------------------------------
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2024-04-09
-- Description:         [ID]Multi-Head Product离线指标，将SPL/BCL的历史数据, 汇总进multiloan查询数据源中，历史数据只需要跑一次
-- Data Granularity:    request_id明细数据
-- PRD:                 https://jira.shopee.io/browse/SPFDT-35534       
------------------------------------------------------------------------

drop table if exists ${SCHEMA}.dwd_risk_multiloan_history_df;
create table ${SCHEMA}.dwd_risk_multiloan_history_df stored as orc as
--SPL
select t1.flow_no
        ,t1.req_time
        ,t2.ktp_no
        ,t2.phone
        ,'1692180814324' as app_id
from
(   select
        flow_no
        ,req_time
    from
        (
            select
                request_id as flow_no
                ,request_time as req_time
                ,row_number() over (partition by request_id order by request_time desc) as rk
            from risk.dwd_risk_id_uw_spl_process_di_dist
            where
                coalesce(policy_status, 1) <= 2
                and region = 'ID'
                and app_id = 'kredit'
                and alias like 'IAO%'
                and result in ('Approve', 'Reject')
                and grass_date >= '2021-07-01'
                and grass_date <= '2023-08-23'
                and length(request_id) > 0
                and request_time * 1000 < 1692778625841
        ) t
    where rk = 1
) t1
inner join
(
    select
        flow_no
        ,req_time
        ,ktp_no
        ,phone
    from
        (
            select
                flow_no
                ,req_time
                ,get_json_object (value, '$.ReqParams.id_card_no') as ktp_no
                ,get_json_object (value, '$.ReqParams.PhoneNo') as phone
                ,row_number() over (partition by flow_no order by req_time desc) as rk
            from risk.ods_risk_live_kafka_gateway_req_rsp_di_v2
            where
                grass_region = 'ID'
                and tn = 'id_live_credit_risk_gateway_req_rsp_kredit'
                and scene_id in ('10011', '10061')
                and grass_date >= '2021-07-01'
                and grass_date <= '2023-08-23'
                and length(flow_no) > 0
        ) t
    where rk = 1
) t2
on t1.flow_no = t2.flow_no
--BCL
union all
select
    tt1.flow_no
    ,tt1.req_time
    ,tt2.ktp_no
    ,tt2.phone
    ,'1692176173197' as app_id
from
    (
        select
            flow_no
            ,req_time
        from
            (
                select
                    request_id as flow_no
                    ,request_time as req_time
                    ,row_number() over (partition by request_id order by request_time desc) as rk
                from risk.dwd_risk_id_uw_bcl_process_di_dist
                where
                    grass_date >= '2021-07-01'
                    and grass_date <= '2023-08-23'
                    and coalesce(policy_status, 1) <= 2
                    and region = 'ID'
                    and app_id = 'spj'
                    and alias like 'IBO%'
                    and get_json_object (rsp, '$.DAJSONDocument.OUTPUT.underwriting_decisions.value') in ('Approve', 'Reject')
                    and length(request_id) > 0
                    and request_time * 1000 < 1692777296730
            )
        where rk = 1
    ) tt1
    inner join (
        select
            flow_no
            ,req_time
            ,ktp_no
            ,phone
        from
            (
                select
                    flow_no
                    ,req_time
                    ,get_json_object (value, '$.ReqParams.id_card_no') as ktp_no
                    ,get_json_object (value, '$.ReqParams.PhoneNo') as phone
                    ,row_number() over (partition by flow_no order by req_time desc) as rk
                from risk.ods_risk_live_kafka_gateway_req_rsp_di_v2
                where
                    grass_region = 'ID'
                    and tn = 'id_live_credit_risk_gateway_req_rsp_spj'
                    and scene_id in ('10001')
                    and grass_date >= '2021-07-01'
                    and grass_date <= '2023-08-23'
                    and length(flow_no) > 0
            )
        where rk = 1
    ) tt2 on tt1.flow_no = tt2.flow_no
;
